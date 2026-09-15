local ADDON, PCT = ...

local Display = { rows = {} }
PCT.Display = Display

local PADDING = 10
local TITLE_HEIGHT = 26
local GROUP_GAP = 8
local LABEL_HEIGHT = 14

-- ESC schließt das Fenster nur, solange es ausgeblendet werden darf.
local function SetEscapeClose(enabled)
	for i = #UISpecialFrames, 1, -1 do
		if UISpecialFrames[i] == "PuffiComboTrackerFrame" then
			tremove(UISpecialFrames, i)
		end
	end
	if enabled then
		tinsert(UISpecialFrames, "PuffiComboTrackerFrame")
	end
end

local BACKDROP = {
	bgFile = "Interface\\Buttons\\WHITE8X8",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 12,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

function Display:Create()
	if self.frame then return self.frame end

	local f = CreateFrame("Frame", "PuffiComboTrackerFrame", UIParent, "BackdropTemplate")
	f:SetSize(240, 120)
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")

	f:SetScript("OnDragStart", function(self)
		if not PCT.db.locked then
			self:StartMoving()
		end
	end)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		Display:SavePosition()
	end)
	f:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" then
			PCT.Editor:Toggle()
		end
	end)
	f:SetScript("OnShow", function() PCT.db.shown = true end)
	f:SetScript("OnHide", function(self)
		if PCT.db.alwaysShow then
			self:Show()
			return
		end
		PCT.db.shown = false
	end)

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.title:SetPoint("TOPLEFT", PADDING, -8)
	f.title:SetText(PCT.title)

	f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.close:SetSize(22, 22)
	f.close:SetPoint("TOPRIGHT", -2, -2)
	f.close:SetScript("OnClick", function() f:Hide() end)

	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetWidth(210)
	f.hint:SetJustifyH("LEFT")

	self.frame = f
	return f
end

-- Rahmenloser Modus: nur die Icons, kein Hintergrund, kein Titel.
-- Im gesperrten Zustand nimmt das Fenster dann auch keine Mausklicks mehr an,
-- damit die unsichtbare Fläche nichts blockiert.
function Display:ApplyStyle()
	local f = self.frame
	if not f then return end

	local always = PCT.db.alwaysShow and true or false

	if PCT.db.plain then
		f:SetBackdrop(nil)
		f.title:Hide()
		f.close:Hide()
		f:EnableMouse(not PCT.db.locked)
	else
		f:SetBackdrop(BACKDROP)
		f:SetBackdropColor(0, 0, 0, 0.55)
		f:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.9)
		f.title:Show()
		f.close:SetShown(not always)
		f:EnableMouse(true)
	end

	SetEscapeClose(not always)
end

function Display:AcquireRow(index)
	local row = self.rows[index]
	if row then return row end

	row = CreateFrame("Frame", nil, self.frame)
	row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	row.label:SetPoint("TOPLEFT")
	row.label:SetJustifyH("LEFT")
	row.slots = {}
	self.rows[index] = row
	return row
end

function Display:Refresh()
	local f = self.frame
	if not f then return end

	local db = PCT.db
	local size, spacing = db.iconSize, db.spacing
	local vertical = db.vertical and true or false
	local plain = db.plain and true or false
	local labelHeight = db.showLabels and LABEL_HEIGHT or 0
	local showBinds = db.showBinds and true or false
	local padding = plain and 0 or PADDING
	local top = plain and 0 or TITLE_HEIGHT

	self:ApplyStyle()

	-- Waagerecht: jede Kombo eine Zeile, Kombos untereinander.
	-- Senkrecht: jede Kombo eine Spalte, Kombos nebeneinander.
	local x, y = padding, -top
	local sumWidth, sumHeight = 0, 0
	local maxWidth, maxHeight = 0, 0
	local visibleGroups = 0

	for index, combo in ipairs(db.combos) do
		local group = self:AcquireRow(index)

		-- Nur belegte Plätze anzeigen, lückenlos aneinandergereiht.
		local filled = 0
		for slot = 1, combo.slots do
			local spellID = combo.spells[slot]
			if PCT.GetSpellData(spellID) then
				filled = filled + 1
				local btn = group.slots[filled] or PCT.CreateSlotButton(group, false)
				group.slots[filled] = btn
				btn.comboIndex, btn.slotIndex = index, slot
				btn:ClearAllPoints()
				if vertical then
					btn:SetPoint("TOPLEFT", group, "TOPLEFT", 0, -labelHeight - (filled - 1) * (size + spacing))
				else
					btn:SetPoint("TOPLEFT", group, "TOPLEFT", (filled - 1) * (size + spacing), -labelHeight)
				end
				PCT.UpdateSlotButton(btn, spellID, size, showBinds and PCT.GetHotkey(spellID) or nil)
				btn:Show()
			end
		end
		for slot = filled + 1, #group.slots do
			group.slots[slot]:Hide()
		end

		if filled == 0 then
			group:Hide()
		else
			visibleGroups = visibleGroups + 1
			group:ClearAllPoints()
			group:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)

			group.label:SetText(combo.name or "")
			group.label:SetShown(db.showLabels)

			local labelWidth = db.showLabels and group.label:GetStringWidth() or 0
			local strip = filled * (size + spacing) - spacing
			local width, height
			if vertical then
				width = math.max(size, labelWidth)
				height = labelHeight + strip
			else
				width = math.max(strip, labelWidth)
				height = labelHeight + size
			end
			group:SetSize(width, height)
			group:Show()

			sumWidth = sumWidth + width + GROUP_GAP
			sumHeight = sumHeight + height + GROUP_GAP
			maxWidth = math.max(maxWidth, width)
			maxHeight = math.max(maxHeight, height)

			if vertical then
				x = x + width + GROUP_GAP
			else
				y = y - height - GROUP_GAP
			end
		end
	end

	for index = #db.combos + 1, #self.rows do
		self.rows[index]:Hide()
	end

	if visibleGroups > 0 then
		f.hint:Hide()
		local contentWidth = vertical and (sumWidth - GROUP_GAP) or maxWidth
		local contentHeight = vertical and maxHeight or (sumHeight - GROUP_GAP)
		if not plain then
			contentWidth = math.max(contentWidth, f.title:GetStringWidth() + 26)
		end
		f:SetSize(contentWidth + padding * 2, top + contentHeight + padding)
	else
		f.hint:ClearAllPoints()
		f.hint:SetPoint("TOPLEFT", f, "TOPLEFT", padding, -top)
		f.hint:SetText(#db.combos == 0
			and "Noch keine Kombo angelegt.\nRechtsklick oder /pct config zum Bearbeiten."
			or "Kombo noch ohne Zauber.\nRechtsklick oder /pct config zum Bearbeiten.")
		f.hint:Show()
		f:SetSize(230, top + 40)
	end
	f:SetScale(db.scale or 1)
end

function Display:SavePosition()
	local point, _, relativePoint, x, y = self.frame:GetPoint(1)
	PCT.db.point = { point, relativePoint, x, y }
end

function Display:RestorePosition()
	local p = PCT.db.point
	self.frame:ClearAllPoints()
	self.frame:SetPoint(p[1] or "CENTER", UIParent, p[2] or "CENTER", p[3] or 0, p[4] or 0)
	self.frame:SetScale(PCT.db.scale or 1)
end
