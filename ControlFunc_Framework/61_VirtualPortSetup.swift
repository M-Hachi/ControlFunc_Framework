//
//  VirtualPortSetup.swift
//  Control-Function
//
import Foundation
import CoreBluetooth

extension BLEManager{
    func VirtualPortSetup_Disconnect(hub: Hub, PortId: UInt8) {
        var bytes : [UInt8]
        bytes = [0x06,0x00,0x61,0x00, PortId]
        let data = Data(bytes: bytes, count: MemoryLayout.size(ofValue: bytes))
        self.WriteDataToHub(hub: hub, data: data)
        /*if(connection.Status[HubId]==1){
         legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
         }else{
         print("VirtualPortSetup_Connect: No Hub!!!")
         }*/
    }
    
    
    func VirtualPortSetup_Connect(hub: Hub, PortIdA: UInt8, PortIdB: UInt8) {
        var bytes : [UInt8]
        bytes = [0x06,0x00,0x61,0x01, PortIdA,PortIdB]
        let data = Data(bytes: bytes, count: MemoryLayout.size(ofValue: bytes))
        self.WriteDataToHub(hub: hub, data: data)
        /*if(connection.Status[HubId]==1){
         legohub.Peripheral[HubId]?.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
         }else{
         print("VirtualPortSetup_Connect: No Hub!!!")
         }*/
    }
    
}
