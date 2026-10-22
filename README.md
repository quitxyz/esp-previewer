# ESP previewer

A small visual sandbox for the Roblox ESP library. This repository contains the browser preview only; it does not run Luau or connect to Roblox.

Open https://quitxyz.github.io/esp-previewer/ or serve this directory with any static HTTP server. No install or build step is required. Three.js 0.170.0 loads from jsDelivr.

## Files

- `index.html` — page and controls
- `styles.css` — responsive layout
- `src/app.js` — settings and input handling
- `src/preview.js` — model, cameras, projection and pointer rotation
- `src/box.js` — canvas box drawing
- `assets/r6.glb` — supplied R6 model with its export-root roll corrected

Box settings are independent for Enemy, Friendly, Self and World. The player groups share the same R6 preview; World uses a crate. Extra is reserved. Settings last until the page reloads.

The scene redraws on changes rather than running a continuous render loop. Boxes project the eight corners of the model's unrotated bounds through its current transform. The front view is orthographic; the 3D view supports horizontal drag rotation.

## R6 orientation

The supplied GLB had a rotated `Sketchfab_model` root, including approximately 0.873° of roll after its up-axis conversion. The preview previously guessed the up axis and applied additional conflicting roll corrections. The asset now retains the original root scale and up-axis conversion, with the measured roll removed. Mesh data, skinning, textures and child transforms are preserved. Runtime code only scales, centers and grounds the model.

Browser output is an appearance reference. Drawing API compatibility, Roblox projection, performance and resource cleanup require separate runtime tests.
