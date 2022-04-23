import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EthereumUtils {
  http.Client httpClient;
  Web3Client ethClient;
  final contractAddress = dotenv.env["FIRST_COIN_CONTRACT_ADDRESS"];

  void initialSetup() {
    httpClient = http.Client();
    String infura =
        "https://kovan.infura.io/v3/" + dotenv.env['INFURA_PROJECT_ID'];
    ethClient = Web3Client(infura, httpClient);
  }

  Future<DeployedContract> getDeployedContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "MyTotalIQ"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future getCurrentIQ() async {
    List<dynamic> result = await query("getCurrentIQ", []);
    var myData = result[0];

    print("---> GET CURRENT = " + myData.toString());
    return myData;
  }

  Future<String> increaseIQ(double amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("increaseIQ", [bigAmount]);
    return response;
  }

  Future<String> decreaseIQ(double amount) async {
    var bigAmount = BigInt.from(amount);
    var response = await submit("decreaseIQ", [bigAmount]);
    print("-----> decreaseIQ response: $response");
    return response;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await getDeployedContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    try {
      EthPrivateKey credential =
          EthPrivateKey.fromHex(dotenv.env['METAMASK_PRIVATE_KEY']);

      DeployedContract contract = await getDeployedContract();

      final ethFunction = contract.function(functionName);

      Transaction transaction = Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
        maxGas: 100000,
      );

      final result = await ethClient.sendTransaction(
        credential,
        transaction,
        chainId:
            42, // ChainID of Kovan, more information: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md
      );

      print("RESULT = $result");
      return result;
    } catch (e) {
      print("Something wrong happened! ${e.toString()}");
      return 'Something wrong happened! ';
    }
  }
}
