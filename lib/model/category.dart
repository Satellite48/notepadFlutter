class Category {
  final int? id;
  final String name;
  final String userId;

  const Category({this.id, required this.name, required this.userId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'user_id': userId};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
        userId: map['user_id']
    );
  }
}
