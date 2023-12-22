In this project i created a Presale smart contract (ICO) addding a vesting functionality to the smart contract where users who buyed
in the presale can claim their tokens only after a minimum period of 30 days.

Note: The name ShibaPinu has been invented. It is not associated to any ERC20 contract on the mainnet.

In order to test the VestingIco smart contract digit:

```shell
$ forge test --fork-url yourUrl --match-path test/VestingIco.t.sol -vvv
```

In order to test the ShibaPinu ERC20 contract digit:

```shell
$ forge test --fork-url yourUrl --match-path test/ShibaPinu.t.sol -vvv
```
