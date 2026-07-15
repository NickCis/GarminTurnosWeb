# Agent Notes

- Target Connect IQ app for Garmin watches. Current primary target is `fenix7s`.
- Build with `make build`; release with `make release`. The default SDK path lives in `Makefile` and can be overridden with `SDK=...`.
- Keep generated Monkey Motion files in `resources/animations/`. Do not hand-edit `.mm` binaries.
- Regenerate the loading animation from the GIF with:

```bash
make animations
```

- `resources/animations/animations.xml` exposes `LoadingSpinner`; `LoadingAnimation.mc` uses it via `Rez.Drawables.LoadingSpinner`.
- Avoid tight `Timer.Timer` intervals that trigger Garmin simulator warnings; prefer `AnimationLayer` for loading animations.
