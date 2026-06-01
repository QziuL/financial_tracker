import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/common/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

/// Header principal da tela inicial com saldo atual e resumo financeiro
class BalanceHeader extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const BalanceHeader({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  State<BalanceHeader> createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = widget.balance >= 0;
    final now = DateTime.now();
    final greeting = _getGreeting();

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Saudação
            Row(
              children: [
                Text(
                  '$greeting 👋',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat("dd 'de' MMM, yyyy", 'pt_BR').format(now),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Card de Saldo Atual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      isPositive
                          ? [const Color(0xFF6D28D9), const Color(0xFF4F46E5)]
                          : [const Color(0xFFDC2626), const Color(0xFF9F1239)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isPositive ? AppColors.primary : AppColors.expense)
                        .withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + Ícone visibilidade
                  Row(
                    children: [
                      const Icon(
                        Iconsax.empty_wallet,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Saldo Atual',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap:
                            () => setState(
                              () => _balanceVisible = !_balanceVisible,
                            ),
                        child: Icon(
                          _balanceVisible ? Iconsax.eye : Iconsax.eye_slash,
                          color: Colors.white54,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Valor do saldo
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _balanceVisible
                            ? Text(
                              key: const ValueKey('visible'),
                              Formatter.formatCurrency(widget.balance),
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 34,
                              ),
                            )
                            : Text(
                              key: const ValueKey('hidden'),
                              '•••••••',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                color: Colors.white54,
                                fontSize: 34,
                                letterSpacing: 4,
                              ),
                            ),
                  ),

                  const SizedBox(height: 20),

                  // Receitas e Despesas
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          context,
                          icon: Iconsax.arrow_up_2,
                          label: 'Receitas',
                          value: widget.totalIncome,
                          color: AppColors.incomeLight,
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Expanded(
                        child: _buildMiniStat(
                          context,
                          icon: Iconsax.arrow_down_2,
                          label: 'Despesas',
                          value: widget.totalExpense,
                          color: AppColors.expenseLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Formatter.formatCurrency(value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour > 5 && hour < 12) return 'Bom dia';
    if (hour > 12 && hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}
