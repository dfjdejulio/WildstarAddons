------------------------------------------------------------------------------------------------
-- Client Lua Script for AMPFinder
-- 2014-04-19, Tomii
-- version 1.6.1, 2014-07-02

-- TODO: Save/restore window position. Kinda works but doesn't handle compact windows well.
-- TODO: Get NPC data rather than hardcoding their names
-- TODO: Localize text when possible
-- TODO: Put prices (via item reference tCost?) on the pane as a swappable option
-- TODO: UpdateArrowVendor and Questgiver -- Show the arrow, but also show a message
-- TODO: UpdateArrowVendor - If player doesn't have rep (or prestige) then say so instead of travel
-- TODO: UpdateArrowQuestgiver - Display a message if they're ON the quest and haven't completed it 
-- 			an arrow to the questgiver itself is misleading
-- TODO: update vendor display if you learn an amp with the vendor window open


-- special thanks to:
--   Carbine for the fantastic game
--   WildstarNasa crew for their tutorials
--   Woode, FirefoxMetzger, Sinaloit, MacHaggis, and Tomed on the addon forums
--   Skaar, Dathlan, and the Pulse guild (Dominion - EU) for the AMP listings
--	 Curse.com for their excellent support
--   EVERYONE who's downloaded and given the addon a try
--   all addon authors and enthusiasts everywhere!

-----------------------------------------------------------------------------------------------
 
require "AbilityBook"
require "Episode"
require "Item"
require "Money"
require "Quest"
require "Window"

-----------------------------------------------------------------------------------------------
-- AMPFinder Module Definition
-----------------------------------------------------------------------------------------------
local AMPFinder = {}

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local knCategoryUtilityId 			= 1
local knCategorySupportId 			= 2
local knCategoryDamageId 			= 3
local knCategoryDamageSupportId 	= 4
local knCategoryDamageUtilitytId 	= 5
local knCategorySupportUtilityId 	= 6

local karCategoryToConstantData =
{
	[knCategoryUtilityId] 			= {"LightBulbS",	"spr_AMPS_MiddleGlow_S", 	Apollo.GetString("AMP_Utility"),	"LabelUtility",		},
	[knCategorySupportId]			= {"LightBulbNE",	"spr_AMPS_MiddleGlow_NE",	Apollo.GetString("AMP_Support"), 	"LabelSupport",		},
	[knCategoryDamageId] 			= {"LightBulbNW",	"spr_AMPS_MiddleGlow_NW", 	Apollo.GetString("AMP_Assault"),	"LabelAssault",		},
	[knCategoryDamageSupportId] 	= {"LightBulbN",	"spr_AMPS_MiddleGlow_N", 	Apollo.GetString("AMP_Hybrid"),		"LabelHybrid",		},
	[knCategoryDamageUtilitytId] 	= {"LightBulbSE",	"spr_AMPS_MiddleGlow_SW", 	Apollo.GetString("AMP_PvPOffense"),	"LabelPvPOffense",	},
	[knCategorySupportUtilityId] 	= {"LightBulbSW",	"spr_AMPS_MiddleGlow_SE", 	Apollo.GetString("AMP_PvPDefense"),	"LabelPvPDefense",	},
}

local knFastDelay = 0.05
local knSlowDelay = 0.5

local knAmpWarrior		= 394
local knAmpEngineer		= 395
local knAmpMedic		= 396
local knAmpStalker		= 397
local knAmpEsper		= 398
local knAmpSpellslinger	= 399

local knClassWarrior	= GameLib.CodeEnumClass.Warrior 	-- 1
local knClassEngineer	= GameLib.CodeEnumClass.Engineer	-- 2
local knClassEsper		= GameLib.CodeEnumClass.Esper		-- 3
local knClassMedic		= GameLib.CodeEnumClass.Medic		-- 4
local knClassStalker 	= GameLib.CodeEnumClass.Stalker		-- 5
local knClassSpellslinger = GameLib.CodeEnumClass.Spellslinger -- 7

local karClassNames = {
	[knClassWarrior]	= Apollo.GetString("ClassWarrior"),
	[knClassEngineer]	= Apollo.GetString("ClassEngineer"),
	[knClassEsper]		= Apollo.GetString("ClassESPER"),
	[knClassMedic]		= Apollo.GetString("ClassMedic"),
	[knClassStalker]	= Apollo.GetString("ClassStalker"),
	[knClassSpellslinger] = Apollo.GetString("ClassSpellslinger"),
}

-- These are exile locations but we're using them as shorthand for both sides
local knLocAutolearned  =  1
local knLocGlenview		=  2 -- starter 1a
local knLocTremor		=  3 -- starter 1b
local knLocQuest		=  4 -- starter 1a/1b
local knLocGallow		=  5 -- starter 2a
local knLocSylvan		=  6 -- starter 2b
local knLocGallowSylvan	=  7 -- starter 2a/2b
local knLocSkywatch		=  8 -- galeras
local knLocThermock		=  9 -- whitevale
local knLocWalkers		= 10 -- farside
local knLocBravo		= 11 -- farside 2
local knLocFoolsHope	= 12 -- wilderrun
local knLocFCON			= 13 -- thayd
local knLocCommodity	= 14 -- thayd
local knLocUnknown		= 15

local knPaneAlgoroc = 17
local knPaneAlgorocQ = -17
local knPaneAuroria = 6
local knPaneCelestion = 5
local knPaneCelestionQ = -5
local knPaneDeradune = 15
local knPaneDeraduneQ = -15
local knPaneEllevar = 7
local knPaneEllevarQ = -7
local knPaneFarside = 28
local knPaneFarsideD = 88 -- Farside: Virtue's Landing (Dominion)
local knPaneFarsideE = 87 -- Farside: Walker's Landing (Exiles)
local knPaneGaleras = 16
local knPaneIllium = 78
local knPaneIlliumC = -78
local knPaneThayd = 14
local knPaneThaydC = -14
local knPaneWhitevale = 2
local knPaneWilderrun = 26
local knPaneComplete 	= -9999
local knPaneCommodity 	= -9998
local knPaneEngineer	= -9991
local knPaneEsper 		= -9992
local knPaneMedic 		= -9993
local knPaneStalker		= -9994
local knPaneSpellslinger= -9995
local knPaneWarrior		= -9996
local ksQuestPanes = knPaneAlgorocQ.."|"..knPaneCelestionQ..
						"|"..knPaneDeraduneQ.."|"..knPaneEllevarQ
local ksVendorPanes = "|"..    --	"|2|5|6|7|14|15|16|17|26|28|78|87|88|"
	knPaneWhitevale.."|"..
	knPaneCelestion.."|"..
	knPaneAuroria.."|"..
	knPaneEllevar.."|"..
	knPaneThayd.."|"..
	knPaneDeradune.."|"..
	knPaneGaleras.."|"..
	knPaneAlgoroc.."|"..
	knPaneWilderrun.."|"..
	knPaneFarside.."|"..
	knPaneIllium.."|"..
	knPaneFarsideE.."|"..
	knPaneFarsideD.."|"

local ktPaneData = {
	[0]					= { "(Current zone)",				nil,			},
	[knPaneAlgoroc] 	= { "Algoroc", 						knLocGallow,	},
	[knPaneAlgorocQ] 	= { "Algoroc (Quest)",				knLocTremor, 	},
	[knPaneAuroria]		= { "Auroria",						knLocSkywatch,	},	 
	[knPaneCelestion]	= { "Celestion",					knLocSylvan,	},
	[knPaneCelestionQ]	= { "Celestion (Quest)",			knLocGlenview,	},
	[knPaneDeradune]	= { "Deradune", 					knLocGallow,	},
	[knPaneDeraduneQ]	= { "Deradune (Quest)", 			knLocGlenview,	},
	[knPaneEllevar]		= { "Ellevar", 						knLocSylvan,	},
	[knPaneEllevarQ]	= { "Ellevar (Quest)",				knLocTremor,	},
	[knPaneFarside]		= { "Farside",						knLocBravo,		},
	[knPaneFarsideD]	= { "Farside: Virtue's Landing",	knLocWalkers,	},
	[knPaneFarsideE]	= { "Farside: Walker's Landing",	knLocWalkers,	},
	[knPaneGaleras]		= { "Galeras",						knLocSkywatch,	},
	[knPaneIllium]		= { "Illium",						knLocFCON,		},
	[knPaneIlliumC]		= { "Illium (Commodity Exch)",		knLocCommodity,	},
	[knPaneThayd]		= { "Thayd",						knLocFCON,		},
	[knPaneThaydC]		= { "Thayd (Commodity Exch)",		knLocCommodity,	},
	[knPaneWhitevale]	= { "Whitevale",					knLocThermock,	},
	[knPaneWilderrun]	= { "Wilderrun",					knLocFoolsHope,	},
	[knPaneComplete]	= { "Rank 2-3 AMPs",				nil,			},
	[knPaneEngineer]	= { "Engineer AMPs",				nil,			},
	[knPaneEsper]		= { "Esper AMPs",					nil,			},
	[knPaneMedic]		= { "Medic AMPs",					nil,			},
	[knPaneStalker]		= { "Stalker AMPs",					nil,			},
	[knPaneSpellslinger]= { "Spellslinger AMPs",			nil,			},
	[knPaneWarrior]		= { "Warrior AMPs",					nil,			},
}

local kiImbueSpellId = 1
local kiAmpCategory = 2
local kiAmpRank = 3
local kiLocation = 4
local kiItemId = 5

local ktUserPrefs = {
	"strFilter",
	"bWindowOpen",
	"bCompact",
}

-- [spellID] = {imbueSpellID, category, rank, knLocation},
local AllAmpData = {		
	[knClassEngineer] = {	
		[57097] = {56798, 5, 2, 10}, -- Blast Back / Walkers
		[57332] = {56787, 2, 3, 15}, -- Boosted Armor / Unknown
		[43210] = {56792, 1, 2, 12}, -- Bust and Move / FoolsHope
		[43214] = {56805, 1, 3, 12}, -- Can't Touch This / FoolsHope
		[43160] = {56785, 3, 3, 12}, -- Cruisin for a Bruisin / FoolsHope
		[57431] = {56816, 6, 2, 13}, -- Defense Protocol / FCON
		[43187] = {56793, 1, 2, 8}, -- Deft Restoration / Skywatch
		[57446] = {56786, 6, 2, 13}, -- Dirty Tricks / FCON
		[43192] = {56808, 5, 3, 13}, -- Disciplined Soldier / FCON
		[60639] = {-1, 2, 3, 1}, -- Disruptive Module / Autolearned
		[57334] = {56788, 2, 2, 4}, -- Enmity / Quest
		[43211] = {56781, 4, 3, 12}, -- Exploit Weakness / FoolsHope
		[57204] = {56790, 3, 2, 13}, -- Explosive Ammo / FCON
		[43216] = {57550, 3, 2, 10}, -- Extra Hurtin' / Walkers
		[57472] = {56804, 4, 2, 15}, -- Forceful Impact / Unknown
		[43247] = {56811, 4, 2, 13}, -- Hamstring Tear / FCON
		[57395] = {56801, 1, 3, 10}, -- Hardened Resolve / Walkers
		[57437] = {56784, 3, 2, 5}, -- Harmful Hits / Gallow
		[43167] = {56795, 6, 2, 7}, -- Helpin' Hand / GallowSylvan
		[57427] = {70828, 1, 2, 9}, -- Keep it Moving / Thermock
		[43219] = {56803, 4, 2, 8}, -- Keep on Truckin' / Skywatch
		[57178] = {70829, 5, 3, 12}, -- Keep up the Pace / FoolsHope
		[57407] = {56807, 5, 2, 13}, -- No Pain, No Pain / FCON
		[57185] = {56810, 6, 3, 13}, -- Protection by Deflection / FCON
		[57387] = {56815, 2, 2, 8}, -- Quick Restart / Skywatch
		[57314] = {56813, 4, 3, 13}, -- Razor's Edge / FCON
		[57098] = {57549, 1, 2, 6}, -- Reckless Dash / Sylvan
		[43207] = {56800, 1, 2, 12}, -- Reflexive Actions / FoolsHope
		[43205] = {56789, 2, 2, 8}, -- Rejuvenating Rain / Skywatch
		[60640] = {-1, 1, 3, 1}, -- Repairbot / Autolearned
		[57262] = {56812, 2, 2, 12}, -- Repeat Business / FoolsHope
		[43189] = {56796, 2, 2, 4}, -- Reroute Power / Quest
		[57468] = {56779, 5, 2, 8}, -- Self-Destruct / Skywatch
		[43095] = {57551, 3, 2, 9}, -- Shrapnel Rounds / Thermock
		[43091] = {56799, 6, 3, 9}, -- Survival Instincts / Thermock
		[60638] = {-1, 3, 3, 1}, -- Target Acquisition / Autolearned
		[57168] = {56802, 4, 2, 15}, -- The Zone / Unknown
		[57433] = {56791, 2, 3, 12}, -- Try and Hurt Me! / FoolsHope
		[57180] = {56814, 6, 2, 13}, -- Turn the Tables / FCON
		[57424] = {56809, 3, 3, 13}, -- Unstable Volatility / FCON
		[57326] = {56806, 5, 2, 13}, -- Volatile Armor / FCON
		[57403] = {56782, 3, 2, 4}, -- Volatility Rising / Quest
	},	
	[knClassEsper] = {	
		[41579] = {56746, 4, 3, 12}, -- B-I-N-G-O / FoolsHope
		[41581] = {56738, 6, 2, 12}, -- Bounce Back / FoolsHope
		[41593] = {56737, 2, 2, 4}, -- Build Up / Quest
		[57227] = {71139, 1, 3, 12}, -- Cheat Death / FoolsHope
		[41595] = {56736, 2, 3, 10}, -- Companion / Walkers
		[41584] = {56740, 1, 2, 12}, -- Defensive Maneuvers / FoolsHope
		[57777] = {56752, 5, 2, 13}, -- Duelist / FCON
		[57191] = {71140, 1, 3, 12}, -- Feedback / FoolsHope
		[41587] = {56732, 3, 3, 10}, -- Figment / Walkers
		[41600] = {56749, 4, 3, 10}, -- Fisticuffs / Walkers
		[33272] = {-1, 1, 3, 1}, -- Fixation / Autolearned
		[57073] = {71129, 2, 2, 8}, -- Focus Mastery / Skywatch
		[56992] = {56729, 3, 2, 15}, -- Follow Through / Unknown
		[57806] = {56756, 6, 2, 13}, -- From the Grave / FCON
		[57159] = {71137, 2, 2, 9}, -- Hard to Hit / Thermock
		[57077] = {56733, 2, 3, 15}, -- Healing Touch / Unknown
		[57089] = {56735, 2, 2, 7}, -- Inspiration / GallowSylvan
		[57747] = {71141, 1, 2, 9}, -- Inspirational Charge / Thermock
		[57213] = {56739, 1, 2, 5}, -- Iron Reflexes / Gallow
		[41599] = {56734, 6, 3, 8}, -- Me Worry? / Skywatch
		[41594] = {56743, 1, 2, 8}, -- Mental Overflow / Skywatch
		[33366] = {-1, 2, 3, 1}, -- Mirage / Autolearned
		[41586] = {56741, 1, 2, 4}, -- Molasses / Quest
		[41598] = {56744, 4, 2, 9}, -- No Pain No... / Thermock
		[57788] = {56751, 5, 2, 13}, -- No Remorse / FCON
		[41590] = {56747, 4, 2, 12}, -- Not Snackworthy / FoolsHope
		[57346] = {56757, 6, 3, 13}, -- Payback / FCON
		[57336] = {56755, 6, 2, 13}, -- Psychic Barrier / FCON
		[61006] = {56731, 3, 3, 4}, -- Quick Response / Quest
		[57027] = {56728, 3, 2, 6}, -- Reckful / Sylvan
		[57019] = {71123, 4, 2, 7}, -- Refund / GallowSylvan
		[41589] = {56742, 5, 3, 10}, -- Rupture / Walkers
		[57792] = {56754, 5, 2, 13}, -- Shocked / FCON
		[56943] = {56727, 5, 3, 12}, -- Slow it Down / FoolsHope
		[57133] = {71131, 2, 2, 9}, -- Spectral Shield / Thermock
		[70523] = {-1, 3, 3, 1}, -- Spectral Swarm / Autolearned
		[57295] = {71138, 6, 2, 8}, -- Stand Strong / Skywatch
		[57012] = {71121, 3, 2, 9}, -- Superiority / Thermock
		[57745] = {56748, 4, 2, 15}, -- Tactician / Unknown
		[57037] = {56730, 5, 2, 15}, -- The Humanity / Unknown
		[57005] = {71120, 3, 2, 9}, -- The Power! / Thermock
		[57786] = {56750, 3, 2, 13}, -- True Sight / FCON
	},	
	[knClassMedic] = {	
		[59034] = {57510, 6, 3, 13}, -- Acerbic Injection / FCON
		[58962] = {57495, 1, 3, 10}, -- Amorphous Barrier / Walkers
		[58907] = {-1, 3, 3, 1}, -- Annihilation / Autolearned
		[59014] = {57503, 5, 2, 13}, -- Antigen Isolation / FCON
		[58943] = {57485, 2, 2, 4}, -- Armor Coating / Quest
		[59032] = {57508, 6, 2, 13}, -- Attrition / FCON
		[59012] = {57506, 5, 3, 13}, -- Chemical Burn / FCON
		[59033] = {57509, 1, 2, 13}, -- Concerted Effort / FCON
		[58882] = {57481, 3, 2, 15}, -- Core Damage / Unknown
		[58912] = {57480, 3, 3, 10}, -- Danger Zone / Walkers
		[59036] = {57512, 6, 3, 13}, -- Debilitative Armor / FCON
		[58980] = {57496, 6, 2, 15}, -- Defense Mechanism / Unknown
		[60676] = {57511, 2, 2, 13}, -- Emergency / FCON
		[58942] = {57484, 6, 2, 9}, -- Emergency Extraction / Thermock
		[58984] = {57476, 3, 2, 4}, -- Empowering Aura / Quest
		[59016] = {57505, 5, 3, 13}, -- Energy Pulse / FCON
		[58909] = {57477, 5, 2, 8}, -- Entrapment / Skywatch
		[58976] = {57492, 1, 3, 6}, -- Health Probes / Sylvan
		[58946] = {57488, 2, 3, 12}, -- Hypercharge / FoolsHope
		[60797] = {60798, 3, 2, 10}, -- In Flux / Walkers
		[58914] = {57482, 3, 3, 15}, -- Meltdown / Unknown
		[58978] = {57494, 4, 2, 8}, -- Null Zone / Skywatch
		[58999] = {57501, 4, 3, 12}, -- Power Cadence / FoolsHope
		[58994] = {57500, 4, 2, 12}, -- Power Converter / FoolsHope
		[58974] = {-1, 1, 3, 1}, -- Protection Probes / Autolearned
		[58932] = {57483, 2, 2, 15}, -- Protective Surge / Unknown
		[60393] = {61044, 1, 2, 10}, -- Quick Dodge / Walkers
		[60677] = {57486, 2, 2, 7}, -- Reboot / GallowSylvan
		[60648] = {71142, 3, 2, 9}, -- Recycler / Thermock
		[58977] = {57493, 1, 2, 9}, -- Regenerator / Thermock
		[58940] = {-1, 2, 3, 1}, -- Rejuvenator / Autolearned
		[58910] = {57478, 4, 3, 9}, -- Renewable Probes / Thermock
		[58919] = {71143, 2, 3, 12}, -- Running on Empty / FoolsHope
		[58995] = {57498, 4, 2, 15}, -- Scalpel! Forceps! / Unknown
		[58981] = {57497, 6, 2, 12}, -- Shield Protocol / FoolsHope
		[58965] = {57491, 1, 2, 4}, -- Shield Reboot / Quest
		[58947] = {57490, 1, 2, 12}, -- Solid State / FoolsHope
		[58892] = {57507, 5, 2, 13}, -- Stay With Me / FCON
		[58997] = {57499, 4, 2, 9}, -- Surgical / Thermock
		[60901] = {60899, 2, 2, 10}, -- Transfusion / Walkers
		[58888] = {57479, 3, 2, 5}, -- Victory Spark / Gallow
		[58879] = {57504, 5, 2, 13}, -- Weakness into Strength / FCON
	},	
	[knClassSpellslinger] = {	
		[56645] = {-1, 3, 3, 1}, -- Assassinate / Autolearned
		[57641] = {52103, 2, 2, 4}, -- Augmented Armor / Quest
		[57644] = {52105, 2, 2, 15}, -- Burst Power / Unknown
		[61170] = {52104, 2, 2, 8}, -- Clarity / Skywatch
		[56590] = {61042, 3, 2, 9}, -- Critical Surge / Thermock
		[56716] = {52125, 5, 2, 13}, -- Danger Danger / FCON
		[56609] = {52094, 3, 2, 5}, -- Deadly Chain / Gallow
		[56703] = {52106, 2, 3, 10}, -- Desperation / Walkers
		[57044] = {52114, 6, 2, 10}, -- Enhanced Shields / Walkers
		[57035] = {52110, 1, 2, 8}, -- Evasive Maneuvers / Skywatch
		[56710] = {52112, 6, 3, 7}, -- Final Salvo / GallowSylvan
		[57135] = {52129, 6, 2, 13}, -- Flame Armor / FCON
		[57803] = {52121, 4, 2, 10}, -- Focus Stone / Walkers
		[57085] = {52131, 6, 2, 13}, -- Frost Armor / FCON
		[57223] = {52095, 1, 2, 4}, -- Frost Snap / Quest
		[57772] = {52128, 6, 2, 13}, -- Fury / FCON
		[61163] = {52099, 3, 3, 10}, -- Gunslinger / Walkers
		[56655] = {52124, 5, 3, 13}, -- Headhunter / FCON
		[57339] = {52109, 2, 3, 12}, -- Healing Aura / FoolsHope
		[60956] = {-1, 2, 3, 1}, -- Healing Torrent / Autolearned
		[61351] = {52108, 2, 2, 12}, -- Holy Roller / FoolsHope
		[61172] = {61043, 1, 3, 12}, -- Homeward Bound / FoolsHope
		[57034] = {52111, 6, 3, 4}, -- Hyper Shield / Quest
		[56876] = {52127, 5, 2, 13}, -- Killer / FCON
		[57028] = {52096, 5, 3, 15}, -- Overpower / Unknown
		[56856] = {52130, 5, 2, 13}, -- Penetrating Rounds / FCON
		[56725] = {52117, 4, 2, 15}, -- Power Surge / Unknown
		[57143] = {52118, 4, 2, 9}, -- Preparation / Thermock
		[57138] = {52116, 1, 2, 15}, -- Readiness / Unknown
		[57067] = {52123, 1, 2, 13}, -- Reorient / FCON
		[56692] = {52102, 2, 2, 6}, -- Savior / Sylvan
		[61174] = {52119, 4, 3, 15}, -- Shock & Awe / Unknown
		[57297] = {52113, 1, 3, 15}, -- Speed of the Void / Unknown
		[57072] = {52126, 1, 2, 13}, -- Spell Armor / FCON
		[56580] = {71853, 3, 3, 10}, -- Surge Damage / Walkers
		[61214] = {52120, 4, 3, 12}, -- The One / FoolsHope
		[61162] = {52100, 3, 2, 15}, -- Trigger Fingers / Unknown
		[57075] = {52122, 5, 2, 13}, -- True Sight / FCON
		[57657] = {52115, 4, 2, 10}, -- Urgency / Walkers
		[56600] = {52097, 3, 2, 15}, -- Vengeance / Unknown
		[56973] = {-1, 1, 3, 1}, -- Void Pact / Autolearned
		[57253] = {52101, 3, 2, 12}, -- Withering Magic / FoolsHope
	},	
	[knClassStalker] = {	
		[39642] = {-1, 2, 3, 1}, -- Amplification Spike / Autolearned
		[59389] = {71149, 1, 2, 8}, -- Assassin / Skywatch
		[59341] = {57524, 2, 2, 4}, -- Avoidance Mastery / Quest
		[59346] = {71150, 1, 2, 9}, -- Balanced / Thermock
		[60842] = {57516, 3, 3, 10}, -- Battle Mastery / Walkers
		[40946] = {57540, 5, 2, 13}, -- Blood Rush / FCON
		[39497] = {-1, 1, 3, 1}, -- Bloodthirst / Autolearned
		[59443] = {71158, 6, 2, 9}, -- Boost / Thermock
		[59298] = {71160, 3, 2, 9}, -- Brutality Mastery / Thermock
		[41152] = {57529, 1, 2, 10}, -- Can't Stop This / Walkers
		[38973] = {-1, 3, 3, 1}, -- Clone / Autolearned
		[59338] = {57521, 5, 2, 7}, -- Cutthroat / GallowSylvan
		[59415] = {57535, 6, 2, 15}, -- Dash for Heals! / Unknown
		[40963] = {57515, 3, 2, 8}, -- Devastate / Skywatch
		[41008] = {57523, 2, 2, 15}, -- Don't Call it a Comeback / Unknown
		[59328] = {71163, 2, 2, 9}, -- Empowered Attack Mastery / Thermock
		[59416] = {57536, 4, 3, 12}, -- Enabler / FoolsHope
		[40933] = {57514, 3, 3, 12}, -- Fatal Wounds / FoolsHope
		[59312] = {57518, 4, 2, 12}, -- Follow Up / FoolsHope
		[59339] = {57522, 2, 2, 8}, -- Forbearance / Skywatch
		[59437] = {57541, 5, 3, 13}, -- Heavy Impact / FCON
		[41165] = {57543, 1, 2, 13}, -- Iron Man / FCON
		[59414] = {57534, 5, 3, 9}, -- Keep Up / Thermock
		[40899] = {57513, 3, 2, 5}, -- Killer Instinct / Gallow
		[41079] = {71157, 2, 3, 12}, -- Last Stand / FoolsHope
		[41178] = {57528, 1, 2, 6}, -- Left in the Dust / Sylvan
		[41220] = {57531, 1, 3, 12}, -- Make it Rain / FoolsHope
		[41019] = {57538, 4, 3, 10}, -- My Turn / Walkers
		[59349] = {71166, 3, 2, 8}, -- Onslaught / Skywatch
		[59436] = {57530, 3, 2, 15}, -- Precision / Unknown
		[59459] = {57545, 6, 3, 13}, -- Quick Reboot / FCON
		[59320] = {71159, 2, 2, 7}, -- Regeneration / GallowSylvan
		[59438] = {57542, 4, 2, 13}, -- Riposte / FCON
		[59457] = {57544, 6, 2, 13}, -- Stay Afloat / FCON
		[59417] = {57537, 4, 2, 12}, -- Stealth Mastery / FoolsHope
		[59394] = {57527, 1, 3, 10}, -- Stealth Regen / Walkers
		[59460] = {57546, 6, 3, 13}, -- Strong-Legged / FCON
		[59335] = {71161, 6, 2, 9}, -- Tech Mastery / Thermock
		[41139] = {57520, 2, 3, 15}, -- That's All You Got? / Unknown
		[41180] = {57517, 5, 2, 4}, -- Trail of Cinders / Quest
		[59400] = {57532, 4, 2, 4}, -- Unfair Advantage / Quest
		[59435] = {57539, 5, 2, 13}, -- Who's Next? / FCON
	},	
	[knClassWarrior] = {	
		[59148] = {71370, 6, 2, 9}, -- Anti-Magic Armor / Thermock
		[59071] = {51531, 3, 3, 10}, -- Armor Shred / Walkers
		[59058] = {51647, 3, 2, 9}, -- Bloodlust / Thermock
		[59170] = {-1, 2, 3, 1}, -- Bolstering Strike / Autolearned
		[59144] = {51685, 6, 3, 13}, -- Bring It / FCON
		[59188] = {51608, 1, 2, 7}, -- Bust Out / GallowSylvan
		[59210] = {51611, 1, 3, 10}, -- Can't Stop, Won't Stop / Walkers
		[59054] = {51527, 5, 2, 8}, -- Cheap Shot / Skywatch
		[59105] = {60973, 5, 2, 13}, -- Cornered / FCON
		[59077] = {51534, 3, 2, 12}, -- Detonate / FoolsHope
		[59209] = {51610, 4, 2, 12}, -- Energy Banks / FoolsHope
		[59106] = {60976, 5, 2, 13}, -- Festering Blade / FCON
		[59143] = {51684, 2, 3, 13}, -- Fortify / FCON
		[59159] = {51570, 2, 2, 4}, -- Full Defense / Quest
		[59160] = {51571, 2, 2, 6}, -- Full Force / Sylvan
		[59087] = {51648, 4, 3, 12}, -- Fury / FoolsHope
		[59177] = {51581, 6, 2, 10}, -- Health Sponge / Walkers
		[59178] = {51582, 2, 2, 15}, -- Impenetrable / Unknown
		[59126] = {71148, 5, 2, 7}, -- Killing Spree / GallowSylvan
		[59137] = {51683, 2, 2, 13}, -- Kinetic Buffer / FCON
		[59208] = {59161, 4, 2, 15}, -- Kinetic Burst / Unknown
		[59197] = {51609, 1, 2, 15}, -- Kinetic Drive / Unknown
		[59045] = {71144, 3, 3, 12}, -- Kinetic Fury / FoolsHope
		[59070] = {51528, 3, 2, 5}, -- Laceration / Gallow
		[59154] = {51574, 2, 2, 15}, -- MKII Battle Suit / Unknown
		[59121] = {61008, 1, 3, 13}, -- No Escape / FCON
		[59082] = {51649, 4, 3, 12}, -- Overwhelming Presence / FoolsHope
		[59062] = {51515, 3, 2, 4}, -- Power Hitter / Quest
		[59204] = {-1, 1, 3, 1}, -- Power Link / Autolearned
		[59053] = {51526, 3, 2, 5}, -- Radiate / Gallow
		[59122] = {61009, 5, 3, 13}, -- Recklessness / FCON
		[59165] = {71146, 6, 2, 9}, -- Reserve Power / Thermock
		[59136] = {51607, 1, 2, 7}, -- Shock Absorber / GallowSylvan
		[59129] = {51682, 1, 2, 13}, -- Speed Burst / FCON
		[59142] = {71147, 6, 3, 10}, -- Spiked Armor / Walkers
		[59092] = {51650, 4, 2, 8}, -- Stance Dancer / Skywatch
		[59104] = {60982, 5, 3, 13}, -- Sunder / FCON
		[59051] = {71145, 4, 2, 7}, -- Sure Shot / GallowSylvan
		[59176] = {51580, 2, 3, 15}, -- To the Pain / Unknown
		[59072] = {-1, 3, 3, 1}, -- Tremor / Autolearned
		[59215] = {51612, 1, 2, 4}, -- Unyielding / Quest
		[59166] = {51572, 6, 2, 6}, -- Vigor / Sylvan
	},	
}

local kiEpisodeNum = 1
local kiEpisodeQuestgiver = 2
local kiEpisodeName = 3
local kiEpisodeQuest1 = 4
local kiEpisodeQuest2 = 5
local kiEpisodeQuest3 = 6
local ktEpisodeInfo = {  -- 541, 309 = knPaneCelestionQ, knPaneDeraduneQ
	[knPaneDeraduneQ]	= {309, "Apprentice Laveka", "Moodies!", 3302, 3304, 5799},
	[knPaneAlgorocQ]	= {392, "Pappy Grizzleston", "Loftite Rush", 4609, 4541, 0},
	[knPaneEllevarQ]	= {538, "Guardian Zelcon", "The Unforgiving Storm", 6575, 6576, 6577},
	[knPaneCelestionQ]	= {541, "Arwick Redleaf", "Greenbough's Guardian", 6670, 6671, 6672},
}

local karEpisodeTitles = {
	-- ep 309, deradune
	[3302] = "Mojo Moodies",
	[3304] = "Tamolo's Necromojo",
	[5799] = "The Staff and the Shaman",
	-- ep 392, algoroc
	[4609] = "The Loftite Hunt Begins",
	[4541] = "Troublesome Tremors",
	-- ep 538, ellevar
	[6575] = "A Healing Hand",
	[6576] = "The Storm's Power",
	[6577] = "Unfortunate Force",
	-- ep 541, celestion
	[6670] = "Reclaiming Greenbough",
	[6671] = "A Fiery Escape",
	[6672] = "Greenbough Guardian",
}

local knCondQuest = 1
local knCondReputation = 2
local knCondPrestige = 3
local knCondVendor = 4
local knCondQuestgiver = 5
local knCondAMP = 6

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function AMPFinder:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
    return o
end

function AMPFinder:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {} -- "AbilityAMPs" no longer absolutely needed
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
-----------------------------------------------------------------------------------------------
-- AMPFinder OnLoad
-----------------------------------------------------------------------------------------------
function AMPFinder:OnLoad()
 	self.xmlDoc = XmlDoc.CreateFromFile("AMPFinder.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self)
end

-----------------------------------------------------------------------------------------------
-- AMPFinder OnDocumentReady
-----------------------------------------------------------------------------------------------
function AMPFinder:OnDocumentReady()
	self.wndAMPFilter = nil
	self.wndAMPTooltip = nil
	self.timerTooltip = nil
	if (self.bWindowOpen == nil) then self.bWindowOpen = false end
	if (self.strFilter == nil) then self.strFilter = "" end
	self.nUserSelectedPane = 0
	self.nDisplayedPane = 0
	self.TimerSpeed = knSlowDelay
	self.idleTicks = 0
	self.tPlayerPos = { x=0, z=0, }
	self.nHeading = 0
	self.wndHover = nil
	self.wndLeave = nil
	if (self.bCompact == nil) then self.bCompact = false end
	self.nCompleteDisplayMode = 1
	self.bInitialShow = true
	self.bAmpLocations = false
	self.LocationToVendor = {}
	-- self.nIntentionalDelay = 10 -- testing
	self.bDebugMessaged = false
	
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "AmpFinderForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
		-- don't show it on open, let user open it
	    self.wndMain:Show(false)
		self.wndMain:FindChild("PickerListFrame"):Show(false)
		self.wndMain:FindChild("CompactBtn"):SetCheck(true)
		self.wndMain:FindChild("MiniFrame"):Show(false)
		self.wndMain:FindChild("ClassListFrame"):Show(false)
		
		self.wndMain:FindChild("PickerBtn"):Enable(false) -- Disable, will be enabled on setamploc
		self.wndMain:FindChild("ClassFrame"):FindChild("ClassButton"):Enable(false)
	
		Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
		
		Apollo.RegisterEventHandler("AMPFinder_ShowHide", "OnInterfaceMenuShowHide", self)
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
		
		Apollo.RegisterSlashCommand("ampfinder", "OnSlashCommand", self)
		
		self.timerTooltip = ApolloTimer.Create(1.5, false, "AMPFinderTooltipClose", self)
		
		self.timerInit = ApolloTimer.Create(knSlowDelay, true, "SetAmpLocations", self)
		self.timerInit:Start()	
	
		self:HookAMPWindow()
		self:HookTooltips()
	end
end

-- returns 'true' if amp locations were set on this pass.
function AMPFinder:SetAmpLocations()
	if (self.bAmpLocations) then return false end
	
	--[[
	self.nIntentionalDelay = self.nIntentionalDelay - 1
	if (self.nIntentionalDelay > 0) then 
		Print("Intentional testing delay. "..self.nIntentionalDelay.." ticks remaining.")
		return false
	end	
	--]]	
	
	local unitPlayer = GameLib.GetPlayerUnit()
	if (unitPlayer == nil) then return false end  -- if GetPlayerUnit() is undefined then we can't finish
	local intClass = unitPlayer:GetClassId()
	if (intClass == nil) then return false end
	local faction = unitPlayer:GetFaction()
	if (faction == nil) then return false end

	self.nClass = intClass
	self.nClassDisplayed = intClass
	self.nFaction = faction

	self.tMyClassAmps = AllAmpData[intClass]
	
	if (faction == Unit.CodeEnumFaction.ExilesPlayer) then
		---- EXILE VENDORS ---
		self.LocationToVendor = {
			[knLocFCON] =		{	{ "Thayd",		"FCON Headquarters",	4211.52, -2254.72,	"Supply Officer Clayre",		nil},				},
			[knLocFoolsHope] =	{	{ "Wilderrun",	"Fool's Hope",			2074.86, -1729.20,	"Merchant Snowglimmer",			"Wilderrun Expedition"},	},
			[knLocGallow] = 	{	{ "Algoroc",	"Gallow",				4085.17, -3938.71,	"Merchant Clara Clearfield",	"The Algoroc Accord"},	},
			[knLocGlenview] = 	{	{ "Celestion",	"Glenview's Bulwark",	1028.70, -3052.39,	"(Questline) Reclaiming Greenbough", nil},			},
			[knLocSkywatch] = 	{	{ "Galeras",	"Skywatch",				5758.36, -2579.27,	"Provisions Officer Windfree",	"OPERATION: Galeras"},	},
			[knLocSylvan] =		{	{ "Celestion",	"Sylvan Glade",			2706.62, -2405.68,	"Melri Gladewalker",			"Protectors of Celestion"},	},
			[knLocThermock] =	{	{ "Whitevale",	"Thermock Hold",		4584.49, -790.67,	"Fenan Sunstrider",				"The Whitevale Frontier"},	},
			[knLocTremor] = 	{	{ "Algoroc",	"Tremor Ridge",			3767.50, -4645.34,	"(Questline) The Loftite Hunt Begins", nil},			},
			[knLocWalkers] =	{	{ "Farside",	"Walker's Landing", 	5899.68, -4946.27,	"Reya Resinbough",				"Farside Sector"},		},
			[knLocBravo] =		{	{ "Farside",	"Touchdown Site Bravo",	4305.31, -5652.43,	"Provisioner Zanogez",			"Farside Sector"},		},
			[knLocCommodity] =	{
				{ "Thayd",		"Academy Corner",		4294.63, -2405.07,	"Commodities Broker Thualla",	nil},
				{ "Thayd",		"Arborian Gardens",		3778.36, -2026.74, 	"Commodities Broker Jaryth",	nil},
				{ "Thayd",		"Fortune's Ground",		4035.35, -1833.44,	"Commodities Broker Dusa",		nil},
			},
		}			
	elseif (faction == Unit.CodeEnumFaction.DominionPlayer) then
		---- DOMINION VENDORS ----
		self.LocationToVendor = {
			[knLocFCON] = 		{	{ "Illium",		"Legion's Way", 		-2856.84, -495.14,	"Supply Officer Phenoxia",		nil},				},
			[knLocFoolsHope] =	{	{ "Wilderrun",	"Fort Vigilance",		1270.62, -2012.74,	"Provisioner Jazira",			"The Wilderrun Campaign"},	},
			[knLocGallow] =		{	{ "Deradune",	"Bloodfire Village",	-5621.64, -710.04,	"Mika",							"The Deradune Watch"},	},
			[knLocGlenview] =	{	{ "Deradune",	"Spearclaw Post",		-5487.2, -1088.3,	"(Quest) Mojo Moodies",			nil},				},
			[knLocSkywatch] =	{	{ "Auroria",	"Hycrest",				-2431, -1884.85,	"Merchant Voxic",				"Auroria Province"},		},
			[knLocSylvan] =		{	{ "Ellevar",	"Lightreach Mission",	-2548, -3501.42,	"Lady Saphis",					"The Ellevar Sanction"},	},
			[knLocThermock] =	{	{ "Whitevale",	"Palerock Post",		2137.97, -754.56,	"Zephix",						"The Whitevale Offensive"},	},
			[knLocTremor] =		{	{ "Ellevar",	"Vigilant's Stand",		-3175.2, -3670.9,	"(Quest) A Healing Hand",		nil},				},
			[knLocWalkers] =	{	{ "Farside",	"Virtue's Landing", 	5353.69, -4555.38,	"Dakahari",						"MISSION: Farside"},		},
			[knLocBravo] =		{	{ "Farside",	"Sovereign's Landing",	4041.86, -5197.45,	"Merchandiser Noriom",			"MISSION: Farside"},		},
			[knLocCommodity] =	{	
				{ "Illium",		"Spaceport Alpha",		-3689.13, -860.79,	"Commodities Broker Lyvire",	nil},
				{ "Illium",		"Fate's Landing",		-2960.37, -1153.7,	"Commodities Broker Kezira",	nil},
				{ "Illium",		"Legion's Way",			-2926.10, -632.32,	"Commodities Broker Larteia",	nil},
			},

		} 
	end

	self.timerInit:Stop()
	self.bAmpLocations = true

	self:CompleteHookup()
end

function AMPFinder:CompleteHookup()
	-- Run by SetAmpLocations as the final stage of setup

	self:HookAMPTooltips()
	self:HookVendorLists()
	
	self.wndMain:FindChild("PickerBtn"):Enable(true)
	self.wndMain:FindChild("ClassFrame"):FindChild("ClassButton"):Enable(true)

	Apollo.RegisterEventHandler("VarChange_ZoneName", 		"OnChangeZone", self)
	Apollo.RegisterEventHandler("SubZoneChanged", 			"OnChangeZone", self)

	Apollo.RegisterEventHandler("PlayerCurrencyChanged",	"OnPlayerCurrencyChanged", self)
	Apollo.RegisterEventHandler("ReputationChanged", 		"OnReputationChanged", self)
	Apollo.RegisterEventHandler("QuestObjectiveUpdated", 	"OnQuestStateChanged", self)
	Apollo.RegisterEventHandler("QuestStateChanged", 		"OnQuestStateChanged", self)
	Apollo.RegisterEventHandler("CharacterUnlockedInlaidEldanAugmentation", "OnAMPChanged", self)
		-- called whenever an AMP is unlocked on the pane

	self.timerPos = ApolloTimer.Create(self.TimerSpeed, true, "UpdateArrow", self)
	
	self:UpdateArrow()
	self:HookPosTrack(false)
	
	self:UpdatePane()
	
	-- todo: debug
	-- if (self.bWindowOpen == true) then self.wndMain:Show(true) end
end

--------------------------------------------------
-- Utility functions 
--------------------------------------------------

local function round(n) 
	return math.floor(n + 0.5)
end

-- Other addons can override these functions if desired~
local function GetAbilityAMPsAddon() 
	local tAddon
	tAddon = Apollo.GetAddon("AbilityAMPs")
	if (tAddon) then return tAddon end
	tAddon = Apollo.GetAddon("GorynychAbilityAMPs")
	if (tAddon) then return tAddon end
	return nil
end

local function GetVendorAddon() 
	local tAddon
	tAddon = Apollo.GetAddon("Vendor")
	if (tAddon) then return tAddon end
	return nil
end

local function GetTooltipsAddon() 
	local tAddon
	tAddon = Apollo.GetAddon("ToolTips")
	if (tAddon) then return tAddon end
	return nil
end

local function GetOptionsAddon() 
	local tAddon
	tAddon = Apollo.GetAddon("OptionsInterface")
	if (tAddon) then return tAddon end
	return nil
end

-- returns 2 if complete, 1 if in progress, 0 if nothing
local function GetQuestStatus(quest)
	local eQuestStatus = quest:GetState()
	if (eQuestStatus == Quest.QuestState_Completed) then
		return 2
	elseif (eQuestStatus == Quest.QuestState_Accepted)
		or (eQuestStatus == Quest.QuestState_Achieved) then
		return 1
	else
		return 0
	end
end

local function IsKeyComplete(nZoneKey) -- used by extendAugmentationTooltip
	local epiInfo = ktEpisodeInfo[nZoneKey]
	local nEp = epiInfo[kiEpisodeNum]
	local tAllEpisodes = QuestLib.GetAllEpisodes(true)
	local epiKey = nil
	for idx, epiEpisode in pairs(tAllEpisodes) do
		if (nEp == epiEpisode:GetId()) then epiKey = epiEpisode end
	end
	local bCompleteAll = false
	if (epiKey ~= nil) then
		local bComplete1 = false
		local bComplete2 = false
		local bComplete3 = false
		if (epiInfo[kiEpisodeQuest3] == 0) then bComplete3 = true end
		
		for idx, queSelected in pairs(epiKey:GetAllQuests()) do
			local nQuestId = queSelected:GetId()
			
			if		(nQuestId == epiInfo[kiEpisodeQuest1]) then 
				if (GetQuestStatus(queSelected)) == 2 then bComplete1 = true end
			elseif	(nQuestId == epiInfo[kiEpisodeQuest2]) then 
				if (GetQuestStatus(queSelected)) == 2 then bComplete2 = true end	
			elseif	(nQuestId == epiInfo[kiEpisodeQuest3]) then
				if (GetQuestStatus(queSelected)) == 2 then bComplete3 = true end
			end
		end
		if (bComplete1 and bComplete2 and bComplete3) then
			bCompleteAll = true
		end
	end
	return bCompleteAll
end

function AMPFinder:GetDistanceSquared(loc)
	local nX = self.tPlayerPos.x - loc[3]
	local nZ = self.tPlayerPos.z - loc[4]
	
	local nDistSq = math.pow(nX, 2) + math.pow(nZ, 2)

	return nDistSq
end

function AMPFinder:GetDegree(loc)
	local nX = loc[3] - self.tPlayerPos.x
	local nZ = loc[4] - self.tPlayerPos.z
	
	local nTheta = math.atan2(nX, -nZ)
	
	if (nTheta > 0) then
		nTheta = (2 * math.pi) - nTheta
	else
		nTheta = -nTheta
	end
	
	local nFace = self.nHeading - nTheta
	if (nFace < 0) then
		nFace = math.pi*2 + nFace
	end	
	local nDegree = nFace * 180 / math.pi
	
	return nDegree
end


function AMPFinder:GetKeyEpisode(nKey)
	-- Will return an episode if it's at least partially complete.
	-- If it's not complete we'll be pointing them there.
	-- It's possible for the episode to be incomplete and still have the amp, though
	local tAllEpisodes = QuestLib.GetAllEpisodes(true)
	local epiKey = nil
	for idx, epiEpisode in pairs(tAllEpisodes) do
		if (nKey == epiEpisode:GetId()) then epiKey = epiEpisode end
	end
	return epiKey
end

--------------------------------------------------
-- IsLearnedByItem(item)
--   returns intLearned, strTier, tAmp
--           2 if learned
--           1 if locked
--           0 if not found
--   strTier is " (Assault Tier 3)" or " (Hybrid A/S Tier 2)"
--------------------------------------------------
function AMPFinder:IsLearnedByItem(item)
	-- lookup the appropriate chart
	-- This will fail for autolearned spells, but you won't have an item for them anyway
	local nClass = item:GetItemType()
	local tAmpData = {}

	if		(nClass == knAmpWarrior)		then tAmpData = AllAmpData[knClassWarrior]
	elseif	(nClass == knAmpEngineer)		then tAmpData = AllAmpData[knClassEngineer]
	elseif	(nClass == knAmpMedic)			then tAmpData = AllAmpData[knClassMedic]
	elseif	(nClass == knAmpStalker)		then tAmpData = AllAmpData[knClassStalker]
	elseif	(nClass == knAmpEsper)			then tAmpData = AllAmpData[knClassEsper]
	elseif	(nClass == knAmpSpellslinger)	then tAmpData = AllAmpData[knClassSpellslinger]
	end
	
	local itemInfo = item:GetDetailedInfo()
	local nImbueId = itemInfo.tPrimary.arSpells[1].splData:GetId()
	
	local nIndex = nil
	for idx, rec in pairs(tAmpData) do
		if (rec[kiImbueSpellId] == nImbueId) then
			nIndex = idx
			break
		end
	end
	if (nIndex == nil) then
		return 0, "", nil
	else
		return self:IsLearnedBySpellId(nIndex, tAmpData[nIndex])
	end
end

--------------------------------------------------
-- IsLearnedBySpellId(nSpellId, tAmpRecord)
--   returns intLearned, strTier, tAmp
--           2 if learned
--           1 if locked
--           0 if not found
--   strTier is " (Assault Tier 3)" or " (Hybrid A/S Tier 2)"
--------------------------------------------------
function AMPFinder:IsLearnedBySpellId(nSpellId, tAmpRecord)
	local boolFound = false
	local boolLearned = false
	local tEldanAugmentationData = AbilityBook.GetEldanAugmentationData(AbilityBook.GetCurrentSpec())
	
	if not tEldanAugmentationData then return end
	
	local strTier = ""
	if (tAmpRecord ~= nil) then
		strTier = " ("..karCategoryToConstantData[ tAmpRecord[kiAmpCategory] ][ 3 ]
			.." Rank " .. tAmpRecord[kiAmpRank] .. ")"
	end
	
	
	local tFoundAmp = nil
	for idx = 1, #tEldanAugmentationData.tAugments do
		local tAmp = tEldanAugmentationData.tAugments[idx]
		
		if (tAmp.nSpellIdAugment == nSpellId) then
			boolFound = true
			tFoundAmp = tAmp
			if tAmp.eEldanAvailability ~= AbilityBook.CodeEnumEldanAvailability.Unavailable then
				boolLearned = true
			end
			
			-- make sure we identify the amp record if tAmpRecord is nil)
			strTier = " ("..karCategoryToConstantData[tAmp.nCategoryId][3].." Rank "
				.. tAmp.nCategoryTier..")"
		end
	end
	
	if (boolFound) then
		if (boolLearned) then
			return 2, strTier, tFoundAmp -- learned
		else 
			return 1, strTier, tFoundAmp -- unlearned
		end
	else 
		return 0, strTier, nil 	 -- if amp is not listed
	end
end


--------------------------------------------------
-- Hook functions
--------------------------------------------------

function AMPFinder:HookAMPWindow()

	local tAbilityAMPs = GetAbilityAMPsAddon() -- Apollo.GetAddon("AbilityAMPs")
	if (tAbilityAMPs == nil) then return end -- can't hook if the addon isn't there
	
	-- change unlocked but non-prerequisited AMPs to blue
	local origRedrawSelections = tAbilityAMPs.RedrawSelections
	
	tAbilityAMPs.RedrawSelections = function(tEldanAugmentationData)
		origRedrawSelections(tEldanAugmentationData)
		
		-- self = AbilityAMPs table
		self.wndAMPFilter = Apollo.LoadForm(self.xmlDoc, "AmpFilterForm", tAbilityAMPs.tWndRefs.wndMain, self)		

		local fBox = self.wndAMPFilter:FindChild("FilterBox")
		if (fBox ~= nil) then
			if (self.strFilter == "") then
				fBox:SetText("Filter...")
				fBox:ClearFocus()
				self.wndAMPFilter:FindChild("FilterClearBtn"):Show(false)
				self.wndAMPFilter:FindChild("SearchIcon"):Show(true)
				self:UpdateAMPWindow(nil)
			else
				fBox:SetText(self.strFilter)
				self.wndAMPFilter:FindChild("FilterClearBtn"):Show(true)
				self.wndAMPFilter:FindChild("SearchIcon"):Show(false)
				fBox:ClearFocus()
				self:UpdateAMPWindow(self.strFilter)
			end
		end 
	end -- end of loop	
end

local function repositionAugmentationTooltip(wndTooltip)
	
	local wndParent = wndTooltip
	while(wndParent:GetParent() ~= nil) do wndParent = wndParent:GetParent() end
	
	local nScreenWidth, nScreenHeight = Apollo:GetScreenSize()
	local parentX, parentY = wndParent:GetPos()
	local nLeft, nTop, nRight, nBottom = wndTooltip:GetAnchorOffsets()
	if ((parentX + nRight + 875) > nScreenWidth) then
		wndTooltip:SetAnchorOffsets(-1125, nTop, -875, nBottom)
	elseif ((parentX + nLeft + 875) < 0) then
		wndTooltip:SetAnchorOffsets(25, nTop, 275, nBottom)
	end
end

local function formatLocation(tLocationData, bCX)
	local strVendorName = tLocationData[5]
	if (bCX) then strVendorName = "the " .. Apollo.GetString("MarketplaceCommodity_CommoditiesExchange") end	
	
	return strVendorName
		.." in "..tLocationData[2]
		..", "..tLocationData[1]							
		.." ("..round(tLocationData[3])
		..", "..round(tLocationData[4])
		..")"
end

local function extendAugmentationTooltip(wndTooltip, wndControl, tAmp)
	-- if amp locations have not been set then we can't give meaningful feedback
	local tAmpFinder = Apollo.GetAddon("AMPFinder")
	if (tAmpFinder.bAmpLocations == false) then return end
	if (tAmpFinder.LocationToVendor[knLocCommodity] == nil) then
		if (tAmpFinder.bDebugMessaged == false) then
			Print("AMP Finder could not get location table - not sure why this happens. Sorry for the inconvenience :( ")
			tAmpFinder.bDebugMessaged = true
		end
		return
	end
	
	local wndParent = wndControl:GetParent()
	local tAugment
	if (tAmp ~= nil) then
		tAugment = tAmp
	else
		tAugment = wndParent:GetData()
	end
	local title = tAugment.strTitle or ""
	local eEnum = tAugment.eEldanAvailability
	
	if (eEnum == AbilityBook.CodeEnumEldanAvailability.Unavailable) then -- 0
		local strLoc = ""
		local nLocation = nil
		local tRecord = tAmpFinder.tMyClassAmps[tAugment.nSpellIdAugment]
		if (tRecord ~= nil) then
			nLocation = tRecord[4]
		end

		if (nLocation == knLocQuest) then

			local nCount = 0
			strLoc = "AMP is locked. Can be obtained from "
			
			if (IsKeyComplete(knPaneCelestionQ) == false) and (IsKeyComplete(knPaneDeraduneQ) == false) then
				local tLocationData1 = tAmpFinder.LocationToVendor[knLocGlenview][1]
				strLoc = strLoc .. formatLocation(tLocationData1, false)
				nCount = nCount+1
			end
			
			if (IsKeyComplete(knPaneAlgorocQ) == false) and (IsKeyComplete(knPaneEllevarQ) == false) then
				if (nCount >= 1) then strLoc = strLoc..", from " end
				
				local tLocationData2 = tAmpFinder.LocationToVendor[knLocTremor][1]
				strLoc = strLoc .. formatLocation(tLocationData2, false)
				nCount = nCount + 1
			end
			
			if (nCount >= 1) then strLoc = strLoc.." or from " end
			tLocationData = tAmpFinder.LocationToVendor[knLocCommodity][1]
			strLoc = strLoc .. formatLocation(tLocationData, true)
			
		elseif (nLocation == knLocGallowSylvan) then
			tLocationData1 = tAmpFinder.LocationToVendor[knLocGallow][1]
			tLocationData2 = tAmpFinder.LocationToVendor[knLocSylvan][1]
			strLoc = "AMP is locked. Can be obtained from "
				.. formatLocation(tLocationData1, false)
				.. formatLocation(tLocationData2, false)
				
		elseif (nLocation == knLocUnknown) then
			tLocationData = tAmpFinder.LocationToVendor[knLocCommodity][1]
			strLoc = "AMP is locked. May be for sale at "
				.. formatLocation(tLocationData, true)
		
		elseif (nLocation ~= nil) then
			-- tLocRecord shouldn't be nil, but it is seeming to be... 
			-- shouldn't happen, but it happens in walatiki temple.
			-- are all amps locked in PVP maps, perhaps?
			-- It may be another not-quite-loading error. Testing for now though. 
	
			local tLocationData = nil
			local tLocRecord = tAmpFinder.LocationToVendor[nLocation]
			if (tLocRecord ~= nil) then tLocationData = tLocRecord[1] end
			if (tLocationData ~= nil) then
				strLoc = "AMP is locked. Can be obtained from "
					.. formatLocation(tLocationData, false)
			else 
				tLocationData = tAmpFinder.LocationToVendor[knLocCommodity][1]
				strLoc = "AMP is locked. May be for sale at "
					.. formatLocation(tLocationData, true)
			end		
		else 
			tLocationData = tAmpFinder.LocationToVendor[knLocCommodity][1]
			strLoc = "AMP is locked. May be for sale at "
					.. formatLocation(tLocationData, true)
		end
		
		wndTooltip:FindChild("DescriptionLabelWindow"):SetAML(
			"<P TextColor=\"UI_TextHoloBodyHighlight\" Font=\"CRB_InterfaceSmall\">"
		    ..strLoc.."</P>"..			
			"<P TextColor=\"UI_TextHoloBody\" Font=\"CRB_InterfaceSmall\">"
			..tAugment.strDescription.."</P>")
			
		-- resize window now that we've added text
		local nTextWidth, nTextHeight = wndTooltip:FindChild("DescriptionLabelWindow"):SetHeightToContentHeight()
		local nLeft, nTop, nRight, nBottom = wndTooltip:GetAnchorOffsets()
		wndTooltip:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nTextHeight + 68)
		
	end -- if eEnum
end

function AMPFinder:HookAMPTooltips()
	local tAbilityAMPs = GetAbilityAMPsAddon() -- Apollo.GetAddon("AbilityAMPs")
	if (tAbilityAMPs == nil) then return end -- can't hook if the addon isn't there

	-- extend AMP Dialog tooltip
	local origOnAugmentationTooltip = tAbilityAMPs.OnAugmentationTooltip
	tAbilityAMPs.OnAugmentationTooltip = function(wndHandler, wndControl, eToolTipType, x, y)	
		origOnAugmentationTooltip(wndHandler, wndControl, eToolTipType, x, y)
		extendAugmentationTooltip(tAbilityAMPs.wndTooltip, wndControl)
		repositionAugmentationTooltip(tAbilityAMPs.wndTooltip)
	end -- tAbilityAMPs.OnAugmentationTooltip
end

function AMPFinder:HookVendorLists()
	local tVendor = GetVendorAddon() -- Apollo.GetAddon("Vendor")
	if (tVendor == nil) then return end
	local origVendorItems = tVendor.DrawListItems
	tVendor.DrawListItems = function(luaCaller, wndParent, tItems)
		local nHeight = origVendorItems(luaCaller, wndParent, tItems)
		
		local tItemWindows = wndParent:GetChildren()
		for key, tCurrItem in ipairs(tItems) do
			local tItemData = tCurrItem.itemData
			if (tItemData ~= nil) then -- fix the items that don't have all their data
				local nItemType = tItemData:GetItemType()
				if (nItemType >= knAmpWarrior) and (nItemType <= knAmpSpellslinger) then
					
					local intFound, strAmpTier = self:IsLearnedByItem(tCurrItem.itemData)
					
					-- we can cheat, there's a 1:1 relationshop between items and their windows
					local wndItem = tItemWindows[key]
					local wndItemLabel = wndItem:FindChild("VendorListItemTitle")
	
					if (intFound == 2) then				
						wndItemLabel:SetText(String_GetWeaselString(Apollo.GetString("Vendor_KnownRecipe"), 
							tCurrItem.itemData:GetName() )  )
					end	
				end
			end
		end
				
		return nHeight
	end
end

function AMPFinder:HookTooltips()
	local tTooltips = GetTooltipsAddon() -- Apollo.GetAddon("ToolTips")
	if (tTooltips == nil) then return end  -- ditch this procedure if user is using a different tooltip mod
	
	-- CreateCallNames is run right after a tooltip is instantiated.
	-- So we can splice code in there.
	-- now passing window args both upstream and downstream - thanks, Tomer!
	local origCreateCallNames = tTooltips.CreateCallNames
	tTooltips.CreateCallNames = function(luaCaller)
		origCreateCallNames(luaCaller)
		local origItemTooltip = Tooltip.GetItemTooltipForm
		Tooltip.GetItemTooltipForm = function(luaCaller, wndControl, item, bStuff, nCount)
			if (item ~= nil) then
			
				local nItemType = item:GetItemType()
				if (nItemType >= knAmpWarrior) and (nItemType <= knAmpSpellslinger) then
				
					wndControl:SetTooltipDoc(nil)
					local wndTooltip, wndTooltipComp = origItemTooltip(luaCaller, wndControl, item, bStuff, nCount)
					
					local intFound, strTier = self:IsLearnedByItem(item)
					local wndHeader = wndTooltip:FindChild("ItemTooltip_Header")
					local wndTypeTxt = wndHeader:FindChild("ItemTooltip_Header_Types")
					wndTypeTxt:SetText(wndTypeTxt:GetText()..strTier)
					
					return wndTooltip, wndTooltipComp
				else 
					return origItemTooltip(luaCaller, wndControl, item, bStuff, nCount)
				end
			else
				return origItemTooltip(luaCaller, wndControl, item, bStuff, nCount)
			end
		end
	end
end 

-----------------------------------------------
-- Many whelps, handle it
-----------------------------------------------

function AMPFinder:OnSave(eType)
	if (eType ~= GameLib.CodeEnumAddonSaveLevel.Account) then return end

	self.bWindowOpen = self.wndMain:IsShown()
	
	local tSaveData = {}
	for idx,property in ipairs(ktUserPrefs) do
		tSaveData[property] = self[property]
	end
	
	return tSaveData
end

function AMPFinder:OnRestore(eType, tSavedData)
	if (eType ~= GameLib.CodeEnumAddonSaveLevel.Account) then return end
	
	for idx,property in ipairs(ktUserPrefs) do
		if tSavedData[property] ~= nil then
			self[property] = tSavedData[property]
		end
	end
	
	-- todo: debug
	-- if (self.wndMain ~= nil) then

		-- self.wndMain:Show(self.bWindowOpen)
		-- if (self.bCompact) then 
		-- 	self:CompactWindow() 
			-- self.bInitialShow = false
			-- self:OnWindowShow()
		-- end
	-- end
	
	if (self.wndAMPFilter == nil) then return end  -- The restore could happen before the filter is hooked
	local fBox = self.wndAMPFilter:FindChild("FilterBox")
	if (fBox ~= nil) then
		fBox:SetText(self.strFilter)
	end
end

function AMPFinder:OnWindowManagementReady()
    Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = "AMP Finder"})
end

function AMPFinder:OnSlashCommand()
	self.wndMain:Show(true)
	self.wndMain:ToFront()
	self:UpdatePane()
	if (self.bPosTracking) then self:HookPosTrack(true) end
end

function AMPFinder:OnCloseWindow( wndHandler, wndControl, eMouseButton )
	self.wndMain:Close()
end

function AMPFinder:OnChangeZone(oVar, strNewZone)
	self:UpdatePane()
end

function AMPFinder:OnFilterClearBtn( wndHandler, wndControl, eMouseButton )
	local fBox = self.wndAMPFilter:FindChild("FilterBox")
	self.wndAMPFilter:FindChild("FilterClearBtn"):Show(false)
	self.wndAMPFilter:FindChild("SearchIcon"):Show(true)
	if (fBox == nil) then return end 
	self.strFilter = ""
	fBox:SetText("Filter...")
	fBox:ClearFocus()
	self:UpdateAMPWindow(nil)
end

function AMPFinder:OnFilterChange( wndHandler, wndControl, strText )
	self.strFilter = strText
	if (strText == "") then
		self.wndAMPFilter:FindChild("FilterClearBtn"):Show(false)
		self.wndAMPFilter:FindChild("SearchIcon"):Show(true)
		self:UpdateAMPWindow(nil)
	else 
		self.wndAMPFilter:FindChild("FilterClearBtn"):Show(true)
		self.wndAMPFilter:FindChild("SearchIcon"):Show(false)
		self:UpdateAMPWindow(strText)
	end
end

-- called when the AMP window filter needs to be updated
function AMPFinder:UpdateAMPWindow(filter)
	if (filter ~= nil) then 
		filter = string.lower(filter)
	end
	
	local tAbilityAMPs = GetAbilityAMPsAddon() -- Apollo.GetAddon("AbilityAMPs")
	if (tAbilityAMPs == nil) then return end -- nothing to do if the addon isn't there
	local cnt = 0
	local wndAMPs = tAbilityAMPs.tWndRefs.wndMain:FindChild("ScrollContainer:Amps")
	for idx, wndAmp in pairs(wndAMPs:GetChildren()) do
		local tAmp = wndAmp:GetData()
		local ampname = string.lower(tAmp.strTitle)
		

		if (tAmp.pixieHighlight ~= nil) then
			wndAMPs:DestroyPixie(tAmp.pixieHighlight)
		end
		
		if (filter ~= nil) then
			if (string.find(ampname,filter) ~= nil) then
				local iX, iY = wndAmp:GetPos()
				local tCircle =	{
					loc = {
						fPoints = { 0, 0, 0, 0 },
						nOffsets = { iX+1, iY-1, iX+30, iY+30 },
					},
					
					strSprite = "DatachronSprites:CommIndicator_GreenPulse",
					bLine = false,
				    DT_CENTER = true,
				}
				tAmp.pixieHighlight = wndAMPs:AddPixie(tCircle)
				cnt = cnt + 1
			end
		end
	end
end

function AMPFinder:AMPFinderBtn_Click( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(true)
	self.wndMain:ToFront()
	self:UpdatePane()
	if (self.bPosTracking) then self:HookPosTrack(true) end
end

function AMPFinder:OnHoverCondAmp( wndHandler, wndControl, x, y )
	self.wndHover = wndControl
	Apollo.StopTimer("AMPFinderTooltipCountdown")
	
	local wndParent = wndControl:GetParent()
	local tData = wndParent:GetData()
	if (tData == nil) then return end
	
	local intFound, strAmpTier, tAugment = self:IsLearnedBySpellId(tData[2])

	if not self.wndMain or not self.wndMain:IsValid() then
		return
	end
	
	if not self.wndAMPTooltip or not self.wndAMPTooltip:IsValid() then
		self.wndAMPTooltip = Apollo.LoadForm(self.xmlDoc, "AMPTooltip",
			nil, self)
	end
	local wndTip = self.wndAMPTooltip

	local sCat = ""
	local sName = ""
	local sPowerCost = ""
	local sTierLabel = ""
	local sDesc = ""
	if (tAugment ~= nil) then
		sCat = karCategoryToConstantData[tAugment.nCategoryId][3] or ""
		sName = tAugment.strTitle or ""
		sPowerCost = String_GetWeaselString(Apollo.GetString("AMP_PowerCost"),
			tAugment.nPowerCost or "")
		sTierLabel = String_GetWeaselString(Apollo.GetString("AMP_TierLabel"),
			sCat, tAugment.nCategoryTier or "")
		sDesc = tAugment.strDescription	
	else
		local tSpell = GameLib.GetSpell(tData[2])
		nRecord = AllAmpData[ tData[4] ][ tData[2] ]
		sCat = karCategoryToConstantData[ nRecord[kiAmpCategory] ][3]
		
		sName = tSpell:GetName()
		sPowerCost = string.upper(karClassNames[ tData[4] ]).." " -- something's eating the last char. oh well.
		sPowerCost = string.sub( sPowerCost, 1, string.len(sPowerCost)-1 ) 
		sTierLabel = String_GetWeaselString(Apollo.GetString("AMP_TierLabel"),
			sCat, nRecord[kiAmpRank] or "")
		sDesc = tSpell:GetFlavor()
	end
	
	wndTip:FindChild("NameLabelWindow"):SetText(sName)
	wndTip:FindChild("PowerCostLabelWindow"):SetText(sPowerCost)
	wndTip:FindChild("TierLabelWindow"):SetText(sTierLabel)
	wndTip:FindChild("DescriptionLabelWindow"):SetAML("<P TextColor=\"UI_TextHoloBody\" Font=\"CRB_InterfaceSmall\">"
		..sDesc.."</P>")
	
	local nTextWidth, nTextHeight = wndTip:FindChild("DescriptionLabelWindow"):SetHeightToContentHeight()
	local nLeft, nTop, nRight, nBottom = wndTip:GetAnchorOffsets()
	wndTip:SetAnchorOffsets(nLeft, nTop, nRight, nTop + nTextHeight + 68)
	
	extendAugmentationTooltip(wndTip, wndControl, tAugment)
	
	nLeft, nTop, nRight, nBottom = wndTip:GetAnchorOffsets()

	local nMainLeft, nMainTop, nMainRight, nMainBottom = self.wndMain:GetAnchorOffsets()
	local tMouse = Apollo.GetMouse()
	wndTip:SetAnchorOffsets(
		nMainRight-30,
		tMouse.y,
		nRight - nLeft + nMainRight-30,
		nBottom - nTop + tMouse.y)
	wndTip:ToFront()
	wndTip:Show(true)
end

function AMPFinder:OnLeaveCondAmp( wndHandler, wndControl, x, y )
	self.wndLeave = wndControl
	self.timerTooltip:Start()
end


function AMPFinder:OnClickCondAmp( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	local tData = wndControl:GetData()
	if (tData == nil) then return end
	local wndParent = wndControl:GetParent()
	if (wndParent:GetName() ~= "AmpGenericForm") then return end
	for idx, wndCurr in pairs(wndParent:GetChildren()) do
		local tAmpData = wndCurr:GetData()
		local wndRank = wndCurr:FindChild("AMPRank")
		if (tAmpData ~= nil) then
			if (self.nCompleteDisplayMode == 0) then
				local nRecord = AllAmpData[ tAmpData[4] ][ tAmpData[2] ]
				
				if (nRecord == nil) then
					wndRank:SetText("World drop")
				else
					local nLoc = nRecord[4]
					if (nLoc == nil) or (nLoc == knLocUnknown) then
						wndRank:SetText("World drop")
					elseif (nLoc == knLocAutolearned) then
						wndRank:SetText("Auto-learned")
					elseif (nLoc == knLocQuest) then
						wndRank:SetText("Quest reward")
					elseif (nLoc == knLocGallowSylvan) then
						wndRank:SetText(self.LocationToVendor[knLocGallow][1][1].."/"
						..self.LocationToVendor[knLocSylvan][1][1])
					elseif (self.LocationToVendor[nLoc] ~= nil) then
						wndRank:SetText(self.LocationToVendor[nLoc][1][1])
					else
						wndRank:SetText("")
					end
				end
			else
				local nRecord = AllAmpData[ tAmpData[4] ][ tAmpData[2] ]

				local nCatId = nRecord[kiAmpCategory]
				local nRank = nRecord[kiAmpRank]
				wndRank:SetText(karCategoryToConstantData[nCatId][3].." R"..nRank)
			end
		end -- tAmpData ~= nil
	end -- pairs

	if (self.nCompleteDisplayMode == 0) then
		self.nCompleteDisplayMode = 1
	else
		self.nCompleteDisplayMode = 0
	end
end -- ClickCondAmp

function AMPFinder:AMPFinderTooltipClose()
	if (Apollo.GetMouseTargetWindow() ~= self.wndHover) then
		if (self.wndAMPTooltip ~= nil) then
			self.wndAMPTooltip:Destroy()
		end
	end
end

function AMPFinder:OnPaneSelectorBtn( wndHandler, wndControl, eMouseButton )
	if (self.wndAMPTooltip ~= nil) then self.wndAMPTooltip:Destroy() end
	self.wndMain:FindChild("PickerListFrame"):Show(false)
	self.wndMain:FindChild("PickerBtn"):SetCheck(false)
	self:UpdatePane(wndControl:GetData())
end

function AMPFinder:OnPickerBtnCheck( wndHandler, wndControl, eMouseButton )
	if (self.wndAMPTooltip ~= nil) then self.wndAMPTooltip:Destroy() end
	self.wndMain:FindChild("PickerListFrame"):Show(true)
	self.wndMain:FindChild("ClassListFrame"):Show(false)
	self.wndMain:FindChild("ClassFrame"):FindChild("ClassButton"):SetCheck(false)
end

function AMPFinder:OnPickerBtnUncheck( wndHandler, wndControl, eMouseButton )
	if (self.wndAMPTooltip ~= nil) then self.wndAMPTooltip:Destroy() end
	local wndListFrame = self.wndMain:FindChild("PickerListFrame")
	if (wndListFrame ~= nil) then
		wndListFrame:Show(false)
	end
end

function AMPFinder:OnClassSelectorBtn( wndHandler, wndControl, eMouseButton )
	if (self.wndAMPTooltip ~= nil) then self.wndAMPTooltip:Destroy() end
	self.wndMain:FindChild("ClassListFrame"):Show(false)
	self.wndMain:FindChild("ClassFrame"):FindChild("ClassButton"):SetCheck(false)
	self.nClassDisplayed = wndControl:GetData()
	self:UpdatePane(-1)
end

function AMPFinder:OnClassBtnCheck( wndHandler, wndControl, eMouseButton )
	if (self.wndAMPTooltip ~= nil) then self.wndAMPTooltip:Destroy() end
	local wndListFrame = self.wndMain:FindChild("ClassListFrame")
	if (wndListFrame ~= nil) then wndListFrame:Show(true) end
	self.wndMain:FindChild("PickerListFrame"):Show(false)
	self.wndMain:FindChild("PickerBtn"):SetCheck(false)
end

function AMPFinder:OnClassBtnUncheck( wndHandler, wndControl, eMouseButton )
	if (self.wndAMPTooltip ~= nil) then self.wndAMPTooltip:Destroy() end
	local wndListFrame = self.wndMain:FindChild("ClassListFrame")
	if (wndListFrame ~= nil) then wndListFrame:Show(false) end
end

function AMPFinder:OnInterfaceMenuListHasLoaded()

	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "AMP Finder",
		{ "AMPFinder_ShowHide", "", "CRB_Basekit:kitIcon_Holo_HazardRadioactive" } ) 

	self:UpdateInterfaceMenuAlerts()

end

function AMPFinder:UpdateInterfaceMenuAlerts()
	local tEldanAugmentationData = AbilityBook.GetEldanAugmentationData(AbilityBook.GetCurrentSpec())
	local nAmpsUnlearned = 0

	if (tEldanAugmentationData ~= nil) then 
		nAmpsUnlearned = #tEldanAugmentationData.tAugments
	
		for idx = 1, #tEldanAugmentationData.tAugments do
			local tAmp = tEldanAugmentationData.tAugments[idx]
			if tAmp.eEldanAvailability ~= AbilityBook.CodeEnumEldanAvailability.Unavailable then
				nAmpsUnlearned = nAmpsUnlearned - 1
			end
		end
	end
	
	Event_FireGenericEvent("InterfaceMenuList_AlertAddOn", "AMP Finder",
		{false, nAmpsUnlearned.." AMPs left to learn", nAmpsUnlearned } )
end

function AMPFinder:OnInterfaceMenuShowHide() 
	self.wndMain:Show(true)
	self.wndMain:ToFront()
	self:UpdatePane()
	if (self.bPosTracking) then self:HookPosTrack(true) end
end


--------------------------------------
-- AMP Finder functions
--------------------------------------

function AMPFinder:UpdateClassIcon() 
	local nClass = self.nClassDisplayed
	local strIcon = "IconSprites:Icon_Windows_UI_CRB_Infinity"
		
	if     (nClass == knClassWarrior) then
		strIcon = "IconSprites:Icon_Windows_UI_CRB_Warrior"
	elseif (nClass == knClassEngineer) then
		strIcon = "IconSprites:Icon_Windows_UI_CRB_Engineer"
	elseif (nClass == knClassEsper) then
		strIcon = "IconSprites:Icon_Windows_UI_CRB_Esper"
	elseif (nClass == knClassMedic) then
		strIcon = "IconSprites:Icon_Windows_UI_CRB_Medic"
	elseif (nClass == knClassStalker) then
		strIcon = "IconSprites:Icon_Windows_UI_CRB_Stalker"
	elseif (nClass == knClassSpellslinger) then
		strIcon = "IconSprites:Icon_Windows_UI_CRB_Spellslinger"
	else
		return -- not sure what this is, but it ain't somethin we can handle
	end
	self.wndMain:FindChild("ClassFrame"):FindChild("ClassIcon"):SetSprite(strIcon)
	self.wndMain:FindChild("ClassFrame"):SetTooltip("Currently showing "
		..karClassNames[self.nClassDisplayed].." AMPs")
end

function AMPFinder:BuildClassMenu() 
	local wndClassList = self.wndMain:FindChild("ClassListFrame")
	if (#wndClassList:GetChildren() > 0) then return end

	local arClassList = {
		knClassEngineer, knClassEsper, knClassMedic,
		knClassSpellslinger, knClassStalker, knClassWarrior,
	}
	local arIconList = {
		"IconSprites:Icon_Windows_UI_CRB_Engineer",
		"IconSprites:Icon_Windows_UI_CRB_Esper",
		"IconSprites:Icon_Windows_UI_CRB_Medic",
		"IconSprites:Icon_Windows_UI_CRB_Spellslinger",
		"IconSprites:Icon_Windows_UI_CRB_Stalker",
		"IconSprites:Icon_Windows_UI_CRB_Warrior",		
	}
	for idx=1, #arClassList do
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "ClassSelectorBtn", wndClassList, self)
		wndCurr:SetData(arClassList[idx])
		wndCurr:FindChild("Label"):SetText(karClassNames[ arClassList[idx] ]) -- arNameList[idx])
		wndCurr:FindChild("Icon"):SetSprite(arIconList[idx])
		if (arClassList[idx] ~= self.nClass) then
			wndCurr:FindChild("Arrow"):Show(false)
		end
	end
	wndClassList:ArrangeChildrenVert(1)
end

function AMPFinder:UpdatePane(nZoneId)
	self:UpdateClassIcon()  -- TODO: Move this to the end of the procedure maybe
	local nOldShownZone = self.nDisplayedPane
	if (nZoneId ~= nil) then
		if (nZoneId == -1) then
			nOldShownZone = nil
		else
			self.nUserSelectedPane = nZoneId
		end
	end
	
	if (self.wndMain == nil) then 
		return
	end

	-- make sure this is set sometime
	-- if it's not been set, abort procedure
	if (self.bAmpLocations == false) then
		self.wndMain:FindChild("AMP_Info"):SetText("AMP Finder is gathering data.\n"..
			"Should only be a few seconds,\nplease wait...")
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()

		return
	end

	local worldid = GameLib.GetCurrentWorldId()
	local zoneid = GameLib.GetCurrentZoneId()
	local tZoneInfo = GameLib.GetCurrentZoneMap()

	if (worldid == nil) then return end
	if (zoneid == nil) then return end
	if (tZoneInfo == nil) then return end

	-- Change zone
	local strZoneName
	if (self.nUserSelectedPane == 0) then
		self.nDisplayedPane = tZoneInfo.id
		
		if (ktPaneData[self.nDisplayedPane] == nil) then
			strZoneName = tZoneInfo.strName
		else
			strZoneName = ktPaneData[self.nDisplayedPane][1]
		end
	elseif (self.nUserSelectedPane == tZoneInfo.id) then
		self.nUserSelectedPane = 0
		self.nDisplayedPane = tZoneInfo.id
		strZoneName = ktPaneData[self.nDisplayedPane][1]
	else
		self.nDisplayedPane = self.nUserSelectedPane
		strZoneName = ktPaneData[self.nDisplayedPane][1]
	end
	
	-- Build zone list
	self.wndMain:FindChild("PickerBtnText"):SetText(strZoneName)
	self.wndMain:FindChild("PickerList"):DestroyChildren()
	local wndPickerList = self.wndMain:FindChild("PickerList")

	self:BuildClassMenu()

	local arZoneList

	if (self.nFaction == Unit.CodeEnumFaction.ExilesPlayer) then
		arZoneList = {knPaneAlgoroc, knPaneAlgorocQ, knPaneCelestion, knPaneCelestionQ, 
			knPaneFarside, knPaneFarsideE, knPaneGaleras, knPaneThayd, knPaneThaydC,
			knPaneWhitevale, knPaneWilderrun, knPaneComplete}
	elseif (self.nFaction == Unit.CodeEnumFaction.DominionPlayer) then
		arZoneList = {knPaneAuroria, knPaneDeradune, knPaneDeraduneQ, knPaneEllevar, 
			knPaneEllevarQ, knPaneFarside, knPaneFarsideD, knPaneIllium, knPaneIlliumC, 
			knPaneWhitevale, knPaneWilderrun, knPaneComplete}
	else
		return
	end
	
	for idx=1, #arZoneList do
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "PaneSelectorBtn", wndPickerList, self)
		local idZone = arZoneList[idx]
		wndCurr:SetData(idZone)
		if (idZone == 0) then
			wndCurr:SetText("(current zone)")
		else
			if (idZone == tZoneInfo.id) then
				wndCurr:SetText("( "..ktPaneData[idZone][1].." )")
				wndCurr:SetStyleEx("UseWindowTextColor",true)
			else
				wndCurr:SetText(ktPaneData[idZone][1])
				wndCurr:SetStyleEx("UseWindowTextColor",false)
			end
		end
	end

	self.wndMain:FindChild("PickerList"):ArrangeChildrenVert(0)
	self.wndMain:FindChild("PickerList"):SetVScrollPos(0) -- 30 is hardcoded formatting of the list item height
	
	if (nOldShownZone == self.nDisplayedPane) then
		-- don't redraw if you haven't left the zone
		return
	end
	
	self.wndMain:FindChild("CompactBtn"):Enable(true)
	
	if (string.find(ksQuestPanes, '|'..self.nDisplayedPane..'|')) then
	
		self.wndMain:FindChild("AMP_Info"):SetText("")								
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()
		self.bPosTracking = true
		self:HookPosTrack(true)
		
		local nTop = 70 -- y location
		local vendorTag = ktPaneData[self.nDisplayedPane][2]
		local wndQgiver = Apollo.LoadForm(self.xmlDoc, "AmpQuestgiverForm", self.wndMain:FindChild("AMP_Info"), self)
		local wndQuestgiver, nTop = self:AddConditionQuestgiver(wndQgiver, nTop, vendorTag, self.nDisplayedPane)
		nTop = self:AddConditionAMPs(knLocQuest, nil, wndQgiver, nTop, true)
		self:SetupArrow(2, wndQgiver, wndQuestgiver)
		wndQgiver:SetAnchorOffsets(10, 10, -10, nTop+20)
		
		self.wndMain:FindChild("AMP_Info"):SetVScrollPos(0)
		self.wndMain:FindChild("AMP_Info"):RecalculateContentExtents()
		self:InvokeWindowPref()
		
	elseif	(self.nDisplayedPane == knPaneThaydC) or
			(self.nDisplayedPane == knPaneIlliumC) then
		
		self.wndMain:FindChild("AMP_Info"):SetText("")								
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()
		self.bPosTracking = true
		self:HookPosTrack(true)
		
		local nTop = 70
		vendorTag = knLocCommodity				
		local wndVend = Apollo.LoadForm(self.xmlDoc, "AmpVendorForm", self.wndMain:FindChild("AMP_Info"), self)
		local wndVendor, nTop = self:AddConditionVendor(wndVend, nTop, vendorTag)
		nTop = self:AddConditionAMPs(knLocUnknown, knLocQuest, wndVend, nTop)

		self:SetupArrow(1, wndVend, wndVendor)
		wndVend:SetAnchorOffsets(10, 10, -10, nTop+20)
		
		self.wndMain:FindChild("AMP_Info"):SetVScrollPos(0)
		self.wndMain:FindChild("AMP_Info"):RecalculateContentExtents()
		self:InvokeWindowPref()

	elseif	(self.nDisplayedPane == knPaneThayd) or
			(self.nDisplayedPane == knPaneIllium) then

		self.wndMain:FindChild("AMP_Info"):SetText("")								
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()
		self.bPosTracking = true
		self:HookPosTrack(true)
				
		local nTop = 70 -- y location
		local vendorTag = knLocFCON
		local wndVend = Apollo.LoadForm(self.xmlDoc, "AmpVendorForm", self.wndMain:FindChild("AMP_Info"), self)
		local wndVendor, nTop = self:AddConditionVendor(wndVend, nTop, vendorTag)
		nTop = self:AddConditionPrestige(75, wndVend, nTop)
		nTop = self:AddConditionAMPs(vendorTag, nil, wndVend, nTop)

		self:SetupArrow(1, wndVend, wndVendor)
		wndVend:SetAnchorOffsets(10, 10, -10, nTop+20)
				
		self.wndMain:FindChild("AMP_Info"):SetVScrollPos(0)
		self.wndMain:FindChild("AMP_Info"):RecalculateContentExtents()
		self:InvokeWindowPref()		

	elseif (string.find(ksVendorPanes,
		"|"..self.nDisplayedPane.."|")) then

		self.wndMain:FindChild("AMP_Info"):SetText("")								
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()
		self.bPosTracking = true
		self:HookPosTrack(true)

		local nTop = 70 -- y location
		local vendorTag, vendorTag2 = ktPaneData[self.nDisplayedPane][2], nil
		local repTag = self.LocationToVendor[vendorTag][1][6]
		if (vendorTag == knLocGallow) or (vendorTag == knLocSylvan) then vendorTag2 = knLocGallowSylvan
		elseif (vendorTag == knLocBravo) then vendorTag2 = knLocWalkers end
		
		local wndVend = Apollo.LoadForm(self.xmlDoc, "AmpVendorForm", self.wndMain:FindChild("AMP_Info"), self)
		local wndVendor, nTop = self:AddConditionVendor(wndVend, nTop, vendorTag)
		nTop = self:AddConditionReputation(wndVend, nTop, repTag)
		nTop = self:AddConditionAMPs(vendorTag, vendorTag2, wndVend, nTop)
		self:SetupArrow(1, wndVend, wndVendor)
		wndVend:SetAnchorOffsets(10, 10, -10, nTop+20)
		
		self.wndMain:FindChild("AMP_Info"):SetVScrollPos(0)
		self.wndMain:FindChild("AMP_Info"):RecalculateContentExtents()
		self:InvokeWindowPref()

	elseif (self.nDisplayedPane == knPaneComplete) then

		self:UpdateClassIcon()
		self.wndMain:FindChild("CompactBtn"):Enable(false)
		self.wndMain:FindChild("AMP_Info"):SetText("")								
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()
		self.bPosTracking = false
		self:HookPosTrack(false)
		self:SetupArrow(0)
		
		local nTop = 10 -- y location
		local wndList = Apollo.LoadForm(self.xmlDoc, "AmpGenericForm", self.wndMain:FindChild("AMP_Info"), self)
		nTop = self:AddConditionAMPs(nil, nil, wndList, nTop)
		wndList:SetAnchorOffsets(10, 10, -10, nTop+20)
													
		self.wndMain:FindChild("AMP_Info"):SetVScrollPos(0)
		self.wndMain:FindChild("AMP_Info"):RecalculateContentExtents()
		self:InvokeWindowPref()	

	else -- current zone is not in the list
	
		self.wndMain:FindChild("AMP_Info"):SetText("No AMP info found for current zone.")				
		self.wndMain:FindChild("AMP_Info"):DestroyChildren()
		self.bPosTracking = false
		self:HookPosTrack(false)
		self:SetupArrow(0)
		
	end					

end -- UpdatePane

function AMPFinder:SetupArrow(nType, wndPane, wndLabel)
	self.nArrowType = nType
	if (nType == 0) then
		self.wndArrowPane = nil
		self.wndArrowLabel = nil
	elseif (nType == 1) then 
		self.wndArrowPane = wndPane
		self.wndArrowLabel = wndLabel
		self:UpdateArrowVendor(true)
	elseif (nType == 2) then
		self.wndArrowPane = wndPane
		self.wndArrowLabel = wndLabel
		self:UpdateArrowQuestgiver(true)
	end
end

function AMPFinder:AddConditionText(wndParent, nTop, strText)
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndParent, self)
	wndCurr:FindChild("ConditionField"):SetText(strText)
	wndCurr:FindChild("Image"):SetSprite(nil)
	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
	return nTop+20
end

function AMPFinder:AddConditionVendor(wndParent, nTop, nVendorTag)
	local tVendorData = self.LocationToVendor[nVendorTag][1]
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndParent, self)
	wndParent:FindChild("AddInfo"):SetText(tVendorData[2].."\n("..round(tVendorData[3])..","..round(tVendorData[4])..")")
	wndCurr:FindChild("ConditionField"):SetText(tVendorData[5])
	wndCurr:FindChild("ConditionField"):SetFont("CRB_InterfaceMedium_BO")
	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
	wndCurr:SetData({knCondVendor, nVendorTag})
	return wndCurr, nTop+25
end

function AMPFinder:AddConditionQuestgiver(wndParent, nTop, nVendorTag, nZoneTag)
	local tVendorData = self.LocationToVendor[nVendorTag][1]
	local tEp = ktEpisodeInfo[nZoneTag]
	local ep, strQgiver, strQline, q1, q2, q3 = tEp[kiEpisodeNum], tEp[kiEpisodeQuestgiver], tEp[kiEpisodeName],
		tEp[kiEpisodeQuest1], tEp[kiEpisodeQuest2], tEp[kiEpisodeQuest3]
		
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndParent, self)
	wndParent:FindChild("AddInfo"):SetText(tVendorData[2].."\n("..round(tVendorData[3])..","..round(tVendorData[4])..")")
	wndCurr:FindChild("ConditionField"):SetText("Quests from "..strQgiver)
	wndCurr:FindChild("ConditionField"):SetTooltip("Questline begins with this questgiver.")
	wndCurr:FindChild("ConditionField"):SetFont("CRB_InterfaceMedium_BO")
	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
	wndCurr:SetData({knCondQuestgiver, nVendorTag})
	nTop = nTop + 25

	local epiKey = self:GetKeyEpisode(ep)

	if (q1 ~= nil) then
		nTop = self:AddConditionQuest(wndParent, nTop, ep, q1)
	end
	
	if (q2 ~= nil) then
		nTop = self:AddConditionQuest(wndParent, nTop, ep, q2)
	end
	
	if (q3 ~= nil) then
		nTop = self:AddConditionQuest(wndParent, nTop, ep, q3)		
	end
	-- update after adding the other conditions
	return wndCurr, nTop
end

function AMPFinder:AddConditionQuest(wndParent, nTop, nEpId, nQuestId)
	local strQName = karEpisodeTitles[nQuestId]
	if (strQName == nil) then return nTop end
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndParent, self)
	wndCurr:FindChild("ConditionField"):SetText("Quest: "..strQName)
	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
	wndCurr:SetData({knCondQuest, nEpId, nQuestId})
	wndCurr:SetTooltip("Complete all the quests for an AMP reward.")
	self:UpdateCondQuest(wndCurr)
	return nTop+20
end

function AMPFinder:AddConditionPrestige(nAmount, wndParent, nTop)
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndParent, self)
	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
	wndCurr:SetData({knCondPrestige,nAmount})
	wndCurr:SetTooltip("AMPs at this vendor can be purchased for Prestige.")
	self:UpdateCondPrestige(wndCurr)
	return nTop+25
end

function AMPFinder:AddConditionReputation(wndParent, nTop, strGroupName)
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndParent, self)
	wndCurr:FindChild("ConditionField"):SetText(strGroupName..": "..
		"0/8000")
	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
	wndCurr:SetData({knCondReputation, strGroupName})
	wndCurr:SetTooltip("Complete quests in this zone\nto achieve a Popular reputation.")
	self:UpdateCondReputation(wndCurr)
	return nTop+25
end

function AMPFinder:AddConditionAMP(wndParent, nTop, sAmpName, nSpellId, nLoc, questTooltip)
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "AMPIndicator", wndParent, self)
	
	wndCurr:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_Lock")
	wndCurr:FindChild("AMPName"):SetText(sAmpName)

	local wndRank = wndCurr:FindChild("AMPRank")
	
	if (self.nCompleteDisplayMode == 1) and (wndParent:GetName() == "AmpGenericForm") then
	
		if (nLoc == nil) or (nLoc == knLocUnknown) then
			wndRank:SetText("World drop")
		elseif (nLoc == knLocAutolearned) then
			wndRank:SetText("Auto-learned")
		elseif (nLoc == knLocQuest) then
			wndRank:SetText("Quest reward")
		elseif (nLoc == knLocGallowSylvan) then
			wndRank:SetText(self.LocationToVendor[knLocGallow][1][1].."/"..self.LocationToVendor[knLocSylvan][1][1])
		elseif (self.LocationToVendor[nLoc] ~= nil) then
			wndRank:SetText(self.LocationToVendor[nLoc][1][1])
		else
			wndRank:SetText("")
		end
		
	else
		local tRecord = AllAmpData[self.nClassDisplayed][nSpellId] -- AllAmpData[nPane][nSpellId]
		strWedgeName = karCategoryToConstantData[ tRecord[kiAmpCategory] ][3]
		wndRank:SetText(strWedgeName.." R"..tRecord[kiAmpRank])		
	end
	
	if (self.nClass == self.nClassDisplayed) then
		wndCurr:SetData( {knCondAMP, nSpellId, false, self.nClassDisplayed} )
	else
		wndCurr:SetData( {knCondAMP, nSpellId, false, self.nClassDisplayed} )
	end

	wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+18)
	
	if (questTooltip) then
		wndCurr:SetTooltip("Quest rewards these amps.\nCan also be dropped\nby enemies or bought on\nthe Commodities Exchange.")
	end
	
	if (self.nClass == self.nClassDisplayed) then
		self:UpdateCondAMP(wndCurr)
	end
	
	return nTop+18
end

function AMPFinder:AddConditionAMPs(loc1, loc2, wndVend, nTop, questTooltip)
	local tNameSorter = { }
	local tNameIndex = { }
	
	local tThisClassAmps = AllAmpData[self.nClassDisplayed]
	if (tThisClassAmps == nil) then
		return nTop
	end
	
	if (self.nClass ~= self.nClassDisplayed) then
		local wndCurr = Apollo.LoadForm(self.xmlDoc, "Condition", wndVend, self)
		wndCurr:FindChild("ConditionField"):SetText(
			karClassNames[self.nClassDisplayed].." AMPs:")
		wndCurr:FindChild("ConditionField"):SetTextColor("UI_TextHoloBodyHighlight")
		wndCurr:FindChild("Image"):SetSprite(nil)
		wndCurr:SetAnchorOffsets(0, nTop, 0, nTop+25)
		nTop = nTop+20
	end
	
	for idx, rec in pairs(tThisClassAmps) do
		local spellData = GameLib.GetSpell(idx)
		if (spellData ~= nil) then
			local sAmpName = spellData:GetName()
			
			local nRecord = tThisClassAmps[idx]
			if (nRecord ~= nil) then
				local nLoc = nRecord[kiLocation]
				if (nLoc == nil) then nLoc = knLocUnknown end
				if ((nLoc == loc1) or (nLoc == loc2)) or (loc1 == nil) then
					table.insert(tNameSorter, sAmpName)
					tNameIndex[sAmpName] = idx
				end
			end
		end
	end
	table.sort(tNameSorter)
	for i,sAmpName in ipairs(tNameSorter) do
		local nSpellId = tNameIndex[sAmpName]
		local tRecord = tThisClassAmps[nSpellId]
		nTop = self:AddConditionAMP(wndVend, nTop, sAmpName, nSpellId, tRecord[4], questTooltip)
	end
	return nTop
end


function AMPFinder:HookPosTrack(bHookMe)
	if (self.timerPos == nil) then return end
	
	if (bHookMe) then
		self.timerPos:Start()
	else
		self.timerPos:Stop()
	end
end

function AMPFinder:OnQuestStateChanged() 
	local wndInfo = self.wndMain:FindChild("AMP_Info")
	for idx, wndContent in pairs(wndInfo:GetChildren()) do
		for idx, wndCondition in pairs(wndContent:GetChildren()) do
			local tData = wndCondition:GetData()
			if (tData) then
				if (tData[1] == knCondQuest) then
					self:UpdateCondQuest(wndCondition,tData)
				end
			end -- tData
		end -- wndContent:GetChildren
	end -- wndInfo:GetChildren
end

function AMPFinder:OnPlayerCurrencyChanged()
	local wndInfo = self.wndMain:FindChild("AMP_Info")
	for idx, wndContent in pairs(wndInfo:GetChildren()) do
		for idx, wndCondition in pairs(wndContent:GetChildren()) do
			local tData = wndCondition:GetData()
			if (tData) then
				if (tData[1] == knCondPrestige) then
					self:UpdateCondPrestige(wndCondition)
				end
			end -- tData
		end -- wndContent:GetChildren
	end -- wndInfo:GetChildren
end

function AMPFinder:OnReputationChanged(tFaction)
	local wndInfo = self.wndMain:FindChild("AMP_Info")
	for idx, wndContent in pairs(wndInfo:GetChildren()) do
		for idx, wndCondition in pairs(wndContent:GetChildren()) do
			local tData = wndCondition:GetData()
			if (tData) then
				if (tData[1] == knCondReputation) then
					self:UpdateCondReputation(wndCondition)
				end
			end -- tData
		end -- wndContent:GetChildren
	end -- wndInfo:GetChildren
end

-- called whenever an AMP is unlocked on the pane
function AMPFinder:OnAMPChanged() 
	local wndInfo = self.wndMain:FindChild("AMP_Info")
	for idx, wndContent in pairs(wndInfo:GetChildren()) do
		for idx, wndCondition in pairs(wndContent:GetChildren()) do
			local tData = wndCondition:GetData()
			if (tData) then
				if (tData[1] == knCondAMP) then
					self:UpdateCondAMP(wndCondition,tData)
				end
			end -- tData
		end -- wndContent:GetChildren
	end -- wndInfo:GetChildren
	
	self:UpdateInterfaceMenuAlerts()
end

function AMPFinder:UpdateArrowVendor(bForceUpdate) -- (wndVendor, wndParent)
	local wndVendor = self.wndArrowPane
	local wndParent = self.wndArrowLabel
	
	local tData = wndParent:GetData()
	local wndArrow = wndVendor:FindChild("Arrow")
	
	wndArrow:DestroyAllPixies()
	
	-- update purchases
	-- traverse the parent, find any getData. if any rep or locked amps are present, we're not complete
	local bComplete = true
	
	for idx, wndCondition in pairs(wndVendor:GetChildren()) do
		local tData = wndCondition:GetData()
		if (tData) then
			if (tData[1] == knCondReputation) then
				bComplete = false
			elseif (tData[1] == knCondAMP) then
				if (tData[3] == false) then
					bComplete = false
				end
			end
		end -- tData
	end
	
	if (bComplete) then
		wndParent:SetTooltip("Purchased all AMPs from vendor")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextTextPureGreen")
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_Checkmark")
		
	end
	
	if (self.bAmpLocations == false) then return end
		
	if (self.bMoving) or (bForceUpdate) then
	
		local tZoneInfo = GameLib.GetCurrentZoneMap()
		
		if (tZoneInfo == nil) or (tZoneInfo.id ~= math.abs(self.nDisplayedPane)) then
			strShownZoneName = ktPaneData[self.nDisplayedPane][1]
	
			wndArrow:SetTextFlags("DT_CENTER", true)
			wndArrow:SetTextFlags("DT_VCENTER", true)
			wndArrow:SetTextFlags("DT_WORDBREAK", true)

			if (bComplete) then
				wndArrow:SetText("Purchased all AMPs from vendor")
			else
				wndArrow:SetText("Travel to "..strShownZoneName)
			end
			return
			
		end
		
		wndArrow:SetTextFlags("DT_CENTER", false)
		wndArrow:SetTextFlags("DT_VCENTER", false)
		wndArrow:SetTextFlags("DT_WORDBREAK", false)

		local arLocations = self.LocationToVendor[tData[2]]
		if (arLocations == nil) then return end
		local nNearestIdx = 1 -- fallback
		local nNearestDist = 99999999
		for idx = 1, #arLocations do
			local dist = self:GetDistanceSquared(arLocations[idx])
			if (dist < nNearestDist) then
				nNearestIdx = idx
				nNearestDist = dist
			end
		end	

		-- sqrt is expensive, so only sqrt once
		local distance = math.sqrt(nNearestDist)
		wndArrow:SetText(math.floor(distance).."m")	
		local tVendorData = arLocations[nNearestIdx]
		if (tVendorData == nil) then return end  -- bugcheck
		
		-- TODO: Cache text changes so we aren't changing the vendor constantly
		wndVendor:FindChild("AddInfo"):SetText(tVendorData[2].."\n("..round(tVendorData[3])..","..round(tVendorData[4])..")")
		wndParent:FindChild("ConditionField"):SetText(tVendorData[5]);
			
		local strSpriteName
		if (distance < 5) then
			local nPixieId = wndArrow:AddPixie({
			  bLine = false,
			  strSprite = "Crafting_CoordSprites:sprCoord_Checkmark",
			  fRotation = 0,
			  loc = {
			    fPoints = {0,0,1,1},
			    nOffsets = {20,0,-20,0}
			  },
			})	
		else
			local nPixieId = wndArrow:AddPixie({
			  bLine = false,
			  strSprite = "ClientSprites:MiniMapPlayerArrow",
			  fRotation = self:GetDegree(arLocations[nNearestIdx]), -- nDegree,
			  loc = {
			    fPoints = {0,0,1,1},
			    nOffsets = {20,0,-20,0}
			  },
			})	
		end
		
	end -- if moving
end -- update arrow vendor

function AMPFinder:UpdateArrowQuestgiver(bForceUpdate) -- (wndVendor, wndParent)
	local wndVendor = self.wndArrowPane
	local wndParent = self.wndArrowLabel
	
	local tData = wndParent:GetData()
	local wndArrow = wndVendor:FindChild("Arrow")
	
	wndArrow:DestroyAllPixies()

	-- update quest progress
	-- traverse the parent, find any getData. if any quests aren't complete, we're not complete
	local bComplete = true
	for idx, wndCondition in pairs(wndVendor:GetChildren()) do
		local tData = wndCondition:GetData()
		if (tData) then
			if (tData[1] == knCondQuest) then bComplete = false end
		end -- tData
	end

	if (bComplete) then
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextTextPureGreen")
		wndParent:FindChild("ConditionField"):SetTooltip("Questline complete. You'll need to look elsewhere for these amps.")
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_Checkmark")
	end
	
	if (self.bAmpLocations == false) then return end
	
	if (self.bMoving) or (bForceUpdate) then
		local tZoneInfo = GameLib.GetCurrentZoneMap()
		
		if (tZoneInfo == nil) or (tZoneInfo.id ~= math.abs(self.nDisplayedPane)) then
			strShownZoneName = ktPaneData[self.nDisplayedPane][1]
	
			wndArrow:SetTextFlags("DT_CENTER", true)
			wndArrow:SetTextFlags("DT_VCENTER", true)
			wndArrow:SetTextFlags("DT_WORDBREAK", true)
			if (bComplete) then
				wndArrow:SetText("Obtained AMP reward")
			else
				wndArrow:SetText("Travel to "..strShownZoneName)
			end
			return
			
		end
		
		wndArrow:SetTextFlags("DT_CENTER", false)
		wndArrow:SetTextFlags("DT_VCENTER", false)
		wndArrow:SetTextFlags("DT_WORDBREAK", false)
	
		-- Questgivers can only have one valid location		
		local arLocations = self.LocationToVendor[tData[2]]
		local distance = math.sqrt(self:GetDistanceSquared(arLocations[1]))
		wndArrow:SetText(math.floor(distance).."m")	
		
		local tVendorData = arLocations[1]

		local strSpriteName
		if (distance < 5) then 
			local nPixieId = wndArrow:AddPixie({
			  bLine = false,
			  strSprite = "Crafting_CoordSprites:sprCoord_Checkmark",
			  fRotation = 0,
			  loc = {
			    fPoints = {0,0,1,1},
			    nOffsets = {20,0,-20,0}
			  },
			})	
		else
			local nPixieId = wndArrow:AddPixie({
			  bLine = false,
			  strSprite = "ClientSprites:MiniMapPlayerArrow",
			  fRotation = self:GetDegree(arLocations[1]),
			  loc = {
			    fPoints = {0,0,1,1},
			    nOffsets = {20,0,-20,0}
			  },
			})	
		end
	end -- if moving
end

function AMPFinder:UpdateCondQuest(wndParent)
	local tData = wndParent:GetData()
	
	local epiKey = self:GetKeyEpisode(tData[2])
	local bComplete = false
	local bInProgress = false
	if (epiKey ~= nil) then
		tEpisodeProgress = epiKey:GetProgress()
		for idx, queSelected in pairs(epiKey:GetAllQuests()) do
			local nQuestId = queSelected:GetId()
			if (nQuestId == tData[3]) then
				local nStatus = GetQuestStatus(queSelected)
				if (nStatus == 2) then
					bComplete = true
				elseif (nStatus == 1) then
					bInProgress = true
				end
			end
		end
	end
	if (bComplete) then
		wndParent:SetData(nil) -- prevent future updates, it's complete
		wndParent:SetTooltip("")
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_Checkmark")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextTextPureGreen")
	elseif (bInProgress) then  -- experimental
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kiticon_Holo_Forward")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_BtnTextHoloListNormal")	
	else
		wndParent:FindChild("Image"):SetSprite(nil)
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextDefault")
	end
end

function AMPFinder:UpdateCondPrestige(wndParent)
	local tData = wndParent:GetData()
	local nCurrent = GameLib.GetPlayerCurrency(Money.CodeEnumCurrencyType.Prestige):GetAmount()
	wndParent:FindChild("ConditionField"):SetText(nCurrent.."/"..tData[2].." "..Apollo.GetString("CRB_Prestige"))
	if (nCurrent > tData[2]) then
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_Checkmark")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextTextPureGreen")
	else
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_X")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextDefault")
	end
end

function AMPFinder:UpdateCondReputation(wndParent)
	local tData = wndParent:GetData()
	local tReputationInfo = GameLib.GetReputationInfo()
	local tThisRep
	for idx, tRep in pairs(tReputationInfo) do
		if (tRep.strName == tData[2]) then tThisRep = tRep end
	end
	
	if (tThisRep == nil) then
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_QuestionMark")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextDefault")
	elseif (tThisRep.nCurrent >= 8000) then
		wndParent:SetData(nil) -- prevent future updates, rep attained
		wndParent:SetTooltip("")
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_Checkmark")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextTextPureGreen")
		wndParent:FindChild("ConditionField"):SetText(tThisRep.strName..": "..
			"8000/8000")

	else
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kiticon_Holo_Forward")
		wndParent:FindChild("ConditionField"):SetTextColor("UI_WindowTextDefault")
		wndParent:FindChild("ConditionField"):SetText(tThisRep.strName..": "..
			tThisRep.nCurrent.."/8000")
	end	
end

function AMPFinder:UpdateCondAMP(wndParent) 
	local tData = wndParent:GetData()
	local intFound, strAmpTier, tAmp = self:IsLearnedBySpellId(tData[2])
	if (tAmp ~= nil) and (tAmp.eEldanAvailability ~= AbilityBook.CodeEnumEldanAvailability.Unavailable) then
		wndParent:SetData( { tData[1], tData[2], true, tData[4] } )  -- set data to 'true' to indicate it's okay
		wndParent:FindChild("Image"):SetSprite(nil)
	else 
		wndParent:FindChild("Image"):SetSprite("CRB_Basekit:kitIcon_Holo_LockDisabled")
	end
end

function AMPFinder:UpdateCharacterPosition()
	-- Updates character position and changes framerate
	
	local unitPlayer = GameLib.GetPlayerUnit()
	if (unitPlayer == nil) then return end
	
	local tPlayerPos = unitPlayer:GetPosition()
	local nHeading = unitPlayer:GetHeading()
	if (tPlayerPos == nil) then return end
	if (nHeading == nil) then return end

	local nDeltaX = tPlayerPos.x - self.tPlayerPos.x
	local nDeltaZ = tPlayerPos.z - self.tPlayerPos.z
	local nDeltaH = nHeading - self.nHeading
	
	if (nDeltaX ~= 0) or (nDeltaZ ~= 0) or (nDeltaH ~= 0) then
		self.bMoving = true
		self.idleTicks = 0
		
		if (GameLib:GetFrameRate() > 15) then
			self.TimerSpeed = knFastDelay
		else 
			self.TimerSpeed = knSlowDelay
		end
		
		self.timerPos:Set(self.TimerSpeed, true)		
	else
		self.bMoving = false
		self.idleTicks = self.idleTicks + 1
		
		if (self.idleTicks == 50) then
			self.TimerSpeed = knSlowDelay
			self.timerPos:Set(self.TimerSpeed, true)
		end
	end
	
	self.tPlayerPos = tPlayerPos
	self.nHeading = nHeading
	
	local tZoneInfo = GameLib.GetCurrentZoneMap()
	if (tZoneInfo ~= nil) then
		self.nZoneId = tZoneInfo.id
	end
end

function AMPFinder:UpdateArrow()
	-- Each vendor/questgiver window has an "arrow" associated with it.
	-- If no arrow, exit function

	if (self.bPosTracking == false) then
		self:HookPosTrack(false)
		return
	end

	if (self.bAmpLocations == false) then return end
	
	self:UpdateCharacterPosition()
	
	if (self.bMoving) then
	
		if (self.nArrowType == 0) then
			return
		elseif (self.nArrowType == 1) then
			self:UpdateArrowVendor()
		elseif (self.nArrowType == 2) then
			self:UpdateArrowQuestgiver()
		end
		
	end
	
	if (self.wndMain:IsShown() == false) then
		self:HookPosTrack(false)
		return
	end

	
end

function AMPFinder:InvokeWindowPref()
	-- TODO: allow the window to be persistent if set by user preference.
	-- this is where we would force window to be shown if it weren't already, on a zone change
	-- self.wndMain:Invoke()
end

---------------------------------------------------------------------------------------------------
-- AMPFinder Functions
---------------------------------------------------------------------------------------------------

function AMPFinder:CompactWindow()
	self.wndMain:FindChild("MiniFrame"):Show(true)
	self.wndMain:FindChild("CloseBtn"):Show(false)
	self.wndMain:FindChild("BGPane"):Show(false)
	self.wndMain:FindChild("Frame"):Show(false)
	self.wndMain:FindChild("WindowTitle"):Show(false)
	self.wndMain:FindChild("PickerBtn"):SetCheck(false)
	self.wndMain:FindChild("PickerBtn"):Show(false)
	self.wndMain:FindChild("PickerListFrame"):Show(false)
	self.wndMain:FindChild("PickerFrame"):Show(false)
	self.wndMain:FindChild("ClassFrame"):Show(false)
	self.wndMain:FindChild("ClassFrame"):FindChild("ClassButton"):SetCheck(false)
	self.wndMain:FindChild("ClassListFrame"):Show(false)
	self.wndMain:FindChild("AMP_Info"):SetStyle("VScroll", false)
	self.wndMain:FindChild("AMP_Info"):SetVScrollPos(0)
	self.wndMain:FindChild("AMP_Info"):SetAnchorOffsets(-28, -11, 288, 90)
	self.wndMain:FindChild("MiniFrame"):SetAnchorOffsets(0, -3, 241, 95)
	self.wndMain:FindChild("CompactBtn"):SetAnchorOffsets(211, -4, 243, 28)
end

function AMPFinder:UnCompactWindow()
	self.wndMain:FindChild("MiniFrame"):Show(false)
	self.wndMain:FindChild("CloseBtn"):Show(true)
	self.wndMain:FindChild("BGPane"):Show(true)
	self.wndMain:FindChild("Frame"):Show(true)
	self.wndMain:FindChild("WindowTitle"):Show(true)
	self.wndMain:FindChild("PickerBtn"):Show(true)
	self.wndMain:FindChild("PickerFrame"):Show(true)
	self.wndMain:FindChild("ClassFrame"):Show(true)
	self.wndMain:FindChild("AMP_Info"):SetStyle("VScroll", true)
	self.wndMain:FindChild("AMP_Info"):SetAnchorOffsets(35, 115, 351, 390)
	self.wndMain:FindChild("MiniFrame"):SetAnchorOffsets(83, 21, 324, 119)
	self.wndMain:FindChild("CompactBtn"):SetAnchorOffsets(294, 20, 326, 52)
end

function AMPFinder:OnCompactShrink( wndHandler, wndControl, eMouseButton )
	if (self.bCompact) then return end
	self.bCompact = true
	self:CompactWindow()
	local nLeft, nTop, nRight, nBottom = self.wndMain:GetAnchorOffsets()
	self.wndMain:SetAnchorOffsets(nLeft+83, nTop+24, nLeft+83+245, nTop+24+100)

	-- thanks to sinaloit :)	
	local OptInterface = GetOptionsAddon() -- Apollo.GetAddon("OptionsInterface")
	if (OptInterface ~= nil) then
	    OptInterface:UpdateTrackedWindow(self.wndMain)
	end
end

function AMPFinder:OnCompactRestore( wndHandler, wndControl, eMouseButton )
	if (self.bCompact == false) then return end
	self.bCompact = false
	self:UnCompactWindow()
	local nLeft, nTop, nRight, nBottom = self.wndMain:GetAnchorOffsets()
	self.wndMain:SetAnchorOffsets(nLeft-83, nTop-24, nLeft-83+386, nTop-24+421)
	
	-- thanks to sinaloit :)
	local OptInterface = GetOptionsAddon() -- Apollo.GetAddon("OptionsInterface")
	if (OptInterface ~= nil) then
	    OptInterface:UpdateTrackedWindow(self.wndMain)
	end
end

function AMPFinder:OnWindowShow( wndHandler, wndControl )
	if (self.bInitialShow == false) then return end
	self.bInitialShow = false

	local nLeft, nTop, nRight, nBottom = self.wndMain:GetAnchorOffsets()
	if (nBottom-nTop < 421) then
		self.bCompact = true
		self.wndMain:FindChild("CompactBtn"):SetCheck(false)
		self:CompactWindow()
	else
		self.bCompact = false
		self.wndMain:FindChild("CompactBtn"):SetCheck(true)
		self:UnCompactWindow()
	end
	
end

------------------------------------------------------------------
-- AMPFinder Instance
-----------------------------------------------------------------------------------------------
local AMPFinderInst = AMPFinder:new()
AMPFinderInst:Init()
