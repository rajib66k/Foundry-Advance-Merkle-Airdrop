## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

we used merkle tree here to verify the actual claimer is claiming the airdrop to save the gas cost rather than looping through a long array

intalling murky (modified Merkle.sol) check github repo of this course
forge install dmfxyz/murky

Signature - A can sign(approves B to make transaction on behalf of A) a signature and send it to B, now B can use that signature to claim airdrop amount to A address and pay gas fees on behalp of A

How signature basic verification works?
getSignerSample function collects massage hashes it and retrive the signer using a compiler ecrecover wich takes hashed massage and  v r c parameters then return signer, Then verifySignerSample verify it with expected signer.

Signature Standards

EIP-191
standardize what the sign data should look loke.
0x19 <1 byte version> <version spesific data> <data to sign>

0x19 - it's signifies that the data is signature. it's decimal value is 25, it was choosen bcz. it was not used any where before.
<1 byte version> - version the sign data is using. diffrent version allows diffrent versions of data structures.

Allowed versions are
0x00: Data with intended validator
0x01: Structured data (associted with EIP712)
0x45: personal_sigmessages

<version spesific data> - we have to provide data according to <1 byte version>

<data to sign> - any data we want to sign

EIP712
standardize the format of version specific data and data to sign.
0x19 0x01 <domainSeparator> <hasStruct(massage)>

0x19 - prefix, 0x01 - version associted with EIP712

<domainSeparator> == <hashStruct(eip712Domain)>
    struct eip712Domain = {
        string name <!-- who verifies the signature (verifier) -->
        string version
        uint256 chainld
        address verifyingContract <!-- how verifier looks like -->
        bytes32 salt
    }

<hasStruct(massage)> - hash of signed stuctured massage, what the signature looks like

in the end a we create a digest and then use that digest with v r c to get signer.
we will use oppenzippline to do this all.
vedio - 11 to know more about digest an how to do all this through oppenzippline.

replay attack
means a signature can be used more than once.
EIP712 prevent replay attack.
