//
//  HubActions.swift
//  Control-Function
//

import Foundation
import CoreBluetooth

public func HubActions_Downstream(HubId: Int, ActionTypes: UInt8) {//02
    let bytes : [UInt8] = [ 0x04, 0x00, 0x02, ActionTypes]
    let data = Data(_:bytes)
    /*if(connection.Status[HubId]==1){
        legohub.Peripheral[HubId]!.writeValue(data, for: legohub.Characteristic[HubId]!, type: .withResponse)
    }else{
        print("HubActions: No Hub!")
    }*/
}

public func HubActions_Upstream(HubId: Int, ReceivedData: [UInt8]) {//02
    switch ReceivedData[3]{
    case 0x30:
        print("Hub Will Switch Off")
    case 0x31:
        print("Hub Will Disconnect")
    case 0x32:
        print("Hub Will Go Into Boot Mode")
        
    default:
        print("Unknown Property:", ReceivedData[3] )
    }
}
