//
//  File.swift
//  
//
//  Created by Ahmed Farrakha on 12/4/20.
//

import Foundation
import GraphQL
import NIO

struct AddSubscriptionFieldExecutionStrategy: SubscriptionFieldExecutionStrategy {
    
    public init () {}

    public func executeFields(
        exeContext: ExecutionContext,
        parentType: GraphQLObjectType,
        sourceValue: Any,
        path: GraphQL.IndexPath,
        fields: [String: [GraphQL.Field]]
    ) throws -> Future<[String: Any]> {
        var results = [String: Future<Any>]()

        fields.forEach { field in
            results[field.key] = exeContext.eventLoopGroup.next().makeSucceededFuture(true).map { $0 ?? Map.null }
        }

        var elements: [String: Any] = [:]

        let eventLoopGroup = exeContext.eventLoopGroup

        guard results.count > 0 else {
            return eventLoopGroup.next().makeSucceededFuture(elements)
        }

        let promise: EventLoopPromise<[String: Any]> = eventLoopGroup.next().makePromise()
        elements.reserveCapacity(results.count)

        for (key, value) in results {
            value.whenSuccess { expectation in
                elements[key] = expectation
                
                if elements.count == results.count {
                    promise.succeed(elements)
                }
            }
            
            value.whenFailure { error in
                promise.fail(error)
            }
        }

        return promise.futureResult
    }
}
