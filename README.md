
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
let client = Beowulf.Client(address: URL(string: "https://testnet-bw.beowulfchain.com/rpc")!)
var wallet = GenKeys(newAccountName: "acc2")
var keys : [String:String] = [:]
keys["BEOxxxxxx”] = "5xxxxxxxx” // key of creator
SetKeys(keys: keys)
let creator = “creator” // name of creator
let new_account = “account” // name of newaccount
AccountCreate(client: client, creator: creator, newAccountName: new_account, publicKey: wallet!.publicKey, fee: "0.10000 W", chain: .testNet)

2. Transfer:
let from_account = "from" // account name send coin
let to_account = "to" // account name receive coin
Transfer(client: client, from: from_account, to: to_account, amount: "0.01000 W", fee: "0.01000 W", memo: "", chain: .testNet)
