import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/constants.dart';
import '../model/bank_account.dart';
import '../constants/functions.dart';
import '../constants/style.dart';
import '../../../providers/accounts_provider.dart';

/// This class shows account summaries in the dashboard
class AccountsSum extends ConsumerWidget with Functions {
  final BankAccount account;

  const AccountsSum({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Locale currentLocale = Localizations.localeOf(context);
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
          color: accountColorListTheme[account.color].withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              await ref
                  .read(accountsProvider.notifier)
                  .selectedAccount(account)
                  .whenComplete(
                      () => Navigator.of(context).pushNamed('/account'));
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accountColorListTheme[account.color],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        accountIconList[account.symbol],
                        size: 20.0,
                        color: white,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        account.name,
                        style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: darkBlue7),
                      ), // TODO: set dinamically instead of hardcoded
                      FutureBuilder<num?>(
                        future: BankAccountMethods().getAccountSum(account.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show a loading indicator while waiting for the future to complete
                            return Transform.scale(
                              scale: 0.5,
                              child: const CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            // Show an error message if the future encounters an error
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Display the result once the future completes successfully
                            final accountSum = snapshot.data ?? 0;
                            return RichText(
                              textScaleFactor:
                                  MediaQuery.of(context).textScaleFactor,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: numToCurrency(accountSum,
                                        currentLocale.languageCode),
                                    style:
                                        Theme.of(context).textTheme.titleSmall!.copyWith(color: darkBlue7),
                                  ),
                                  TextSpan(
                                    text: "€",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.apply(
                                      fontFeatures: [
                                        const FontFeature.subscripts()
                                      ],
                                    ).copyWith(color: darkBlue7),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
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
