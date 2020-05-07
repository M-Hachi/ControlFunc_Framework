//
//  FindHub.swift
//  Control-Function


import Foundation
import UIKit
import CoreBluetooth
//test30
public let legohubServiceCBUUID = CBUUID(string: "00001623-1212-EFDE-1623-785FEABCD123")
public let legohubCharacteristicCBUUID = CBUUID(string: "00001624-1212-EFDE-1623-785FEABCD123")

struct BLEConst {
    static let MaxHubs = 10
}

public class HubConnectionManager{
    public var Characteristic = [CBCharacteristic?](repeating: nil, count: 10)
    public var Peripheral = [CBPeripheral?](repeating: nil, count: 10)
    public var manufacturerdata = [ManufacturerData](repeating:ManufacturerData(), count: 10)
    public var Identifier = [UUID](repeating: UUID(uuidString: "ABC1C06A-1844-4DA8-11C2-298F5C64BE2B")!, count: 10)
    public var No = 0
    public var IsConnected = [Bool](repeating: false/*初期値*/, count: 10/*必要な要素数*/)
    
    public init() {
        
    }
}
/*
 public let BLEHub: [Hub] = {
 var BLEHub = [Hub]()
 for _ in 0 ..< 5 {
 BLEHub.append(Hub())
 }
 return BLEHub
 }()*/

public class BLEManager:NSObject{
    public var centralManager : CBCentralManager!
    
    public let BLEStatus = HubConnectionManager()
    public var AlertController: UIAlertController!
    
    public var BLEHub: [Hub]
    //public let Hardware: PuHardware
    //public let Port: PuPort
    
    public func Toggle_On(SwiftView: UIViewController, SwiftSwitch:UISwitch, HubId:Int){
        self.alert_hub(SwiftView: SwiftView, SwiftSwitch: SwiftSwitch, No: HubId)
        self.BLEStatus.No=HubId
        //self.ConnectionStatus.No=HubId
        self.centralManager.scanForPeripherals(withServices: [legohubServiceCBUUID])
    }
    
    public func Toggle_Off(SwiftView: UIViewController, SwiftSwitch:UISwitch, HubId:Int){
        if(self.BLEStatus.IsConnected[HubId]){
            //if(self.ConnectionStatus.IsConnected[HubId]){
            print("Hub\(HubId) turn Off Action")
            self.HubActions_Downstream(HubId: HubId, ActionTypes: 0x01)
            self.BLEStatus.IsConnected[HubId]=false
        }else{
            print("Error hub \(HubId): Switch Toggle Off")
        }
        
    }
    
    public func alert_hub(SwiftView: UIViewController, SwiftSwitch:UISwitch, No:Int) {
        self.AlertController = UIAlertController(title: "Scanning...", message: "Press button on hub.", preferredStyle: .alert)
        self.AlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{
            (action: UIAlertAction!) -> Void in
            //Cancelが押された時の処理
            print("Switch turned Off")
            SwiftSwitch.setOn(false, animated: true)
            self.centralManager.stopScan()
        }))
        SwiftView.present(self.AlertController, animated: true, completion: nil)
    }
    
    public func closeAlert() {
        self.AlertController.dismiss(animated: true, completion: nil)
    }
    
    public func WriteData(HubId: Int, data: Data){
        if(BLEStatus.IsConnected[HubId]){
            print("will write")
            self.BLEStatus.Peripheral[HubId]!.writeValue(data, for: BLEStatus.Characteristic[HubId]!, type: .withResponse)
        }else{
            print("ERROR: Hub\(HubId) is not connected!")
        }
    }
   
    
    func ReadManufacturerData(data: NSData, hub: Hub){
        hub.manufacturerdata.ButtonState=Int(UInt8(data[2]))
        hub.manufacturerdata.SystemTypeAndDeviceNumber=Int(UInt8(data[3]))
        
        print("ButtonState: \(hub.manufacturerdata.ButtonState)")
        print("systemtype:  \(hub.manufacturerdata.SystemTypeAndDeviceNumber)")
        
        print(data, "count= ",data.count)
        let zero = UInt8(data[0])
        print("zero: ", String(zero, radix: 2)) //->000D
        
        let one = UInt8(data[1])
        print("one: ", String(one, radix: 2)) //->000D
        
        
        let buttonstate = UInt8(data[2])
        //print( "button", String(format: "%04X", buttonstate)) //->000D
        print("buttonstate: ", String(buttonstate, radix: 2)) //->000D
        
        let systemtype = UInt8(data[3])
        print("systemtype: ", String(systemtype, radix: 2)) //->000D
        
        let device = UInt8(data[4])
        print("device capabilities: ", String(device, radix: 2)) //->000D
        
        let network = UInt8(data[5])
        print("network: ", String(network, radix: 10)) //->000D
        let status = UInt8(data[6])
        print("status: ", String(status, radix: 2)) //->000D
        let option = UInt8(data[7])
        print("option: ", String(option, radix: 10)) //->000D
        
    }
    
    public init(NumberOfHubs: Int) {
        self.BLEHub = {
            var BLEHub = [Hub]()
            for _ in 0 ..< NumberOfHubs {
                BLEHub.append(Hub())
            }
            return BLEHub
        }()
        super.init()
        self.centralManager=CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate{
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        //self.BTCondition_label.text = String("unknown")
        case .resetting:
            print("central.state is .resetting")
        //self.BTCondition_label.text = String("resetting")
        case .unsupported:
            print("central.state is .unsupported")
        //self.BTCondition_label.text = String("unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        //self.BTCondition_label.text = String("unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        //self.BTCondition_label.text = String("OFF")
        case .poweredOn:
            print("central.state is .poweredOn")
        //self.BTCondition_label.text = String("ON")
        @unknown default:
            print("unknown deafult")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("peripheral is: ",peripheral)
        print("peripheral name is: ",peripheral.name!)
        print("peripheral identifier is: ",peripheral.identifier)
        
        //BLEHub[BLEStatus.No].Device = self.ReadManufacturerData(data: advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData, hub: BLEHub[BLEStatus.No])
        self.ReadManufacturerData(data: advertisementData[CBAdvertisementDataManufacturerDataKey] as! NSData, hub: BLEHub[BLEStatus.No])
        //print("advertisementData is: ", BLEHub[BLEStatus.No].Device)
        //HubStatus.Peripheral[ConnectionStatus.No] = peripheral
        BLEStatus.Peripheral[BLEStatus.No] = peripheral
        //legohub.Peripheral[connection.No] = peripheral
        
        //legohub.Peripheral[connection.No]?.delegate = self //こっちだと数回接続するとなんかエラー出るけど通信はできる
        
        //legohub.Identifier[connection.No] = peripheral.identifier
        //HubStatus.Identifier[ConnectionStatus.No] = peripheral.identifier
        BLEStatus.Identifier[BLEStatus.No] = peripheral.identifier
        
        //central.connect(legohub.Peripheral[connection.No]!)
        //central.connect(HubStatus.Peripheral[ConnectionStatus.No]!)
        central.connect(BLEStatus.Peripheral[BLEStatus.No]!)
        
        central.stopScan()
    }
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        AlertController.dismiss(animated: true, completion: nil)
        //connection.Status[connection.No]=1
        peripheral.delegate = self as CBPeripheralDelegate
        print("didDiscoverServices")
        peripheral.discoverServices([legohubServiceCBUUID])
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected!")
        if(error==nil){
            print("no error")
        }else{
            print("Disconnect error: \(String(describing: error))")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("services for",peripheral.name!)
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print(characteristic)
            //legohub.Characteristic.insert(characteristic, at: connection.No )
            
            //legohub.Characteristic[connection.No] = characteristic
            //HubStatus.Characteristic[ConnectionStatus.No] = characteristic
            BLEStatus.Characteristic[BLEStatus.No] = characteristic
            self.BLEStatus.IsConnected[BLEStatus.No]=true//接続できたことを記録
            
            self.DidConnectToHub(HubId:BLEStatus.No)
            peripheral.setNotifyValue(true, for: characteristic)
            //HubPropertiesSet(Hub: connection.No, Reference: 0x06, Operation: 0x05)
            //HubPropertiesSet(Hub: connection.No, Reference: 0x06, Operation: 0x02)
            //HubProperties_Downstream(HubId: connection.No, HubPropertyReference: 0x06, HubPropertyOperation: 0x02)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {//readに必要
        switch characteristic.uuid {
        case legohubCharacteristicCBUUID:
            if(characteristic.value==nil){
                print("value is nil")
            }else{
                let characteristicData = characteristic.value
                let size :Int = Int(characteristicData?.first ?? 0)
                var data = [UInt8](repeating: 0, count: size)
                _ = characteristicData?.copyBytes(to: &data, count: MemoryLayout<UInt8>.size * size)
                var Hub:Int = -1
                var i:Int = 0
                
                while(i<=BLEConst.MaxHubs){
                    if(peripheral.identifier == BLEStatus.Identifier[i]){
                        //if(peripheral.identifier == HubStatus.Identifier[i]){
                        Hub=i
                        break
                    }else{
                        i+=1
                    }
                }
                if(Hub == -1){
                    print("unknown Hub")
                    abort()
                }
                
                switch data[2]{
                case 0x01:
                    HubProperties_Upstream(HubId: Hub, ReceivedData: data)
                case 0x02:
                    HubActions_Upstream(HubId: Hub, ReceivedData: data)
                case 0x03:
                    HubAlerts_Upstream(HubId: Hub, ReceivedData: data)
                case 0x04:
                    HubAttatchedIo_Upstream(HubId: Hub, ReceivedData: data)
                case 0x05:
                    GenericErrorMessages_Upstream(HubId: Hub, data: data)
                case 0x44:
                    PortModeInformation_Upstream(HubId: Hub, ReceivedData: data)
                case 0x45:
                    PortValue_Single(HubId: Hub, ReceivedData: data)
                case 0x47:
                    PortInputFormat_Upstream(HubId: Hub, ReceivedData: data)
                case 0x82:
                    PortOutputCommandFeedback_Upstream(HubID: Hub, data: data)
                    
                default:
                    //print((String(data, radix: 16))
                    print("Unknown Updated value:",data )
                }
            }
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
}
