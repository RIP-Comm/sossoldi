import 'package:flutter/material.dart';

import "../../../constants/style.dart";

class LabelListTile extends StatelessWidget {
  const LabelListTile(
    this.labelController, {
    super.key,
  });

  final TextEditingController labelController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Icon(
                Icons.description,
                size: 24.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "Description",
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: labelController,
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: "Add a description", hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary
              )),
              textAlign: TextAlign.end,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
