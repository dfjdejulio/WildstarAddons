-----------------------------------------------------------------------------------------------
-- Client Lua Script for NeighborNotes
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Unit"
require "FriendshipLib"
require "string"
require "HousingLib"
require "CraftingLib"

-----------------------------------------------------------------------------------------------
-- NeighborNotes Module Definition
-----------------------------------------------------------------------------------------------
local NeighborNotes = {}

local ktNodeType =
{
	["Relic"] = 1,
	["Survival"] = 2,
	["Mining"] = 3,
}

local ktRelicNodeWeight =
{
	["Standard Relic Node"] = 1,	
	["Accelerated Relic Node"] = 1,
	["Advanced Relic Node"] = 2,	
	["Dynamic Relic Node"] = 3,
	["Kinetic Relic Node"] = 4,
}

local ktSurvivalNodeWeight =
{
	["Deradune Tree"] = 1,
	["Algoroc Tree"] = 1,
	["Ellevar Tree"] = 1,
	["Wilderrun Tree"] = 2,
	["Galeras Tree"] = 2,
	["Whitevale Tree"] = 2,
	["Farside Tree"] = 3,
	["Grimvault Tree"] = 4,
	["Malgrave Tree"] = 4,
}	

local ktMiningNodeWeight =
{	
	["Iron Node"] = 1,
	["Titanium Node"] = 1,
	["Platinum Node"] = 2,
	["Xenocite Node"] = 3,
	["Galactium Node"] = 4,

	["Zephyrite Node"] = 2,
	["Hydrogem Node"] = 3,
	["Shadeslate Node"] = 4,
	["Novacite Node"] = 4,
}

local ktRelicNodeName =
{
	[1] = "Relic Hunter 1",
	[2] = "Relic Hunter 2",
	[3] = "Relic Hunter 3",
	[4] = "Relic Hunter 4",
}

local ktSurvivalNodeName =
{
	[1] = "Survival 1",
	[2] = "Survival 2",
	[3] = "Survival 3",
	[4] = "Survival 4",
}

local ktMiningNodeName =
{
	[1] = "Mining 1",
	[2] = "Mining 2",
	[3] = "Mining 3",
	[4] = "Mining 4",
}

local ktRelicNodeIcon = 
{
	[1] = "IconSprites:Icon_TradeskillMisc_Standard_omniplasm",
	[2] = "IconSprites:Icon_TradeskillMisc_AdvancedOmniplasm",
	[3]	= "IconSprites:Icon_TradeskillMisc_Kinetic_omniplasm",
	[4] = "IconSprites:Icon_TradeskillMisc_DynamicOmniplasm",
}

local ktSurvivalNodeIcon =
{
	[1] = "IconSprites:Icon_TradeskillMisc_AncientWood",
	[2] = "IconSprites:Icon_TradeskillMisc_AugmentedWood",
	[3] = "IconSprites:Icon_TradeskillMisc_Ironbark_wood",
	[4] = "IconSprites:Icon_TradeskillMisc_PrimalHardwood",
}

local ktMiningNodeIcon =
{	
	[1] = "IconSprites:Icon_TradeskillMisc_Iron_Ore",
	[2] = "IconSprites:Icon_TradeskillMisc_PlatinumOre",
	[3] = "IconSprites:Icon_TradeskillMisc_Xenocite_ore",
	[4] = "IconSprites:Icon_TradeskillMisc_Galactium_ore",
}

local ktPlugName = 
{
	-- Useful Plots
	[1] = "Festival",
	[2] = "Garden",
	[3] = "Vending Machine",
	[4] = "Crafting Station",
	[5] = "Warhorn",
	[6] = "Mailbox",
	[7] = "Personal Bank",
	
	-- Biome Teleports
	[101] = "Biome: Algoroc",
	[102] = "Biome: Auroria",
	[103] = "Biome: Celestion",
	[104] = "Biome: Crimson Isle",
	[105] = "Biome: Deradune",
	[106] = "Biome: Ellevar",
	[107] = "Biome: Everstar Grove",
	[108] = "Biome: Farside",
	[109] = "Biome: Galeras",
	[110] = "Biome: Grimvault",
	[111] = "Biome: Levian Bay",
	[112] = "Biome: Malgrave",
	[113] = "Biome: Northern Wilds",
	[114] = "Biome: Whitevale",
	[115] = "Biome: Wilderrun",
	
	-- 1x1 Challenges
	[201] = "CHALLENGE: Anti-Air Defense Tower", --
	[202] = "CHALLENGE: Bone Pit", --
	[203] = "CHALLENGE: Cubig Feeder", --
	[204] = "CHALLENGE: Flying Saucer", --
	[205] = "CHALLENGE: Medical Station", --
	[206] = "CHALLENGE: Weather Control Station", --
	[207] = "CHALLENGE: Whirlwind", --
	
	-- 1x2 Challenges
	[301] = "CHALLENGE: Eldan Excavation", --
	[302] = "CHALLENGE: Garbage Dump", --
	[303] = "CHALLENGE: Ice Pond", --
	[304] = "CHALLENGE: Large Spiderland",	--
	[305] = "CHALLENGE: Lopp Party", --
	[306] = "CHALLENGE: Magma Flow", --
	[307] = "CHALLENGE: Moonshiner Cabin", --
	[308] = "CHALLENGE: Prospector Plot",
	[309] = "CHALLENGE: Protostar Hazard Training Course", --
	[310] = "CHALLENGE: Shardspire Canyon", --
	[311] = "CHALLENGE: Spooky Graveyard", --
	[312] = "CHALLENGE: Osun Forge", --
	
	-- 1x1 Expeditions
	[401] = "EXPEDITION: Abandoned Eldan Test Lab", -- Conflicts with the other Instance Portals
	[402] = "EXPEDITION: Creepy Cave", -- Conflicts with the other Instance Portals
	[403] = "EXPEDITION: Kel Voreth Underforge", -- Conflicts with the other Instance Portals
	[404] = "EXPEDITION: Mayday", --
	
	-- 1x2 Expeditions
	--[501] = "",
	
	-- 1x1 Raids
	[601] = "RAID: Datascape Raid Portal", 
	
	-- 1x2 Raids
	--[701] = "",
	
	-- 1x1 Public Event
	--[801] = "",
	
	-- 1x2 Public Event
	[901] = "PUBLIC EVENT: Blasted Landscape", --
}

local ktPlugUnitLookup = 
{
	-- Useful stuff
	["Food Table"] = 1,
	["Snack-O-Matic 3000"] = 3,	
	["Crafting Station"] = 4,
	["Warhorn"] = 5,
	["Dominion Mailbox"] = 6,
	["Exile Mailbox"] = 6,
	["Draken Mailbox"] = 6,
	["Aurin Mailbox"] = 6,
	["Private Storage"] = 7,

	-- Biome Portals
	["Algoroc Portal"] = 101,
	["Auroria Portal"] = 102,
	["Celestion Portal"] = 103,
	["Crimson Isle Portal"] = 104,
	["Deradune Portal"] = 105,
	["Ellevar Portal"] = 106,
	["Everstar Grove Portal"] = 107,
	["Farside Portal"] = 108,
	["Galeras Portal"] = 109,
	["Grimvault Portal"] = 110,
	["Levian Bay Portal"] = 111,
	["Malgrave Portal"] = 112,
	["Northern Wilds Portal"] = 113,
	["Whitevale Portal"] = 114,
	["Wilderrun Portal"] = 115,
	
	-- Challenges		
	["Rocket Launcher"] = 201,
	["Spirit Zapper"] = 202,
	["Cubig Feeder"] = 203,
	["Ikthian Flying Saucer"] = 204,
	["Critically Wounded Patient"] = 205,
	["Seriously Wounded Patient"] = 205,
	["Lightly Wounded Patient"] = 205,
	["Electrostatic Container"] = 206,
	["Air-infused Crystal"] = 207,

	["Research Desk"] = 301,
	["The Pile!"] = 302,
	["Anomaly Scanner"] = 303,
	["Anachronondax"] = 304,
	["Celebratory Incense"] = 305,
	["Crazed Fire Elemental"] = 306,
	["Spigot"] = 307,
	["Protostar Hazard Training Console"] = 309,
	["Plushie"] = 310,
	["Call To The Spirits!"] = 311,
	["Book of Elements"] = 312,

	-- Expeditions
	["Transport Ship"] = 404,
	
	["Exile Beacon"] = 901,
}

local ktGenericPlugIcon =
{
	["Biome"] = "CRB_MinimapSprites:sprMM_InstancePortal",
	["Challenge"] = "IconSprites:Icon_Achievement_Achievement_Challenges",
	["Expedition"] = "IconSprites:Icon_Achievement_Achievement_Shiphand",
	["Dungeon"] = "IconSprites:Icon_Achievement_Achievement_Dungeon",
	["Raid"] = "IconSprites:Icon_Achievement_Achievement_Raid",
	["PublicEvent"] = "IconSprites:Icon_Achievement_Achievement_WorldEvent",
}

local ktPlugIcon =
{
	[1] = "IconSprites:Icon_Windows_UI_CRB_Adventure_Malgrave_Food",
	[3] = "IconSprites:Icon_MapNode_Map_vendor_Consumable",
	[4] = "IconSprites:Icon_MapNode_Map_Tradeskill",
	[5] = "IconSprites:Icon_ItemMisc_Horn_02",
	[6] = "IconSprites:Icon_MapNode_Map_Mailbox",
	[7] = "IconSprites:Icon_MapNode_Map_Bank",
}

local ktDefaultUserSettings = {
	bOpenWithSocial = true,
	bCloseWithSocial = true,
	bOnVisitSelectNext = true,

	tFilters = {
		bHarvestable = false,
		bShowAllCharacters = false,
	},
}

local ktDefaultNeighborInfo = {
	strNote = "",
	nNodeType = 0,
	nNodeID = 0,
	nNodeWeight = 0,
	nPlugWeight = 0,
	tPlugs = {},
}

local knSettingsVersion = 2
local knNeighborListVersion = 1

local kcrOnline = ApolloColor.new("UI_TextHoloBodyHighlight")
local kcrOffline = ApolloColor.new("UI_BtnTextGrayNormal")
local kcrNeutral = ApolloColor.new("gray")

-----------------------------------------------------------------------------------------------
-- Generic Addon Functions
-----------------------------------------------------------------------------------------------

-- This is the constructor
function NeighborNotes:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Registers our Addon with the Apollo UI
function NeighborNotes:Init()
	local bHasConfiguration = true
	local strConfigText = "Neighbor Notes"
	local tDependencies = {
		"SocialPanel",
	}
    Apollo.RegisterAddon(self, bHasConfiguration, strConfigText, tDependencies)
end

-- Loads the initial variables and registers the NN Callback function (for when the window is loaded)
function NeighborNotes:OnLoad()
	self.tActivePlayerSkills = {}
	self.tNeighborNotes = {}
	self.tActiveNodeList = {}
	self.tQueuedUnits = {}
	self.tActiveNodeList = {}
	

	self.tUserSettings = ktDefaultUserSettings
	self.strNeighborName = ""
	self.strCurrentZone = GetCurrentZoneName()
	self.bNeighborZone = NeighborNotes:IsNeighborZone()

	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)

	self.xmlDoc = XmlDoc.CreateFromFile("NeighborNotes.xml")
	if self.xmlDoc == nil then
		Apollo.AddAddonErrorText(self, "Could not load XML form file")
	else
		self.xmlDoc:RegisterCallback("OnDocumentLoaded", self)
	end
end

-- Loads the window data, registers event handlers, slash commands, and timers
function NeighborNotes:OnDocumentLoaded()
	if self.xmlDoc ~= nil then
		-- Register Timers
		self.timerZoneLoad = ApolloTimer.Create(3, false, "ZoneLoadTimer", self)
		
		-- Register event handlers
		Apollo.RegisterEventHandler("ToggleAddon_NN", 				"OpenNN", self)

		Apollo.RegisterEventHandler("HousingNeighborUpdate",		"RefreshList", self)
		Apollo.RegisterEventHandler("HousingNeighborsLoaded", 		"RefreshList", self)
		Apollo.RegisterEventHandler("VarChange_ZoneName",			"OnChangeZoneName", self)
		Apollo.RegisterEventHandler("SubZoneChanged",				"OnChangeZoneName", self)

		-- Monitor the social window events		
		Apollo.RegisterEventHandler("EventGeneric_OpenSocialPanel", "OnSocialWindowToggle", self)
		Apollo.RegisterEventHandler("ToggleSocialWindow", 			"OnSocialWindowToggle", self)
		Apollo.RegisterEventHandler("SocialWindowHasBeenClosed",	"OnSocialWindowClose", self)
		Apollo.RegisterEventHandler("GenericEvent_InitializeNeighbors", "OnSocialWindowToggle", self)		
		
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", 	"OnInterfaceMenuListHasLoaded", self)
		Apollo.RegisterEventHandler("Tutorial_RequestUIAnchor", 	"OnTutorial_RequestUIAnchor", self)
		
		-- Register Slash Commands				
		Apollo.RegisterSlashCommand("neighbornotes", 				"OpenNN", self)
		Apollo.RegisterSlashCommand("nn", 							"OpenNN", self)

		self.timerZoneLoad:Start()
	end	
end


-- Saves data when the game is closed, or when the UI is reloaded
function NeighborNotes:OnSave(eType)
	local tSave = {}
	if eType == GameLib.CodeEnumAddonSaveLevel.Realm then
		tSave = {
			nNeighborListVersion = knNeighborListVersion,
			tNeighborNotes = self.tNeighborNotes,
		}
	end
	
	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		tSave = {
			nSettingsVersion = knSettingsVersion,
			tUserSettings = self.tUserSettings,
		}
	end
	
	return tSave
end

-- Loads data when the game is closed, or when the UI is reloaded
function NeighborNotes:OnRestore(eType, tLoad)
	if not tLoad then
		return
	end
	if eType == GameLib.CodeEnumAddonSaveLevel.Realm then
		if knNeighborListVersion == tLoad.nNeighborListVersion then
			if not tLoad.tNeighborNotes then
				self.tNeighborNotes = {}
			else
				self.tNeighborNotes = tLoad.tNeighborNotes
			end
			-- check for missing data
			for strNeighborName, tData in pairs(self.tNeighborNotes) do
				if not tData.strNote then
					tData.strNote = ""
				end
				if not tData.nNodeType then
					tData.nNodeType = 0
				else
				end
				if not tData.nNodeID then
					tData.nNodeID = 0
				end
				if not tData.nNodeWeight then
					tData.nNodeWeight = 0
				end
				if not tData.nPlugWeight then
					tData.nPlugWeight = 0
				end
				if not tData.nPlugs then
					tData.nPlugs = {}
				end
				if tData.nNodeWeight == 0 and tData.nNodeType ~= 0 then
					tData.nNodeWeight = tData.nNodeType * 10 + tData.nNodeID
				end
			end
		else
			self.tNeighborNotes = {}
		end
	elseif eType == GameLib.CodeEnumAddonSaveLevel.Character then
		self.tUserSettings = ktDefaultUserSettings
		if knSettingsVersion == tLoad.nSettingsVersion then
			if tLoad.tUserSettings.tFilters.bHarvestable ~= nil then
				self.tUserSettings.tFilters.bHarvestable = tLoad.tUserSettings.tFilters.bHarvestable
			end
			if tLoad.tUserSettings.tFilters.bShowAllCharacters ~= nil then
				self.tUserSettings.tFilters.bShowAllCharacters = tLoad.tUserSettings.tFilters.bShowAllCharacters
			end
			if tLoad.tUserSettings.bOpenWithSocial ~= nil then
				self.tUserSettings.bOpenWithSocial = tLoad.tUserSettings.bOpenWithSocial
			end
			if tLoad.tUserSettings.bCloseWithSocial ~= nil then
				self.tUserSettings.bCloseWithSocial = tLoad.tUserSettings.bCloseWithSocial
			end
			if tLoad.tUserSettings.bOnVisitSelectNext ~= nil then
				self.tUserSettings.bOnVisitSelectNext = tLoad.tUserSettings.bOnVisitSelectNext
			end
		end
	end
end

function NeighborNotes:OnConfigure()
	NeighborNotes:OnConfigBtn()
end

------------------------------------------------------------------------------------------
-- Main Draw
------------------------------------------------------------------------------------------
function NeighborNotes:Initialize()
	if not self.wndMain or not self.wndMain:IsValid() then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "NeighborListForm", nil, self)
		if not self.wndMain then
			Apollo.AddAddonErrorText(self, "Could not load the NeighborNotes window.")
			return
		end
		Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = "Neighbor Notes"})

		self.wndListContainer = self.wndMain:FindChild("ListContainer")
		self.wndConfig = self.wndMain:FindChild("ConfigWindow")
		self.wndMain:FindChild("AddMemberCloseBtn"):SetData(self.wndMain:FindChild("AddWindow"))
		self.wndMain:FindChild("EditNoteCloseBtn"):SetData(self.wndMain:FindChild("EditNoteWindow"))
		self.wndMain:FindChild("NodeFilterCloseBtn"):SetData(self.wndMain:FindChild("NodeFilterWindow"))
		self.wndMain:FindChild("NeighborFilterCloseBtn"):SetData(self.wndMain:FindChild("NeighborFilterWindow"))
		self.wndMain:FindChild("AccountWideCheckbox"):SetCheck(self.tUserSettings.tFilters.bShowAllCharacters)
		self.wndMain:FindChild("TradeSkillCheckbox"):SetCheck(self.tUserSettings.tFilters.bHarvestable)
	
		if self.locSavedWindowLoc then
			self.wndMain:MoveToLocation(self.locSavedWindowLoc)
		end
	end
end

-- Shows the Neighbor Notes Window (or hides it if it is already open)
function NeighborNotes:OpenNN(bShow)
	if not self.wndMain and bShow ~= false then
		self:Initialize()
	elseif self.wndMain:IsShown() and bShow ~= true then
		self.wndMain:Close()
		return
	end
	self.wndMain:Invoke()
	self.wndMain:ToFront()
	self:RefreshList()
end

------------------------------------------------------------------------------------------
-- External Event Handlers
------------------------------------------------------------------------------------------

-- Places units that are fed to the client into a table/queue named self.tQueuedUnits
function NeighborNotes:OnUnitCreated(unit)
	if HousingLib.IsHousingWorld() == false then
		return
	end
	if unit == null or not unit:IsValid() or unit == GameLib.GetPlayerUnit() then
		return
	end
	table.insert(self.tQueuedUnits, unit)
end

-- Refreshes the List Container that contains the neighbor data
function NeighborNotes:RefreshList()
	if not self.wndMain then
		return
	end
	if self.bVisitor == nil then
		local addVisitor = Apollo.GetAddon("Visitor")
		if addVisitor then
			self.bVisitor = true
		else
			self.bVisitor = false
			self.wndMain:FindChild("TheVisitorBtn"):Show(false)			
		end
	end
	
	local nPrevId = nil
	for key, wndOld in pairs(self.wndListContainer:GetChildren()) do
		if wndOld:FindChild("FriendBtn"):IsChecked() then
			nPrevId = wndOld:GetData().nId
		end
	end

	-- Clear the current list container
	self.wndListContainer:DestroyChildren()
	
	-- Updates the Neighbor Notes data with the current neighbor list
	local tNeighbors = HousingLib.GetNeighborList()
	if not tNeighbors then
		return
	end
	for nIndex, tNeighbor in ipairs(tNeighbors) do
		if tNeighbor.strCharacterName and not self.tNeighborNotes[tNeighbor.strCharacterName] then
			self.tNeighborNotes[tNeighbor.strCharacterName] = {}
			self.tNeighborNotes[tNeighbor.strCharacterName].tPlugs = {}
		end
	end
	tNeighbors = nil
	
	-- set up the neighbor lookup table
	--local tSortData = HousingLib.GetNeighborList() or {}
	local tSortData = {}

	for strName, tNeighbor in pairs(self.tNeighborNotes) do
		-- check to see if the neighbor is already in the Sort Table
		tNData = {}
		tNData.strNote = tNeighbor.strNote or  ""
		tNData.nNodeType = tNeighbor.nNodeType or 0
		tNData.nNodeID = tNeighbor.nNodeID or 0
		tNData.nNodeWeight = tNeighbor.nNodeWeight or 0
		tNData.nPlugWeight = tNeighbor.nPlugWeight or 0
		tNData.strCharacterName = strName
		local tTemp = NeighborNotes:GetNeighborByName(strName)
		if tTemp then
			tNData.fLastOnline = tTemp.fLastOnline or 1.0
			tNData.ePermissionNeighbor = tTemp.ePermissionNeighbor or HousingLib.NeighborPermissionLevel.Normal
			tNData.nId = tTemp.nId
		else
			tNData.fLastOnline = 1.0
			tNData.ePermissionNeighbor = 999
		end
		table.insert(tSortData, tNData)
	end
	
	-- Apply filters
	tSortData = NeighborNotes:GetFilteredTable(tSortData)
	
	-- Do our sort	
	if self.fnSort then
		table.sort(tSortData, self.fnSort)
	end

	-- Populate the List Container
	for key, tCurrNeighbor in pairs(tSortData) do
		local wndListItem = Apollo.LoadForm(self.xmlDoc, "NeighborListItem", self.wndListContainer, self)
		wndListItem:SetData(tCurrNeighbor) -- set the full table since we have no direct lookup for neighbors
		local strColorToUse = kcrOffline
		if tCurrNeighbor.fLastOnline == 0 then -- online / check for strWorldZone
			strColorToUse = kcrOnline
		end

		local tName = wndListItem:FindChild("Name")
		tName:SetText(tCurrNeighbor.strCharacterName)
		tName:SetTextColor(strColorToUse)
		local tNoteData = self.tNeighborNotes[tCurrNeighbor.strCharacterName]
		if tNoteData ~= nil then
			if tNoteData.strNote ~= nil then
				local wndNote = wndListItem:FindChild("Notes")
				wndNote:SetText(tNoteData.strNote)
				wndNote:SetTextColor(strColorToUse)
			end
			if tNoteData.nNodeType ~= nil then
				local wndNode = wndListItem:FindChild("Node")
				if tNoteData.nNodeType == ktNodeType["Relic"] then
					wndNode:SetSprite(ktRelicNodeIcon[tNoteData.nNodeID])
					wndNode:SetTooltip(ktRelicNodeName[tNoteData.nNodeID])
				elseif tNoteData.nNodeType == ktNodeType["Survival"] then
					wndNode:SetSprite(ktSurvivalNodeIcon[tNoteData.nNodeID])
					wndNode:SetTooltip(ktSurvivalNodeName[tNoteData.nNodeID])			
				elseif tNoteData.nNodeType == ktNodeType["Mining"] then
					wndNode:SetSprite(ktMiningNodeIcon[tNoteData.nNodeID])
					wndNode:SetTooltip(ktMiningNodeName[tNoteData.nNodeID])			
				end
			end
			if tNoteData.tPlugs ~= nil then
				for nIndex, nPlugID in pairs(tNoteData.tPlugs) do
					if nPlugID ~= nil and nPlugID ~= 0 then
						local wndPlug = wndListItem:FindChild("Plug" .. nIndex)
						if ktPlugIcon[nPlugID] == nil then
							if nPlugID < 101 then
								wndPlug:SetSprite("IconSprites:Icon_CraftingUI_Item_Crafting_PowerCore_Blue")
							elseif nPlugID > 100 and nPlugID < 201 then
								wndPlug:SetSprite(ktGenericPlugIcon["Biome"])
							elseif nPlugID > 200 and nPlugID < 401 then
								wndPlug:SetSprite(ktGenericPlugIcon["Challenge"])
							elseif nPlugID > 400 and nPlugID < 601 then
								wndPlug:SetSprite(ktGenericPlugIcon["Expedition"])
							elseif nPlugID > 600 and nPlugID < 801 then
								wndPlug:SetSprite(ktGenericPlugIcon["Raid"])
							elseif nPlugID > 800 and nPlugID < 1001 then
								wndPlug:SetSprite(ktGenericPlugIcon["PublicEvent"])
							end
						else
							wndPlug:SetSprite(ktPlugIcon[nPlugID])
						end
						wndPlug:SetTooltip(ktPlugName[nPlugID])
					end
				end
			end
		end
		
		if nPrevId ~= nil then
			wndListItem:FindChild("FriendBtn"):SetCheck(tCurrNeighbor.nId == nPrevId)
		end

		wndListItem:FindChild("RoommateIcon"):Show(tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Roommate)
		if tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Roommate then
			wndListItem:FindChild("RoommateIcon"):SetTooltip(Apollo.GetString("Neighbors_RoommateTooltip"))
		end

		wndListItem:FindChild("AccountIcon"):Show(tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Account)
		if tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Account then
			wndListItem:FindChild("AccountIcon"):SetTooltip(Apollo.GetString("Neighbors_RoommateTooltip"))
		end

		wndListItem:FindChild("NotNeighborIcon"):Show(tCurrNeighbor.ePermissionNeighbor == 999)
		if tCurrNeighbor.ePermissionNeighbor == 999 then
			wndListItem:FindChild("NotNeighborIcon"):SetTooltip("This is a neighbor of another character")
		end
		
		wndListItem:FindChild("Name"):SetTextColor(strColorToUse)

	end

	-- set scroll
	self.wndListContainer:ArrangeChildrenVert()
	self:UpdateControls()
end

-- Updates self.strCurrentZone and self.bNeighborZone with current zone info
function NeighborNotes:OnChangeZoneName(oVar, strNewZone)
	self.strCurrentZone = strNewZone
	self.bNeighborZone = NeighborNotes:IsNeighborZone()
	self.timerZoneLoad:Start()
end

function NeighborNotes:OnSocialWindowToggle()
	if self.tUserSettings.bOpenWithSocial then
		local wndSocial = Apollo.FindWindowByName("SocialPanelForm")
		if wndSocial and wndSocial:IsShown() then
			local locLocation = wndSocial:GetLocation()
			if wndSocial:FindChild("SplashNeighborsBtn"):IsChecked() then
				self:OpenNN(true)
			end
		end
	end
end

function NeighborNotes:OnSocialWindowClose()
	if self.tUserSettings.bCloseWithSocial then
		if self.wndMain and self.wndMain:IsShown() then
			self.wndMain:Close()
		end
	end
end

-- Registers Neighbor Notes with the Interface Menu
function NeighborNotes:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Neighbor Notes", { "ToggleAddon_NN", "", "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_SupportTicket"})
end

function NeighborNotes:OnTutorial_RequestUIAnchor(eAnchor, idTutorial, strPopupText)
	if not self.wndMain or not self.wndMain:IsValid() then
		return 
	end

	local tRect = {}
	tRect.l, tRect.t, tRect.r, tRect.b = self.wndMain:GetRect()
	
	Event_FireGenericEvent("Tutorial_RequestUIAnchorResponse", eAnchor, idTutorial, strPopupText, tRect)
end

----------------------------------------------------------------------------------------------
-- Timer Handler Functions
-----------------------------------------------------------------------------------------------

-- When this timer runs, it processes the items in the self.tQueuedUnits table/queue
function NeighborNotes:ZoneLoadTimer()
	-- stop the timer
	self.timerZoneLoad:Stop()
	-- see if this zone should be scanned
	if HousingLib.IsHousingWorld() == false then
		self.tQueuedUnits = {}
		return
	end

	if self.bNeighborZone == false then
		self.tQueuedUnits = {}
		return
	end
	
	if #self.tQueuedUnits == 0 then
		Print("No units found in this Neighborhood")
		return
	end
	
	self.unitPlayerDisposition = GameLib.GetPlayerUnit()
	if self.unitPlayerDisposition == nill or not self.unitPlayerDisposition:IsValid() then
		self.tQueuedUnits = {}
		return
	end

	self.tActivePlayerSkills = NeighborNotes:GetActiveTradeskills()
		
	local tHarvestNodes = {}
	local tUnitNodes = {}
	local nHarvestCount = 0
	local nUnitCount = 0
	for nIndex, udUnit in pairs(self.tQueuedUnits) do
		if udUnit:GetType() == "Harvest" then
			nHarvestCount = nHarvestCount + 1
			tHarvestNodes[udUnit:GetName()] = 1
		else
			local strName = udUnit:GetName()
			if strName ~= nil and strName ~= "" then
				--Print(strName) -- Use to get a list of the unit names
				tUnitNodes[strName] = 1
				nUnitCount = nUnitCount + 1
			end
		end	
	end
	
	self.tQueuedUnits = {}
	if nHarvestCount > 0 then
		NeighborNotes:UpdateNode(tHarvestNodes)
	end
	if nUnitCount > 0 then
		NeighborNotes:UpdatePlugs(tUnitNodes)
	end
	Print("Neighbor Notes: Finished Gathering info on " .. self.strNeighborName)
	NeighborNotes:RefreshList()
end

-----------------------------------------------------------------------------------------------
-- NeighborListItem Controls (an individual row in the neighbor list)
-----------------------------------------------------------------------------------------------

-- this is called when the friend button is pressed
function NeighborNotes:OnFriendBtn(wndHandler, wndControl, eMouseButton)
	local tCurrNeighbor = wndControl:GetParent():GetData()

	if tCurrNeighbor == nil then
		return false
	end

	for key, wndPlayerEntry in pairs(self.wndListContainer:GetChildren()) do
		wndPlayerEntry:FindChild("FriendBtn"):SetCheck(wndPlayerEntry:GetData() == tCurrNeighbor)
	end

	self:UpdateControls()
end

-- this fires when a friend is unselected
function NeighborNotes:OnFriendBtnUncheck(wndHandler, wndControl, eMouseButton)
	local tCurrNeighbor = wndControl:GetParent():GetData()

	if tCurrNeighbor == nil then
		return false
	end

	self:UpdateControls()
end

function NeighborNotes:OnContextMenuOnlyBtn(wndHandler, wndControl)
	local tCurrNeighbor = wndControl:GetParent():GetData()
	Event_FireGenericEvent("GenericEvent_NewContextMenuPlayer", self.wndMain, tCurrNeighbor.strCharacterName)
end


-----------------------------------------------------------------------------------------------
-- NeighborListForm Controls (the whole neighbor list)
-----------------------------------------------------------------------------------------------

-- When one of the table headers is clicked, this sets up the sort and calls RefreshList()
function NeighborNotes:OnNeighborSortToggle( wndHandler, wndControl, eMouseButton )
	
	-- If the string is blank, assign it "zzzzz" so that it sorts under non-blank strings 
	function NeighborNotes.SWeight(strNote)
		if strNote == "" then
			return "zzzzz"
		end
		return strNote
	end
	
	-- if the number is nil, assign it 0 so that it doesn't break the sort
	function NeighborNotes.NWeight(nNumber)
		if nNumber == nil then
			return 0
		end
		return nNumber
	end
	
	local bChecked = wndHandler:IsChecked()
	local strLastChecked = wndHandler:GetName()
	self.fnSort = nil
	
	if strLastChecked == "Label_Friend" then
		if bChecked then
			self.fnSort = function(a,b) return (a.strCharacterName > b.strCharacterName) end
		else
			self.fnSort = function(a,b) return (a.strCharacterName < b.strCharacterName) end
		end
	elseif strLastChecked == "Label_Roommate" then
		if bChecked then
			self.fnSort = function(a,b) return (a.ePermissionNeighbor > b.ePermissionNeighbor) end
		else
			self.fnSort = function(a,b) return (a.ePermissionNeighbor < b.ePermissionNeighbor) end
		end
	elseif strLastChecked == "Label_Node" then
		if bChecked then
			self.fnSort = function(a,b) return (NeighborNotes.NWeight(a.nNodeWeight) > NeighborNotes.NWeight(b.nNodeWeight)) end
		else
			self.fnSort = function(a,b) return (NeighborNotes.NWeight(a.nNodeWeight) < NeighborNotes.NWeight(b.nNodeWeight)) end
		end
	elseif strLastChecked == "Label_Plugs" then
		if bChecked then
			self.fnSort = function(a,b) return (a.nPlugWeight > b.nPlugWeight) end
		else
			self.fnSort = function(a,b) return (a.nPlugWeight < b.nPlugWeight) end
		end
	elseif strLastChecked == "Label_Notes" then
		if bChecked then
			self.fnSort = function(a,b) return (a.strNote > b.strNote) end
		else
			self.fnSort = function(a,b) return (NeighborNotes.SWeight(a.strNote) < NeighborNotes.SWeight(b.strNote)) end
		end
	end
	
	self:RefreshList()
end

-- When a tab is right clicked, show the associated context window
function NeighborNotes:OnTabClick(wndHandler, wndControl, eMouseButton)
	if eMouseButton == GameLib.CodeEnumInputMouse.Right then
		local wndFilterWindow = wndControl:FindChild("FilterWindow")
		if wndFilterWindow then
			wndFilterWindow:SetFocus()
			wndFilterWindow:Show(true)
			return
		end
	end
end


-- This is called to update the controls at the bottom of the window, changing the appearance of the buttons
--	depending on the current location or selected user
function NeighborNotes:UpdateControls()
	if not self.wndMain or not self.wndMain:IsValid() then
		return
	end

	local wndControls = self.wndMain:FindChild("Controls")
	local tCurr = nil

	for key, wndListItem in pairs(self.wndListContainer:GetChildren()) do
		if wndListItem:FindChild("FriendBtn"):IsChecked() then
			tCurr = wndListItem:GetData()
		end
	end

	local wndHomeBtn = wndControls:FindChild("TeleportHomeBtn")
	local wndEditNoteBtn = wndControls:FindChild("EditNoteBtn")
	local wndVisitBtn = wndControls:FindChild("VisitBtn")
	local wndAddBtn = wndControls:FindChild("AddBtn")
	
	wndAddBtn:SetData(nil)
	
	-- must be on my skymap to visit; must be on someone else's to return (add button)
	wndHomeBtn:Enable(HousingLib.IsHousingWorld())
	wndControls:FindChild("HomeDisabledBlocker"):Show(not HousingLib.IsHousingWorld())
	wndControls:FindChild("VisitDisabledBlocker"):Show(not HousingLib.IsHousingWorld())
	if HousingLib.IsHousingWorld() == false then
		wndHomeBtn:FindChild("TeleportHomeIcon"):SetBGColor(ApolloColor.new(1, 0, 0, .5))
	else
		wndHomeBtn:FindChild("TeleportHomeIcon"):SetBGColor(ApolloColor.new(1, 1, 1, 1))
	end

	if not tCurr then
		wndVisitBtn:Enable(false)
		wndEditNoteBtn:Enable(false)
		return
	end
	
	wndEditNoteBtn:SetData(tCurr)
	wndEditNoteBtn:Enable(true)
	
	if not tCurr.nId then
		wndAddBtn:SetData(tCurr)
		wndVisitBtn:Enable(false)
		return
	end
	
	wndVisitBtn:Enable(HousingLib.IsHousingWorld())
	wndVisitBtn:SetData(tCurr)
end

-- AddNeighbor Sub-Window Functions
function NeighborNotes:OnAddBtn(wndHandler, wndControl)
	local wndAdd = wndControl:FindChild("AddWindow")
	local wndEditBox = wndAdd:FindChild("AddMemberEditBox")
	local tCurr = wndControl:GetData()
	wndEditBox:SetText("")
	if tCurr and not tCurr.nId then
		wndEditBox:SetText(tCurr.strCharacterName or "")
	end
	wndAdd:FindChild("AddMemberEditBox"):SetFocus()
	wndAdd:Show(true)
end

function NeighborNotes:OnAddMemberYesClick( wndHandler, wndControl )
	local wndParent = wndControl:GetParent()
	local strName = wndParent:FindChild("AddMemberEditBox"):GetText()

	if strName ~= nil and strName ~= "" then
		HousingLib.NeighborInviteByName(strName)
	end
	wndControl:GetParent():Show(false)
end

-- Visit Button Function
function NeighborNotes:OnVisitConfirmBtn(wndHandler, wndControl)
	if self.tUserSettings.bOnVisitSelectNext == true then
		local bFound = false
		for key, wndTemp in pairs(self.wndListContainer:GetChildren()) do
			if bFound == false then
				if wndTemp:FindChild("FriendBtn"):IsChecked() then
					bFound = true
					wndTemp:FindChild("FriendBtn"):SetCheck(false)
				end
			else
				wndTemp:FindChild("FriendBtn"):SetCheck(true)
				break
			end
		end	
	end	
	local tCurr = wndControl:GetData()
	if tCurr ~= nil then
		Apollo.StopTimer("NNLoadDelay")
		HousingLib.VisitNeighborResidence(tCurr.nId)
	end
end

-- Home Button Function
function NeighborNotes:OnTeleportHomeBtn(wndHandler, wndControl)
	Apollo.StopTimer("NNLoadDelay")
	HousingLib.RequestTakeMeHome()
	Event_FireGenericEvent("ToggleSocialWindow") -- Here to prevent change instance not reloading panel
end


function NeighborNotes:OnCloseBtn( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end

function NeighborNotes:OnEditNoteBtn( wndHandler, wndControl, eMouseButton )
	local wndEdit = wndControl:FindChild("EditNoteWindow")
	local wndEditBox = wndEdit:FindChild("NoteEditBox")
	local tCurr = wndControl:GetData()
	if tCurr == nil then
		return
	end
	if tCurr.strCharacterName == nil or tCurr.strCharacterName == "" then
		return
	end
	local strNote = self:GetCharacterNote(tCurr.strCharacterName)
	wndEditBox:SetText(strNote)
	wndEditBox:SetFocus()
	wndEdit:Show(true)
end


function NeighborNotes:OnSubCloseBtn(wndHandler, wndControl, mouseBtn)
	wndControl:GetParent():Show(false)
end


function NeighborNotes:OnNoteSubmitClick( wndHandler, wndControl)
	local wndParent = wndControl:GetParent()
	local strNote = wndParent:FindChild("NoteEditBox"):GetText()
	local tCurrNeighbor = wndParent:GetParent():GetData()
	self:SetCharacterNote(tCurrNeighbor.strCharacterName, strNote)
	self:RefreshList()
	wndParent:Show(false)
end


function NeighborNotes:OnTradeSkillCheckBox( wndHandler, wndControl, eMouseButton )
	self.tUserSettings.tFilters.bHarvestable = wndControl:IsChecked()
	wndControl:GetParent():Show(false)
	NeighborNotes:RefreshList()
end

function NeighborNotes:OnAccountWideCheckBox( wndHandler, wndControl, eMouseButton )
	self.tUserSettings.tFilters.bShowAllCharacters = wndControl:IsChecked()
	wndControl:GetParent():Show(false)
	NeighborNotes:RefreshList()
end

-- Opens the Node Filter Window
function NeighborNotes:OnNodeTabClick( wndHandler, wndControl, eMouseButton)
	local wndNodeFilter = wndControl:FindChild("NodeFilterWindow")
	if wndNodeFilter ~= nil then
		if eMouseButton == GameLib.CodeEnumInputMouse.Right then
			wndNodeFilter:SetFocus()
			wndNodeFilter:Show(true)
		end
	end
end


function NeighborNotes:OnSubWindowClosed( wndHandler, wndControl )
	wndControl:GetParent():SetCheck(false)
end

function NeighborNotes:OnConfigBtn( wndHandler, wndControl, eMouseButton )
	if self.wndConfig and self.wndConfig:IsShown() then
		self.wndConfig:Close()
		return
	elseif not self.wndConfig or not self.wndConfig:IsValid() then
		self.wndConfig = Apollo.LoadForm(self.xmlDoc, "ConfigWindow", nil, self)
	end
	local wndContent = self.wndConfig:FindChild("ContentMain")
	wndContent:FindChild("CheckboxOpenWithSocial"):SetCheck(self.tUserSettings.bOpenWithSocial)
	wndContent:FindChild("CheckboxCloseWithSocial"):SetCheck(self.tUserSettings.bCloseWithSocial)
	wndContent:FindChild("CheckboxShowAllNeighbors"):SetCheck(self.tUserSettings.tFilters.bShowAllCharacters)
	wndContent:FindChild("CheckboxShowHarvestable"):SetCheck(self.tUserSettings.tFilters.bHarvestable)
	wndContent:FindChild("CheckboxVisitNext"):SetCheck(self.tUserSettings.bOnVisitSelectNext)
	self.wndConfig:Show(true)
	self.wndConfig:ToFront()
end

function NeighborNotes:OnVisitRandomBtn( wndHandler, wndControl, eMouseButton )
	Event_FireGenericEvent("HousingRandomResidenceListReceived", self.wndMain, nil)
end

function NeighborNotes:OnTheVisitorBtn( wndHandler, wndControl, eMouseButton )
	Apollo.ParseInput("/visit")	
end

---------------------------------------------------------------------------------------------------
-- tNeighborNotes datatable access functions
---------------------------------------------------------------------------------------------------

-- Returns the text note based on the character name
function NeighborNotes:GetCharacterNote(strCharacterName)
	if strCharacterName == nil then
		return ""
	end
	if self.tNeighborNotes == nil then
		Print("Can't access the Neighbor Notes data table")
		Apollo.AddAddonErrorText("Can't access the neighbornotes table")
	end	
	if self.tNeighborNotes[strCharacterName] ~= nil and self.tNeighborNotes[strCharacterName].strNote ~= nil then
		return self.tNeighborNotes[strCharacterName].strNote
	end
	return ""
end

-- Sets the text note for the specified character
function NeighborNotes:SetCharacterNote(strCharacterName, strNote)
	if self.tNeighborNotes[strCharacterName] == nil then
		self.tNeighborNotes[strCharacterName] = {}
	end
	self.tNeighborNotes[strCharacterName].strNote = strNote
end

-- Updates the node of the current Neighbor node
function NeighborNotes:UpdateNode(tUnitNames)
	local nBest = 0
	local nType = 0
	for strName, nNum in pairs(tUnitNames) do
		-- see which type it is
		local nRelic = ktRelicNodeWeight[strName]
		local nSurvival = ktSurvivalNodeWeight[strName]
		local nMining = ktMiningNodeWeight[strName]
		local strTemp = ""
		if nRelic ~= nil then 
			strTemp = nRelic
		end
		if nSurvival ~= nil then
			strTemp = strTemp .. " " .. nSurvival
		end
		if nMining ~= nil then
			strTemp = strTemp .. " " .. nMining
		end
		if nRelic ~= nil then
			if nBest < nRelic then
				nType = ktNodeType["Relic"]
				nBest = nRelic
			end
		elseif nSurvival ~= nil then
			if nBest < nSurvival then
				nType = ktNodeType["Survival"]
				nBest = nSurvival
			end
		elseif nMining ~= nil then
			if nBest < nMining then
				nType = ktNodeType["Mining"]
				nBest = nMining
			end
		end
	end
	if nBest ~= 0 and nBest ~= nil then
		if self.tNeighborNotes[self.strNeighborName] == nil then
			self.tNeighborNotes[self.strNeighborName] = {}
		end
		if self.tNeighborNotes[self.strNeighborName].nNodeType ~= nil and self.tNeighborNotes[self.strNeighborName].nNodeType == nType then
			if self.tNeighborNotes[self.strNeighborName].nNodeID >= nBest then
				return
			end
		end
		self.tNeighborNotes[self.strNeighborName].nNodeType = nType;
		self.tNeighborNotes[self.strNeighborName].nNodeID = nBest;
		-- Calculate node weight
		self.tNeighborNotes[self.strNeighborName].nNodeWeight = nType * 10 + nBest
	end
end

-- Replaces the existing Plugs with the list provided in tUnitNames
function NeighborNotes:UpdatePlugs(tUnitNames)
	local tNewPlugs = {}
	-- Build a current list of plugs
	for strUnitName, nNum in pairs(tUnitNames) do
		if strUnitName ~= nil and strUnitName ~= "" then
			local nPlugID = ktPlugUnitLookup[strUnitName]
			if nPlugID ~= nil then
				tNewPlugs[nPlugID] = 1
			end
		end
	end

	-- Build an ordered table
	local nCount = 0
	local tOrdered = {}
	for nPlugID, nJunk in pairs(tNewPlugs) do
		nCount = nCount + 1
		tOrdered[nCount] = nPlugID
	end

	if nCount > 0 then
		if self.tNeighborNotes[self.strNeighborName] == nil then
			self.tNeighborNotes[self.strNeighborName] = {}
		end
		self.tNeighborNotes[self.strNeighborName].tPlugs = tOrdered
		self.tNeighborNotes[self.strNeighborName].nPlugWeight = nCount
	else
		self.tNeighborNotes[self.strNeighborName].tPlugs = {}
		self.tNeighborNotes[self.strNeighborName].nPlugWeight = 0
	end
end

-- Determines if this zone is the zone of a neighbor
function NeighborNotes:IsNeighborZone()
	self.bNeighborZone = false
	self.strNeighborName = ""
	local nFirst = self.strCurrentZone:find('%[', 1)
	local nLast = self.strCurrentZone:find('%]', 1)
	if nFirst ~= nil and nLast ~= nil then
		local strNeighborName = self.strCurrentZone:sub(nFirst + 1, nLast -1)
		if(strNeighborName ~= "") then
			local tNeighborList = HousingLib.GetNeighborList()
			local isNeighbor = false
			for key, tCurrNeighbor in pairs(tNeighborList) do
				if tCurrNeighbor.strCharacterName == strNeighborName then
					self.bNeighborZone = true
					self.strNeighborName = strNeighborName
					break
				end
			end
		end
	end
	return self.bNeighborZone
end

-- Returns the neighbor info for strName from HousingLib.GetNeighborList()
function NeighborNotes:GetNeighborByName(strName)
	if strName ~= nil and strName ~= "" then
		tNeighborList = HousingLib.GetNeighborList()
		for nIndex, tNeighbor in ipairs(tNeighborList) do
			if tNeighbor.strCharacterName == strName then
				return tNeighbor
			end
		end	
	end
	-- no neighbor found
	return nil
end

-- Applies filters from self.tUserSettings.tFilters to the table tNeighborList
function NeighborNotes:GetFilteredTable(tNeighborList)
	local tRemoveList = {}
	local strCharName = GameLib.GetPlayerUnit():GetName()
	local tActiveSkills = NeighborNotes:GetActiveTradeskills()

	tRemoveList[strCharName] = true
	
	for nIndex, tNeighbor in ipairs(tNeighborList) do
		if self.tUserSettings.tFilters.bShowAllCharacters == false then
			if not NeighborNotes:GetNeighborByName(tNeighbor.strCharacterName) then
				tRemoveList[tNeighbor.strCharacterName] = true
			end
		end
		if self.tUserSettings.tFilters.bHarvestable == true then
			if tNeighbor.nNodeType == ktNodeType["Relic"] and tActiveSkills["Relic"] then
				-- do nothing
			elseif tNeighbor.nNodeType == ktNodeType["Survival"] and tActiveSkills["Survival"] then
				-- do nothing
			elseif tNeighbor.nNodeType == ktNodeType["Mining"] and tActiveSkills["Mining"] then
				-- do nothing
			else
				tRemoveList[tNeighbor.strCharacterName] = true
			end
		end
	end
	
	-- Build the return list
	local tReturnList = {}
	for nIndex, tNeighbor in ipairs(tNeighborList) do
		if not tRemoveList[tNeighbor.strCharacterName] then
			table.insert(tReturnList, tNeighbor)
		end
	end
	return tReturnList
end

-- returns a table with tradeskill names as the index.  Inactive skills are excluded
function NeighborNotes:GetActiveTradeskills()
	local tReturnList = {}
	local tKnownSkills = CraftingLib.GetKnownTradeskills()
	if tKnownSkills then
		for nIndex, tSkill in ipairs(tKnownSkills) do
			local tInfo = CraftingLib.GetTradeskillInfo(tSkill.eId)
			if tInfo and tInfo.bIsActive then
				if tSkill.strName == "Relic_Hunter" then
					tReturnList["Relic"] = true
				elseif tSkill.strName == "Survivalist" then
					tReturnList["Survival"] = true
				elseif tSkill.strName == "Mining" then
					tReturnList["Mining"] = true
				end
			end
		end
	end
	return tReturnList
end

---------------------------------------------------------------------------------------------------
-- ConfigWindow Functions
---------------------------------------------------------------------------------------------------

function NeighborNotes:OnConfigOK( wndHandler, wndControl, eMouseButton)
	local wndContent = wndControl:GetParent():FindChild("ContentMain")
	self.tUserSettings.bOpenWithSocial = wndContent:FindChild("CheckboxOpenWithSocial"):IsChecked()
	self.tUserSettings.bCloseWithSocial = wndContent:FindChild("CheckboxCloseWithSocial"):IsChecked()
	self.tUserSettings.tFilters.bShowAllCharacters = wndContent:FindChild("CheckboxShowAllNeighbors"):IsChecked()
	self.tUserSettings.tFilters.bHarvestable = wndContent:FindChild("CheckboxShowHarvestable"):IsChecked()
	self.tUserSettings.bOnVisitSelectNext = wndContent:FindChild("CheckboxVisitNext"):IsChecked()
	self.wndConfig:Close()
	NeighborNotes:RefreshList()
end

function NeighborNotes:OnConfigCancel( wndHandler, wndControl, eMouseButton )
	self.wndConfig:Close()
end

-- Initialize the Addon
local NeighborNotesInst = NeighborNotes:new()
NeighborNotes:Init()


