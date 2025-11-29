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

  void setToken(String token) => _token = token;
  void setPermissions(List<String> permissions) => _permissions = permissions;
  void setFirstName(String firstName) => _firstName = firstName;
  void setLastName(String lastName) => _lastName = lastName;
  void setUserName(String userName) => _userName = userName;
  void setRoleName(String roleName) => _roleName = roleName;

  String get getFirstName => _firstName ?? "";
  String get getLastName => _lastName ?? "";
  String get getUserName => _userName ?? "";
  String get getRoleName => _roleName ?? "";

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  bool allowed(String permission) {
    if (_permissions == null || _permissions!.isEmpty) return false;

    return _permissions!.contains(permission);
  }

  Future<void> logout() async {
    try {
      await Api.instance.post("/api/auth/logout", {}); 
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