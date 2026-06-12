import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../utils/theme.dart';

class TypingIndicator extends StatefulWidget {
  final String streamingContent;
  const TypingIndicator({super.key, required this.streamingContent});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _dotController;
  late List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotAnims = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(
          parent: _dotController,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.accessibility_new_rounded,
                color: Colors.white, size: 18),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.aiBubble,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: widget.streamingContent.isEmpty
                  ? _buildDots()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
                          data: widget.streamingContent,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                height: 1.6),
                            h2: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            h3: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            strong: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w700),
                            listBullet: const TextStyle(
                                color: AppTheme.accent, fontSize: 14),
                          ),
                          shrinkWrap: true,
                        ),
                        const SizedBox(height: 6),
                        _buildCursor(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _dotAnims[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _dotAnims[i].value),
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCursor() {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (_, __) => Opacity(
        opacity: (_dotController.value * 2).clamp(0, 1) < 1
            ? _dotController.value * 2
            : 2 - _dotController.value * 2,
        child: Container(
          width: 2,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
