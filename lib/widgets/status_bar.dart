// lib/widgets/status_bar.dart

import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final String label;
  final double currentValue;
  final double totalValue;
  final Color barColor;
  final VoidCallback? onPercentageTap;

  const StatusBar({
    super.key,
    required this.label,
    required this.currentValue,
    required this.totalValue,
    required this.barColor,
    this.onPercentageTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (totalValue > 0) ? (currentValue / totalValue).clamp(0.0, 1.0) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label: ${currentValue.toStringAsFixed(0)} / ${totalValue.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              GestureDetector(
                onTap: onPercentageTap,
                child: Text(
                  '(${(percentage * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}