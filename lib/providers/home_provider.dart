import 'package:flutter/foundation.dart';
import 'package:smart_house/core/platform_channel/home_channel.dart';
import '../models/home_model.dart';

class HomeProvider with ChangeNotifier {
  List<HomeModel> _homes = [];
  bool _isLoading = false;
  String? _errorMessage;
  HomeModel? _selectedHome;

  List<HomeModel> get homes => _homes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  HomeModel? get selectedHome => _selectedHome;

  /// Set selected home
  void setSelectedHome(HomeModel? home) {
    _selectedHome = home;
    notifyListeners();
  }

  /// Fetch all homes
  Future<void> fetchHomes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await HomeChannel.getHomeList();
      _homes = result.map((json) => HomeModel.fromJson(json)).toList();

      // Set first home as selected if none is selected
      if (_homes.isNotEmpty && _selectedHome == null) {
        _selectedHome = _homes.first;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching homes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new home
  Future<bool> createHome(String name) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Home name cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final homeId = await HomeChannel.createHome(name: name.trim());

      // Refresh home list after creation
      await fetchHomes();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error creating home: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a home
  Future<bool> deleteHome(int homeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await HomeChannel.deleteHome(homeId: homeId);

      // Remove from local list
      _homes.removeWhere((home) => home.homeId == homeId);

      // Clear selected home if it was deleted
      if (_selectedHome?.homeId == homeId) {
        _selectedHome = _homes.isNotEmpty ? _homes.first : null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error deleting home: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update home name
  Future<bool> updateHomeName(int homeId, String newName) async {
    if (newName.trim().isEmpty) {
      _errorMessage = 'Home name cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await HomeChannel.updateHomeName(homeId: homeId, name: newName.trim());

      // Update local list
      final index = _homes.indexWhere((home) => home.homeId == homeId);
      if (index != -1) {
        _homes[index] = _homes[index].copyWith(name: newName.trim());
      }

      // Update selected home if it matches
      if (_selectedHome?.homeId == homeId) {
        _selectedHome = _selectedHome!.copyWith(name: newName.trim());
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error updating home name: $e');
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _homes = [];
    _isLoading = false;
    _errorMessage = null;
    _selectedHome = null;
    notifyListeners();
  }
}
