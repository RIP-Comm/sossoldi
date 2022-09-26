import 'package:flutter/material.dart';

import 'package:sossoldi/pages/example/widget/example_form_widget.dart';

// database
import 'package:sossoldi/database/sossoldi_database.dart';
import 'package:sossoldi/model/example.dart';

class AddEditExamplePage extends StatefulWidget {
  final Example? example;

  const AddEditExamplePage({
    Key? key,
    this.example,
  }) : super(key: key);
  @override
  _AddEditExamplePageState createState() => _AddEditExamplePageState();
}

class _AddEditExamplePageState extends State<AddEditExamplePage> {
  final _formKey = GlobalKey<FormState>();
  late bool isImportant;
  late int number;
  late String title;
  late String description;

  @override
  void initState() {
    super.initState();

    isImportant = widget.example?.isImportant ?? false;
    number = widget.example?.number ?? 0;
    title = widget.example?.title ?? '';
    description = widget.example?.description ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: ExampleFormWidget(
            isImportant: isImportant,
            number: number,
            title: title,
            description: description,
            onChangedImportant: (isImportant) =>
                setState(() => this.isImportant = isImportant),
            onChangedNumber: (number) => setState(() => this.number = number),
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedDescription: (description) =>
                setState(() => this.description = description),
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateExample,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateExample() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.example != null;

      if (isUpdating) {
        await updateExample();
      } else {
        await addExample();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateExample() async {
    final example = widget.example!.copy(
      isImportant: isImportant,
      number: number,
      title: title,
      description: description,
    );

    await ExampleDatabase.instance.update(example);
  }

  Future addExample() async {
    final example = Example(
      title: title,
      isImportant: true,
      number: number,
      description: description,
      dataTime: DateTime.now(),
    );

    await ExampleDatabase.instance.create(example);
  }
}
