import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class KitStepProgress extends StatelessWidget {
  const KitStepProgress({
    super.key,
    required this.labels,
    required this.currentIndex,
  });

  final List<String> labels;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: i <= currentIndex
                    ? KitColors.primary
                    : KitColors.border,
              ),
            ),
          _StepDot(
            index: i,
            label: labels[i],
            state: i < currentIndex
                ? _StepState.done
                : i == currentIndex
                    ? _StepState.active
                    : _StepState.upcoming,
          ),
        ],
      ],
    );
  }
}

enum _StepState { done, active, upcoming }

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.label,
    required this.state,
  });

  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isActive = state != _StepState.upcoming;
    final color = isActive ? KitColors.primary : KitColors.border;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: state == _StepState.upcoming
                ? KitColors.white
                : KitColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: state == _StepState.done
              ? const Icon(Icons.check_rounded, size: 16, color: KitColors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: state == _StepState.active
                        ? KitColors.white
                        : KitColors.textHint,
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? KitColors.textPrimary : KitColors.textHint,
          ),
        ),
      ],
    );
  }
}
