import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    @JsonKey(name: 'last_name') required String lastName,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'pseudo_code') required String pseudoCode,
    @JsonKey(name: 'group_label') String? groupLabel,
    @JsonKey(name: 'first_language') String? firstLanguage,
    @JsonKey(name: 'flsco_level') int? flscoLevel,
    String? notes,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}
