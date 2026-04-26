/// Response model from the ClasseViva login endpoint.
class LoginResponse {
  final String token;
  final DateTime expire;
  final String studentId;
  final String firstName;
  final String lastName;

  LoginResponse({
    required this.token,
    required this.expire,
    required this.studentId,
    required this.firstName,
    required this.lastName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String;
    final expireStr = json['expire'] as String;
    final expire = DateTime.parse(expireStr);

    final ident = json['ident'] as String? ?? '';
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';

    // Extract numeric student ID from ident (e.g. 'S9425341D' → '9425341')
    String studentId = ident;
    final match = RegExp(r'[A-Za-z](\d+)[A-Za-z]').firstMatch(ident);
    if (match != null) {
      studentId = match.group(1)!;
    }

    return LoginResponse(
      token: token,
      expire: expire,
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
