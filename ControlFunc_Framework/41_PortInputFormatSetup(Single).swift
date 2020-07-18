//
//  PortInputFormatSetup(Single).swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation
extension BLEManager{
    public func PortInputFormatSetup_Single(hub: Hub, PortId: UInt8, Mode: UInt8, DeltaInterval: Double, NotificationEnabled: UInt8){//41
        let DIntervalArray: [UInt8] =  DtoInt32(double: DeltaInterval)
        let bytes: [UInt8] = [0x0A, 0x00, 0x41, PortId, Mode,DIntervalArray[0],DIntervalArray[1],DIntervalArray[2],DIntervalArray[3], NotificationEnabled]
        let data = Data(_:bytes)
        self.WriteDataToHub(hub: hub, data: data)
        hub.Port[Int(PortId)].Mode = Int(Mode)
    }
}
