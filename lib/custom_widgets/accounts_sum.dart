import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../model/bank_account.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import 'account_modal.dart';

/// This class shows account summaries in dashboard
class AccountsSum extends StatelessWidget with Functions {
  final BankAccount account;

  const AccountsSum({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      margin: const EdgeInsets.fromLTRB(0, 4, 16, 6),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [defaultShadow],
      ),
      child: Container(
      decoration: BoxDecoration(
        color: accountColorList[account.color].withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showModalBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                isDismissible: true,
                builder: (BuildContext buildContext) {
                  return DraggableScrollableSheet(
                    builder: (_, controller) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color(0xff356CA3),
                      ),
                      child: ListView(
                        controller: controller,
                        children: [
                          AccountDialog(
                            accountName: account.name,
                            amount: account.value,
                          )
                        ],
                      ),
                    ),
                    initialChildSize: 0.7,
                    minChildSize: 0.5,
                    maxChildSize: 1,
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accountColorList[account.color],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(accountIconList[account.symbol], size: 20.0, color: white),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(account.name, style: Theme.of(context).textTheme.bodyLarge),
                      RichText(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: numToCurrency(account.value),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            TextSpan(
                              text: "€",
                              style: Theme.of(context).textTheme.bodyMedium?.apply(
                                fontFeatures: [const FontFeature.subscripts()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
