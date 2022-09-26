import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sossoldi/pages/example/edit_example_page.dart';

// database
import 'package:sossoldi/database/sossoldi_database.dart';
import 'package:sossoldi/model/example.dart';

class ExampleDetailPage extends StatefulWidget {
  final int exampleId;

  const ExampleDetailPage({
    Key? key,
    required this.exampleId,
  }) : super(key: key);

  @override
  _ExampleDetailPageState createState() => _ExampleDetailPageState();
}

class _ExampleDetailPageState extends State<ExampleDetailPage> {
  late Example example;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshExample();
  }

  Future refreshExample() async {
    setState(() => isLoading = true);

    this.example = await ExampleDatabase.instance.read(widget.exampleId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      example.title,
                      style: TextStyle(
                        color: Colors.black, // Colors.white
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(example.dataTime),
                      style: TextStyle(color: Colors.black), // Colors.white38
                    ),
                    SizedBox(height: 8),
                    Text(
                      example.description,
                      style: TextStyle(
                          color: Colors.black, fontSize: 18), // Colors.white70
                    )
                  ],
                ),
              ),
      );

  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditExamplePage(example: example),
        ));

        refreshExample();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          await ExampleDatabase.instance.delete(widget.exampleId);

          Navigator.of(context).pop();
        },
      );
}
