import 'dart:math';

class Images {
  static List<String> avatars = List.generate(
      20, (index) => 'assets/images/avatar/avatar_${index + 1}.png');

  static List<String> landscape = List.generate(
      10, (index) => 'assets/images/dummy/landscape_${index + 1}.png');

  static List<String> profile = List.generate(
      5, (index) => 'assets/images/dummy/profile_${index + 1}.jpg');

  static List<String> product = List.generate(
      6, (index) => 'assets/images/dummy/product_${index + 1}.png');
  static List<String> singleProduct = List.generate(
      4, (index) => 'assets/images/products/products_0${index + 1}.png');

  static List<String> nft =
      List.generate(5, (index) => 'assets/images/dummy/nft_${index + 1}.jpg');

  static String logo = 'assets/images/logo/logo.png';
  static String logoSm = 'assets/images/logo/logo-sm.png';
  static String authBackground = 'assets/images/dummy/cococara_auth.jpg';//auth_background.png
  static String google = 'assets/images/brand/google.png';
  static String auth2Background = 'assets/images/dummy/auth_2.png';

  static String randomImage(List<String> images) {
    return images[Random().nextInt(images.length)];
  }
}
