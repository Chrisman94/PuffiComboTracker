local ADDON, PCT = ...

local Display = { rows = {} }
PCT.Display = Display

local PADDING = 10
local TITLE_HEIGHT = 26
local ROW_GAP = 8
local LABEL_HEIGHT = 14

function Display:Create()
	if self.frame then return self.frame end

	local f = CreateFrame("Frame", "PuffiComboTrackerFrame", UIParent, "BackdropTemplate")
	f:SetSize(240, 120)
	f:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets = { left = 3, right = 3, top = 3, bottom = 3 },
	})
	f:SetBackdropColor(0, 0, 0, 0.55)
	f:SetBackdropBorderColor(0.35, 0.35, 0.35, 0.9)
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
	f:SetScript("OnHide", function() PCT.db.shown = false end)

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.title:SetPoint("TOPLEFT", PADDING, -8)
	f.title:SetText(PCT.title)

	f.close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	f.close:SetSize(22, 22)
	f.close:SetPoint("TOPRIGHT", -2, -2)
	f.close:SetScript("OnClick", function() f:Hide() end)

	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("TOPLEFT", PADDING, -TITLE_HEIGHT)
	f.hint:SetWidth(200)
	f.hint:SetJustifyH("LEFT")
	f.hint:SetText("Noch keine Kombo angelegt.\nRechtsklick oder /pct config zum Bearbeiten.")

	tinsert(UISpecialFrames, "PuffiComboTrackerFrame")

	self.frame = f
	return f
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
	local labelHeight = db.showLabels and LABEL_HEIGHT or 0
	local y = -TITLE_HEIGHT
	local contentWidth = f.title:GetStringWidth() + 26

	for index, combo in ipairs(db.combos) do
		local row = self:AcquireRow(index)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, y)

		row.label:SetText(combo.name or "")
		row.label:SetShown(db.showLabels)

		for slot = 1, combo.slots do
			local btn = row.slots[slot] or PCT.CreateSlotButton(row)
			row.slots[slot] = btn
			btn.comboIndex, btn.slotIndex = index, slot
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", row, "TOPLEFT", (slot - 1) * (size + spacing), -labelHeight)
			PCT.UpdateSlotButton(btn, combo.spells[slot], size)
			btn:Show()
		end
		for slot = combo.slots + 1, #row.slots do
			row.slots[slot]:Hide()
		end

		local rowWidth = combo.slots * (size + spacing) - spacing
		local rowHeight = labelHeight + size
		row:SetSize(rowWidth, rowHeight)
		row:Show()

		contentWidth = math.max(contentWidth, rowWidth, db.showLabels and row.label:GetStringWidth() or 0)
		y = y - rowHeight - ROW_GAP
	end

	for index = #db.combos + 1, #self.rows do
		self.rows[index]:Hide()
	end

	local hasCombos = #db.combos > 0
	f.hint:SetShown(not hasCombos)

	if hasCombos then
		f:SetSize(contentWidth + PADDING * 2, -y - ROW_GAP + PADDING)
	else
		f:SetSize(240, TITLE_HEIGHT + 40)
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
