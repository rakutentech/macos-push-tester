import Foundation

struct ErrorState: Equatable {
    var error: NSError
    var actionType: ActionType
}
