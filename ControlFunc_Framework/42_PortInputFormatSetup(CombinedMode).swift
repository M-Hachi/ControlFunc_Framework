//
//  PortInputFormatSetup(CombinedMode).swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation

extension BLEManager{//
    public func PortInputFormatSetup_CombinedMode(hub:Hub, PortId: UInt8, SubCommand: UInt8){//42 for use in Virtual port
        
        let bytes: [UInt8] = [0x05, 0x00, 0x42, PortId, SubCommand]
        let data = Data(_:bytes)
        self.WriteDataToHub(hub: hub, data: data)
    }
    
    
    public func PortInputFormatSetup_CombinedMode_SetModeDataSet(hub:Hub, PortId: UInt8, CombinationIndex: UInt8, Mode_DataSet:[UInt8]){//42
        
        let bytes: [UInt8] = [0x08, 0x00, 0x42, PortId, 0x01, CombinationIndex, Mode_DataSet[0], Mode_DataSet[1]]
        let data = Data(_:bytes)
        self.WriteDataToHub(hub: hub, data: data)
    }
}
