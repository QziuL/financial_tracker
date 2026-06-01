import '../../common/config/dependencies.dart';
import '../../common/theme/app_theme.dart';
import '../../domain/entity/transaction_entity.dart';
import 'package:financial_tracker/main.dart';
import 'package:financial_tracker/ui/controller/home_page_controller.dart';
import 'package:financial_tracker/ui/widget/balance_header.dart';
import 'package:financial_tracker/ui/widget/date_filter_transactions.dart';
import 'package:financial_tracker/ui/widget/summary_carousel.dart';
import 'package:financial_tracker/ui/widget/transaction_sheet.dart';
import 'package:financial_tracker/ui/widget/transaction_sheets_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late HomePageController viewModelController;
  late AnimationController _spinController;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    viewModelController = injector.get<HomePageController>();
    viewModelController.load.execute().then((_) {
      if (mounted) setState(() => _isFirstLoad = false);
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Watch((context) {
        final isLoading = viewModelController.load.runningSignal.value;
        return Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ─── App Bar
                SliverAppBar(
                  expandedHeight: 0,
                  floating: true,
                  snap: true,
                  backgroundColor:
                      isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  elevation: 0,
                  title: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.wallet_2,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FinanceTrack',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    // Refresh button
                    Watch((context) {
                      final isLoading =
                          viewModelController.load.runningSignal.value;

                      // controla o spin contínuo
                      if (isLoading) {
                        _spinController.repeat();
                      } else {
                        _spinController.stop();
                        _spinController.reset();
                      }

                      return IconButton(
                        icon: RotationTransition(
                          turns: _spinController,
                          child: Icon(
                            Iconsax.refresh,
                            color:
                                isLoading
                                    ? AppColors.primary
                                    : (isDark
                                        ? Colors.white70
                                        : AppColors.primary),
                          ),
                        ),
                        tooltip: isLoading ? 'Atualizando...' : 'Atualizar',
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  setState(() => _isFirstLoad = false);
                                  viewModelController.load.execute();
                                },
                      );
                    }),
                    // Filter button
                    Watch((context) {
                      final isVisible =
                          viewModelController.isFilterVisible.value;
                      return IconButton(
                        icon: Icon(
                          isVisible ? Iconsax.filter_remove : Iconsax.filter,
                        ),
                        tooltip:
                            isVisible ? 'Ocultar filtros' : 'Mostrar filtros',
                        onPressed: viewModelController.toggleFilterVisibility,
                        color:
                            isVisible
                                ? AppColors.primary
                                : (isDark ? Colors.white70 : Colors.black54),
                      );
                    }),
                    // Theme toggle
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: themeModeNotifier,
                      builder: (context, themeMode, _) {
                        final isCurrentlyDark = themeMode == ThemeMode.dark;
                        return IconButton(
                          icon: Icon(
                            isCurrentlyDark ? Iconsax.sun_1 : Iconsax.moon,
                          ),
                          tooltip:
                              isCurrentlyDark ? 'Modo claro' : 'Modo escuro',
                          onPressed: () {
                            themeModeNotifier.value =
                                isCurrentlyDark
                                    ? ThemeMode.light
                                    : ThemeMode.dark;
                          },
                          color: isDark ? Colors.white70 : Colors.black54,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                  ],
                ),

                // ─── Content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance header card
                      Watch((context) {
                        final income = viewModelController.totalIncome.value;
                        final expense = viewModelController.totalExpense.value;
                        final balance = viewModelController.balance.value;
                        return BalanceHeader(
                          totalIncome: income,
                          totalExpense: expense,
                          balance: balance,
                        );
                      }),

                      // Filter section
                      Watch((context) {
                        final isVisible =
                            viewModelController.isFilterVisible.value;
                        return AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          child:
                              isVisible
                                  ? DateFilterTransactions(
                                    filtro: (
                                      type: viewModelController.filterType,
                                      startDate: viewModelController.startDate,
                                      endDate: viewModelController.endDate,
                                    ),
                                    onFilterChanged: (startDate, endDate) {
                                      viewModelController
                                          .searchTransactionsByDate
                                          .execute(startDate!, endDate!);
                                    },
                                    onUpdateFilter: (type, startDate, endDate) {
                                      viewModelController.setFiltersParams(
                                        type,
                                        startDate,
                                        endDate,
                                      );
                                    },
                                    onAllTransactionsFiltered: () {
                                      viewModelController.load.execute();
                                    },
                                    onTapHideFilter:
                                        viewModelController
                                            .toggleFilterVisibility,
                                  )
                                  : const SizedBox.shrink(),
                        );
                      }),

                      // Chart carousel
                      Watch((context) {
                        final income = viewModelController.totalIncome.value;
                        final expense = viewModelController.totalExpense.value;
                        return SummaryCarousel(
                          totalIncome: income,
                          totalExpense: expense,
                        );
                      }),

                      // Action buttons — Adicionar Receita / Despesa
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                context,
                                label: 'Nova Receita',
                                icon: Iconsax.add_circle,
                                gradient: const LinearGradient(
                                  colors: [AppColors.income, Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onPressed: () => _showIncomeSheet(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                context,
                                label: 'Nova Despesa',
                                icon: Iconsax.minus_cirlce,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.expense,
                                    Color(0xFFDC2626),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                onPressed: () => _showExpenseSheet(context),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Transaction list
                      Watch((context) {
                        final incomes = viewModelController.incomes.value;
                        final expenses = viewModelController.expenses.value;
                        return TransactionCardSheets(
                          incomeTransactions: incomes,
                          expenseTransactions: expenses,
                          onDelete: (id) {
                            viewModelController.deleteTransaction.execute(id);
                          },
                          onEdit: (transaction) => _showEditSheet(context, transaction),
                          undoDelete:
                              viewModelController.undoDelectedTransaction,
                          scaffoldContext: context,
                        );
                      }),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
            // ─── Loading overlay banner (apenas no refresh manual) ───
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: (isLoading && !_isFirstLoad) ? 0 : -80,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Atualizando dados...',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withValues(
                alpha: 0.4,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomeSheet(BuildContext context) {
    TransactionSheet.show(
      context: context,
      type: TransactionType.income,
      submitCommand: viewModelController.saveTransaction,
    );
  }

  void _showExpenseSheet(BuildContext context) {
    TransactionSheet.show(
      context: context,
      type: TransactionType.expense,
      submitCommand: viewModelController.saveTransaction,
    );
  }

  void _showEditSheet(BuildContext context, TransactionEntity transaction) {
    TransactionSheet.show(
      context: context,
      type: transaction.type,
      submitCommand: viewModelController.saveTransaction,
      initialTransaction: transaction,
    );
  }
}
