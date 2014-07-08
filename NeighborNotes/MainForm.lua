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
		self.wndMain:FindChild("AccountWideCheckbox"):SetCheck(self.tCharacter.tFilters.bShowAllCharacters)
		self.wndMain:FindChild("TradeSkillCheckbox"):SetCheck(self.tCharacter.tFilters.bHarvestable)

		-- Set the default sort
		self.wndMain:FindChild("Label_Friend"):SetCheck(false)
		self:OnNeighborSortToggle(self.wndMain:FindChild("Label_Friend"))

		
		-------------------------------------------------------------------------------------------------
		-- CAN PROBABLY REMOVE THIS
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

--------------------------------------------------------------------------------------------------------
-- Form Events
--------------------------------------------------------------------------------------------------------
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

-- When one of the table headers is clicked, this sets up the sort and calls RefreshList()
function NeighborNotes:OnNeighborSortToggle( wndHandler, wndControl, eMouseButton )
	
	-- If the string is blank, assign it "zzzzz" so that it sorts under non-blank strings 
	function SWeight(strNote)
		if strNote == "" then
			return "zzzzz"
		end
		return strNote
	end
	
	-- if the number is nil, assign it 0 so that it doesn't break the sort
	function NWeight(nNumber)
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
			self.fnSort = function(a,b) return (NWeight(a.nNodeID) > NWeight(b.nNodeID)) end
		else
			self.fnSort = function(a,b) return (NWeight(a.nNodeID) < NWeight(b.nNodeID)) end
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
			self.fnSort = function(a,b) return (SWeight(a.strNote) < SWeight(b.strNote)) end
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

	if not self.wndMain then
		self:Initialize()
		self:RefreshList()
	end	
	if self.tCharacter.bOnVisitSelectNext == true then
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
	local tCurr = self.wndMain:FindChild("VisitBtn"):GetData()
	if tCurr ~= nil then
		Apollo.StopTimer("NNLoadDelay")
		self.tQueuedUnits = {}
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
	self.tCharacter.tFilters.bHarvestable = wndControl:IsChecked()
	wndControl:GetParent():Show(false)
	self:RefreshList()
end

function NeighborNotes:OnAccountWideCheckBox( wndHandler, wndControl, eMouseButton )
	self.tCharacter.tFilters.bShowAllCharacters = wndControl:IsChecked()
	wndControl:GetParent():Show(false)
	self:RefreshList()
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
		self.wndConfig = Apollo.LoadForm(self.xmlConfig, "ConfigWindow", nil, self)
	end
	local wndContent = self.wndConfig:FindChild("ContentMain")
	wndContent:FindChild("CheckboxOpenWithSocial"):SetCheck(self.tCharacter.bOpenWithSocial)
	wndContent:FindChild("CheckboxCloseWithSocial"):SetCheck(self.tCharacter.bCloseWithSocial)
	wndContent:FindChild("CheckboxShowAllNeighbors"):SetCheck(self.tCharacter.tFilters.bShowAllCharacters)
	wndContent:FindChild("CheckboxShowHarvestable"):SetCheck(self.tCharacter.tFilters.bHarvestable)
	wndContent:FindChild("CheckboxVisitNext"):SetCheck(self.tCharacter.bOnVisitSelectNext)
	self.wndConfig:Show(true)
	self.wndConfig:ToFront()
end

function NeighborNotes:OnVisitRandomBtn( wndHandler, wndControl, eMouseButton )
	Event_FireGenericEvent("HousingRandomResidenceListReceived", self.wndMain, nil)
end

function NeighborNotes:OnTheVisitorBtn( wndHandler, wndControl, eMouseButton )
	Apollo.ParseInput("/visit")	
end

