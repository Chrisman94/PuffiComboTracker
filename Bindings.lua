local ADDON, PCT = ...

-- Tastenbelegung zu einem Zauber finden.
--
-- Blizzard schreibt in jeden Aktionsleisten-Knopf bereits die gekürzte
-- Tastenbezeichnung ("S1", "A-3"). Statt die Belegung selbst aus GetBindingKey
-- zusammenzusetzen und abzukürzen, laufen wir also die Knöpfe ab, schauen nach,
-- welcher Zauber auf dem zugehörigen Platz liegt, und übernehmen den Text.
-- Das erspart eine eigene Abkürzungslogik und stimmt immer mit dem überein,
-- was auf der Leiste steht.
local BUTTON_PREFIXES = {
	"ActionButton",             -- Hauptleiste (blättert mit Seite/Gestalt mit)
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarRightButton",
	"MultiBarLeftButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
}

local map = {}
local dirty = true

local function SpellOnSlot(slot)
	local actionType, id = GetActionInfo(slot)
	if actionType == "spell" then
		return id
	elseif actionType == "macro" and GetMacroSpell then
		return GetMacroSpell(id)
	end
	return nil
end

local function Rebuild()
	wipe(map)
	for _, prefix in ipairs(BUTTON_PREFIXES) do
		for index = 1, 12 do
			local button = _G[prefix .. index]
			if button then
				local slot = button.action
				if not slot and button.GetAttribute then
					slot = button:GetAttribute("action")
				end
				local hotkey = button.HotKey and button.HotKey:GetText()
				-- Leerer Text = nichts belegt; RANGE_INDICATOR ist der Punkt,
				-- den Blizzard anstelle einer Taste anzeigt.
				if slot and hotkey and hotkey ~= "" and hotkey ~= RANGE_INDICATOR then
					local spellID = SpellOnSlot(slot)
					if spellID and not map[spellID] then
						map[spellID] = hotkey
					end
				end
			end
		end
	end
	dirty = false
end

-- Talente ersetzen Zauber teilweise durch andere IDs. Liegt der gespeicherte
-- Zauber nicht auf der Leiste, prüfen wir zusätzlich seine Ersetzung.
local function OverrideOf(spellID)
	if C_Spell and C_Spell.GetOverrideSpell then
		return C_Spell.GetOverrideSpell(spellID)
	elseif FindSpellOverrideByID then
		return FindSpellOverrideByID(spellID)
	end
	return nil
end

function PCT.GetHotkey(spellID)
	if type(spellID) ~= "number" then return nil end
	if dirty then Rebuild() end

	local key = map[spellID]
	if key then return key end

	local override = OverrideOf(spellID)
	if override and override ~= spellID then
		return map[override]
	end
	return nil
end

-- Neu einlesen, wenn sich Belegung, Leisteninhalt oder Seite ändert.
-- Die Ereignisse kommen beim Anmelden im Schwung, deshalb wird das
-- Aktualisieren kurz gesammelt statt jedes Mal einzeln ausgelöst.
local watcher = CreateFrame("Frame")
local pending = false

for _, event in ipairs({
	"UPDATE_BINDINGS",
	"ACTIONBAR_SLOT_CHANGED",
	"ACTIONBAR_PAGE_CHANGED",
	"UPDATE_BONUS_ACTIONBAR",
	"UPDATE_SHAPESHIFT_FORM",
	"PLAYER_ENTERING_WORLD",
}) do
	watcher:RegisterEvent(event)
end

watcher:SetScript("OnEvent", function()
	dirty = true
	if pending then return end
	pending = true
	C_Timer.After(0.2, function()
		pending = false
		if PCT.db and PCT.db.showBinds then
			PCT:UpdateDisplay()
		end
	end)
end)
