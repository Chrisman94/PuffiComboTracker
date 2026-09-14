local ADDON, PCT = ...

-- Zauber-Infos möglichst versionsunabhängig holen.
function PCT.GetSpellData(spellID)
	if type(spellID) ~= "number" then return nil end
	if C_Spell and C_Spell.GetSpellInfo then
		local info = C_Spell.GetSpellInfo(spellID)
		if info and info.name then
			return info.name, info.iconID or (C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(spellID))
		end
	elseif GetSpellInfo then
		local name, _, icon = GetSpellInfo(spellID)
		if name then
			return name, icon
		end
	end
	return nil
end

-- Was hängt am Mauszeiger? Zauberbuch und Aktionsleisten liefern
-- je nach Client unterschiedliche Rückgabewerte, daher alle prüfen.
function PCT.GetCursorSpellID()
	local cursorType, info1, info2, info3 = GetCursorInfo()
	if cursorType == "spell" then
		local candidates = { info3, info2, info1 }
		for i = 1, 3 do
			local value = candidates[i]
			if type(value) == "number" and PCT.GetSpellData(value) then
				return value
			end
		end
	elseif cursorType == "action" and info1 then
		local actionType, id = GetActionInfo(info1)
		if actionType == "spell" and PCT.GetSpellData(id) then
			return id
		elseif actionType == "macro" and GetMacroSpell then
			local spellID = GetMacroSpell(id)
			if PCT.GetSpellData(spellID) then
				return spellID
			end
		end
	end
	return nil
end

function PCT.TryAssignFromCursor(btn)
	if PCT.db.locked then return false end
	local spellID = PCT.GetCursorSpellID()
	if not spellID then return false end
	PCT:SetSlot(btn.comboIndex, btn.slotIndex, spellID)
	ClearCursor()
	return true
end

local function PickupSpell(spellID)
	if C_Spell and C_Spell.PickupSpell then
		C_Spell.PickupSpell(spellID)
	elseif _G.PickupSpell then
		_G.PickupSpell(spellID)
	end
end

function PCT.CreateSlotButton(parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	btn:RegisterForDrag("LeftButton")

	btn.bg = btn:CreateTexture(nil, "BACKGROUND")
	btn.bg:SetAllPoints()
	btn.bg:SetColorTexture(0, 0, 0, 0.85)

	btn.icon = btn:CreateTexture(nil, "ARTWORK")
	btn.icon:SetPoint("TOPLEFT", 1, -1)
	btn.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	btn.plus = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	btn.plus:SetPoint("CENTER")
	btn.plus:SetText("+")
	btn.plus:SetTextColor(0.55, 0.55, 0.55)

	btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
	btn.highlight:SetAllPoints()
	btn.highlight:SetColorTexture(1, 1, 1, 0.12)

	btn:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.spellID then
			GameTooltip:SetSpellByID(self.spellID)
			if not PCT.db.locked then
				GameTooltip:AddLine("Rechtsklick: Platz leeren", 0.6, 0.6, 0.6)
			end
		else
			GameTooltip:SetText(PCT.db.locked and "Leerer Platz" or "Zauber hierher ziehen", 1, 1, 1)
		end
		GameTooltip:Show()
	end)

	btn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	btn:SetScript("OnReceiveDrag", function(self)
		PCT.TryAssignFromCursor(self)
	end)

	btn:SetScript("OnClick", function(self, button)
		if button == "RightButton" then
			if not PCT.db.locked then
				PCT:SetSlot(self.comboIndex, self.slotIndex, nil)
			end
			return
		end
		PCT.TryAssignFromCursor(self)
	end)

	-- Zauber aus einem Platz herausziehen (zum Umsortieren).
	btn:SetScript("OnDragStart", function(self)
		if PCT.db.locked or not self.spellID then return end
		PickupSpell(self.spellID)
		PCT:SetSlot(self.comboIndex, self.slotIndex, nil)
	end)

	return btn
end

function PCT.UpdateSlotButton(btn, spellID, size)
	btn:SetSize(size, size)
	local name, icon = PCT.GetSpellData(spellID)
	btn.spellID = name and spellID or nil
	btn.spellName = name
	if icon then
		btn.icon:SetTexture(icon)
		btn.plus:Hide()
	else
		btn.icon:SetColorTexture(0.12, 0.12, 0.12, 0.9)
		btn.plus:SetShown(not PCT.db.locked)
	end
end
