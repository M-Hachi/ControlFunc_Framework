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

//legohubの中身を配列にする
//CBCharacteristicの初期値を設定できないのでlegohubを配列にはできない？
public class HubStatusManager{
    public var Characteristic = [CBCharacteristic?](repeating: nil, count: 10)
    public var Peripheral = [CBPeripheral?](repeating: nil, count: 10)
    public var Identifier = [UUID](repeating: UUID(uuidString: "ABC1C06A-1844-4DA8-11C2-298F5C64BE2B")!, count: 10)
    
    public init() {
        
    }
    static var Button = [Bool](repeating: false, count: 10)
    static var Battery = [Int](repeating: 0, count: 10)
}

public class ConnectionStatusManager{
    public var No = 0
    public var IsConnected = [Bool](repeating: false/*初期値*/, count: 10/*必要な要素数*/)
    public init() {
        
    }
}
public class BLEManager:NSObject{
    public var centralManager : CBCentralManager!
    
    //public var HubStatus = [HubStatusManager](repeating: HubStatusManager(), count: BLEConst.MaxHubs)
    public var HubStatus = HubStatusManager()
    public var ConnectionStatus = ConnectionStatusManager()
    
    public var AlertController: UIAlertController!
    
    public static var No = 0
    public static var Status = [Int](repeating: 0/*初期値*/, count: 10/*必要な要素数*/)
    
    public func Toggle_On(SwiftView: UIViewController, SwiftSwitch:UISwitch, HubId:Int){
        self.alert_hub(SwiftView: SwiftView, SwiftSwitch: SwiftSwitch, No: HubId)
        self.ConnectionStatus.No=HubId
        print("HubId=\(self.ConnectionStatus.No)")
        self.centralManager.scanForPeripherals(withServices: [legohubServiceCBUUID])
    }
    public func Toggle_Off(SwiftView: UIViewController, SwiftSwitch:UISwitch, HubId:Int){
        if(self.ConnectionStatus.IsConnected[HubId]){
            print("Hub\(HubId) turn Off Action")
            self.HubActions_Downstream(HubId: HubId, ActionTypes: 0x01)
        }else{
            print("Error: Switch Toggle Off")
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
        //self.alert.dismiss(animated: true, completion: nil)
    }
    
    public func WriteData(HubId: Int, data: Data){
        if(ConnectionStatus.IsConnected[HubId]){ self.HubStatus.Peripheral[HubId]!.writeValue(data, for: HubStatus.Characteristic[HubId]!, type: .withResponse)
        }else{
            print("ERROR: Hub\(HubId) is not connected!")
        }
    }
    public override init() {
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
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        print("peripheral is: ",peripheral)
        print("peripheral name is: ",peripheral.name!)
        print("peripheral identifier is: ",peripheral.identifier)
        //legohub.Peripheral.append(peripheral)
        //legohub.Peripheral.insert(peripheral, at: connection.No)
        
        HubStatus.Peripheral[ConnectionStatus.No] = peripheral
        //legohub.Peripheral[connection.No] = peripheral
        
        //legohub.Peripheral[connection.No]?.delegate = self //こっちだと数回接続するとなんかエラー出るけど通信はできる
        
        //legohub.Identifier[connection.No] = peripheral.identifier
        HubStatus.Identifier[ConnectionStatus.No] = peripheral.identifier
        
        //central.connect(legohub.Peripheral[connection.No]!)
        central.connect(HubStatus.Peripheral[ConnectionStatus.No]!)
        
        central.stopScan()
    }
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        AlertController.dismiss(animated: true, completion: nil)
        //closeAlert()
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
            HubStatus.Characteristic[ConnectionStatus.No] = characteristic
            
            print(self.HubStatus)
            ConnectionStatus.IsConnected[ConnectionStatus.No]=true//接続できたことを記録
            
            //DidConnectToHub(HubID:connection.No)
            
            //setNotifyValue( true, for: characteristic )
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
                    if(peripheral.identifier == HubStatus.Identifier[i]){
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
                /*switch peripheral.identifier{
                case HubStatus.Identifier[0]:
                    Hub = 0
                case HubStatus.Identifier[1]:
                    Hub = 1
                case HubStatus.Identifier[2]:
                    Hub = 2
                case HubStatus.Identifier[3]:
                    Hub = 3
                default:
                    Hub = -1
                    print("unknown Hub")
                }*/
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
/*public class BLEManager {
 public var centralManager : CBCentralManager!
 public var bleHandler : FindHub // delegate
 public init() {
 self.bleHandler = FindHub()
 self.centralManager = CBCentralManager(delegate: self.bleHandler, queue:       nil)
 }
 }*/
/*public class FindHub: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
 //public var centralManager: CBCentralManager!
 public var AlertController: UIAlertController!
 public var HubStatus = [HubStatusManager](repeating: HubStatusManager(), count: 10)
 public var ConnectionStatus = ConnectionStatusManager()
 
 public override init () {
 //HubStatus[0]
 super.init()
 //centralManager=CBCentralManager(delegate: self, queue: nil)
 }
 
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
 public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
 print("peripheral is: ",peripheral)
 print("peripheral name is: ",peripheral.name!)
 print("peripheral identifier is: ",peripheral.identifier)
 //legohub.Peripheral.append(peripheral)
 //legohub.Peripheral.insert(peripheral, at: connection.No)
 
 HubStatus[ConnectionStatus.No].Peripheral = peripheral
 //legohub.Peripheral[connection.No] = peripheral
 
 //legohub.Peripheral[connection.No]?.delegate = self //こっちだと数回接続するとなんかエラー出るけど通信はできる
 
 //legohub.Identifier[connection.No] = peripheral.identifier
 HubStatus[ConnectionStatus.No].Identifier = peripheral.identifier
 
 //central.connect(legohub.Peripheral[connection.No]!)
 central.connect(HubStatus[ConnectionStatus.No].Peripheral!)
 
 central.stopScan()
 }
 public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
 print("connected!")
 AlertController.dismiss(animated: true, completion: nil)
 //closeAlert()
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
 HubStatus[ConnectionStatus.No].Characteristic = characteristic
 
 //print(legohub.Characteristic)
 //print(legohub.Peripheral)
 //print("connection.No = \(connection.No)")
 
 //connection.Status[connection.No]=1 //接続できたことを記録
 ConnectionStatus.IsConnected[ConnectionStatus.No]=true
 
 //DidConnectToHub(HubID:connection.No)
 
 //setNotifyValue( true, for: characteristic )
 peripheral.setNotifyValue(true, for: characteristic)
 //HubPropertiesSet(Hub: connection.No, Reference: 0x06, Operation: 0x05)
 //HubPropertiesSet(Hub: connection.No, Reference: 0x06, Operation: 0x02)
 //HubProperties_Downstream(HubId: connection.No, HubPropertyReference: 0x06, HubPropertyOperation: 0x02)
 }
 }
 
 public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {//readに必要
 //print("did update value")
 switch characteristic.uuid {
 case legohubCharacteristicCBUUID:
 if(characteristic.value==nil){
 print("value is nil")
 }else{
 let characteristicData = characteristic.value
 let size :Int = Int(characteristicData?.first ?? 0)
 var data = [UInt8](repeating: 0, count: size)
 _ = characteristicData?.copyBytes(to: &data, count: MemoryLayout<UInt8>.size * size)
 let Hub:Int
 switch peripheral.identifier{
 //case legohub.Identifier[0]:
 case HubStatus[0].Identifier:
 Hub = 0
 //case legohub.Identifier[1]:
 case HubStatus[1].Identifier:
 Hub = 1
 //case legohub.Identifier[2]:
 case HubStatus[2].Identifier:
 Hub = 2
 //case legohub.Identifier[3]:
 case HubStatus[3].Identifier:
 Hub = 3
 default:
 Hub = -1
 print("unknown Hub")
 }
 switch data[2]{
 case 0x01:
 HubProperties_Upstream(HubId: Hub, ReceivedData: data)
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
 
 }*/


/*struct legohub{
 static var Characteristic = [CBCharacteristic?](repeating: nil, count: 10)
 static var Peripheral = [CBPeripheral?](repeating: nil, count: 10)
 //static var Status = [Int](repeating: 0/*初期値*/, count: 10/*必要な要素数*/)
 //static var Identifier = [UUID](repeating: UUID(uuidString: "ABCDEFGH-1234-5678-9123-IJKLMNOPQRST")!, count: 10)
 static var Identifier = [UUID](repeating: UUID(uuidString: "ABC1C06A-1844-4DA8-11C2-298F5C64BE2B")!, count: 10)
 static var Button = [Bool](repeating: false, count: 10)
 static var Battery = [Int](repeating: 0, count: 10)
 }*/

//legohubの状態を示す．legohubはnilの可能性がある
/*public struct connection{
 public init() {}
 //class connection{
 public static var No = 0
 public static var Status = [Int](repeating: 0/*初期値*/, count: 10/*必要な要素数*/)
 public static var Buffer = [[Int]](repeating: [Int](repeating: 0, count: 100), count: 10)
 static var BufferTimer = [[Int]](repeating: [Int](repeating: 0, count: 100), count: 10)
 }*/
