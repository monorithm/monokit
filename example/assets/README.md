# Showcase assets

Bundled imagery for the Monokit showcase. Consumed exclusively through
`lib/kit/app_image.dart` (`AppImage`), which falls back to deterministic
procedural art when an asset is absent — so the app looks intentional even before
these folders are populated.

```
assets/images/
  products/    product photography (storefront, commerce, cards)
  media/       feed / live / video surfaces (rendered on the dark media canvas)
  avatars/     people (prefer generated/geometric over real faces)
  scenarios/   scenario-specific hero imagery
```

## Adding real images

1. Drop license-safe files here (CC0 / Unsplash / Pexels licenses, or original work).
   Avoid identifiable faces unless the license covers likeness.
2. Declare the directories in `example/pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/images/products/
       - assets/images/media/
       - assets/images/avatars/
       - assets/images/scenarios/
   ```
   (Flutter does not recurse — list each directory that contains files. Do **not**
   declare an empty directory; `flutter build` fails on it.)
3. Pass the path to `AppImage(asset: 'assets/images/products/chair.jpg', seed: 'chair')`.
   The `seed` still drives the fallback if the file is ever missing.
