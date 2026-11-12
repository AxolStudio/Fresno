# Windows test candidate

The public game repository contains no private AxolLib source. The build-only workflow template is `tools/hosted/windows_arcade.yml`; its executable copy runs in the private AxolLib repository and checks out this game at an exact commit.

Desktop dependency checkout: `ci-dependency` from private `AxolStudio/axollib` commit `7ad35e46be22517cc4d2677abcf48ec3f1808cb9`. The existing `axollib` gitlink remains unchanged for inherited non-desktop targets.

Pinned hosted toolchain is installed by `tools/Setup-WindowsLibraries.ps1`. The workflow runs `Test-ArcadeCore.ps1`, `Build-ArcadeTests.ps1`, then `Build-WindowsCandidate.ps1`. The production executable is compiled but never launched in CI. Native tests compile out telemetry and bind isolated test saves.

The single candidate starts fullscreen and serves both launcher and ordinary Windows use. No release, merge, or itch deployment occurs. Check diagnostic JSON and process exit codes, not just a workflow badge. Seeded death/ending tests do not establish full-campaign completion; physical controller/hotplug, cabinet focus, and live API acceptance remain separate checks.
