import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class QuickActionChips extends StatelessWidget {
  /// Called with the English prompt string when a chip is tapped.
  final Function(String prompt) onChipTap;

  const QuickActionChips({super.key, required this.onChipTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();

    // Visible label is translated; prompt sent to AI is always English.
    final chips = <(String label, String prompt)>[
      (lang.chipUdidCard,         'How do I apply for a UDID card?'),
      (lang.chipSchemes,          'What disability schemes are available in India?'),
      (lang.chipRights,           'What are my rights under the Rights of Persons with Disabilities (RPWD) Act 2016?'),
      (lang.chipNearbyHelp,       'How do I find nearby disability help centers?'),
      (lang.chipPensionBenefits,  'What pension and financial benefits can I get?'),
      (lang.chipEducation,        'What education support is available for persons with disabilities?'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, prompt) = chips[index];
          return ActionChip(
            label: Text(label),
            onPressed: () => onChipTap(prompt),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: 13,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}