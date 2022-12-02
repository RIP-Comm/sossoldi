import 'package:flutter/material.dart';

class ElencoTab extends StatelessWidget {
  const ElencoTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            "Elenco $index",
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.blue),
          ),
        );
      },
    );
  }
}
