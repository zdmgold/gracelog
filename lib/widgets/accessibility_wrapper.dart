import 'package:flutter/material.dart';

/// Accessibility wrapper utility ensuring every interactive element
/// has proper [Semantics] labels, hints, and actions.
///
/// Also provides [ExcludeSemantics] for decorative elements and
/// respects [MediaQuery.disableAnimationsOf] for reduced motion.
///
/// Use [AccessibleButton] for tappable targets and
/// [AccessibleTextField] for input fields.
class AccessibilityWrapper {
  AccessibilityWrapper._();

  /// Wraps a child widget with full Semantics for interactive elements.
  static Widget interactive({
    required Widget child,
    required String label,
    String? hint,
    bool? selected,
    bool? checked,
    bool? enabled,
    VoidCallback? onTapHint,
    VoidCallback? onLongPressHint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      selected: selected,
      checked: checked,
      enabled: enabled,
      onTap: onTapHint,
      onLongPress: onLongPressHint,
      button: onTapHint != null,
      child: child,
    );
  }

  /// Hides decorative elements from the accessibility tree.
  static Widget decorative({required Widget child}) {
    return ExcludeSemantics(child: child);
  }

  /// Respects the user's "Reduce Motion" system preference.
  /// Returns [duration] if motion is enabled, [Duration.zero] if disabled.
  static Duration animationDuration(
    BuildContext context, {
    required Duration duration,
  }) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    return disableAnimations ? Duration.zero : duration;
  }

  /// Respects the user's "Reduce Motion" system preference.
  /// Returns the [curve] if motion is enabled, [Curves.linear] if disabled.
  static Curve animationCurve(
    BuildContext context, {
    required Curve curve,
  }) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    return disableAnimations ? Curves.linear : curve;
  }
}

/// Pre-configured accessible button widget.
/// Ensures 48dp minimum touch target and proper Semantics.
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticsLabel,
    this.semanticsHint,
    this.minSize = const Size(48, 48),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? semanticsLabel;
  final String? semanticsHint;
  final Size minSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      button: true,
      enabled: onPressed != null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize.width,
          minHeight: minSize.height,
        ),
        child: InkWell(
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Pre-configured accessible text field with proper Semantics.
class AccessibleTextField extends StatelessWidget {
  const AccessibleTextField({
    super.key,
    required this.controller,
    this.semanticsLabel,
    this.semanticsHint,
    this.decoration,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? semanticsLabel;
  final String? semanticsHint;
  final InputDecoration? decoration;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      hint: semanticsHint,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: decoration,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
