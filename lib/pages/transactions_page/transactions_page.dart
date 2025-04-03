import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/transactions_provider.dart';
import '../../utils/snack_bars/transactions_snack_bars.dart';
import 'widgets/accounts_tab.dart';
import 'widgets/categories_tab.dart';
import 'widgets/custom_sliver_delegate.dart';
import 'widgets/list_tab.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage>
    with TickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: "List", height: 35),
    Tab(text: "Categories", height: 35),
    Tab(text: "Accounts", height: 35),
  ];

  late TabController _tabController;
  late ScrollController _scrollController;

  final double headerMaxHeight = 140.0;
  final double headerMinHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        duplicatedTransactoinProvider,
        (prev, curr) => showDuplicatedTransactionSnackBar(context,
            transaction: curr, ref: ref));

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        // snap the header open/close when it's in between the two states
        final double scrollDistance = headerMaxHeight - headerMinHeight;

        if (_scrollController.offset > 0 &&
            _scrollController.offset < scrollDistance) {
          final double snapOffset =
              (_scrollController.offset / scrollDistance > 0.5)
                  ? scrollDistance + 10
                  : 0;

          //! the app freezes on animateTo
          // // Future.microtask(() => _scrollController.animateTo(snapOffset,
          // //     duration: Duration(milliseconds: 200), curve: Curves.easeIn));

          // microtask() runs the callback after the build ends
          Future.microtask(() => _scrollController.jumpTo(snapOffset));
        }
        return false;
      },
      child: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: CustomSliverDelegate(
                ticker: this,
                myTabs: myTabs,
                tabController: _tabController,
                expandedHeight: headerMaxHeight,
                minHeight: headerMinHeight,
              ),
              pinned: true,
              floating: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            ListTab(),
            CategoriesTab(),
            AccountsTab(),
          ],
        ),
      ),
    );
  }
}
