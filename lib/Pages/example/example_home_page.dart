// Home page.
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sossoldi/pages/example/edit_example_page.dart';
import 'package:sossoldi/pages/example/widget/example_card_widget.dart';
import 'package:sossoldi/pages/example/example_detail_page.dart';

// database
import 'package:sossoldi/database/sossoldi_database.dart';
import 'package:sossoldi/model/example.dart';

class HomePageExample extends StatefulWidget {
  @override
  State<HomePageExample> createState() => _HomePageExampleState();
}

class _HomePageExampleState extends State<HomePageExample> {
  late List<Example> examples;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshExamples();
  }

  @override
  void dispose() {
    ExampleDatabase.instance.close();

    super.dispose();
  }

  Future refreshExamples() async {
    setState(() => isLoading = true);

    this.examples = await ExampleDatabase.instance.readAll();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Examples',
            style: TextStyle(fontSize: 24),
          ),
          actions: [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : examples.isEmpty
                  ? Text(
                      'No Examples',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  : buildExamples(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddEditExamplePage()),
            );

            refreshExamples();
          },
        ),
      );

  Widget buildExamples() => StaggeredGridView.countBuilder(
        padding: EdgeInsets.all(8),
        itemCount: examples.length,
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final example = examples[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ExampleDetailPage(exampleId: example.id!),
              ));

              refreshExamples();
            },
            child: ExampleCardWidget(example: example, index: index),
          );
        },
      );
}
