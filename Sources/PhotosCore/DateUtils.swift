import Foundation

public enum DateParseError: Error, CustomStringConvertible {
    case invalidFormat(String)

    public var description: String {
        switch self {
        case .invalidFormat(let value):
            return "Invalid date '\(value)'. Expected format: YYYY-MM-DD"
        }
    }
}

public func parseDate(_ string: String) throws -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current

    guard let date = formatter.date(from: string) else {
        throw DateParseError.invalidFormat(string)
    }
    return date
}

public func endOfDay(_ date: Date) -> Date {
    var calendar = Calendar.current
    calendar.timeZone = .current
    var components = calendar.dateComponents([.year, .month, .day], from: date)
    components.hour = 23
    components.minute = 59
    components.second = 59
    return calendar.date(from: components) ?? date
}
