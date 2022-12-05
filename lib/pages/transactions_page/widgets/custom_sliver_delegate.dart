import 'dart:math';

import 'package:flutter/material.dart';

import 'month_selector.dart';

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  const CustomSliverDelegate({
    required this.myTabs,
    required this.tabController,
  });

  final TabController tabController;
  final List<Tab> myTabs;

  static const double minHeight = 56.0;
  static const double expandedHeight = 140.0;

  final amount = 258.45; // get from backend

  // TODO: expand on Tap
  // TODO: snap to open/closed when it's almost open/closed

  // TODO: make header floating
  // FloatingHeaderSnapConfiguration
  // https://api.flutter.dev/flutter/widgets/SliverPersistentHeaderDelegate/snapConfiguration.html

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    /// 0 when fully extended, 1 when fully collapsed
    double shrinkPercentage = min(1, shrinkOffset / (maxExtent - minExtent));

    // TODO: improve animations
    // prevent the expanded widget from shrinking in size when collapsing
    return Container(
      color: Colors.grey.shade300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: max(
                18,
                25 * (1 - shrinkPercentage),
              ),
            ),
            child: FittedBox(
              alignment: Alignment.topLeft,
              child: Text(
                "Visualizza:",
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (shrinkPercentage < .5)
                  Opacity(
                    opacity: 1 - shrinkPercentage,
                    child: _buildExtendedWidget(context),
                  ),
                if (shrinkPercentage > .5)
                  Opacity(
                    opacity: shrinkPercentage,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildCollapsedWidget(context),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(
            thickness: 1.0,
            height: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  _buildExtendedWidget(BuildContext context) {
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TabBar(
                controller: tabController,
                labelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Color(0xFFB9BABC),
                splashBorderRadius: BorderRadius.circular(50),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color(0xFF356CA3),
                ),
                // TODO: capitalize text of the selected label
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
                tabs: myTabs,
              ),
              const SizedBox(height: 8),
              // TODO: make sure buttons are not clickable when partially collapsed
              MonthSelector(amount: amount),
            ],
          ),
        ),
      ),
    );
  }

  _buildCollapsedWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 8.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Color(0xFF356CA3),
          ),
          child: Text(
            myTabs[tabController.index].text!,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
        Text(
          "Settembre 2022",
          style:
              Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 14),
        ),
        Text(
          "$amount €",
          style: TextStyle(
              color: (amount > 0) ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Text'),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => minHeight; //kToolbarHeight + 30;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
