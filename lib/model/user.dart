class User {
  int? id;
  final String lastname;
  final String firstname;
  final String email;
  final String password;

  User({
    this.id,
    required this.lastname,
    required this.firstname,
    required this.email,
    required this.password,
  });

  //convertir le model en Map pour enregistrer sur sqlite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lastname': lastname,
      'firstname': firstname,
      'email': email,
      'password': password,
    };
  }

  // creer un model a partir du map de sqlite pour la vue
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      lastname: map['lastname'],
      firstname: map['firstname'],
      email: map['email'],
      password: map['password'],
    );
  }
}
