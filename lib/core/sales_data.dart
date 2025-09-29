import 'package:flutter/foundation.dart';

class SalesData extends ChangeNotifier {
  static final SalesData instance = SalesData._internal();
  SalesData._internal();

  int smallSold = 0;
  int largeSold = 0;
  double totalStockMl = 1200; // initial stock 5L
  double revenue = 0.0;
  int smallCups = 1;
  int largeCups = 1;

  // Refund tracking
  double totalRefundAmount = 0.0;
  int totalRefunds = 0;
  int smallRefunds = 0;
  int largeRefunds = 0;

  // Refund reasons
  int overfreezeRefunds = 0;
  int cupDropRefunds = 0;
  int otherRefunds = 0;
  void refund({required bool isSmall, required double amount, String reason = "overfreeze"}) {
    totalRefunds++;
    totalRefundAmount += amount;
    if (isSmall) {
      smallRefunds++;
    } else {
      largeRefunds++;
    }

    switch (reason) {
      case "overfreeze":
        overfreezeRefunds++;
        break;
      case "cupDrop":
        cupDropRefunds++;
        break;
      default:
        otherRefunds++;
    }

    notifyListeners();
  }

  void sellSmallDrink() {
    if (totalStockMl >= 300 && smallCups > 0) {
      smallSold++;
      totalStockMl -= 300;
      revenue += 30;
      smallCups--;
      notifyListeners();
    }
  }

  void sellLargeDrink() {
    if (totalStockMl >= 400 && largeCups > 0) {
      largeSold++;
      totalStockMl -= 400;
      revenue += 45;
      largeCups--;
      notifyListeners();
    }
  }

  void reset() {
    smallSold = 0;
    largeSold = 0;
    totalStockMl = 5000;
    revenue = 0.0;
    smallCups = 25;
    largeCups = 25;
    totalRefundAmount = 0.0;
    totalRefunds = 0;
    smallRefunds = 0;
    largeRefunds = 0;
    overfreezeRefunds = 0;
    cupDropRefunds = 0;
    otherRefunds = 0;
    notifyListeners();
  }

  void addStock() {
    totalStockMl = 5000;
    notifyListeners();
  }

  void resetCups() {
    smallCups = 25;
    largeCups = 25;
    notifyListeners();
  }
}
