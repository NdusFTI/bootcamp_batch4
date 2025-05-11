// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MockUSDC} from "../src/MockUSDC.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    MockUSDC public usdc;
    Vault public vault;

    address public alice = makeAddr("Alice"); // Membuat Akun Lain
    address public bob = makeAddr("Bob"); // Membuat Akun Lain
    address public charlie = makeAddr("Charlie"); // Membuat Akun Lain

    function setUp() public {
        usdc = new MockUSDC();
        vault = new Vault(address(usdc));
    }
    
    function test_Deposit() public {
        vm.startPrank(alice);
        usdc.mint(alice, 1000);
        usdc.approve(address(vault), 1000);
        vault.deposit(1000);
        assertEq(vault.balanceOf(alice), 1000);
        vm.stopPrank();

        vm.startPrank(bob);
        usdc.mint(bob, 2000);
        usdc.approve(address(vault), 2000);
        vault.deposit(2000);
        assertEq(vault.balanceOf(bob), 2000);
        vm.stopPrank();

        vm.startPrank(charlie);
        usdc.mint(charlie, 3000);
        usdc.approve(address(vault), 3000);
        vault.deposit(3000);
        assertEq(vault.balanceOf(charlie), 3000);
        vm.stopPrank();
    }

    function test_Scenario() public {
        // Alice deposit 1.000.000
        // Bob Deposit 2.000.000
        // distributeYield 1.000.000
        // Charlie Deposit 1.000.000

        // Prepare
        usdc.mint(alice, 1_000_000);
        usdc.mint(bob, 2_000_000);
        usdc.mint(charlie, 1_000_000);

        // Alice
        vm.startPrank(alice);
        usdc.approve(address(vault), 1_000_000);
        vault.deposit(1_000_000);
        assertEq(vault.balanceOf(alice), 1_000_000);
        vm.stopPrank();

        // Bob
        vm.startPrank(bob);
        usdc.approve(address(vault), 2_000_000);
        vault.deposit(2_000_000);
        assertEq(vault.balanceOf(bob), 2_000_000);
        vm.stopPrank();

        // Distribute Yield
        usdc.mint(address(this), 1_000_000);
        usdc.approve(address(vault), 1_000_000);
        vault.distributeYield(1_000_000);

        // Charlie
        vm.startPrank(charlie);
        usdc.approve(address(vault), 1_000_000);
        vault.deposit(1_000_000);
        assertEq(vault.balanceOf(charlie), 750_000);
        vm.stopPrank();

        // Alice withdraw
        vm.startPrank(alice);
        vault.withdraw(vault.balanceOf(alice));
        assertEq(usdc.balanceOf(alice), 1_333_333);
        vm.stopPrank();

        // Bob withdraw
        vm.startPrank(bob);
        vault.withdraw(vault.balanceOf(bob));
        assertEq(usdc.balanceOf(bob), 2_666_666);
        vm.stopPrank();

        // Charlie withdraw
        vm.startPrank(charlie);
        vault.withdraw(vault.balanceOf(charlie));
        assertEq(usdc.balanceOf(charlie), 1_000_001);
        vm.stopPrank();
    }
}