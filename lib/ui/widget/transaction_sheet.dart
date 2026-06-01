import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'transaction_form.dart';

/// Bottom sheet para adicionar transações de receita ou despesa
class TransactionSheet extends StatelessWidget {
  final TransactionType type;
  final Command1<void, Failure, TransactionEntity> submitCommand;

  const TransactionSheet({
    super.key,
    required this.type,
    required this.submitCommand,
  });

  static Future<void> show({
    required BuildContext context,
    required TransactionType type,
    required Command1<void, Failure, TransactionEntity> submitCommand,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              TransactionSheet(type: type, submitCommand: submitCommand),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = type == TransactionType.income;

    final gradient =
        isIncome
            ? const LinearGradient(
              colors: [AppColors.income, Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
            : const LinearGradient(
              colors: [AppColors.expense, Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    final iconData = isIncome ? Iconsax.home_trend_up : Iconsax.trend_down;
    final formTitle = type.nameSingular;
    final availableHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      height: availableHeight,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header com gradiente
          Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(iconData, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Adicionar $formTitle',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.close_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Formulário
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: TransactionForm(
                  type: type,
                  isIncome: isIncome,
                  submitCommand: submitCommand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
