//
//  File.swift
//  
//
//  Created by Thu on 5/5/20.
//

import Foundation
import CommonCrypto

public struct WalletData: Decodable {
    public var name: String
    public var privateKey: String
    public var publicKey: String
    
    public init?(){
        self.name = ""
        self.privateKey = ""
        self.publicKey = ""
    }
    
    public init?(name: String, privateKey: String, publicKey: String){
        self.name = name
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
}

public struct Wallet: Decodable {
    public var cipherKeys: String
    public var cipherType: String = "aes-256-cbc"
    public var salt: String
    public var name: String
    public init?(){
        self.cipherKeys = ""
        self.cipherType = "aes-256-cbc"
        self.salt = ""
        self.name = ""
    }
}

public struct PlainKeys: Decodable {
    public var checksum: [UInt8]
    public var keys: [String: String]
    public init?(){
        self.checksum = []
        self.keys = [:]
    }
}

func isNew() -> Bool{
    return Wallet_?.cipherKeys.count == 0
}

func isLocked() -> Bool{
    return Checksum_.isEmpty
}

func lock() -> String?{
    if isLocked(){
        return "The wallet must be unclocked before the password can be set"
    }
    encryptKeys()
    for (k, _) in Keys_ {
      Keys_[k] = ""
    }
    Keys_ = [:]
    Checksum_ = []
    Locked = true
    return nil
}
func RandStringBytes(length: Int) -> String{
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

func CreatePrivateKey(user: String, role: String, password: String) -> PrivateKey?{
    let new_password = password + Wallet_!.salt
    let seed = user + role + new_password
    return PrivateKey(seed: seed)
}

func CreatePublicKey(privateKey: PrivateKey) -> PublicKey{
    return privateKey.createPublic()
}

public func GenKeys(newAccountName: String) -> WalletData?{
    var err = ValidateNameAccount(account: newAccountName)
    if err != nil{
        return nil
    }
    let role = "owner"
    let password = RandStringBytes(length: 16)
    let priv = CreatePrivateKey(user: newAccountName, role: role, password: password)
    if priv == nil{
        return nil
    }
    let pub = CreatePublicKey(privateKey: priv!)
    return WalletData(name: newAccountName, privateKey: priv!.wif, publicKey: pub.address)
}

public func SaveWalletFile(walletPath: String, walletFilename: String, password: String, walletData: WalletData?) -> String?{
    if password.isEmpty{
        return "Password is not empty"
    }
    if password.count < 8{
        return "Password length >= 8 characters"
    }
    if walletData == nil || walletData!.name.isEmpty || walletData!.privateKey.isEmpty || walletData!.publicKey.isEmpty{
        return "Wallet Data is invalid"
    }
    var keys: [String: String] = [:]
    keys[walletData!.publicKey] = walletData!.privateKey
    let salt = RandStringBytes(length: 16)
    let new_password = password + salt
    var checksum : [UInt8] = []
    if let strData = new_password.data(using: String.Encoding.utf8) {
           /// #define CC_SHA256_DIGEST_LENGTH     32
           /// Creates an array of unsigned 8 bit integers that contains 32 zeros
           var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
    
           /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
           /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
           strData.withUnsafeBytes {
               // CommonCrypto
               // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
               // OpenSSL                                                                             |
               // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
               CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
           }
        checksum = digest
    }
    var plainKeys = PlainKeys()
        plainKeys?.checksum = checksum
        plainKeys?.keys = keys
        //Convert to [byte]
        let jsonData = try! JSONSerialization.data(withJSONObject: plainKeys!, options: .prettyPrinted)
        
    //    var plainTxt = String(bytes: jsonData, encoding: .utf8)
        var cipherText = jsonData.encryptAES256_CBC_PKCS7_IV(key: NSData(bytes: plainKeys?.checksum, length: (plainKeys?.checksum.count)!) as Data)
        //This cipherKeys include iv + cipherText
        var cipherKeys = String(bytes: cipherText!, encoding: .utf8)!
    return nil
}

func encryptKeys(){
    var plainKeys = PlainKeys()
        plainKeys?.checksum = Checksum_
        plainKeys?.keys = Keys_
        //Convert to [byte]
        let jsonData = try! JSONSerialization.data(withJSONObject: plainKeys!, options: .prettyPrinted)
        
    //    var plainTxt = String(bytes: jsonData, encoding: .utf8)
        var cipherText = jsonData.encryptAES256_CBC_PKCS7_IV(key: NSData(bytes: plainKeys?.checksum, length: (plainKeys?.checksum.count)!) as Data)
        //This cipherKeys include iv + cipherText
        Wallet_?.cipherKeys = String(bytes: cipherText!, encoding: .utf8)!
        
}

extension Data {
    func randomGenerateBytes(count: Int) -> Data? {
        let bytes = UnsafeMutableRawPointer.allocate(byteCount: count, alignment: 1)
        defer { bytes.deallocate() }
        let status = CCRandomGenerateBytes(bytes, count)
        guard status == kCCSuccess else { return nil }
        return Data(bytes: bytes, count: count)
    }
    
    func crypt(operation: Int, algorithm: Int, options: Int, key: Data,
            initializationVector: Data, dataIn: Data) -> Data? {
        return key.withUnsafeBytes { keyUnsafeRawBufferPointer in
            return dataIn.withUnsafeBytes { dataInUnsafeRawBufferPointer in
                return initializationVector.withUnsafeBytes { ivUnsafeRawBufferPointer in
                    // Give the data out some breathing room for PKCS7's padding.
                    let dataOutSize: Int = dataIn.count + kCCBlockSizeAES128*2
                    let dataOut = UnsafeMutableRawPointer.allocate(byteCount: dataOutSize,
                        alignment: 1)
                    defer { dataOut.deallocate() }
                    var dataOutMoved: Int = 0
                    let status = CCCrypt(CCOperation(operation), CCAlgorithm(algorithm),
                        CCOptions(options),
                        keyUnsafeRawBufferPointer.baseAddress, key.count,
                        ivUnsafeRawBufferPointer.baseAddress,
                        dataInUnsafeRawBufferPointer.baseAddress, dataIn.count,
                        dataOut, dataOutSize, &dataOutMoved)
                    guard status == kCCSuccess else { return nil }
                    return Data(bytes: dataOut, count: dataOutMoved)
                }
            }
        }
    }

    /// Encrypts for you with all the good options turned on: CBC, an IV, PKCS7
    /// padding (so your input data doesn't have to be any particular length).
    /// Key can be 128, 192, or 256 bits.
    /// Generates a fresh IV for you each time, and prefixes it to the
    /// returned ciphertext.
    func encryptAES256_CBC_PKCS7_IV(key: Data) -> Data? {
        guard let iv = randomGenerateBytes(count: kCCBlockSizeAES128) else { return nil }
        // No option is needed for CBC, it is on by default.
        guard let ciphertext = crypt(operation: kCCEncrypt,
                                    algorithm: kCCAlgorithmAES,
                                    options: kCCOptionPKCS7Padding,
                                    key: key,
                                    initializationVector: iv,
                                    dataIn: self) else { return nil }
        return iv + ciphertext
    }
    
    /// Decrypts self, where self is the IV then the ciphertext.
    /// Key can be 128/192/256 bits.
    func decryptAES256_CBC_PKCS7_IV(key: Data) -> Data? {
        guard count > kCCBlockSizeAES128 else { return nil }
        let iv = prefix(kCCBlockSizeAES128)
        let ciphertext = suffix(from: kCCBlockSizeAES128)
        return crypt(operation: kCCDecrypt, algorithm: kCCAlgorithmAES,
            options: kCCOptionPKCS7Padding, key: key, initializationVector: iv,
            dataIn: ciphertext)
    }
}
