//
//  PortOutputCommand.swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation

extension BLEManager{//
    /*public func PortOutputCommand_StartPower(HubId: Int, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Power: Double) {
        var bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        print("SC:\(StartupAndCompletetionInformation)")
        //CommonHeader, PortID, S&Cinfo, SubCommand(=motor control), payload(=power, degrees, etc)
        //let port:UInt8=UInt8(PortId.rawValue)
        bytes = [0x08,0x00,0x81,PortId, StartupAndCompletetionInformation,0x51,0x00,DtoUInt8(double: Power)]
        let data = Data(bytes: bytes, count: 8)
        //self.WriteData(HubId: HubId, data: data)
        //    legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
    }*/
    
    public func PortOutputCommand_StartPower(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Power: Double) {
        var bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        //print("SC:\(StartupAndCompletetionInformation)")
        //CommonHeader, PortID, S&Cinfo, SubCommand(=motor control), payload(=power, degrees, etc)
        //let port:UInt8=UInt8(PortId.rawValue)
        bytes = [0x08,0x00,0x81,PortId, StartupAndCompletetionInformation,0x51,0x00,DtoUInt8(double: Power)]
        let data = Data(bytes: bytes, count: 8)
        self.WriteDataToHub(hub: hub, data: data)
    }
    
    
    public func PortOutputCommand_SetAccTime(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Time: Int, ProfileNo :UInt8){//0x05
        let bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        let TimeArray = InttoInt16(value: Time)
        bytes = [ 0x09,0x00,0x81,PortId, StartupAndCompletetionInformation,0x05, TimeArray[0], TimeArray[1], ProfileNo]
        let data = Data(bytes: bytes, count: MemoryLayout.size(ofValue: bytes))
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
    }
    
    
    public func PortOutputCommand_SetDecTime(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Time: Int, ProfileNo :UInt8){//0x05
        let bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        let TimeArray = InttoInt16(value: Time)
        bytes = [ 0x09,0x00,0x81,PortId, StartupAndCompletetionInformation,0x06, TimeArray[0], TimeArray[1], ProfileNo]
        let data = Data(bytes: bytes, count: MemoryLayout.size(ofValue: bytes))
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
    }
    
    
    public func PortOutputCommand_StartSpeed(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Speed:Double, MaxPower:UInt8, UseProfile:UInt8) {//0x07
        var bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        var SpeedOut :Double
        
        if(abs(Speed)>100){
            SpeedOut = 100*Speed/abs(Speed)
        }else{
            SpeedOut = Speed
        }
        
        bytes = [0x09,0x00,0x81,PortId, StartupAndCompletetionInformation,0x07,DtoUInt8(double: SpeedOut),MaxPower, UseProfile ]
        
        let data = Data(bytes: bytes, count: 9)
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withoutResponse)
    }
    public func PortOutputCommand_StartSpeedForTime(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Time:Double, Speed:Double, MaxPower:UInt8, EndState:UInt8, UseProfile:UInt8) {//0x09
        var bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        var SpeedOut :Double
        
        if(abs(Speed)>100){
            SpeedOut = 100*Speed/abs(Speed)
        }else{
            SpeedOut = Speed
        }
        
        let TimeArray = DtoInt16(double: Time)
        
        bytes = [0x09,0x00,0x81,PortId, StartupAndCompletetionInformation,0x09,TimeArray[0], TimeArray[1], DtoUInt8(double: SpeedOut), MaxPower, EndState, UseProfile ]
        
        let data = Data(bytes: bytes, count: 12)
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withoutResponse)
    }
    
    public func PortOutputCommand_StartSpeedForDegrees(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Degrees:Double, Speed:Double, MaxPower:UInt8, EndState:UInt8, UseProfile:UInt8) {//0x0B = 11
        var bytes : [UInt8]
        var SPEED=Speed
        if(abs(SPEED)>100){
            SPEED = 100 * abs(Speed)/Speed
        }
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        let AbsPosArray = DtoInt32(double: Degrees)
        print("deg:\(Degrees)")
        bytes = [0x0e,0x00,0x81,PortId, StartupAndCompletetionInformation,0x0B,AbsPosArray[0],AbsPosArray[1], AbsPosArray[2],AbsPosArray[3],DtoUInt8(double: SPEED),MaxPower, EndState, UseProfile ]
        let data = Data(bytes: bytes, count: 14)
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withoutResponse)
    }
    
    public func PortOutputCommand_GotoAbsolutePosition(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, AbsPos:Double, Speed:UInt8, MaxPower:UInt8, EndState:UInt8, UseProfile:UInt8) {//0x0D
        var bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        let AbsPosArray = DtoInt32(double: AbsPos)
        bytes = [0x0e,0x00,0x81,PortId, StartupAndCompletetionInformation,0x0D,AbsPosArray[0],AbsPosArray[1], AbsPosArray[2],AbsPosArray[3],Speed,MaxPower, EndState,UseProfile ]
        let data = Data(bytes: bytes, count: 14)
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withoutResponse)
    }
    
    public func PortOutputCommand_PresetEncoder(hub: Hub, PortId: UInt8, StartupInformation: Int, CompletetionInformation: Int, Position :Double) {//N/A
        var bytes : [UInt8]
        let StartupAndCompletetionInformation: UInt8 = UInt8(StartupInformation*16 + CompletetionInformation)
        let PosArray = DtoInt32(double: Position)
        bytes = [0x0B,0x00,0x81,PortId, StartupAndCompletetionInformation,0x51,0x02,PosArray[0], PosArray[1],PosArray[2],PosArray[3]]
        print("PresetEncoder:\(bytes)")
        let data = Data(bytes: bytes, count: 10)
        self.WriteDataToHub(hub: hub, data: data)
        //legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
    }
}
