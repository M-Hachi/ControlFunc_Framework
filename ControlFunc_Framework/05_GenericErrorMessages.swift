//
//  GenericErrorMessages.swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation
import CoreBluetooth
extension BLEManager{
    
    func GenericErrorMessages_Upstream(hub: Hub, data: [UInt8]){//05//aabbcc
        //String( value[3], radix: 16)
        print("Error:CommandType:\(data[3]), ErrorCode:\(data[4])")
    }
}
