import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/app/ruh_code_app.dart';

void main() {
  test('RC-0002 exposes Turkish and English only at runtime', () {
    expect(
      RuhCodeApp.supportedLocales,
      const <Locale>[Locale('tr'), Locale('en')],
    );
    expect(RuhCodeApp.supportedLocales, hasLength(2));
    expect(
      RuhCodeApp.supportedLocales.map((locale) => locale.languageCode).toSet(),
      <String>{'tr', 'en'},
    );
  });

  test('RC-0002 keeps all Flutter localization delegates wired', () {
    expect(
      RuhCodeApp.localizationDelegates,
      containsAll(<LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ]),
    );
    expect(RuhCodeApp.localizationDelegates, hasLength(3));
  });
}
