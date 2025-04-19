import 'dart:io';

import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../constants/style.dart";
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/transactions_provider.dart';
import '../../utils/decimal_text_input_formatter.dart';
import '../../../ui/device.dart';
import '../../../ui/extensions.dart';

class AmountWidget extends ConsumerStatefulWidget {
  const AmountWidget(
    this.amountController, {
    super.key,
  });

  final TextEditingController amountController;

  @override
  ConsumerState<AmountWidget> createState() => _AmountWidgetState();
}

class _AmountWidgetState extends ConsumerState<AmountWidget> {
  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(transactionTypeProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Sizes.lg, vertical: Sizes.xl),
      child: TextField(
        controller: widget.amountController,
        decoration: InputDecoration(
          hintText: "0",
          border: InputBorder.none,
          prefixText: ' ',
          suffixText: currencyState.selectedCurrency.symbol,
          suffixStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: selectedType.toColor(
                  brightness: Theme.of(context).brightness,
                ),
              ),
        ),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          // Leaving the default behaviour on Android which seems to be working as expeceted.
          signed: Platform.isAndroid,
        ),
        inputFormatters: [
          DecimalTextInputFormatter(decimalDigits: 2),
        ],
        autofocus: false,
        textAlign: TextAlign.center,
        cursorColor: grey1,
        style: TextStyle(
          color: selectedType.toColor(
            brightness: Theme.of(context).brightness,
          ),
          fontSize: 58,
          fontWeight: FontWeight.bold,
        ),
        onTapOutside: (_) {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
      ),
    );
  }
}
