import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/settings_provider.dart';

class NotificationTypeTile extends ConsumerStatefulWidget {
  final NotificationReminderType type;
  final VoidCallback setNotificationTypeCallback;

  const NotificationTypeTile(
      {super.key, required this.type, required this.setNotificationTypeCallback});

  @override
  NotificationTypeTileState createState() => NotificationTypeTileState();
}

class NotificationTypeTileState extends ConsumerState<NotificationTypeTile> {
  late SharedPreferences prefs;
  bool isPrefInizialized = false;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isPrefInizialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isPrefInizialized) return Container();

    NotificationReminderType? notificationReminderType =
        NotificationReminderType.values.firstWhere((e) =>
            e.toString().split('.').last ==
            prefs.getString('transaction-reminder-cadence'));

    final typeName =
        "${widget.type.name[0].toUpperCase()}${widget.type.name.substring(1).toLowerCase()}";

    return GestureDetector(
      onTap: () {
        widget.setNotificationTypeCallback.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        width: MediaQuery.of(context).size.width,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: notificationReminderType == widget.type
                ? Colors.blue
                : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                typeName,
                style: TextStyle(
                  color: notificationReminderType == widget.type
                      ? Colors.blue
                      : Colors.black,
                ),
              ),
              const Spacer(),
              notificationReminderType == widget.type
                  ? const Icon(
                      Icons.check,
                      color: Colors.blue,
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
