//
//  HubActions.swift
//  Control-Function
//

import Foundation
import CoreBluetooth

extension BLEManager{
    public func HubActions_Downstream(hub: Hub, ActionTypes: UInt8) {//02
        let bytes : [UInt8] = [ 0x04, 0x00, 0x02, ActionTypes]
        let data = Data(_:bytes)
        
        self.WriteDataToHub(hub: hub, data: data)
    }
    
    public func HubActions_Upstream(hub: Hub, ReceivedData: [UInt8]) {//02
        switch ReceivedData[3]{
        case 0x30:
            print("Hub Will Switch Off")
            self.delegate?.didTurnOffHub(hub)
            self.toggledelegate?.didTurnOffHub(hub)
            hub.isconnected = false
        case 0x31:
            print("Hub Will Disconnect")
            self.delegate?.didDisconnectHub(hub)
            self.toggledelegate?.didDisconnectHub(hub)
            hub.isconnected = false
        case 0x32:
            print("Hub Will Go Into Boot Mode")
        default:
            print("Unknown Property:", ReceivedData[3] )
        }
    }
}
public protocol HubToggleDelegate: class {
    func didTurnOffHub(_ hub: Hub)
    func didDisconnectHub(_ hub: Hub)
}
