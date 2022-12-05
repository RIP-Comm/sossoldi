import 'package:flutter/material.dart';

import 'widgets/custom_sliver_delegate.dart';
import 'widgets/categories_tab.dart';
import 'widgets/accounts_tab.dart';
import 'widgets/list_tab.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  static const List<Tab> myTabs = <Tab>[
    Tab(text: "Elenco", height: 35),
    Tab(text: "Cateogorie", height: 35),
    Tab(text: "Conti", height: 35),
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverPersistentHeader(
              delegate: CustomSliverDelegate(
                myTabs: myTabs,
                tabController: _tabController,
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
