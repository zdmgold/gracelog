import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/utils/constants.dart';
import '../core/models/category_suggestion.dart';

/// Reusable gratitude item input field with category auto-suggest.
///
/// Features:
///   - Min 10 chars, max 200 chars with live counter
///   - Category auto-suggest dropdown based on keyword matching
///   - Filled background, 12px radius, focused border
///   - 48dp touch target, haptic feedback on submit
///   - Animated underline progress indicator
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
  bool _isFocused = false;

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
    final theme = Theme.of(context);
    final length = widget.controller.text.length;
    final isValid = length >= widget.minLength;
    final progress = (length / widget.maxLength).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: TextField(
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
              fillColor: theme.colorScheme.surfaceContainerHighest,
              counterText: '$length/${widget.maxLength}',
              counterStyle: TextStyle(
                fontSize: 12,
                color: isValid
                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                    : theme.colorScheme.error,
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
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.error,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        // Animated underline progress
        AnimatedContainer(
          duration: AppConstants.durationFast,
          height: 2,
          width: _isFocused
              ? MediaQuery.of(context).size.width * progress
              : 0,
          margin: const EdgeInsets.only(top: 2, left: 16, right: 16),
          decoration: BoxDecoration(
            color: isValid
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        if (_showSuggestion && _suggestedCategory != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Chip(
              avatar: const Icon(Icons.auto_awesome, size: 16),
              label: Text('Category: $_suggestedCategory'),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
            ),
          ),
      ],
    );
  }
}
