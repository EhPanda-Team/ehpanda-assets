# EhPanda assets

Images for EhPanda that are served from this repository rather than kept in the app repository.

## `app-marketplace/`

The icon and screenshots for EhPanda's listings in app marketplaces (AltStore, SideStore).

- `icon.png` is the app icon, 1024 × 1024 pixels, square and without rounded corners or transparency: AltStore and SideStore round it themselves. It is the artwork of the app's own icon (`App/EhPanda.icon` in the app repository).
- `iphone/` holds the screenshots, one folder per device. File names start with a two-digit number, which is the image's position in the listing.
- The marketplace source files in the app repository link to each image by its raw URL, `https://raw.githubusercontent.com/EhPanda-Team/ehpanda-assets/main/app-marketplace/<path>`. Screenshots are listed together with their width and height in whole pixels.
- Renaming, moving or resizing an image means updating those source files in the same change; until then the listing shows a broken or distorted image.

### Rounded screenshots

AltStore and SideStore show a screenshot as it is, without rounding its corners, so the files in `app-marketplace/iphone/` have the corners already rounded, as on the App Store, and are transparent outside them (RGBA PNG). Do not edit them by hand and do not round them again.

- `source/iphone/` holds the same screenshots as they were taken, with square corners. Replace a screenshot there, never in `app-marketplace/`.
- `tools/round-corners.swift` reads `source/iphone/` and writes `app-marketplace/iphone/` with the same names and size. Run it from anywhere on a Mac with Xcode: `swift tools/round-corners.swift`. Running it again gives the same files.
- The radius is the App Store's: the 6.9-inch iPhone screenshots on apps.apple.com (`.iphone-d74.portrait`, for example on https://apps.apple.com/us/app/id310633997) are drawn with `border-radius: 12.8% / 5.7%`, that is 12.8% of the width across and 5.7% of the height down. At 1260 × 2736 pixels that is about 161 × 156 pixels.
- The corner is the continuous (squircle) corner of iOS, not a quarter circle: the edge starts to bend 1.5287 times the radius before the corner.
