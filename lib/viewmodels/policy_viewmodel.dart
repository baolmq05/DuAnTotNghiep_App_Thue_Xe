import 'package:flutter/material.dart';
import '../models/policy_model.dart';
import '../services/policy_service.dart';

class PolicyViewModel extends ChangeNotifier {
  PolicyViewModel({PolicyService? policyService})
      : _policyService = policyService ?? PolicyService();

  final PolicyService _policyService;

  List<PolicySection> _sections = [];
  final List<GlobalKey> _sectionKeys = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAccepted = false;
  bool _hasReadFully = false;
  int _activeTabIndex = 0;

  List<PolicySection> get sections => _sections;
  List<GlobalKey> get sectionKeys => _sectionKeys;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAccepted => _isAccepted;
  bool get hasReadFully => _hasReadFully;
  int get activeTabIndex => _activeTabIndex;

  Future<void> loadPolicy() async {
    // Only load if not already loaded or empty
    if (_sections.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sections = await _policyService.fetchPolicy();
      _sectionKeys.clear();
      _sectionKeys.addAll(
        List.generate(_sections.length, (index) => GlobalKey(debugLabel: 'section_$index')),
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAccepted(bool val) {
    if (_isAccepted != val) {
      _isAccepted = val;
      notifyListeners();
    }
  }

  void setHasReadFully(bool val) {
    if (_hasReadFully != val) {
      _hasReadFully = val;
      notifyListeners();
    }
  }

  void resetAcceptance() {
    _isAccepted = false;
    _hasReadFully = false;
    notifyListeners();
  }

  void setActiveTab(int index) {
    if (_activeTabIndex != index) {
      _activeTabIndex = index;
      notifyListeners();
    }
  }
}
