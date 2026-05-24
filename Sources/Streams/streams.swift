import Vapor
import FlorShopDTOs

func streams(_ app: Application) {
    let billingProvider = FlorShopBillingProvider()
    Task {
        let billingStream = BillingStreamHandler(
            streamName: ValkeyStream.billing,
            groupName: "core-service",
            consumerName: "core-1",
            app: app,
            billingProvider: billingProvider
        )
        let billingListener = billingStream.getListener()
        await billingListener.start(on: app, handler: billingStream.handler)
    }
    Task {
        let authStream = AuthStreamHandler(
            streamName: ValkeyStream.auth,
            groupName: "core-service",
            consumerName: "core-1",
            app: app
        )
        let authListener = authStream.getListener()
        await authListener.start(on: app, handler: authStream.handler)
    }
}
