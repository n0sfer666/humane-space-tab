# Using Humane Space Tab

[Русская версия](guide.ru.md)

The app has no window of its own to work in: it lives in the menu bar, and everything it
does happens while you hold a shortcut.

![The ribbon](images/ribbon.png)

## First run

1. Install it — `brew install --cask n0sfer/tap/humane-space-tab`, or open the disk
   image from Releases and drag **Humane Space Tab.app** onto the Applications
   shortcut — and launch it.
2. A downloaded build is refused the first time — open **System Settings → Privacy &
   Security**, scroll to the bottom and press **Open Anyway**, then launch it again.
3. The app asks for **Accessibility** as it starts. Grant it in **System Settings →
   Privacy & Security → Accessibility**. The switcher starts working within a couple of
   seconds; no relaunch is needed.

The menu bar icon is the only proof the app is running: `⇄` when it works, a warning
triangle when it cannot. macOS ties an Accessibility grant to the code signature, so the
grant has to be given again after every update.

## Switching between applications

Hold **⌘** and tap **Tab**. What you get depends on how long you hold it:

- **A quick tap** — under the reveal delay (120 ms by default) — switches to the previous
  application without showing anything, the way muscle memory expects.
- **Keep ⌘ down** and the ribbon appears with the applications of the **current Space**,
  most recently used first. Every further **Tab** moves the selection one step.

While the ribbon is open:

| Key | What it does |
|---|---|
| **Tab** | one step forward |
| **⇧Tab** | one step back |
| **Escape** | cancel — nothing is switched |
| release **⌘** | switch to the selected application |

The selected application is the icon that is bigger and brighter, with its name under it;
its neighbours are dimmed. From five applications on, the ribbon becomes a carousel: the
selection keeps its place and the icons turn under it, so a step is always the same
distance for the eye and the list has no ends — past the last application comes the first.
Below five, every icon keeps its place and only the selection moves. The panel stops
growing at ten slots.

## Switching between the windows of one application

Hold **⌘** and tap **`** (the key above Tab). The ribbon lists the windows of the
application in front — only the ones on the current Space, in stacking order, each with
its own title. The gesture is the same: `⇧` reverses, Escape cancels, releasing **⌘**
raises the window.

The system shortcut counts windows on every Space at once, which is how it throws you onto
another desk. This one cannot: a window that is not here is not in the list, so it never
switches Space and never un-minimises anything.

## The mouse

While the ribbon is open the pointer works on it:

- **move the mouse** over an icon to select it — a pointer that merely rests where the
  ribbon opened changes nothing until it moves;
- **click** an icon to switch to it immediately, without waiting for **⌘** to come up;
- **scroll** over the ribbon to step the selection.

## Settings

Open them from the menu bar icon → **Settings…**.

![Settings](images/settings.png)

| Setting | What it is |
|---|---|
| **Applications** | the shortcut that opens the ribbon. Click the field, type the combination, or press **Restore default** for `⌘Tab`. |
| **Windows of the front app** | the second shortcut, `` ⌘` `` by default. |
| **Show the ribbon on** | the screen with keyboard focus, or the screen the pointer is on. |
| **Reveal delay** | how long the shortcut must be held before the ribbon appears — 0 to 500 ms. At `0` it appears at once. |
| **Open at login** | registers the app with macOS as a login item. |
| **Switch between windows, not applications** | makes `⌘Tab` list windows, the way Windows and Linux do. Off by default: two documents of one editor are then two entries. |
| **Use the private Space layer** | the private layer knows which Space a minimised window belongs to, but it is undocumented. Off, the app uses on-screen windows only. |

A shortcut needs a modifier to hold, and the recorder refuses what the design cannot
honour — a combination without a modifier, one that already contains **⇧** (that is the
reverse direction), **Escape**, `⌘Q` and `⌘W` — and says which of those it was. The
shortcut is drawn with the keys of your current input source, so a Russian layout shows
`⌘Ё` where an English one shows `` ⌘` ``.

## The menu bar

| Item | When it is there |
|---|---|
| **Grant Accessibility…** | while the permission is missing — asks again |
| **Open Input Monitoring…** | when macOS is withholding key presses (see below) |
| **Settings…** | always |
| **Copy Inventory** | always — copies the current Space's application list to the clipboard, which is what to attach to a bug report |
| **Quit Humane Space Tab** | always |

## When something is wrong

**No icon in the menu bar.** A menu bar with no free slot left of the notch drops the
icon: macOS draws no status item it cannot fit, and nothing in the app can claim the
space. Free a slot, or open the app again from Finder or Spotlight — a second launch opens
Settings instead of a second copy.

**The icon says macOS is withholding key presses.** An old entry for the app is denying it
in **System Settings → Privacy & Security → Input Monitoring**. Remove that entry with
**−** — the app does not need the permission, only the absence of a refusal — and click
back into the app; the tap is rebuilt without a relaunch.

**`⌘Tab` is still the system switcher.** The Accessibility grant is missing or belongs to
the previous build. Use **Grant Accessibility…**, and if the list already has an entry for
the app, remove it with **−** and grant it again.

**"Open at login" does not stick.** If macOS refuses the registration it says so under the
checkbox, in its own words. The usual reason is a build the system does not recognise:
every local build carries its own ad-hoc signature, so a registration made by yesterday's
copy does not belong to today's. Turn it off and on again on the copy that is in
`/Applications`.

## What the app can see

It holds Accessibility, which is broad, and deliberately does very little with it: no
network code at all, no AppleEvents, no plugins; keystrokes are inspected only to match
your shortcut; window titles are read only while window switching is on and only to be
drawn; the pointer is seen only over the ribbon's own panel. It never asks for Screen
Recording, which is why it shows no window previews. The full threat model is
[S00](specs/S00-threat-model.md).
