//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol";

import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
// import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import {IERC20} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

error WrongTokenSent(string tokenSent);

contract RemoteLendingManager is AxelarExecutable {
    string public lendingToken;

    constructor(
        address _gateway,
        string memory tokenSymbol
    ) AxelarExecutable(_gateway) {
        lendingToken = tokenSymbol;
    }

    function _executeWithToken(
        string calldata srcChain,
        string calldata srcAddress,
        bytes calldata payload,
        string calldata tokenSymbol,
        uint256 amount
    ) internal override {
        if (
            keccak256(abi.encodePacked(tokenSymbol)) !=
            keccak256(abi.encodePacked(lendingToken))
        ) revert WrongTokenSent(tokenSymbol);
    }
}
