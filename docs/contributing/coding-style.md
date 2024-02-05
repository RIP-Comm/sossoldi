---
title: Coding style
layout: default
nav_order: 3
parent: How to contribute to the project
---

# Coding style

If you want to help out with the project you should keep in mind the following guidelines.

## Formatting

- Follow the official Dart Style Guide for code formatting.
- Use consistent indentation.
- Limit line length to 80 characters.

## Imports

Import packages using the following format:
```bash
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
Use relative imports for local files:
```bash
import '../../../providers/accounts_provider.dart';
```

## Break down pages into separate widgets

In order to improve readability of our code we should break down each page into separate widgets stored in separate files, with each of them representing a section of the page.
Each page should be wrapped in a folder with the same name containing a widgets subfolder that stores custom widgets extracted from that page.
```bash
Example:
├── transactions_page.dart
└── widgets
    ├── accounts_tab.dart
    ├── categories_tab.dart
    ├── custom_sliver_delegate.dart
    ├── list_tab.dart
    └── month_selector.dart
```
The widgets subfolder should contain widgets that are specific to a particular page, whereas the ones that are shared across multiple pages should go in /lib/custom_widgets.

## Use trailing comma

Flutter code often involves building fairly deep tree-shaped data structures, for example in a build method. To get good automatic formatting, we recommend you adopt the optional trailing commas. The guideline for adding a trailing comma is simple: Always add a trailing comma at the end of a parameter list in functions, methods, and constructors where you care about keeping the formatting you crafted. This helps the automatic formatter to insert an appropriate amount of line breaks for Flutter-style code.
See here.

## Avoid Copy/Paste:

Do not copy and paste code blocks without proper understanding. Instead of duplicating code, consider creating a shared function or method and if you do so add a line in the [Reusable Widget List](widget-list.html).

## File Structure:

Organize files in a clear and consistent folder structure. Group related files together, such as placing all providers in a 'providers' folder.

## Naming Conventions:

Follow camelCase for variable and function names. Use clear and descriptive names for variables, functions, and classes.

By following these coding styles, you will help ensure consistency, readability, and maintainability of codebase in the project.