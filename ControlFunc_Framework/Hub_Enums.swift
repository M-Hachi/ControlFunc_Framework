// Created 2020/05/05
// Using Swift 5.0

import Foundation
public enum PuHardware : Int{
    case Nil = 0x00
    case MMotor = 0x01
    case TrainMotor = 0x02
    case LedLight = 0x08
    case VisionSensor = 0x25
    case BoostMotor = 0x26
    case LMotor = 0x2e
    case XlMotor = 0x2f
    
    mutating public func Name() -> String {
        switch self {
        case .Nil:
            return "Nil"
        case .MMotor:
            return "M Motor"
        case .TrainMotor:
            return "Train Motor"
        case .LedLight:
            return "LED Light"
        case .VisionSensor:
            return "Vision Sensor"
        case .BoostMotor:
            return "BOOST Motor"
        case .LMotor:
            return "L Motor"
        case .XlMotor:
            return "XL Motor"
        }
    }
}
/*
public enum PuPort : Int{
    case A = 0x00
    case B = 0x01
    case C = 0x02
    case D = 0x03
    case E = 0x04
    case F = 0x05
    
}
*/
