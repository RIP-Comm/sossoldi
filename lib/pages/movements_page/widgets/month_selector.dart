import 'package:flutter/material.dart';

class MonthSelector extends StatelessWidget {
  MonthSelector({
    required this.amount,
    Key? key,
  }) : super(key: key);

  double amount;
  double height = 60;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: implement date picker for custom period
        print('Choose a custom range of dates');
      },
      child: Container(
        clipBehavior: Clip.antiAlias, // force rounded corners on children
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFFf1f5f9),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Container(
                height: height,
                width: height,
                color: Color(0xFF00152d),
                child: const Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                // TODO: implement moving to previus month
                print("Move to previus month");
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Settembre 2022",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Text(
                  "$amount €",
                  style: TextStyle(
                      color: (amount > 0) ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Text'),
                ),
              ],
            ),
            GestureDetector(
              child: Container(
                height: height,
                width: height,
                color: Color(0xFF00152d),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                // TODO: implement moving to next month
                print("Move to next month");
              },
            ),
          ],
        ),
      ),
    );
  }
}
