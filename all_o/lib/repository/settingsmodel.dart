import 'settingrep.dart';
import 'package:flutter/material.dart';

class SettingViewModel extends ChangeNotifier {
  late bool _isDark;
  late String _identifiant;
  late String _motdepasse;
  late SettingRepository _settingRepository;
  bool get isDark => _isDark;
  String get identifiant => _identifiant;
  String get motdepasse => _motdepasse;
  SettingViewModel() {
    _isDark = false;
    _identifiant = "";
    _motdepasse = "";
    _settingRepository = SettingRepository();
    getSettingsDark();
    getSettingsIdentifiant();
    getSettingsMotdepasse();
  }

  set isDark(bool value) {
    _isDark = value;
    _settingRepository.saveSettingsDark(value);
    notifyListeners();
  }

  set identifiant(String value) {
    _identifiant = value;
    _settingRepository.saveSettingsIdentifiant(value);
    notifyListeners();
  }

  set motdepasse(String value) {
    _motdepasse = value;
    _settingRepository.saveSettingsMotdepasse(value);
    notifyListeners();
  }

  void getSettingsDark() async {
    _isDark = await _settingRepository.getSettingsDark();
    notifyListeners();
  }

  void getSettingsIdentifiant() async {
    _identifiant = await _settingRepository.getSettingsIdentifiant();
    notifyListeners();
  }

  void getSettingsMotdepasse() async {
    _motdepasse = await _settingRepository.getSettingsMotdepasse();
    notifyListeners();
  }
}
