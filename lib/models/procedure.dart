import 'dart:convert';

import 'package:color/color.dart';

import '../data/procedures.dart';

class Procedure {
  String name;
  String? type;
  String? gap;
  double price;
  int id;
  Color? color;

  static final Map<int, Procedure> map = {};

  static Procedure get(int id) {
    return procedures.firstWhere((p) => p.id == id,
        orElse: () => procedures[0]);
  }

  Procedure({
    required this.id,
    required this.name,
    required this.price,
    this.color,
    this.type,
    this.gap,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'gap': gap,
      'price': price,
      'id': id,
      'color': color!.hashCode,
    };
  }

  factory Procedure.fromMap(Map<String, dynamic> map) {
    return Procedure(
      name: map['name'],
      type: map['type'],
      gap: map['gap'],
      price: map['price'],
      id: map['id'],
      color: Color.hex(
        '${map['color']}',
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Procedure.fromJson(String source) =>
      Procedure.fromMap(json.decode(source));
}
