import 'package:flutter/foundation.dart';

/// Immutable model representing a gratitude prompt.
@immutable
class Prompt {
  const Prompt({
    required this.id,
    required this.category,
    required this.text,
    this.scriptureReference,
    this.isScriptureBased = false,
  });

  final String id;
  final String category;
  final String text;
  final String? scriptureReference;
  final bool isScriptureBased;

  Prompt copyWith({
    String? id,
    String? category,
    String? text,
    String? scriptureReference,
    bool? isScriptureBased,
  }) {
    return Prompt(
      id: id ?? this.id,
      category: category ?? this.category,
      text: text ?? this.text,
      scriptureReference: scriptureReference ?? this.scriptureReference,
      isScriptureBased: isScriptureBased ?? this.isScriptureBased,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'text': text,
      'scriptureReference': scriptureReference,
      'isScriptureBased': isScriptureBased,
    };
  }

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      category: json['category'] as String,
      text: json['text'] as String,
      scriptureReference: json['scriptureReference'] as String?,
      isScriptureBased: json['isScriptureBased'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prompt &&
        other.id == id &&
        other.category == category &&
        other.text == text &&
        other.scriptureReference == scriptureReference &&
        other.isScriptureBased == isScriptureBased;
  }

  @override
  int get hashCode {
    return Object.hash(id, category, text, scriptureReference, isScriptureBased);
  }

  @override
  String toString() => 'Prompt(id: $id, category: $category)';
}
