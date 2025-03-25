import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/functions.dart';
import '../../../constants/style.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/transactions_provider.dart';
import '../../../ui/device.dart';
import '../../../utils/formatted_date_range.dart';
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

  // TODO: expand on Tap

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    /// 0 when fully extended, 1 when fully collapsed
    double shrinkPercentage = min(1, shrinkOffset / (maxExtent - minExtent));

    // TODO: improve animations
    // prevent the expanded widget from shrinking in size when collapsing

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        border: const Border(
          bottom: BorderSide(color: grey2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    child: CollapsedWidget(myTabs, tabController),
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
                TabBar(
                  controller: tabController,
                  tabs: myTabs,
                  splashBorderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
                  indicatorPadding: EdgeInsets.symmetric(horizontal: Sizes.lg),
                  // TODO: capitalize text of the selected label
                  // not possible from TextStyle https://github.com/flutter/flutter/issues/22695
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                const MonthSelector(type: MonthSelectorType.advanced),
              ],
            ),
          ),
        ),
      ),
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

class CollapsedWidget extends StatelessWidget with Functions {
  const CollapsedWidget(this.myTabs, this.tabController, {super.key});

  final List<Tab> myTabs;
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final totalAmount = ref.watch(totalAmountProvider);
      final startDate = ref.watch(filterDateStartProvider);
      final endDate = ref.watch(filterDateEndProvider);
      final currencyState = ref.watch(currencyStateNotifier);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: Sizes.xxs,
              horizontal: Sizes.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.borderRadius * 10),
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
            getFormattedDateRange(startDate, endDate),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: numToCurrency(totalAmount),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: totalAmount >= 0 ? green : red),
                ),
                TextSpan(
                  text: currencyState.selectedCurrency.symbol,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: totalAmount >= 0 ? green : red),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
