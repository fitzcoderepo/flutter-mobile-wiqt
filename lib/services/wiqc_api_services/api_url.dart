import 'dart:io';

class BaseUrl {
  static String getBaseUrl() {
    if (Platform.isAndroid || Platform.isIOS) {
      return "https://www.wateriqcloud-dev.com";
    } else {
      throw UnsupportedError("This platform is not supported");
    }
  }
}
