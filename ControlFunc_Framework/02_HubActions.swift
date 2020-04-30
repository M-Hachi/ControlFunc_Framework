//
//  HubActions.swift
//  Control-Function
//

import Foundation
import CoreBluetooth

extension BLEManager{//
    public func HubActions_Downstream(HubId: Int, ActionTypes: UInt8) {//02
        let bytes : [UInt8] = [ 0x04, 0x00, 0x02, ActionTypes]
        let data = Data(_:bytes)
        
        self.WriteData(HubId: HubId, data: data)
    }
    
    public func HubActions_Upstream(HubId: Int, ReceivedData: [UInt8]) {//02
        switch ReceivedData[3]{
        case 0x30:
            print("Hub Will Switch Off")
        case 0x31:
            print("Hub Will Disconnect")
            self.ConnectionStatus.IsConnected[HubId]=false
        case 0x32:
            print("Hub Will Go Into Boot Mode")
            
        default:
            print("Unknown Property:", ReceivedData[3] )
        }
    }
}
