//// **Parser**
//
//
///**
//* Given a GraphQL source, parses it into a Document.
//* Throws GraphQLError if a syntax error is encountered.
//*/
//func parse(source: Source, options: ParseOptions?) -> Document {
//    let parser = makeParser(source, options: options)
//    return parseDocument(parser)
//}
//
//func parse(source: String, options: ParseOptions?) -> Document {
//    let sourceObj = Source(body: source, name: nil)
//    let parser = makeParser(sourceObj, options: options)
//    return parseDocument(parser)
//}
//
///**
//* Given a string containing a GraphQL value, parse the AST for that value.
//* Throws GraphQLError if a syntax error is encountered.
//*
//* This is useful within tools that operate upon GraphQL Values directly and
//* in isolation of complete GraphQL documents.
//*/
//func parseValue(source: Source, options: ParseOptions?) -> Value {
//    let parser = makeParser(source, options: options)
//    // TODO: Check if return isConst here as false makes sense
//    // I think it'll just be undefined in JS and so is falsey
//    return parseValueLiteral(parser, isConst: false)
//}
//
//func parseValue(source: String, options: ParseOptions?) -> Value {
//    let sourceObj = Source(body: source, name: nil)
//    let parser = makeParser(sourceObj, options: options)
//    // TODO: Check if return isConst here as false makes sense
//    // I think it'll just be undefined in JS and so is falsey
//    return parseValueLiteral(parser, isConst: false)
//}
//
///**
//* Converts a name lex token into a name parse node.
//*/
//func parseName(parser: Parser) -> Name {
//    // TODO: Fix this 
//    // (later comment: not sure why it needs to be fixed)
//    let token = expect(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue))
//    return Name(value: token.value!, loc: loc(parser, start: token.start))
//}
//
//// Implements the parsing rules in the Document section.
//
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
//
//
//// Implements the parsing rules in the Operations section.
//
//func parseOperationDefinition(parser: Parser) -> Definition {
//    let start = parser.token.start
//    if peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue)) {
//        return Definition._OperationDefinition(
//            def: OperationDefinition(
//                operation: "query",
//                name: nil,
//                variableDefinitions: nil,
//                directives: [],
//                selectionSet: parseSelectionSet(parser),
//                loc: loc(parser, start: start)
//            )
//        )
//    }
//    let operationToken = expect(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue))
//    let operation = operationToken.value
//    return Definition._OperationDefinition(
//        def: OperationDefinition(
//            operation: operation!,
//            name: parseName(parser),
//            variableDefinitions: parseVariableDefinitions(parser),
//            directives: parseDirectives(parser),
//            selectionSet: parseSelectionSet(parser),
//            loc: loc(parser, start: start)
//        )
//    )
//}
//
//func parseVariableDefinitions(parser: Parser) -> [VariableDefinition] {
//    return peek(parser, kind: getTokenKindDesc(TokenKind.PAREN_L.rawValue)) ?
//        many(
//            parser,
//            openKind: TokenKind.PAREN_L.rawValue,
//            parseFn: parseVariableDefinition,
//            closeKind: TokenKind.PAREN_R.rawValue
//        ) :
//        []
//}
//
//func parseVariableDefinition(parser: Parser) -> VariableDefinition {
//    let start = parser.token.start
//    let defaultValue: Value? = skip(parser, kind: getTokenKindDesc(TokenKind.EQUALS.rawValue)) ? parseValueLiteral(parser, isConst: true) : nil
//    // TODO: Blog about this shit - it's THE shit
//    // TODO: Blog about the whole thing: JS -> Swift, pretty sick
//    return VariableDefinition(
//        variable: parseVariable(parser),
//        type: (expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)), parseType(parser)).1,
//        defaultValue: defaultValue,
//        loc: loc(parser, start: start)
//    )
//}
//
//func parseVariable(parser: Parser) -> Value {
//    let start = parser.token.start;
//    expect(parser, kind: getTokenKindDesc(TokenKind.DOLLAR.rawValue))
//    return Value._Variable(val: Variable(name: parseName(parser), loc: loc(parser, start: start)))
//}
//
//func parseSelectionSet(parser: Parser) -> SelectionSet {
//    let start = parser.token.start
//    return SelectionSet(
//        selections: many(
//            parser,
//            openKind: TokenKind.BRACE_L.rawValue,
//            parseFn: parseSelection,
//            closeKind: TokenKind.BRACE_R.rawValue
//        ),
//        loc: loc(parser, start: start)
//    )
//}
//
//func parseSelection(parser: Parser) -> Selection {
//    return peek(parser, kind: getTokenKindDesc(TokenKind.SPREAD.rawValue)) ?
//        parseFragment(parser) :
//        parseField(parser)
//}
//
///**
//* Corresponds to both Field and Alias in the spec
//*/
//func parseField(parser: Parser) -> Selection {
//    let start = parser.token.start
//    
//    let nameOrAlias = parseName(parser)
//    var alias: Name?
//    var name: Name
//    if skip(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)) {
//        alias = nameOrAlias
//        name = parseName(parser)
//    } else {
//        alias = nil
//        name = nameOrAlias
//    }
//    
//    let selectionSet: SelectionSet? = peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue)) ? parseSelectionSet(parser) : nil
//    
//    return Selection._Field(val:
//        Field(
//            alias: alias,
//            name: name,
//            arguments: parseArguments(parser),
//            directives: parseDirectives(parser),
//            selectionSet: selectionSet,
//            loc: loc(parser, start: start)
//        )
//    )
//}
//
//func parseArguments(parser: Parser) -> [Argument] {
//    return peek(parser, kind: getTokenKindDesc(TokenKind.PAREN_L.rawValue)) ?
//        many(
//            parser,
//            openKind: TokenKind.PAREN_L.rawValue,
//            parseFn: parseArgument,
//            closeKind: TokenKind.PAREN_R.rawValue
//        ) :
//        []
//}
//
//func parseArgument(parser: Parser) -> Argument {
//    let start = parser.token.start
//    // TODO: One like this somewhere else as well
//    // value: (expect(parser, TokenKind.COLON), parseValueLiteral(parser, false)),
//    // Investigate in graphql-test
//    // Seems to just run the expect function but then return the parseValueLiteral function return value
//    return Argument(
//        name: parseName(parser),
//        value: (expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)), parseValueLiteral(parser, isConst: false)).1,
//        loc: loc(parser, start: start)
//    )
//}
//
//
//// Implements the parsing rules in the Fragments section.
//
///**
//* Corresponds to both FragmentSpread and InlineFragment in the spec
//*/
//func parseFragment(parser: Parser) -> Selection {
//    let start = parser.token.start
//    expect(parser, kind: getTokenKindDesc(TokenKind.SPREAD.rawValue))
//    if parser.token.value == "on" {
//        advance(parser)
//        return Selection._InlineFragment(val:
//            InlineFragment(
//                typeCondition: parseNamedType(parser),
//                directives: parseDirectives(parser),
//                selectionSet: parseSelectionSet(parser),
//                loc: loc(parser, start: start)
//            )
//        )
//    }
//    return Selection._FragmentSpread(val:
//        FragmentSpread(
//            name: parseFragmentName(parser),
//            directives: parseDirectives(parser),
//            loc: loc(parser, start: start)
//        )
//    )
//}
//
//func parseFragmentName(parser: Parser) -> Name {
//    if parser.token.value == "on" {
//        throw unexpected(parser)
//    }
//    return parseName(parser)
//}
//
//func parseFragmentDefinition(parser: Parser) -> Definition {
//    let start = parser.token.start
//    expectKeyword(parser, value: "fragment")
//    return Definition._FragmentDefinition(def:
//        FragmentDefinition(
//            name: parseFragmentName(parser),
//            typeCondition: (expectKeyword(parser, value: "on"), parseNamedType(parser)).1,
//            directives: parseDirectives(parser),
//            selectionSet: parseSelectionSet(parser),
//            loc: loc(parser, start: start)
//        )
//    )
//}
//
//
//// Implements the parsing rules in the Values section.
//
//func parseConstValue(parser: Parser) -> Value {
//    return parseValueLiteral(parser, isConst: true)
//}
//
//func parseValueValue(parser: Parser) -> Value {
//    return parseValueLiteral(parser, isConst: false)
//}
//
//func parseValueLiteral(parser: Parser, isConst: Bool) -> Value {
//    let token = parser.token
//    switch token.kind {
//    case TokenKind.BRACKET_L.rawValue:
//        return parseList(parser, isConst: isConst)
//    case TokenKind.BRACE_L.rawValue:
//        return parseObject(parser, isConst: isConst)
//    case TokenKind.INT.rawValue:
//        advance(parser)
//        return Value._IntValue(val: IntValue(value: token.value!, loc: loc(parser, start: token.start)))
//    case TokenKind.FLOAT.rawValue:
//        advance(parser)
//        return Value._FloatValue(val: FloatValue(value: token.value!, loc: loc(parser, start: token.start)))
//    case TokenKind.STRING.rawValue:
//        advance(parser)
//        return Value._StringValue(val: StringValue(value: token.value!, loc: loc(parser, start: token.start)))
//    case TokenKind.NAME.rawValue:
//        if token.value == "true" || token.value == "false" {
//            advance(parser)
//            return Value._BooleanValue(val: BooleanValue(value: token.value! == "true", loc: loc(parser, start: token.start)))
//        } else if token.value != "null" {
//            advance(parser)
//            return Value._EnumValue(val: EnumValue(value: token.value!, loc: loc(parser, start: token.start)))
//        }
//        break
//    case TokenKind.DOLLAR.rawValue:
//        if !isConst {
//            return parseVariable(parser)
//        }
//        break
//    }
//    throw unexpected(parser)
//}
//
//func parseList(parser: Parser, isConst: Bool) -> Value {
//    let start = parser.token.start
//    let item = isConst ? parseConstValue : parseValueValue
//    return Value._ListValue(val:
//        ListValue(
//            values: any(
//                parser,
//                openKind: TokenKind.BRACKET_L.rawValue,
//                parseFn: item,
//                closeKind: TokenKind.BRACKET_R.rawValue
//            ),
//            loc: loc(parser, start: start)
//        )
//    )
//}
//
//func parseObject(parser: Parser, isConst: Bool) -> Value {
//    let start = parser.token.start
//    expect(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue))
//    var fieldNames: [String:Bool] = [:]
//    var fields: [ObjectField] = []
//    while !skip(parser, kind: getTokenKindDesc(TokenKind.BRACE_R.rawValue)) {
//        fields.append(parseObjectField(parser, isConst: isConst, fieldNames: fieldNames))
//    }
//    return Value._ObjectValue(val:
//        ObjectValue(
//            fields: fields,
//            loc: loc(parser, start: start)
//        )
//    )
//}
//
//func parseObjectField(parser: Parser, isConst: Bool, var fieldNames: [String:Bool]) -> ObjectField {
//    let start = parser.token.start
//    let name = parseName(parser)
//    if let val = fieldNames[name.value] {
//        throw syntaxError(
//            parser.source,
//            start,
//            "Duplicate input object field \(name.value)."
//        )
//    }
//    fieldNames[name.value] = true
//    return ObjectField(
//        name: name,
//        value: (expect(parser, kind: getTokenKindDesc(TokenKind.COLON.rawValue)), parseValueLiteral(parser, isConst: isConst)).1,
//        loc: loc(parser, start: start)
//    )
//}
//
//// Implements the parsing rules in the Directives section.
//
//func parseDirectives(parser: Parser) -> [Directive] {
//    var directives: [Directive]
//    while peek(parser, kind: getTokenKindDesc(TokenKind.AT.rawValue)) {
//        directives.append(parseDirective(parser))
//    }
//    return directives
//}
//
//func parseDirective(parser: Parser) -> Directive {
//    let start = parser.token.start
//    expect(parser, kind: getTokenKindDesc(TokenKind.AT.rawValue))
//    return Directive(
//        name: parseName(parser),
//        arguments: parseArguments(parser),
//        loc: loc(parser, start: start)
//    )
//}
//
//
//// Implements the parsing rules in the Types section.
//
///**
//* Handles the Type: NamedType, ListType, and NonNullType parsing rules.
//*/
//func parseType(parser: Parser) -> Type {
//    let start = parser.token.start
//    var type: Type
//    if skip(parser, kind: getTokenKindDesc(TokenKind.BRACKET_L.rawValue)) {
//        type = parseType(parser)
//        expect(parser, kind: getTokenKindDesc(TokenKind.BRACKET_R.rawValue))
//        type = Type._ListType(type: ListType(type: type, loc: loc(parser, start: start)))
//    } else {
//        type = parseNamedType(parser)
//    }
//    if skip(parser, kind: getTokenKindDesc(TokenKind.BANG.rawValue)) {
//        return Type._NonNullType(
//            type: NonNullType(
//                type: type,
//                loc: loc(parser, start: start)
//            )
//        )
//    }
//    return type
//}
//
//// TODO: Make this nicer, I hate returning Type when really it's always going to be a NamedType
//// This appears with NonNullType and a few other places as well. It's gross, and is basically
//// abusing static typing, but it makes it easier to work with
//func parseNamedType(parser: Parser) -> Type {
//    let start = parser.token.start
//    return Type._NamedType(type: NamedType(name: parseName(parser), loc: loc(parser, start: start)))
//}
//
