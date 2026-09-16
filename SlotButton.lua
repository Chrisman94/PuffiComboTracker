local ADDON, PCT = ...
local L = PCT.L

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
	if not btn.editable then return false end
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

-- editable = true nur im Editor; im Anzeigefenster sind die Plätze
-- schreibgeschützt und zeigen keine Platzhalter.
function PCT.CreateSlotButton(parent, editable)
	local btn = CreateFrame("Button", nil, parent)
	btn.editable = editable and true or false
	btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	btn:RegisterForDrag("LeftButton")

	btn.bg = btn:CreateTexture(nil, "BACKGROUND")
	btn.bg:SetAllPoints()
	btn.bg:SetColorTexture(0, 0, 0, 0.85)

	btn.icon = btn:CreateTexture(nil, "ARTWORK")
	btn.icon:SetPoint("TOPLEFT", 1, -1)
	btn.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	-- Tastenbelegung in der oberen Ecke; Schatten statt Umriss-Font,
	-- damit der Text auch auf hellen Icons lesbar bleibt.
	btn.hotkey = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
	btn.hotkey:SetPoint("TOPRIGHT", -1, -2)
	btn.hotkey:SetJustifyH("RIGHT")
	btn.hotkey:SetShadowColor(0, 0, 0, 1)
	btn.hotkey:SetShadowOffset(1, -1)
	btn.hotkey:Hide()

	btn.plus = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	btn.plus:SetPoint("CENTER")
	btn.plus:SetText("+")
	btn.plus:SetTextColor(0.55, 0.55, 0.55)
	btn.plus:Hide()

	if btn.editable then
		btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
		btn.highlight:SetAllPoints()
		btn.highlight:SetColorTexture(1, 1, 1, 0.12)
	end

	btn:SetScript("OnEnter", function(self)
		if not self.spellID and not self.editable then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if self.spellID then
			GameTooltip:SetSpellByID(self.spellID)
			if self.editable then
				GameTooltip:AddLine(L.TOOLTIP_CLEAR, 0.6, 0.6, 0.6)
			end
		else
			GameTooltip:SetText(L.TOOLTIP_DRAG, 1, 1, 1)
		end
		GameTooltip:Show()
	end)

	btn:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	if btn.editable then
		btn:SetScript("OnReceiveDrag", function(self)
			PCT.TryAssignFromCursor(self)
		end)

		btn:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				PCT:SetSlot(self.comboIndex, self.slotIndex, nil)
				return
			end
			PCT.TryAssignFromCursor(self)
		end)

		-- Zauber aus einem Platz herausziehen (zum Umsortieren).
		btn:SetScript("OnDragStart", function(self)
			if not self.spellID then return end
			PickupSpell(self.spellID)
			PCT:SetSlot(self.comboIndex, self.slotIndex, nil)
		end)
	end

	return btn
end

function PCT.UpdateSlotButton(btn, spellID, size, hotkey)
	btn:SetSize(size, size)
	local name, icon = PCT.GetSpellData(spellID)
	btn.spellID = name and spellID or nil
	btn.spellName = name
	if icon then
		btn.icon:SetTexture(icon)
		btn.plus:Hide()
	else
		btn.icon:SetColorTexture(0.12, 0.12, 0.12, 0.9)
		btn.plus:SetShown(btn.editable)
	end

	if btn.spellID and hotkey and hotkey ~= "" then
		btn.hotkey:SetText(hotkey)
		btn.hotkey:Show()
	else
		btn.hotkey:Hide()
	end
end
