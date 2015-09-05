//
//  Language-Schema.swift
//  SwiftGQL
//
//  Created by Hamilton Chapman on 31/08/2015.
//  Copyright © 2015 hc.gg. All rights reserved.
//

import Foundation

// **Kinds**

let SCHEMA_DOCUMENT = "SchemaDocument"
let TYPE_DEFINITION = "TypeDefinition"
let FIELD_DEFINITION = "FieldDefinition"
let INPUT_VALUE_DEFINITION = "InputValueDefinition"
let INTERFACE_DEFINITION = "InterfaceDefinition"
let UNION_DEFINITION = "UnionDefinition"
let SCALAR_DEFINITION = "ScalarDefinition"
let ENUM_DEFINITION = "EnumDefinition"
let ENUM_VALUE_DEFINITION = "EnumValueDefinition"
let INPUT_OBJECT_DEFINITION = "InputObjectDefinition"


// **AST**

struct SchemaDocument {
    let kind = "SchemaDocument"
    let loc: Location?
    let definitions: [SchemaDefinition]
}

enum SchemaDefinition {
    case TypeDef(definition: TypeDefinition)
    case InterfaceDef(definition: InterfaceDefinition)
    case UnionDef(definition: UnionDefinition)
    case ScalarDef(definition: ScalarDefinition)
    case EnumDef(definition: EnumDefinition)
    case InputObjectDef(definition: InputObjectDefinition)
}

struct FieldDefinition {
    let kind = "FieldDefinition"
    let loc: Location?
    let name: Name
    let arguments: [InputValueDefinition]
    let type: Type
}

struct InputValueDefinition {
    let kind = "InputValueDefinition"
    let loc: Location?
    let name: Name
    let type: Type
    let defaultValue: Value?
}

struct EnumValueDefinition {
    let kind = "EnumValueDefinition"
    let loc: Location?
    let name: Name
}

struct TypeDefinition {
    let kind = "TypeDefinition"
    let loc: Location?
    let name: Name
    let interfaces: [NamedType]?
    let fields: [FieldDefinition]
}

struct InterfaceDefinition {
    let kind = "InterfaceDefinition"
    let loc: Location?
    let name: Name
    let fields: [FieldDefinition]
}

struct UnionDefinition {
    let kind = "UnionDefinition"
    let loc: Location?
    let name: Name
    let types: [NamedType]
}

struct ScalarDefinition {
    let kind = "ScalarDefinition"
    let loc: Location?
    let name: Name
}

struct EnumDefinition {
    let kind = "EnumDefinition"
    let loc: Location?
    let name: Name
    let values: [EnumValueDefinition]
}

struct InputObjectDefinition {
    let kind = "InputObjectDefinition"
    let loc: Location?
    let name: Name
    let fields: [InputValueDefinition]
}


// **Parser**

func parseSchemaIntoAST(source: Source, options: ParseOptions?) -> SchemaDocument {
    let parser = makeParser(source, options: options)
    return parseSchemaDocument(parser)
}

func parseSchemaIntoAST(source: String, options: ParseOptions?) -> SchemaDocument {
    let sourceObj = Source(body: source, name: nil)
    let parser = makeParser(sourceObj, options: options)
    return parseSchemaDocument(parser)
}

/**
* SchemaDocument : SchemaDefinition+
*/
func parseSchemaDocument(parser: Parser) -> SchemaDocument {
    let start = parser.token.start
    var definitions: [SchemaDefinition] = []
    repeat {
        definitions.append(parseSchemaDefinition(parser))
    } while !skip(parser, kind: getTokenKindDesc(TokenKind.EOF.rawValue))
    
    return SchemaDocument(loc: loc(parser, start: start), definitions: definitions)
}

/**
* SchemaDefinition :
*   - TypeDefinition
*   - InterfaceDefinition
*   - UnionDefinition
*   - ScalarDefinition
*   - EnumDefinition
*   - InputObjectDefinition
*/
func parseSchemaDefinition(parser: Parser) -> SchemaDefinition {
    if !peek(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue)) {
 //       throw unexpected(parser)
    }
    switch parser.token.value! {
    case "type":
        return parseTypeDefinition(parser)
    case "interface":
        return parseInterfaceDefinition(parser)
    case "union":
        return parseUnionDefinition(parser)
    case "scalar":
        return parseScalarDefinition(parser)
    case "enum":
    return parseEnumDefinition(parser)
    case "input":
        return parseInputObjectDefinition(parser)
    default:
        throw unexpected(parser)
    }
}

/**
* TypeDefinition : TypeName ImplementsInterfaces? { FieldDefinition+ }
*
* TypeName : Name
*/
func parseTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "type")
    let name = parseName(parser)
    let interfaces = parseImplementsInterfaces(parser)
    let fields = any(parser, openKind: TokenKind.BRACE_L.rawValue, parseFn: parseFieldDefinition, closeKind: TokenKind.BRACE_R.rawValue)
    return SchemaDefinition.TypeDef(definition: TypeDefinition(loc: loc(parser, start: start), name: name, interfaces: interfaces, fields: fields))
}

/**
* ImplementsInterfaces : `implements` NamedType+
*/
func parseImplementsInterfaces(parser: Parser) -> [NamedType] {
    var types: [NamedType] = []
    if parser.token.value == "implements" {
        advance(parser)
        repeat {
            types.append(parseNamedType(parser))
        } while !peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue))
    }
    return types
}

/**
* FieldDefinition : FieldName ArgumentsDefinition? : Type
*
* FieldName : Name
*/
func parseFieldDefinition(parser: Parser) -> FieldDefinition {
    let start = parser.token.start
    let name = parseName(parser)
    let args = parseArgumentDefs(parser)
    expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue))
    let type = parseType(parser)
    return FieldDefinition(loc: loc(parser, start: start), name: name, arguments: args, type: type)
}

/**
* ArgumentsDefinition : ( InputValueDefinition+ )
*/
func parseArgumentDefs(parser: Parser) -> [InputValueDefinition] {
    if !peek(parser, kind: getTokenKindDesc(TokenKind.PAREN_L.rawValue)) {
        return []
    }
    return many(parser, openKind: TokenKind.PAREN_L.rawValue, parseFn: parseInputValueDef, closeKind: TokenKind.PAREN_R.rawValue)
}

/**
* InputValueDefinition : Name : Value[Const] DefaultValue?
*
* DefaultValue : = Value[Const]
*/
func parseInputValueDef(parser: Parser) -> InputValueDefinition {
    let start = parser.token.start
    let name = parseName(parser)
    expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue))
    // TODO: Why is there an extra false in call here?
//    var type = parseType(parser, false)
    let type = parseType(parser)
    var defaultValue: Value? = nil
    if skip(parser, kind: getTokenKindDesc(TokenKind.EQUALS.rawValue)) {
        defaultValue = parseConstValue(parser)
    }
    return InputValueDefinition(loc: loc(parser, start: start), name: name, type: type, defaultValue: defaultValue)
}

/**
* InterfaceDefinition : `interface` TypeName { Fields+ }
*/
func parseInterfaceDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "interface")
    let name = parseName(parser)
    let fields = any(parser, openKind: TokenKind.BRACE_L.rawValue, parseFn: parseFieldDefinition, closeKind: TokenKind.BRACE_R.rawValue)
    return SchemaDefinition.InterfaceDef(definition: InterfaceDefinition(loc: loc(parser, start: start), name: name, fields: fields))
}

/**
* UnionDefinition : `union` TypeName = UnionMembers
*/
func parseUnionDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "union")
    let name = parseName(parser)
    expect(parser, kind: getTokenKindDesc(TokenKind.EQUALS.rawValue))
    let types = parseUnionMembers(parser)
    return SchemaDefinition.UnionDef(definition: UnionDefinition(loc: loc(parser, start: start), name: name, types: types))
}

/**
* UnionMembers :
*   - NamedType
*   - UnionMembers | NamedType
*/
func parseUnionMembers(parser: Parser) -> [NamedType] {
    var members: [NamedType] = []
    repeat {
        members.append(parseNamedType(parser))
    } while skip(parser, kind: getTokenKindDesc(TokenKind.PIPE.rawValue))
    return members
}

/**
* ScalarDefinition : `scalar` TypeName
*/
func parseScalarDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "scalar")
    let name = parseName(parser)
    return SchemaDefinition.ScalarDef(definition: ScalarDefinition(loc: loc(parser, start: start), name: name))
}

/**
* EnumDefinition : `enum` TypeName { EnumValueDefinition+ }
*/
func parseEnumDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "enum")
    let name = parseName(parser)
    let values = many(parser, openKind: TokenKind.BRACE_L.rawValue, parseFn: parseEnumValueDefinition, closeKind: TokenKind.BRACE_R.rawValue)
    return SchemaDefinition.EnumDef(definition: EnumDefinition(loc: loc(parser, start: start), name: name, values: values))
}

/**
* EnumValueDefinition : EnumValue
*
* EnumValue : Name
*/
func parseEnumValueDefinition(parser: Parser) -> EnumValueDefinition {
    let start = parser.token.start
    let name = parseName(parser)
    return EnumValueDefinition(loc: loc(parser, start: start), name: name)
}

/**
* InputObjectDefinition : `input` TypeName { InputValueDefinition+ }
*/
func parseInputObjectDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "input")
    let name = parseName(parser)
    let fields = any(parser, openKind: TokenKind.BRACE_L.rawValue, parseFn: parseInputValueDef, closeKind: TokenKind.BRACE_R.rawValue)
    return SchemaDefinition.InputObjectDef(definition: InputObjectDefinition(loc: loc(parser, start: start), name: name, fields: fields))
}




