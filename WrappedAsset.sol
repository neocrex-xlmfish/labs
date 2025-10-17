// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.x/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.x/contracts/access/Ownable.sol";

/**
 * @title WrappedAsset
 * @dev An ERC20 token contract representing a locked asset from the Stellar network.
 * This contract is responsible for minting tokens when an asset is locked on Stellar
 * and burning them when the asset is unlocked back on Stellar.
 *
 * NOTE: For a production bridge, the 'owner' must be replaced by a secure, decentralized
 * Multi-Signature or Governance Contract (the 'Bridge Authority') to manage minting and burning.
 */
contract WrappedAsset is ERC20, Ownable {
    // Mapping to prevent replay attacks during the cross-chain transfer
    mapping(bytes32 => bool) public processedDeposits;

    // Address of the Bridge Relayer/Authority, which is the only entity allowed to mint/burn
    address private bridgeAuthority;

    // Events for tracking cross-chain transfers
    event Minted(bytes32 indexed txHash, address indexed recipient, uint256 amount);
    event Burned(address indexed burner, uint256 amount, string stellarAddress);

    constructor(
        string memory name,
        string memory symbol,
        address _bridgeAuthority
    ) ERC20(name, symbol) {
        bridgeAuthority = _bridgeAuthority;
        // The contract deployer initially owns the contract, but the authority is set separately.
        // In a real implementation, ownership should be transferred to a governance mechanism.
    }

    modifier onlyBridgeAuthority() {
        require(msg.sender == bridgeAuthority, "Caller is not the Bridge Authority");
        _;
    }

    /**
     * @notice Allows the contract owner to update the address of the Bridge Authority.
     * @param _newAuthority The new address of the Bridge Authority.
     */
    function setBridgeAuthority(address _newAuthority) public onlyOwner {
        bridgeAuthority = _newAuthority;
    }

    /**
     * @notice Mints new wrapped tokens based on a successful lock event observed on Stellar.
     * This function is called by the off-chain Bridge Relayer/Authority.
     * @param _depositHash A unique hash/identifier for the Stellar lock transaction (e.g., Soroban event hash).
     * @param _recipient The EVM address to receive the minted wrapped tokens.
     * @param _amount The amount of tokens to mint.
     */
    function mint(
        bytes32 _depositHash,
        address _recipient,
        uint256 _amount
    ) public onlyBridgeAuthority {
        require(!processedDeposits[_depositHash], "Deposit already processed");

        _mint(_recipient, _amount);
        processedDeposits[_depositHash] = true;

        emit Minted(_depositHash, _recipient, _amount);
    }

    /**
     * @notice Burns wrapped tokens to initiate the transfer back to the Stellar network.
     * @param _amount The amount of tokens to burn.
     * @param _stellarAddress The destination Stellar public key (G... address).
     */
    function burn(
        uint256 _amount,
        string memory _stellarAddress
    ) public {
        _burn(msg.sender, _amount);

        // This event signals the off-chain Relayers to unlock the assets on Stellar
        emit Burned(msg.sender, _amount, _stellarAddress);
    }
}
