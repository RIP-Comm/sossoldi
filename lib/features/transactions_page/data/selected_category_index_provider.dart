import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to manage the selected category index
/// in the categories pie chart.
final selectedCategoryIndexProvider =
    StateProvider.autoDispose<int>((ref) => -1);
