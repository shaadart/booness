import 'package:flutter/material.dart';

class SearchControllerProvider extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}