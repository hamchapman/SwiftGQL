//
//  Types.swift
//  SwiftGraphQL
//
//  Created by Hamilton Chapman on 18/08/2015.
//
//

import Foundation

















enum GraphQLType {
    case GraphQLScalarType
    case GraphQLObjectType
    case GraphQLInterfaceType
    case GraphQLUnionType
    case GraphQLEnumType
    case GraphQLInputObjectType
    case GraphQLList
    case GraphQLNonNull
}

//func isType(type: AnyObject) -> Bool {
//    type is
//}