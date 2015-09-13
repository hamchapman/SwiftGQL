// **AST**

/**
* Contains a range of UTF-8 character offsets that identify
* the region of the source from which the AST derived.
*/
struct Location {
    let start: Int
    let end: Int
    let source: Source?
}

/**
* The list of all possible AST node types.
*/
enum NodeList {
    case _Name(value: Name)
    case _Document(value: Document)
    case _OperationDefinition(value: OperationDefinition)
    case _VariableDefinition(value: VariableDefinition)
    case _Variable(value: Variable)
    case _SelectionSet(value: SelectionSet)
    case _Field(value: Field)
    case _Argument(value: Argument)
    case _FragmentSpread(value: FragmentSpread)
    case _InlineFragment(value: InlineFragment)
    case _FragmentDefinition(value: FragmentDefinition)
    case _IntValue(value: IntValue)
    case _FloatValue(value: FloatValue)
    case _StringValue(value: StringValue)
    case _BooleanValue(value: BooleanValue)
    case _EnumValue(value: EnumValue)
    case _ListValue(value: ListValue)
    case _ObjectValue(value: ObjectValue)
    case _ObjectField(value: ObjectField)
    case _Directive(value: Directive)
    case _ListType(value: ListType)
    case _NonNullType(value: NonNullType)
}

// Name

struct Name {
    let kind = "Name"
    let value: String
    let loc: Location?
}

// Document

struct Document {
    let kind = "Document"
    let definitions: [Definition]
    let loc: Location?
}

enum Definition {
    case _OperationDefinition(def: OperationDefinition)
    case _FragmentDefinition(def: FragmentDefinition)
}

struct OperationDefinition {
    // TODO: Cleanup
    //    operation: 'query' | 'mutation';
    let kind = "OperationDefinition"
    let operation: String
    let name: Name?
    let variableDefinitions: [VariableDefinition]?
    let directives: [Directive]?
    let selectionSet: SelectionSet
    let loc: Location?
}

struct VariableDefinition {
    let kind = "VariableDefinition"
    let variable: Value
    let type: Type
    let defaultValue: Value?
    let loc: Location?
}

struct Variable {
    let kind = "Variable"
    let name: Name
    let loc: Location?
}

struct SelectionSet {
    let kind = "SelectionSet"
    let selections: [Selection]
    let loc: Location?
}

enum Selection {
    case _Field(val: Field)
    case _FragmentSpread(val: FragmentSpread)
    case _InlineFragment(val: InlineFragment)
}

enum Fragment {
    case _FragmentSpread(val: FragmentSpread)
    case _InlineFragment(val: InlineFragment)
}

struct Field {
    let kind = "Field"
    let alias: Name?
    let name: Name
    let arguments: [Argument]?
    let directives: [Directive]?
    let selectionSet: SelectionSet?
    let loc: Location?
}

struct Argument {
    let kind = "Argument"
    let name: Name
    let value: Value
    let loc: Location?
}


// Fragments

struct FragmentSpread {
    let kind = "FragmentSpread"
    let name: Name
    let directives: [Directive]?
    let loc: Location?
}

struct InlineFragment {
    let kind = "InlineFragment"
    let typeCondition: Type
    let directives: [Directive]?
    let selectionSet: SelectionSet
    let loc: Location?
}

struct FragmentDefinition {
    let kind = "FragmentDefinition"
    let name: Name
    let typeCondition: Type
    let directives: [Directive]?
    let selectionSet: SelectionSet
    let loc: Location?
}


// Values

enum Value {
    case _Variable(val: Variable)
    case _IntValue(val: IntValue)
    case _FloatValue(val: FloatValue)
    case _StringValue(val: StringValue)
    case _BooleanValue(val: BooleanValue)
    case _EnumValue(val: EnumValue)
    case _ListValue(val: ListValue)
    case _ObjectValue(val: ObjectValue)
}

struct IntValue {
    let kind = "IntValue"
    let value: String
    let loc: Location?
}

struct FloatValue {
    let kind = "FloatValue"
    let value: String
    let loc: Location?
}

struct StringValue {
    let kind = "StringValue"
    let value: String
    let loc: Location?
}

struct BooleanValue {
    let kind = "BooleanValue"
    let value: Bool
    let loc: Location?
}

struct EnumValue {
    let kind = "EnumValue"
    let value: String
    let loc: Location?
}

struct ListValue {
    let kind = "ListValue"
    let values: [Value]
    let loc: Location?
}

struct ObjectValue {
    let kind = "ObjectValue"
    let fields: [ObjectField]
    let loc: Location?
}

struct ObjectField {
    let kind = "ObjectField"
    let name: Name
    let value: Value
    let loc: Location?
}


// Directives

struct Directive {
    let kind = "Directive"
    let name: Name
    let arguments: [Argument]?
    let loc: Location?
}


// Types

enum Type {
    case _NamedType(type: NamedType)
    case _ListType(type: ListType)
    case _NonNullType(type: NonNullType)
}

enum NullableType {
    case _NamedType(type: NamedType)
    case _ListType(type: ListType)
}

struct NamedType {
    let kind = "NamedType"
    let name: Name
    let loc: Location?
}

struct ListType {
    let kind = "ListType"
    let type: Type
    let loc: Location?
}

struct NonNullType {
    let kind = "NonNullType"
    let type: Type
    let loc: Location?
}


// 

struct SchemaDocument {
    let kind = "SchemaDocument"
    let loc: Location?
    let definitions: [SchemaDefinition]
}

enum SchemaDefinition {
    case _ObjectTypeDef(definition: ObjectTypeDefinition)
    case _InterfaceDef(definition: InterfaceDefinition)
    case _UnionDef(definition: UnionDefinition)
    case _ScalarDef(definition: ScalarDefinition)
    case _EnumDef(definition: EnumDefinition)
    case _InputObjectDef(definition: InputObjectDefinition)
    case _TypeExtensionDef(definition: TypeExtensionDefinition)
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

struct ObjectTypeDefinition {
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

struct TypeExtensionDefinition {
    let kind = "TypeExtensionDefinition"
    let loc: Location?
    // TODO: I want this to be ObjectTypeDefinition, as that's what it really is
    // Just need to figure out how to type all these things
    let definition: SchemaDefinition
}
