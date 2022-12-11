//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol";

import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import {IERC20} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

contract SourceLender is AxelarExecutable {
    struct Config {
        string destinationChain;
        string destinationAddress;
        string tokenSymbol;
        string thisChain;
    }

    Config public config;
    IAxelarGasService public immutable gasReceiver;

    constructor(
        address _gateway,
        address _receiver,
        string memory _thisChain,
        string memory _destinationChain,
        string memory _destinationAddress,
        string memory _lendingTokenSymbol
    ) AxelarExecutable(_gateway) {
        gasReceiver = IAxelarGasService(_receiver);

        config.thisChain = _thisChain;
        config.destinationChain = _destinationChain;
        config.destinationAddress = _destinationAddress;
        config.tokenSymbol = _lendingTokenSymbol;
    }
}
