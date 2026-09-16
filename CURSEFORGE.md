# Puffi Combo Tracker

**Build your own ability combos and keep them on screen while you play.**

You know the feeling: a class you just picked up, or one you're dusting off
after months away, and the order of your abilities just won't stick. Puffi
Combo Tracker fixes that without being a rotation helper and without cooldown
clutter - you decide the order, the addon shows it back to you as a compact row
of icons. That's it.

---

## What it does

In the editor you drag spells from your spellbook onto slots, give the whole
thing a name ("Opener", "AoE", "Burst"), and get a small, freely placeable
window showing exactly those icons in exactly that order. As many combos as you
like, 1-10 slots each.

## What it deliberately does **not** do

So nobody installs it expecting the wrong thing:

* It **suggests nothing** and calculates nothing - this is not a rotation helper.
* It tracks **no cooldowns**, procs, resources or auras.
* It **does not interfere with combat** and casts nothing.
* The icons in the display window are **not clickable** - it is display only.

It's a cheat sheet, not an assistant. That's the whole point: no performance
cost, no hooks into the game, nothing that can break.

---

## Features

* **Any number of named combos**, 1-10 slots each
* **Drag & drop** from your spellbook or action bars straight into the editor
* **Keybinds on the icons** - if a spell sits on an action bar, its key is
  shown in the corner of the icon
* **Freely movable and lockable**, icon size adjustable from 20 to 64 pixels
* **Horizontal or vertical** - a combo as a row or as a column
* **"Icons only" mode** - no border, background, title or close button
* **"Always show" option** - the window can no longer be closed by accident and
  is back immediately after login
* **Empty slots are not drawn** - a combo with five slots and three spells is
  three icons long
* **Saved per character** - every alt has its own combos
* **No dependencies** - no Ace3, no libraries, ~1,100 lines of Lua

---

## Getting started

1. `/pct config` opens the editor.
2. Create a **new combo** and name it.
3. Open your spellbook (`P`) and drag spells onto the empty slots.

Done. The display window appears and can be dragged wherever you want it.

**Changing spells:** right-click a slot to clear it. A filled slot can be
dragged out and dropped elsewhere to reorder the combo.

The editor is also reachable by **right-clicking the display window** or via
the **addon menu on the minimap**.

---

## Slash commands

| Command | Effect |
| --- | --- |
| `/pct` | Show/hide the display window |
| `/pct config` | Open the combo editor |
| `/pct lock` | Lock/unlock the window |
| `/pct vertical` | Switch between horizontal and vertical layout |
| `/pct plain` | Toggle the window frame (icons only) |
| `/pct always` | Keep the window permanently visible (on/off) |
| `/pct keys` | Show/hide keybinds on the icons |
| `/pct reset` | Reset the window position |
| `/pct help` | Command overview |

Every option is available as a checkbox in the editor as well.

---

## Details that matter

### Keybinds

The key shown comes straight from your action bar buttons, so it is **exactly
what's written there**. It updates automatically when you rebind keys, page
your bars, or shapeshift. If a talent replaces your spell with a different
ability, that ability's bar slot is resolved too - so you see the key you
actually press.

> **Limitation:** only WoW's default bars are read (main bar plus the seven
> additional bars). If you've replaced your bars entirely with **Bartender4**
> or **ElvUI**, no keys will show - those addons manage their own bindings,
> which the game does not store in the default buttons. You can turn the
> display off with `/pct keys`.

### "Icons only" mode

Border, background, title and close button disappear; what's left are the bare
icons (plus combo names, if enabled). Ideal for a clean UI.

If the window is **locked** while in this mode, the invisible area stops
accepting mouse clicks, so it won't get in your way. To move it, `/pct lock`
first; to hide it, `/pct`.

### "Always show"

Removes the close button, stops ESC and `/pct` from hiding the window, and
brings it straight back after login. To hide it again, switch the option off
first via the checkbox or `/pct always`.

---

## Language

**English** and **German** - the addon switches automatically based on your
client language. All strings live in a single `Locale.lua`, so adding another
language is a matter of copying one block; pull requests are welcome.

## Feedback

Bugs, requests and ideas are welcome as an issue on
[GitHub](https://github.com/Chrisman94/PuffiComboTracker/issues) or as a
comment on this project page.

License: MIT
