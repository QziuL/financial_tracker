import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import '../../common/utils/formatter.dart';
import '../../domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Widget que exibe uma lista de transações de receitas e despesas em abas
class TransactionCardSheets extends StatefulWidget {
  final List<TransactionEntity> incomeTransactions;
  final List<TransactionEntity> expenseTransactions;
  final Function(String id) onDelete;
  final Function(TransactionEntity transaction) onEdit;
  final Command1<void, Failure, TransactionEntity> undoDelete;
  final BuildContext scaffoldContext;

  const TransactionCardSheets({
    super.key,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.onDelete,
    required this.onEdit,
    required this.undoDelete,
    required this.scaffoldContext,
  });

  @override
  State<TransactionCardSheets> createState() => _TransactionCardSheetsState();
}

class _TransactionCardSheetsState extends State<TransactionCardSheets>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ─── Header com abas ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.receipt_item,
                      size: 16,
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Transações',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    // Contagem de transações
                    _buildCountBadge(context),
                  ],
                ),
                const SizedBox(height: 12),
                // Tab bar customizado
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            _tabController.index == 0
                                ? [AppColors.income, const Color(0xFF059669)]
                                : [AppColors.expense, const Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (_tabController.index == 0
                                  ? AppColors.income
                                  : AppColors.expense)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      _buildTab(
                        context,
                        title: TransactionType.income.namePlural,
                        icon: Iconsax.arrow_up_2,
                        count: widget.incomeTransactions.length,
                        isSelected: _tabController.index == 0,
                      ),
                      _buildTab(
                        context,
                        title: TransactionType.expense.namePlural,
                        icon: Iconsax.arrow_down_2,
                        count: widget.expenseTransactions.length,
                        isSelected: _tabController.index == 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Lista de transações ──────────────────────────────────
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(
                  context,
                  transactions: widget.incomeTransactions,
                  isIncome: true,
                ),
                _buildTransactionList(
                  context,
                  transactions: widget.expenseTransactions,
                  isIncome: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(BuildContext context) {
    final isIncome = _tabController.index == 0;
    final count =
        isIncome
            ? widget.incomeTransactions.length
            : widget.expenseTransactions.length;
    final color = isIncome ? AppColors.income : AppColors.expense;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count ${count == 1 ? 'item' : 'itens'}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int count,
    required bool isSelected,
  }) {
    return Tab(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context, {
    required List<TransactionEntity> transactions,
    required bool isIncome,
  }) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context, isIncome: isIncome);
    }

    final color = isIncome ? AppColors.income : AppColors.expense;
    final icon = isIncome ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      physics: const BouncingScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final undoTransaction = transaction.copyWith();

        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.expense, Color(0xFFDC2626)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Iconsax.trash, color: Colors.white, size: 22),
                SizedBox(height: 4),
                Text(
                  'Excluir',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) async {
            await widget.onDelete(transaction.id);

            ScaffoldMessenger.of(widget.scaffoldContext).clearSnackBars();
            ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Iconsax.trash, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"${transaction.title}" excluída',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.expense,
                action: SnackBarAction(
                  label: 'DESFAZER',
                  textColor: Colors.white,
                  onPressed: () async {
                    await widget.undoDelete.execute(undoTransaction);
                    if (widget.undoDelete.resultSignal.value?.isSuccess ??
                        false) {
                      ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text('"${transaction.title}" restaurada!'),
                          backgroundColor: AppColors.income,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget
                                    .undoDelete
                                    .resultSignal
                                    .value
                                    ?.failureValueOrNull
                                    ?.toString() ??
                                'Erro ao restaurar',
                          ),
                          backgroundColor: AppColors.expense,
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
          child: InkWell(
            onTap: () => widget.onEdit(transaction),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.dividerDark.withValues(alpha: 0.5)
                        : color.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isIncome
                              ? [
                                AppColors.income.withValues(alpha: 0.2),
                                AppColors.income.withValues(alpha: 0.1),
                              ]
                              : [
                                AppColors.expense.withValues(alpha: 0.2),
                                AppColors.expense.withValues(alpha: 0.1),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                title: Text(
                  transaction.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      size: 11,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.black38,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      Formatter.formatDate(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white38
                                : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (isIncome ? '+' : '-') +
                        Formatter.formatCurrency(transaction.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ), // closes trailing Container
              ), // closes ListTile
            ), // closes AnimatedContainer
          ), // closes InkWell
        ); // closes Dismissible
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isIncome}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isIncome ? AppColors.income : AppColors.expense;
    final icon = isIncome ? Iconsax.coin : Iconsax.shopping_cart;
    final message =
        isIncome ? 'Nenhuma receita registrada' : 'Nenhuma despesa registrada';
    final hint =
        isIncome
            ? 'Adicione uma receita para começar!'
            : 'Adicione uma despesa para acompanhar seus gastos!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
