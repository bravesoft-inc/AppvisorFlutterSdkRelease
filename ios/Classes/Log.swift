private var printLogs: Bool {
    UserDefaults.standard.bool(forKey: "enableLogs")
}
public func log(_ className:String, _ message:String, line: Int = #line){
    if printLogs {
        NSLog("AppvisorFlutterSDKSwift:[\(className):\(line)] \(message)")
    }
}
