//
//  PortOutputCommandFeedback.swift
//  Control-Function
//
//  Created by 森内　映人 on 2020/04/04.
//  Copyright © 2020 森内　映人. All rights reserved.
//

import Foundation

extension BLEManager{//

func PortOutputCommandFeedback_Upstream(hub: Hub,  ReceivedData: [UInt8]){//82
    self.delegate?.didReceivePortOutputCommandFeedback(hub,hub.Port[ Int(ReceivedData[3])], ReceivedData[4])
    /*
    if(ReceivedData[4]==10){
        print("Hub[\(hub.Name)] Port[\( ReceivedData[3])] is Busy/Full")
        //connection.Buffer[HubID][Int(data[3])] = 0x10
    }*/
}
}
