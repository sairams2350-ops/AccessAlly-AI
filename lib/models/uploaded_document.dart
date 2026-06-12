class UploadedDocument {
  final String id;
  final String name;
  final String storagePath;
  final String downloadUrl;
  final String category;
  final String extension;
  final String? extractedText;
  final DateTime uploadedAt;

  UploadedDocument({
    required this.id,
    required this.name,
    required this.storagePath,
    required this.downloadUrl,
    required this.category,
    required this.extension,
    this.extractedText,
    required this.uploadedAt,
  });

  String get iconEmoji {
    switch (extension.toLowerCase()) {
      case 'pdf': return '📄';
      case 'doc':
      case 'docx': return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png': return '🖼️';
      case 'xlsx':
      case 'csv': return '📊';
      default: return '📎';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'udid': return 'UDID Certificate';
      case 'medical': return 'Medical Report';
      case 'checklist': return 'Checklist';
      case 'academic': return 'Academic Doc';
      default: return 'Document';
    }
  }
}
