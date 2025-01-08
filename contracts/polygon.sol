// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BorrowingLendingPlatform {
    // Events for logging actions
    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);

    mapping(address => uint256) public collateralBalance;
    mapping(address => uint256) public borrowedBalance;

    uint256 public constant COLLATERAL_RATIO = 150; 
    uint256 public constant DECIMALS = 100;

    function depositCollateral() external payable {
        require(msg.value > 0, "Must deposit some collateral");
        collateralBalance[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function borrow(uint256 borrowAmount) external {
        uint256 maxBorrowable = (collateralBalance[msg.sender] * DECIMALS) / COLLATERAL_RATIO;
        require(borrowAmount > 0, "Borrow amount must be greater than 0");
        require(borrowAmount <= maxBorrowable, "Borrow amount exceeds allowed limit");

        borrowedBalance[msg.sender] += borrowAmount;
        payable(msg.sender).transfer(borrowAmount);

        emit Borrowed(msg.sender, borrowAmount);
    }

    function repayLoan() external payable {
        require(msg.value > 0, "Repay amount must be greater than 0");
        require(borrowedBalance[msg.sender] >= msg.value, "Repay amount exceeds borrowed balance");

        borrowedBalance[msg.sender] -= msg.value;
        emit Repaid(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 withdrawAmount) external {
        require(withdrawAmount > 0, "Withdraw amount must be greater than 0");
        require(borrowedBalance[msg.sender] == 0, "Cannot withdraw collateral with outstanding loan");
        require(collateralBalance[msg.sender] >= withdrawAmount, "Withdraw amount exceeds collateral balance");

        collateralBalance[msg.sender] -= withdrawAmount;
        payable(msg.sender).transfer(withdrawAmount);

        emit CollateralWithdrawn(msg.sender, withdrawAmount);
    }

    /**
     * @dev View the user's max borrowable amount.
     */
    function getMaxBorrowable(address user) external view returns (uint256) {
        return (collateralBalance[user] * DECIMALS) / COLLATERAL_RATIO;
    }
}
