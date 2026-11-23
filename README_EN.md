# M-Audio Code 25 — Remote Codec & Mapping for Reason

Custom **Lua Remote** control surface codec and mapping file (`.remotemap`) designed to use the **M-Audio Code 25** in **Reason** with **SysEx** LED state feedback, an **XY mode engine**, and a clean, modular structure.

---

## Features & Improvements

### 1. SysEx LED State Feedback (`port = 2`)
* **Dedicated output port:** sends SysEx messages on the configured LED port (`LED_OUTPUT_PORT = 2`), including session open/close (`remote_prepare_for_use` / `remote_release_from_use`) and write command (`67`):
  `F0 00 01 05 7F 31 04 67 00 00 00 <HI> <LO> 00 <COLOR> F7`.
* **Centralized `LED_BUTTONS` table (Buttons 1–16):** groups button LED configuration (Remote item index, `OFF` / `ON` addresses, active/inactive colors, and `last_on` state tracking) to avoid duplicated code and redundant SysEx messages.
* **State tracking via `output="value"` and `remote_set_state`:** reads parameter states via `remote.get_item_value(...)` and queues messages into `pendingLedMessages`, delivered in `remote_deliver_midi` while checking available buffer space (`max_bytes >= 16`).

### 2. XY Mode Engine (Buttons 17–20 + XY Pad)
* **Four switchable modes (CC 28–31):**
  * **Button 17 — `SYNTH`:** routes the XY Pad (`Pad X` / `Pad Y`, CC 106 / 107) to `Macro X` / `Macro Y`.
  * **Button 18 — `FX`:** routes the XY Pad to `FX X` / `FX Y`.
  * **Button 19 — `COMBI`:** routes the XY Pad to `Combi X` / `Combi Y`.
  * **Button 20 — `PERF`:** routes the XY Pad to `Perf X` / `Perf Y`.
* **Per-mode LED feedback:** lights up the active mode's dedicated LED and turns the others off when `setMode(...)` is called.
* **Anti-jitter (`XY_THRESHOLD`):** filters minor fluctuations to prevent unwanted parameter jumps.

### 3. `.remotemap` File
* Maps controls defined in `Code25.lua` (`Button 1`–`Button 20`, faders, knobs, XY Pad, etc.) to target parameters inside Reason devices.
* Lets you reuse assignments across songs or devices and update mappings without modifying the core Lua script.

---

## Reason Device Behavior Notes

* **Differences across rack devices:** some devices (such as **Thor**, **Combinator**, and **SubTractor**) report state updates reliably even when the rack is hidden or when switching tracks. Other modules (such as **Dr. Octo Rex** and **Redrum**) may require the rack to be visible or the track to be focused for `remote_set_state` to reflect changes immediately.
* **Button role separation:** buttons **1–16** handle parameter state LED feedback via `LED_BUTTONS`, while buttons **17–20** are reserved for switching XY modes.

---

## Installation

1. **Place the files:** copy `Code25.lua` and your `.remotemap` file into Reason's custom control surface directory for your Reason installation.
2. **Verify the LED port:** check `LED_OUTPUT_PORT` in `Code25.lua` (`2` by default) against your MIDI port setup (verifiable with a MIDI monitor such as **MIDI-OX** or **SendSX**).
3. **Load in Reason:** reload control surfaces (or restart Reason) and select the **M-Audio Code 25** surface.

---

## Customization & Extension

* **Add or update a LED-tracked button (1–16):**
  1. Add `output="value"` to the corresponding item in `remote_init()`.
  2. Add or update its entry in `LED_BUTTONS` with its `OFF` / `ON` addresses and desired colors (`COLOR_OFF`, `COLOR_GREEN`, `COLOR_CYAN`, `COLOR_BLUE`, `COLOR_MAGENTA`, `COLOR_RED`, `COLOR_YELLOW`, `COLOR_WHITE`).
* **Adjust parameter mappings:** edit your `.remotemap` file (after making a backup) to target your preferred instruments or effects.

---

## Reference

* SysEx protocol documentation: [M-Audio-CODE-MIDI-Keyboard-SysEx-Reverse-Engineering](https://github.com/emreozcelik/M-Audio-CODE-MIDI-Keyboard-SysEx-Reverse-Engineering) by `emreozcelik`.
