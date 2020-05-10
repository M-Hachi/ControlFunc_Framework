//
//  HubAttatchedIo.swift
//  Control-Function
//

//import Foundation
//import CoreBluetooth

extension BLEManager{
    
    public func HubAttatchedIo_Upstream(hub: Hub, ReceivedData: [UInt8]){//01
        switch ReceivedData[0] {
        case 5:     //Detatched Io
            if(ReceivedData[4]==0x00){
                print("detatched port:\(Int(ReceivedData[3]))")
                //HubHW[HubId].DetatchedIo(Port: Int(ReceivedData[3]))
                //self.BLEHub[HubId].attatchedHw.DetatchedIo(Port: Int(ReceivedData[3]))
                //hub.attatchedHw.DetatchedIo(Port: Int(ReceivedData[3]))
                
                hub.Port[Int(ReceivedData[3])].DetatchedIo()
                self.delegate?.didDetatchPort(hub, hub.Port[Int(ReceivedData[3])])
            }else{
                print("Error: HubAttatchedIo")
            }
            
        case 15:    //Attatched Io
            if(ReceivedData[4]==0x01){
                //self.BLEHub[HubId].attatchedHw.AttatchedIo(Port: Int(ReceivedData[3]), IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), HardwareRevision: 0, SoftwareRevision: 0)
                //HubHW[HubId].AttatchedIo(Port: Int(ReceivedData[3]), IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), HardwareRevision: 0, SoftwareRevision: 0)
                hub.Port[Int(ReceivedData[3])].AttatchedIo(IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), HardwareRevision: 0, SoftwareRevision: 0)
                print("Hub[\(hub.id)].HubPort[\(Int(ReceivedData[3]))]  = \(hub.Port[Int(ReceivedData[3])].Hardware.Name())")
                self.delegate?.didAttatchPort(hub)
            }else{
                print("Error: HubAttatchedIo")
            }
            
        case 9:     //Attatched Virtual Io
            if(ReceivedData[4]==0x02){
                //self.BLEHub[HubId].attatchedHw.AttatchedVirtualIo(Port: Int(ReceivedData[3]), IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), PortIdA: Int(ReceivedData[7]), PortIdB: Int(ReceivedData[8]))
                //hub.attatchedHw.AttatchedVirtualIo(Port: Int(ReceivedData[3]), IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), PortIdA: Int(ReceivedData[7]), PortIdB: Int(ReceivedData[8]))
                hub.Port[Int(ReceivedData[3])].AttatchedVirtualIo(IoTypeId: Int16toInt(value: [ReceivedData[5], ReceivedData[6]]), PortIdA: Int(ReceivedData[7]), PortIdB: Int(ReceivedData[8]))
                self.delegate?.didAttatchVirtualPort(hub)
            }else{
                print("Error: HubAttatchedIo")
            }
        default:
            print("Error: HubAttatchedIo")
        }
    }
}
