we used merkle tree here to verify the actual claimer is claiming the airdrop to save the gas cost rather than looping through a long array

intalling murky (modified Merkle.sol) check github repo of this course
forge install dmfxyz/murky

Signature - A can sign(approves B to make transaction on behalf of A) a signature and send it to B, now B can use that signature to claim airdrop amount to A address and pay gas fees on behalp of A

How signature basic verification works?
getSignerSample function collects massage hashes it and retrive the signer using a compiler ecrecover wich takes hashed massage and  v r s parameters then return signer, Then verifySignerSample verify it with expected signer.

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

in the end a we create a digest and then use that digest with v r s to get signer.
we will use oppenzippline to do this all.
vedio - 11 to know more about digest an how to do all this through oppenzippline.

replay attack
means a signature can be used more than once.
EIP712 prevent replay attack.

How signature works?
public key derived from private key. private key signs the massage public key verifies the singer knows the private key but its impossible to get private key from public key.

ECDSA - Signatures Algorithm based on elliptic curve cryptography to be exact (secp256k1 curve)
Ganarating Key pairs
creating signatures
verifying signature

secp256k1 curve: Search to how its look like
each coordinate of curve is (v, r, s)
each x axis point have two coordinate (v, r, s) & (v', r', s')
some one have (v, r, s) signature they can compute (v', r', s') signature without a private key. This enables a form of replay attack known as signature malleability.

ECDSA contains:
Two constants
G - Ganarator point (random constant point on the curve)
n - Prime Number genarated by G (n defines the length of private key)\
Theree intigers
r: x point on secp256k1 curve
s: proof singer knows the private key
v: index of the secp256k1 curve (might be positive or negetive)

private key: genarated by 0 to n-1 (n is the length of the private key)
public key: pG (p = private key, G = Ganarator point)

how public key is safe to use?
Public Key Cryptography (Asymmetric Encryption) used by ECDSA.
pubKey = pG (p & G are tow large prime no. now our result is large no.)
let xy = 96,673 (its impossible to find all possible x values and then find actual x and y values)

how signatures are created?
signatures = hash of a massage + private key using ECDSA signatures algorithm
first we ganarate a random no k then we genarate R = k*G = (x, y)
r = x (from R)
s = we calculate using nonce(k), hash of massage, private key, r & n
v = we then define we are using + part or - part of the y-axis

how signature verifies?
signing algorithm
ECDSA takes sign massage + signature from the signing algorithme + public key and the output was a bool weather the signature is valid or not
but its works in reverse its reverse s to r then provided r maches if then the signature is valid

How this works in smart contract?
EVM compiler ecrecover do this for and retrive singer
we then verify it singer == actualSinger
if we use ecrecover in verifiction directy without restricted s it might get signature malleability exposed we need to resticted s to one side wether + or - & another thing is if singnature is invalid ecrecover returns 0 address we need to handle it correctly.
we can use openzeppelin ECDSA library we are protected all against these.

Transaction types
1. 0x0 - lagacy transaction type (before eth transaction types were intorduced)
2. 0x01(EIP-2930) - type 1 : EIP-2930 solves contract brokage problem : 0x01 contains same as lagacy but with an additional paramete named access list parameter (address[] & storage key). enables gas saving by pre declaring allowed contract and storage slots.
3. 0x02(EIP-1559) - type 2 : introduced to tackle high network fees and congestion. Added parameters: maxPriorityFeePerGas(max fee for priority transaction), maxFeePerGas(max fee for transaction) = (maxPriorityFeePerGas + baseFee). zk sync supports type - 2 but not supports these parametes bcz. gas works diffrently in zk sync.
4. 0x03(EIP-4844) - type 3 (bolb transaction) : introduced scaling in rollups but for now its not used as much. Two additional parameters with type-0 and type-2 are added as max_bolb_fee_per_gas(fees that burn before transaction means non-rfundable fees if transaction fails.), bolb_versioned_hashes(list of versioned bolb accosiated with transaction bolb). L2 have to submit data of all transaction with that batch to L1. L1 stores these data minnig cost for eth community increses and also gas cost for L2 as well. bolb : L2 sends batch of data to verify on L1(eth) but in bolb data eventualy deleted from the eth node after transction verification. to know more about bolb tx (video 16).

ZK Sync specific transaction types
1. 0x71(EIP-712) - type 113 : EIP-712 standardized the massage data stucture. Helps in access zk sync specific features like account abstractions and paymasters. To use 0x71 type transaction smart contract must be deployed. Use standard eth parameters and two additional parameters as well. gasPerPubData(gas per single bytes)(pub data: data that submited by L2 to L1), customSignature(for when singer account is not in way), paymasterParams(parameter for cofiguring a custom paymaster), factory_dep(byte code of smart contract deployed).
2. 0xff - type 5(priority transactions) : allowes sending transactions from L1 to L2 directly.

Account Abstraction
Allows user to use smart contracts as wallet. Tiss enables custumizations like multisign wallets
Etherium : both EOAs (Externaly Owned Accounts) & smart contract accounts
ZK Sync : uses smart contract accounts netivly means all address are smart contract address. Tish allow remix ide to send transaction on behalf of us by signing a signature.


Interaction.s.sol

Creating A Signature
1. deploy contract : forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url http://localhost:8545 --broadcast --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 : == Return == 0: contract MerkleAirdrop 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 1: contract BagleToken 0x5FbDB2315678afecb367f032d93F642f64180aa3
2. call getMassageHash : cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMassageHash(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545 : return digest 0x184e30c4b19f5e304a89352421dc50346dad61c461e79155b910e73fd856dc72
3. cast wallet sign --no-hash 0x184e30c4b19f5e304a89352421dc50346dad61c461e79155b910e73fd856dc72 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 : returns signature massage (copy rest exept 0x) 0xfbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c : --no-hash search google for reson
4. Splitting A Signature : see codes & another method is there see video 24
5. claim on behalf of 1st anvil address : forge script script/Interaction.s.sol --rpc-url http://localhost:8545 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --broadcast : use a diff private key rather 1st anvil address.
6. check if 1st anvil address get token or not : cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
