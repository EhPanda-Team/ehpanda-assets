# EhPanda assets

Images for EhPanda that are kept in this repository rather than in the app repository.

## `app-marketplace/`

The icon, banner and screenshots for EhPanda's listings in app marketplaces (AltStore, SideStore).

- `icon.png` is the app icon, 1024 × 1024 pixels, square and without rounded corners or transparency: AltStore and SideStore round it themselves. It is the artwork of the app's own icon (`App/EhPanda.icon` in the app repository).
- `header.png` is the banner at the top of a source's page in AltStore, 2400 × 1600 pixels (3:2, as AltStore recommends) and without text, because AltStore shows it blurred until it is swiped. Every source uses the same one.
- `iphone/` holds the screenshots, one folder per device. File names are a two-digit number, which is the image's position in the listing, and a short name for the screen, with no version or size.
- The marketplace source files in the app repository link to each image by its raw URL, `https://raw.githubusercontent.com/EhPanda-Team/ehpanda-assets/main/app-marketplace/<path>`. Screenshots are listed together with their width and height in whole pixels.
- Renaming, moving or resizing an image means updating those source files in the same change; until then the listing shows a broken or distorted image.

### Screenshots

AltStore rounds a screenshot's corners itself, but only when the image is exactly 9:19.5, the shape of a modern iPhone's screen (it allows a difference of 0.001 in the width-to-height ratio). Any other shape gets square corners and a thin outline. So the screenshots in `app-marketplace/iphone/` are 1260 × 2730 pixels, with square corners and no transparency.

- A screenshot taken at 1260 × 2736 is 0.001 too far from 9:19.5, so 3 pixels are cut from its top and from its bottom (`sips -c 2730 1260 <taken>.png --out app-marketplace/iphone/<name>.png`).
- The screenshots are in English, as AltStore and SideStore show every person the same screenshots whatever their language.

## `app-store/`

The screenshots for EhPanda's App Store listing. They are uploaded to App Store Connect rather than served from here.

- `iphone/` holds the iPhone screenshots. Each shows the same screen as the screenshot of the same name in `app-marketplace/iphone/`, and the names follow the same rule.
- They are 1206 × 2622 pixels, the size App Store Connect requires for iPhone with Dynamic Island (medium display), with square corners and no transparency: App Store Connect refuses images with an alpha channel.
- They are in English.
