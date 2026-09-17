// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IAgentFactory
 * @dev Dans le protocole d'origine (Virtuals), une "factory" déploie les clones
 * de token et garde des droits d'admin dessus (modifier onlyOwnerOrFactory).
 *
 * Ici, on déploie SANS factory : le token mémorise simplement l'adresse qui a
 * appelé initialize() (msg.sender) comme "factory". Concrètement, ce sera ton
 * EOA de déploiement — qui cumulera donc les rôles owner + factory.
 * Le token n'appelle jamais aucune fonction de la factory, d'où l'interface vide.
 */
interface IAgentFactory {}
