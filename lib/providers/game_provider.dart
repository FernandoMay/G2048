import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:g2048/controllers/game_controller.dart';
import 'package:g2048/services/web3_service.dart';

final web3Provider = Provider<Web3Service>((ref) {
  return Web3Service();
});

final gameProvider = gameControllerProvider;

final isBlockchainConnectedProvider = StateProvider<bool>((ref) => false);
