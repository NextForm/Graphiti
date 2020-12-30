import GraphQL
import NIO

public protocol API {
    associatedtype Resolver
    associatedtype ContextType
    var resolver: Resolver { get }
    var schema: Schema<Resolver, ContextType> { get }
}

extension API {
    public func execute(
        request: String,
        context: ContextType,
        on eventLoopGroup: EventLoopGroup,
        variables: [String: Map] = [:],
        operationName: String? = nil,
        addingSubscription: Bool = false
    ) -> EventLoopFuture<GraphQLResult> {
        return schema.execute(
            request: request,
            resolver: resolver,
            context: context,
            eventLoopGroup: eventLoopGroup,
            variables: variables,
            operationName: operationName,
            addingSubscription: addingSubscription
        )
    }
}
