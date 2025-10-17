# **Cross-Chain Bridge Architecture: Stellar (Soroban) \<=\> EVM (Solidity)**

This document outlines the architecture for a non-custodial **Lock-and-Mint** bridge, facilitating the transfer of assets (like XLM or custom Stellar tokens) between the Stellar network and any EVM-compatible blockchain.

## **I. Core Components**

| Component | Chain | Technology | Role |
| :---- | :---- | :---- | :---- |
| **1\. Stellar Locker Contract** | Stellar | Soroban (Rust) | Locks native Stellar assets and emits events. |
| **2\. EVM Wrapped Token Contract** | EVM | Solidity (ERC-20) | Mints/burns wrapped tokens (e.g., wXLM). |
| **3\. Relayer Network** | Off-Chain | Go/Rust/TypeScript | Observes both chains, validates transactions, and submits proofs. |
| **4\. Bridge Authority** | Both | Multi-sig/Governance | Secures the critical mint and unlock functions across both chains. |

## **II. Bridge Workflow: Stellar $\\rightarrow$ EVM (Lock & Mint)**

This flow creates a wrapped asset (e.g., wXLM) on the EVM chain corresponding to a native asset locked on Stellar.

1. **User Action (Stellar):** The user executes a Stellar transaction that calls the **Stellar Locker Contract (1)**.  
   * **Input:** Asset ID, Amount, and the destination EVM address (encoded in the memo or function arguments).  
   * **Action:** The contract verifies the transfer, locks the native asset within its account, and emits a **Soroban Event** containing a unique deposit\_hash, the amount, and the evm\_address.  
2. **Relayer Observation (Off-Chain):** The **Relayer Network (3)** continuously monitors the Stellar network's ledger closing and specifically listens for the unique event emitted by the Locker Contract.  
3. **Proof Generation & Consensus:**  
   * Each Relayer validates the Stellar transaction's finality.  
   * A quorum (e.g., 7 of 10 Relayers) must digitally sign a message that attests to the validated lock event data.  
4. **Minting (EVM):** A Relayer submits the signed proof message to the **EVM Wrapped Token Contract (2)** via its mint() function.  
   * **Verification:** The EVM contract (controlled by the **Bridge Authority (4)**) verifies the Relayers' signatures and checks the deposit\_hash against its processedDeposits mapping to prevent double-spending/replays.  
   * **Action:** If successful, the contract mints the corresponding wXLM tokens to the user's specified EVM address.

## **III. Bridge Workflow: EVM $\\rightarrow$ Stellar (Burn & Unlock)**

This flow unlocks the native asset on Stellar corresponding to a wrapped asset burned on the EVM chain.

1. **User Action (EVM):** The user calls the burn() function on the **EVM Wrapped Token Contract (2)**.  
   * **Input:** Amount and the destination Stellar public key (G... address, encoded as a string).  
   * **Action:** The contract burns the user's wXLM tokens and emits a **Solidity Event (Burned)** containing the amount and stellar\_address.  
2. **Relayer Observation (Off-Chain):** The **Relayer Network (3)** monitors the EVM chain for the Burned event emitted by the Wrapped Token Contract.  
3. **Proof Generation & Consensus:**  
   * Relayers wait for sufficient block confirmations on the EVM chain to ensure finality.  
   * A quorum of Relayers signs a message attesting to the validated burn event data.  
4. **Unlocking (Stellar):** A Relayer submits the signed proof message to a secondary unlock() function on the **Stellar Locker Contract (1)**.  
   * **Verification:** The Soroban contract verifies the Relayers' signatures and checks a mapping to prevent replay attacks.  
   * **Action:** If successful, the contract releases the locked native Stellar assets to the user's specified Stellar public key.

## **IV. Critical Security Considerations**

* **Bridge Authority (4):** The security of the entire bridge relies on the governance model of the Bridge Authority. It should be a decentralized multi-signature wallet or a DAO governed by stakeholders to prevent single points of failure.  
* **Replay Attacks:** Crucial check is needed on both the Soroban and EVM contracts to ensure a specific cross-chain transaction ID (deposit/burn hash) is only processed once.  
* **Relayer Integrity:** The Relayer Network must be decentralized, incentivized to act honestly, and have a robust consensus mechanism to prevent collusion.