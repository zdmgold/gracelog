import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';
import '../core/models/scripture_verse.dart';
import '../core/providers/entries_provider.dart';
import '../core/services/scripture_engine.dart';
import '../core/utils/constants.dart';
import '../core/utils/theme.dart';
import '../widgets/gratitude_input_field.dart';
import '../widgets/mood_selector.dart';
import '../widgets/scripture_card.dart';

/// Daily gratitude entry form.
///
/// Features:
/// - Dynamic list of 3+ gratitude items
/// - Mood selector with scripture suggestion, mood-tinted background
/// - Category auto-suggest
/// - Save with validation (min 3 items, 10 chars each)
/// - Haptic feedback, checkmark morph, and milestone celebration on save
class DailyEntryScreen extends StatefulWidget {
  const DailyEntryScreen({
    super.key,
    this.preselectedVerse,
  });

  /// If provided, this verse is pre-filled in the entry.
  final ScriptureVerse? preselectedVerse;

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen>
    with SingleTickerProviderStateMixin {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final List<TextEditingController> _itemControllers = [];
  late final AnimationController _checkmarkController;

  MoodType _selectedMood = MoodType.thankful;
  ScriptureVerse? _suggestedVerse;
  String? _category;
  bool _isSaving = false;
  bool _showSuccess = false;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      duration: AppConstants.durationSlow,
      vsync: this,
    );
    _addItemField();
    _addItemField();
    _addItemField();
    _suggestedVerse = widget.preselectedVerse ??
        ScriptureEngine().getVerseForMood(_selectedMood);
  }

  @override
  void dispose() {
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _checkmarkController.dispose();
    // Provider intentionally not disposed here — matches the
    // instance-per-screen convention established in Batch 1.
    super.dispose();
  }

  void _addItemField() {
    setState(() {
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItemField(int index) {
    if (_itemControllers.length <= 3) return;
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
    });
  }

  void _onMoodSelected(MoodType mood) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedMood = mood;
      _suggestedVerse = ScriptureEngine().getVerseForMood(mood);
    });
  }

  Future<void> _saveEntry() async {
    if (_isSaving) return;

    final items = _itemControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (items.length < 3) {
      _showError('Please add at least 3 gratitude items.');
      return;
    }

    final invalidItems = items.where((i) => i.length < 10).toList();
    if (invalidItems.isNotEmpty) {
      _showError('Each gratitude item must be at least 10 characters.');
      return;
    }

    setState(() => _isSaving = true);

    final entry = DailyEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      gratitudeItems: items,
      mood: _selectedMood,
      scriptureReference: _suggestedVerse?.reference,
      scriptureText: _suggestedVerse?.text,
      category: _category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _entriesProvider.addEntry(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      HapticFeedback.heavyImpact();
      final streak = await _entriesProvider.getStreak();

      if (!mounted) return;

      if (streak > 0 && AppConstants.streakMilestones.contains(streak)) {
        // Milestone: celebration overlay
        setState(() => _showConfetti = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _showConfetti = false);
      } else {
        // Regular save: checkmark morph
        setState(() => _showSuccess = true);
        _checkmarkController.forward(from: 0);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() => _showSuccess = false);
          _checkmarkController.reset();
        }
      }

      if (mounted) Navigator.of(context).pop();
    } else {
      _showError('Failed to save entry. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodColor = _selectedMood.colorToken;

    return AnimatedContainer(
      duration: theme.durationNormal,
      color: moodColor.withOpacity(0.06),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          ),
          title: Text(
            'New Entry',
            style: theme.textTheme.titleLarge,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: TextButton(
                  onPressed: _isSaving ? null : _saveEntry,
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : Text(
                          'Save',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  MoodSelector(
                    selectedMood: _selectedMood,
                    onMoodSelected: _onMoodSelected,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'What are you grateful for?',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add at least 3 items (10+ characters each)',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  ..._buildItemFields(theme),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _addItemField,
                    icon: Icon(Icons.add, color: theme.colorScheme.primary),
                    label: Text(
                      'Add another item',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_suggestedVerse != null) ...[
                    Text(
                      'Suggested Scripture',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ScriptureCard(
                      verse: _suggestedVerse!,
                      showActions: false,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _suggestedVerse = ScriptureEngine()
                                .getVerseForMood(_selectedMood);
                          });
                        },
                        child: Text(
                          'Suggest another verse',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
            if (_showSuccess) _buildSuccessOverlay(theme),
            if (_showConfetti) _buildMilestoneOverlay(theme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemFields(ThemeData theme) {
    return List.generate(_itemControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GratitudeInputField(
                controller: _itemControllers[index],
                hintText: 'I am grateful for...',
                onCategorySuggested: (cat) {
                  if (_category == null) {
                    setState(() => _category = cat);
                  }
                },
              ),
            ),
            if (_itemControllers.length > 3)
              IconButton(
                onPressed: () => _removeItemField(index),
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Remove item',
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSuccessOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _checkmarkController,
            curve: Curves.elasticOut,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.accentSuccess,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Entry Saved!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneOverlay(ThemeData theme) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              color: AppColors.accentWarm,
              size: 72,
            ),
            const SizedBox(height: 16),
            Text(
              'Milestone reached!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Keep the streak alive.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
