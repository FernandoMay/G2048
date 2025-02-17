import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Web3Service {
  late Web3Client _client;
  late DeployedContract _contract;
  
  Future<void> initialize(String rpcUrl, String contractAddress, String abiPath) async {
    _client = Web3Client(rpcUrl, Client());
    
    final abiString = await rootBundle.loadString(abiPath);
    final abi = jsonDecode(abiString);
    
    _contract = DeployedContract(
      ContractAbi.fromJson(jsonEncode(abi), 'Game2048'),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  Future<void> startGame(Credentials credentials) async {
    final function = _contract.function('startGame');
    await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [],
      ),
    );
  }

  Future<void> makeMove(Credentials credentials, int direction) async {
    final function = _contract.function('makeMove');
    await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [BigInt.from(direction)],
      ),
    );
  }

  Future<Map<String, dynamic>> getGameState() async {
    final function = _contract.function('getGameState');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );

    return {
      'board': _convertBoard(result[0]),
      'isGameOver': result[1] as bool,
      'isWon': result[2] as bool,
      'score': (result[3] as BigInt).toInt(),
    };
  }

  List<List<int>> _convertBoard(List<dynamic> board) {
    return board.map((row) => 
      (row as List<dynamic>).map((cell) => 
        (cell as BigInt).toInt()
      ).toList()
    ).toList();
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    final function = _contract.function('getAchievements');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );

    return (result[0] as List<dynamic>).map((achievement) => {
      'name': achievement[0] as String,
      'description': achievement[1] as String,
      'unlocked': achievement[2] as bool,
    }).toList();
  }

  Future<Map<String, int>> getHighScores() async {
    final function = _contract.function('getHighScores');
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );

    Map<String, int> highScores = {};
    final addresses = result[0] as List<EthereumAddress>;
    final scores = (result[1] as List<BigInt>).map((score) => score.toInt()).toList();

    for (var i = 0; i < addresses.length; i++) {
      highScores[addresses[i].hex] = scores[i];
    }

    return highScores;
  }

  void dispose() {
    _client.dispose();
  }
}
