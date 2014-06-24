-----------------------------------------------------------------------------------------------
-- Client Lua Script for NeighborNotes
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Unit"
require "FriendshipLib"
require "string"
require "HousingLib"

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
	[202] = "CHALLENGE: Bone Pit",
	[203] = "CHALLENGE: Cubig Feeder", --
	[204] = "CHALLENGE: Flying Saucer", --
	[205] = "CHALLENGE: Medical Station", --
	[206] = "CHALLENGE: Weather Control Station",
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
	
	-- 1x1 Expeditions
	[401] = "EXPEDITION: Abandoned Eldan Test Lab", -- Conflicts with Abandoned Test Lab
	[402] = "EXPEDITION: Creepy Cave",
	[403] = "EXPEDITION: Kel Voreth Underforge", -- Conflicts with Abandoned Eldan Test Lab
	[404] = "EXPEDITION: Mayday", --
	
	-- 1x2 Expeditions
	[501] = "",
	
	-- 1x1 Raids
	[601] = "RAID: Datascape Raid Portal", 
	
	-- 1x2 Raids
	[701] = "",
	
	-- 1x1 Public Event
	[801] = "",
	
	-- 1x2 Public Event
	[901] = "PUBLIC EVENT: Blasted Landscape", --
}

local ktPlugUnitLookup = 
{
	-- Useful stuff
	["Food Table"] = 1,
	["Snack-O-Matic 3000"] = 3,	
	["Crafting Station"] = 4,

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
	["Cubig Feeder"] = 203,
	["Ikthian Flying Saucer"] = 204,
	["Critically Wounded Patient"] = 205,
	["Seriously Wounded Patient"] = 205,
	["Lightly Wounded Patient"] = 205,
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

	-- Expeditions
	["Instance Portal"] = 401,
	["Transport Ship"] = 404,
	
	["Exile Beacon"] = 901,
}

local ktGenericPlugIcon =
{
	["Biome"] = "IconSprites:Icon_Achievement_Achievement_Zone",
	["Challenge"] = "IconSprites:Icon_Achievement_Achievement_Challenges",
	["Expedition"] = "IconSprites:Icon_Achievement_Achievement_Shiphand",
	["Dungeon"] = "IconSprites:Icon_Achievement_Achievement_Dungeon",
	["Raid"] = "IconSprites:Icon_Achievement_Achievement_Raid",
	["PublicEvent"] = "IconSprites:Icon_Achievement_Achievement_WorldEvent",
}

local ktPlugIcon =
{
	[1] = "IconSprites:Icon_ItemMisc_Meat_pie",
	[3] = "IconSprites:Icon_MapNode_Map_vendor_Consumable",
	[4] = "IconSprites:Icon_ItemMisc_Generic_toolbox",
}

local ktDefaultSettings = {
	AutoInviteFriends = false,
	AutoInviteGuild = false,
	BlackList = {},
}

local ktDefaultNeighborInfo = {
	strNote = "Default",
	nNodeType = 0,
	nNodeID = 0,	
	tPlugs = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
	}
}

local knSettingsVersion = 1
local knNeighborListVersion = 1

local kcrOnline = ApolloColor.new("UI_TextHoloBodyHighlight")
local kcrOffline = ApolloColor.new("UI_BtnTextGrayNormal")
local kcrNeutral = ApolloColor.new("gray")

-----------------------------------------------------------------------------------------------
-- Generic Addon Functions
-----------------------------------------------------------------------------------------------
function NeighborNotes:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function NeighborNotes:Init()
    Apollo.RegisterAddon(self, false, "", { "SocialPanel" })
end

function NeighborNotes:OnLoad()
	self.tNeighborNotes = {}
	self.tActiveNodeList = {}
	self.tQueuedUnits = {}
	self.tActiveNodeList = {}

	self.tUserSettings = ktDefaultSettings
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

function NeighborNotes:OnDocumentLoaded()
	if self.xmlDoc ~= nil then
		self.wndMain = Apollo.LoadForm(self.xmlDoc, "NeighborListForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the NeighborNotes window.")
			return
		end
		self.wndMain:Show(false)

		self.wndListContainer = self.wndMain:FindChild("ListContainer")
		
		self.wndMain:FindChild("AddMemberCloseBtn"):SetData(self.wndMain:FindChild("AddWindow"))
		self.wndMain:FindChild("EditNoteCloseBtn"):SetData(self.wndMain:FindChild("EditNoteWindow"))
		
		-- Register Timers
		self.timerZoneLoad = ApolloTimer.Create(4, false, "ZoneLoadTimer", self)
		
		-- Register event handlers
		Apollo.RegisterEventHandler("HousingNeighborUpdate",		"RefreshList", self)
		Apollo.RegisterEventHandler("HousingNeighborsLoaded", 		"RefreshList", self)
		Apollo.RegisterEventHandler("VarChange_ZoneName",			"OnChangeZoneName", self)
		Apollo.RegisterEventHandler("SubZoneChanged",				"OnChangeZoneName", self)
		Apollo.RegisterEventHandler("ToggleAddon_NN", 				"OpenNN", self)
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", 	"OnInterfaceMenuListHasLoaded", self)
		Apollo.RegisterEventHandler("WindowMove", 					"OnWindowMove", self)
				
		Apollo.RegisterSlashCommand("neighbornotes", 				"OpenNN", self)
		Apollo.RegisterSlashCommand("nn", 							"OpenNN", self)

		-- Position window
		if self.tUserSettings.tWindowLocation then
			if self.tUserSettings.tWindowLocation.nOffsets[3] ~= 0 and self.tUserSettings.tWindowLocation.nOffsets[4] ~= 0 then
				local locWindowLoc = WindowLocation.new(self.tUserSettings.tWindowLocation)
				self.wndMain:MoveToLocation(locWindowLoc)
			end
		end
		self.timerZoneLoad:Start()
	end	
end

function NeighborNotes:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Neighbor Notes", { "ToggleAddon_NN", "", "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_SupportTicket"})
end

function NeighborNotes:OnWindowMove()
	local locWindowLocation = self.wndMain and self.wndMain:GetLocation() or self.locSavedWindowLoc	
	self.tUserSettings.tWindowLocation = locWindowLocation and locWindowLocation:ToTable() or nil
end
	
function NeighborNotes:OnSave(eType)
	local tSave = {}
	if eType == GameLib.CodeEnumAddonSaveLevel.Realm then
		tSave = {
			nNeighborListVersion = knNeighborListVersion,
			tNeighborNotes = self.tNeighborNotes,
		}
	end
	
	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		-- save the window location
		local locWindowLocation = self.wndMain and self.wndMain:GetLocation() or self.locSavedWindowLoc	
		self.tUserSettings.tWindowLocation = locWindowLocation and locWindowLocation:ToTable() or nil
		
		tSave = {
			nSettingsVersion = knSettingsVersion,
			tUserSettings = self.tUserSettings,
		}
	end
	
	return tSave
end

function NeighborNotes:OnRestore(eType, tLoad)
	if not tLoad then
		return
	end
	if eType == GameLib.CodeEnumAddonSaveLevel.Realm then
		if knNeighborListVersion == tLoad.nNeighborListVersion then
			self.tNeighborNotes = tLoad.tNeighborNotes
		end
	elseif eType == GameLib.CodeEnumAddonSaveLevel.Character then
		if knSettingsVersion == tLoad.nSettingsVersion then
			self.tUserSettings = tLoad.tUserSettings
		else
			self.tUserSettings = ktDefaultSettings
		end
		-- Load the window location
		if self.tUserSettings.tWindowLocation then
			if self.wndMain then
				local locWindowLoc = WindowLocation.new(self.tUserSettings.tWindowLocation)
				self.wndMain:MoveToLocation(locWindowLoc)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------
-- Timer Handler Functions
-----------------------------------------------------------------------------------------------
function NeighborNotes:ZoneLoadTimer()
	-- stop the timer
	self.timerZoneLoad:Stop()
	
	-- see if this zone should be scanned
	if HousingLib.IsHousingWorld() == false then
		self.tQueuedUnits = {}
		return
	end
	local next = next
	if next(self.tQueuedUnits) == nil then
		return
	end
	
	if self.bNeighborZone == false then
		return
	end
	
	
	self.unitPlayerDisposition = GameLib.GetPlayerUnit()
	if self.unitPlayerDisposition == nill or not self.unitPlayerDisposition:IsValid() then
		return
	end
	
	local tHarvestNodes = {}
	local tUnitNodes = {}
	local nHarvestCount = 0
	local nUnitCount = 0
	for id, udUnit in pairs(self.tQueuedUnits) do
		if udUnit:GetType() == "Harvest" then
			nHarvestCount = nHarvestCount +1
			tHarvestNodes[udUnit:GetName()] = 1
		else
			local strName = udUnit:GetName()
			if strName ~= nil and strName ~= "" then
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
	NeighborNotes.PostDebug("Neighbor Notes: Finished Gathering info on " .. self.strNeighborName)
end

-----------------------------------------------------------------------------------------------
-- Event Handler Functions
-----------------------------------------------------------------------------------------------
function NeighborNotes:OnChangeZoneName(oVar, strNewZone)
	self.strCurrentZone = strNewZone
	self.bNeighborZone = NeighborNotes:IsNeighborZone()
	self.timerZoneLoad:Start()
end

function NeighborNotes:OnUnitCreated(unit)
	if HousingLib.IsHousingWorld() == false then
		return
	end
	if unit == null or not unit:IsValid() or unit == GameLib.GetPlayerUnit() then
		return
	end
	self.tQueuedUnits[unit:GetId()] = unit
end

function NeighborNotes:RefreshList()
	local nPrevId = nil
	for key, wndOld in pairs(self.wndListContainer:GetChildren()) do
		if wndOld:FindChild("FriendBtn"):IsChecked() then
			nPrevId = wndOld:GetData().nId
		end
	end

	self.wndListContainer:DestroyChildren()
	
	local tNeighbors = HousingLib.GetNeighborList() or {}
	-- Add data to neighbor table for sorting
	for nIndex, tNeighbor in ipairs(tNeighbors) do
		tNeighbor.strNote = ""
		tNeighbor.nNodeWeight = 0
		tNeighbor.nPlugWeight = 0
		local tNoteData = self.tNeighborNotes[tNeighbor.strCharacterName]
		if tNoteData ~= nil then
			-- Note
			if tNoteData.strNote ~= nil then
				tNeighbor.strNote = tNoteData.strNote
			end
			-- Node
			if tNoteData.nNodeType ~= nil and tNoteData.nNodeID ~= nil then
				tNeighbor.nNodeWeight = tNoteData.nNodeType * 10 + tNoteData.nNodeID
			end
			-- Plugs
			if tNoteData.tPlugs ~= nil then
				local nCount = 0
				for nIndex, nPlugID in pairs(tNoteData.tPlugs) do
					nCount = nCount + 1
				end 
				tNeighbor.nPlugWeight = nCount
			end
		end
	end
		
	-- Do our sort	
	if self.fnSort then
		table.sort(tNeighbors, self.fnSort)
	end

	-- Populate the List Container
	for key, tCurrNeighbor in pairs(tNeighbors) do
		local wndListItem = Apollo.LoadForm(self.xmlDoc, "FriendForm", self.wndListContainer, self)
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

		wndListItem:FindChild("Name"):SetTextColor(strColorToUse)

	end

	-- set scroll
	self.wndListContainer:ArrangeChildrenVert()
	self:UpdateControls()
end

-----------------------------------------------------------------------------------------------
-- Slash Commands
-----------------------------------------------------------------------------------------------
function NeighborNotes:OpenNN()
	if self.wndMain:IsShown() then
		self.wndMain:Show(false)
	else
		self:RefreshList()
		self.wndMain:Show(true)
		self.wndMain:ToFront()
	end
end

-----------------------------------------------------------------------------------------------
-- FriendsList Functions
-----------------------------------------------------------------------------------------------
function NeighborNotes:OnNeighborSortToggle(wndHandler, wndControl)
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

	-- must be on my skymap to visit; must be on someone else's to return (add button)
	wndControls:FindChild("TeleportHomeBtn"):Enable(HousingLib.IsHousingWorld())
	wndControls:FindChild("HomeDisabledBlocker"):Show(not HousingLib.IsHousingWorld())
	wndControls:FindChild("VisitDisabledBlocker"):Show(not HousingLib.IsHousingWorld())
	if HousingLib.IsHousingWorld() == false then
		wndControls:FindChild("TeleportHomeBtn"):FindChild("TeleportHomeIcon"):SetBGColor(ApolloColor.new(1, 0, 0, .5))
	else
		wndControls:FindChild("TeleportHomeBtn"):FindChild("TeleportHomeIcon"):SetBGColor(ApolloColor.new(1, 1, 1, 1))
	end
	if not tCurr or not tCurr.nId then
		wndControls:FindChild("EditNoteBtn"):Enable(false)
		wndControls:FindChild("VisitBtn"):Enable(false)
		return
	end

	wndControls:FindChild("EditNoteBtn"):Enable(tCurr.ePermissionNeighbor ~= HousingLib.NeighborPermissionLevel.Account)
	wndControls:FindChild("VisitBtn"):Enable(HousingLib.IsHousingWorld())


	wndControls:FindChild("EditNoteBtn"):SetData(tCurr)
	wndControls:FindChild("VisitBtn"):SetData(tCurr)
end

-----------------------------------------------------------------------------------------------
-- FriendsListForm Button Functions
-----------------------------------------------------------------------------------------------
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

-- AddNeighbor Sub-Window Functions
function NeighborNotes:OnAddBtn(wndHandler, wndControl)
	local wndAdd = wndControl:FindChild("AddWindow")
	wndAdd:FindChild("AddMemberEditBox"):SetText("")
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
	local tCurrNeighbor = wndControl:GetData()

	if tCurrNeighbor ~= nil then
		Apollo.StopTimer("NNLoadDelay")
		HousingLib.VisitNeighborResidence(tCurrNeighbor.nId)

	end
	self.wndMain:Show(false)
end

-- Home Button Function
function NeighborNotes:OnTeleportHomeBtn(wndHandler, wndControl)
	Apollo.StopTimer("NNLoadDelay")
	HousingLib.RequestTakeMeHome()
	Event_FireGenericEvent("ToggleSocialWindow") -- Here to prevent change instance not reloading panel
end


---------------------------------------------------------------------------------------------------
-- NeighborListForm Functions
---------------------------------------------------------------------------------------------------
function NeighborNotes:OnCloseBtn( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end

local NeighborNotesInst = NeighborNotes:new()
NeighborNotes:Init()

function NeighborNotes:OnEditNoteBtn( wndHandler, wndControl, eMouseButton )
	local wndEdit = wndControl:FindChild("EditNoteWindow")
	local wndEditBox = wndEdit:FindChild("NoteEditBox")
	local tCurrNeighbor = wndControl:GetData()
	if tCurrNeighbor == nil then
		return
	end
	--NeighborNotes.PostDebug("Control = " .. wndControl:GetName())
	if tCurrNeighbor.strCharacterName == nil or tCurrNeighbor.strCharacterName == "" then
		return
	end
	--NeighborNotes.PostDebug("Name = " .. tCurrNeighbor.strCharacterName)
	local strNote = self:GetCharacterNote(tCurrNeighbor.strCharacterName)
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
	--NeighborNotes.PostDebug("Name = " .. tCurrNeighbor.strCharacterName)
	self:SetCharacterNote(tCurrNeighbor.strCharacterName, strNote)
	self:RefreshList()
	wndParent:Show(false)
end

function NeighborNotes:OnRosterAddMemberCloseBtn( wndHandler, wndControl )
end

---------------------------------------------------------------------------------------------------
-- General Functions
---------------------------------------------------------------------------------------------------

function NeighborNotes.PostDebug(strMessage)
	ChatSystemLib.PostOnChannel(3, strMessage)
end	

function NeighborNotes:GetCharacterNote(strCharacterName)
	--NeighborNotes.PostDebug("Name = " .. strCharacterName)
	if strCharacterName == nil then
		return ""
	end
	if self.tNeighborNotes == nil then
		Apollo.AddAddonErrorText("Can't access the neighbornotes table")
	end	
	if self.tNeighborNotes[strCharacterName] ~= nil and self.tNeighborNotes[strCharacterName].strNote ~= nil then
		return self.tNeighborNotes[strCharacterName].strNote
	end
	return ""
end

function NeighborNotes:SetCharacterNote(strCharacterName, strNote)
	if self.tNeighborNotes[strCharacterName] == nil then
		self.tNeighborNotes[strCharacterName] = {}
	end
	self.tNeighborNotes[strCharacterName].strNote = strNote
end

function NeighborNotes:GetNameFromZone(strZoneName)
	-- we need to find the block brackets
	local nFirst = strZoneName:find('%[', 1)
	if nFirst == nil then
		return ""
	end
	local nLast = strZoneName:find('%]', 1)
	return strZoneName:sub(nFirst + 1, nLast -1)
end

function NeighborNotes:IsNeighborZone()
	--NeighborNotes.PostDebug("Zone Name is " .. self.strCurrentZone)
	local strNeighborName = NeighborNotes:GetNameFromZone(self.strCurrentZone)
	if(strNeighborName == "") then
		self.bNeighborZone = false
		return false
	end
	--NeighborNotes.PostDebug("Neighbor Name is " .. strNeighborName)
	local tNeighborList = HousingLib.GetNeighborList()
	local isNeighbor = false
	for key, tCurrNeighbor in pairs(tNeighborList) do
		if tCurrNeighbor.strCharacterName == strNeighborName then
			isNeighbor = true
			self.strNeighborName = strNeighborName
			break
		end
	end
	return isNeighbor
end

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
		--NeighborNotes.PostDebug("Type=" .. nType .. " ID=" .. nBest)
		if self.tNeighborNotes[self.strNeighborName] == nil then
			self.tNeighborNotes[self.strNeighborName] = {}
		end
		self.tNeighborNotes[self.strNeighborName].nNodeType = nType;
		self.tNeighborNotes[self.strNeighborName].nNodeID = nBest;
	end
end

function NeighborNotes:UpdatePlugs(tUnitNames)
	local tNewPlugs = {}
	-- Build a current list of plugs
	for strUnitName, nNum in pairs(tUnitNames) do
		if strUnitName ~= nil and strUnitName ~= "" then
			local nPlugID = NeighborNotes:GetPlugID(strUnitName)
			if nPlugID ~= "" then
				--NeighborNotes.PostDebug("Found Plug: " .. nPlugID)
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
	else
		if self.tNeighborNotes[self.strNeighborName] ~= nil then
			self.tNeighborNotes[self.strNeighborName].tPlugs = nil
		end
	end
end

function NeighborNotes:GetPlugID(strUnitName)
	local nPlugID = ktPlugUnitLookup[strUnitName]
	if nPlugID == nil then
		return ""
	end
	return nPlugID
end
