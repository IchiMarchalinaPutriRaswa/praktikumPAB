import 'package:flutter/foundation.dart';

class FitMatchStore {
  static final Map<String, double> measurements = {};
  static final Map<String, double> bodyMeasurements = {};

  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void save(Map<String, double> values) {
    if (values.isEmpty) return;
    measurements
      ..clear()
      ..addAll(values);
    revision.value++;
  }

  static void saveBody(Map<String, double> values) {
    if (values.isEmpty) return;
    bodyMeasurements
      ..clear()
      ..addAll(values);
    revision.value++;
  }

  static void clear() {
    measurements.clear();
    bodyMeasurements.clear();
    revision.value++;
  }
}
