class AppUser {
  late String id, name, mobile, email, password;

  AppUser();

  AppUser.fromJason(Map<String, dynamic> userMap) {
    id = userMap["id"];
    name = userMap["name"];
    mobile = userMap["mobile"];
    email = userMap["email"];
    password = userMap["password"];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "mobile": mobile,
      "email": email,
      "password": password
    };
  }
}
