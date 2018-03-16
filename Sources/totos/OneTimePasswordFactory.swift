//
//  OneTimePassword.swift
//  totosPackageDescription
//
//  Created by Andy Sherwood on 3/13/18.
//

import Foundation
import CCommonCrypto

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhX", $0) }.joined(separator: "-")
    }
}

public class OneTimePasswordFactory {
    
    private let _sharedSecret:Data
    private let _ttlSeconds:Int64
    
    public init(sharedSecret:Data, ttlSeconds:Int = 30) {
        _sharedSecret = sharedSecret
        _ttlSeconds = Int64(ttlSeconds)
    }
    
    public init?(sharedSecret:String, ttlSeconds:Int = 30) {
        
        guard let sharedSecretData = sharedSecret.data(using: .utf8) else {
            return nil
        }
        
        _sharedSecret = sharedSecretData
        _ttlSeconds = Int64(ttlSeconds)
    }

    public func generate() -> OneTimePassword {
        
        let to = Int64(Date.init(timeIntervalSince1970: 0).timeIntervalSince1970)
        let ti = self._ttlSeconds
        let un = Int64(Date().timeIntervalSince1970)
        var tc = (un - to) / ti
        
        let tcData = Data(buffer: UnsafeBufferPointer(start: &tc, count: 1))

        return OneTimePassword(value: hotp(key: _sharedSecret, counter: tcData) % 1000000, expires: (tc+1) * ti)
    }
    
    private func hotp(key:Data, counter:Data) -> Int {

        let hmacCounter = hmac(key: key, message: counter)
        
        return truncate(data: hmacCounter) & 0x7FFFFFFF
    }
    
    private func truncate(data:Data) -> Int {

        var result:Int = 0
        var resultData = Data(bytesNoCopy: &result, count: MemoryLayout<Int>.size, deallocator: .none)
        let stride = data.count / 4
        let remnant = data.count % 4
        
        resultData.withUnsafeMutableBytes { (pResult:UnsafeMutablePointer<UInt8>) in
            data.withUnsafeBytes({ (pData:UnsafePointer<UInt8>) in
                
                for y in 0..<4 {
                    
                    let o = y * stride
                    
                    for x in 0..<stride {
                        pResult[y] ^= pData[o + x]
                    }
                }
                
                for x in 0..<remnant {
                    pResult[x] ^= pData[stride*4 + x]
                }

            })
        }

        return result;
    }
    
    private func hmac(key:Data, message:Data) -> Data {

        var result = sha1(xor(key, 0x5c))
        var xordkey = xor(key, 0x36)
        xordkey.append(message)
        
        result.append(xordkey)
        
        return result
    }

    private func sha1(_ dataIn: Data) -> Data {
        
        var bytes: [UInt8] = Array(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        dataIn.withUnsafeBytes { (pDataIn:UnsafePointer<UInt8>) in
            _ = CC_SHA1(pDataIn, CC_LONG(dataIn.count), &bytes)
        }
        
        let dataOut = Data(bytes: bytes)
        
        return dataOut
    }
    
    private func xor(_ dataIn:Data, _ value:UInt8) -> Data {

        var dataOut = Data(count: dataIn.count)
        
        dataOut.withUnsafeMutableBytes { (pDataOut:UnsafeMutablePointer<UInt8>) in
            dataIn.withUnsafeBytes({ (pDataIn:UnsafePointer<UInt8>) in
                
                for i in 0..<dataIn.count {
                    pDataOut[i] = pDataIn[i] ^ value
                }
            })
        }

        return dataOut
    }
}
