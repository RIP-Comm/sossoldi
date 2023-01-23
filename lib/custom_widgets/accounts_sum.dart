import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/style.dart';
import 'account_modal.dart';

/// This class shows account summaries in dashboard
class AccountsSum extends StatelessWidget {
  final String accountName;
  final num amount;
  final String accountLogo;

  const AccountsSum({
    super.key,
    required this.accountName,
    required this.amount,
    this.accountLogo = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      margin: const EdgeInsets.fromLTRB(0, 4, 16, 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD7E2ED),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [defaultShadow],
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
                          accountName: accountName,
                          amount: amount,
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
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.settings, size: 20.0, color: Color(0xFFD7E2ED)),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(accountName, style: Theme.of(context).textTheme.bodyLarge),
                    RichText(
                      textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: amount.toStringAsFixed(2),
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
    );
  }
}
