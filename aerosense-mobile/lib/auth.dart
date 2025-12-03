import 'package:aerosense/api.dart';

class Auth {
  Auth._();
  static final Auth instance = Auth._();

  String? _token;
  List<String>? _permissions;
  String? _firstName;
  String? _lastName;
  String? _userName;
  String? _roleName;

  set token(String value) => _token = value;
  set permissions(List<String> value) => _permissions = value;
  set firstName(String value) => _firstName = value;
  set lastName(String value) => _lastName = value;
  set userName(String value) => _userName = value;
  set roleName(String value) => _roleName = value;

  String get token => _token ?? '';
  List<String> get permissions => _permissions ?? <String>[];
  String get firstName => _firstName ?? '';
  String get lastName => _lastName ?? '';
  String get userName => _userName ?? '';
  String get roleName => _roleName ?? '';

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  bool allowed(String permission) {
    if (_permissions == null || _permissions!.isEmpty) {
      return false;
    }

    return _permissions!.contains(permission);
  }

  Future<void> logout() async {
    try {
      await Api.instance.post('/api/auth/logout', <String, dynamic>{}); 
    } 
    catch (e) {
      //
    }
    finally {
      _token = null;
      _permissions = null;
      _firstName = null;
      _lastName = null;
      _userName = null;
      _roleName = null;

      Api.instance.clearToken();
    }
  }
}
