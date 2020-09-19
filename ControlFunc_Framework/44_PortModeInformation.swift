//
//  PortModeInformation.swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BLEManager{
    public func PortModeInformation_Upstream(hub: Hub, ReceivedData: [UInt8]){//44
        let InformationType: Int = Int(ReceivedData[5])
        
        var max = 0
        var k = 5
        while ReceivedData[k] != 0 {
            max = k+1
            k+=1
        }
        var Min:Float = 0.0
        var Max:Float = 0.0
        
        switch InformationType {
        case 0x00://NAME
            print("Port = \(ReceivedData[3]), Mode = \(ReceivedData[4])")
            print("Name= \(( String(bytes: ReceivedData[ReceivedData.index(ReceivedData.startIndex, offsetBy: 6)..<ReceivedData.index(ReceivedData.startIndex, offsetBy: max)], encoding: .ascii) ?? "No Name for Mode" )!)")
        case 0x01://RAW
            memcpy(&Min, [ReceivedData[6],ReceivedData[7],ReceivedData[8],ReceivedData[9]], 4)
            memcpy(&Max, [ReceivedData[10],ReceivedData[11],ReceivedData[12],ReceivedData[13]], 4)
            print("RawMin= \(Min)", "RawMax= \(Max)")
        case 0x02://PCT
            memcpy(&Min, [ReceivedData[6],ReceivedData[7],ReceivedData[8],ReceivedData[9]], 4)
            memcpy(&Max, [ReceivedData[10],ReceivedData[11],ReceivedData[12],ReceivedData[13]], 4)
            print("PctMin= \(Min)", "PctMax= \(Max)")
        case 0x03://SI
            memcpy(&Min, [ReceivedData[6],ReceivedData[7],ReceivedData[8],ReceivedData[9]], 4)
            memcpy(&Max, [ReceivedData[10],ReceivedData[11],ReceivedData[12],ReceivedData[13]], 4)
            print("SiMin= \(Min)", "SiMax= \(Max)")
        case 0x04:////SYMBOL
            print("Symbol= \(( String(bytes: ReceivedData[ReceivedData.index(ReceivedData.startIndex, offsetBy: 6)..<ReceivedData.index(ReceivedData.startIndex, offsetBy: max)], encoding: .ascii) ?? "No Symbol for Mode" )! )\n")
        default:
            print("Error: information type \(InformationType)")
        }
    }
}
