import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';
import '../core/models/scripture_verse.dart';
import '../core/providers/app_state_provider.dart';
import '../core/providers/entries_provider.dart';
import '../core/services/scripture_engine.dart';

/// Bedtime reflection screen.
///
/// Simplified entry mode with OLED-black background (#000000), one
/// gratitude item, peaceful mood default, sleep-prompt scripture,
/// and a "Save" close button.
///
/// Colors here are intentionally hardcoded (not theme-driven) — this
/// screen must stay true black regardless of light/dark theme, for
/// genuine OLED power savings and reduced brightness before sleep.
class BedtimeReflectionScreen extends StatefulWidget {
  const BedtimeReflectionScreen({super.key});

  @override
  State<BedtimeReflectionScreen> createState() => _BedtimeReflectionScreenState();
}

class _BedtimeReflectionScreenState extends State<BedtimeReflectionScreen> {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final AppStateProvider _appStateProvider = AppStateProvider();
  final TextEditingController _controller = TextEditingController();
  ScriptureVerse? _sleepVerse;
  bool _isSaving = false;
  bool _weTurnedOnBedtimeMode = false;

  @override
  void initState() {
    super.initState();
    if (!_appStateProvider.value.isBedtimeMode) {
      _appStateProvider.toggleBedtimeMode();
      _weTurnedOnBedtimeMode = true;
    }
    _loadSleepVerse();
  }

  Future<void> _loadSleepVerse() async {
    await ScriptureEngine().initialize();
    final verse = ScriptureEngine().getVerseForMood(MoodType.peaceful) ??
        ScriptureEngine().getRandomVerse();
    if (mounted) {
      setState(() => _sleepVerse = verse);
    }
  }

  @override
  void dispose() {
    if (_weTurnedOnBedtimeMode) {
      _appStateProvider.toggleBedtimeMode();
    }
    _controller.dispose();
    // EntriesProvider intentionally not disposed — instance-per-screen
    // convention established in Batch 1.
    super.dispose();
  }

  Future<void> _saveAndRest() async {
    if (_isSaving) return;

    final text = _controller.text.trim();
    if (text.isEmpty) {
      _showError('Share one thing you are grateful for today.');
      return;
    }

    setState(() => _isSaving = true);

    final entry = DailyEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      gratitudeItems: [text],
      mood: MoodType.peaceful,
      scriptureReference: _sleepVerse?.reference,
      scriptureText: _sleepVerse?.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _entriesProvider.addEntry(entry);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      HapticFeedback.lightImpact();
      Navigator.of(context).pop();
    } else {
      _showError('Failed to save. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.nights_stay, color: Colors.white.withOpacity(0.6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bedtime Reflection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.6)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_sleepVerse != null) ...[
                Text(
                  _sleepVerse!.reference,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 8),
                Text(
                  '"${_sleepVerse!.text}"',
                  style: TextStyle(fontSize: 20, height: 1.6, color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),
              ],
              // FIX: bedtime-appropriate wording
              Text(
                'Before you go to bed, what is one thing you are grateful for today?',
                style: TextStyle(fontSize: 18, height: 1.5, color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 3,
                minLines: 1,
                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.9)),
                decoration: InputDecoration(
                  hintText: 'I am grateful for...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAndRest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white.withOpacity(0.8)),
                        )
                      // FIX: button label changed from "Rest Well" to "Save"
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Your entry is saved locally on your device.',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
