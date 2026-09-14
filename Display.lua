local ADDON, PCT = ...

local Display = { rows = {} }
PCT.Display = Display

local PADDING = 10
local TITLE_HEIGHT = 26
local GROUP_GAP = 8
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
	local vertical = db.vertical and true or false
	local labelHeight = db.showLabels and LABEL_HEIGHT or 0

	-- Waagerecht: jede Kombo eine Zeile, Kombos untereinander.
	-- Senkrecht: jede Kombo eine Spalte, Kombos nebeneinander.
	local x, y = PADDING, -TITLE_HEIGHT
	local sumWidth, sumHeight = 0, 0
	local maxWidth, maxHeight = 0, 0

	for index, combo in ipairs(db.combos) do
		local group = self:AcquireRow(index)
		group:ClearAllPoints()
		group:SetPoint("TOPLEFT", f, "TOPLEFT", x, y)

		group.label:SetText(combo.name or "")
		group.label:SetShown(db.showLabels)

		for slot = 1, combo.slots do
			local btn = group.slots[slot] or PCT.CreateSlotButton(group, false)
			group.slots[slot] = btn
			btn.comboIndex, btn.slotIndex = index, slot
			btn:ClearAllPoints()
			if vertical then
				btn:SetPoint("TOPLEFT", group, "TOPLEFT", 0, -labelHeight - (slot - 1) * (size + spacing))
			else
				btn:SetPoint("TOPLEFT", group, "TOPLEFT", (slot - 1) * (size + spacing), -labelHeight)
			end
			PCT.UpdateSlotButton(btn, combo.spells[slot], size)
			btn:Show()
		end
		for slot = combo.slots + 1, #group.slots do
			group.slots[slot]:Hide()
		end

		local labelWidth = db.showLabels and group.label:GetStringWidth() or 0
		local strip = combo.slots * (size + spacing) - spacing
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

	for index = #db.combos + 1, #self.rows do
		self.rows[index]:Hide()
	end

	local hasCombos = #db.combos > 0
	f.hint:SetShown(not hasCombos)

	if hasCombos then
		local contentWidth = vertical and (sumWidth - GROUP_GAP) or maxWidth
		local contentHeight = vertical and maxHeight or (sumHeight - GROUP_GAP)
		contentWidth = math.max(contentWidth, f.title:GetStringWidth() + 26)
		f:SetSize(contentWidth + PADDING * 2, TITLE_HEIGHT + contentHeight + PADDING)
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
