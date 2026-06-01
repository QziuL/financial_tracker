import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Formulário reutilizável para adicionar receitas ou despesas
class TransactionForm extends StatefulWidget {
  final Command1<void, Failure, TransactionEntity> submitCommand;
  final TransactionType type;
  final bool isIncome;

  final TransactionEntity? initialTransaction;

  const TransactionForm({
    super.key,
    required this.type,
    required this.isIncome,
    required this.submitCommand,
    this.initialTransaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Color get _accentColor =>
      widget.isIncome ? AppColors.income : AppColors.expense;

  Color get _accentColorLight =>
      widget.isIncome ? AppColors.incomeLight : AppColors.expenseLight;

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      _titleController.text = widget.initialTransaction!.title;
      _amountController.text = widget.initialTransaction!.amount.toStringAsFixed(2).replaceAll('.', ',');
      _selectedDate = widget.initialTransaction!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _accentColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final enteredTitle = _titleController.text.trim();
      final enteredAmount = double.parse(_amountController.text.replaceAll(',', '.'));

      final newTransaction = TransactionEntity(
        id: widget.initialTransaction?.id,
        title: enteredTitle,
        amount: enteredAmount,
        date: _selectedDate,
        type: widget.type,
      );

      await widget.submitCommand.execute(newTransaction);

      if (widget.submitCommand.resultSignal.value?.isFailure ?? false) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao adicionar ${widget.type.nameSingular}: '
              '${widget.submitCommand.resultSignal.value?.failureValueOrNull ?? 'Erro desconhecido'}',
            ),
            backgroundColor: AppColors.expense,
          ),
        );
        if (mounted) Navigator.pop(context);
        return;
      }

      _titleController.clear();
      _amountController.clear();
      setState(() => _selectedDate = DateTime.now());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                widget.isIncome ? Iconsax.tick_circle : Iconsax.close_circle,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text('${widget.type.nameSingular} adicionada com sucesso!'),
            ],
          ),
          backgroundColor: _accentColor,
        ),
      );
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // ─── Badge do tipo de transação ───────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isIncome ? Iconsax.arrow_up_2 : Iconsax.arrow_down_2,
                      color: _accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.type.nameSingular.toUpperCase(),
                      style: TextStyle(
                        color: _accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Campo Descrição ──────────────────────────────────────
            _buildLabel(context, 'Descrição', Iconsax.document_text),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Ex: Aluguel, Salário...',
                prefixIcon: Icon(Iconsax.document_text, color: _accentColor, size: 20),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _accentColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe uma descrição';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ─── Campo Valor ──────────────────────────────────────────
            _buildLabel(context, 'Valor (R\$)', Iconsax.money),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: '0,00',
                prefixIcon: Icon(Iconsax.money, color: _accentColor, size: 20),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                  color: _accentColor,
                  fontWeight: FontWeight.w700,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _accentColor, width: 2),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe um valor';
                }
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null) return 'Digite um número válido';
                if (parsed <= 0) return 'O valor deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ─── Campo Data ───────────────────────────────────────────
            _buildLabel(context, 'Data', Iconsax.calendar_1),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _presentDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.dividerDark.withValues(alpha: 0.5)
                      : _accentColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar_1, color: _accentColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Iconsax.edit,
                      size: 16,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            // ─── Botão de envio ───────────────────────────────────────
            Watch((context) {
              final isRunning = widget.submitCommand.runningSignal.value;
              return GestureDetector(
                onTap: isRunning ? null : _submitForm,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isRunning
                          ? [_accentColor.withValues(alpha: 0.6), _accentColor.withValues(alpha: 0.4)]
                          : [_accentColor, _accentColorLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isRunning
                        ? []
                        : [
                            BoxShadow(
                              color: _accentColor.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  alignment: Alignment.center,
                  child: isRunning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isIncome ? Iconsax.add_circle : Iconsax.minus_cirlce,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.initialTransaction != null 
                                ? 'Atualizar ${widget.type.nameSingular}' 
                                : 'Adicionar ${widget.type.nameSingular}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
