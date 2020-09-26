//
//  PortValue(Single).swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BLEManager{
    
    func PortValue_Single(hub:Hub, ReceivedData: [UInt8]){//45
        var value: Double = 0.0
        
        //print("ReceivedData:\(ReceivedData)")
        switch ReceivedData[3]{//Port
        case 0x00:
            hub.Port[0].ValueForMode[hub.Port[0].Mode].ScalarValue = datatoDouble(data: ReceivedData)[0]
            
            //print("portA: \(hub.Port[0].ValueForMode[hub.Port[0].Mode].ScalarValue)")
        case 0x01:
            hub.Port[1].ValueForMode[hub.Port[1].Mode].ScalarValue = datatoDouble(data: ReceivedData)[0]
        case 0x02:
            hub.Port[2].ValueForMode[hub.Port[2].Mode].ScalarValue = datatoDouble(data: ReceivedData)[0]
        case 0x03:
            hub.Port[3].ValueForMode[hub.Port[3].Mode].ScalarValue = datatoDouble(data: ReceivedData)[0]
            //print("portD[\(hub.Port[3].Mode)]: \(hub.Port[3].ValueForMode[hub.Port[3].Mode].ScalarValue)")
        case 0x04:
            hub.Port[4].ValueForMode[hub.Port[4].Mode].ScalarValue = datatoDouble(data: ReceivedData)[0]
        case 0x05:
            hub.Port[5].ValueForMode[hub.Port[4].Mode].ScalarValue = datatoDouble(data: ReceivedData)[0]
            
        case 0x63:
            if(ReceivedData[0]==10){
                
                hub.Port[0x63].ValueForMode[hub.Port[0x63].Mode].YawValue=Double(Int16toInt(value: [ReceivedData[4],ReceivedData[5]]))
                hub.Port[0x63].ValueForMode[hub.Port[0x63].Mode].PitchValue=Double(Int16toInt(value: [ReceivedData[6],ReceivedData[7]]))
                hub.Port[0x63].ValueForMode[hub.Port[0x63].Mode].RollValue=Double(Int16toInt(value: [ReceivedData[8],ReceivedData[9]]))
                hub.Port[0x63].ValueForMode[hub.Port[0x63].Mode].invert()
                //print("pos data: \(hub.Port[0x63].ValueForMode[hub.Port[0x63].Mode].PitchValue)")
            }else{
                print("Unknown Mode 0x63: \(ReceivedData)")
                value = datatoDouble(data: ReceivedData)[0]
                print("Hub[\(hub.Name)] Port[\(ReceivedData[3])] value: \(value)")
            }
        /*
         case 0x3b:
         if(ReceivedData[0]==6){//mode=0
         print(ReceivedData)
         value = Double(Int16toInt(value: [ReceivedData[5],ReceivedData[4]]))
         print("Hub[\(HubId)] Port[\(ReceivedData[3])] value: \(value)")
         }else{//mode==1
         print(ReceivedData)
         //print("error in 0x3d")
         }
         case 0x3c:
         if(ReceivedData[0]==6){//mode=0
         print(ReceivedData)
         value = Double(Int16toInt(value: [ReceivedData[5],ReceivedData[4]]))
         print("Hub[\(HubId)] Port[\(ReceivedData[3])] value: \(value)")
         }else{//mode==1
         print(ReceivedData)
         //print("error in 0x3d")
         }
         case 0x3d:
         if(ReceivedData[0]==6){//mode=0
         //print(ReceivedData)
         value = Double(Int16toInt(value: [ReceivedData[5],ReceivedData[4]]))
         print("Hub[\(HubId)] Port[\(ReceivedData[3])] value: \(value)")
         }else{//mode==1
         print("error in 0x3d")
         }
         case 0x60:
         if(ReceivedData[0]==6){//mode=0
         value = Double(Int16toInt(value: [ReceivedData[5],ReceivedData[4]]))
         print("Hub[\(HubId)] Port[\(ReceivedData[3])] value: \(value)")
         }else{//mode==1
         print("error in 0x60")
         }
         case 0x61:
         if(ReceivedData[0]==10){//mode=0
         HubAtt[HubId].yaw = Int16toInt(value: [ReceivedData[9],ReceivedData[8]])
         HubAtt[HubId].pitch = Int16toInt(value: [ReceivedData[7],ReceivedData[6]])
         HubAtt[HubId].roll = Int16toInt(value: [ReceivedData[5],ReceivedData[4]])
         }else{//mode==1
         //value = InttoDouble(value: ReceivedData[4])
         print("Hub[\(HubId)] Port[\(ReceivedData[3])] value: \(value)")
         }
         case 0x62:
         if(ReceivedData[0]==10){
         HubAtt[HubId].yaw = Int16toInt(value: [ReceivedData[9],ReceivedData[8]])
         HubAtt[HubId].pitch = Int16toInt(value: [ReceivedData[7],ReceivedData[6]])
         HubAtt[HubId].roll = Int16toInt(value: [ReceivedData[5],ReceivedData[4]])
         }else{
         print("error in 0x62")
         }
         case 0x63:
         if(ReceivedData[0]==10){
         HubAtt[HubId].yaw = Int16toInt(value: [ReceivedData[5],ReceivedData[4]])
         HubAtt[HubId].pitch = Int16toInt(value: [ReceivedData[7],ReceivedData[6]])
         HubAtt[HubId].roll = Int16toInt(value: [ReceivedData[9],ReceivedData[8]])
         HubAtt[HubId].invert()
         }else{
         print(ReceivedData)
         //value = datatoDouble(ReceivedData: ReceivedData)
         //print("Hub[\(HubId)] Port[\(ReceivedData[3])] value: \(value)")
         }
         //print("Att[\(HubId)]=Y:\(HubAtt[HubId].yaw) P:\(HubAtt[HubId].pitch) R:\(HubAtt[HubId].roll)")*/
        default:
            //print(ReceivedData)
            value = datatoDouble(data: ReceivedData)[0]
            print("Hub[\(hub.Name)] Port[\(ReceivedData[3])] value: \(value)")
            hub.Port[Int(ReceivedData[3])].ValueForMode[hub.Port[Int(ReceivedData[3])].Mode].ScalarValue = value
        }
        delegate?.didUpdatePortValue(hub, hub.Port[Int(ReceivedData[3])])
    }
}
