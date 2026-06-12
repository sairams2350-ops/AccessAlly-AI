import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DocumentUploadSheet extends StatefulWidget {
  const DocumentUploadSheet({super.key});

  @override
  State<DocumentUploadSheet> createState() => _DocumentUploadSheetState();
}

class _DocumentUploadSheetState extends State<DocumentUploadSheet> {
  String? _selectedCategory;

  static const categories = [
    {
      'id': 'udid',
      'label': 'UDID / Disability Certificate',
      'desc': 'Unique Disability ID card or benchmark certificate (RPWD 2016)',
      'icon': Icons.badge_outlined,
      'color': AppTheme.accent,
    },
    {
      'id': 'medical',
      'label': 'Medical / Specialist Report',
      'desc': 'Ophthalmologist, audiologist, psychiatrist, or CRC report',
      'icon': Icons.medical_information_outlined,
      'color': Color(0xFF60A5FA),
    },
    {
      'id': 'checklist',
      'label': 'Accessibility Checklist',
      'desc': 'Campus accessibility audit or compliance checklist',
      'icon': Icons.checklist_rounded,
      'color': Color(0xFFA78BFA),
    },
    {
      'id': 'academic',
      'label': 'Academic Document',
      'desc': 'Marksheets, transcripts, or previous accommodation records',
      'icon': Icons.school_outlined,
      'color': AppTheme.accentAmber,
    },
    {
      'id': 'other',
      'label': 'Other Document',
      'desc': 'Any other supporting document for admission',
      'icon': Icons.folder_outlined,
      'color': AppTheme.textSecondary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Upload Document',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Select the type of document to upload for AI analysis',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),

          // Category List
          ...categories.map((cat) {
            final isSelected = _selectedCategory == cat['id'];
            final color = cat['color'] as Color;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.1)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? color : AppTheme.surfaceBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat['icon'] as IconData,
                          color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat['label'] as String,
                              style: TextStyle(
                                  color: isSelected
                                      ? color
                                      : AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
                          Text(cat['desc'] as String,
                              style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Supported formats note
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppTheme.textMuted, size: 16),
                SizedBox(width: 8),
                Text(
                  'Supported: PDF, DOC, DOCX, JPG, PNG, XLSX, CSV (max 10MB)',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedCategory == null
                  ? null
                  : () => Navigator.pop(
                context,
                {'category': _selectedCategory},
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                disabledBackgroundColor: AppTheme.surfaceBorder,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _selectedCategory == null
                    ? 'Select a document type'
                    : 'Choose File & Upload',
                style: TextStyle(
                  color: _selectedCategory == null
                      ? AppTheme.textMuted
                      : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
