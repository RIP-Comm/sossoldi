import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sossoldi/custom_widgets/account_modal.dart';

/// This class shows account summaries in dashboard
class AccountsSum extends StatelessWidget {
  final accountName;
  final amount;
  final accountLogo;
  const AccountsSum(
      {super.key,
      required this.accountName,
      required this.amount,
      this.accountLogo = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 145.0,
        child: Card(
          semanticContainer: true,
          child: Column(
            children: [
              ListTile(
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
                          child:
                            ListView(
                              controller: controller,
                              children: [
                                AccountDialog(accountName: accountName,)
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
                leading: Container(
                  child: Image(
                      width: 27.0,
                      image: AssetImage(accountLogo),
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Container(
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(Icons.settings, size: 15.0),
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(217, 217, 217, 1)),
                        );
                      }),
                ),
                contentPadding: EdgeInsets.only(left: 8.0, right: 8.0),
                horizontalTitleGap: -8.0,
                title: Text(accountName,
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              Transform.translate(
                  offset: Offset(0, -10),
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: amount,
                        style: Theme.of(context).textTheme.titleSmall),
                    TextSpan(
                      text: "€",
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.apply(fontFeatures: [FontFeature.subscripts()]),
                    ),
                  ]))),
            ],
          ),
        ));
  }
}
