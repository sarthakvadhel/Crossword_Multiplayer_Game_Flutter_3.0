import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/game_state_model.dart';

class StorageService {
  static const String _gameStateKey = 'game_state';
  static const String _userProfileKey = 'user_profile';
  
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveGameState(GameStateModel state) async {
    final json = jsonEncode(state.toJson());
    await _prefs?.setString(_gameStateKey, json);
  }

  GameStateModel? loadGameState() {
    final json = _prefs?.getString(_gameStateKey);
    if (json == null) return null;
    return GameStateModel.fromJson(jsonDecode(json));
  }

  Future<void> clearGameState() async {
    await _prefs?.remove(_gameStateKey);
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _prefs?.setString(_userProfileKey, jsonEncode(profile));
  }

  Map<String, dynamic>? loadUserProfile() {
    final json = _prefs?.getString(_userProfileKey);
    if (json == null) return null;
    return jsonDecode(json);
  }

  bool get hasGameState => _prefs?.containsKey(_gameStateKey) ?? false;
}
