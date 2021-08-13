pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

// @TODO: Inherit the crowdsale contracts
contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, 
RefundablePostDeliveryCrowdsale 

{
    
    constructor(
        // Using non-negative rate of wei. 
        uint rate,
        // address payable is the beneficiary of the wallet.
        address payable wallet,
        // PupperCoinSale will work with the PupperCoin token and receive the ether raised.
        PupperCoin token,
        // open is "now" here
        uint now,
        // close is "now" + 24 weeks, to set the time properly, as per instructions.
        uint close, 
        // RefundablePostDeliveryCrowdsale delivers tokens when crowdsale closes and goal is met.
        uint goal
    )
        // Pass the constructor parameters to the crowdsale contracts.
        // Parameters rate, wallet, and the token go to crowdsale constructor.
        Crowdsale(rate, wallet, token)
        // This Crowdsale is capped.
        CappedCrowdsale(goal)
        // Parameters now and close (now + 24 weeks) go to TimedCrowdsale
        TimedCrowdsale(now, now + 24 weeks)
        // RefundablePostDeliveryCrowdsale has no constructor; replace w/RefundableCrowdsale.  
        // Users will get a refund if the goal is not met.
        RefundableCrowdsale(goal)
        public
    {
        // constructor can stay empty
    }
}

contract PupperCoinSaleDeployer {

    address public token_sale_address;
    address public pupper_token_address;

    constructor(
        // the address payable wallet will get the ETH from the sale.
        string memory name, 
        string memory symbol,
        address payable wallet, 
        uint goal
    )
        public
    {
        // @TODO: create the PupperCoin and keep its address handy
        
        PupperCoin token = new PupperCoin(name, symbol, 0);
        pupper_token_address = address(token);

        // @TODO: create the PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        // 1 = 1 wei, and the goal is the total max number of tokens. 
        PupperCoinSale pupper_token = new PupperCoinSale(1, wallet, token, now, now + 24 weeks, goal);
        token_sale_address = address(pupper_token);
        
        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
}
