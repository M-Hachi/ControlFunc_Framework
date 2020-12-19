// Created 2020/12/19
// Using Swift 5.0

import Foundation
import CoreBluetooth
import UIKit

public protocol HatchManagerDelegate: class {
    func willSetRange(_ manager: HatchManager)
    func didSetRange(_ manager: HatchManager)
}

public class HatchManager: NSObject{
    public var delegate: HatchManagerDelegate?
    public let blemanager: BLEManager
    public let hub: Hub
    public let PortId: UInt8
    public var intervalpoint: [Double]
    //public var max: Double
    public var max: Double = -100
    public var min: Double = 100
    
    public var range: Double = 0
    
    public var Alert: UIAlertController?
    //var AlertIsOnScreen: Bool=false
    
    public var maxpower = 0
    public var Tolerance: Double = 0.05
    
    public var maxSet: Bool{
        didSet{
            print("setmax")
            if(minSet == false){
                self.min = max+100
                print("min = \(min)")
            }
        }
    }
    public var minSet: Bool{
        didSet{
            print("setmin")
            if(maxSet == false){
                self.max = min-100
                print("max = \(max)")
            }
        }
    }
    public var nowSetting: Int = 0
    
    //var move : Bool = false
    
    var value_now: Double = 0
    var value_past: Double = 0
    var lowestSpeed: Int = 10
    public var motorvalue_past:Int = 0
    var topped:Bool = false
    public var motorvalue:Int = 0
    
    public var calibrating: Bool {
        didSet{
            print("cal = \(calibrating)")
            if(calibrating){
                self.maxSet=false
                self.minSet=false
            }
        }
        
    }
    public var SetRangeTimer: Timer?
    var EndTimer: Timer?
    
    var SendValueTimer: Timer?
    public var Value: Double = 0.0
    
    /*public func Calibrate(View: UIViewController){
     alert(View: View)
     
     blemanager.PortInputFormatSetup_Single(hub: hub, PortId: PortId, Mode: 0x02, DeltaInterval: 2, NotificationEnabled: 0x01)
     
     /*guard SetRangeTimer == nil else {
     print("SetRangeTimer != nil")
     return
     }*/
     self.SetRangeTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(SetRange), userInfo: nil, repeats: true)
     }*/
    public func Calibrate(){
        //alert(View: View)
        self.maxSet=false
        self.minSet=false
        self.delegate?.willSetRange(self)
        blemanager.PortInputFormatSetup_Single(hub: hub, PortId: PortId, Mode: 0x02, DeltaInterval: 2, NotificationEnabled: 0x01)
        self.SetRangeTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(SetRange), userInfo: nil, repeats: true)
    }
    
    public func ReCalibrate(View: UIViewController){
        /*if(self.AlertIsOnScreen){
         print("ISonscreen")
         }else{
         self.AlertIsOnScreen=true*/
        alert(View: View)
        //}
        Calibrate()
    }
    public func Calibrate_Sequential(View: UIViewController, title:String, lowestspeed: Int, range: Int){//manually move close to max
        calibrating=true
        self.lowestSpeed = lowestspeed
        self.range = Double(range)
        self.delegate?.willSetRange(self)
        blemanager.PortInputFormatSetup_Single(hub: hub, PortId: PortId, Mode: 0x02, DeltaInterval: 10, NotificationEnabled: 0x01)//check position
        alert_Sequential(View: View, Title: title)
    }
    
    public func SetIntervalPoints(){
        //self.range = max - min
        self.range = max - min
        
        let interval = range/Double(self.intervalpoint.count+1)
        for i in 0 ..< intervalpoint.count {
            intervalpoint[i] = min + interval*Double(i+1)
        }
        self.max = self.max - (self.range * self.Tolerance)
        self.min = self.min + (self.range * self.Tolerance)
        self.range = self.max - self.min
        print("max = \(self.max)")
        print("min = \(self.min)")
        //print("interval[0]= \(self.intervalpoint[0])")
    }
    
    
    func alert(View: UIViewController){
        self.Alert = UIAlertController(title: "Servo Motor", message: "Setting Range...", preferredStyle: .alert)
        self.Alert!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            self.Dump()
        }))
        
        View.present(Alert!, animated: true, completion: nil)
        
    }
    
    func alert_Sequential(View: UIViewController, Title:String){
        self.Alert = UIAlertController(title: Title, message: "Current position is closer to:", preferredStyle: .alert)
        self.Alert!.addAction(UIAlertAction(title: "Max", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.blemanager.PortOutputCommand_StartPower(hub: self.hub, PortId: self.PortId, StartupInformation: 0x00, CompletetionInformation: 0x00, Power: Double(self.maxpower))
            
            self.SetRangeTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.SetRange_Sequential), userInfo: nil, repeats: true)
        }))
        self.Alert!.addAction(UIAlertAction(title: "Min", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.blemanager.PortOutputCommand_StartPower(hub: self.hub, PortId: self.PortId, StartupInformation: 0x00, CompletetionInformation: 0x00, Power: -1*Double(self.maxpower))
            
            self.SetRangeTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.SetRange_Sequential), userInfo: nil, repeats: true)
        }))
        View.present(Alert!, animated: true, completion: nil)
    }
    @objc func SetRange_Sequential(){
        let motorspeed = motorvalue-motorvalue_past
        //print("motorval = \(motorvalue)")
        if(abs(motorspeed) > lowestSpeed){
            topped=true
            print("topped")
        }
        if(calibrating && topped){
            if( abs(motorspeed) < lowestSpeed ){//speed is low
                
                blemanager.PortOutputCommand_StartPower(hub: hub, PortId: PortId, StartupInformation: 0x01, CompletetionInformation: 0x00, Power: 0)
                if(motorvalue>0){//to max
                    self.max = Double(motorvalue)
                    self.min = max - range
                }else{//to min
                    self.min = Double(motorvalue)
                    self.max = min + range
                }
                print("val = \(min), \(max)")
                calibrating = false
                topped=false
                
                self.SetRangeTimer!.invalidate()
                delegate?.didSetRange(self)
            }
        }
        motorvalue_past=motorvalue
        
    }
    @objc func SetRange(){
        print("setrange")
        
        if(self.maxSet == false){
        //if(self.maxSet == false && self.move == false){
            //self.move = true
            print("setting MAX...")
            nowSetting = 1
            self.blemanager.PortOutputCommand_StartSpeed(hub: hub, PortId: self.PortId, StartupInformation: 0, CompletetionInformation: 0, Speed: 100, MaxPower: UInt8(self.maxpower), UseProfile: 0x00)
        }else if(self.minSet == false){
            //}else if(self.minSet == false && self.move == false){
            print("setting MIN...")
            nowSetting = -1
            //self.move = true
            self.blemanager.PortOutputCommand_StartSpeed(hub: hub, PortId: self.PortId, StartupInformation: 0, CompletetionInformation: 0, Speed: -100, MaxPower: UInt8(self.maxpower), UseProfile: 0x00)
        }else if(self.minSet == true && self.maxSet == true){
            print("Hatch set complete\tMin:\(self.min), Max:\(self.max)")
            nowSetting = 0
            //blemanager.PortInputFormatSetup_Single(hub: hub, PortId: PortId, Mode: 0x02, DeltaInterval: 2, NotificationEnabled: 0x00)
            
            self.SetIntervalPoints()
            let middle = (self.max+self.min)/2
            self.blemanager.PortOutputCommand_GotoAbsolutePosition(hub: hub, PortId: PortId, StartupInformation: 0, CompletetionInformation: 0x01, AbsPos: middle, Speed: 100, MaxPower: 100, EndState: 0x7e, UseProfile: 0x00)
            
            EndTimer = Timer.scheduledTimer(timeInterval:1, target: self, selector: #selector(StopTimer), userInfo: nil, repeats: false)
            
            if((Alert?.isViewLoaded)==true){
                //self.AlertIsOnScreen=false
                Alert!.dismiss(animated: true, completion: nil)
            }
            self.SetRangeTimer!.invalidate()
            self.delegate?.didSetRange(self)
        }
        SetRangeRefresher(hub: self.hub, PortId: self.PortId)
    }
    
    @objc func StopTimer(){
        
        self.blemanager.PortOutputCommand_StartPower(hub: self.hub, PortId: self.PortId, StartupInformation: 0, CompletetionInformation: 0, Power: 0)
    }
    
    public func SetRangeRefresher(hub: Hub, PortId: UInt8){
        value_now = Double(hub.Port[Int(PortId)].ValueForMode[2].ScalarValue)
        print("value_now= \(value_now)")
        
        if(value_now < value_past && value_now < self.min && nowSetting == -1){
            print("update min")
            self.min = value_now
            //self.move=true
        }
        if(value_now > value_past && value_now > self.max && nowSetting == 1){
            print("update max")
            self.max = value_now
            //self.move=true
        }
        //}else if(abs(value_past-value_now)<2 && abs(value_now-self.min)<2 && self.move==true){
        /*}else if(value_now-value_past > -4 && abs(value_now-self.min)<4 && self.move==true){
         print("minset = true")
         self.minSet = true
         self.move = false
         }else if(abs(value_past-value_now)<4 && abs(value_now-self.max)<4 && self.move==true){
         print("maxset = true")
         self.maxSet = true
         self.move = false
         }*/
        if(value_now-value_past < 10 && abs(value_past-self.min)<4 && nowSetting == -1){
            print("minset = true")
            self.minSet = true
            //self.move = false
        }else if(abs(value_past-self.max)<10 && nowSetting == 1){
        //}else if(value_now-value_past > -4 && abs(value_past-self.max)<4 && nowSetting == 1){
            print("maxset = true")
            self.maxSet = true
            //self.move = false
        }
        value_past=value_now
    }
    
    /*@objc func SendValue(){
     print("Value = \(Value)")
     blemanager.PortOutputCommand_GotoAbsolutePosition(hub: self.hub, PortId: 2, StartupInformation: 0b0001, CompletetionInformation: 0, AbsPos: Value, Speed: 70, MaxPower: 100, EndState: 0x7e, UseProfile: 0x11)
     }*/
    
    public func Dump(){
        self.SetRangeTimer?.invalidate()
        self.EndTimer?.invalidate()
        self.maxSet = false
        self.minSet = false
        //self.move = false
        nowSetting = 0
        self.min=0
        self.max=0
        self.blemanager.PortOutputCommand_StartPower(hub: self.hub, PortId: self.PortId, StartupInformation: 0b0001, CompletetionInformation: 0, Power: 0)
        if((Alert?.isViewLoaded)==true){
            //self.AlertIsOnScreen=false
            Alert!.dismiss(animated: true, completion: nil)
        }
        
    }
    
    public init(blemanager: BLEManager, hub: Hub, PortId: UInt8, intervals: Int, maxpower: Int, tolerance: Double) {
        self.minSet = false
        self.maxSet = false
        self.blemanager = blemanager
        self.hub = hub
        self.PortId = PortId
        self.maxpower = maxpower
        self.Tolerance = tolerance
        self.intervalpoint = {
            var value = [Double]()
            for _ in 0 ..< intervals {
                value.append(0.00)
            }
            return value
        }()
        self.motorvalue = 0
        self.calibrating = false
        super.init()
    }
}
