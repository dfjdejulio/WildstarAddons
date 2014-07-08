---------------------------------------------------------------------------------------------------
-- ConfigWindow Functions
---------------------------------------------------------------------------------------------------

function NeighborNotes:OnConfigOK( wndHandler, wndControl, eMouseButton)
	local wndContent = wndControl:GetParent():FindChild("ContentMain")
	self.tCharacter.bOpenWithSocial = wndContent:FindChild("CheckboxOpenWithSocial"):IsChecked()
	self.tCharacter.bCloseWithSocial = wndContent:FindChild("CheckboxCloseWithSocial"):IsChecked()
	self.tCharacter.tFilters.bShowAllCharacters = wndContent:FindChild("CheckboxShowAllNeighbors"):IsChecked()
	self.tCharacter.tFilters.bHarvestable = wndContent:FindChild("CheckboxShowHarvestable"):IsChecked()
	self.tCharacter.bOnVisitSelectNext = wndContent:FindChild("CheckboxVisitNext"):IsChecked()
	self.wndConfig:Close()
	self:RefreshList()
end

function NeighborNotes:OnConfigCancel( wndHandler, wndControl, eMouseButton )
	self.wndConfig:Close()
end
