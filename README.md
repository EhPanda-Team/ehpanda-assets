# EhPanda assets

Images for EhPanda that are served from this repository rather than kept in the app repository.

## `app-marketplace/`

Screenshots for EhPanda's listings in app marketplaces (AltStore, SideStore), one folder per device, for example `app-marketplace/iphone/`.

- File names start with a two-digit number, which is the image's position in the listing.
- The marketplace source files in the app repository link to each image by its raw URL, `https://raw.githubusercontent.com/EhPanda-Team/ehpanda-assets/main/app-marketplace/<device>/<file>`, together with its width and height in whole pixels.
- Renaming, moving or resizing an image means updating those source files in the same change; until then the listing shows a broken or distorted image.
