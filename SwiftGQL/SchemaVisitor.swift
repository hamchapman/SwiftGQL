//export var SchemaKeys = {
//    Name: QueryDocumentKeys.Name,
//    
//    SchemaDocument: [ 'definitions' ],
//    TypeDefinition: [ 'name', 'interfaces', 'fields' ],
//    FieldDefinition: [ 'name', 'arguments', 'type' ],
//    InputValueDefinition: [ 'name', 'type', 'defaultValue' ],
//    InterfaceDefinition: [ 'name', 'fields' ],
//    UnionDefinition: [ 'name', 'types' ],
//    ScalarDefinition: [ 'name' ],
//    EnumDefinition: [ 'name', 'values' ],
//    EnumValueDefinition: [ 'name' ],
//    InputObjectDefinition: [ 'name', 'fields' ],
//    
//    IntValue: QueryDocumentKeys.IntValue,
//    FloatValue: QueryDocumentKeys.FloatValue,
//    StringValue: QueryDocumentKeys.StringValue,
//    BooleanValue: QueryDocumentKeys.BooleanValue,
//    EnumValue: QueryDocumentKeys.EnumValue,
//    ListValue: QueryDocumentKeys.ListValue,
//    ObjectValue: QueryDocumentKeys.ObjectValue,
//    ObjectField: QueryDocumentKeys.ObjectField,
//    
//    NamedType: QueryDocumentKeys.NamedType,
//    ListType: QueryDocumentKeys.ListType,
//    NonNullType: QueryDocumentKeys.NonNullType,
//};
//
//export function visitSchema(root, visitor, keys) {
//    return visit(root, visitor, keys || SchemaKeys);
//}
