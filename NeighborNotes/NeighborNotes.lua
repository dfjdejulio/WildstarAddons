-----------------------------------------------------------------------------------------------
-- Client Lua Script for NeighborNotes
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------

require "Window"
require "Unit"
require "string"
require "CraftingLib"
require "FriendshipLib"
require "GuildLib"
require "HousingLib"

-----------------------------------------------------------------------------------------------
-- NeighborNotes Module Definition
-----------------------------------------------------------------------------------------------
NeighborNotes = {}

NeighborNotes.tEnums = {}
NeighborNotes.tLocale = {}

NeighborNotes.tLiveData = {
	tProfessionNames = {},
	bShowSplash = true,
	strNeighborName = "",	
	tActivePlayerSkills = {},
	tQueuedUnits = {},
	tPlugs		= {},	-- tPlugs = { [nPlugID] = strNonLocalizedPlugName, }
	tPlugUnits	= {},	-- tUnits = { [strLocalizedUnitName] = nPlugID, }
	tNodes		= {},
	tNodeUnits	= {},	
	tGroups 	= {},	-- [GroupName] = { nType, tRoster = {} }
}

NeighborNotes.tDefaults = {
	tCharacterSettings = {
		bOpenWithSocial 	= true,
		bCloseWithSocial 	= true,
		bOnVisitSelectNext 	= true,
		tFilters = {
			bHarvestable 		= false,
			bShowAllCharacters 	= false,
		},
	},

	tNeighborInfo = {
		strNote 	= "",
		nNodeID 	= 0,
		tPlugs 		= {},
	},
}

NeighborNotes.tAccount 		= { nVersion = 13 }
NeighborNotes.tRealm 		= { nVersion = 3, tNeighborList = {} }
NeighborNotes.tCharacter = NeighborNotes.tDefaults.tCharacterSettings
NeighborNotes.tCharacter.nVersion = 3

NeighborNotes.tColors = {
	crOnline 	= ApolloColor.new("UI_TextHoloBodyHighlight"),
	crOffline 	= ApolloColor.new("UI_BtnTextGrayNormal"),
	crNeutral 	= ApolloColor.new("gray"),
}

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
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)

	-- Create the forms
	self.xmlDoc = XmlDoc.CreateFromFile("MainForm.xml")
	self.xmlConfig = XmlDoc.CreateFromFile("ConfigForm.xml")
	if self.xmlDoc == nil or self.xmlConfig == nil then
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
		Apollo.RegisterEventHandler("OnFriendshipUpdate",			"RefreshList", self)
		Apollo.RegisterEventHandler("OnFriendshipUpdateOnline",		"RefreshList", self)
		Apollo.RegisterEventHandler("OnFriendshipAccountDataUpdate","RefreshList", self)
		Apollo.RegisterEventHandler("GuildRoster",					"OnGuildRosterReceived", self)
		Apollo.RegisterEventHandler("GuildMemberChange",			"OnGuildRosterReceived", self)
		Apollo.RegisterEventHandler("VarChange_ZoneName",			"OnChangeZoneName", self)
		Apollo.RegisterEventHandler("SubZoneChanged",				"OnChangeZoneName", self)

		-- Monitor the social window events		
		Apollo.RegisterEventHandler("EventGeneric_OpenSocialPanel", "OnSocialWindowToggle", self)
		Apollo.RegisterEventHandler("ToggleSocialWindow", 			"OnSocialWindowToggle", self)
		Apollo.RegisterEventHandler("SocialWindowHasBeenClosed",	"OnSocialWindowClose", self)
		Apollo.RegisterEventHandler("GenericEvent_InitializeNeighbors", "OnSocialWindowToggle", self)		
		
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", 	"OnInterfaceMenuListHasLoaded", self)
		--Apollo.RegisterEventHandler("Tutorial_RequestUIAnchor", 	"OnTutorial_RequestUIAnchor", self)
		
		-- Register Slash Commands				
		Apollo.RegisterSlashCommand("neighbornotes", 				"OpenNN", self)
		Apollo.RegisterSlashCommand("nn", 							"OpenNN", self)
		Apollo.RegisterSlashCommand("nnv",	 						"OnVisitConfirmBtn", self)

		self:SetLocaleData()
		self:OnChangeZoneName( nil, GetCurrentZoneName())
		self.timerZoneLoad:Start()
	end	
end

----------------------------------------------------------------------------------------------
-- Global Event Handlers
----------------------------------------------------------------------------------------------

-- Saves data when the game is closed, or when the UI is reloaded
function NeighborNotes:OnSave(eType)
	local tSave = {}
	-- Account Level
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
		tSave = self.tAccount
	end
	-- Realm Level
	if eType == GameLib.CodeEnumAddonSaveLevel.Realm then
		tSave = self.tRealm
	end
	-- Character Level
	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		tSave = self.tCharacter
	end
	return tSave
end

-- Loads data when the game is closed, or when the UI is reloaded
function NeighborNotes:OnRestore(eType, tLoad)
	if not tLoad then
		return
	end
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
		if tLoad then
			if tLoad.nVersion == nil or tLoad.nVersion ~= self.tAccount.nVersion then
				self.tLiveData.bShowSplash = true
			else
				self.tLiveData.bShowSplash = false
			end
			-- Load other data here
		end
	end
	if eType == GameLib.CodeEnumAddonSaveLevel.Realm then
		if tLoad then
			if tLoad.nVersion == self.tRealm.nVersion and tLoad.tNeighborList then
				for strNeighborName, tData in pairs(tLoad.tNeighborList) do
					if not tData.strNote then
						tData.strNote = ""
					end
					if not tData.nNodeID then
						tData.nNodeID = 0
					end
					self.tRealm.tNeighborList[strNeighborName] = tData
				end
			end
		else
			self.tRealm.tNeighborList = {}
		end
	end
	if eType == GameLib.CodeEnumAddonSaveLevel.Character then
		if tLoad then
			if tLoad.nVersion == self.tCharacter.nVersion and tLoad.Filters then
				if tLoad.tFilters.bHarvestable ~= nil then
					self.tCharacter.tFilters.bHarvestable = tLoad.tFilters.bHarvestable
				end
				if tLoad.tFilters.bShowAllCharacters ~= nil then
					self.tCharacter.tFilters.bShowAllCharacters = tLoad.tFilters.bShowAllCharacters
				end
			end
			if tLoad.bOpenWithSocial ~= nil then
				self.tCharacter.bOpenWithSocial = tLoad.bOpenWithSocial
			end
			if tLoad.bCloseWithSocial ~= nil then
				self.tCharacter.bCloseWithSocial = tLoad.bCloseWithSocial
			end
			if tLoad.bOnVisitSelectNext ~= nil then
				self.tCharacter.bOnVisitSelectNext = tLoad.bOnVisitSelectNext
			end
		end
	end
end

function NeighborNotes:OnConfigure()
	NeighborNotes:OnConfigBtn()
end


------------------------------------------------------------------------------------------
-- Generic Event Handlers
------------------------------------------------------------------------------------------

-- Places units that are fed to the client into a table/queue named self.tQueuedUnits
function NeighborNotes:OnUnitCreated(unit)
	if HousingLib.IsHousingWorld() == false then
		return
	end
	if unit == null or not unit:IsValid() or unit == GameLib.GetPlayerUnit() then
		return
	end
	table.insert(self.tLiveData.tQueuedUnits, unit)
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
		if tNeighbor.strCharacterName and not self.tRealm.tNeighborList[tNeighbor.strCharacterName] then
			self.tRealm.tNeighborList[tNeighbor.strCharacterName] = {}
			self.tRealm.tNeighborList[tNeighbor.strCharacterName].tPlugs = {}
		end
	end
	tNeighbors = nil
	
	-- set up the neighbor lookup table
	--local tSortData = HousingLib.GetNeighborList() or {}
	local tSortData = {}

	for strName, tData in pairs(self.tRealm.tNeighborList) do
		-- check to see if the neighbor is already in the Sort Table
		tNData = {}
		tNData.strNote = tData.strNote or  ""
		tNData.nNodeID = tData.nNodeID or 0
		tNData.strCharacterName = strName
		tNData.nPlugWeight = #tData.tPlugs
		local tTemp = self:GetNeighborByName(strName)
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
	tSortData = self:GetFilteredTable(tSortData)
	
	-- Do our sort	
	if tSortData and #tSortData > 0 then
		if self.fnSort then
			table.sort(tSortData, self.fnSort)
		end
	end

	-- Set the neighbor count
	self.wndMain:FindChild("NeighborCount"):SetText(#tSortData)
	
	local nPos = 1
	local bStop = false
	-- Populate the List Container
	for key, tCurrNeighbor in pairs(tSortData) do
		local wndListItem = Apollo.LoadForm(self.xmlDoc, "NeighborListItem", self.wndListContainer, self)
		wndListItem:SetData(tCurrNeighbor) -- set the full table since we have no direct lookup for neighbors
		local strColorToUse = self.tColors.crOffline
		if tCurrNeighbor.fLastOnline == 0 then -- online / check for strWorldZone
			strColorToUse = self.tColors.crOnline
		end

		local tName = wndListItem:FindChild("Name")
		tName:SetText(tCurrNeighbor.strCharacterName)
		tName:SetTextColor(strColorToUse)
		local tNoteData = self.tRealm.tNeighborList[tCurrNeighbor.strCharacterName]
		if tNoteData ~= nil then
			if tNoteData.strNote ~= nil and tNoteData.strNote ~= "" then
				local wndNote = wndListItem:FindChild("Notes")
				wndNote:SetText(tNoteData.strNote)
				wndNote:SetTextColor(strColorToUse)
			end
			if tNoteData.nNodeID ~= nil and tNoteData.nNodeID ~= 0 then
				local wndNode = wndListItem:FindChild("Node")
				wndNode:SetSprite(self.tEnums.tNodes[tNoteData.nNodeID].strIcon)
				tTempNode = self.tLiveData.tNodes[tNoteData.nNodeID]
				wndNode:SetTooltip(self.tLiveData.tNodes[tNoteData.nNodeID])
			end
			if tNoteData.tPlugs ~= nil then
				for nIndex, nPlugID in ipairs(tNoteData.tPlugs) do
					if nPlugID ~= nil and nPlugID ~= 0 then
						local wndPlug = wndListItem:FindChild("Plug" .. nIndex)
						if not wndPlug then -- There are currently 7 plug spots, any more than 7 will not be shown
							break
						end
						if self.tEnums.tPlugs[nPlugID].strIcon == nil then
							if nPlugID < 101 then
								wndPlug:SetSprite("IconSprites:Icon_CraftingUI_Item_Crafting_PowerCore_Blue")
							elseif nPlugID < 201 then
								wndPlug:SetSprite(self.tEnums.tPlugType["Biome"].strIcon)
							elseif nPlugID < 401 then
								wndPlug:SetSprite(self.tEnums.tPlugType["Challenge"].strIcon)
							elseif nPlugID < 601 then
								wndPlug:SetSprite(self.tEnums.tPlugType["Expedition"].strIcon)
							elseif nPlugID < 801 then
								wndPlug:SetSprite(self.tEnums.tPlugType["Raid"].strIcon)
							elseif nPlugID < 1001 then
								wndPlug:SetSprite(self.tEnums.tPlugType["PublicEvent"].strIcon)
							end
						else
							wndPlug:SetSprite(self.tEnums.tPlugs[nPlugID].strIcon)
						end
						wndPlug:SetTooltip(self.tLiveData.tPlugs[nPlugID])
					end
				end
			end
		end
		
		if nPrevId ~= nil and tCurrNeighbor.nId == nPrevId then
			wndListItem:FindChild("FriendBtn"):SetCheck(true)
			bStop = true
		end

		local wndIcon = wndListItem:FindChild("RoommateIcon")
		if tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Roommate then
			wndIcon:Show(true)
			wndIcon:SetSprite("ClientSprites:Icon_Windows_UI_CRB_Attribute_Health")
			wndIcon:SetTooltip(Apollo.GetString("Neighbors_RoommateTooltip"))
		elseif tCurrNeighbor.ePermissionNeighbor == 999 then
			wndIcon:Show(true)
			wndIcon:SetSprite("DatachronSprites:btnBagFullNormal")
			wndIcon:SetTooltip("This is a neighbor of another character")
		else
			wndIcon:Show(false)
		end
		
		wndIcon = wndListItem:FindChild("AccountIcon")
			wndIcon:Show(tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Account)
		if tCurrNeighbor.ePermissionNeighbor == HousingLib.NeighborPermissionLevel.Account then
			wndIcon:SetTooltip(Apollo.GetString("Neighbors_RoommateTooltip"))
		end
		
		-- Add Icons for Guild and Circle Members
		wndIcon = wndListItem:FindChild("FavIcon")
		if tCurrNeighbor.bFavorite then
			wndIcon:Show(true)
		else
			wndIcon:Show(false)
		end
		
		wndIcon = wndListItem:FindChild("GroupIcon")
		strGroups = self:GetGroups(tCurrNeighbor.strCharacterName)
		if strGroups then
			wndIcon:Show(true)
			wndIcon:SetTooltip(strGroups)
		else
			wndIcon:Show(false)
		end
		wndListItem:FindChild("Name"):SetTextColor(strColorToUse)
		if not bStop then
			nPos = nPos + 40
		end
	end
	
	-- set scroll
	self.wndListContainer:ArrangeChildrenVert()
	self:UpdateControls()
	if nPrevId ~= nil then
		self.wndListContainer:SetVScrollPos(nPos)
	end
end

-- Gets Guild and Circle data
function NeighborNotes:OnGuildRosterReceived(groupCurr, tGroupRoster)
	if not tGroupRoster or #tGroupRoster == 0 then
		return
	end
	local tGroup = nil
	for nIndex, tTemp in ipairs(self.tLiveData.tGroups) do
		if tTemp.strName == groupCurr:GetName() then
			tGroup = tTemp
		end
	end
	if not tGroup then
		tGroup = { strName = groupCurr:GetName(), nType = groupCurr:GetType() }
		table.insert(self.tLiveData.tGroups, tGroup)
	end
	-- Build the roster
	local tRoster = {}
	for nIndex, tCharacter in ipairs(tGroupRoster) do
		tRoster[tCharacter.strName] = true
	end
	tGroup.tRoster = tRoster
end

-- Updates self.strCurrentZone and self.bNeighborZone with current zone info
function NeighborNotes:OnChangeZoneName(oVar, strNewZone)
	if strNewZone == nil or strNewZone == "" then
		return
	end
	self.tLiveData.strNeighborName = ""
	local nFirst = strNewZone:find('%[', 1)
	local nLast = strNewZone:find('%]', 1)
	if nFirst ~= nil and nLast ~= nil then
		local strNeighborName = strNewZone:sub(nFirst + 1, nLast -1)
		if(strNeighborName ~= "") then
			local tNeighborList = HousingLib.GetNeighborList()
			for key, tCurrNeighbor in pairs(tNeighborList) do
				if tCurrNeighbor.strCharacterName == strNeighborName then
					self.tLiveData.strNeighborName = strNeighborName
					break
				end
			end
		end
	end
	self.timerZoneLoad:Start()
end

function NeighborNotes:OnSocialWindowToggle()
	if self.tCharacter.bOpenWithSocial then
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
	if self.tCharacter.bCloseWithSocial then
		if self.wndMain and self.wndMain:IsShown() then
			self.wndMain:Close()
		end
	end
end

-- Registers Neighbor Notes with the Interface Menu
function NeighborNotes:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Neighbor Notes", { "ToggleAddon_NN", "", "IconSprites:Icon_Windows32_UI_CRB_InterfaceMenu_SupportTicket"})
end

-------------------------------------------------------------------------------------------------
-- This might be useless
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

	local tGuild = GuildLib.GetGuilds()
	if #tGuild > 0 then
		for nIndex, guildCurr in ipairs(GuildLib.GetGuilds()) do
			guildCurr:RequestMembers()
		end
	end	
	
	if self.tMissingNodes then
		for nIndex, strTemp in ipairs(self.tMissingNodes) do
			--Print(strTemp .. " is missing from the local node table")
		end
		self.tMissingNodes = nil
	end
	if self.tMissingPlugs then
		for nIndex, strTemp in ipairs(self.tMissingPlugs) do
			--Print(strTemp .. " is missing from the local plug table")
		end
	end
	
	if self.tMissingNodeUnits then
		for nIndex, strTemp in ipairs(self.tMissingNodeUnits) do
			--Print(strTemp .. " does not have any associated units")
		end
	end
	
	if self.tMissingPlugUnits then
		for nIndex, strTemp in ipairs(self.tMissingPlugUnits) do
			--Print(strTemp .. " does not have any associated units")
		end
	end
		
	-- see if this zone should be scanned
	if HousingLib.IsHousingWorld() == false then
		self.tLiveData.tQueuedUnits = {}
		return
	end

	if self.tLiveData.strNeighborName == nil or self.tLiveData.strNeighborName == "" then
		self.tLiveData.tQueuedUnits = {}
		return
	end
	
	if #self.tLiveData.tQueuedUnits == 0 then
		Print("No units found in this Neighborhood")
		return
	end
	
	local unitPlayerDisposition = GameLib.GetPlayerUnit()
	if unitPlayerDisposition == nil or not unitPlayerDisposition:IsValid() then
		self.tLiveData.tQueuedUnits = {}
		return
	end
	
	local tHarvestNodes = {}
	local tUnitNodes = {}
	local nHarvestCount = 0
	local nUnitCount = 0
	for nIndex, udUnit in pairs(self.tLiveData.tQueuedUnits) do
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
	
	self.tLiveData.tQueuedUnits = {}
	if nHarvestCount > 0 then
		self:UpdateNode(tHarvestNodes)
	end
	if nUnitCount > 0 then
		self:UpdatePlugs(tUnitNodes)
	end
	Print("Neighbor Notes: Finished Gathering info on " .. self.tLiveData.strNeighborName)
	self:RefreshList()
end


---------------------------------------------------------------------------------------------------
-- tNeighborNotes datatable access functions
---------------------------------------------------------------------------------------------------

-- Returns the text note based on the character name
function NeighborNotes:GetCharacterNote(strCharacterName)
	if strCharacterName == nil or strCharacterName == "" then
		return ""
	end
	if self.tRealm.tNeighborList == nil then
		Print("Can't access the Neighbor Notes data table")
		Apollo.AddAddonErrorText("Can't access the neighbornotes table")
	end	
	if self.tRealm.tNeighborList[strCharacterName] ~= nil and self.tRealm.tNeighborList[strCharacterName].strNote ~= nil then
		return self.tRealm.tNeighborList[strCharacterName].strNote
	end
	return ""
end

-- Sets the text note for the specified character
function NeighborNotes:SetCharacterNote(strCharacterName, strNote)
	if self.tRealm.tNeighborList[strCharacterName] == nil then
		self.tRealm.tNeighborList[strCharacterName] = {}
	end
	self.tRealm.tNeighborList[strCharacterName].strNote = strNote
end

-- Updates the node of the current Neighbor node
function NeighborNotes:UpdateNode(tUnitNames)
	local nBest = 0
	for strName, nNum in pairs(tUnitNames) do
		-- see which type it is
		local nNode = self.tLiveData.tNodeUnits[strName]
		if nNode ~= nil and nNode > nBest then
			nBest = nNode
		end
	end
	if nBest ~= 0 then
		Print("Found Node: " .. self.tLiveData.tNodes[nBest])	
		if self.tRealm.tNeighborList[self.tLiveData.strNeighborName] == nil then
			self.tRealm.tNeighborList[self.tLiveData.strNeighborName] = {}
		end
		if self.tRealm.tNeighborList[self.tLiveData.strNeighborName].nNodeID ~= nil then
			if self.tRealm.tNeighborList[self.tLiveData.strNeighborName].nNodeID >= nBest then
				return
			end
		end
		self.tRealm.tNeighborList[self.tLiveData.strNeighborName].nNodeID = nBest;
	end
end

-- Replaces the existing Plugs with the list provided in tUnitNames
function NeighborNotes:UpdatePlugs(tUnitNames)
	function fSort(a,b)
		return (a[1] < b[1])
	end
	local tNewPlugs = {}
	local nCount = 0
	-- Build a current list of plugs
	for strUnitName, nNum in pairs(tUnitNames) do
		if strUnitName ~= nil and strUnitName ~= "" then
			local nPlugID = self.tLiveData.tPlugUnits[strUnitName]
			if nPlugID ~= nil then
				tNewPlugs[nPlugID] = 1
				nCount = nCount + 1
			end
		end
	end

	if self.tRealm.tNeighborList[self.tLiveData.strNeighborName] == nil then
		self.tRealm.tNeighborList[self.tLiveData.strNeighborName] = self.tDefaults.tCharacter
	end	
	self.tRealm.tNeighborList[self.tLiveData.strNeighborName].tPlugs = {}
	if nCount > 0 then
		local strPlugs = ""
		for nPlugID, nNum in pairs(tNewPlugs) do
			table.insert(self.tRealm.tNeighborList[self.tLiveData.strNeighborName].tPlugs, nPlugID)
			strPlugs = strPlugs .. " " .. self.tLiveData.tPlugs[nPlugID]
		end
		Print("Found Plugs:" .. strPlugs)
		table.sort(self.tRealm.tNeighborList[self.tLiveData.strNeighborName].tPlugs)		
	end
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

function NeighborNotes:GetGroups(strNeighborName)
	local strGroups = ""
	for nIndex, tGuild in ipairs(self.tLiveData.tGroups) do
		if tGuild.tRoster[strNeighborName] then
			if strGroups ~= "" then
				strGroups = strGroups .. "\n\r"
			end
			if tGuild.nType == GuildLib.GuildType_Circle then
				strGroups = strGroups .. tGuild.strName .. "(Circle)"
			elseif tGuild.nType == GuildLib.GuildType_Guild then
				strGroups = strGroups .. tGuild.strName .. "(Guild)"
			end
		end
	end
	if strGroups ~= "" then
		return strGroups
	else
		return nil
	end
end

function NeighborNotes:IsFriend(strName)
	
end

function NeighborNotes:IsGuildie(strName)

end

function NeighborNotes:GetCircleID(strName)

end

-- Applies filters from self.tUserSettings.tFilters to the table tNeighborList
function NeighborNotes:GetFilteredTable(tNeighborList)
	local tRemoveList = {}
	local strCharName = GameLib.GetPlayerUnit():GetName()
	local tActiveSkills = self:GetActiveTradeskills()

	tRemoveList[strCharName] = true
	
	for nIndex, tNeighbor in ipairs(tNeighborList) do
		if self.tCharacter.tFilters.bShowAllCharacters == false then
			if not self:GetNeighborByName(tNeighbor.strCharacterName) then
				tRemoveList[tNeighbor.strCharacterName] = true
			end
		end
		if self.tCharacter.tFilters.bHarvestable == true then
			if tNeighbor.nNodeID == nil or tNeighbor.nNodeID == 0 then
				tRemoveList[tNeighbor.strCharacterName] = true
			elseif tNeighbor.nNodeID < 011 and tActiveSkills["Relic"] then
				-- do nothing
			elseif tNeighbor.nNodeID > 10 and tNeighbor.nNodeID < 021 and tActiveSkills["Survival"] then
				-- do nothing
			elseif tNeighbor.nNodeID > 20 and tNeighbor.nNodeID < 031 and tActiveSkills["Mining"] then
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
				if tSkill.strName == self.tLiveData.tProfessionNames["Relic Hunter"] then
					tReturnList["Relic"] = true
				elseif tSkill.strName == self.tLiveData.tProfessionNames["Survivalist"] then
					tReturnList["Survival"] = true
				elseif tSkill.strName == self.tLiveData.tProfessionNames["Mining"] then
					tReturnList["Mining"] = true
				end
			end
		end
	end
	return tReturnList
end

-- This builds the tLiveData.tNodes, tNodeUnits, tPlugs, and tPlugUnits tables with localized names
function NeighborNotes:BuildTablesFromLocale(tLocale)
	self.tLiveData.tNodes = {}
	self.tLiveData.tNodeUnits = {}
	self.tMissingNodes = {}
	self.tMissingPlugs = {}
	self.tMissingNodeUnits = {}
	self.tMissingPlugUnits = {}
	-- Load locale data for Nodes
	for nId, tData in pairs(self.tEnums.tNodes) do
		local tNodeTemp = tLocale.tNodes[tData.strName]
		if tNodeTemp then
			self.tLiveData.tNodes[nId] = tNodeTemp.strName
			if not tNodeTemp.tUnits or #tNodeTemp.tUnits == 0 then
				table.insert(self.tMissingNodeUnits, tData.strName)
			end	
			for nIndex, strLocalName in ipairs(tNodeTemp.tUnits) do
				self.tLiveData.tNodeUnits[strLocalName] = nId
			end
		else
			table.insert(self.tMissingNodes, tData.strName)
		end
	end
	-- Load Locale data for Plots
	self.tLiveData.tPlugs = {}
	self.tLiveData.tPlugUnits = {}
	for nId, tData in pairs(self.tEnums.tPlugs) do
		local tPlugTemp = tLocale.tPlugs[tData.strName]
		if tPlugTemp then
			self.tLiveData.tPlugs[nId] = tPlugTemp.strName
			if not tPlugTemp.tUnits or #tPlugTemp.tUnits == 0 then
				table.insert(self.tMissingPlugUnits, tData.strName)
			end	
			for nIndex, strLocalName in ipairs(tPlugTemp.tUnits) do
				self.tLiveData.tPlugUnits[strLocalName] = nId
			end
		else
			table.insert(self.tMissingPlugs, tData.strName)
		end
	end
	-- Load Profession Names
	self.tLiveData.tProfessionNames = tLocale.tProfessionNames
end

-- Tries to determine the local and then calls BuildTablesFromLocale
function NeighborNotes:SetLocaleData()
	-- Figure out the locale
	local strCancel = Apollo.GetString(1)
	local strLocale = ""
	if strCancel == "Abbrechen" then -- German
		self:BuildTablesFromLocale(self.tLocale.de)
	elseif strCancel == "Annulaer" then -- French
		self:BuildTablesFromLocale(self.tLocale.fr)
	elseif strCancel == "something" then -- Korean
		self:BuildTablesFromLocale(self.tLocale.ko)
	else
		self:BuildTablesFromLocale(self.tLocale.en)
	end
end


-- Initialize the Addon
local NeighborNotesInst = NeighborNotes:new()
NeighborNotes:Init()


