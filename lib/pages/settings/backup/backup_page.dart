import 'package:flutter/material.dart';

import 'widgets/backup_option_card.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BackupOptionsScaffold(
      title: 'Import/Export',
      options: [
        BackupOptionCard(
          title: 'Import data',
          description: 'Restore a Sossoldi backup or import from Money Manager',
          icon: Icons.upload_file,
          onTap: () => Navigator.of(context).pushNamed('/backup-import'),
        ),
        BackupOptionCard(
          title: 'Export data',
          description: 'Save your data as a database backup or a CSV file',
          icon: Icons.download,
          onTap: () => Navigator.of(context).pushNamed('/backup-export'),
        ),
      ],
    );
  }
}
