import 'package:flutter/widgets.dart';
import 'package:fulminant/app/app.dart';
import 'package:fulminant/home/home.dart';
import 'package:fulminant/login/login.dart';

List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
