//
//  Hub_Structs.swift
//  JoyStick_V4->SiriTest
//

import Foundation
import CoreBluetooth
import UIKit

public class PortValue: NSObject{
    public var Id:Int
    public var InformationType: Int = -1
    public var DeltaInterval: Int = -1
    public var NotificationEnabled: Int = -1
    
    public var ScalarValue: Double = 0
    
    public var xValue: Double = 0
    public var yValue: Double = 0
    public var zValue: Double = 0
    
    public var RollValue: Double = 0
    public var PitchValue: Double = 0
    public var YawValue: Double = 0
    
    public init(Id: Int) {
        self.Id = Id
    }
}


public class HatchManager: NSObject{
    public let blemanager: BLEManager
    public let hub: Hub
    public let PortId: UInt8
    public var intervalpoint: [Double]
    public var max: Double = 0
    public var min: Double = 0
    public var range: Double = 0
    
    public var Alert: UIAlertController?
    
    public var maxpower = 0
    var maxSet: Bool = false
    var minSet: Bool = false
    var move : Bool = false
    
    var value_now: Double = 0
    var value_past: Double = 0
    
    var SetRangeTimer: Timer?
    var EndTimer: Timer?
    
    var SendValueTimer: Timer?
    public var Value: Double = 0.0
    
    public func StartTimer(View: UIViewController){
        print("StartTimer")
        
        alert(View: View)
        
        blemanager.PortInputFormatSetup_Single(hub: hub, PortId: PortId, Mode: 0x02, DeltaInterval: 2, NotificationEnabled: 0x01)
        
        guard SetRangeTimer == nil else { return }
        self.SetRangeTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(SetRange), userInfo: nil, repeats: true)
    }
    
    public func SetIntervalPoints(){
        self.range = max - min
        let interval = range/Double(self.intervalpoint.count+1)
        for i in 0 ..< intervalpoint.count {
            intervalpoint[i] = min + interval*Double(i+1)
        }
        print("max = \(self.max)")
        print("min = \(self.min)")
        print("interval[0]= \(self.intervalpoint[0])")
    }
    
    
    func alert(View: UIViewController){
        self.Alert = UIAlertController(title: "Servo Motor", message: "Setting Range...", preferredStyle: .alert)
        self.Alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            self.Dump()
        }))
        
        View.present(Alert!, animated: true, completion: nil)

    }
    
    @objc func SetRange(){
        print("setrange")
        
        if(self.maxSet == false && self.move == false){
            //self.move = true
            print("setting MAX...")
            self.blemanager.PortOutputCommand_StartSpeed(hub: hub, PortId: self.PortId, StartupInformation: 0, CompletetionInformation: 0, Speed: 30, MaxPower: UInt8(self.maxpower), UseProfile: 0x00)
        }else if(self.minSet == false && self.move == false){
            print("setting MIN...")
            //self.move = true
            self.blemanager.PortOutputCommand_StartSpeed(hub: hub, PortId: self.PortId, StartupInformation: 0, CompletetionInformation: 0, Speed: -30, MaxPower: UInt8(self.maxpower), UseProfile: 0x00)
        }else if(self.minSet == true && self.maxSet == true){
            print("Hatch set complete\tMin:\(self.min), Max:\(self.max)")
            self.SetIntervalPoints()
            self.blemanager.PortOutputCommand_GotoAbsolutePosition(hub: hub, PortId: PortId, StartupInformation: 0, CompletetionInformation: 0, AbsPos: self.intervalpoint[0], Speed: 100, MaxPower: 100, EndState: 0x7e, UseProfile: 0x00)
            
            EndTimer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(StopTimer), userInfo: nil, repeats: false)
            //EndTimerIsOn = true
            Alert!.dismiss(animated: true, completion: nil)
            self.SetRangeTimer!.invalidate()
            //SendValueTimer = Timer.scheduledTimer(timeInterval:0.2, target: self, selector: #selector(SendValue), userInfo: nil, repeats: true)
        }
        SetRangeRefresher(hub: self.hub, PortId: self.PortId)
    }
    
    @objc func StopTimer(){
        self.blemanager.PortOutputCommand_StartPower(hub: self.hub, PortId: self.PortId, StartupInformation: 0, CompletetionInformation: 0, Power: 0)
    }
    
    public func SetRangeRefresher(hub: Hub, PortId: UInt8){
        value_now = Double(hub.Port[Int(PortId)].Value[2].ScalarValue)
        print("value_now= \(value_now)")
        
        if(value_now < value_past && value_now < self.min){
            print("update min")
            self.min = value_now
            self.move=true
        }else if(value_now > value_past && value_now > self.max){
            print("update max")
            self.max = value_now
            self.move=true
        //}else if(abs(value_past-value_now)<2 && abs(value_now-self.min)<2 && self.move==true){
        }else if(value_now-value_past > -2 && abs(value_now-self.min)<2 && self.move==true){
            print("minset = true")
            self.minSet = true
            self.move = false
        }else if(abs(value_past-value_now)<2 && abs(value_now-self.max)<2 && self.move==true){
            print("maxset = true")
            self.maxSet = true
            self.move = false
        }
        value_past=value_now
    }
    
    @objc func SendValue(){
        print("Value = \(Value)")
        blemanager.PortOutputCommand_GotoAbsolutePosition(hub: self.hub, PortId: 2, StartupInformation: 0b0001, CompletetionInformation: 0, AbsPos: Value, Speed: 70, MaxPower: 100, EndState: 0x7e, UseProfile: 0x11)
        
    }
    
    public func Dump(){
        self.SetRangeTimer!.invalidate()
        self.EndTimer?.invalidate()
        self.maxSet = false
        self.minSet = false
        self.move = false
        self.blemanager.PortOutputCommand_StartPower(hub: self.hub, PortId: self.PortId, StartupInformation: 0b0001, CompletetionInformation: 0, Power: 0)
    
    }
    
    public init(blemanager: BLEManager, hub: Hub, PortId: UInt8, intervals: Int, maxpower: Int) {
        self.blemanager = blemanager
        self.hub = hub
        self.PortId = PortId
        self.maxpower = maxpower
        self.intervalpoint = {
            var value = [Double]()
            for _ in 0 ..< intervals {
                value.append(0.00)
            }
            return value
        }()
    }
}

public class HubPort: NSObject{
    public var Id: Int = 0
    public var Name: String = "PortNameUnknown"
    //public var Identifier: String = "WhatIsThis?"
    public var Hardware: PuHardware
    public var Mode: Int = 0
    public var Value: [PortValue]
    /*public var InformationType: Int = -1
    public var DeltaInterval: Int = -1
    public var NotificationEnabled: Int = -1
    public var InputValue: Double = 0
    //public var OutputValue: Double = 0
    
    public var xValue: Double = 0
    public var yValue: Double = 0
    public var zValue: Double = 0
    
    public var RollValue: Double = 0
    public var PitchValue: Double = 0
    public var YawValue: Double = 0*/
    
    func DetatchedIo(){
        self.Hardware=PuHardware.Nil
    }
    
    
    func AttatchedIo(IoTypeId:Int, HardwareRevision:Int, SoftwareRevision:Int){
        print("port[\(self.Id)]: attatched \(IoTypeId)!")
        self.Hardware=PuHardware.init(rawValue: IoTypeId) ?? PuHardware.init(rawValue: -1)!
    }
    
    func AttatchedVirtualIo(IoTypeId:Int, PortIdA:Int, PortIdB:Int){
            print("Port\(PortIdA) and Port\(PortIdA) forms Vport")
    }
    public init(Id: Int) {
        self.Id = Id
        self.Hardware = PuHardware.Nil
        self.Value = {
            var value = [PortValue]()
            for Mode in 0 ..< 10 {
                value.append(PortValue(Id: Mode))
            }
            return value
        }()
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
    public var Port : [HubPort]//(repeating: Port(Hardware: PuHardware.Nil), count: 256)
    //public var attatchedHw = AttatchedHW(PortA: PuHardware.Nil, PortB: PuHardware.Nil, PortC: PuHardware.Nil, PortD: PuHardware.Nil, PortE: PuHardware.Nil, PortF: PuHardware.Nil)
    public var Button: Bool = false
    public var FWVersion: Int = -1
    public var HWVersion: Int = -1
    public var RSSI: Int = 0
    public var BatteryVoltage: Int = -1
    public var BatteryType: Int = -1
    
    public var gyro: HubPort
    
    public init(Name: String){
        self.Name = Name
        self.Port = {
            var Port = [HubPort]()
            for i in 0 ..< 256 {
                Port.append(HubPort(Id: i))
            }
            return Port
        }()
        //self.HubPort[0].Name = "PortA"
        self.gyro = self.Port[63]
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
