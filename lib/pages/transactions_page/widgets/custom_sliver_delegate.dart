import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../constants/style.dart';
import 'month_selector.dart';

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  const CustomSliverDelegate({
    required this.ticker,
    required this.myTabs,
    required this.tabController,
    required this.expandedHeight,
    required this.minHeight,
  });

  final TabController tabController;
  final List<Tab> myTabs;
  final TickerProvider ticker;

  final double minHeight;
  final double expandedHeight;

  final amount = 258.45; // get from backend

  // TODO: expand on Tap

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    /// 0 when fully extended, 1 when fully collapsed
    double shrinkPercentage = min(1, shrinkOffset / (maxExtent - minExtent));

    // TODO: improve animations
    // prevent the expanded widget from shrinking in size when collapsing

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        border: const Border(
          bottom: BorderSide(width: 1.0, color: grey2),
        ),
      ),
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
                "View:",
                style: Theme.of(context).textTheme.titleLarge,
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
                    child: _buildExtendedWidget(context, shrinkPercentage),
                  ),
                if (shrinkPercentage > .5)
                  Opacity(
                    opacity: shrinkPercentage,
                    child: _buildCollapsedWidget(context),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  _buildExtendedWidget(BuildContext context, double shrinkPercentage) {
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.fitHeight,
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: IgnorePointer(
            // disable all buttons during the transition
            ignoring: (shrinkPercentage != 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                TabBar(
                  controller: tabController,
                  tabs: myTabs,
                  labelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  unselectedLabelColor: grey2,
                  splashBorderRadius: BorderRadius.circular(50),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  // TODO: capitalize text of the selected label
                  // not possible from TextStyle https://github.com/flutter/flutter/issues/22695
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  unselectedLabelStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 8),
                MonthSelector(amount: amount),
              ],
            ),
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
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Text(
            myTabs[tabController.index].text!,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white),
          ),
        ),
        Text(
          "Settembre 2022",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          "$amount €",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: (amount > 0) ? green : red),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  TickerProvider? get vsync => ticker;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration {
    return FloatingHeaderSnapConfiguration(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 200),
    );
  }
}
