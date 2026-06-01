import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../common/theme/app_theme.dart';
import '../../common/utils/formatter.dart';

/// Widget para exibir gráfico de pizza com receitas vs despesas
class SummaryChart extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;

  const SummaryChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<SummaryChart> createState() => _SummaryChartState();
}

class _SummaryChartState extends State<SummaryChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _controller;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotateAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.totalIncome + widget.totalExpense;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          (widget.totalIncome == 0 && widget.totalExpense == 0)
              ? _buildEmptyState(context)
              : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // ─── Gráfico
                    Expanded(
                      flex: 5,
                      child: AnimatedBuilder(
                        animation: _rotateAnim,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _rotateAnim.value,
                            child: child,
                          );
                        },
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 38,
                            startDegreeOffset: -90,
                            sections: _buildSections(total),
                            pieTouchData: PieTouchData(
                              touchCallback: (event, response) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      response == null ||
                                      response.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex =
                                      response
                                          .touchedSection!
                                          .touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ─── Legenda
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegend(
                            context,
                            label: 'Receitas',
                            icon: Iconsax.arrow_up_2,
                            color: AppColors.income,
                            amount: widget.totalIncome,
                            percent:
                                total > 0
                                    ? (widget.totalIncome / total * 100)
                                    : 0,
                            isSelected: _touchedIndex == 0,
                          ),
                          const SizedBox(height: 14),
                          _buildLegend(
                            context,
                            label: 'Despesas',
                            icon: Iconsax.arrow_down_2,
                            color: AppColors.expense,
                            amount: widget.totalExpense,
                            percent:
                                total > 0
                                    ? (widget.totalExpense / total * 100)
                                    : 0,
                            isSelected: _touchedIndex == 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    final incomeRadius = _touchedIndex == 0 ? 56.0 : 48.0;
    final expenseRadius = _touchedIndex == 1 ? 56.0 : 48.0;

    if (widget.totalIncome == 0 && widget.totalExpense == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey.shade300,
          radius: 48,
          showTitle: false,
        ),
      ];
    }

    final sections = <PieChartSectionData>[];

    if (widget.totalIncome > 0) {
      sections.add(
        PieChartSectionData(
          value: widget.totalIncome,
          title: '${(widget.totalIncome / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          radius: incomeRadius,
          color: AppColors.income,
          badgeWidget:
              _touchedIndex == 0
                  ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.income,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.income.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.arrow_up_2,
                      color: Colors.white,
                      size: 12,
                    ),
                  )
                  : null,
          badgePositionPercentageOffset: 1.3,
        ),
      );
    }

    if (widget.totalExpense > 0) {
      sections.add(
        PieChartSectionData(
          value: widget.totalExpense,
          title: '${(widget.totalExpense / total * 100).toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          radius: expenseRadius,
          color: AppColors.expense,
          badgeWidget:
              _touchedIndex == 1
                  ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.expense,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.expense.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.arrow_down_2,
                      color: Colors.white,
                      size: 12,
                    ),
                  )
                  : null,
          badgePositionPercentageOffset: 1.3,
        ),
      );
    }

    return sections;
  }

  Widget _buildLegend(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required double amount,
    required double percent,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                ),
                Text(
                  Formatter.formatCurrency(amount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.chart_21,
          size: 44,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        const SizedBox(height: 10),
        Text(
          'Sem transações ainda',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        Text(
          'Adicione receitas ou despesas',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      ],
    );
  }
}
