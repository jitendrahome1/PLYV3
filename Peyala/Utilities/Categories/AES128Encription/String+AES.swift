//
//  String+AES.swift
//  KIARA
//
//  Created by Debaprasad Mondal on 15/07/16.
//  Copyright © 2016 Indusnet Technologies Pvt. Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

extension String {
    
    func generateSaltWithLength (_ len : Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in (0..<len){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString as String
    }
    
    func setAESEncription() -> String {
        //let AESPassword = "I!ndu(sNet!#Konc*Kia"
        //let saltString = "518740671b7851e1d0a18c14262754e0"
        let input:Array<UInt8> = self.utf8.map {$0}
        //let password: Array<UInt8> = AESPassword.utf8.map {$0}
        //let salt: Array<UInt8> = saltString.utf8.map {$0}
//        let value = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 1000, keyLength: 16, variant: .sha1).calculate()
        //MARK: Static key provided, automatic key generation slowing down the process.
        let value:Array<UInt8> = [198,253,46,195,211,6,6,172,77,89,241,247,177,14,51,79]
        
        let aes = try! AES(key: value, blockMode: .ECB, padding: PKCS7())
        let encrypted = try! aes.encrypt(input)
        return encrypted.toBase64()!
    }
    
    func getAESDecryption() -> String {
        guard self.length > 0 else {
            return ""
        }
        //let AESPassword = "I!ndu(sNet!#Konc*Kia"
        //let saltString = "518740671b7851e1d0a18c14262754e0"
        let decodedData = Data(base64Encoded: self, options:   NSData.Base64DecodingOptions.ignoreUnknownCharacters /*NSDataBase64DecodingOptions(rawValue: 0)*/)
        let count = decodedData!.count / MemoryLayout<UInt8>.size
        
        // create array of appropriate length:
        var array = [UInt8](repeating: 0, count: count)
        
        // copy bytes into array
        (decodedData! as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        let input:Array<UInt8> = array// decoddstr!.utf8.map {$0}
        //let password: Array<UInt8> = AESPassword.utf8.map {$0}
        //let salt: Array<UInt8> = saltString.utf8.map {$0}
        //let value = try! PKCS5.PBKDF2(password: password, salt: salt, iterations: 1000, keyLength: 16, variant: .sha1).calculate()
         //MARK: Static key provided, automatic key generation slowing down the process.
        let value:Array<UInt8> = [198,253,46,195,211,6,6,172,77,89,241,247,177,14,51,79]
        
      //  print(value.toBase64());
        
        let aes = try! AES(key: value, blockMode: .ECB, padding: PKCS7())
        let decrypted = try! aes.decrypt(input)
       
        let  decryptedData =  Data(bytes: decrypted as [UInt8], count: decrypted.count)//Data(bytes: decrypted as [UInt8], length: decrypted.count)
        let iso: String = String(data: decryptedData, encoding: String.Encoding.isoLatin1)!
        let dutf8: NSData = iso.data(using: String.Encoding.utf8)! as NSData
        let originalStr = String(data: dutf8 as Data, encoding: String.Encoding.utf8)
        return originalStr!
    }
}
