import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sales officer's own details, kept on the device.
class ProfileStore extends ChangeNotifier {
  late SharedPreferences _prefs;
  String name = '';
  String employeeId = '';
  String area = '';
  String phone = '';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    name = _prefs.getString('profile_name') ?? '';
    employeeId = _prefs.getString('profile_id') ?? '';
    area = _prefs.getString('profile_area') ?? '';
    phone = _prefs.getString('profile_phone') ?? '';
  }

  Future<void> save({required String name, required String employeeId, required String area, required String phone}) async {
    this.name = name.trim();
    this.employeeId = employeeId.trim();
    this.area = area.trim();
    this.phone = phone.trim();
    await _prefs.setString('profile_name', this.name);
    await _prefs.setString('profile_id', this.employeeId);
    await _prefs.setString('profile_area', this.area);
    await _prefs.setString('profile_phone', this.phone);
    notifyListeners();
  }
}
