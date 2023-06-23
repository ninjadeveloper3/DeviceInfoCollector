//
//  DICModels.swift
//  DeviceInfoCollector
//
//  Created by Ahsan on 21/06/2023.
//

public struct TimeStamp {
    let dateTime: String
}

public struct UIDeviceInfo {
    let name: String
    let version: String
    let model: String
    let isSimulator: Bool
    let isJailBroken: Bool
}

public struct DeviceLocale {
    let language: String
    let country: String
    let calendar: String
    let timeOffset: String
}

public struct DeviceSpecifications {
    let themeColor: String
    let orientation: String
}

public struct DeviceAccessibility {
    let isGuidedAccessEnabled: Bool
    let isVPNConnected: Bool
    let isVoiceOver: Bool
    let isClosedCaptioning: Bool
    let isDarkerSystemColors: Bool
    let isMicroPhoneEnabled: Bool
}

public struct DeviceInformation {
    let kernelName: String
    let kernelVer: String
    let cpuInfo: String
    let kernelArch: String
    let BootTime: String
    let internelStorage: String
    let RAM: String
}

public struct DeviceScreenInformation {
    let width: Double
    let height: Double
    let resoulution: String
}

public struct DeviceAvailbility {
    let iCloudAvailable: Bool
    let VoIPStatus: Bool
    let inAppPurchaseAllowed: Bool
    
}

public struct DeviceIdentifiers {
    let idfv: String
    let idfa: String
    let randomKeyChain: String
}

public struct DeviceNetworkInformatoin {
    let ssid: String
    let ip: String
    let carrierName: String
}

public struct DeviceKeyboards {
    let installedKeyboards: [String]
}

public struct DeviceLocation {
    let location: String
}

public struct DeviceFonts {
    let availableFonts: [String]
}

struct DeviceContacts {
    let contacts: [String]
}
