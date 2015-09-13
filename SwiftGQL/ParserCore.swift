//// **ParserCore**
//
///**
//* Returns the parser object that is used to store state throughout the
//* process of parsing.
//*/
//// TODO: Figure out WTF a _lexToken is
//func makeParser(source: Source, options: ParseOptions?) -> Parser {
//    var _lexToken = lex(source)
//    return Parser(_lexToken, source, options, prevEnd: 0, token: _lexToken())
//}
//
//
//// TODO: This ain't legit, figure out what I really need
//struct Parser {
////    let _lexToken: Lexer
//    let _lexToken: Token
//    let source: Source
//    let options: ParseOptions?
//    var prevEnd: Int
//    var token: Token
//}
//
///**
//* Configuration options to control parser behavior
//*/
//struct ParseOptions {
//    /**
//    * By default, the parser creates AST nodes that know the location
//    * in the source that they correspond to. This configuration flag
//    * disables that behavior for performance or testing.
//    */
//    let noLocation: Bool?
//    
//    /**
//    * By default, the parser creates AST nodes that contain a reference
//    * to the source that they were created from. This configuration flag
//    * disables that behavior for performance or testing.
//    */
//    let noSource: Bool?
//}
//
///**
//* Returns a location object, used to identify the place in
//* the source that created a given parsed object.
//*/
//func loc(parser: Parser, start: Int) -> Location? {
//    if let _ = parser.options?.noLocation {
//        return nil
//    }
//    if let _ = parser.options?.noSource {
//        return Location(start: start, end: parser.prevEnd, source: nil)
//    }
//    return Location(start: start, end: parser.prevEnd, source: parser.source)
//}
//
///**
//* Moves the internal parser object to the next lexed token.
//*/
//func advance(var parser: Parser) {
//    let prevEnd = parser.token.end
//    parser.prevEnd = prevEnd
//    parser.token = parser._lexToken(prevEnd)
//}
//
//// TODO: Work out whether to use getTokenKindDesc or getTokenDesc at different points
//
///**
//* Determines if the next token is of a given kind
//*/
//func peek(parser: Parser, kind: String) -> Bool {
//    return getTokenKindDesc(parser.token.kind) == kind
//}
//
///**
//* If the next token is of the given kind, return true after advancing
//* the parser. Otherwise, do not change the parser state and return false.
//*/
//func skip(parser: Parser, kind: String) -> Bool {
//    let match = getTokenKindDesc(parser.token.kind) == kind
//    if match {
//        advance(parser)
//    }
//    return match
//}
//
///**
//* If the next token is of the given kind, return that token after advancing
//* the parser. Otherwise, do not change the parser state and return false.
//*/
//func expect(parser: Parser, kind: String) -> Token {
//    var token = parser.token
//    if (getTokenKindDesc(token.kind) == kind) {
//        advance(parser)
//        return token
//    }
//    throw syntaxError(
//        parser.source,
//        token.start,
//        "Expected \(kind), found \(getTokenDesc(token))"
//    )
//}
//
///**
//* If the next token is a keyword with the given value, return that token after
//* advancing the parser. Otherwise, do not change the parser state and return
//* false.
//*/
//func expectKeyword(parser: Parser, value: String) -> Token {
//    let token = parser.token
//    if token.kind == TokenKind.NAME.rawValue && token.value == value {
//        advance(parser)
//        return token
//    }
//    throw syntaxError(
//        parser.source,
//        token.start,
//        "Expected \(value), found \(getTokenDesc(token))"
//    )
//}
//
///**
//* Helper export function for creating an error when an unexpected lexed token
//* is encountered.
//*/
//// TODO: BaseError correct?
//func unexpected(parser: Parser, atToken: Token?) -> BaseError {
//    let token = atToken ?? parser.token
//    return syntaxError(
//        parser.source,
//        token.start,
//        "Unexpected \(getTokenDesc(token))"
//    )
//}
//
///**
//* Returns a possibly empty list of parse nodes, determined by
//* the parseFn. This list begins with a lex token of openKind
//* and ends with a lex token of closeKind. Advances the parser
//* to the next lex token after the closing token.
//*/
//func any<T>(parser: Parser, openKind: Int, parseFn: (parser: Parser) -> T, closeKind: Int) -> [T] {
//    expect(parser, kind: getTokenKindDesc(openKind))
//    var nodes: [T] = []
//    while !skip(parser, kind: getTokenKindDesc(closeKind)) {
//        nodes.append(parseFn(parser: parser))
//    }
//    return nodes
//}
//
///**
//* Returns a non-empty list of parse nodes, determined by
//* the parseFn. This list begins with a lex token of openKind
//* and ends with a lex token of closeKind. Advances the parser
//* to the next lex token after the closing token.
//*/
//func many<T>(parser: Parser, openKind: Int, parseFn: (parser: Parser) -> T, closeKind: Int) -> [T] {
//    expect(parser, kind: getTokenKindDesc(openKind))
//    var nodes = [parseFn(parser: parser)]
//    while !skip(parser, kind: getTokenKindDesc(closeKind)) {
//        nodes.append(parseFn(parser: parser))
//    }
//    return nodes
//}
//
//
