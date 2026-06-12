import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/uploaded_document.dart';

class DocumentService {
  static const allowedExtensions = ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg', 'xlsx', 'csv', 'txt'];
  static const maxFileSizeMB = 10;

  Future<PickedDocument?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final sizeMB = file.size / (1024 * 1024);
    if (sizeMB > maxFileSizeMB) {
      throw Exception('File too large. Maximum size is ${maxFileSizeMB}MB.');
    }

    return PickedDocument(
      name: file.name,
      extension: file.extension?.toLowerCase() ?? 'bin',
      bytes: file.bytes,
      size: file.size,
    );
  }

  Future<UploadedDocument> processDocument({
    required PickedDocument picked,
    required String sessionId,
    required String documentCategory,
    Function(double)? onProgress,
  }) async {
    onProgress?.call(0.3);
    await Future.delayed(const Duration(milliseconds: 400));
    final text = await _extractText(picked);
    onProgress?.call(1.0);

    return UploadedDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: picked.name,
      storagePath: 'local/${picked.name}',
      downloadUrl: '',
      category: documentCategory,
      extension: picked.extension,
      extractedText: text,
      uploadedAt: DateTime.now(),
    );
  }

  Future<String> _extractText(PickedDocument picked) async {
    if (picked.bytes == null) return '[No content available]';
    switch (picked.extension) {
      case 'txt':
      case 'csv':
        try { return String.fromCharCodes(picked.bytes!); } catch (_) {}
        break;
      case 'pdf':
        try {
          final document = PdfDocument(inputBytes: picked.bytes!);
          final extractor = PdfTextExtractor(document);
          final text = extractor.extractText();
          document.dispose();
          if (text.trim().isNotEmpty) return text;
        } catch (_) {}
        return '[PDF: ${picked.name}] — Could not extract text. File size: ${(picked.size / 1024).toStringAsFixed(1)} KB';
      case 'jpg':
      case 'jpeg':
      case 'png':
        final base64Data = base64Encode(picked.bytes!);
        return '[IMAGE_BASE64:${picked.extension}]$base64Data';
      case 'doc':
      case 'docx':
        return '[Word Document: ${picked.name}]\n'
            'File size: ${(picked.size / 1024).toStringAsFixed(1)} KB\n'
            'Please share the key points from this document for AI analysis.';
    }
    return '[Document: ${picked.name}] — ${(picked.size / 1024).toStringAsFixed(1)} KB';
  }

  static String getCategoryLabel(String category) {
    const map = {
      'udid': 'UDID / Disability Certificate',
      'medical': 'Medical / Specialist Report',
      'checklist': 'Compliance Checklist',
      'academic': 'Academic Document',
      'other': 'General Document',
    };
    return map[category] ?? 'Document';
  }
}

class PickedDocument {
  final String name;
  final String extension;
  final Uint8List? bytes;
  final int size;
  PickedDocument({required this.name, required this.extension, this.bytes, required this.size});
}