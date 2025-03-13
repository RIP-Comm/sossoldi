import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";

import '../../../constants/functions.dart';
import "../../../constants/style.dart";
import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';

class AmountWidget extends ConsumerStatefulWidget {
  const AmountWidget(
    this.amountController, {
    super.key,
  });

  final TextEditingController amountController;

  @override
  ConsumerState<AmountWidget> createState() => _AmountWidgetState();
}

class _AmountWidgetState extends ConsumerState<AmountWidget> with Functions {
  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(transactionTypeProvider);
    final currencyState = ref.watch(currencyStateNotifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: TextField(
        controller: widget.amountController,
        decoration: InputDecoration(
          hintText: "0",
          border: InputBorder.none,
          prefixText: ' ',
          suffixText: currencyState.selectedCurrency.symbol,
          suffixStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: typeToColor(
                  selectedType,
                  brightness: Theme.of(context).brightness,
                ),
              ),
        ),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          // Leaving the default behaviour on Android which seems to be working as expeceted.
          signed: defaultTargetPlatform == TargetPlatform.android,
        ),
        inputFormatters: [
          // Allow only digits and one decimal separator.
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),

          // AI generated regex: checks that the String contains either one comma or
          // one period. Only two decimal digits only allowed.
          //
          // Because replacementString is not nullable and defaults to empty String
          // I've set it to the current input text so that every time a second period
          // is inserted, it won't clear the text that's already present.
          FilteringTextInputFormatter.allow(
            RegExp(r'^(\d*([.,]\d{0,2})?|[.,]\d{0,2})$'),
            replacementString: widget.amountController.text,
          ),

          // Replaces comma with period.
          FilteringTextInputFormatter.deny(RegExp(r','), replacementString: '.'),
        ],
        autofocus: false,
        textAlign: TextAlign.center,
        cursorColor: grey1,
        style: TextStyle(
          color: typeToColor(
            selectedType,
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
