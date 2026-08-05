import 'package:flutter/foundation.dart';

/// Immutable model representing a gratitude category suggestion.
@immutable
class CategorySuggestion {
  const CategorySuggestion({
    required this.name,
    required this.iconName,
    required this.keywords,
  });

  final String name;
  final String iconName;
  final List<String> keywords;

  CategorySuggestion copyWith({
    String? name,
    String? iconName,
    List<String>? keywords,
  }) {
    return CategorySuggestion(
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      keywords: keywords ?? this.keywords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconName': iconName,
      'keywords': keywords,
    };
  }

  factory CategorySuggestion.fromJson(Map<String, dynamic> json) {
    return CategorySuggestion(
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategorySuggestion &&
        other.name == name &&
        other.iconName == iconName &&
        listEquals(other.keywords, keywords);
  }

  @override
  int get hashCode {
    return Object.hash(name, iconName, Object.hashAll(keywords));
  }

  @override
  String toString() {
    return 'CategorySuggestion(name: $name)';
  }
}

/// Pre-populated default categories.
class DefaultCategories {
  const DefaultCategories._();

  static const List<CategorySuggestion> all = [
    CategorySuggestion(
      name: 'Family',
      iconName: 'family_restroom',
      keywords: ['family', 'parents', 'children', 'siblings', 'home'],
    ),
    CategorySuggestion(
      name: 'Health',
      iconName: 'favorite',
      keywords: ['health', 'healing', 'body', 'strength', 'energy'],
    ),
    CategorySuggestion(
      name: 'Provision',
      iconName: 'attach_money',
      keywords: ['provision', 'money', 'job', 'work', 'finances', 'food'],
    ),
    CategorySuggestion(
      name: 'Grace',
      iconName: 'auto_fix_high',
      keywords: ['grace', 'mercy', 'forgiveness', 'salvation', 'redemption'],
    ),
    CategorySuggestion(
      name: 'Nature',
      iconName: 'park',
      keywords: ['nature', 'sun', 'rain', 'trees', 'flowers', 'sky'],
    ),
    CategorySuggestion(
      name: 'Friends',
      iconName: 'people',
      keywords: ['friends', 'community', 'church', 'fellowship', 'people'],
    ),
    CategorySuggestion(
      name: 'Work',
      iconName: 'work',
      keywords: ['work', 'career', 'calling', 'ministry', 'purpose'],
    ),
    CategorySuggestion(
      name: 'Rest',
      iconName: 'bedtime',
      keywords: ['rest', 'sleep', 'peace', 'quiet', 'sabbath'],
    ),
    CategorySuggestion(
      name: 'Church',
      iconName: 'church',
      keywords: ['church', 'worship', 'sermon', 'prayer', 'pastor'],
    ),
    CategorySuggestion(
      name: 'Scripture',
      iconName: 'menu_book',
      keywords: ['scripture', 'bible', 'verse', 'word', 'promise'],
    ),
  ];

  /// Returns the best matching category for a given input text.
  static CategorySuggestion? match(String input) {
    final lower = input.toLowerCase();
    for (final category in all) {
      for (final keyword in category.keywords) {
        if (lower.contains(keyword.toLowerCase())) {
          return category;
        }
      }
    }
    return null;
  }
}
