//
//  Hub_Structs.swift
//  JoyStick_V4->SiriTest
//

import Foundation
import CoreBluetooth
public struct Port{
    public var Id: Int
    public var Name: String = "PortNameUnknown"
    //public var Identifier: String = "WhatIsThis?"
    public var Hardware: PuHardware
    public var InputMode: Int = -1
    public var OutputMode: Int = -1
    public var InformationType: Int = -1
    public var DeltaInterval: Int = -1
    public var NotificationEnabled: Int = -1
    public var InputValue: Double = 0
    public var OutputValue: Double = 0
    
    mutating func DetatchedIo(){
        self.Hardware=PuHardware.Nil
    }
    
    
    mutating func AttatchedIo(IoTypeId:Int, HardwareRevision:Int, SoftwareRevision:Int){
        print("port[\(self.Id)]: attatched \(IoTypeId)!")
        self.Hardware=PuHardware.init(rawValue: IoTypeId) ?? PuHardware.init(rawValue: -1)!
    }
    
    mutating func AttatchedVirtualIo(IoTypeId:Int, PortIdA:Int, PortIdB:Int){
            print("Port\(PortIdA) and Port\(PortIdA) forms Vport")
    }
}

public struct ManufacturerData{
    var Length: Int = -1
    var DataTypeName: Int = -1
    var ManufacturerId: Int = -1
    var ButtonState: Int = -1
    public var SystemTypeAndDeviceNumber :Int = -1
    //128=100 00000 = Technic Hub
    //65=010 00001 = Train Hub(HUB NO.4)
    var DeviceCapabilities: Int = -1
    var LastNetWork:Int = -1
    var Status: Int = -1
    var Option: Int = -1
}

public class Hub: NSObject{//portの情報などを保持する
    public var Name: String = "HubNameUnknown"
    public var AdvName: String = "AdvNameUnknown"
    public var id: Int = -1
    public var Characteristic: CBCharacteristic?
    public var Peripheral: CBPeripheral?
    public var manufacturerdata = ManufacturerData()
    public var Identifier : UUID?
    public var isconnected: Bool = false
    //public var manufacturerdata = ManufacturerData()
    
    public var Device: String = "device"
    public var HubPort : [Port]//(repeating: Port(Hardware: PuHardware.Nil), count: 256)
    //public var attatchedHw = AttatchedHW(PortA: PuHardware.Nil, PortB: PuHardware.Nil, PortC: PuHardware.Nil, PortD: PuHardware.Nil, PortE: PuHardware.Nil, PortF: PuHardware.Nil)
    public var Button: Bool = false
    public var FWVersion: Int = -1
    public var HWVersion: Int = -1
    public var RSSI: Int = 0
    public var BatteryVoltage: Int = -1
    public var BatteryType: Int = -1
    
    public init(Name: String){
        self.Name = Name
        self.HubPort = {
            var HubPort = [Port]()
            for i in 0 ..< 256 {
                HubPort.append(Port(Id: i, Hardware: PuHardware.Nil))
            }
            return HubPort
        }()
        //self.HubPort[0].Name = "PortA"
    }
}

//var DriveHub = [Attitude].self
/*struct Attitude{
    var yaw: Int = 0
    var roll: Int = 0
    var pitch: Int = 0
    var yaw_cal: Int = 0
    var roll_cal: Int = 0
    var pitch_cal: Int = 0
    
    var yaw_inv: Int = 0
    var roll_inv: Int = 0
    
    var yaw_slider: Int = 0
    var yaw1: Int = 0
}*/
class Attitude{
    var yaw: Int = 0
    var roll: Int = 0
    var pitch: Int = 0
    var yaw_cal: Int = 0
    var roll_cal: Int = 0
    var pitch_cal: Int = 0
    
    var yaw_inv: Int = 0
    var roll_inv: Int = 0
    
    var yaw_slider: Int = 0
    var yaw1: Int = 0
    
    init(){
        self.yaw = 0
        self.roll = 0
        self.pitch = 0
        self.yaw_cal = 0
        self.roll_cal = 0
        self.pitch_cal = 0
        
        self.yaw_inv = 0
        self.roll_inv = 0
        
        self.yaw_slider = 0
        self.yaw1 = 0
    }
    
    func invert(){
        if(roll>=0){
            roll_inv=roll-180
        }else{
            roll_inv=roll+180
        }
    }
}
var HubAtt = [Attitude](repeating: Attitude() , count: 10)
//var HubAtt = [Attitude](repeating: Attitude(yaw: 0, roll:0, pitch:0, yaw_cal:0, roll_cal:0, pitch_cal:0, yaw_slider:0, yaw1: 0) , count: 10)
/*
public struct AttatchedHW{
    
    public var PortA: PuHardware
    public var PortB: PuHardware
    public var PortC: PuHardware
    public var PortD: PuHardware
    public var PortE: PuHardware
    public var PortF: PuHardware
    
    mutating func DetatchedIo(Port:Int){
        switch Port {
        case 0:
            self.PortA=PuHardware.Nil
        case 1:
            self.PortB=PuHardware.Nil
        case 2:
            self.PortC=PuHardware.Nil
        case 3:
            self.PortD=PuHardware.Nil
        case 4:
            self.PortE=PuHardware.Nil
        case 5:
            self.PortF=PuHardware.Nil
        default:
            print("Error in Port=\(Port)")
        }
    }
    
    mutating func AttatchedIo(Port:Int, IoTypeId:Int, HardwareRevision:Int, SoftwareRevision:Int){
        switch Port {
        case 0:
            self.PortA=PuHardware.init(rawValue: IoTypeId)!
        case 1:
            self.PortB=PuHardware.init(rawValue: IoTypeId)!
        case 2:
            self.PortC=PuHardware.init(rawValue: IoTypeId)!
        case 3:
            self.PortD=PuHardware.init(rawValue: IoTypeId)!
        case 4:
            self.PortE=PuHardware.init(rawValue: IoTypeId)!
        case 5:
            self.PortF=PuHardware.init(rawValue: IoTypeId)!
        default:
            print("Error in Port=\(Port)")
        }
    }
    
    mutating func AttatchedVirtualIo(Port:Int, IoTypeId:Int, PortIdA:Int, PortIdB:Int){
            print("Port\(PortIdA) and Port\(PortIdA) forms Vport\(Port)")
    }
}*/

//var HubHW = [AttatchedHW](repeating: AttatchedHW(PortA: PuHardware.Nil, PortB:PuHardware.Nil, PortC: 0, PortD: 0, PortE: 0, PortF: 0), count: 10)
    //var HubHW = [AttatchedHW](repeating: AttatchedHW(PortB: 0, PortC: 0, PortD: 0, PortE: 0, PortF: 0), count: 10)
/*
struct PortValue{
    var PortA: Double
    var PortB: Double
    var PortC: Double
    var PortD: Double
    var PortE: Double
    var PortF: Double
}
var HubPorts = [PortValue](repeating: PortValue(PortA: 0, PortB: 0, PortC: 0, PortD: 0, PortE: 0, PortF: 0), count: 10)
*/

struct PortTimer{
    var PortA = Timer()
    var PortB = Timer()
    var PortC = Timer()
    var PortD = Timer()
    var PortE = Timer()
    var PortF = Timer()
}
var HubTimers = [PortTimer](repeating: PortTimer(), count: 10)


struct DegreesCal{//最大値・最小値・零点設定用
    var Max: Double
    var Min: Double
    var Zero: Double
    var MaxSet: Bool
    var MinSet: Bool
    var ZeroSet: Bool
    var Move: Bool
}
/*
struct ArmHub{
    static var hatch = [Double](repeating: 0, count: 100)//PortA
    static var hatchCal = DegreesCal(Max: 0, Min: 0, Zero: 0, MaxSet: false, MinSet: false, ZeroSet: false, Move: false)
    
    static var Elbow : Int = 0
    static var Elbow_cal : Int = 0
    
    static var Ports = PortValue(PortA: 0, PortB: 0, PortC: 0, PortD: 0, PortE: 0, PortF: 0)
    static var Ports_dt = PortValue(PortA: 0, PortB: 0, PortC: 0, PortD: 0, PortE: 0, PortF: 0)
    
    static var Mode : Int = 0
    static var Attatchment : Int = 0
    //static var GestureRecognition:Bool = false
    static var Gesture :Int = 0
    static var GestureLog = [Int](repeating: 0, count: 3)
    static var Gesture_Timer = Timer()
    static var Gesture_IntervalTimer = Timer()
    static var Gesture_Error=[Double](repeating: 0.0, count: 5)
    static var Gesture_Error_min:Double=0.0
    static var Gesture_Tolerance=[Double](repeating: 0.5, count: 5)
    static var userDefaults = UserDefaults.standard
}
*/
