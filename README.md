# cyclone-nothing

Parametric 3D-printable phone holder that mounts a Nothing Phone 2 onto a GameSir Cyclone 2 controller — connector plate, diagonal arm, print-in-place swivel pivot, and a self-centering screw-adjustable clamp.

**[Open the live customizer / STL export →](https://thefehr.github.io/cyclone-nothing/)**
**[Read the assembly guide →](https://thefehr.github.io/cyclone-nothing/assembly_guide.html)**

## What it does

- Snap-fit connector plate slides into the controller's own USB-C accessory port — no glue, no screws, reverse-engineered from a real controller.
- A tilted arm carries a print-in-place swivel pivot, so the clamp rotates 90° between portrait (handheld console emulation) and landscape (x64 emulation — also works for PC streaming) orientations without removing the phone.
- The clamp is a screw-adjustable, car-mount-style claw grip on the phone's short edges — screen and back stay fully exposed. A dual-handed printed leadscrew draws both claws in together and keeps the phone centered at any width.
- **No metal anywhere.** Every joint is either a real printed helical thread or a plain friction-fit pin cut from your own printer filament, glued in place. No screws, nuts, or hardware to source.

## Print + assemble

Nine independent print jobs, no combined prints, no captured/impossible-to-assemble joints — see the [assembly guide](https://thefehr.github.io/cyclone-nothing/assembly_guide.html) for the parts list, hardware (4 filament pins + CA glue), and the exact build order (some joints can only close in one sequence).

Verified STL exports for the current design live in [`stl/`](stl/); the [live customizer](https://thefehr.github.io/cyclone-nothing/) lets you tweak any dimension (screw diameter, rail length, clamp reach, pivot tilt, etc.) and export fresh STLs for your own printer/tolerances.

## Repo layout

- `phone_holder.scad` — the parametric design, annotated with OpenSCAD Customizer comments (drives the live web form automatically).
- `lib/threads.scad` — [rcolyer/threads-scad](https://github.com/rcolyer/threads-scad) (CC0), used for the printed leadscrew/nut threads.
- `stl/` — current verified STL export of all 9 parts.
- `reference/` — measurements/reference meshes the connector plate was reverse-engineered from.
- `index.html` / `worker-shim.js` — the live in-browser preview, built on [openscad-customizer-web](https://github.com/TheFehr/openscad-customizer-web).
- `assembly_guide.html` — step-by-step build guide.

## License

[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
