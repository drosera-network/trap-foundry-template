import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "../src/ResponseProtocol.sol";

contract DeployResponseProtocol is Script, Test {
  
    function run() external {
        vm.startBroadcast();
        ResponseProtocol _responseProtocol = new ResponseProtocol();
        vm.stopBroadcast();
    }
}
