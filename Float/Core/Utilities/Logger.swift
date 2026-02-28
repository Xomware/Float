import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.xomware.float"
    
    static let auth = Logger(subsystem: subsystem, category: "Auth")
    static let map = Logger(subsystem: subsystem, category: "Map")
    static let deals = Logger(subsystem: subsystem, category: "Deals")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let location = Logger(subsystem: subsystem, category: "Location")
}
