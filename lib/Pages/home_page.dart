// Home page.

import 'package:flutter/material.dart';
import 'package:sossoldi/widgets/CustomAppBar.dart';
import 'package:sossoldi/widgets/actionBar.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        body:Center(
          child: Column(
            children: <Widget>[
              Expanded(
                    // Replace Center() and put the ListView here
                child: Center(
                  child: Text(
                    "Sossoldi",
                       style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ),
            ],
          )
        )
    );
  }
}
