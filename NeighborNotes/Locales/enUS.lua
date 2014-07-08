------------------------------------------------------------------------------------------------
-- This is a locale file for Neighbor Notes
-- If you are editing this file for a particular language, do not change the names in blocks [ ] 
-- You want change the names after the =
-- So if you're changing thicket, it should look like this:
-- ["Thicket"] = "Dickicht" -- German translation
------------------------------------------------------------------------------------------------

NeighborNotes.tLocale.en = {

	tProfessionNames = {
		["Relic Hunter"] 	= "Relic Hunter",
		["Survivalist"]		= "Survivalist",
		["Mining"]			= "Mining",
	},

---------------------------------------------------------------------------------------------
-- For Nodes, again, do not change the names in blocks [ ].  Only modify the names after the =
-- Do not change the variable names, 'strName' and 'tUnits'
-- strName = the name of the plug
-- tUnits = a table which represents the units which are associated with the node
--   Neighbor Notes uses the units to determine which nodes are on the property
---------------------------------------------------------------------------------------------
	tNodes = {
		-- Node Plug Names
		["Thicket Tier 1"]	= { strName = "Thicket Tier 1", tUnits = { "Deradune Tree", "Algoroc Tree", "Ellevar Tree", "Celestion Tree", } },
		["Thicket Tier 2"]	= { strName = "Thicket Tier 2", tUnits = { "Galeras Tree", "Whitevale Tree" ,"Auroria Tree", } },
		["Thicket Tier 3"]	= { strName = "Thicket Tier 3", tUnits = { "Wilderrun Tree", "Farside Tree", } },
		["Thicket Tier 4"]	= { strName = "Thicket Tier 4", tUnits = { "Grimvault Tree", "Malgrave Tree", } },
		
		["Relic Dig Tier 1"]	= {	strName = "Relic Dig Tier 1",	tUnits = {"Standard Relic Node", "Accelerated Relic Node", } },
		["Relic Dig Tier 2"]	= {	strName = "Relic Dig Tier 2",	tUnits = {"Advanced Relic Node", } },
		["Relic Dig Tier 3"]	= {	strName = "Relic Dig Tier 3",	tUnits = {"Dynamic Relic Node", } },
		["Relic Dig Tier 4"]	= {	strName = "Relic Dig Tier 4",	tUnits = {"Kinetic Relic Node", } },
		
		["Mineral Deposit Tier 1"]	= { strName = "Mineral Deposit Tier 1", tUnits = {"Iron Node", "Titanium Node", "Zephyrite Node",} },
		["Mineral Deposit Tier 2"]	= { strName = "Mineral Deposit Tier 2", tUnits = {"Platinum Node", "Hydrogem Node",} },
		["Mineral Deposit Tier 3"]	= { strName = "Mineral Deposit Tier 3", tUnits = {"Xenocite Node", "Shadeslate Node",} },
		["Mineral Deposit Tier 4"]	= { strName = "Mineral Deposit Tier 4", tUnits = {"Galactium Node", "Novacite Node",} },
	},
	
---------------------------------------------------------------------------------------------
-- For Plugs, again, do not change the names in blocks [ ].  Only modify the names after the =
-- Do not change the variable names, 'strName' and 'tUnits'
-- strName = the name of the plug
-- tUnits is a table which represents the units which are associated with the plug
--   Neighbor Notes uses the units to determine which plugs are on the property
---------------------------------------------------------------------------------------------
	tPlugs = {
		-- Useful stuff
		["Festival"] 			= { strName = "Festival", 			tUnits = { "Food Table" } },
		["Vending Machine"] 	= { strName = "Vending Machine", 	tUnits = { "Snack-O-Matic 3000" } },
		["Crafting Station"] 	= { strName = "Crafting Station",  	tUnits = { "Crafting Station" } },
		["Warhorn"] 			= { strName = "Warhorn", 			tUnits = { "Warhorn" } },
		["Mailbox"]				= { strName = "Mailbox", 			tUnits = { "Exile Mailbox", "Dominion Mailbox", "Draken Mailbox", "Aurin Mailbox", "Chua Mailbox", } },
		["Personal Bank"]		= { strName = "Personal Bank",		tUnits = { "Private Storage" } },
		["Floor Piano"]			= { strName = "Floor Piano",		tUnits = { "Octave" } },
	
		-- Biome Portals
		["Algoroc"]			= { strName = "Algoroc",		tUnits = { "Algoroc Portal" } },
		["Auroria"]			= { strName = "Auroria",		tUnits = { "Auroria Portal" } },
		["Celestion"]		= { strName = "Celestion",		tUnits = { "Celestion Portal" } },
		["Crimson Isle"]	= { strName = "Crimson Isle",	tUnits = { "Crimson Isle Portal" } },
		["Deradune"]		= { strName = "Deradune",		tUnits = { "Deradune Portal" } },
		["Ellevar"]			= { strName = "Ellevar",		tUnits = { "Ellevar Portal" } },
		["Everstar Grove"]	= { strName = "Everstar Grove",	tUnits = { "Everstar Grove Portal" } },
		["Farside"]			= { strName = "Farside",		tUnits = { "Farside Portal" } },
		["Galeras"]			= { strName = "Galeras",		tUnits = { "Galeras Portal" } },
		["Grimvault"]		= { strName = "Grimvault",		tUnits = { "Grimvault Portal" } },
		["Levian Bay"] 		= { strName = "Levian Bay", 	tUnits = { "Levian Bay Portal" } },
		["Malgrave"]		= { strName = "Malgrave", 		tUnits = { "Malgrave Portal" } },
		["Northern Wilds"] 	= { strName = "Northern Wilds", tUnits = { "Northern Wilds Portal" } },
		["Whitevale"]		= { strName = "Whitevale", 		tUnits = { "Whitevale Portal" } },
		["Wilderrun"]		= { strName = "Wilderrun",		tUnits = { "Wilderrun Portal" } },
			
		-- 1x1 Challenges		
		["Anti-Air Defense Tower"]	= { strName = "Anti-Air Defense Tower",	tUnits = { "Rocket Launcher" } },
		["Bone Pit"]				= { strName = "Bone Pit", 				tUnits = { "Spirit Zapper" } },
		["Cubig Feeder"]			= { strName = "Cubig Feeder",			tUnits = { "Cubig Feeder" } },
		["Flying Saucer"]			= { strName = "Flying Saucer",			tUnits = { "Ikthian Flying Saucer" } },
		["Medical Station"]			= {	strName = "Medical Station",		tUnits = { "Lightly Wounded Patient", "Seriously Wounded Patient", "Critically Wounded Patient" } },
		["Weather Control Station"]	= { strName = "Weather Control Station", tUnits = { "Electrostatic Container" } },
		["Whirlwind"]				= { strName = "Whirlwind",				tUnits = { "Air-infused Crystal" } },
	
		-- 1x2 Challenges
		["Eldan Excavation"] 				= { strName = "Eldan Excavation",	tUnits = { "Research Desk" } },
		["Garbage Dump"]					= { strName = "Garbage Dump", 		tUnits = { "The Pile!" } },
		["Ice Pond"]						= { strName = "Ice Pond",			tUnits = { "Anomaly Scanner" } },
		["Large Spiderland"]				= { strName = "Large Spiderland",	tUnits = { "Anachronondax" } },
		["Lopp Party"]						= { strName = "Lopp Party",			tUnits = { "Celebratory Incense" } },
		["Magma Flow"]						= { strName = "Magma Flow",			tUnits = { "Crazed Fire Elemental" } },
		["Moonshiner Cabin"]				= {	strName = "Moonshiner Cabin",	tUnits = { "Spigot" } },
		["Prospector Plot"]					= { strName = "Prospector Plot", 	tUnits = {} },
		["Protostar Hazard Training Course"] = { strName = "Protostar Hazard Training Course", tUnits = { "Protostar Hazard Training Console" } },
		["Shardspire Canyon"]				= { strName = "Shardspire Canyon",	tUnits = { "Plushie" } },
		["Spooky Graveyard"]				= { strName = "Spooky Graveyard",	tUnits = { "Call To The Spirits!" } },
		["Osun Forge"]						= { strName = "Osun Forge",			tUnits = { "Book of Elements" } },
	
		-- Expeditions
		["Abandoned Eldan Test Lab"] 	= { strName = "Abandoned Eldan Test Lab", 	tUnits = { } },
		["Creepy Cave"]					= { strName = "Creepy Cave",				tUnits = { } },
		["Kel Voreth Underforge"] 		= { strName = "Kel Voreth Underforge", 		tUnits = { } },
		["Mayday"] 						= { strName = "Mayday", 					tUnits = { "Transport Ship" } },
	
		-- Raids
		["Datascape Raid Portal"] 	= { strName = "Datascape Raid Portal", 	tUnits = { } },
	
		-- Public Events
		["Blasted Landscape"] 		= { strName = "Blasted Landscape", 		tUnits = { "Exile Beacon" } },
		["Corrupted Laboratory"]		= { strName = "Corrupted Laboratory",	tUnits = { "Control Panel" } },
	},
}