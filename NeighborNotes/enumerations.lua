-- Harvest Node Info
NeighborNotes.tEnums = {
	tPlugType = {
		["Biome"]		= {	nID = 001,	strIcon = "CRB_MinimapSprites:sprMM_InstancePortal" },
		["Challenge"]	= { nID = 002,	strIcon = "IconSprites:Icon_Achievement_Achievement_Challenges" },
		["Expedition"]	= { nID = 003,	strIcon = "IconSprites:Icon_Achievement_Achievement_Shiphand" },
		["Dungeon"]		= { nID = 004,	strIcon = "IconSprites:Icon_Achievement_Achievement_Dungeon" },
		["Raid"]		= { nID = 005,	strIcon = "IconSprites:Icon_Achievement_Achievement_Raid" },
		["PublicEvent"] = { nID = 006,	strIcon = "IconSprites:Icon_Achievement_Achievement_WorldEvent" },
		["Item"]		= {	nID = 010,	strIcon = "" },
	},

	tNodes = {
		[001]	= { strName = "Relic Dig Tier 1", strIcon = "IconSprites:Icon_TradeskillMisc_Standard_omniplasm" },
		[002]	= { strName = "Relic Dig Tier 2", strIcon = "IconSprites:Icon_TradeskillMisc_AdvancedOmniplasm" },
		[003]	= { strName = "Relic Dig Tier 3", strIcon = "IconSprites:Icon_TradeskillMisc_Kinetic_omniplasm" },
		[004]	= { strName = "Relic Dig Tier 4", strIcon = "IconSprites:Icon_TradeskillMisc_DynamicOmniplasm" },
		[011]	= { strName = "Thicket Tier 1", strIcon = "IconSprites:Icon_TradeskillMisc_AncientWood" },
		[012]	= { strName = "Thicket Tier 2", strIcon = "IconSprites:Icon_TradeskillMisc_AugmentedWood" },
		[013]	= { strName = "Thicket Tier 3", strIcon = "IconSprites:Icon_TradeskillMisc_Ironbark_wood" },
		[014]	= { strName = "Thicket Tier 4", strIcon = "IconSprites:Icon_TradeskillMisc_PrimalHardwood" },
		[021]	= { strName = "Mineral Deposit Tier 1", strIcon = "IconSprites:Icon_TradeskillMisc_Iron_Ore" },
		[022]	= { strName = "Mineral Deposit Tier 2", strIcon = "IconSprites:Icon_TradeskillMisc_PlatinumOre" },
		[023]	= { strName = "Mineral Deposit Tier 3", strIcon = "IconSprites:Icon_TradeskillMisc_Xenocite_ore" },
		[024]	= { strName = "Mineral Deposit Tier 4", strIcon = "IconSprites:Icon_TradeskillMisc_Galactium_ore" },
	},
	
	tPlugs = {
		-- Useful Plots
		[001] = { strName = "Festival", strIcon = "IconSprites:Icon_Windows_UI_CRB_Adventure_Malgrave_Food"},
		--[002] = { strName = "Garden", },
		[003] = { strName = "Vending Machine", strIcon = "IconSprites:Icon_MapNode_Map_vendor_Consumable" },
		[004] = { strName = "Crafting Station", strIcon = "IconSprites:Icon_MapNode_Map_Tradeskill" },
		[005] = { strName = "Warhorn", strIcon = "IconSprites:Icon_ItemMisc_Horn_02" },
		[006] = { strName = "Mailbox", strIcon = "IconSprites:Icon_MapNode_Map_Mailbox" },
		[007] = { strName = "Personal Bank", strIcon = "IconSprites:Icon_MapNode_Map_Bank" },
		[008] = { strName = "Floor Piano", strIcon = "IconSprites:Icon_Housing1x1_1947_Darkspur_Floor_Piano_03" },
				
		-- Biome Teleports
		[101] = { strName = "Algoroc"},
		[102] = { strName = "Auroria"},
		[103] = { strName = "Celestion"},
		[104] = { strName = "Crimson Isle"},
		[105] = { strName = "Deradune"},
		[106] = { strName = "Ellevar"},
		[107] = { strName = "Everstar Grove"},
		[108] = { strName = "Farside"},
		[109] = { strName = "Galeras"},
		[110] = { strName = "Grimvault"},
		[111] = { strName = "Levian Bay"},
		[112] = { strName = "Malgrave"},
		[113] = { strName = "Northern Wilds"},
		[114] = { strName = "Whitevale"},
		[115] = { strName = "Wilderrun"},
		
		-- 1x1 Challenges
		[201] = { strName = "Anti-Air Defense Tower"},
		[202] = { strName = "Bone Pit"},
		[203] = { strName = "Cubig Feeder"},
		[204] = { strName = "Flying Saucer"},
		[205] = { strName = "Medical Station"},
		[206] = { strName = "Weather Control Station"},
		[207] = { strName = "Whirlwind"},
		
		-- 1x2 Challenges
		[301] = { strName = "Eldan Excavation"},
		[302] = { strName = "Garbage Dump"},
		[303] = { strName = "Ice Pond"},
		[304] = { strName = "Large Spiderland"},
		[305] = { strName = "Lopp Party"},
		[306] = { strName = "Magma Flow"},
		[307] = { strName = "Moonshiner Cabin"},
		[308] = { strName = "Prospector Plot"},  ---  NOT FOUND YET
		[309] = { strName = "Protostar Hazard Training Course"},
		[310] = { strName = "Shardspire Canyon"},
		[311] = { strName = "Spooky Graveyard"},
		[312] = { strName = "Osun Forge"},
		
		-- 1x1 Expeditions
		[401] = { strName = "Abandoned Eldan Test Lab"}, -- Conflicts with the other Instance Portals
		[402] = { strName = "Creepy Cave"}, -- Conflicts with the other Instance Portals
		[403] = { strName = "Kel Voreth Underforge"}, -- Conflicts with the other Instance Portals
		[404] = { strName = "Mayday"},
		
		-- 1x2 Expeditions
		--[501] = { strName = "",
		
		-- 1x1 Raids
		[601] = { strName = "Datascape Raid Portal"},
		
		-- 1x2 Raids
		--[701] = "",
		
		-- 1x1 Public Event
		--[801] = "",
		
		-- 1x2 Public Event
		[901] = { strName = "Blasted Landscape"},
		[902] = { strName = "Corrupted Laboratory"},
	},
}
	