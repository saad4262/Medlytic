import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Bottom navigation state
  final RxInt currentBottomIndex = 0.obs;

  // Page controller for smooth transitions
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  // Navigation methods
  void changeBottomIndex(int index) {
    currentBottomIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Reset navigation state
  void resetNavigation() {
    currentBottomIndex.value = 0;
    pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
