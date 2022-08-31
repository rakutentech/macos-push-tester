import Foundation

enum DefaultPayloads {
    static let apns = """
{
    "aps":{
        "alert":"Test",
        "sound":"default",
        "badge":1
    }
}
"""
    static let fcmV1 = """
{
    "message":{
        "notification":{
            "title":"Firebase Cloud Message Title",
            "body":"Firebase Cloud Message Body",
            "subtitle":"Firebase Cloud Message Subtitle"
        }
    }
}
"""
    static let fcmLegacy = """
{
    "notification": {
        "body":"Firebase Cloud Message Body",
        "title":"Firebase Cloud Message Title",
        "subtitle":"Firebase Cloud Message Subtitle"
    }
}

"""
}
