import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';
import '../core/models/scripture_verse.dart';
import '../core/providers/entries_provider.dart';
import '../core/services/scripture_engine.dart';
import '../core/utils/constants.dart';
import '../widgets/gratitude_input_field.dart';
import '../widgets/mood_selector.dart';
import '../widgets/scripture_card.dart';

/// Daily gratitude entry form.
///
/// Features:
///   - Dynamic list of 3+ gratitude items
///   - Mood selector with scripture suggestion
///   - Category auto-suggest
///   - Save with validation (min 3 items, 10 chars each)
///   - Haptic feedback on save
///   - Success animation
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

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final List<TextEditingController> _itemControllers = [];
  MoodType _selectedMood = MoodType.thankful;
  ScriptureVerse? _suggestedVerse;
  String? _category;
  bool _isSaving = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
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
    _entriesProvider.dispose();
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
    setState(() {
      _selectedMood = mood;
      _suggestedVerse = ScriptureEngine().getVerseForMood(mood);
    });
  }

  Future<void> _saveEntry() async {
    if (_isSaving) return;

    // Validation
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
      HapticFeedback.mediumImpact();
      setState(() => _showSuccess = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();
    } else {
      _showError('Failed to save entry. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textError,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: AppColors.textPrimary),
        ),
        title: Text(
          'New Entry',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveEntry,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentPrimary,
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentPrimary,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                MoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: _onMoodSelected,
                ),
                const SizedBox(height: 24),
                Text(
                  'What are you grateful for?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add at least 3 items (10+ characters each)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._buildItemFields(),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _addItemField,
                  icon: Icon(Icons.add, color: AppColors.accentPrimary),
                  label: Text(
                    'Add another item',
                    style: TextStyle(color: AppColors.accentPrimary),
                  ),
                ),
                const SizedBox(height: 24),
                if (_suggestedVerse != null) ...[
                  Text(
                    'Suggested Scripture',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
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
                        style: TextStyle(color: AppColors.accentPrimary),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
          if (_showSuccess)
            Container(
              color: Colors.black54,
              child: Center(
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildItemFields() {
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
                  color: AppColors.textError,
                ),
                tooltip: 'Remove item',
              ),
          ],
        ),
      );
    });
  }
}
