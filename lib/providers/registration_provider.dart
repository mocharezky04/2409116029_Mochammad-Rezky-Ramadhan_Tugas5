// lib/providers/registration_provider.dart
import 'package:flutter/foundation.dart';
import '../models/registrant_model.dart';

class RegistrationProvider extends ChangeNotifier {
  final List<Registrant> _registrants = [];

  // Getters
  List<Registrant> get registrants => List.unmodifiable(_registrants);
  int get count => _registrants.length;

  // Add registrant
  void addRegistrant(Registrant registrant) {
    _registrants.add(registrant);
    notifyListeners();
  }

  // Update registrant by id
  void updateRegistrant(Registrant updatedRegistrant) {
    final index = _registrants.indexWhere((r) => r.id == updatedRegistrant.id);
    if (index == -1) return;
    _registrants[index] = updatedRegistrant;
    notifyListeners();
  }

  // Remove registrant
  void removeRegistrant(String id) {
    _registrants.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Get by ID
  Registrant? getById(String id) {
    try {
      return _registrants.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if email already registered
  bool isEmailRegistered(String email, {String? excludeId}) {
    return _registrants.any(
      (r) => r.id != excludeId && r.email.toLowerCase() == email.toLowerCase(),
    );
  }
}
