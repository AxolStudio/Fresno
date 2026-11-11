# Fresno arcade compatibility
Goal: make the existing Windows game operable with keyboard alone or gamepad alone, using HaxeFlixel 6.2.1, without changing the live release or existing art.
Use the existing action system and menu styling. Add A/X jump, separate confirmation from Back, and a pause menu with Resume, Restart Level, Main Menu and desktop Quit to Launcher. Preserve automatic death retry. Make the ending escapable without waiting on an online score response.
The existing AxolAPI is retained in its private repository. Its historical pinned snapshot is adapted only on an isolated compatibility branch; no private source is copied into the public game repository.
Alternatives: an external keyboard mapper would not fix in-game navigation; replacing the input system would add unnecessary scope. The smallest in-game change is selected.
Verification: failing source contracts first, real Windows and HTML5 compilation, then automated native keyboard/gamepad action and menu tests. Physical-controller playtesting is a separate requirement. Diagnostics report actual stage results in JSON, not workflow color. No deployment, public release, credentials or permissions changes.
