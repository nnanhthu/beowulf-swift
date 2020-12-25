
swift-beowulf
===========

Official Beowulf library for Swift.

Installation
------------

Using the [Swift package manager](https://swift.org/package-manager/):

In your Package.swift add:

```
dependencies: [
    .package(url: "https://github.com/nnanhthu/beowulf-swift", .branch("master"))
]
```

and run `swift package update`. Now you can `import Beowulf` in your Swift project.


Running tests
-------------

To run all tests simply run `swift test`, this will run both the unit- and integration-tests. To run them separately use the `--filter` flag, e.g. `swift test --filter BeowulfIntegrationTests`


Developing
----------

Development of the library is best done with Xcode, to generate a `.xcodeproj` you need to run `swift package generate-xcodeproj`.

To enable test coverage display go "Scheme > Manage Schemes..." menu item and edit the "Beowulf-Package" scheme, select the Test configuration and under the Options tab enable "Gather coverage for some targets" and add the `Beowulf` target.

After adding adding more unit tests the `swift test --generate-linuxmain` command has to be run and the XCTestManifest changes committed for the tests to be run on Linux.

How to use
----------

Example: 
1. Creating a new account:
```
let client = Beowulf.Client(address: URL(string: "https://testnet-bw.beowulfchain.com/rpc")!)
var wallet = GenKeys(newAccountName: "acc2")
var keys : [String:String] = [:]
keys["BEOxxxxxx”] = "5xxxxxxxx” // key of creator
SetKeys(keys: keys)
let creator = “creator” // name of creator
let new_account = “account” // name of newaccount
AccountCreate(client: client, creator: creator, newAccountName: new_account, publicKey: wallet!.publicKey, fee: "0.10000 W", chain: .testNet)
```

2. Set password to lock wallet. After setting password, wallet will be locked.
```
SetPassword(password: "password")
```

3. Unlock wallet to submit transaction
```
Unlock(password: "password")
```

4. Import private key for 1 account. Wallet must be unlocked before importing key.
```
let private_key = "5xxxx"
let account_name = "account"
ImportKey(wif: private_key, name: account_name) 
```

5. Save wallet file
```
let path = "wallet" // path of location to save wallet file
let wallet_filename = "" // name of wallet file
let password = "password" // password of wallet set at 2
let wallet_data = xxx // returned from GenKeys function
SaveWalletFile(walletPath: path, walletFilename: wallet_filename, password: password, walletData: wallet_data)
```

6. Load keys from wallet file
```
let path = "wallet/test-wallet.json" // path to wallet file
let password = "password" // password of wallet set at 2
SetKeysFromFileWallet(pathFileWallet: path, password: password)
```

7. Transfer:
```
// Import key of from_account to submit transaction
let private_key = "5xxxx"
let account_name = "from"
ImportKey(wif: private_key, name: account_name) 
let from_account = account_name// account name send coin
let to_account = "to" // account name receive coin
Transfer(client: client, from: from_account, to: to_account, amount: "0.01000 W", fee: "0.01000 W", memo: "", chain: .testNet)
```
