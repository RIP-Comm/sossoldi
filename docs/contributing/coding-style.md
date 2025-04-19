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

## Adpot the Clean Architecture (feature-based folder structure)

The project is organized using the Clean Architecture pattern, which separates the code into three main layers: Data, Domain, and Presentation. This separation of concerns helps to keep the codebase organized and maintainable.

The main layers are:
- **Data Layer**: This layer is responsible for data management. It contains the repositories, data sources, and any other code related to data management.
- **Domain Layer**: This layer is responsible for the business logic. It contains the use cases, entities, and any other code related to business logic.
- **Presentation Layer**: This layer is responsible for the user interface and user experience. It contains the widgets, screens, and any other UI-related code.

An example of the folder structure is as follows:

```bash
lib/
├── features/
│   ├── accounts/
│   │   ├── data/ # Data layer, responsible for data management (providers, repositories, etc.)
│   │   ├── domain/ # Domain layer, where you define models and use cases
│   │   └── presentation/ # Presentation layer, where you define widgets and screens
```

## Use trailing comma

Flutter code often involves building fairly deep tree-shaped data structures, for example in a build method. To get good automatic formatting, we recommend you adopt the optional trailing commas. The guideline for adding a trailing comma is simple: Always add a trailing comma at the end of a parameter list in functions, methods, and constructors where you care about keeping the formatting you crafted. This helps the automatic formatter to insert an appropriate amount of line breaks for Flutter-style code.
See here.

## Avoid Copy/Paste:

Do not copy and paste code blocks without proper understanding. Instead of duplicating code, consider creating a shared function or method and if you do so add a line in the [Reusable Widget List](widget-list.html).

## Naming Conventions:

Follow camelCase for variable and function names. Use clear and descriptive names for variables, functions, and classes.

By following these coding styles, you will help ensure consistency, readability, and maintainability of codebase in the project.