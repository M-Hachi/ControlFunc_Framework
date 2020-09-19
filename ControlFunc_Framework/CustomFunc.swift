// Created 2020/08/28
// Using Swift 5.0

import Foundation
func GetPortModeInfo(Hub: Int, port:Int){
    print("port:\(port)")
    for mode in 0...10{
        for type in 0...4{
            //PortModeInformationRequest(HubId: Hub, PortId: UInt8(port), Mode: UInt8(mode), InformationType: UInt8(type))
        }
    }
}

func CalcYaw(yaw: Double)->Double{
    var Mul: Double
    let Ratio :Double = 140/12
    Mul = yaw*Ratio
    if(Mul > 45.0*Ratio){
        Mul = 45.0*Ratio
    }else if(Mul < -45.0*Ratio){
        Mul = -45.0*Ratio
    }
    print("Calc Yaw: \(Mul)")
    return Mul
}
