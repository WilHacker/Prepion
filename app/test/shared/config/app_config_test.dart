import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/config/app_config.dart';

void main() {
  test('apunta al backend local del emulador cuando no se define API_URL', () {
    expect(AppConfig.apiUrl, 'http://10.0.2.2:8800');
  });
}
