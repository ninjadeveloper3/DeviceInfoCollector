//
//  DICDataManager.swift
//  DeviceInfoCollector
//
//  Created by Ahsan on 21/06/2023.
//

import Foundation
import SwiftUI
import CoreLocation
import NetworkExtension
import Darwin
import MediaPlayer
import AVFoundation
import CoreTelephony
import Contacts
import StoreKit
import AppTrackingTransparency
import AdSupport
import SystemConfiguration.CaptiveNetwork

public class DICDataManager: NSObject, ObservableObject {
    
    var locationManager = DICLocationManager()
    
    public override init() {
        super.init()
        
    }
    
    public func fetchTimeStamp() -> String {
        // Function to ferch current date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let currentTimestamp = dateFormatter.string(from: Date())
        return "\(currentTimestamp)"
    }
    
    public func fetchUIDeviceInfo() -> UIDeviceInfo{
        let device = UIDevice.current
        
        return UIDeviceInfo(name: device.name, version: device.systemVersion, model: device.model, isSimulator: UIDevice.isSimulator, isJailBroken: UIDevice.isJailBroken)
    }
    
    public func fetchDeviceLocale() -> DeviceLocale{
        let currentLocale = Locale.current
        var country = ""
        var lang = ""
        let calendar = Calendar.current.identifier
        let timeZone = TimeZone.current
        let timeZoneOffset = timeZone.secondsFromGMT()
        
        // Convert the offset to hours and minutes
        let offsetHours = timeZoneOffset / 3600
        let offsetMinutes = (timeZoneOffset % 3600) / 60
        
        if #available(iOS 16.0, *) {
            country = currentLocale.language.region?.identifier ?? ""
            lang = currentLocale.language.languageCode?.identifier ?? ""
        } else{
            country = currentLocale.regionCode ?? ""
            lang = currentLocale.languageCode ?? ""
        }
        
        return DeviceLocale(language: lang, country: country, calendar: "\(calendar)", timeOffset: "\(offsetHours) hours \(offsetMinutes) minutes")
    }
    
    public func fetchDeviceLocation() -> DeviceLocation {
        return DeviceLocation(location: "\(locationManager.getCurrentLocation())")
    }
    
    public func fetchDeviceSpecs() -> DeviceSpecifications {
        
        return DeviceSpecifications(themeColor: "\(UITraitCollection.current.userInterfaceStyle.rawValue == 1 ? "Light" : "Dark")", orientation: getCurrentDeviceOrientation())
    }
    
    public func fetchDeviceAccessibility() -> DeviceAccessibility{
        
        return DeviceAccessibility(isGuidedAccessEnabled: UIAccessibility.isGuidedAccessEnabled, isVPNConnected: fetchVPNConnecttion(), isVoiceOver: UIAccessibility.isVoiceOverRunning, isClosedCaptioning: UIAccessibility.isClosedCaptioningEnabled, isDarkerSystemColors: UIAccessibility.isDarkerSystemColorsEnabled, isMicroPhoneEnabled: isSingleMicrophoneEnabled())
    }
    
    func fetchFonts() -> DeviceFonts{
        var fontList = [String]()
        for familyName in UIFont.familyNames {
            print("Font Family: \(familyName)")
            for fontName in UIFont.fontNames(forFamilyName: familyName) {
                print("   \(fontName)")
                fontList.append(fontName)
            }
        }
        return DeviceFonts(availableFonts: fontList)
    }
    
    func fetchSystemInformation() -> DeviceInformation{
        
        var kernelArch = ""
        var kernelName = ""
        var kernelVer = ""
        
        if let kernelArchitecture = getKernelArchitecture() {
            kernelArch = kernelArchitecture
        } else {
            kernelArch = "N/A"
        }
        
        if let name = getKernelName() {
            kernelName = name
        } else{
            kernelName = "N/A"
        }
        
        if let archVer = getKernelVersion() {
            kernelVer = archVer
        } else {
            kernelVer = "N/A"
        }
        
        return DeviceInformation(kernelName: kernelName, kernelVer: kernelVer, cpuInfo: "\(ProcessInfo.processInfo.activeProcessorCount)", kernelArch: kernelArch, BootTime: fetchBootTime(), internelStorage: fetchDiskStorage(), RAM: fetchDeviceRAM())
        
    }
    
    func fetchScreenInfo() -> DeviceScreenInformation{
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let screenResolution = "\(UIScreen.main.nativeBounds.width) x \(UIScreen.main.nativeBounds.height)"
        
        return DeviceScreenInformation(width: screenWidth, height: screenHeight, resoulution: screenResolution)
    }
    
    func fetchDeviceAvailability() -> DeviceAvailbility{
        
        return DeviceAvailbility(iCloudAvailable: checkiCloudAvailable(), VoIPStatus: checkVoIPStatus(), inAppPurchaseAllowed: SKPaymentQueue.canMakePayments())
        
    }
    
    func fetchDeviceIdentifiers() -> DeviceIdentifiers {
        
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? ""
        var idfa = ""
        requestIDFA { String in
            idfa = String
        }
        
        
        return DeviceIdentifiers(idfv: idfv, idfa: idfa, randomKeyChain: generateRandomKey())
    }
    
    func fetchDeviceNetworkInfo() -> DeviceNetworkInformatoin {
        
        var wifiName = ""
        var ip = ""
        
        if let ipAddress = getIPAddress() {
            ip = "\(ipAddress)"
        } else {
            ip = "Unable to retrieve IP address."
        }
        
        getNetworkInfo { (wifiInfo) in
            wifiName = wifiInfo["SSID"] as? String ?? ""
        }
        
        return DeviceNetworkInformatoin(ssid: wifiName, ip: ip, carrierName: fetchCarrierName())
    }

    func fetchKeyboards() -> DeviceKeyboards{
        var result = [""]
        if let installedKeyboard = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] {
           result = installedKeyboard
        }
        return DeviceKeyboards(installedKeyboards: result)
    }
    
    
    func requestIDFA(completion: @escaping (String) -> Void){
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // User granted permission, IDFA is available
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    completion("\(idfa)")
                case .denied:
                    // User denied permission
                    completion("User denied permission to track IDFA.")
                case .restricted, .notDetermined:
                    // Tracking permission is restricted or not determined
                    completion("Tracking permission is restricted or not determined.")
                @unknown default:
                    break
                }
            }
        } else {
            completion("N/A")
        }
    }
    
    func generateRandomKey() -> String{
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            let keyManager = DICKeyManager(keychainService: bundleIdentifier, keychainAccount: "encryptionKey")
            return "\(keyManager.generateAndStoreKey())"
        } else {
            return "N/A"
        }
    }
    
    func isSingleMicrophoneEnabled() -> Bool{
        let audioSession = AVAudioSession.sharedInstance()
        guard let currentInput = audioSession.currentRoute.inputs.first else {
            return false
        }
        
        if currentInput.portType == "MicrophoneBuiltIn" {
            return true
        } else {
            return false
        }
    }
    
    func checkiCloudAvailable() -> Bool{
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            print(currentToken)
            return true
        } else {
            return false
        }
    }
    
    func checkVoIPStatus() -> Bool{
        let cellularData = CTCellularData()
        let status = cellularData.restrictedState
        
        switch status {
        case .restricted:
            // VoIP is not allowed
            return false
        case .notRestricted:
            // VoIP is allowed
            return true
        case .restrictedStateUnknown:
            // Unable to determine VoIP restriction state
            return false
        @unknown default:
            return false
        }
    }
    
    func fetchBootTime() -> String{
        if let lastBootTime = getLastBootTime() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .medium
            let formattedLastBootTime = dateFormatter.string(from: lastBootTime)
            return formattedLastBootTime
        } else {
            return "N/A"
        }
    }
    
    func fetchVPNConnecttion() -> Bool{
        
        if let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? Dictionary<String, Any>,
           let scopes = settings["__SCOPED__"] as? [String:Any] {
            for (key, _) in scopes {
                if key.contains("tap") || key.contains("tun") || key.contains("ppp") || key.contains("ipsec") {
                    return true
                }
            }
        }
        return false
    }
    
    func fetchDiskStorage() -> String{
        var availInternal = ""
        var totalInternal = ""
        if let diskSpace = getDiskSpace() {
            let formattedTotalSpace = ByteCountFormatter.string(fromByteCount: Int64(diskSpace.total), countStyle: .file)
            let formattedFreeSpace = ByteCountFormatter.string(fromByteCount: Int64(diskSpace.free), countStyle: .file)
            availInternal = formattedFreeSpace
            totalInternal = formattedTotalSpace
        } else {
            return "N/A"
        }
        
        return "\(availInternal) / \(totalInternal)"
    }
    
    func fetchDeviceRAM() -> String{
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let physicalMemoryInGB = Double(physicalMemory) / 1024 / 1024 / 1024
        
        return String(format: "%.2f", physicalMemoryInGB)
    }
    
    func fetchCarrierName() -> String{
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value {
            return "\(carrier.carrierName ?? "Nil")"
        } else{
            return "N/A"
        }
    }
    
}


extension DICDataManager{
    
    func getCurrentDeviceOrientation() -> String {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return "Unknown"
        }
        
        let orientation = windowScene.interfaceOrientation
        
        switch orientation {
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "Portrait Upside Down"
        case .landscapeLeft:
            return "Landscape Left"
        case .landscapeRight:
            return "Landscape Right"
        default:
            return "Unknown"
        }
    }
    
    func getDiskSpace() -> (total: UInt64, free: UInt64)? {
        let fileManager = FileManager.default
        do {
            let systemAttributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let totalSpace = systemAttributes[.systemSize] as? NSNumber,
               let freeSpace = systemAttributes[.systemFreeSize] as? NSNumber {
                return (totalSpace.uint64Value, freeSpace.uint64Value)
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
    
    func getKernelArchitecture() -> String? {
        var size: size_t = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        
        let architecture = String(cString: machine)
        return architecture
    }
    
    func getKernelName() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.sysname)
        let kernelName = machineMirror.children.reduce("") { (result, element) in
            guard let value = element.value as? Int8, value != 0 else { return result }
            return result + String(UnicodeScalar(UInt8(value)))
        }
        
        return kernelName
    }
    
    func getKernelVersion() -> String? {
        var systemInfo = utsname()
        if uname(&systemInfo) == 0 {
            let version = withUnsafeBytes(of: &systemInfo.release) { pointer in
                Array(pointer.prefix(while: { $0 != 0 }).map { CChar(bitPattern: $0) }) + [CChar(0)]
            }
            let kernelVersion = String(cString: version)
            return kernelVersion
        }
        return nil
    }
    
    func getLastBootTime() -> Date? {
        var bootTime = timeval()
        var bootTimeSize = MemoryLayout<timeval>.size
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        
        guard sysctl(&mib, u_int(mib.count), &bootTime, &bootTimeSize, nil, 0) == 0 else {
            return nil
        }
        
        let bootTimeInSeconds = TimeInterval(bootTime.tv_sec)
        return Date(timeIntervalSince1970: bootTimeInSeconds)
    }
    
    func getContactNames(completion: @escaping (DeviceContacts) -> Void) {
        var contactNames: [String] = []
        
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        DispatchQueue.global(qos: .background).async {
            do {
                try contactStore.enumerateContacts(with: request) { contact, _ in
                    let fullName = "\(contact.givenName) \(contact.familyName)"
                    if let phone = contact.phoneNumbers.first?.value.stringValue {
                        contactNames.append("\(fullName): \(phone)")
                    } else {
                        contactNames.append(fullName)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(DeviceContacts(contacts: contactNames))
                }
            } catch {
                print("Error fetching contacts: \(error)")
                DispatchQueue.main.async {
                    return
                }
            }
        }
    }
    
    
    func getNetworkInfo(compleationHandler: @escaping ([String: Any])->Void){
        
        var currentWirelessInfo: [String: Any] = [:]
        
        if #available(iOS 14.0, *) {
            
            NEHotspotNetwork.fetchCurrent { network in
                
                guard let network = network else {
                    compleationHandler([:])
                    return
                }
                
                let bssid = network.bssid
                let ssid = network.ssid
                currentWirelessInfo = ["BSSID ": bssid, "SSID": ssid, "SSIDDATA": "<54656e64 615f3443 38354430>"]
                compleationHandler(currentWirelessInfo)
            }
        }
        else {
#if !TARGET_IPHONE_SIMULATOR
            guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
                compleationHandler([:])
                return
            }
            
            guard let name = interfaceNames.first, let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String: Any] else {
                compleationHandler([:])
                return
            }
            
            currentWirelessInfo = info
            
#else
            currentWirelessInfo = ["BSSID ": "c8:3a:35:4c:85:d0", "SSID": "Tenda_4C85D0", "SSIDDATA": "<54656e64 615f3443 38354430>"]
#endif
            compleationHandler(currentWirelessInfo)
        }
    }
    
    // Retrieve IP address
    func getIPAddress() -> String? {
        var address: String?
        
        // Get list of network interfaces
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                
                // Filter for IPv4 or IPv6 interface
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: (interface?.ifa_name)!)
                    
                    // Filter for Wi-Fi interface
                    if name == "en0" {
                        var addr = interface?.ifa_addr.pointee
                        
                        // Get IP address string
                        var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NUMERICHOST) == 0 {
                            address = String(cString: hostBuffer)
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
}

extension UIDevice {
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    static var isJailBroken: Bool {
        get {
            if UIDevice.isSimulator { return false }
            if DICJailBrokenHelper.hasCydiaInstalled() { return true }
            if DICJailBrokenHelper.isContainsSuspiciousApps() { return true }
            if DICJailBrokenHelper.isSuspiciousSystemPathsExists() { return true }
            return DICJailBrokenHelper.canEditSystemFiles()
        }
    }
}



