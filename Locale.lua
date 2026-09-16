local ADDON, PCT = ...

-- Englisch ist der Standard; passende Clients ueberschreiben unten.
-- Neue Sprache: Block nach demselben Muster ergaenzen.
local L = {
	COMBO_PREFIX          = "Combo ",
	DEFAULT_COMBO_NAME    = "My Combo",

	MSG_LOCKED            = "Window locked - cannot be moved.",
	MSG_UNLOCKED          = "Window unlocked - movable.",
	MSG_VERTICAL          = "Vertical layout.",
	MSG_HORIZONTAL        = "Horizontal layout.",
	MSG_PLAIN_ON          = "Icons only, no frame.",
	MSG_PLAIN_OFF         = "Frame turned back on.",
	MSG_ALWAYS_ON         = "Window stays visible at all times.",
	MSG_ALWAYS_OFF        = "Window can be hidden again.",
	MSG_BINDS_ON          = "Keybinds are shown.",
	MSG_BINDS_OFF         = "Keybinds hidden.",
	MSG_ALWAYS_BLOCKED    = "Window is set to \"always show\" - use /pct always first.",
	MSG_POSITION_RESET    = "Position reset.",
	MSG_HELP              = "Commands: /pct (toggle window), /pct config (edit combos), /pct lock (lock/unlock), /pct vertical (layout), /pct plain (frame on/off), /pct always (always show), /pct keys (keybinds), /pct reset (position).",

	DISPLAY_NO_COMBO      = "No combo created yet.\nRight-click or /pct config to edit.",
	DISPLAY_EMPTY_COMBO   = "Combo has no spells yet.\nRight-click or /pct config to edit.",

	CHECK_LOCKED          = "Window locked",
	CHECK_LABELS          = "Show names",
	CHECK_VERTICAL        = "Vertical layout",
	CHECK_PLAIN           = "Icons only",
	CHECK_ALWAYS          = "Always show",
	CHECK_BINDS           = "Show keybinds",
	ICON_SIZE             = "Icon size: ",
	BUTTON_NEW_COMBO      = "New combo",
	EDITOR_HINT           = "Drag spells from your spellbook or action bars onto a slot.\nRight-click clears a slot.",
	SLOT_SINGULAR         = " slot",
	SLOT_PLURAL           = " slots",

	TOOLTIP_CLEAR         = "Right-click: clear slot",
	TOOLTIP_DRAG          = "Drag a spell here",
}

if GetLocale() == "deDE" then
	L.COMBO_PREFIX        = "Kombo "
	L.DEFAULT_COMBO_NAME  = "Meine Kombo"

	L.MSG_LOCKED          = "Fenster gesperrt – nicht verschiebbar."
	L.MSG_UNLOCKED        = "Fenster entsperrt – verschiebbar."
	L.MSG_VERTICAL        = "Senkrechte Anordnung."
	L.MSG_HORIZONTAL      = "Waagerechte Anordnung."
	L.MSG_PLAIN_ON        = "Nur Icons, ohne Rahmen."
	L.MSG_PLAIN_OFF       = "Rahmen wieder eingeschaltet."
	L.MSG_ALWAYS_ON       = "Fenster bleibt immer sichtbar."
	L.MSG_ALWAYS_OFF      = "Fenster kann wieder ausgeblendet werden."
	L.MSG_BINDS_ON        = "Tastenbelegung wird angezeigt."
	L.MSG_BINDS_OFF       = "Tastenbelegung ausgeblendet."
	L.MSG_ALWAYS_BLOCKED  = "Fenster ist auf \"immer anzeigen\" gestellt – zuerst /pct always."
	L.MSG_POSITION_RESET  = "Position zurückgesetzt."
	L.MSG_HELP            = "Befehle: /pct (Fenster an/aus), /pct config (Kombos bearbeiten), /pct lock (sperren/entsperren), /pct vertical (Anordnung), /pct plain (Rahmen an/aus), /pct always (immer anzeigen), /pct keys (Tastenbelegung), /pct reset (Position)."

	L.DISPLAY_NO_COMBO    = "Noch keine Kombo angelegt.\nRechtsklick oder /pct config zum Bearbeiten."
	L.DISPLAY_EMPTY_COMBO = "Kombo noch ohne Zauber.\nRechtsklick oder /pct config zum Bearbeiten."

	L.CHECK_LOCKED        = "Fenster gesperrt"
	L.CHECK_LABELS        = "Namen anzeigen"
	L.CHECK_VERTICAL      = "Senkrecht anordnen"
	L.CHECK_PLAIN         = "Nur Icons"
	L.CHECK_ALWAYS        = "Immer anzeigen"
	L.CHECK_BINDS         = "Tasten anzeigen"
	L.ICON_SIZE           = "Icon-Größe: "
	L.BUTTON_NEW_COMBO    = "Neue Kombo"
	L.EDITOR_HINT         = "Zauber aus Zauberbuch oder Aktionsleiste auf einen Platz ziehen.\nRechtsklick leert einen Platz."
	L.SLOT_SINGULAR       = " Platz"
	L.SLOT_PLURAL         = " Plätze"

	L.TOOLTIP_CLEAR       = "Rechtsklick: Platz leeren"
	L.TOOLTIP_DRAG        = "Zauber hierher ziehen"
end

PCT.L = L
