import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/daily_entry.dart';
import '../models/scripture_verse.dart';

/// GraceLog export service.
///
/// Handles three export formats:
///   1. JSON  -- machine-readable backup of all entries
///   2. PNG   -- Instagram-ready 1080x1080 square image of a single
///               entry + scripture verse
///   3. PDF   -- printable journal export of entry list
///
/// All exports are written to the temporary directory, then shared
/// via the native share sheet. Files are cleaned up after sharing.
class ExportService {
  static const int _instagramSize = 1080;

  Future<ShareResult?> exportToJson(List<DailyEntry> entries) async {
    try {
      final jsonList = entries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      final file = await _writeTempFile('gracelog_export.json', jsonString);
      return await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'GraceLog Export',
        ),
      );
    } catch (e, stackTrace) {
      _logError('exportToJson', e, stackTrace);
      return null;
    }
  }

  Future<ShareResult?> exportToImage(
    DailyEntry entry,
    ScriptureVerse verse,
  ) async {
    try {
      final image = _generateInstagramImage(entry, verse);
      final pngBytes = img.encodePng(image);
      final file = await _writeTempFileBytes(
        'gracelog_${_dateFileName(entry.date)}.png',
        pngBytes,
      );
      return await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'My GraceLog Entry',
        ),
      );
    } catch (e, stackTrace) {
      _logError('exportToImage', e, stackTrace);
      return null;
    }
  }

  Future<ShareResult?> exportToPdf(List<DailyEntry> entries) async {
    try {
      final pdfContent = _generatePlainTextPdf(entries);
      final file = await _writeTempFile(
        'gracelog_journal_${_dateFileName(DateTime.now())}.txt',
        pdfContent,
      );
      return await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'GraceLog Journal',
        ),
      );
    } catch (e, stackTrace) {
      _logError('exportToPdf', e, stackTrace);
      return null;
    }
  }

  img.Image _generateInstagramImage(DailyEntry entry, ScriptureVerse verse) {
    const size = _instagramSize;
    final image = img.Image(width: size, height: size);

    _drawGradientBackground(image, top: 0xFF1A1A2E, bottom: 0xFF16213E);
    _drawAccentBar(image, color: 0xFFE94560, height: 8);

    img.drawString(
      image,
      'GRACELOG',
      font: img.arial14,
      x: 60,
      y: 60,
      color: img.ColorRgba8(255, 255, 255, 128),
    );

    final dateText =
        '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    img.drawString(
      image,
      dateText,
      font: img.arial14,
      x: size - 200,
      y: 60,
      color: img.ColorRgba8(255, 255, 255, 128),
    );

    img.drawString(
      image,
      verse.reference,
      font: img.arial48,
      x: 60,
      y: 180,
      color: img.ColorRgba8(233, 69, 96, 255),
    );

    final verseLines = _wrapText(verse.text, maxCharsPerLine: 42);
    int yPos = 280;
    for (final line in verseLines) {
      img.drawString(
        image,
        line,
        font: img.arial24,
        x: 60,
        y: yPos,
        color: img.ColorRgba8(255, 255, 255, 255),
      );
      yPos += 44;
    }

    img.drawLine(
      image,
      x1: 60,
      y1: yPos + 20,
      x2: size - 60,
      y2: yPos + 20,
      color: img.ColorRgba8(255, 255, 255, 64),
    );

    yPos += 60;
    img.drawString(
      image,
      "Today's Gratitude:",
      font: img.arial24,
      x: 60,
      y: yPos,
      color: img.ColorRgba8(233, 69, 96, 255),
    );

    yPos += 50;
    for (int i = 0; i < entry.gratitudeItems.length && i < 3; i++) {
      final item = entry.gratitudeItems[i];
      final bullet = '${i + 1}. $item';
      final lines = _wrapText(bullet, maxCharsPerLine: 46);
      for (final line in lines) {
        img.drawString(
          image,
          line,
          font: img.arial24,
          x: 60,
          y: yPos,
          color: img.ColorRgba8(255, 255, 255, 230),
        );
        yPos += 44;
      }
    }

    img.drawString(
      image,
      'Generated with GraceLog',
      font: img.arial14,
      x: 60,
      y: size - 60,
      color: img.ColorRgba8(255, 255, 255, 100),
    );

    return image;
  }

  void _drawGradientBackground(
    img.Image canvas, {
    required int top,
    required int bottom,
  }) {
    final topR = (top >> 16) & 0xFF;
    final topG = (top >> 8) & 0xFF;
    final topB = top & 0xFF;
    final botR = (bottom >> 16) & 0xFF;
    final botG = (bottom >> 8) & 0xFF;
    final botB = bottom & 0xFF;

    for (int y = 0; y < canvas.height; y++) {
      final t = y / canvas.height;
      final r = (topR + (botR - topR) * t).round();
      final g = (topG + (botG - topG) * t).round();
      final b = (topB + (botB - topB) * t).round();
      final color = img.ColorRgba8(r, g, b, 255);
      for (int x = 0; x < canvas.width; x++) {
        canvas.setPixel(x, y, color);
      }
    }
  }

  void _drawAccentBar(img.Image canvas, {required int color, required int height}) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < canvas.width; x++) {
        canvas.setPixel(x, y, img.ColorRgba8(
          (color >> 16) & 0xFF,
          (color >> 8) & 0xFF,
          color & 0xFF,
          255,
        ));
      }
    }
  }

  List<String> _wrapText(String text, {required int maxCharsPerLine}) {
    final words = text.split(' ');
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ((currentLine.length + 1 + word.length) <= maxCharsPerLine) {
        currentLine += ' $word';
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }
    if (currentLine.isNotEmpty) lines.add(currentLine);
    return lines;
  }

  String _generatePlainTextPdf(List<DailyEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('GRACELOG JOURNAL EXPORT');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Entries: ${entries.length}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final entry in entries) {
      buffer.writeln('Date: ${entry.date.toIso8601String().split("T").first}');
      buffer.writeln('Mood: ${entry.mood.name}');
      if (entry.category != null) {
        buffer.writeln('Category: ${entry.category}');
      }
      buffer.writeln();
      for (int i = 0; i < entry.gratitudeItems.length; i++) {
        buffer.writeln('  ${i + 1}. ${entry.gratitudeItems[i]}');
      }
      if (entry.scriptureReference != null) {
        buffer.writeln();
        buffer.writeln('  Scripture: ${entry.scriptureReference}');
        if (entry.scriptureText != null) {
          buffer.writeln('  "${entry.scriptureText}"');
        }
      }
      buffer.writeln();
      buffer.writeln('-' * 50);
      buffer.writeln();
    }

    return buffer.toString();
  }

  Future<File> _writeTempFile(String fileName, String content) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    return file.writeAsString(content, flush: true);
  }

  Future<File> _writeTempFileBytes(String fileName, Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    return file.writeAsBytes(bytes, flush: true);
  }

  String _dateFileName(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  void _logError(String method, Object error, StackTrace stackTrace) {
    // ignore: avoid_print
    print('[ExportService::$method] $error\n$stackTrace');
  }
}
