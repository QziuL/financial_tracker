import 'summary_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../common/theme/app_theme.dart';

class SummaryCarousel extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;

  const SummaryCarousel({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<SummaryCarousel> createState() => _SummaryCarouselState();
}

class _SummaryCarouselState extends State<SummaryCarousel>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ─── Título da seção ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Icon(
                Iconsax.chart_2,
                size: 16,
                color: isDark ? Colors.white60 : Colors.black45,
              ),
              const SizedBox(width: 6),
              Text(
                'Visão Geral',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Indicador de página
              Row(
                children: List.generate(
                  2,
                  (index) => TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: _currentPage == index ? 1.0 : 0.0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: value * 20 + 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── Carrossel ──────────────────────────────────────────────
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: 2,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                HapticFeedback.selectionClick();
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: index == 0
                      ? _buildIncomeExpenseCards(context)
                      : SummaryChart(
                          totalIncome: widget.totalIncome,
                          totalExpense: widget.totalExpense,
                        ),
                );
              },
            ),
          ),
        ),

        // ─── Dica de swipe ─────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            _currentPage == 0 ? 'Deslize para ver o gráfico →' : '← Deslize para ver o resumo',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white30 : Colors.black26,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseCards(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Income card
        Expanded(
          child: _StatCard(
            label: 'Receitas',
            icon: Iconsax.home_trend_up,
            value: widget.totalIncome,
            gradient: const LinearGradient(
              colors: [AppColors.income, Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        // Expense card
        Expanded(
          child: _StatCard(
            label: 'Despesas',
            icon: Iconsax.trend_down,
            value: widget.totalExpense,
            gradient: const LinearGradient(
              colors: [AppColors.expense, Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final Gradient gradient;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient)
                .colors
                .first
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
