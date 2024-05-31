class Receiver {
  final String id;
  final String name;
  final String email;
  final String password;
  final String type;

  Receiver({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.type,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) {
    return Receiver(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'type': type,
    };
  }
}
