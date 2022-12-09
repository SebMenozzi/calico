import Foundation
import Platform_macOS

public class Console {

    public enum Level: Int {
        case debug = 0
        case info  = 1
        case warn  = 2
        case error = 3
        
        public var str: String { get {
            switch self {
            case .debug:
                return "Debug"
            case .info:
                return "Info"
            case .warn:
                return "Warning"
            case .error:
                return "Error"
            }
        }}
    }

    public struct Message {

        public var timestamp: String = "00:00:00.000"
        public var level: Level = .info
        public var content: String = ""
        
        public var str: String { get {
            "[\(timestamp)] \(level.str) - \(content)"
        }}
    }
    
    private static let maxMessageCount: Int = 1000
    private static var messages: [Message?] = [Message?](
        repeating: nil, 
        count: maxMessageCount
    )
    private static var start: Int = 0
    private static var end: Int = 0
    public private(set) static var numMessages: Int  = 0
    
    public static func getMessageList() -> [Message?] {
        return messages
    }
    
    private static var outputCursor: Int = start
    
    public static func nextMessage() -> Message? {
        guard outputCursor != end else {  // including the case where numMessages == 0
            outputCursor = start // reset
            return nil
        }
        
        let msg = messages[outputCursor]
        outputCursor = (outputCursor + 1) % maxMessageCount
        return msg
    }
    
    public static func clear() {
        numMessages = 0
        start = 0
        end = 0
        outputCursor = start

        for index in messages.indices {
            messages[index] = nil
        }
    }
    
    @inline(__always)
    public static func debug(_ msg: String) {
        addMessage(msg, level: .debug)
    }

    @inline(__always)
    public static func info(_ msg: String) {
        addMessage(msg, level: .info)
    }
    
    @inline(__always)
    public static func warn(_ msg: String) {
        addMessage(msg, level: .warn)
    }
    
    @inline(__always)
    public static func error(_ msg: String) {
        addMessage(msg, level: .error)
    }
    
    private static func addMessage(_ msg: String, level: Level) {
        let dateFormatter = DateFormatter()..{
            $0.dateFormat = "hh:mm:ss.SSS"
        }
        
        let message = Message()..{
            $0.timestamp = dateFormatter.string(from: Date())
            $0.level = level
            $0.content = msg
        }
       
        messages[end] = message
        numMessages = min(numMessages + 1, maxMessageCount)
        
        end = (end + 1) % maxMessageCount
        
        // Update start when end overlaps
        if start == end {
            start = (start + 1) % maxMessageCount
        }
    }
}
