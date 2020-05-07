//
//  HubAttatchedIo.swift
//  Control-Function
//

//import Foundation
//import CoreBluetooth

extension BLEManager{
    public func HubAttatchedIo_Upstream(HubId: Int, ReceivedData: [UInt8]){//01
        switch ReceivedData[0] {
        case 5:     //Detatched Io
            if(ReceivedData[4]==0x00){
                print("detatched port:\(Int(ReceivedData[3]))")
                //HubHW[HubId].DetatchedIo(Port: Int(ReceivedData[3]))
                self.BLEHub[HubId].attatchedHw.DetatchedIo(Port: Int(ReceivedData[3]))
            }else{
                print("Error: HubAttatchedIo")
            }
            
        case 15:    //Attatched Io
            if(ReceivedData[4]==0x01){
                self.BLEHub[HubId].attatchedHw.AttatchedIo(Port: Int(ReceivedData[3])
                    , IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), HardwareRevision: 0, SoftwareRevision: 0)
                //HubHW[HubId].AttatchedIo(Port: Int(ReceivedData[3]), IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), HardwareRevision: 0, SoftwareRevision: 0)
                print("Hub[\(HubId)].PortA  = \(self.BLEHub[HubId].attatchedHw.PortA.Name())")
            }else{
                print("Error: HubAttatchedIo")
            }
            
        case 9:     //Attatched Virtual Io
            if(ReceivedData[4]==0x02){
                self.BLEHub[HubId].attatchedHw.AttatchedVirtualIo(Port: Int(ReceivedData[3]), IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), PortIdA: Int(ReceivedData[7]), PortIdB: Int(ReceivedData[8]))
            }else{
                print("Error: HubAttatchedIo")
            }
        default:
            print("Error: HubAttatchedIo")
        }
    }
}
