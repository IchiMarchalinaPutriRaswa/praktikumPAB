import 'package:flutter/foundation.dart';

class FitMatchStore {
  static final Map<String, double> measurements = {};
  static final Map<String, double> bodyMeasurements = {};
  static final Map<String, Map<String, double>> measurementsByCategory = {};
  static final Map<String, Map<String, double>> bodyMeasurementsByCategory = {};
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static String normalizeCategory(String category) {
    final value = category.toLowerCase().trim();
    if (['celana', 'rok', 'bawahan'].contains(value)) return 'bawahan';
    if (['atasan', 'outerwear', 'dress'].contains(value)) return 'atasan';
    return value;
  }

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
    measurementsByCategory[normalizeCategory(category)] = Map.from(values);
    revision.value++;
  }

  static void saveBodyForCategory(String category, Map<String, double> values) {
    if (values.isEmpty) return;
    bodyMeasurementsByCategory[normalizeCategory(category)] = Map.from(values);
    revision.value++;
  }

  static Map<String, double> getMeasurements(String category) {
    final key = normalizeCategory(category);
    final saved = measurementsByCategory[key];
    if (saved != null) return Map.from(saved);
    return measurementsByCategory.isEmpty ? Map.from(measurements) : {};
  }

  static Map<String, double> getBodyMeasurements(String category) {
    final key = normalizeCategory(category);
    final saved = bodyMeasurementsByCategory[key];
    if (saved != null) return Map.from(saved);
    return bodyMeasurementsByCategory.isEmpty ? Map.from(bodyMeasurements) : {};
  }

  static void clearCategory(String category) {
    final key = normalizeCategory(category);
    measurementsByCategory.remove(key);
    bodyMeasurementsByCategory.remove(key);
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
