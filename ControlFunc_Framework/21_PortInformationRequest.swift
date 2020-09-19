//
//  PortInformationRequest.swift
//  Control-Function
//

import Foundation
import CoreBluetooth

extension BLEManager{
    public func PortInformationRequest(hub: Hub, PortId: UInt8, InformationType: UInt8) {//21
        print("HubId: \(hub.id), PortID: \(PortId), InfoType: \(InformationType)" )
        let bytes: [UInt8] = [0x05, 0x00, 0x21, PortId, InformationType]
        //let bytes : [UInt8] = [ 0x08, 0x00, 0x81, 0x32, 0x11, 0x51, 0x00, UInt8(Int16(LED_color)) ]
        let data = Data(_:bytes)
        self.WriteDataToHub(hub: hub, data: data)
    }
}
