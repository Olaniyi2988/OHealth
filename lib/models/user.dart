class User {
  int userId;
  int userTypeId;
  String username;
  String password;
  String authToken;
  String fingerClient;
  String fingerMatcher;

  User(
      {this.username,
      this.userId,
      this.userTypeId,
      this.password,
      this.authToken,
      this.fingerClient,
      this.fingerMatcher});

  factory User.fromJson(Map json, String token) {
    return User(
        userId: json['userid'],
        userTypeId: json['user_type_id'],
        username: json['username'],
        authToken: token,
        password: json['password'],
        fingerClient: json['fingerprintclient'],
        fingerMatcher: json['fingerprintmatcher']);
  }

  factory User.fromDBJson(Map json) {
    return User(
        userId: json['userid'],
        userTypeId: json['user_type_id'],
        username: json['username'],
        authToken: json['token'],
        password: json['password'],
        fingerClient: json['fingerprintclient'],
        fingerMatcher: json['fingerprintmatcher']);
  }

  Map<String, dynamic> toJson() {
    return {
      "userid": userId,
      "user_type_id": userTypeId,
      "username": username,
      "password": password,
      "token": authToken,
      'fingerprintclient': fingerClient,
      'fingerprintmatcher': fingerMatcher
    };
  }
}
