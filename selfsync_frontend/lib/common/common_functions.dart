import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

bool isLocalPath(String path) {
  if (path.isEmpty) {
    return false; // it will show a nice error image
  }
  // Parse the string into a Uri object
  Uri? uri = Uri.tryParse(path);

  // Check if the Uri is a URL or a file path
  if (uri != null &&
      (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https'))) {
    return false; // URL
  } else {
    return true; // Local path
  }
}

String generateUniqueId() {
  return const Uuid().v4();
}

bool get isTablet {
  final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
  final logicalShortestSide = firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
  return logicalShortestSide > 600;
}

String monthToName(int month) {
  switch (month) {
    case  0:
      return 'All Months';
    case 1:
      return 'January';
    case 2:
      return 'February';
    case 3:
      return 'March';
    case 4:
      return 'April';
    case 5:
      return 'May';
    case 6:
      return 'June';
    case 7:
      return 'July';
    case 8:
      return 'August';
    case 9:
      return 'September';
    case 10:
      return 'October';
    case 11:
      return 'November';
    case 12:
      return 'December';
    default:
      return 'Invalid Month';
  }
}
