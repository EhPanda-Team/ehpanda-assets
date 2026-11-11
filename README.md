# EhPanda assets

Images for EhPanda that are served from this repository rather than kept in the app repository.

## `app-marketplace/`

The icon, banner and screenshots for EhPanda's listings in app marketplaces (AltStore, SideStore).

- `icon.png` is the app icon, 1024 × 1024 pixels, square and without rounded corners or transparency: AltStore and SideStore round it themselves. It is the artwork of the app's own icon (`App/EhPanda.icon` in the app repository).
- `header.png` is the banner at the top of a source's page in AltStore, 2400 × 1600 pixels (3:2, as AltStore recommends) and without text, because AltStore shows it blurred until it is swiped. Every source uses the same one.
- `iphone/` holds the screenshots, one folder per device. File names start with a two-digit number, which is the image's position in the listing.
- The marketplace source files in the app repository link to each image by its raw URL, `https://raw.githubusercontent.com/EhPanda-Team/ehpanda-assets/main/app-marketplace/<path>`. Screenshots are listed together with their width and height in whole pixels.
- Renaming, moving or resizing an image means updating those source files in the same change; until then the listing shows a broken or distorted image.

### Screenshots

AltStore rounds a screenshot's corners itself, but only when the image is exactly 9:19.5, the shape of a modern iPhone's screen (it allows a difference of 0.001 in the width-to-height ratio). Any other shape gets square corners and a thin outline. So the screenshots in `app-marketplace/iphone/` are 1260 × 2730 pixels, with square corners and no transparency.

- `source/iphone/` holds the screenshots as they were taken, 1260 × 2736 pixels. That is 0.001 too far from 9:19.5, so each served file is the same screenshot with 3 pixels cut from the top and from the bottom: `sips -c 2730 1260 source/iphone/<name>.png --out app-marketplace/iphone/<name>-1260x2730.png`.
- The size is in the file name, so a new size is a new URL. AltStore keeps images it has downloaded by URL, and would go on showing the old image under an old one.
