// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IAgentTokenV2
 * @dev Interface de base du token (héritée du modèle AgentToken de Virtuals Protocol).
 * Elle regroupe :
 *  - les erreurs custom (moins chères en gas qu'un require avec string) ;
 *  - les événements émis par le token ;
 *  - les structs de paramètres passés encodés (abi.encode) à initialize() —
 *    l'ordre des champs est CRITIQUE : abi.decode doit lire exactement ce que
 *    le script de déploiement a encodé.
 */
interface IAgentTokenV2 is IERC20Metadata {
    // ---------------------------------------------------------------- erreurs
    error AllowanceDecreasedBelowZero();
    error ApproveFromTheZeroAddress();
    error ApproveToTheZeroAddress();
    error BurnExceedsBalance();
    error BurnFromTheZeroAddress();
    error CallerIsNotAdminNorFactory();
    error CannotSetToZeroAddress();
    error CannotWithdrawThisToken();
    error InitialLiquidityAlreadyAdded();
    error InitialLiquidityNotYetAdded();
    error InsufficientAllowance();
    error LiquidityPoolCannotBeAddressZero();
    error LiquidityPoolMustBeAContractAddress();
    error MaxSupplyTooHigh();
    error MintToZeroAddress();
    error NoTokenForLiquidityPair();
    error SupplyTotalMismatch();
    error TransferAmountExceedsBalance();
    error TransferFailed();
    error TransferFromZeroAddress();
    error TransferToBlacklistedAddress();
    error TransferToZeroAddress();

    // ------------------------------------------------------------- événements
    event AutoSwapThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event ExternalCallError(uint256 identifier);
    event InitialLiquidityAdded(uint256 tokenA, uint256 tokenB, uint256 lpToken);
    event LiquidityPoolAdded(address addedPool);
    event LiquidityPoolCreated(address addedPool);
    event LiquidityPoolRemoved(address removedPool);
    event ProjectTaxBasisPointsChanged(
        uint256 oldBuyBasisPoints,
        uint256 newBuyBasisPoints,
        uint256 oldSellBasisPoints,
        uint256 newSellBasisPoints
    );
    event ProjectTaxRecipientUpdated(address treasury);
    event ValidCallerAdded(bytes32 addedValidCaller);
    event ValidCallerRemoved(bytes32 removedValidCaller);

    // ----------------------------------------------------------------- structs
    /**
     * @dev Paramètres de supply.
     * Les montants sont en tokens ENTIERS : initialize() multiplie par 10^18.
     * Contrainte vérifiée on-chain : maxSupply == lpSupply + vaultSupply.
     */
    struct ERC20SupplyParameters {
        uint256 maxSupply;
        uint256 lpSupply;
        uint256 vaultSupply;
        uint256 botProtectionDurationInSeconds;
        address vault;
    }

    /**
     * @dev Paramètres de taxe.
     * Taxes en basis points (1 bp = 0,01 % ; 100 = 1 %), dénominateur 10000.
     * taxSwapThresholdBasisPoints : unités /1e6 (voir SWAP_THRESHOLD_DENOMINATOR).
     */
    struct ERC20TaxParameters {
        uint256 projectBuyTaxBasisPoints;
        uint256 projectSellTaxBasisPoints;
        uint256 taxSwapThresholdBasisPoints;
        address projectTaxRecipient;
    }

    // --------------------------------------------------------------- fonctions
    /**
     * @notice Entrée d'initialisation historique (V2/V3). Dans AgentTokenV4 cette
     * variante revert systématiquement : on doit utiliser la version 5 arguments.
     */
    function initialize(
        address[3] memory integrationAddresses_,
        bytes memory baseParams_,
        bytes memory supplyParams_,
        bytes memory taxParams_
    ) external;
}
