# Fresno Windows candidate continuation

Goal: finish existing modernization branch 6e7b92d, not recreate prior work. Preserve assets and the inherited non-desktop projections; do not claim equivalence to original main24d70dd.

- [ ] Retain existing controls and add desktop neutral gates, Cancel-default process Exit, production-equivalent Credits and explicit fullscreen startup.
- [ ] Reuse existing tracked client game identifier with bounded event/score transport. Stable anonymous identity flushed before networking; isolated regression saves and no live test telemetry. Preserve score positions/IDs/lastId and own-row-below-top-ten display.
- [ ] Initialize desktop on engine thread. Apply pinned Flixel6.2.1 native bitmap reentry/log compatibility without editing private library source.
- [ ] Keep private AxolLib7ad35e46 only in private hosted checkout. Public repository contains no private snapshots or new credentials.
- [ ] Preserve existing component tests as limited evidence; add separate fullscreen real-loop keyboard/gamepad smoke, pixel checks and guarded constructor/frame error reports. Label death/ending fixtures, do not claim full campaign.
- [ ] Hosted native regression and one release compile-only package; verify JSON/exit codes, package CRC and hashes. No native execution on Lewton, no merge or itch publication.
- [ ] Independent review and owner-only Drive delivery. Physical devices/hotplug/cabinet and live server acceptance remain manual follow-up.
