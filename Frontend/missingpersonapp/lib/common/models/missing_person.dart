import 'dart:typed_data';

class MissingPerson {
  final String id;
  final String userId;
  final Name name;
  final String gender;
  final int age;
  final List<Uint8List> photos;
  final String skinColor;
  final Clothing clothing;
  final String bodySize;
  final String description;
  final int timeSinceDisappearance;
  final String inputHash;
  final int version;
  final MissingCaseId missingCaseId;

  MissingPerson({
    required this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.age,
    required this.photos,
    required this.skinColor,
    required this.clothing,
    required this.bodySize,
    required this.description,
    required this.timeSinceDisappearance,
    required this.inputHash,
    required this.version,
    required this.missingCaseId,
  });

  factory MissingPerson.fromJson(Map<String, dynamic> json) {
    List<Uint8List> photos = [];
    if (json['photos'] != null) {
      photos = List<Uint8List>.from(json['photos'].map((photo) => Uint8List.fromList(photo.cast<int>())));
    }

    return MissingPerson(
      id: json['_id'] as String,
      userId: json['user_id'] as String,
      name: Name.fromJson(json['name'] as Map<String, dynamic>),
      gender: json['gender'] as String? ?? 'Unknown',
      age: json['age'] as int? ?? 0,
      skinColor: json['skin_color'] as String? ?? 'Unknown',
      photos: photos,
      clothing: json['clothing'] != null ? Clothing.fromJson(json['clothing'] as Map<String, dynamic>) : Clothing(),
      bodySize: json['body_size'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? 'No description available',
      timeSinceDisappearance: json['timeSinceDisappearance'] as int? ?? 0,
      inputHash: json['inputHash'] as String? ?? '',
      version: json['__v'] as int? ?? 0,
      missingCaseId: json['missing_case_id'] != null ? MissingCaseId.fromJson(json['missing_case_id'] as Map<String, dynamic>) : MissingCaseId(),
    );
  }
}

class Name {
  final String firstName;
  final String middleName;
  final String lastName;

  Name({
    this.firstName = '',
    this.middleName = '',
    this.lastName = '',
  });

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      firstName: json['firstName'] as String? ?? '',
      middleName: json['middleName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
    );
  }

  toLowerCase() {}
}

class Clothing {
  final UpperClothing upper;
  final LowerClothing lower;

  Clothing({
    UpperClothing? upper,
    LowerClothing? lower,
  })  : upper = upper ?? UpperClothing(),
        lower = lower ?? LowerClothing();

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      upper: UpperClothing.fromJson(json['upper'] as Map<String, dynamic>? ?? {}),
      lower: LowerClothing.fromJson(json['lower'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class UpperClothing {
  final String clothType;
  final String clothColor;

  UpperClothing({
    this.clothType = '',
    this.clothColor = '',
  });

  factory UpperClothing.fromJson(Map<String, dynamic> json) {
    return UpperClothing(
      clothType: json['clothType'] as String? ?? '',
      clothColor: json['clothColor'] as String? ?? '',
    );
  }
}

class LowerClothing {
  final String clothType;
  final String clothColor;

  LowerClothing({
    this.clothType = '',
    this.clothColor = '',
  });

  factory LowerClothing.fromJson(Map<String, dynamic> json) {
    return LowerClothing(
      clothType: json['clothType'] as String? ?? '',
      clothColor: json['clothColor'] as String? ?? '',
    );
  }
}

class MissingCaseId {
  final String id;
  final String status;
  final List<String> imageBuffers;

  MissingCaseId({
    this.id = '',
    this.status = '',
    List<String>? imageBuffers,
  }) : imageBuffers = imageBuffers ?? [];

  factory MissingCaseId.fromJson(Map<String, dynamic> json) {
    return MissingCaseId(
      id: json['_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      imageBuffers: (json['imageBuffers'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}
