// ignore_for_file: non_constant_identifier_names,camel_case_types
import 'package:flutter/material.dart';
import 'package:younpc/src/common/to_router.dart';

class RootPage extends StatelessWidget with PageMixin {
  RootPage({super.key});

  factory RootPage.fromURI(Location to) {
    return RootPage();
  }

  @override
  String get uriTemplate => "/]";

  @override
  Uri get uri => Uri.parse("/");

  static Page<dynamic> page(BuildContext context, Location loc, Widget child) {
    return MaterialPage(key: ValueKey(loc.uri.toString()), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return const Text("/  root page");
  }
}
