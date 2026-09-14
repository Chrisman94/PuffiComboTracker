# Puffi Combo Tracker

Ein leichtgewichtiges WoW-Retail-Addon, mit dem man sich eigene Kombos aus den
Fähigkeiten seiner Klasse zusammenstellt und diese in einem kompakten
Übersichtsfenster anzeigen lässt.

Rein visuell: das Addon merkt sich die Reihenfolge der Zauber, die man selbst
festgelegt hat. Es greift nicht in den Kampf ein, verfolgt keine Cooldowns und
schlägt nichts vor – es zeigt nur, was man sich als Kombo notiert hat.

## Funktionen

- Beliebig viele benannte Kombos mit je 1–10 Plätzen
- Zauber per Drag & Drop aus Zauberbuch oder Aktionsleiste auf einen Platz ziehen
- Kombos umbenennen, umsortieren und löschen
- Übersichtsfenster frei verschiebbar, sperrbar, Icon-Größe einstellbar
- Anordnung waagerecht (Kombo als Zeile) oder senkrecht (Kombo als Spalte)
- Einstellungen und Kombos werden pro Charakter gespeichert
- Keine Abhängigkeiten (kein Ace3, keine Libs)

## Installation

1. Repository herunterladen bzw. klonen.
2. Den Ordner `PuffiComboTracker` nach
   `World of Warcraft\_retail_\Interface\AddOns\` kopieren.
   Wichtig: der Ordnername muss exakt `PuffiComboTracker` heißen.
3. WoW neu starten bzw. `/reload`.

## Benutzung

| Befehl | Wirkung |
| --- | --- |
| `/pct` | Übersichtsfenster ein-/ausblenden |
| `/pct config` | Kombo-Editor öffnen |
| `/pct lock` | Fenster sperren/entsperren |
| `/pct vertical` | Zwischen waagerechter und senkrechter Anordnung wechseln |
| `/pct reset` | Fensterposition zurücksetzen |
| `/pct help` | Befehlsübersicht |

Der Editor ist auch per Rechtsklick auf das Übersichtsfenster oder über das
Addon-Menü (Zahnrad-Symbol an der Minimap) erreichbar.

**Zauber zuweisen:** Zauberbuch öffnen, Zauber auf einen leeren Platz ziehen.
Rechtsklick auf einen Platz leert ihn. Ein Zauber lässt sich aus einem Platz
herausziehen, um ihn woanders abzulegen. Ist das Fenster gesperrt, sind alle
Plätze schreibgeschützt und reagieren nur noch mit Tooltip.

## Dateien

| Datei | Inhalt |
| --- | --- |
| `Core.lua` | SavedVariables, Kombo-Verwaltung, Slash-Befehle |
| `SlotButton.lua` | Icon-Platz als Widget, Cursor-/Zauber-Erkennung |
| `Display.lua` | Übersichtsfenster |
| `Editor.lua` | Konfigurationsfenster |

## Hinweis zur Interface-Version

In der `.toc` steht `## Interface: 120100`. Passt das nicht zur installierten
Spielversion, zeigt WoW das Addon als veraltet an. Die korrekte Nummer liefert
im Spiel:

```
/dump (select(4, GetBuildInfo()))
```

## Lizenz

MIT – siehe [LICENSE](LICENSE).
