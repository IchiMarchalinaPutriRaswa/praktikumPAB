import 'package:flutter/foundation.dart';

class FitMatchStore {
  static final Map<String, double> measurements = {};
  static final Map<String, double> bodyMeasurements = {};

  static final Map<String, Map<String, double>> measurementsByCategory = {};
  static final Map<String, Map<String, double>> bodyMeasurementsByCategory = {};

  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void save(Map<String, double> values) {
    if (values.isEmpty) return;
    measurements..clear()..addAll(values);
    revision.value++;
  }

  static void saveBody(Map<String, double> values) {
    if (values.isEmpty) return;
    bodyMeasurements..clear()..addAll(values);
    revision.value++;
  }

  static void saveForCategory(String category, Map<String, double> values) {
    if (values.isEmpty) return;
    measurementsByCategory[category] = Map.from(values);
    revision.value++;
  }

  static void saveBodyForCategory(String category, Map<String, double> values) {
    if (values.isEmpty) return;
    bodyMeasurementsByCategory[category] = Map.from(values);
    revision.value++;
  }

  static Map<String, double> getMeasurements(String category) =>
      Map.from(measurementsByCategory[category] ?? {});

  static Map<String, double> getBodyMeasurements(String category) =>
      Map.from(bodyMeasurementsByCategory[category] ?? {});

  static void clearCategory(String category) {
    measurementsByCategory.remove(category);
    bodyMeasurementsByCategory.remove(category);
    revision.value++;
  }

  static void clear() {
    measurements.clear();
    bodyMeasurements.clear();
    measurementsByCategory.clear();
    bodyMeasurementsByCategory.clear();
    revision.value++;
  }
}
