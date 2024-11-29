// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";

contract GeerateInput is Script {
    uint256 amount = 25 * 1e18;
    string[] types =  new string[](2);
    uint256 count;
    string[] whitelist = new string[](5);
    string private inputPath = "/script/target/input.json";

    function run() public {
        types[0] = "address";
        types[1] = "uint";
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        whitelist[4] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        count = whitelist.length;
        string memory input = _createJSON();
        vm.writeFile(string.concat(vm.projectRoot(), inputPath), input);

        console.log("DONE: The output is found at %s", inputPath);
    }

     function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(amount); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint"], "count":', countString, ',"values": {');
        for (uint256 i = 0; i < whitelist.length; i++) {
            if (i == whitelist.length - 1) {
                json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',amountString,'"', ' }');
            } else {
            json = string.concat(json, '"', vm.toString(i), '"', ': { "0":', '"',whitelist[i],'"',', "1":', '"',amountString,'"', ' },');
            }
        }
        json = string.concat(json, '} }');
        return json;
    }

}