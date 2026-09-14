local ADDON, PCT = ...

local Editor = { entries = {} }
PCT.Editor = Editor

local SLOT_SIZE = 32
local SLOT_GAP = 4
local ENTRY_WIDTH = 396
local ENTRY_HEIGHT = 74
local ENTRY_GAP = 4

local function CreateCheckbox(parent, label, x, y, onClick)
	local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	check:SetSize(24, 24)
	check:SetPoint("TOPLEFT", x, y)
	check.text = check:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	check.text:SetPoint("LEFT", check, "RIGHT", 2, 0)
	check.text:SetText(label)
	check:SetScript("OnClick", function(self)
		onClick(self:GetChecked() and true or false)
	end)
	return check
end

local function CreateSmallButton(parent, text, width)
	local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	btn:SetSize(width or 22, 20)
	btn:SetText(text)
	return btn
end

function Editor:Create()
	if self.frame then return self.frame end

	local f = CreateFrame("Frame", "PuffiComboTrackerEditor", UIParent, "BasicFrameTemplateWithInset")
	f:SetSize(460, 440)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:Hide()
	tinsert(UISpecialFrames, "PuffiComboTrackerEditor")

	f.heading = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.heading:SetPoint("TOP", 0, -5)
	f.heading:SetText(PCT.title)

	self.lockCheck = CreateCheckbox(f, "Fenster gesperrt", 12, -32, function(checked)
		PCT.db.locked = checked
		PCT:Update()
	end)

	self.labelCheck = CreateCheckbox(f, "Namen anzeigen", 170, -32, function(checked)
		PCT.db.showLabels = checked
		PCT:UpdateDisplay()
	end)

	self.verticalCheck = CreateCheckbox(f, "Senkrecht anordnen", 12, -58, function(checked)
		PCT.db.vertical = checked
		PCT:UpdateDisplay()
	end)

	local slider = CreateFrame("Slider", "PuffiComboTrackerSizeSlider", f, "OptionsSliderTemplate")
	slider:SetWidth(120)
	slider:SetPoint("TOPRIGHT", -24, -44)
	slider:SetMinMaxValues(20, 64)
	slider:SetValueStep(2)
	slider:SetObeyStepOnDrag(true)
	slider.lowText = slider.Low or _G["PuffiComboTrackerSizeSliderLow"]
	slider.highText = slider.High or _G["PuffiComboTrackerSizeSliderHigh"]
	slider.valueText = slider.Text or _G["PuffiComboTrackerSizeSliderText"]
	if slider.lowText then slider.lowText:SetText("20") end
	if slider.highText then slider.highText:SetText("64") end
	slider:SetScript("OnValueChanged", function(self, value)
		local size = math.floor(value + 0.5)
		if PCT.db.iconSize == size then return end
		PCT.db.iconSize = size
		if self.valueText then
			self.valueText:SetText("Icon-Größe: " .. size)
		end
		PCT:UpdateDisplay()
	end)
	self.sizeSlider = slider

	local addButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
	addButton:SetSize(120, 22)
	addButton:SetPoint("TOPLEFT", 14, -84)
	addButton:SetText("Neue Kombo")
	addButton:SetScript("OnClick", function() PCT:AddCombo() end)

	f.hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.hint:SetPoint("TOPLEFT", 140, -88)
	f.hint:SetWidth(300)
	f.hint:SetJustifyH("LEFT")
	f.hint:SetText("Zauber aus Zauberbuch oder Aktionsleiste auf einen Platz ziehen.\nRechtsklick leert einen Platz.")

	local scroll = CreateFrame("ScrollFrame", "PuffiComboTrackerEditorScroll", f, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 14, -118)
	scroll:SetPoint("BOTTOMRIGHT", -34, 14)

	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(ENTRY_WIDTH, 10)
	scroll:SetScrollChild(child)
	self.child = child

	self.frame = f
	return f
end

function Editor:AcquireEntry(index)
	local entry = self.entries[index]
	if entry then return entry end

	entry = CreateFrame("Frame", nil, self.child, "BackdropTemplate")
	entry:SetSize(ENTRY_WIDTH, ENTRY_HEIGHT)
	entry:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 10,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
	})
	entry:SetBackdropColor(1, 1, 1, 0.05)
	entry:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
	entry.slots = {}

	entry.nameBox = CreateFrame("EditBox", nil, entry, "InputBoxTemplate")
	entry.nameBox:SetSize(150, 20)
	entry.nameBox:SetPoint("TOPLEFT", 14, -8)
	entry.nameBox:SetAutoFocus(false)
	entry.nameBox:SetMaxLetters(40)
	entry.nameBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
	entry.nameBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
		Editor:Refresh()
	end)
	entry.nameBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then
			PCT:SetComboName(entry.comboIndex, self:GetText())
		end
	end)

	entry.countText = entry:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	entry.countText:SetPoint("LEFT", entry.nameBox, "RIGHT", 10, 0)

	entry.minus = CreateSmallButton(entry, "-")
	entry.minus:SetPoint("LEFT", entry.countText, "RIGHT", 8, 0)
	entry.minus:SetScript("OnClick", function()
		local combo = PCT.db.combos[entry.comboIndex]
		if combo then PCT:SetSlotCount(entry.comboIndex, combo.slots - 1) end
	end)

	entry.plus = CreateSmallButton(entry, "+")
	entry.plus:SetPoint("LEFT", entry.minus, "RIGHT", 2, 0)
	entry.plus:SetScript("OnClick", function()
		local combo = PCT.db.combos[entry.comboIndex]
		if combo then PCT:SetSlotCount(entry.comboIndex, combo.slots + 1) end
	end)

	entry.delete = CreateFrame("Button", nil, entry, "UIPanelCloseButton")
	entry.delete:SetSize(24, 24)
	entry.delete:SetPoint("TOPRIGHT", -4, -4)
	entry.delete:SetScript("OnClick", function()
		PCT:RemoveCombo(entry.comboIndex)
	end)

	entry.up = CreateSmallButton(entry, "|TInterface\\Buttons\\Arrow-Up-Up:12|t")
	entry.up:SetPoint("RIGHT", entry.delete, "LEFT", -2, 0)
	entry.up:SetScript("OnClick", function() PCT:MoveCombo(entry.comboIndex, -1) end)

	entry.down = CreateSmallButton(entry, "|TInterface\\Buttons\\Arrow-Down-Up:12|t")
	entry.down:SetPoint("RIGHT", entry.up, "LEFT", -2, 0)
	entry.down:SetScript("OnClick", function() PCT:MoveCombo(entry.comboIndex, 1) end)

	self.entries[index] = entry
	return entry
end

function Editor:Refresh()
	if not self.frame then return end

	local db = PCT.db
	self.lockCheck:SetChecked(db.locked)
	self.labelCheck:SetChecked(db.showLabels)
	self.verticalCheck:SetChecked(db.vertical)
	self.sizeSlider:SetValue(db.iconSize)
	if self.sizeSlider.valueText then
		self.sizeSlider.valueText:SetText("Icon-Größe: " .. db.iconSize)
	end

	local y = -ENTRY_GAP
	for index, combo in ipairs(db.combos) do
		local entry = self:AcquireEntry(index)
		entry.comboIndex = index
		entry:ClearAllPoints()
		entry:SetPoint("TOPLEFT", self.child, "TOPLEFT", 0, y)

		if not entry.nameBox:HasFocus() then
			entry.nameBox:SetText(combo.name or "")
		end
		entry.countText:SetText(combo.slots .. (combo.slots == 1 and " Platz" or " Plätze"))
		entry.minus:SetEnabled(combo.slots > PCT.MIN_SLOTS)
		entry.plus:SetEnabled(combo.slots < PCT.MAX_SLOTS)
		entry.up:SetEnabled(index > 1)
		entry.down:SetEnabled(index < #db.combos)

		for slot = 1, combo.slots do
			local btn = entry.slots[slot] or PCT.CreateSlotButton(entry, true)
			entry.slots[slot] = btn
			btn.comboIndex, btn.slotIndex = index, slot
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", entry, "TOPLEFT", 14 + (slot - 1) * (SLOT_SIZE + SLOT_GAP), -34)
			PCT.UpdateSlotButton(btn, combo.spells[slot], SLOT_SIZE)
			btn:Show()
		end
		for slot = combo.slots + 1, #entry.slots do
			entry.slots[slot]:Hide()
		end

		entry:Show()
		y = y - ENTRY_HEIGHT - ENTRY_GAP
	end

	for index = #db.combos + 1, #self.entries do
		self.entries[index]:Hide()
	end

	self.child:SetHeight(math.max(10, -y))
end

function Editor:Toggle()
	self:Create()
	if self.frame:IsShown() then
		self.frame:Hide()
	else
		self:Refresh()
		self.frame:Show()
	end
end
