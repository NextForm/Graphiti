//
//  Subscription.swift
//
//
//  Created by Ahmed Farrakha on 12/4/20.
//

import Foundation
import GraphQL

public final class Subscription<Resolver, Context>: Component<Resolver, Context> {
    let fields: [FieldComponent<Resolver, Context>]
    
    let isTypeOf: GraphQLIsTypeOf = { source, _, _ in
        return source is Resolver
    }
    
    override func update(typeProvider: SchemaTypeProvider) throws {
        typeProvider.subscription = try GraphQLObjectType(
            name: name,
            description: description,
            fields: fields(typeProvider: typeProvider),
            isTypeOf: isTypeOf
        )
    }

    func fields(typeProvider: TypeProvider) throws -> GraphQLFieldMap {
        var map: GraphQLFieldMap = [:]
        
        for field in fields {
            let (name, field) = try field.field(typeProvider: typeProvider)
            map[name] = field
        }
        
        return map
    }
    
    public init(
        name: String,
        fields: [FieldComponent<Resolver, Context>]
    ) {
        self.fields = fields
        super.init(name: name)
    }
}

public extension Subscription {
    convenience init(
        as name: String = "Subscription",
        @FieldComponentBuilder<Resolver, Context> _ fields: () -> FieldComponent<Resolver, Context>
    ) {
        self.init(name: name, fields: [fields()])
    }
    
    convenience init(
        as name: String = "Subscription",
        @FieldComponentBuilder<Resolver, Context> _ fields: () -> [FieldComponent<Resolver, Context>]
    ) {
        self.init(name: name, fields: fields())
    }
}
