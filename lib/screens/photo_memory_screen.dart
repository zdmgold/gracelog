import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/models/daily_entry.dart';
import '../core/models/mood_type.dart';
import '../core/providers/entries_provider.dart';
import '../core/utils/haptics.dart';
import '../widgets/mood_selector.dart';

/// Quick photo-memory gratitude entry.
///
/// Flow: pick a photo (camera or gallery), pick a mood, optional
/// short caption, save. Only the photo itself is required — caption
/// and mood default are both optional, matching the same "fast
/// capture, not a second full form" principle as Voice Note.
class PhotoMemoryScreen extends StatefulWidget {
  const PhotoMemoryScreen({super.key});

  @override
  State<PhotoMemoryScreen> createState() => _PhotoMemoryScreenState();
}

class _PhotoMemoryScreenState extends State<PhotoMemoryScreen> {
  final EntriesProvider _entriesProvider = EntriesProvider();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  MoodType _selectedMood = MoodType.thankful;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _captionController.dispose();
    // EntriesProvider intentionally not disposed — instance-per-screen
    // convention established in Batch 1.
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, maxWidth: 2000, imageQuality: 85);
      if (picked == null) return;

      Haptics.tap(context);
      setState(() => _selectedImage = File(picked.path));
    } catch (e) {
      _showError(
        source == ImageSource.camera
            ? 'Could not open the camera. Please try again.'
            : 'Could not open your photo library. Please try again.',
      );
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from library'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_selectedImage == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Copy into app-managed storage — image_picker's returned path
      // can point to a cache location the OS may clear independently
      // of this app, so we persist a durable copy the way the audio
      // recorder already does.
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${dir.path}/gracelog_photos');
      if (!await photoDir.exists()) {
        await photoDir.create(recursive: true);
      }
      final ext = _selectedImage!.path.split('.').last;
      final savedPath = '${photoDir.path}/${const Uuid().v4()}.$ext';
      final savedFile = await _selectedImage!.copy(savedPath);

      final caption = _captionController.text.trim();
      final entry = DailyEntry(
        id: const Uuid().v4(),
        date: DateTime.now(),
        gratitudeItems: [caption.isNotEmpty ? caption : 'Photo memory'],
        mood: _selectedMood,
        photoPaths: [savedFile.path],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _entriesProvider.addEntry(entry);

      if (!mounted) return;

      if (success) {
        Haptics.success(context);
        Navigator.of(context).pop();
      } else {
        setState(() => _isSaving = false);
        _showError('Failed to save. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError('Something went wrong saving the photo. Please try again.');
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text('Photo Memory', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageArea(theme),
              const SizedBox(height: 24),
              if (_selectedImage != null) ...[
                Text('How are you feeling?', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                MoodSelector(selectedMood: _selectedMood, onMoodSelected: (mood) => setState(() => _selectedMood = mood)),
                const SizedBox(height: 20),
                TextField(
                  controller: _captionController,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    hintText: 'Add a short caption (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveEntry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                          )
                        : const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(ThemeData theme) {
    if (_selectedImage == null) {
      return InkWell(
        onTap: _showPickerSheet,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text('Tap to add a photo', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(_selectedImage!, height: 320, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: _showPickerSheet,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Choose a different photo',
            ),
          ),
        ),
      ],
    );
  }
}
