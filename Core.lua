local ADDON, PCT = ...

PCT.addonName = ADDON
PCT.title = "Puffi Combo Tracker"
PCT.MIN_SLOTS = 1
PCT.MAX_SLOTS = 10

local defaults = {
	initialized = false,
	locked = false,
	shown = true,
	scale = 1,
	iconSize = 32,
	spacing = 4,
	showLabels = true,
	point = { "CENTER", "CENTER", 0, 120 },
	combos = {},
}

local function CopyDefaults(src, dst)
	for key, value in pairs(src) do
		if type(value) == "table" then
			if type(dst[key]) ~= "table" then
				dst[key] = {}
			end
			CopyDefaults(value, dst[key])
		elseif dst[key] == nil then
			dst[key] = value
		end
	end
	return dst
end

function PCT:Print(msg)
	print("|cff7ad0ff" .. self.title .. "|r: " .. tostring(msg))
end

-- Kombo-Verwaltung -----------------------------------------------------------

function PCT:AddCombo(name)
	local combo = {
		name = name or ("Kombo " .. (#self.db.combos + 1)),
		slots = 5,
		spells = {},
	}
	table.insert(self.db.combos, combo)
	self:Update()
	return combo
end

function PCT:RemoveCombo(index)
	if not self.db.combos[index] then return end
	table.remove(self.db.combos, index)
	self:Update()
end

function PCT:MoveCombo(index, offset)
	local combos = self.db.combos
	local target = index + offset
	if not combos[index] or not combos[target] then return end
	combos[index], combos[target] = combos[target], combos[index]
	self:Update()
end

function PCT:SetComboName(index, name)
	local combo = self.db.combos[index]
	if not combo then return end
	combo.name = name
	self:UpdateDisplay()
end

function PCT:SetSlotCount(index, count)
	local combo = self.db.combos[index]
	if not combo then return end
	count = math.max(self.MIN_SLOTS, math.min(self.MAX_SLOTS, count))
	for slot = count + 1, combo.slots do
		combo.spells[slot] = nil
	end
	combo.slots = count
	self:Update()
end

function PCT:SetSlot(comboIndex, slotIndex, spellID)
	local combo = self.db.combos[comboIndex]
	if not combo or not slotIndex or slotIndex > combo.slots then return end
	combo.spells[slotIndex] = spellID
	self:Update()
end

-- Aktualisierung -------------------------------------------------------------

function PCT:UpdateDisplay()
	if self.Display then
		self.Display:Refresh()
	end
end

function PCT:Update()
	self:UpdateDisplay()
	if self.Editor and self.Editor.frame and self.Editor.frame:IsShown() then
		self.Editor:Refresh()
	end
end

function PCT:ToggleLock()
	self.db.locked = not self.db.locked
	self:Print(self.db.locked and "Fenster gesperrt." or "Fenster entsperrt – Zauber können jetzt zugewiesen werden.")
	self:Update()
end

function PCT:Toggle()
	if not self.Display or not self.Display.frame then return end
	self.Display.frame:SetShown(not self.Display.frame:IsShown())
end

function PCT:ResetPosition()
	self.db.point = { "CENTER", "CENTER", 0, 120 }
	self.db.scale = 1
	if self.Display then
		self.Display:RestorePosition()
	end
	self:Print("Position zurückgesetzt.")
end

-- Laden ----------------------------------------------------------------------

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		PuffiComboTrackerDB = CopyDefaults(defaults, PuffiComboTrackerDB or {})
		PCT.db = PuffiComboTrackerDB
		if not PCT.db.initialized then
			PCT.db.initialized = true
			PCT:AddCombo("Meine Kombo")
		end
	elseif event == "PLAYER_LOGIN" then
		PCT.Display:Create()
		PCT.Display:RestorePosition()
		PCT.Display:Refresh()
		PCT.Display.frame:SetShown(PCT.db.shown)
	end
end)

-- Slash-Befehle --------------------------------------------------------------

SLASH_PUFFICOMBOTRACKER1 = "/pct"
SLASH_PUFFICOMBOTRACKER2 = "/puffi"
SlashCmdList.PUFFICOMBOTRACKER = function(input)
	local cmd = string.lower(strtrim(input or ""))
	if cmd == "config" or cmd == "edit" or cmd == "options" then
		PCT.Editor:Toggle()
	elseif cmd == "lock" or cmd == "unlock" then
		PCT:ToggleLock()
	elseif cmd == "reset" then
		PCT:ResetPosition()
	elseif cmd == "help" then
		PCT:Print("Befehle: /pct (Fenster an/aus), /pct config (Kombos bearbeiten), /pct lock (sperren/entsperren), /pct reset (Position).")
	else
		PCT:Toggle()
	end
end

function PuffiComboTracker_OnAddonCompartmentClick()
	PCT.Editor:Toggle()
end
