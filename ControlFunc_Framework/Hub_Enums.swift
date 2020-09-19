// Created 2020/05/05
// Using Swift 5.0

import Foundation
public enum PuHardware : Int{
    case Unknown = -1
    case Nil = 0x00
    case MMotor = 0x01
    case TrainMotor = 0x02
    case LedLight = 0x08
    
    case RGBLight = 0x17
    case ExternalTilt = 0x22
    case Motion = 0x23
    case VisionSensor = 0x25
    case BoostMotor = 0x26
    case InternalServo = 0x27
    case InternalTilt = 0x28
    
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
            return "LED Light (White)"
        case .VisionSensor:
            return "Vision Sensor (Bst)"
        case .BoostMotor:
            return "Servo Motor (Bst)"
        case .LMotor:
            return "L Motor (C+)"
        case .XlMotor:
            return "XL Motor (C+)"
        case .RGBLight:
            return "RGB Light"
        case .ExternalTilt:
            return "External Tilt Sensor"
        case .Motion:
            return "Motion Sensor"
        case .InternalServo:
            return "Internal Motor with Tacho"
        case .InternalTilt:
            return "Internal Tilt Sensor"
        case .Unknown:
            return "Unknown Hw"
        }
    }
}
/*
public enum PuPort : UInt8{
    public typealias RawValue = UInt8
    
    case PortA = 0x00
    case PortB = 0x01
    case PortC = 0x02
    case PortD = 0x03
    case PortE = 0x04
    case PortF = 0x05
    
}*/

