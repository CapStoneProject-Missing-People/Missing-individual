import 'dart:convert';

class UpperClothing {
  String clothType;
  String clothColor;

  UpperClothing({
    required this.clothType,
    required this.clothColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'clothType': clothType,
      'clothColor': clothColor,
    };
  }

  factory UpperClothing.fromMap(Map<String, dynamic> map) {
    return UpperClothing(
      clothType: map['clothType'] ?? '',
      clothColor: map['clothColor'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UpperClothing.fromJson(String source) =>
      UpperClothing.fromMap(json.decode(source));
}

class LowerClothing {
  String clothType;
  String clothColor;

  LowerClothing({
    required this.clothType,
    required this.clothColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'clothType': clothType,
      'clothColor': clothColor,
    };
  }

  factory LowerClothing.fromMap(Map<String, dynamic> map) {
    return LowerClothing(
      clothType: map['clothType'] ?? '',
      clothColor: map['clothColor'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LowerClothing.fromJson(String source) =>
      LowerClothing.fromMap(json.decode(source));
}

class Clothing {
  final UpperClothing upper;
  final LowerClothing lower;

  Clothing({
    required this.upper,
    required this.lower,
  });

  Map<String, dynamic> toMap() {
    return {
      'upper': upper.toMap(),
      'lower': lower.toMap(),
    };
  }

  factory Clothing.fromMap(Map<String, dynamic> map) {
    return Clothing(
      upper: UpperClothing.fromMap(map['upper'] ?? {}),
      lower: LowerClothing.fromMap(map['lower'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory Clothing.fromJson(String source) =>
      Clothing.fromMap(json.decode(source));
}
