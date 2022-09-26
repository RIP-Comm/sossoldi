final String tableExample = 'example';

class ExampleFields {
  static final String id = '_id';
  static final String isImportant = 'isImportant';
  static final String number = 'number';
  static final String title = 'title';
  static final String description = 'description';
  static final String dataTime = 'dataTime';

  static final List<String> allFields = [
    id,
    isImportant,
    number,
    title,
    description,
    dataTime
  ];
}

class Example {
  final int? id;
  final bool isImportant;
  final int number;
  final String title;
  final String description;
  final DateTime dataTime;

  const Example({
    this.id,
    required this.isImportant,
    required this.number,
    required this.title,
    required this.description,
    required this.dataTime,
  });

  Example copy({
    int? id,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? dataTime,
  }) =>
      Example(
        id: id ?? this.id,
        isImportant: isImportant ?? this.isImportant,
        number: number ?? this.number,
        title: title ?? this.title,
        description: description ?? this.description,
        dataTime: dataTime ?? this.dataTime,
      );

  static Example fromJson(Map<String, Object?> json) => Example(
      id: json[ExampleFields.id] as int?,
      isImportant: json[ExampleFields.isImportant] == 1,
      number: json[ExampleFields.number] as int,
      title: json[ExampleFields.title] as String,
      description: json[ExampleFields.description] as String,
      dataTime: DateTime.parse(json[ExampleFields.dataTime] as String));

  Map<String, Object?> toJson() => {
        ExampleFields.id: id,
        ExampleFields.isImportant: isImportant ? 1 : 0,
        ExampleFields.number: number,
        ExampleFields.title: title,
        ExampleFields.description: description,
        ExampleFields.dataTime: dataTime.toIso8601String(),
      };
}
