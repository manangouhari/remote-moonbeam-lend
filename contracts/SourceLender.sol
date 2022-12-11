//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executables/AxelarExecutable.sol";

import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import {IERC20} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol";

error GasNotProvided();

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

    function openPosition(uint256 toLend) external payable {
        address tokenAddress = gateway.tokenAddresses(config.tokenSymbol);
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), toLend);
        IERC20(tokenAddress).approve(address(gateway), toLend);

        bytes memory payload = abi.encode(msg.sender);

        if (msg.value == 0) revert GasNotProvided();
        // Paying gas for the contract call to happen on the Remote chain.
        gasReceiver.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            config.destinationChain,
            config.destinationAddress,
            payload,
            config.tokenSymbol,
            toLend,
            msg.sender
        );

        // Calling the Axelar Gateway to call the contract on the Remote chain.
        gateway.callContractWithToken(
            config.destinationChain,
            config.destinationAddress,
            payload,
            config.tokenSymbol,
            toLend
        );
    }
}
