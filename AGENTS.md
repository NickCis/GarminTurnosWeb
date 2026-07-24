# Agent Notes

- Target Connect IQ app for Garmin watches. Current primary target is `fenix7s`.
- `manifest.xml` is generated from `manifest.template.xml` (do not commit it). App IDs live in the `Makefile`: `APP_ID_BETA` / `APP_ID_PROD`.
- Build with `make build` (beta by default) or `make build VARIANT=prod`. Release with `make release` / `make release VARIANT=prod`. The default SDK path lives in `Makefile` and can be overridden with `SDK=...`.
- Launcher icons: base `resources/` is 40×40; non-default sizes live in `resources-<device>` (and buckets `resources-icon-*`). Regenerate with `make icons`. After installing new device packs in SDK Manager, check `compiler.json` → `launcherIcon` and extend `scripts/gen_launcher_icons.py` if needed.
- Keep generated Monkey Motion files in `resources-anim/animations/`. Do not hand-edit `.mm` binaries. Regenerate the loading animation from the GIF with:

```bash
make animations
```

- `resources-anim/animations/animations.xml` exposes `LoadingSpinner`; `LoadingAnimation.mc` uses it via `Rez.Drawables.LoadingSpinner`. On `fr55` / `vivoactive3` (no Monkey Motion) the loader draws centered text only — animations are omitted via `monkey.jungle`.
- Avoid tight `Timer.Timer` intervals that trigger Garmin simulator warnings; prefer `AnimationLayer` for loading animations.
