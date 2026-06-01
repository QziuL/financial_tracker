import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/common/types/date_filter_type.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

/// Widget para filtrar transações por data
class DateFilterTransactions extends StatefulWidget {
  final Function(DateTime? startDate, DateTime? endDate) onFilterChanged;
  final Function() onAllTransactionsFiltered;
  final Function(DateFilterType type, DateTime? startDate, DateTime? endDate)
      onUpdateFilter;
  final VoidCallback? onTapHideFilter;
  final ({DateFilterType type, DateTime? startDate, DateTime? endDate}) filtro;

  const DateFilterTransactions({
    super.key,
    required this.onFilterChanged,
    required this.filtro,
    this.onTapHideFilter,
    required this.onAllTransactionsFiltered,
    required this.onUpdateFilter,
  });

  @override
  State<DateFilterTransactions> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterTransactions> {
  late DateFilterType _filterType;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _filterType = widget.filtro.type;
    _startDate = widget.filtro.startDate;
    _endDate = widget.filtro.endDate;
    _initializeDates();
  }

  void _initializeDates() {
    final now = DateTime.now();
    final range = _filterType.resolveRange(now, _startDate, _endDate);
    setState(() {
      _startDate = range?.start;
      _endDate = range?.end;
    });
  }

  void _applyFilter(DateFilterType type) {
    setState(() {
      _filterType = type;
      _initializeDates();
    });

    if (type == DateFilterType.all) {
      widget.onAllTransactionsFiltered();
    } else {
      widget.onFilterChanged(_startDate, _endDate);
    }
    widget.onUpdateFilter(_filterType, _startDate, _endDate);
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 1));
    final safeRange = _filterType
        .resolveRange(now, _startDate, _endDate)
        ?.cappedAt(maxDate);

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: safeRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _filterType = DateFilterType.custom;
        _startDate = pickedDateRange.start;
        _endDate = DateTime(
          pickedDateRange.end.year,
          pickedDateRange.end.month,
          pickedDateRange.end.day,
          23,
          59,
          59,
        );
      });

      widget.onFilterChanged(_startDate, _endDate);
      widget.onUpdateFilter(_filterType, _startDate, _endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Cabeçalho ───────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.filter,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Filtrar por Período',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onTapHideFilter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Iconsax.close_circle,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ─── Chips de filtro ──────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(DateFilterType.all, 'Tudo', Iconsax.calendar),
              _buildFilterChip(DateFilterType.today, 'Hoje', Iconsax.sun_1),
              _buildFilterChip(
                  DateFilterType.week, 'Esta Semana', Iconsax.calendar_2),
              _buildFilterChip(DateFilterType.month, 'Este Mês', Iconsax.moon),
              _buildFilterChip(
                  DateFilterType.custom, 'Personalizado', Iconsax.calendar_edit),
            ],
          ),

          // ─── Intervalo personalizado ──────────────────────────────
          if (_filterType == DateFilterType.custom &&
              _startDate != null &&
              _endDate != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectCustomDateRange,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.calendar_1,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(_startDate!)} — ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Iconsax.edit,
                      size: 13,
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(DateFilterType type, String label, IconData icon) {
    final isSelected = _filterType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (type == DateFilterType.custom) {
          _selectCustomDateRange();
        } else {
          _applyFilter(type);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
