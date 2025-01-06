import 'package:equatable/equatable.dart';

class Animal extends Equatable {
  final String id;
  final String name;
  final int count;

  const Animal({required this.id, required this.name, required this.count});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "count": count,
    };
  }

  factory Animal.fromMap(Map<String, dynamic> data) {
    return Animal(
      id: data["id"],
      name: data["name"],
      count: data["count"],
    );
  }

  @override
  List<Object?> get props => [id, name, count];
}
