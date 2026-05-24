import FlorShopDTOs
import FlorShopValkey

protocol StreamHandler {
    var streamName: ValkeyStream { get }
    var groupName: String { get }
    var consumerName: String { get }
    func getListener() -> StreamListener
    func handler(fields: [String: String]) async -> Bool
}

extension StreamHandler {
    func getListener() -> StreamListener {
        return StreamListener(streamName: streamName, groupName: groupName, consumerName: consumerName)
    }
}
