//// **AST**
//
//struct SchemaDocument {
//    let kind = "SchemaDocument"
//    let loc: Location?
//    let definitions: [SchemaDefinition]
//}
//
//enum SchemaDefinition {
//    case TypeDef(definition: TypeDefinition)
//    case InterfaceDef(definition: InterfaceDefinition)
//    case UnionDef(definition: UnionDefinition)
//    case ScalarDef(definition: ScalarDefinition)
//    case EnumDef(definition: EnumDefinition)
//    case InputObjectDef(definition: InputObjectDefinition)
//    case _TypeExtensionDef(definition: TypeExtensionDefinition)
//}
//
//struct FieldDefinition {
//    let kind = "FieldDefinition"
//    let loc: Location?
//    let name: Name
//    let arguments: [InputValueDefinition]
//    let type: Type
//}
//
//struct InputValueDefinition {
//    let kind = "InputValueDefinition"
//    let loc: Location?
//    let name: Name
//    let type: Type
//    let defaultValue: Value?
//}
//
//struct EnumValueDefinition {
//    let kind = "EnumValueDefinition"
//    let loc: Location?
//    let name: Name
//}
//
//struct TypeDefinition {
//    let kind = "TypeDefinition"
//    let loc: Location?
//    let name: Name
//    let interfaces: [NamedType]?
//    let fields: [FieldDefinition]
//}
//
//struct InterfaceDefinition {
//    let kind = "InterfaceDefinition"
//    let loc: Location?
//    let name: Name
//    let fields: [FieldDefinition]
//}
//
//struct UnionDefinition {
//    let kind = "UnionDefinition"
//    let loc: Location?
//    let name: Name
//    let types: [NamedType]
//}
//
//struct ScalarDefinition {
//    let kind = "ScalarDefinition"
//    let loc: Location?
//    let name: Name
//}
//
//struct EnumDefinition {
//    let kind = "EnumDefinition"
//    let loc: Location?
//    let name: Name
//    let values: [EnumValueDefinition]
//}
//
//struct InputObjectDefinition {
//    let kind = "InputObjectDefinition"
//    let loc: Location?
//    let name: Name
//    let fields: [InputValueDefinition]
//}
//
//struct TypeExtensionDefinition {
//    let kind = "TypeExtensionDefinition"
//    let loc: Location?
//    let defintion: Definition
//}
