//function parse(source, options) {
//    var sourceObj = source instanceof _source.Source ? source : new _source.Source(source);
//    var parser = makeParser(sourceObj, options || {});
//    return parseDocument(parser);
//}
/**
* Given a GraphQL source, parses it into a Document.
* Throws GraphQLError if a syntax error is encountered.
*/
func parse(source: Source, options: ParseOptions?) -> Document {
    let parser = makeParser(source, options: options)
    return parseDocument(parser)
}

func parse(source: String, options: ParseOptions?) -> Document {
    let sourceObj = Source(body: source, name: nil)
    let parser = makeParser(sourceObj, options: options)
    return parseDocument(parser)
}

/**
* Given a string containing a GraphQL value, parse the AST for that value.
* Throws GraphQLError if a syntax error is encountered.
*
* This is useful within tools that operate upon GraphQL Values directly and
* in isolation of complete GraphQL documents.
*/
//function parseValue(source, options) {
//    var sourceObj = source instanceof _source.Source ? source : new _source.Source(source);
//    var parser = makeParser(sourceObj, options || {});
//    return parseValueLiteral(parser);
//}
func parseValue(source: Source, options: ParseOptions?) -> Value {
    let parser = makeParser(source, options: options)
    // TODO: Check if return isConst here as false makes sense
    // I think it'll just be undefined in JS and so is falsey
    return parseValueLiteral(parser, isConst: false)
}

func parseValue(source: String, options: ParseOptions?) -> Value {
    let sourceObj = Source(body: source, name: nil)
    let parser = makeParser(sourceObj, options: options)
    // TODO: Check if return isConst here as false makes sense
    // I think it'll just be undefined in JS and so is falsey
    return parseValueLiteral(parser, isConst: false)
}

/**
* Converts a name lex token into a name parse node.
*/
//function parseName(parser) {
//    var token = expect(parser, _lexer.TokenKind.NAME);
//    return {
//        kind: _kinds.NAME,
//        value: token.value,
//        loc: loc(parser, token.start)
//    };
//}
func parseName(parser: Parser) -> Name {
    // TODO: Fix this
    // (later comment: not sure why it needs to be fixed)
    let token = expect(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue))
    return Name(value: token.value!, loc: loc(parser, start: token.start))
}

// Implements the parsing rules in the Document section.

/**
* Document : Definition+
*/
//function parseDocument(parser) {
//    var start = parser.token.start;
//    
//    var definitions = [];
//    do {
//        definitions.push(parseDefinition(parser));
//    } while (!skip(parser, _lexer.TokenKind.EOF));
//    
//    return {
//        kind: _kinds.DOCUMENT,
//        definitions: definitions,
//        loc: loc(parser, start)
//    };
//}
// TODO: Sort out redeclaration (this one is the new unified version)
func parseDocument(parser: Parser) -> Document {
    let start = parser.token.start

    var definitions: [Definition] = []
    repeat {
        definitions.append(parseDefinition(parser))
    } while !skip(parser, kind: getTokenKindDesc(TokenKind.EOF.rawValue))

    return Document(definitions: definitions, loc: loc(parser, start: start))
}
//func parseDocument(parser: Parser) -> Document {
//    let start = parser.token.start
//    var definitions: [Definition]
//    repeat {
//        if peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue)) {
//            definitions.append(parseOperationDefinition(parser))
//        } else if peek(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue)) {
//            if parser.token.value == "query" || parser.token.value == "mutation" {
//                definitions.append(parseOperationDefinition(parser))
//            } else if parser.token.value == "fragment" {
//                definitions.append(parseFragmentDefinition(parser))
//            } else {
//                throw unexpected(parser)
//            }
//        } else {
//            throw unexpected(parser)
//        }
//    } while !skip(parser, kind: getTokenKindDesc(TokenKind.EOF.rawValue))
//    return Document(definitions: definitions, loc: loc(parser, start: start))
//}


// TODO: Probably make peek (and maybe expect, skip etc) all use kind as an Int rather than the stupid kind description string
/**
* Definition :
*   - OperationDefinition
*   - FragmentDefinition
*   - TypeDefinition
*/
func parseDefinition(parser: Parser) -> Definition {
    if peek(parser, getTokenKindDesc(TokenKind.BRACE_L.rawValue)) {
        return parseOperationDefinition(parser)
    }
    
    if peek(parser, getTokenKindDesc(TokenKind.NAME.rawValue)) {
        switch parser.token.value! {
        case "query":
        case "mutation":
            // Note: subscription is an experimental non-spec addition.
        case "subscription":
            return parseOperationDefinition(parser)
        case "fragment":
            return parseFragmentDefinition(parser)
            
        case "type":
        case "interface":
        case "union":
        case "scalar":
        case "enum":
        case "input":
        case "extend":
            return parseTypeDefinition(parser)
        }
    }
    
    throw unexpected(parser)
}

// Implements the parsing rules in the Operations section.

/**
* OperationDefinition :
*  - SelectionSet
*  - OperationType Name VariableDefinitions? Directives? SelectionSet
*
* OperationType : one of query mutation
*/
//function parseOperationDefinition(parser) {
//    var start = parser.token.start;
//    if (peek(parser, _lexer.TokenKind.BRACE_L)) {
//        return {
//            kind: _kinds.OPERATION_DEFINITION,
//            operation: 'query',
//            name: null,
//            variableDefinitions: null,
//            directives: [],
//            selectionSet: parseSelectionSet(parser),
//            loc: loc(parser, start)
//        };
//    }
//    var operationToken = expect(parser, _lexer.TokenKind.NAME);
//    var operation = operationToken.value;
//    return {
//        kind: _kinds.OPERATION_DEFINITION,
//        operation: operation,
//        name: parseName(parser),
//        variableDefinitions: parseVariableDefinitions(parser),
//        directives: parseDirectives(parser),
//        selectionSet: parseSelectionSet(parser),
//        loc: loc(parser, start)
//    };
//}
func parseOperationDefinition(parser: Parser) -> Definition {
    let start = parser.token.start
    if peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue)) {
        return Definition._OperationDefinition(
            def: OperationDefinition(
                operation: "query",
                name: nil,
                variableDefinitions: nil,
                directives: [],
                selectionSet: parseSelectionSet(parser),
                loc: loc(parser, start: start)
            )
        )
    }
    let operationToken = expect(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue))
    let operation = operationToken.value
    return Definition._OperationDefinition(
        def: OperationDefinition(
            operation: operation!,
            name: parseName(parser),
            variableDefinitions: parseVariableDefinitions(parser),
            directives: parseDirectives(parser),
            selectionSet: parseSelectionSet(parser),
            loc: loc(parser, start: start)
        )
    )
}


/**
* VariableDefinitions : ( VariableDefinition+ )
*/
//function parseVariableDefinitions(parser) {
//    return peek(parser, _lexer.TokenKind.PAREN_L) ? many(parser, _lexer.TokenKind.PAREN_L, parseVariableDefinition, _lexer.TokenKind.PAREN_R) : [];
//}
func parseVariableDefinitions(parser: Parser) -> [VariableDefinition] {
    return peek(parser, kind: getTokenKindDesc(TokenKind.PAREN_L.rawValue)) ?
        many(
            parser,
            openKind: TokenKind.PAREN_L.rawValue,
            parseFn: parseVariableDefinition,
            closeKind: TokenKind.PAREN_R.rawValue
        ) :
        []
}

/**
* VariableDefinition : Variable : Type DefaultValue?
*/
//function parseVariableDefinition(parser) {
//    var start = parser.token.start;
//    return {
//        kind: _kinds.VARIABLE_DEFINITION,
//        variable: parseVariable(parser),
//        type: (expect(parser, _lexer.TokenKind.COLON), parseType(parser)),
//        defaultValue: skip(parser, _lexer.TokenKind.EQUALS) ? parseValueLiteral(parser, true) : null,
//        loc: loc(parser, start)
//    };
//}

func parseVariableDefinition(parser: Parser) -> VariableDefinition {
    let start = parser.token.start
    let defaultValue: Value? = skip(parser, kind: getTokenKindDesc(TokenKind.EQUALS.rawValue)) ? parseValueLiteral(parser, isConst: true) : nil
    // TODO: Blog about this shit - it's THE shit
    // TODO: Blog about the whole thing: JS -> Swift, pretty sick
    return VariableDefinition(
        variable: parseVariable(parser),
        type: (expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)), parseType(parser)).1,
        defaultValue: defaultValue,
        loc: loc(parser, start: start)
    )
}

/**
* Variable : $ Name
*/
//function parseVariable(parser) {
//    var start = parser.token.start;
//    expect(parser, _lexer.TokenKind.DOLLAR);
//    return {
//        kind: _kinds.VARIABLE,
//        name: parseName(parser),
//        loc: loc(parser, start)
//    };
//}
func parseVariable(parser: Parser) -> Value {
    let start = parser.token.start;
    expect(parser, kind: getTokenKindDesc(TokenKind.DOLLAR.rawValue))
    return Value._Variable(val: Variable(name: parseName(parser), loc: loc(parser, start: start)))
}

/**
* SelectionSet : { Selection+ }
*/
//function parseSelectionSet(parser) {
//    var start = parser.token.start;
//    return {
//        kind: _kinds.SELECTION_SET,
//        selections: many(parser, _lexer.TokenKind.BRACE_L, parseSelection, _lexer.TokenKind.BRACE_R),
//        loc: loc(parser, start)
//    };
//}
func parseSelectionSet(parser: Parser) -> SelectionSet {
    let start = parser.token.start
    return SelectionSet(
        selections: many(
            parser,
            openKind: TokenKind.BRACE_L.rawValue,
            parseFn: parseSelection,
            closeKind: TokenKind.BRACE_R.rawValue
        ),
        loc: loc(parser, start: start)
    )
}

/**
* Selection :
*   - Field
*   - FragmentSpread
*   - InlineFragment
*/
//function parseSelection(parser) {
//    return peek(parser, _lexer.TokenKind.SPREAD) ? parseFragment(parser) : parseField(parser);
//}
func parseSelection(parser: Parser) -> Selection {
    return peek(parser, kind: getTokenKindDesc(TokenKind.SPREAD.rawValue)) ?
        parseFragment(parser) :
        parseField(parser)
}

/**
* Field : Alias? Name Arguments? Directives? SelectionSet?
*
* Alias : Name :
*/
/**
* Corresponds to both Field and Alias in the spec
*/
//function parseField(parser) {
//    var start = parser.token.start;
//    
//    var nameOrAlias = parseName(parser);
//    var alias;
//    var name;
//    if (skip(parser, _lexer.TokenKind.COLON)) {
//        alias = nameOrAlias;
//        name = parseName(parser);
//    } else {
//        alias = null;
//        name = nameOrAlias;
//    }
//    
//    return {
//        kind: _kinds.FIELD,
//        alias: alias,
//        name: name,
//        arguments: parseArguments(parser),
//        directives: parseDirectives(parser),
//        selectionSet: peek(parser, _lexer.TokenKind.BRACE_L) ? parseSelectionSet(parser) : null,
//        loc: loc(parser, start)
//    };
//}
func parseField(parser: Parser) -> Selection {
    let start = parser.token.start
    
    let nameOrAlias = parseName(parser)
    var alias: Name?
    var name: Name
    if skip(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)) {
        alias = nameOrAlias
        name = parseName(parser)
    } else {
        alias = nil
        name = nameOrAlias
    }
    
    let selectionSet: SelectionSet? = peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue)) ? parseSelectionSet(parser) : nil
    
    return Selection._Field(val:
        Field(
            alias: alias,
            name: name,
            arguments: parseArguments(parser),
            directives: parseDirectives(parser),
            selectionSet: selectionSet,
            loc: loc(parser, start: start)
        )
    )
}

/**
* Arguments : ( Argument+ )
*/
//function parseArguments(parser) {
//    return peek(parser, _lexer.TokenKind.PAREN_L) ? many(parser, _lexer.TokenKind.PAREN_L, parseArgument, _lexer.TokenKind.PAREN_R) : [];
//}
func parseArguments(parser: Parser) -> [Argument] {
    return peek(parser, kind: getTokenKindDesc(TokenKind.PAREN_L.rawValue)) ?
        many(
            parser,
            openKind: TokenKind.PAREN_L.rawValue,
            parseFn: parseArgument,
            closeKind: TokenKind.PAREN_R.rawValue
        ) :
        []
}

/**
* Argument : Name : Value
*/
//function parseArgument(parser) {
//    var start = parser.token.start;
//    return {
//        kind: _kinds.ARGUMENT,
//        name: parseName(parser),
//        value: (expect(parser, _lexer.TokenKind.COLON), parseValueLiteral(parser, false)),
//        loc: loc(parser, start)
//    };
//}
func parseArgument(parser: Parser) -> Argument {
    let start = parser.token.start
    // TODO: See below
    // Investigate in graphql-test
    // Seems to just run the expect function but then return the parseValueLiteral function return value
    return Argument(
        name: parseName(parser),
        value: (expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)), parseValueLiteral(parser, isConst: false)).1,
        loc: loc(parser, start: start)
    )
}

// Implements the parsing rules in the Fragments section.

/**
* Corresponds to both FragmentSpread and InlineFragment in the spec.
*
* FragmentSpread : ... FragmentName Directives?
*
* InlineFragment : ... on TypeCondition Directives? SelectionSet
*/
//function parseFragment(parser) {
//    var start = parser.token.start;
//    expect(parser, _lexer.TokenKind.SPREAD);
//    if (parser.token.value === 'on') {
//        advance(parser);
//        return {
//            kind: _kinds.INLINE_FRAGMENT,
//            typeCondition: parseNamedType(parser),
//            directives: parseDirectives(parser),
//            selectionSet: parseSelectionSet(parser),
//            loc: loc(parser, start)
//        };
//    }
//    return {
//        kind: _kinds.FRAGMENT_SPREAD,
//        name: parseFragmentName(parser),
//        directives: parseDirectives(parser),
//        loc: loc(parser, start)
//    };
//}
func parseFragment(parser: Parser) -> Selection {
    let start = parser.token.start
    expect(parser, kind: getTokenKindDesc(TokenKind.SPREAD.rawValue))
    if parser.token.value == "on" {
        advance(parser)
        return Selection._InlineFragment(val:
            InlineFragment(
                typeCondition: parseNamedType(parser),
                directives: parseDirectives(parser),
                selectionSet: parseSelectionSet(parser),
                loc: loc(parser, start: start)
            )
        )
    }
    return Selection._FragmentSpread(val:
        FragmentSpread(
            name: parseFragmentName(parser),
            directives: parseDirectives(parser),
            loc: loc(parser, start: start)
        )
    )
}

/**
* FragmentDefinition :
*   - fragment FragmentName on TypeCondition Directives? SelectionSet
*
* TypeCondition : NamedType
*/
//function parseFragmentDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'fragment');
//    return {
//        kind: _kinds.FRAGMENT_DEFINITION,
//        name: parseFragmentName(parser),
//        typeCondition: (expectKeyword(parser, 'on'), parseNamedType(parser)),
//        directives: parseDirectives(parser),
//        selectionSet: parseSelectionSet(parser),
//        loc: loc(parser, start)
//    };
//}
func parseFragmentDefinition(parser: Parser) -> Definition {
    let start = parser.token.start
    expectKeyword(parser, value: "fragment")
    return Definition._FragmentDefinition(def:
        FragmentDefinition(
            name: parseFragmentName(parser),
            typeCondition: (expectKeyword(parser, value: "on"), parseNamedType(parser)).1,
            directives: parseDirectives(parser),
            selectionSet: parseSelectionSet(parser),
            loc: loc(parser, start: start)
        )
    )
}


/**
* FragmentName : Name but not `on`
*/
//function parseFragmentName(parser) {
//    if (parser.token.value === 'on') {
//        throw unexpected(parser);
//    }
//    return parseName(parser);
//}
func parseFragmentName(parser: Parser) -> Name {
    if parser.token.value == "on" {
        throw unexpected(parser)
    }
    return parseName(parser)
}

// Implements the parsing rules in the Values section.

/**
* Value[Const] :
*   - [~Const] Variable
*   - IntValue
*   - FloatValue
*   - StringValue
*   - BooleanValue
*   - EnumValue
*   - ListValue[?Const]
*   - ObjectValue[?Const]
*
* BooleanValue : one of `true` `false`
*
* EnumValue : Name but not `true`, `false` or `null`
*/
//function parseValueLiteral(parser, isConst) {
//    var token = parser.token;
//    switch (token.kind) {
//    case _lexer.TokenKind.BRACKET_L:
//        return parseList(parser, isConst);
//    case _lexer.TokenKind.BRACE_L:
//        return parseObject(parser, isConst);
//    case _lexer.TokenKind.INT:
//        advance(parser);
//        return {
//            kind: _kinds.INT,
//            value: token.value,
//            loc: loc(parser, token.start)
//        };
//    case _lexer.TokenKind.FLOAT:
//        advance(parser);
//        return {
//            kind: _kinds.FLOAT,
//            value: token.value,
//            loc: loc(parser, token.start)
//        };
//    case _lexer.TokenKind.STRING:
//        advance(parser);
//        return {
//            kind: _kinds.STRING,
//            value: token.value,
//            loc: loc(parser, token.start)
//        };
//    case _lexer.TokenKind.NAME:
//        if (token.value === 'true' || token.value === 'false') {
//            advance(parser);
//            return {
//                kind: _kinds.BOOLEAN,
//                value: token.value === 'true',
//                loc: loc(parser, token.start)
//            };
//        } else if (token.value !== 'null') {
//            advance(parser);
//            return {
//                kind: _kinds.ENUM,
//                value: token.value,
//                loc: loc(parser, token.start)
//            };
//        }
//        break;
//    case _lexer.TokenKind.DOLLAR:
//        if (!isConst) {
//            return parseVariable(parser);
//        }
//        break;
//    }
//    throw unexpected(parser);
//}
func parseValueLiteral(parser: Parser, isConst: Bool) -> Value {
    let token = parser.token
    switch token.kind {
    case TokenKind.BRACKET_L.rawValue:
        return parseList(parser, isConst: isConst)
    case TokenKind.BRACE_L.rawValue:
        return parseObject(parser, isConst: isConst)
    case TokenKind.INT.rawValue:
        advance(parser)
        return Value._IntValue(val: IntValue(value: token.value!, loc: loc(parser, start: token.start)))
    case TokenKind.FLOAT.rawValue:
        advance(parser)
        return Value._FloatValue(val: FloatValue(value: token.value!, loc: loc(parser, start: token.start)))
    case TokenKind.STRING.rawValue:
        advance(parser)
        return Value._StringValue(val: StringValue(value: token.value!, loc: loc(parser, start: token.start)))
    case TokenKind.NAME.rawValue:
        if token.value == "true" || token.value == "false" {
            advance(parser)
            return Value._BooleanValue(val: BooleanValue(value: token.value! == "true", loc: loc(parser, start: token.start)))
        } else if token.value != "null" {
            advance(parser)
            return Value._EnumValue(val: EnumValue(value: token.value!, loc: loc(parser, start: token.start)))
        }
        break
    case TokenKind.DOLLAR.rawValue:
        if !isConst {
            return parseVariable(parser)
        }
        break
    }
    throw unexpected(parser)
}


//function parseConstValue(parser) {
//    return parseValueLiteral(parser, true);
//}
func parseConstValue(parser: Parser) -> Value {
    return parseValueLiteral(parser, isConst: true)
}

//function parseValueValue(parser) {
//    return parseValueLiteral(parser, false);
//}
func parseValueValue(parser: Parser) -> Value {
    return parseValueLiteral(parser, isConst: false)
}

/**
* ListValue[Const] :
*   - [ ]
*   - [ Value[?Const]+ ]
*/
//function parseList(parser, isConst) {
//    var start = parser.token.start;
//    var item = isConst ? parseConstValue : parseValueValue;
//    return {
//        kind: _kinds.LIST,
//        values: any(parser, _lexer.TokenKind.BRACKET_L, item, _lexer.TokenKind.BRACKET_R),
//        loc: loc(parser, start)
//    };
//}
func parseList(parser: Parser, isConst: Bool) -> Value {
    let start = parser.token.start
    let item = isConst ? parseConstValue : parseValueValue
    return Value._ListValue(val:
        ListValue(
            values: any(
                parser,
                openKind: TokenKind.BRACKET_L.rawValue,
                parseFn: item,
                closeKind: TokenKind.BRACKET_R.rawValue
            ),
            loc: loc(parser, start: start)
        )
    )
}

/**
* ObjectValue[Const] :
*   - { }
*   - { ObjectField[?Const]+ }
*/
//function parseObject(parser, isConst) {
//    var start = parser.token.start;
//    expect(parser, _lexer.TokenKind.BRACE_L);
//    var fieldNames = {};
//    var fields = [];
//    while (!skip(parser, _lexer.TokenKind.BRACE_R)) {
//        fields.push(parseObjectField(parser, isConst, fieldNames));
//    }
//    return {
//        kind: _kinds.OBJECT,
//        fields: fields,
//        loc: loc(parser, start)
//    };
//}
func parseObject(parser: Parser, isConst: Bool) -> Value {
    let start = parser.token.start
    expect(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue))
    var fieldNames: [String:Bool] = [:]
    var fields: [ObjectField] = []
    while !skip(parser, kind: getTokenKindDesc(TokenKind.BRACE_R.rawValue)) {
        fields.append(parseObjectField(parser, isConst: isConst, fieldNames: fieldNames))
    }
    return Value._ObjectValue(val:
        ObjectValue(
            fields: fields,
            loc: loc(parser, start: start)
        )
    )
}

/**
* ObjectField[Const] : Name : Value[?Const]
*/
//function parseObjectField(parser, isConst, fieldNames) {
//    var start = parser.token.start;
//    var name = parseName(parser);
//    if (fieldNames.hasOwnProperty(name.value)) {
//        throw (0, _error.syntaxError)(parser.source, start, 'Duplicate input object field ' + name.value + '.');
//    }
//    fieldNames[name.value] = true;
//    return {
//        kind: _kinds.OBJECT_FIELD,
//        name: name,
//        value: (expect(parser, _lexer.TokenKind.COLON), parseValueLiteral(parser, isConst)),
//        loc: loc(parser, start)
//    };
//}
func parseObjectField(parser: Parser, isConst: Bool, var fieldNames: [String:Bool]) -> ObjectField {
    let start = parser.token.start
    let name = parseName(parser)
    if let val = fieldNames[name.value] {
        throw syntaxError(
            parser.source,
            start,
            "Duplicate input object field \(name.value)."
        )
    }
    fieldNames[name.value] = true
    return ObjectField(
        name: name,
        value: (expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)), parseValueLiteral(parser, isConst: isConst)).1,
        loc: loc(parser, start: start)
    )
}

// Implements the parsing rules in the Directives section.

/**
* Directives : Directive+
*/
//function parseDirectives(parser) {
//    var directives = [];
//    while (peek(parser, _lexer.TokenKind.AT)) {
//        directives.push(parseDirective(parser));
//    }
//    return directives;
//}
func parseDirectives(parser: Parser) -> [Directive] {
    var directives: [Directive]
    while peek(parser, kind: getTokenKindDesc(TokenKind.AT.rawValue)) {
        directives.append(parseDirective(parser))
    }
    return directives
}

/**
* Directive : @ Name Arguments?
*/
//function parseDirective(parser) {
//    var start = parser.token.start;
//    expect(parser, _lexer.TokenKind.AT);
//    return {
//        kind: _kinds.DIRECTIVE,
//        name: parseName(parser),
//        arguments: parseArguments(parser),
//        loc: loc(parser, start)
//    };
//}
func parseDirective(parser: Parser) -> Directive {
    let start = parser.token.start
    expect(parser, kind: getTokenKindDesc(TokenKind.AT.rawValue))
    return Directive(
        name: parseName(parser),
        arguments: parseArguments(parser),
        loc: loc(parser, start: start)
    )
}

// Implements the parsing rules in the Types section.

/**
* Type :
*   - NamedType
*   - ListType
*   - NonNullType
*/

//function parseType(parser) {
//    var start = parser.token.start;
//    var type;
//    if (skip(parser, _lexer.TokenKind.BRACKET_L)) {
//        type = parseType(parser);
//        expect(parser, _lexer.TokenKind.BRACKET_R);
//        type = {
//            kind: _kinds.LIST_TYPE,
//            type: type,
//            loc: loc(parser, start)
//        };
//    } else {
//        type = parseNamedType(parser);
//    }
//    if (skip(parser, _lexer.TokenKind.BANG)) {
//        return {
//            kind: _kinds.NON_NULL_TYPE,
//            type: type,
//            loc: loc(parser, start)
//        };
//    }
//    return type;
//}
func parseType(parser: Parser) -> Type {
    let start = parser.token.start
    var type: Type
    if skip(parser, kind: getTokenKindDesc(TokenKind.BRACKET_L.rawValue)) {
        type = parseType(parser)
        expect(parser, kind: getTokenKindDesc(TokenKind.BRACKET_R.rawValue))
        type = Type._ListType(type: ListType(type: type, loc: loc(parser, start: start)))
    } else {
        type = parseNamedType(parser)
    }
    if skip(parser, kind: getTokenKindDesc(TokenKind.BANG.rawValue)) {
        return Type._NonNullType(
            type: NonNullType(
                type: type,
                loc: loc(parser, start: start)
            )
        )
    }
    return type
}

/**
* NamedType : Name
*/
//function parseNamedType(parser) {
//    var start = parser.token.start;
//    return {
//        kind: _kinds.NAMED_TYPE,
//        name: parseName(parser),
//        loc: loc(parser, start)
//    };
//}
// TODO: Make this nicer, I hate returning Type when really it's always going to be a NamedType
// This appears with NonNullType and a few other places as well. It's gross, and is basically
// abusing static typing, but it makes it easier to work with
func parseNamedType(parser: Parser) -> Type {
    let start = parser.token.start
    return Type._NamedType(
        type: NamedType(
            name: parseName(parser),
            loc: loc(parser, start: start)
        )
    )
}

// Implements the parsing rules in the Type Definition section.

/**
* TypeDefinition :
*   - ObjectTypeDefinition
*   - InterfaceTypeDefinition
*   - UnionTypeDefinition
*   - ScalarTypeDefinition
*   - EnumTypeDefinition
*   - InputObjectTypeDefinition
*   - TypeExtensionDefinition
*/
//function parseTypeDefinition(parser) {
//    if (!peek(parser, _lexer.TokenKind.NAME)) {
//        throw unexpected(parser);
//    }
//    switch (parser.token.value) {
//    case 'type':
//        return parseObjectTypeDefinition(parser);
//    case 'interface':
//        return parseInterfaceTypeDefinition(parser);
//    case 'union':
//        return parseUnionTypeDefinition(parser);
//    case 'scalar':
//        return parseScalarTypeDefinition(parser);
//    case 'enum':
//    return parseEnumTypeDefinition(parser);
//    case 'input':
//        return parseInputObjectTypeDefinition(parser);
//    case 'extend':
//        return parseTypeExtensionDefinition(parser);
//    default:
//        throw unexpected(parser);
//    }
//}
// TODO: Check the return type here
func parseTypeDefinition(parser: Parser) -> SchemaDefinition {
    if !peek(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue)) {
       throw unexpected(parser)
    }
    switch parser.token.value! {
    case "type":
        return parseObjectTypeDefinition(parser)
    case "interface":
        return parseInterfaceTypeDefinition(parser)
    case "union":
        return parseUnionTypeDefinition(parser)
    case "scalar":
        return parseScalarTypeDefinition(parser)
    case "enum":
        return parseEnumTypeDefinition(parser)
    case "input":
        return parseInputObjectTypeDefinition(parser)
    case "extend":
        return parseTypeExtensionDefinition(parser)
    default:
        throw unexpected(parser)
    }
}


/**
* ObjectTypeDefinition : type Name ImplementsInterfaces? { FieldDefinition+ }
*/
//function parseObjectTypeDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'type');
//    var name = parseName(parser);
//    var interfaces = parseImplementsInterfaces(parser);
//    var fields = any(parser, _lexer.TokenKind.BRACE_L, parseFieldDefinition, _lexer.TokenKind.BRACE_R);
//    return {
//        kind: _kinds.OBJECT_TYPE_DEFINITION,
//        name: name,
//        interfaces: interfaces,
//        fields: fields,
//        loc: loc(parser, start)
//    };
//}
// TODO: Again, check return type, and for all others mentioned in parseTypeDefinition fn
// Probably change name of enum to be something more like TypeDefinition
func parseObjectTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "type")
    let name = parseName(parser)
    let interfaces = parseImplementsInterfaces(parser)
    let fields = any(
        parser,
        openKind: TokenKind.BRACE_L.rawValue,
        parseFn: parseFieldDefinition,
        closeKind: TokenKind.BRACE_R.rawValue
    )
    return SchemaDefinition._ObjectTypeDef(
        definition: ObjectTypeDefinition(
            loc: loc(parser, start: start),
            name: name,
            interfaces: interfaces,
            fields: fields
        )
    )
}

/**
* ImplementsInterfaces : implements NamedType+
*/
//function parseImplementsInterfaces(parser) {
//    var types = [];
//    if (parser.token.value === 'implements') {
//        advance(parser);
//        do {
//            types.push(parseNamedType(parser));
//        } while (!peek(parser, _lexer.TokenKind.BRACE_L));
//    }
//    return types;
//}
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
* FieldDefinition : Name ArgumentsDefinition? : Type
*/
//function parseFieldDefinition(parser) {
//    var start = parser.token.start;
//    var name = parseName(parser);
//    var args = parseArgumentDefs(parser);
//    expect(parser, _lexer.TokenKind.COLON);
//    var type = parseType(parser);
//    return {
//        kind: _kinds.FIELD_DEFINITION,
//        name: name,
//        arguments: args,
//        type: type,
//        loc: loc(parser, start)
//    };
//}
func parseFieldDefinition(parser: Parser) -> FieldDefinition {
    let start = parser.token.start
    let name = parseName(parser)
    let args = parseArgumentDefs(parser)
    expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue))
    let type = parseType(parser)
    return FieldDefinition(
        loc: loc(parser, start: start),
        name: name,
        arguments: args,
        type: type
    )
}

/**
* ArgumentsDefinition : ( InputValueDefinition+ )
*/
//function parseArgumentDefs(parser) {
//    if (!peek(parser, _lexer.TokenKind.PAREN_L)) {
//        return [];
//    }
//    return many(parser, _lexer.TokenKind.PAREN_L, parseInputValueDef, _lexer.TokenKind.PAREN_R);
//}
func parseArgumentDefs(parser: Parser) -> [InputValueDefinition] {
    if !peek(parser, kind: getTokenKindDesc(TokenKind.PAREN_L.rawValue)) {
        return []
    }
    return many(
        parser,
        openKind: TokenKind.PAREN_L.rawValue,
        parseFn: parseInputValueDef,
        closeKind: TokenKind.PAREN_R.rawValue
    )
}

/**
* InputValueDefinition : Name : Type DefaultValue?
*/
//function parseInputValueDef(parser) {
//    var start = parser.token.start;
//    var name = parseName(parser);
//    expect(parser, _lexer.TokenKind.COLON);
//    var type = parseType(parser, false);
//    var defaultValue = null;
//    if (skip(parser, _lexer.TokenKind.EQUALS)) {
//        defaultValue = parseConstValue(parser);
//    }
//    return {
//        kind: _kinds.INPUT_VALUE_DEFINITION,
//        name: name,
//        type: type,
//        defaultValue: defaultValue,
//        loc: loc(parser, start)
//    };
//}
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
    return InputValueDefinition(
        loc: loc(parser, start: start),
        name: name,
        type: type,
        defaultValue: defaultValue
    )
}

/**
* InterfaceTypeDefinition : interface Name { FieldDefinition+ }
*/
//function parseInterfaceTypeDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'interface');
//    var name = parseName(parser);
//    var fields = any(parser, _lexer.TokenKind.BRACE_L, parseFieldDefinition, _lexer.TokenKind.BRACE_R);
//    return {
//        kind: _kinds.INTERFACE_TYPE_DEFINITION,
//        name: name,
//        fields: fields,
//        loc: loc(parser, start)
//    };
//}
func parseInterfaceTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "interface")
    let name = parseName(parser)
    let fields = any(
        parser,
        openKind: TokenKind.BRACE_L.rawValue,
        parseFn: parseFieldDefinition,
        closeKind: TokenKind.BRACE_R.rawValue
    )
    return SchemaDefinition._InterfaceDef(
        definition: InterfaceDefinition(
            loc: loc(parser, start: start),
            name: name,
            fields: fields
        )
    )
}

/**
* UnionTypeDefinition : union Name = UnionMembers
*/
//function parseUnionTypeDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'union');
//    var name = parseName(parser);
//    expect(parser, _lexer.TokenKind.EQUALS);
//    var types = parseUnionMembers(parser);
//    return {
//        kind: _kinds.UNION_TYPE_DEFINITION,
//        name: name,
//        types: types,
//        loc: loc(parser, start)
//    };
//}
func parseUnionTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "union")
    let name = parseName(parser)
    expect(parser, kind: getTokenKindDesc(TokenKind.EQUALS.rawValue))
    let types = parseUnionMembers(parser)
    return SchemaDefinition._UnionDef(
        definition: UnionDefinition(
            loc: loc(parser, start: start),
            name: name,
            types: types
        )
    )
}

/**
* UnionMembers :
*   - NamedType
*   - UnionMembers | NamedType
*/
//function parseUnionMembers(parser) {
//    var members = [];
//    do {
//        members.push(parseNamedType(parser));
//    } while (skip(parser, _lexer.TokenKind.PIPE));
//    return members;
//}
func parseUnionMembers(parser: Parser) -> [NamedType] {
    var members: [NamedType] = []
    repeat {
        members.append(parseNamedType(parser))
    } while skip(parser, kind: getTokenKindDesc(TokenKind.PIPE.rawValue))
    return members
}

/**
* ScalarTypeDefinition : scalar Name
*/
//function parseScalarTypeDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'scalar');
//    var name = parseName(parser);
//    return {
//        kind: _kinds.SCALAR_TYPE_DEFINITION,
//        name: name,
//        loc: loc(parser, start)
//    };
//}
func parseScalarTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "scalar")
    let name = parseName(parser)
    return SchemaDefinition._ScalarDef(
        definition: ScalarDefinition(
            loc: loc(parser, start: start),
            name: name
        )
    )
}

/**
* EnumTypeDefinition : enum Name { EnumValueDefinition+ }
*/
//function parseEnumTypeDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'enum');
//    var name = parseName(parser);
//    var values = many(parser, _lexer.TokenKind.BRACE_L, parseEnumValueDefinition, _lexer.TokenKind.BRACE_R);
//    return {
//        kind: _kinds.ENUM_TYPE_DEFINITION,
//        name: name,
//        values: values,
//        loc: loc(parser, start)
//    };
//}
func parseEnumTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "enum")
    let name = parseName(parser)
    let values = many(
        parser,
        openKind: TokenKind.BRACE_L.rawValue,
        parseFn: parseEnumValueDefinition,
        closeKind: TokenKind.BRACE_R.rawValue
    )
    return SchemaDefinition._EnumDef(
        definition: EnumDefinition(
            loc: loc(parser, start: start),
            name: name,
            values: values
        )
    )
}

/**
* EnumValueDefinition : EnumValue
*
* EnumValue : Name
*/
//function parseEnumValueDefinition(parser) {
//    var start = parser.token.start;
//    var name = parseName(parser);
//    return {
//        kind: _kinds.ENUM_VALUE_DEFINITION,
//        name: name,
//        loc: loc(parser, start)
//    };
//}
func parseEnumValueDefinition(parser: Parser) -> EnumValueDefinition {
    let start = parser.token.start
    let name = parseName(parser)
    return EnumValueDefinition(
        loc: loc(parser, start: start),
        name: name
    )
}

/**
* InputObjectTypeDefinition : input Name { InputValueDefinition+ }
*/
//function parseInputObjectTypeDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'input');
//    var name = parseName(parser);
//    var fields = any(parser, _lexer.TokenKind.BRACE_L, parseInputValueDef, _lexer.TokenKind.BRACE_R);
//    return {
//        kind: _kinds.INPUT_OBJECT_TYPE_DEFINITION,
//        name: name,
//        fields: fields,
//        loc: loc(parser, start)
//    };
//}
func parseInputObjectTypeDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "input")
    let name = parseName(parser)
    let fields = any(
        parser,
        openKind: TokenKind.BRACE_L.rawValue,
        parseFn: parseInputValueDef,
        closeKind: TokenKind.BRACE_R.rawValue
    )
    return SchemaDefinition._InputObjectDef(
        definition: InputObjectDefinition(
            loc: loc(parser, start: start),
            name: name,
            fields: fields
        )
    )
}


/**
* TypeExtensionDefinition : extend ObjectTypeDefinition
*/
//function parseTypeExtensionDefinition(parser) {
//    var start = parser.token.start;
//    expectKeyword(parser, 'extend');
//    var definition = parseObjectTypeDefinition(parser);
//    return {
//        kind: _kinds.TYPE_EXTENTION_DEFINITION,
//        definition: definition,
//        loc: loc(parser, start)
//    };
//}
func parseTypeExtensionDefinition(parser: Parser) -> SchemaDefinition {
    let start = parser.token.start
    expectKeyword(parser, value: "extend")
    let definition = parseObjectTypeDefinition(parser)
    return SchemaDefinition._TypeExtensionDef(
        definition: TypeExtensionDefinition(
            loc: loc(parser, start: start),
            definition: definition
        )
    )
}









// Core parsing utility functions


// TODO: This _maybe_ ain't legit, figure out what I really need
struct Parser {
    let _lexToken: NextTokenFn
    let source: Source
    let options: ParseOptions?
    var prevEnd: Int
    var token: Token
}

/**
* Configuration options to control parser behavior
*/
struct ParseOptions {
    /**
    * By default, the parser creates AST nodes that know the location
    * in the source that they correspond to. This configuration flag
    * disables that behavior for performance or testing.
    */
    let noLocation: Bool?
    
    /**
    * By default, the parser creates AST nodes that contain a reference
    * to the source that they were created from. This configuration flag
    * disables that behavior for performance or testing.
    */
    let noSource: Bool?
}

//function makeParser(source, options) {
//    var _lexToken = (0, _lexer.lex)(source);
//    return {
//        _lexToken: _lexToken,
//        source: source,
//        options: options,
//        prevEnd: 0,
//        token: _lexToken()
//    };
//}
/**
* Returns the parser object that is used to store state throughout the
* process of parsing.
*/
// TODO: Figure out WTF a _lexToken is
func makeParser(source: Source, options: ParseOptions?) -> Parser {
    var _lexToken = lex(source)
    return Parser(_lexToken: _lexToken, source: source, options: options, prevEnd: 0, token: _lexToken(nil))
}


//function loc(parser, start) {
//    if (parser.options.noLocation) {
//        return null;
//    }
//    if (parser.options.noSource) {
//        return { start: start, end: parser.prevEnd };
//    }
//    return { start: start, end: parser.prevEnd, source: parser.source };
//}
/**
* Returns a location object, used to identify the place in
* the source that created a given parsed object.
*/
func loc(parser: Parser, start: Int) -> Location? {
    if let _ = parser.options?.noLocation {
        return nil
    }
    if let _ = parser.options?.noSource {
        return Location(start: start, end: parser.prevEnd, source: nil)
    }
    return Location(start: start, end: parser.prevEnd, source: parser.source)
}

//function advance(parser) {
//    var prevEnd = parser.token.end;
//    parser.prevEnd = prevEnd;
//    parser.token = parser._lexToken(prevEnd);
//}
/**
* Moves the internal parser object to the next lexed token.
*/
func advance(var parser: Parser) {
    let prevEnd = parser.token.end
    parser.prevEnd = prevEnd
    parser.token = parser._lexToken(prevEnd)
}

// TODO: Work out whether to use getTokenKindDesc or getTokenDesc at different points

//function peek(parser, kind) {
//    return parser.token.kind === kind;
//}
/**
* Determines if the next token is of a given kind
*/
func peek(parser: Parser, kind: String) -> Bool {
    return getTokenKindDesc(parser.token.kind) == kind
}

//function skip(parser, kind) {
//    var match = parser.token.kind === kind;
//    if (match) {
//        advance(parser);
//    }
//    return match;
//}
/**
* If the next token is of the given kind, return true after advancing
* the parser. Otherwise, do not change the parser state and return false.
*/
func skip(parser: Parser, kind: String) -> Bool {
    let match = getTokenKindDesc(parser.token.kind) == kind
    if match {
        advance(parser)
    }
    return match
}

//function expect(parser, kind) {
//    var token = parser.token;
//    if (token.kind === kind) {
//        advance(parser);
//        return token;
//    }
//    throw (0, _error.syntaxError)(parser.source, token.start, 'Expected ' + (0, _lexer.getTokenKindDesc)(kind) + ', found ' + (0, _lexer.getTokenDesc)(token));
//}
/**
* If the next token is of the given kind, return that token after advancing
* the parser. Otherwise, do not change the parser state and return false.
*/
func expect(parser: Parser, kind: String) -> Token {
    var token = parser.token
    if (getTokenKindDesc(token.kind) == kind) {
        advance(parser)
        return token
    }
    throw syntaxError(
        parser.source,
        token.start,
        "Expected \(kind), found \(getTokenDesc(token))"
    )
}

//function expectKeyword(parser, value) {
//    var token = parser.token;
//    if (token.kind === _lexer.TokenKind.NAME && token.value === value) {
//        advance(parser);
//        return token;
//    }
//    throw (0, _error.syntaxError)(parser.source, token.start, 'Expected "' + value + '", found ' + (0, _lexer.getTokenDesc)(token));
//}
/**
* If the next token is a keyword with the given value, return that token after
* advancing the parser. Otherwise, do not change the parser state and return
* false.
*/
func expectKeyword(parser: Parser, value: String) -> Token {
    let token = parser.token
    if token.kind == TokenKind.NAME.rawValue && token.value == value {
        advance(parser)
        return token
    }
    throw syntaxError(
        parser.source,
        token.start,
        "Expected \(value), found \(getTokenDesc(token))"
    )
}

//function unexpected(parser, atToken) {
//    var token = atToken || parser.token;
//    return (0, _error.syntaxError)(parser.source, token.start, 'Unexpected ' + (0, _lexer.getTokenDesc)(token));
//}
/**
* Helper export function for creating an error when an unexpected lexed token
* is encountered.
*/
// TODO: BaseError correct?
// TODO: throw vs return?
func unexpected(parser: Parser, atToken: Token?) -> BaseError {
    let token = atToken ?? parser.token
    throw syntaxError(
        parser.source,
        token.start,
        "Unexpected \(getTokenDesc(token))"
    )
}

//function any(parser, openKind, parseFn, closeKind) {
//    expect(parser, openKind);
//    var nodes = [];
//    while (!skip(parser, closeKind)) {
//        nodes.push(parseFn(parser));
//    }
//    return nodes;
//}
/**
* Returns a possibly empty list of parse nodes, determined by
* the parseFn. This list begins with a lex token of openKind
* and ends with a lex token of closeKind. Advances the parser
* to the next lex token after the closing token.
*/
func any<T>(parser: Parser, openKind: Int, parseFn: (parser: Parser) -> T, closeKind: Int) -> [T] {
    expect(parser, kind: getTokenKindDesc(openKind))
    var nodes: [T] = []
    while !skip(parser, kind: getTokenKindDesc(closeKind)) {
        nodes.append(parseFn(parser: parser))
    }
    return nodes
}

//function many(parser, openKind, parseFn, closeKind) {
//    expect(parser, openKind);
//    var nodes = [parseFn(parser)];
//    while (!skip(parser, closeKind)) {
//        nodes.push(parseFn(parser));
//    }
//    return nodes;
//}
/**
* Returns a non-empty list of parse nodes, determined by
* the parseFn. This list begins with a lex token of openKind
* and ends with a lex token of closeKind. Advances the parser
* to the next lex token after the closing token.
*/
func many<T>(parser: Parser, openKind: Int, parseFn: (parser: Parser) -> T, closeKind: Int) -> [T] {
    expect(parser, kind: getTokenKindDesc(openKind))
    var nodes = [parseFn(parser: parser)]
    while !skip(parser, kind: getTokenKindDesc(closeKind)) {
        nodes.append(parseFn(parser: parser))
    }
    return nodes
}

/**
* By default, the parser creates AST nodes that know the location
* in the source that they correspond to. This configuration flag
* disables that behavior for performance or testing.
*/

/**
* By default, the parser creates AST nodes that contain a reference
* to the source that they were created from. This configuration flag
* disables that behavior for performance or testing.
*/