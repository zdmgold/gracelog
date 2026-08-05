import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/category_suggestion.dart';
import '../core/utils/constants.dart';

/// Reusable gratitude item input field with category auto-suggest.
///
/// Features:
///   - Min 10 chars, max 200 chars with live counter
///   - Category auto-suggest dropdown based on keyword matching
///   - Filled background (bgTertiary), 12px radius, focused border
///   - 48dp touch target, haptic feedback on submit
class GratitudeInputField extends StatefulWidget {
  const GratitudeInputField({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onCategorySuggested,
    this.hintText = 'I am grateful for...',
    this.minLength = 10,
    this.maxLength = 200,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onCategorySuggested;
  final String hintText;
  final int minLength;
  final int maxLength;

  @override
  State<GratitudeInputField> createState() => _GratitudeInputFieldState();
}

class _GratitudeInputFieldState extends State<GratitudeInputField> {
  String? _suggestedCategory;
  bool _showSuggestion = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text.toLowerCase();
    if (text.length < 3) {
      setState(() {
        _showSuggestion = false;
        _suggestedCategory = null;
      });
      return;
    }

    String? match;
    for (final category in CategorySuggestion.predefined) {
      for (final keyword in category.keywords) {
        if (text.contains(keyword.toLowerCase())) {
          match = category.name;
          break;
        }
      }
      if (match != null) break;
    }

    setState(() {
      _suggestedCategory = match;
      _showSuggestion = match != null;
    });

    if (match != null) {
      widget.onCategorySuggested?.call(match);
    }
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.controller.text.length;
    final isValid = length >= widget.minLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          maxLength: widget.maxLength,
          maxLines: 3,
          minLines: 1,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            if (value.trim().length >= widget.minLength) {
              HapticFeedback.lightImpact();
              widget.onSubmitted?.call(value.trim());
            }
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: AppColors.bgTertiary,
            counterText: '$length/${widget.maxLength}',
            counterStyle: TextStyle(
              fontSize: 12,
              color: isValid
                  ? AppColors.textSecondary
                  : AppColors.textError,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderFocus,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        if (_showSuggestion && _suggestedCategory != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Chip(
              avatar: const Icon(Icons.auto_awesome, size: 16),
              label: Text('Category: $_suggestedCategory'),
              backgroundColor: AppColors.bgSecondary,
              side: BorderSide.none,
            ),
          ),
      ],
    );
  }
}
