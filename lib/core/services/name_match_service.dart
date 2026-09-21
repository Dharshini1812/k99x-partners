// lib/features/onboarding/data/service/name_match_service.dart
//
// On-device OCR (ML Kit text recognition) to pull the printed name off an
// Aadhaar / PAN photo, plus a fuzzy comparator so minor OCR noise (case,
// spacing, a dropped middle name) doesn't produce a false "mismatch".
//
// NOTE: this is a best-effort client-side check meant to catch obvious
// typos/wrong-photo mistakes before submission. For anything that gates
// account approval, re-verify server-side against UIDAI/NSDL-backed data —
// on-device OCR on a phone photo is not a compliance-grade identity check.

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class NameExtractionResult {
  final String? rawText;
  final String? guessedName;
  NameExtractionResult({this.rawText, this.guessedName});
}

class NameMatchService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<NameExtractionResult> extractText(File image) async {
    final inputImage = InputImage.fromFile(image);
    final result = await _recognizer.processImage(inputImage);
    return NameExtractionResult(
      rawText: result.text,
      guessedName: _guessName(result.text),
    );
  }

  /// Heuristic line-picker: Aadhaar/PAN OCR text is noisy (numbers, labels,
  /// government boilerplate). A name line is usually 2-4 alphabetic words,
  /// with no digits, that isn't one of the known label words.
  String? _guessName(String rawText) {
    final skipWords = RegExp(
      r'(GOVERNMENT|INDIA|INCOME TAX|DEPARTMENT|PERMANENT|ACCOUNT|NUMBER|'
      r'DOB|DATE OF BIRTH|MALE|FEMALE|MOBILE|ADDRESS|UNIQUE|IDENTIFICATION|'
      r'AUTHORITY|SIGNATURE|FATHER)',
      caseSensitive: false,
    );

    final lines =
        rawText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);

    for (final line in lines) {
      if (skipWords.hasMatch(line)) continue;
      if (RegExp(r'\d').hasMatch(line)) continue;
      if (!RegExp(r'^[A-Za-z .]+$').hasMatch(line)) continue;
      final words = line.split(RegExp(r'\s+'));
      if (words.length < 2 || words.length > 4) continue;
      return line.trim();
    }
    return null;
  }

  /// Word-overlap fuzzy match, tolerant of a missing/extra middle name.
  bool namesLikelyMatch(String a, String b) {
    final na = _normalize(a);
    final nb = _normalize(b);
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;

    final wordsA = na.split(' ').toSet();
    final wordsB = nb.split(' ').toSet();
    final overlap = wordsA.intersection(wordsB).length;
    final smaller =
        wordsA.length < wordsB.length ? wordsA.length : wordsB.length;
    if (smaller == 0) return false;
    return overlap / smaller >= 0.7;
  }

  String _normalize(String s) => s
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z ]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  void dispose() => _recognizer.close();
}
