/// Bundled image paths, centralized so call sites stay typo-safe.
///
/// Images are real photography under the Unsplash License (free, commercial use
/// permitted, no attribution required), fetched deterministically by seed. Every
/// path is still paired with an [AppImage] `seed`, so a missing file degrades to
/// designed procedural art rather than a broken box.
class AppAssets {
  const AppAssets._();

  static const String chair = 'assets/images/products/chair.jpg';
  static const String phone = 'assets/images/products/phone.jpg';
  static const String sneakers = 'assets/images/products/sneakers.jpg';
  static const String plant = 'assets/images/products/plant.jpg';
  static const String lamp = 'assets/images/products/lamp.jpg';

  static const String live = 'assets/images/media/live.jpg';
  static const String travel = 'assets/images/media/travel.jpg';
  static const String food = 'assets/images/media/food.jpg';

  static const String store = 'assets/images/scenarios/store.jpg';
  static const String studio = 'assets/images/scenarios/studio.jpg';
}
