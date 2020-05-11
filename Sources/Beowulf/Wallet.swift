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

public struct Wallet: Codable {
    public var cipherKeys: Data?
    public var cipherType: String = "aes-256-cbc"
    public var salt: String
    public var name: String
    public init?(){
        self.cipherKeys = nil
        self.cipherType = "aes-256-cbc"
        self.salt = ""
        self.name = ""
    }
    public init?(cipherKeys: Data?, cipherType: String, salt: String, name: String){
        self.cipherKeys = cipherKeys
        self.cipherType = cipherType
        self.salt = salt
        self.name = name
    }
    enum CodingKeys: String, CodingKey {
        case cipherKeys = "cipherKeys"
        case cipherType = "cipherType"
        case salt = "salt"
        case name = "name"
    }
}

public struct PlainKeys: Codable {
    public var checksum: [UInt8]
    public var keys: [String: String]
    public init?(){
        self.checksum = []
        self.keys = [:]
    }
    enum CodingKeys: String, CodingKey {
        case checksum = "checksum"
        case keys = "keys"
    }
}

func RandStringBytes(length: Int) -> String{
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+"
    return String((0..<length).map{ _ in letters.randomElement()! })
}

func isNew() -> Bool{
    return Wallet_?.cipherKeys?.count == 0
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

func Unlock(password: String) -> String?{
    if password.count == 0{
        return "Password must be not empty"
    }
    let new_password = password + Wallet_!.salt
    var checksum : [UInt8] = []
    if let strData = new_password.data(using: String.Encoding.utf8) {
           /// #define CC_SHA256_DIGEST_LENGTH     32
           /// Creates an array of unsigned 8 bit integers that contains 32 zeros
           var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
    
           strData.withUnsafeBytes {
               CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
           }
        checksum = digest
    }
    //Convert cipherKeys from string to data
//    let data = Wallet_?.cipherKeys.data(using: String.Encoding.utf8)
    let data = Wallet_?.cipherKeys
    var decrypted = data?.decryptAES256_CBC_PKCS7_IV(key: NSData(bytes: checksum, length: (checksum.count)) as Data)
    //Convert jsondata to object
    do {
        // make sure this JSON is in the format we expect
        let json = try JSONDecoder().decode(PlainKeys.self, from: decrypted!)
        if json != nil{
//        if let json = try JSONSerialization.jsonObject(with: decrypted!, options: []) as? [String: Any] {
            // try to read out a string array
            let ck = json.checksum
            
            if ck != checksum{
                return "Don't match checksum"
            }
            Checksum_ = ck
            
            let keys = json.keys
            Keys_ = keys
            Locked = false
            SetKeys(keys: keys)
            
        }
    } catch let error as NSError {
        print("Failed to load: \(error.localizedDescription)")
    }
    return nil
}

func SetPassword(password: String) -> String?{
    if !isNew(){
        if isLocked() {
            return "The wallet must be unlocked before the password can be set"
        }
    }
    let salt = RandStringBytes(length: 16)
    let new_password = password + salt
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
        Checksum_ = digest
    }
    Wallet_?.salt = salt
    Wallet_?.cipherType = "aes-256-cbc"
    return lock()
}

func LoadWallet(fileName: String = "wallet.json") -> Bool{
    //Read file
    let bundle = Bundle.main
    let path = bundle.path(forResource: "data", ofType: "json")!
//    var error:NSError?
    do {
//        let text2 = try String(contentsOf: fileURL, encoding: .utf8)
        let data:NSData = try NSData(contentsOfFile: path)
        //    let json:AnyObject = JSONSerialization.JSONObjectWithData(data, options: JSONSerialization.ReadingOptions.AllowFragments, error:&error)
             // JSONObjectWithData returns AnyObject so the first thing to do is to downcast this to a known type
        //    if let nsDictionaryObject = json as? NSDictionary {
        //            if let swiftDictionary = nsDictionaryObject as Dictionary? {
        //                print(swiftDictionary)
        //        }
        //    }
            do {
                // make sure this JSON is in the format we expect
                Wallet_ = try JSONDecoder().decode(Wallet.self, from: data as Data)
//                if json != nil{
//                if let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any] {
                    // try to read out a string array
//                    if let cipherKeys = json["cipherKeys"] as? Data {
//                        Wallet_?.cipherKeys = cipherKeys
//                    }
//                    if let cipherType = json["cipherType"] as? String {
//                        Wallet_?.cipherType = cipherType
//                    }
//                    if let salt = json["salt"] as? String {
//                        Wallet_?.salt = salt
//                    }
//                    if let name = json["name"] as? String {
//                        Wallet_?.name = name
//                    }
//                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                return false
            }
    }
    catch {/* error handling here */return false}
    
    return true
}

func saveWallet(fileName: String = "wallet.json"){
    encryptKeys()
    //Convert to [byte]
    let jsonData = try! JSONSerialization.data(withJSONObject: Wallet_!, options: .prettyPrinted)
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

    let fileURL = dir.appendingPathComponent(fileName)

    //writing
    do {
        try jsonData.write(to: fileURL)
    }
    catch {/* error handling here */}
    }
}

func importKey(wif: String) -> Bool{
    let privateKey = PrivateKey(wif)!
    let publicKey = CreatePublicKey(privateKey: privateKey)
    let pubKey = publicKey.address
    Keys_[pubKey] = wif
    return true
}

func ImportKey(wif: String, name: String) -> Bool{
    if isLocked(){
        return false
    }
    Wallet_?.name = name
    if importKey(wif: wif){
        saveWallet(fileName: name+".json")
        CurrentKeys_.removeAll()
        CurrentKeys_.append(wif)
        return true
    }
    return false
}

func encryptKeys(){
    var plainKeys = PlainKeys()
        plainKeys?.checksum = Checksum_
        plainKeys?.keys = Keys_
        //Convert to [byte]
//        let jsonData = try! JSONSerialization.data(withJSONObject: plainKeys!, options: .prettyPrinted)
    let jsonData = try! JSONEncoder().encode(plainKeys!)
        
    //    var plainTxt = String(bytes: jsonData, encoding: .utf8)
        var cipherText = jsonData.encryptAES256_CBC_PKCS7_IV(key: NSData(bytes: plainKeys?.checksum, length: (plainKeys?.checksum.count)!) as Data)
        //This cipherKeys include iv + cipherText
        Wallet_?.cipherKeys = cipherText // String(bytes: cipherText!, encoding: .utf8)!
        
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
    var walletFilename = walletFilename
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
    //let jsonData = try! JSONSerialization.data(withJSONObject: plainKeys!, options: .prettyPrinted)
    let jsonData = try! JSONEncoder().encode(plainKeys)
    //    var plainTxt = String(bytes: jsonData, encoding: .utf8)
    let cipherText = jsonData.encryptAES256_CBC_PKCS7_IV(key: NSData(bytes: plainKeys?.checksum, length: (plainKeys?.checksum.count)!) as Data)
    //This cipherKeys include iv + cipherText
    if cipherText == nil{
        return "error when encrypting key"
    }
    let cipherKeys = cipherText // String(decoding: cipherText!, as: UTF8.self)
    if cipherKeys == nil{
        return "error when converting key"
    }
    if walletFilename.isEmpty{
        walletFilename = walletData!.name + "-" + WalletName_
    }
    var filePath = walletFilename
    if !walletPath.isEmpty{
        
        filePath = walletPath + "/" + walletFilename
    }
    let wl = Wallet(cipherKeys: cipherKeys, cipherType: "aes-256-cbc", salt: salt, name: walletData!.name)
    
//    let wlData = try! JSONSerialization.data(withJSONObject: wl, options: .prettyPrinted)
    let wlData = try! JSONEncoder().encode(wl)
    //Write to file
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        if !walletPath.isEmpty{
            //Create directory if not exist
            let DirPath = dir.appendingPathComponent(walletPath)
            if !FileManager.default.fileExists(atPath: DirPath.path){
            do
            {
                try FileManager.default.createDirectory(atPath: DirPath.path, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError
            {
                return "Unable to create directory \(error.debugDescription)"
            }
            }
        }
        var fileURL : URL = dir.appendingPathComponent(filePath)
//        if #available(OSX 10.11, *) {
//            fileURL = URL(fileURLWithPath: filePath, relativeTo: dir).appendingPathExtension("json")
//        }
        print(fileURL.path)
        //let fileURL = dir.appendingPathComponent(filePath)

    //writing
    do {
        try wlData.write(to: fileURL)
    }
    catch {/* error handling here */}
    }
    
    return nil
}

func checkFileExisted(pathFile: String) -> String?{
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    if let pathComponent = url.appendingPathComponent(pathFile) {
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
            return nil
        } else {
            return "FILE NOT AVAILABLE"
        }
    } else {
        return "FILE PATH NOT AVAILABLE"
    }
}
func SetKeys(keys: [String:String]){
    if keys.count > 0{
        CurrentKeys_.removeAll()
        for (_,v) in keys{
            CurrentKeys_.append(v)
        }
    }
}
public func SetKeysFromFileWallet(pathFileWallet: String, password: String) -> String?{
    if pathFileWallet.isEmpty{
        return "Path file wallet is not empty"
    }
    if password.isEmpty{
        return "Password is not empty"
    }
    let err = checkFileExisted(pathFile: pathFileWallet)
    if err != nil{
        return err
    }
    var wl : Wallet = Wallet()!
    //Read file
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//    let bundle = Bundle.main
//    let path = bundle.path(forResource: "data", ofType: "json")!
    //    var error:NSError?
        var fileURL : URL = dir.appendingPathComponent(pathFileWallet)
    do {
//        let data:NSData = try NSData(contentsOfFile: path)
        let data: NSData = try NSData(contentsOf: fileURL)
            
        do {
            // make sure this JSON is in the format we expect
            wl = try JSONDecoder().decode(Wallet.self, from: data as Data)
            if wl != nil{
            //if let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any]{
                // try to read out a string array
//                if let cipherKeys = json["cipherKeys"] as? String {
//                    wl.cipherKeys = Data(cipherKeys.utf8)
//                }
//                if let cipherType = json["cipherType"] as? String {
//                    wl.cipherType = cipherType
//                }
//                if let salt = json["salt"] as? String {
//                    wl.salt = salt
//                }
//                if let name = json["name"] as? String {
//                    wl.name = name
//                }
                let new_password = password + wl.salt
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
//                    let cipherData = wl.cipherKeys.data(using: String.Encoding.utf8)
                    let cipherData = wl.cipherKeys // Data(wl.cipherKeys.utf8)
                    if cipherData == nil{
                        return "error"
                    }
                    var decrypted = (cipherData!.decryptAES256_CBC_PKCS7_IV(key: NSData(bytes: checksum, length: (checksum.count)) as Data))!
                    //Convert jsondata to object
                    do {
                        // make sure this JSON is in the format we expect
                        let decoder = JSONDecoder()
                        do {
                            let pk = try decoder.decode(PlainKeys.self, from: decrypted)
                            print (pk)
                            // try to read out a string array
                            SetKeys(keys: pk.keys)
                            
                        } catch {
                            print(error.localizedDescription)
                        }
//                        if let json = try JSONSerialization.jsonObject(with: decrypted!, options: []) as? [String: Any] {
//                            // try to read out a string array
//                            if let keys = json["keys"] as? [String:String] {
//                                SetKeys(keys: keys)
//                            }
//                        }
//                        return nil
                    } catch let error as NSError {
                        return "Failed to load: \(error.localizedDescription)"
                    }
                }
            }
        } catch let error as NSError {
            return "Failed to load: \(error.localizedDescription)"
                    
        }
    }
    catch {/* error handling here */return "error"}
    }
    return "error"
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
