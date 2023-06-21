//
//  DICModels.swift
//  DeviceInfoCollector
//
//  Created by Ahsan on 21/06/2023.
//

struct DeviceName {
    let name: String
}

struct TimeStamp {
    let dateTime: String
}

struct ColorTheme {
    let themeName: String
}

struct DeviceCountry {
    let countryName: String
}

struct OSVersion {
    let version: String
}

struct DeviceLangauge {
    let lang: String
}

struct DeviceLocation {
    let location: String
}

struct DeviceOrientation {
    let orientation: String
}

struct DeviceStorage {
    let internalStorage: String
    let externalStorage: String
}

struct DeviceFonts {
    let availableFonts: [String]
}

struct DeviceTimeZone {
    let timeZone: String
}

struct DeviceModel {
    let model: String
}

struct GuidedAccess {
    let guidedAccess: String
}

struct DeviceKeyboards {
    let installedKeyboards: [String]
}

struct DeviceVPN{
    let vpnConnection: String
}

struct kernelArch {
    let arch: String
}

struct KernelName {
    let archName: String
}

struct kernelVersion {
    let archVersion: String
}

struct CPUInfo {
    let cpuCount: String
}

struct DeviceScreen {
    let screeninfo: String
}

struct DeviceBootTime {
    let bootTime: String
}

struct CheckDevice {
    let isSimulator: String
    let isjailBroken: String
}

struct DeviceRAM {
    let ram: String
}

struct DeviceMicroPhone {
    let monoAudioEnabled: String
}

struct DeviceCarrierName {
    let serviceProvider: String
}

struct DeviceVoiceOver {
    let voiceOverEnabled: String
    let captionEnabled: String
    let systemColorEnabled: String
}

struct DeviceContacts {
    let contacts: [String]
}

struct DeviceInAppPurchase {
    let purchaseAllowed: String
}

struct IDFA {
    let identifier: String
}

struct IDFV {
    let identifier: String
}

struct DeviceSecureKey {
    let key: String
}

struct DeviceNetworkInformation {
    let ssid: String
    let ip: String
}

struct DeviceiCloud {
    let token: String
}

struct CalendarType {
    let name: String
}

struct DeviceVoIP {
    let status: String
}

