import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/univerinfo_reponsitory.dart';

// Tạo một instance của repository
final univerInfoRepositoryProvider = Provider<UniverInfoRepository>((ref) {
  return UniverInfoRepository();
});

// Provider cho danh sách ngành (nganhs)
final nganhsFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchNganhs();
});

// Provider cho danh sách đơn vị (donvis)
final donvisFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchDonVis();
});

// Provider cho danh sách chuyên ngành (chuyenNganhs)
final chuyenNganhFutureProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(univerInfoRepositoryProvider);
  return await repository.fetchChuyenNganh();
});

