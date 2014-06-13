-----------------------------------------------------------------------------------------------
-- Client Lua Script for Generalist
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "GameLib"
require "PlayerPathLib"
require "Item"
require "Money"
 
-----------------------------------------------------------------------------------------------
-- Generalist Module Definition
-----------------------------------------------------------------------------------------------
local Generalist = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

-- local kcrSelectedText = ApolloColor.new("UI_BtnTextHoloPressedFlyby")
-- local kcrNormalText = ApolloColor.new("UI_BtnTextHoloNormal")

local altTooltip = "<P Font=\"CRB_InterfaceSmall\" TextColor=\"white\">%s</P>"

-- Costume slots, from the Character UI
--
local genSlotFromId = -- string name, then id, then button art
{
	[0]  = "ChestSlot",
	[1]  = "LegsSlot",
	[2]  = "HeadSlot",
	[3]  = "ShoulderSlot",
	[4]  = "FeetSlot",
	[5]  = "HandsSlot",
	[6]  = "ToolSlot",
	[7]  = "AttachmentSlot",
	[8]  = "SupportSlot",
	[10] = "ImplantSlot",
	[11] = "GadgetSlot",
	[15] = "ShieldSlot",	
	[16] = "WeaponSlot",				
}

local altClassToIcon =
{
	[GameLib.CodeEnumClass.Warrior] 		= "IconSprites:Icon_Windows_UI_CRB_Warrior",
	[GameLib.CodeEnumClass.Engineer] 		= "IconSprites:Icon_Windows_UI_CRB_Engineer",
	[GameLib.CodeEnumClass.Esper] 			= "IconSprites:Icon_Windows_UI_CRB_Esper",
	[GameLib.CodeEnumClass.Medic] 			= "IconSprites:Icon_Windows_UI_CRB_Medic",
	[GameLib.CodeEnumClass.Stalker] 		= "IconSprites:Icon_Windows_UI_CRB_Stalker",
	[GameLib.CodeEnumClass.Spellslinger] 	= "IconSprites:Icon_Windows_UI_CRB_Spellslinger",
}

local altClassToString =
{
	[GameLib.CodeEnumClass.Warrior] 		= "Warrior",
	[GameLib.CodeEnumClass.Engineer] 		= "Engineer",
	[GameLib.CodeEnumClass.Esper] 			= "Esper",
	[GameLib.CodeEnumClass.Medic] 			= "Medic",
	[GameLib.CodeEnumClass.Stalker] 		= "Stalker",
	[GameLib.CodeEnumClass.Spellslinger] 	= "Spellslinger",
}

local altPathToIcon = {
	[PlayerPathLib.PlayerPathType_Explorer] = "CRB_PlayerPathSprites:spr_Path_Explorer_Stretch",
	[PlayerPathLib.PlayerPathType_Soldier] = "CRB_PlayerPathSprites:spr_Path_Soldier_Stretch",
	[PlayerPathLib.PlayerPathType_Settler] = "CRB_PlayerPathSprites:spr_Path_Settler_Stretch",
	[PlayerPathLib.PlayerPathType_Scientist] = "CRB_PlayerPathSprites:spr_Path_Scientist_Stretch",
}
local altPathToString = {
	[PlayerPathLib.PlayerPathType_Explorer] = Apollo.GetString("PlayerPathExplorer"),
	[PlayerPathLib.PlayerPathType_Soldier] = Apollo.GetString("PlayerPathSoldier"),
	[PlayerPathLib.PlayerPathType_Settler] = Apollo.GetString("PlayerPathSettler"),
	[PlayerPathLib.PlayerPathType_Scientist] = Apollo.GetString("PlayerPathScientist"),
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Generalist:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	o.tItems = {} -- keep track of all the list items
	-- o.wndSelectedListItem = nil -- keep track of which list item is currently selected

    return o
end

function Generalist:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end

-----------------------------------------------------------------------------------------------
-- Generalist OnLoad
-----------------------------------------------------------------------------------------------
function Generalist:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Generalist.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Generalist OnDocLoaded
-----------------------------------------------------------------------------------------------
function Generalist:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	
		-- Set up the main window
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "GeneralistForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
			
		-- item list window
		self.wndItemList = self.wndMain:FindChild("ItemList")
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("gen", "OnGeneralistOn", self)
		
		-- Get ourselves into the Interface menu
		Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
		Apollo.RegisterEventHandler("ToggleGeneralist", "OnGeneralistOn", self)

		-- doesn't really need a timer, I think
		-- self.timer = ApolloTimer.Create(1.0, true, "OnTimer", self)

	end
end


-----------------------------------------------------------------------------------------------
-- Close window button functions.  As simple as they get.
-----------------------------------------------------------------------------------------------

function Generalist:OnCancel()
	-- Close the detail window as well if it's there
	if self.wndDetail ~= nil then
		self.wndDetail:Close()
		self.detailOpen = false
	end
	-- Close the search window as well if it's there
	if self.wndSearch ~= nil then
		self.wndSearch:Close()
		self.searchOpen = nil
	end
	-- And close the main window
	self.wndMain:Close()
end

function Generalist:OnDetailCancel()
	-- Close the detail window
	self.wndDetail:Close()
	-- And mark that it's closed, so we can open another
	self.detailOpen = false
end

function Generalist:OnSearchClose()
	-- Close the search window
	self.wndSearch:Close()
	-- And mark that it's closed, so we can open another
	self.searchOpen = nil
end

-----------------------------------------------------------------------------------------------
-- Generalist Functions
-----------------------------------------------------------------------------------------------

-- on SlashCommand "/gen"
function Generalist:OnGeneralistOn()
	self.wndMain:Invoke() -- show the window
	
	-- if altData doesn't exist yet, create empty hash
	if self.altData == nil then
		self.altData = {}
	end
	
	-- populate the character list
	self:PopulateCharList()
end

-- on timer
function Generalist:OnTimer()
	-- Do your timer-related stuff here.
end

-----------------------------------------------------------------------------------------------
-- Populate list of characters
-----------------------------------------------------------------------------------------------

function Generalist:PopulateCharList()
	-- make sure the list is empty to start with
	self:DestroyCharList()
	
	-- next, add the current character to the table, and/or update its data
	self:AddCurrentCharacter()
	
	-- Get the current character's faction
	local factID = GameLib.GetPlayerUnit():GetFaction()
	
	-- Build list of characters of this faction
	local a = {}
    for name in pairs(self.altData) do
		-- Only add characters of this faction to the list
		if self.altData[name].faction == factID then
			table.insert(a, name)
		end
	end
	
	-- Sort the list (alphabetically)
    table.sort(a)
	
	-- Now loop through the table of data and add all characters to the list item
	--
	local totalCash = 0
	local counter
	local name
	for counter, name in ipairs(a) do
		self:AddEntry(name,counter)
		
		-- Add this character's money to the total
		if self.altData[name].cash ~= nil then
			totalCash = totalCash + self.altData[name].cash
		end

	end
	
	-- Update the total cash display
	self.wndMain:FindChild("TotalCash"):SetAmount(totalCash,true)
			
	-- now all the item are added, call ArrangeChildrenVert to list out the list items vertically
	self.wndItemList:ArrangeChildrenVert()
end

-- clear the item list
function Generalist:DestroyCharList()
	-- destroy all the wnd inside the list
	for idx,wnd in ipairs(self.tItems) do
		wnd:Destroy()
	end

	-- clear the list item array
	self.tItems = {}
	self.wndSelectedListItem = nil
end

-- 
-- Add alt's entry into the item list at a particular index
--
function Generalist:AddEntry(name,i)
	-- load the window item for the list item
	local wnd = Apollo.LoadForm(self.xmlDoc, "ListItem", self.wndItemList, self)
	
	-- keep track of the window item created
	self.tItems[i] = wnd
	
	local entry = self.altData[name]

	-- give it a piece of data to refer to 
	local wndItemText = wnd:FindChild("CharName")

	if wndItemText then -- make sure the text wnd exist
	
		-- Character's Name
		wndItemText:SetText(name) -- set the item wnd's text to alt's name
		--wndItemText:SetTextColor(kcrNormalText)
		
		-- Character's Level
		wnd:FindChild("PlayerLevel"):SetText(tostring(entry.level))
		
		-- Character's Class, as icon with tooltip
		wnd:FindChild("PlayerClass"):SetSprite(altClassToIcon[entry.class])
		if altClassToString[entry.class] ~= nil then
			wnd:FindChild("PlayerClass"):SetTooltip(string.format(altTooltip, altClassToString[entry.class]))
		end
			
		-- Character's Gold
		if entry.cash ~= nil then
			wnd:FindChild("PlayerGold"):SetAmount(entry.cash, true)
		else
			wnd:FindChild("PlayerGold"):Show(false)
		end
		
		-- Character's Path
		wnd:FindChild("PlayerPath"):SetSprite(altPathToIcon[entry.path])
		if altPathToString[entry.path] ~= nil then
			wnd:FindChild("PlayerPath"):SetTooltip(string.format(altTooltip, altPathToString[entry.path]))
		end
		
	end
	wnd:SetData(i)
end

-----------------------------------------------------------------------------------------------
-- Add the current character to the data structure and update their info
-----------------------------------------------------------------------------------------------
function Generalist:AddCurrentCharacter()

	-- Get the current character's name
	--
	local unitPlayer = GameLib.GetPlayerUnit()
	local myName = unitPlayer:GetName()
	
	-- Is there an entry for this player in the table?
	-- Add an empty entry if not.
	--
	if self.altData[myName] == nil then
		self.altData[myName] = {}
	end
	
	-- Now update the entry.  First, the basics.
	--
	self.altData[myName].level   = unitPlayer:GetLevel()
	self.altData[myName].faction = unitPlayer:GetFaction()
	self.altData[myName].class   = unitPlayer:GetClassId()
	self.altData[myName].path    = PlayerPathLib.GetPlayerPathType()
	self.altData[myName].cash    = GameLib.GetPlayerCurrency():GetAmount()

	-- Update the player's list of unlocked AMPs.
	self:GetUnlockedAmps(myName)
	
	-- Update the player's list of known tradeskills and schematics
	self:GetTradeskills(myName)
	
	-- Update the player's equipped gear
	self:GetCharEquipment(myName)
	
	-- Update the player's inventory
	self:GetCharInventory(myName)
	
end

-----------------------------------------------------------------------------------------------
-- Functions for storing particular parts of the current character's data
-----------------------------------------------------------------------------------------------

function Generalist:GetCharInventory(myName)
	
	-- Hash for storing our complete inventory
	local myInv = {}
	
	-- Inventory hash format will be:
	-- {
	--   itemDbIdNumber = {name, count, location},
	--   anotherItemDbIdNumber = {name, count, location},
	-- }
	
	-- Get the big inventory hash, and loop through it.
	--
	local inv = GameLib.GetPlayerUnit():GetInventoryItems()
	for _,invBag in ipairs(inv) do
		-- Get the DB ID# of the item
		local id = invBag.itemInBag:GetItemId()
		local name = invBag.itemInBag:GetName()
		
		-- Have we encountered any of this item yet?
		if myInv[id] == nil then
			-- Nope, it's new.  Put it in the hash.
			myInv[id] = {}
			myInv[id].location = 1
			myInv[id].name = name
			myInv[id].count = invBag.itemInBag:GetStackCount()
		else
			-- Nope, we already saw another stack of it.  Add this one to it.
			myInv[id].count = myInv[id].count + invBag.itemInBag:GetStackCount()
		end	
	end -- of loop through inventory bags
	
	-- The tradeskill bag structure is much more complicated,
	-- having categories.
	--
	local supply = GameLib.GetPlayerUnit():GetSupplySatchelItems()
		for category,contents in pairs(supply) do
	
		-- Now loop through the items in the category.
		for _,thing in ipairs(contents) do
			-- The ID of the thing
			local id = thing.itemMaterial:GetItemId()
			local name = thing.itemMaterial:GetName()
						
			-- Now it's a similar song-and-dance to the bit where
			-- we looped through the inventory bags, but we use a 
			-- different variable.  
			
			-- Have we encountered any of this item yet?
			if myInv[id] == nil then
				-- Nope, it's new.  Put it in the hash.
				myInv[id] = {}
				myInv[id].location = 2
				myInv[id].name = name
				myInv[id].count = thing.nCount
			else
				-- Nope, we already saw another stack of it.  Add this one to it.
				myInv[id].count = myInv[id].count + thing.nCount
				myInv[id].location = bit32.bor(2,myInv[id].location)
			end	
		
		end -- of loop through things in a supply category
	
	end -- of loop through supply categories
	
	-- Now we have to get equipment as well!
	local eq = GameLib.GetPlayerUnit():GetEquippedItems()
	for key, itemEquipped in pairs(eq) do
		-- the item's ID
		local id = itemEquipped:GetItemId()
		local name = itemEquipped:GetName()
		
		if myInv[id] == nil then
			-- Nope, it's new.  Put it in the hash.
			myInv[id] = {}
			myInv[id].location = 4
			myInv[id].name = name
			myInv[id].count = 1
		else
			-- We already saw a stack of it.  Add this one to it.
			myInv[id].count = myInv[id].count + 1
			myInv[id].location = bit32.bor(4,myInv[id].location)
		end	
		
	end
	
	-- Finally, set our data
	self.altData[myName].inventory = myInv
	
end

function Generalist:GetUnlockedAmps(myName)
	local unlocked = {}
	local amps = AbilityBook.GetEldanAugmentationData(AbilityBook.GetCurrentSpec()).tAugments
	for _,ampEntry in ipairs(amps) do
		if ampEntry.nItemIdUnlock ~= 0 then
			if ampEntry.bUnlocked == true then
				table.insert(unlocked, ampEntry)
			end
		end
	end
	self.altData[myName].unlocked = unlocked
end

function Generalist:GetTradeskills(myName)
	local ts = {}
	local schem = {}
	local tsk = CraftingLib:GetKnownTradeskills()
	for _,tSkill in ipairs(tsk) do
		table.insert(ts, tSkill)
		-- Print( "adding skill: " ..  tSkill.strName .. " (" .. tSkill.eId .. ")" )
		schem[tSkill.eId] = CraftingLib.GetSchematicList(tSkill.eId)
	end
	
	self.altData[myName].tradeSkills = ts
	
	-- Sort schematics and then save them
	table.sort(schem, function(a,b)
		if a.strName ~= nil and b.strName ~= nil then
			return a.strName < b.strNam
		else
			return 0
		end
	end)
	self.altData[myName].schematics = schem
end

function Generalist:GetCharEquipment(myName)
	local eq = GameLib.GetPlayerUnit():GetEquippedItems()
	local equipment = {}
	for key, itemEquipped in pairs(eq) do
		equipment[itemEquipped:GetSlot()] = itemEquipped:GetItemId()
	end 
	self.altData[myName].equipment = equipment
end

-----------------------------------------------------------------------------------------------
-- Activating the Detail window
-----------------------------------------------------------------------------------------------
function Generalist:OnListItemSelected(wndHandler, wndControl)
    -- make sure the wndControl is valid
    if wndHandler ~= wndControl then
        return
    end
    
	-- Is one already open?
	if self.detailOpen then
		return
	end
	
	if self.searchOpen then
		return
	end
	
    -- Who was picked?
	local wndItemText = wndControl:FindChild("CharName")
	local charName = wndItemText:GetText()

	-- Set up everything in the detail window
	self:PopulateDetailWindow(charName)

	-- And now display the window
	self.wndDetail:Invoke()
	
	-- Flag that the detail window is open by setting detailOpen to the char
	self.detailOpen = charName
		    
	-- Print( "item " ..  self.wndSelectedListItem:GetData() .. " is selected.")
end

-----------------------------------------------------------------------------------------------
-- Populating the Detail window
-----------------------------------------------------------------------------------------------
function Generalist:PopulateDetailWindow(charName)

	-- Set up the details window
	self.wndDetail = Apollo.LoadForm(self.xmlDoc, "DetailForm", self.wndMain, self)
	if self.wndDetail == nil then
		Apollo.AddAddonErrorText(self, "Could not load the details window for some reason.")
		return
	end
	self.wndDetail:Show(false, true)
	
	-- The entry for the chosen character
	local entry = self.altData[charName]

	-- Set title to the character's name
	self.wndDetail:FindChild("CharName"):SetText(charName)
	
	-- Character's Level
	self.wndDetail:FindChild("PlayerLevel"):SetText("Level " .. tostring(entry.level))
		
	-- Character's Class, as icon with tooltip
	self.wndDetail:FindChild("PlayerClass"):SetSprite(altClassToIcon[entry.class])
	if altClassToString[entry.class] ~= nil then
		self.wndDetail:FindChild("PlayerClass"):SetTooltip(string.format(altTooltip, altClassToString[entry.class]))
	end
			
	-- Character's Gold
	if entry.cash ~= nil then
		self.wndDetail:FindChild("PlayerGold"):SetAmount(entry.cash, true)
	else
		self.wndDetail:FindChild("PlayerGold"):Show(false)
	end
		
	-- Character's Path
	self.wndDetail:FindChild("PlayerPath"):SetSprite(altPathToIcon[entry.path])
	if altPathToString[entry.path] ~= nil then
		self.wndDetail:FindChild("PlayerPath"):SetTooltip(string.format(altTooltip, altPathToString[entry.path]))
	end
	
	-- Tab set
	local tabSet = self.wndDetail:FindChild("DetailTabs")
	
	local unlockText = ""
	
	-- Tradeskill Picker
	self.wndDetail:FindChild("TradeskillPickerList"):DestroyChildren()
	self.wndDetail:FindChild("TradeskillPickerBtn"):AttachWindow(self.wndDetail:FindChild("TradeskillPickerListFrame"))
	
	-- First, sneak AMPs into this list
	local wndCurr = Apollo.LoadForm(self.xmlDoc, "TradeskillBtn", 
		self.wndDetail:FindChild("TradeskillPickerList"), self)
	wndCurr:SetData('amps')
	wndCurr:SetText('AMPs Unlocked')
	
	if entry.tradeSkills ~= nil and table.getn(entry.tradeSkills) > 0 then
		for i,skill in ipairs (entry.tradeSkills) do
			local wndCurr = Apollo.LoadForm(self.xmlDoc, "TradeskillBtn", 
				self.wndDetail:FindChild("TradeskillPickerList"), self)
				
			-- Set the button's data and text to the skill's eId/strName
			wndCurr:SetData(skill.eId)
			wndCurr:SetText(skill.strName)
		end
	end
	
	self.wndDetail:FindChild("TradeskillPickerList"):ArrangeChildrenVert()
	
	-- Character's equipment
	--
	--Print ("Equipment has " .. table.getn(entry.equipment) .. " entries")
	if entry.equipment == nil then entry.equipment = {} end
	
	for key, id in pairs(entry.equipment) do
	
		local itemData = Item.GetDataFromId(id)
		
		--Print ( key .. ": " .. itemData:GetName() )
		
		if genSlotFromId[key] ~= nil then
		
			-- Name of the slot control
			local slot = self.wndDetail:FindChild(genSlotFromId[key])
			
			-- Set the icon
			slot:SetSprite(itemData:GetIcon())
			
			-- Clear the tooltip
			slot:SetTooltipDoc(nil)
			
			-- And generate the tooltip
			Tooltip.GetItemTooltipForm(self, slot, itemData, {bPrimary = true, bSelling = false})
		
		end
		
	end -- of loop through equipment
	
end

---------------------------------------------------------------------------------------------------
-- Open the Search Form
---------------------------------------------------------------------------------------------------

function Generalist:OpenSearch( wndHandler, wndControl, eMouseButton )
	
	-- Return if there's already a search open
	if self.searchOpen ~= nil then
		return
	end
	
	-- Set up the search window
	self.wndSearch = Apollo.LoadForm(self.xmlDoc, "SearchForm", self.wndMain, self)
	if self.wndSearch == nil then
		Apollo.AddAddonErrorText(self, "Could not load the search window for some reason.")
		return
	end
	self.wndSearch:Show(false, true)
	self.wndSearch:SetOpacity(1,1)
	
	-- Prevent opening another one
	self.searchOpen = true
	
	-- And now display the window
	self.wndSearch:Invoke()
	
end

-----------------------------------------------------------------------------------------------
-- Create a new tab of the details window
-----------------------------------------------------------------------------------------------
function Generalist:NewDetailTab(strTitle)

	local newTab = Apollo.LoadForm(self.xmlDoc, "DetailTabs", self.wndDetail, self)
	if newTab == nil then
		Apollo.AddAddonErrorText(self, "Could not create the new tab for some reason.")
		return
	end
	
	newTab:SetText(strTitle)
	newTab:Show(true)
	
	return newTab	
end

-----------------------------------------------------------------------------------------------
-- Saving and loading our data
-----------------------------------------------------------------------------------------------
function Generalist:OnSave(eLevel)
    -- Only save at the Realm level
    if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Realm then
        return nil
    end

	-- Simply return the table we've been using!
	return self.altData
end

function Generalist:OnRestore(eLevel, tData)
    -- Only restore at the Realm level
    if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Realm then
        return nil
    end
	
	-- And load this into our data structure
	self.altData = tData
end

---------------------------------------------------------------------------------------------------
-- TradeskillBtn Functions
---------------------------------------------------------------------------------------------------

function Generalist:OnTradeskillPickerBtn( wndHandler, wndControl, eMouseButton )

	-- Close the popup menu
	self.wndDetail:FindChild("TradeskillPickerListFrame"):Show(false)
	
	-- Entry for the character in question
	local entry = self.altData[self.detailOpen]
	
	-- What skill did they pick?
	local pickedSkill = wndHandler:GetData()
	-- Print( "picked skill: " ..  pickedSkill )
	
	-- This is where we'll put the output, either AMPs or schematics.
	local recipeList = {}
	local recipeText = ""
	
	-- Change the text of the menu button itself to whatever they picked
	self.wndDetail:FindChild("TradeskillPickerBtn"):SetText(wndHandler:GetText())
	
	-- Empty the recipe list item
	local recList = self.wndDetail:FindChild("RecipeList")
	recList:DestroyChildren()
	
	-- Did they want to see unlocked AMPs?
	if pickedSkill == 'amps' then

		if entry.unlocked ~= nil and table.getn(entry.unlocked) > 0 
			and entry.unlocked[1].strTitle ~= nil then
		
			local unlocked = entry.unlocked

			-- Sort them
			table.sort(unlocked, function(a,b) 
				if a.strTitle ~= nil and b.strTitle ~= nil then
					return a.strTitle < b.strTitle
				else
					return 0
				end
			end)
			
			-- Now loop through
			for _,amp in ipairs(unlocked) do

				-- Create an entry as a child of the list container
				local wnd = Apollo.LoadForm(self.xmlDoc, "SchematicKnown", recList, self)
				wnd:FindChild("ItemName"):SetText(amp.strTitle)

				-- And the icon
				local itemData = Item.GetDataFromId(amp.nItemIdUnlock)
				local icon = wnd:FindChild("ItemIcon")
				icon:SetSprite(itemData:GetIcon())
					
				-- And its tooltip
				icon:SetTooltipDoc(nil)
				Tooltip.GetItemTooltipForm(self, icon, itemData, {bPrimary = true, bSelling = false})
				
			end -- of loop through amps	
			
		else -- no amps unlocked
			local wnd = Apollo.LoadForm(self.xmlDoc, "NoSchematicKnown", recList, self)
			wnd:FindChild("ItemName"):SetText("(No AMPs unlocked)")
		end
		
	else -- schematics rather than amps
	
		-- get the schematics for the desired tradeskill
		local schematics

		if entry.schematics ~= nil and entry.schematics[pickedSkill] ~= nil then
			 schematics = entry.schematics[pickedSkill]
		end
	
		-- Any schematics?
		if schematics ~= nil and table.getn(schematics) > 0 then
		
			-- Sort them
			table.sort(schematics, function(a,b) return a.strName < b.strName end)
			
			-- Now loop through them
			for _,recipe in ipairs(schematics) do
				local sid = recipe.nSchematicId
				local name = recipe.strName
				local itemId = CraftingLib.GetSchematicInfo(sid).itemOutput:GetItemId()
	
				-- Create an entry as a child of the list container
				local wnd = Apollo.LoadForm(self.xmlDoc, "SchematicKnown", recList, self)
				wnd:FindChild("ItemName"):SetText(name)

				-- And the icon
				local itemData = Item.GetDataFromId(itemId)
				local icon = wnd:FindChild("ItemIcon")
				icon:SetSprite(itemData:GetIcon())
					
				-- And its tooltip
				icon:SetTooltipDoc(nil)
				local compare = itemData:GetEquippedItemForItemType()
				Tooltip.GetItemTooltipForm(self, icon, itemData,
					{bPrimary = true, bSelling = false, itemCompare = compare})
			end -- of loop through schematics in this skill
		else -- there are no schematics in this skill
			-- Create an empty entry
			local wnd = Apollo.LoadForm(self.xmlDoc, "NoSchematicKnown", recList, self)
		end -- of what to do if there are schematics in this skill
	end -- of if amps/crafting block
	
	-- And now arrange them in the list
	recList:ArrangeChildrenVert()
	
end

function Generalist:OnInterfaceMenuListHasLoaded()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "Generalist", 
		{"ToggleGeneralist", "", "GeneralistInterfaceSprite"})
end

---------------------------------------------------------------------------------------------------
-- The Search Function
---------------------------------------------------------------------------------------------------

function Generalist:GeneralistSearchSubmitted( wndHandler, wndControl, eMouseButton )

	-- Okay, this is gross.
	-- First, clear previous search results.
	--
	local resList = self.wndSearch:FindChild("ResultList")
	resList:DestroyChildren()
	
	-- Get the current character's faction
	local factID = GameLib.GetPlayerUnit():GetFaction()
	
	-- Build list of characters of this faction
	local a = {}
    for name in pairs(self.altData) do
		-- Only add characters of this faction to the list
		if self.altData[name].faction == factID then
			table.insert(a, name)
		end
	end
	
	-- Sort the list to make results a little saner to read.
	table.sort(a)
	
	-- Get the string we're searching for, and lowercase it.
	local needle = string.lower(self.wndSearch:FindChild("SearchField"):GetText())
	
	-- Now loop through all the characters of this faction.
	--
	for _,charName in ipairs(a) do
	
		-- The alt's inventory
		local theInv = self.altData[charName].inventory
		
		-- Inventory might be nil (unlikely but possible)
		
		if theInv ~= nil then
		
			-- Loop through the items
			--
			for id, info in pairs(theInv) do
		
				if string.find(string.lower(info.name),needle) ~= nil then
			
					-- We found it!  Create an entry as a child of the result list.
					local wnd = Apollo.LoadForm(self.xmlDoc, "SearchResult", resList, self)
					wnd:FindChild("ItemChar"):SetText(charName)
					wnd:FindChild("ItemName"):SetText(info.name)
					wnd:FindChild("ItemCount"):SetText(info.count)
					
					-- And the location
					if info.location == nil then
						wnd:FindChild("ItemPlace"):SetText("(Unknown)")
					else
						local locs = {}
						if bit32.band(4, info.location) == 4 then table.insert(locs,"Equipped") end
						if bit32.band(1, info.location) == 1 then table.insert(locs,"Inventory") end
						if bit32.band(2, info.location) == 2 then table.insert(locs,"Tradeskill") end
						local places = table.concat(locs,", ")
						wnd:FindChild("ItemPlace"):SetText(places)
					end
				
					-- And the icon
					local itemData = Item.GetDataFromId(id)
					local icon = wnd:FindChild("ItemIcon")
					icon:SetSprite(itemData:GetIcon())
					
					-- And its tooltip
					icon:SetTooltipDoc(nil)
					Tooltip.GetItemTooltipForm(self, icon, itemData, {bPrimary = true, bSelling = false})
			
				end -- of what to do if we find a match
		
			end -- of loop through items in the alt's inventory
			
		end -- of what to do if the alt has an inventory
	
	end -- of loop through alts
	
	-- now all the item are added, call ArrangeChildrenVert to list out the list items vertically
	resList:ArrangeChildrenVert()

end

-----------------------------------------------------------------------------------------------
-- Instantiation
-----------------------------------------------------------------------------------------------
local GeneralistInstance = Generalist:new()
GeneralistInstance:Init()