import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/transactions_provider.dart';
import '../../ui/snack_bars/transactions_snack_bars.dart';
import 'widgets/accounts_tab.dart';
import 'widgets/add_transaction_card.dart';
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
  late List<Tab> myTabs = [];
  late TabController _tabController;
  late ScrollController _scrollController;

  final double headerMaxHeight = 140.0;
  final double headerMinHeight = 56.0;

  @override
  void initState() {
    super.initState();

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

    final l10n = AppLocalizations.of(context)!;
    if(myTabs.isEmpty)
    {
      myTabs = [
        Tab(text: l10n.list, height: 35),
        Tab(text: l10n.categories, height: 35),
        Tab(text: l10n.accounts, height: 35),
      ];
      _tabController = TabController(vsync: this, length: myTabs.length);
      // Reset the selected index when switch tab
      _tabController.addListener(() => ref.invalidate(selectedListIndexProvider));
    }


    _tabController = TabController(vsync: this, length: myTabs.length);

    ref.listen(
      duplicatedTransactionProvider,
      (prev, curr) => showDuplicatedTransactionSnackBar(
        context,
        transaction: curr,
        ref: ref,
      ),
    );
    final transactionsExistsAsync = ref.watch(transactionsExistsProvider);

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
      child: transactionsExistsAsync.when(
        data: (transactionsExists) {
          if (transactionsExists) {
            return LayoutBuilder(
              key: ValueKey(transactionsExists),
              builder: (context, constraints) {
                return NestedScrollView(
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
                    children: const [ListTab(), CategoriesTab(), AccountsTab()],
                  ),
                );
              },
            );
          }

          return const AddTransactionCard();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            "An error occurred: $error",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
