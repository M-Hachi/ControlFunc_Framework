//
//  HubProperties.swift
//  Control-Function
//
import Foundation
import CoreBluetooth

/*
 Commmon Header
 
 Property
 0x01    Advertising Name
 0x02    Button
 0x03    FW Version
 
 Operation
 
 Payload
 */
extension BLEManager{
    public func HubProperties_Downstream(hub: Hub, HubPropertyReference: UInt8, HubPropertyOperation: UInt8){//01
        let bytes : [UInt8] = [ 0x05, 0x00, 0x01, HubPropertyReference, HubPropertyOperation]//enable
        let data = Data(_:bytes)
        self.WriteDataToHub(hub: hub, data: data)
        //self.WriteData(HubId: HubId, data: data)
        
    }
    
    public func HubProperties_Upstream(hub: Hub, ReceivedData: [UInt8]){//01
        if(ReceivedData[4]==0x06){//Update
            switch ReceivedData[3]{
            case 0x01:
                print("Advertising Name: \(ReceivedData)")
            case 0x02:
                print("State: \(ReceivedData[5])")
                if(ReceivedData[5]==1){
                    //BLEHub[HubId].Button=true
                    hub.Button = true
                }else{
                    hub.Button = false
                    //BLEHub[HubId].Button=false
                }
            case 0x03:
                print("FW Version")
            case 0x04:
                print("HW Version")
            case 0x05:
                print("RSSI: \(UInt8toInt(value: ReceivedData[5]))")
                //BLEHub[HubId].RSSI =  UInt8toInt(value: ReceivedData[5])
                hub.RSSI = UInt8toInt(value: ReceivedData[5])
            case 0x06:
                print("Battery Voltage: \(Int(ReceivedData[5]))")
                //BLEHub[HubId].BatteryVoltage =  Int(ReceivedData[5])
                hub.BatteryVoltage = Int(ReceivedData[5])
            case 0x07:
                print("Battery Type")
            case 0x08:
                print("Manufacturer Name")
            case 0x09:
                print("Radio Firmware Version")
            case 0x0A:
                print("Lego Wireless Protocol Version")
            case 0x0B:
                print("System Type ID")
            case 0x0C:
                print("H/W Network ID")
            case 0x0D:
                print("Primary MAC Adderss")
            case 0x0E:
                print("Secondary MAC Address")
            case 0x0F:
                print("Hardware Network Family")
            default:
                print("Unknown Property:", ReceivedData[3] )
            }
        }else{
            print("Error: HubPropertiesUpstream")
        }
    }
}
