import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileUpdateProvider = StateNotifierProvider.autoDispose((ref) => PasswordNotifier(ref));

class PasswordNotifier extends StateNotifier<ProfileStatus> {
  PasswordNotifier(this.ref) : super(ProfileStatus.initialize);
  final Ref ref;

  Future<void> onUpdate(String? centroMedico, String? email) async {
    state = ProfileStatus.loading;
    //TODO
  }

  Future<void> onDeleteProfile() async {
    state = ProfileStatus.loading;
    //TODO
  }
}

enum ProfileStatus { initialize, loading, success, failed }
