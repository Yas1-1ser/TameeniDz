import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/data/user_repository.dart';
import 'package:tameenidz/features/shared/domain/models/user_model.dart';

final usersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(userRepositoryProvider).streamUsers();
});
