//
//  Language.swift
//  SwiftGraphQL
//
//  Created by Hamilton Chapman on 18/08/2015.
//
//

import Foundation

// **Kinds**

// Name

let NAME = "Name"

// Document

let DOCUMENT = "Document"
let OPERATION_DEFINITION = "OperationDefinition"
let VARIABLE_DEFINITION = "VariableDefinition"
let VARIABLE = "Variable"
let SELECTION_SET = "SelectionSet"
let FIELD = "Field"
let ARGUMENT = "Argument"

// Fragments

let FRAGMENT_SPREAD = "FragmentSpread"
let INLINE_FRAGMENT = "InlineFragment"
let FRAGMENT_DEFINITION = "FragmentDefinition"

// Values

let INT = "IntValue"
let FLOAT = "FloatValue"
let STRING = "StringValue"
let BOOLEAN = "BooleanValue"
let ENUM = "EnumValue"
let LIST = "ListValue"
let OBJECT = "ObjectValue"
let OBJECT_FIELD = "ObjectField"

// Directives

let DIRECTIVE = "Directive"

// Types

let NAMED_TYPE = "NamedType"
let LIST_TYPE = "ListType"
let NON_NULL_TYPE = "NonNullType"



// **SourceLocation**

struct SourceLocation {
    let line: Int
    let column: Int
}

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex, options: [])
        let nsString = text as NSString
        let results = regex.matchesInString(text,
            options: [], range: NSMakeRange(0, nsString.length))
        return results.map { nsString.substringWithRange($0.range)}
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}


/**
* Takes a Source and a UTF-8 character offset, and returns the corresponding
* line and column as a SourceLocation.
*/

// TODO: Sort out regex solution here
func getLocation(source: Source, position: Int) -> SourceLocation {
    var line = 1
    var column = position + 1
    let lineRegexp = "\r\n|[\n\r\u{2028}\u{2029}]"
    let matches = matchesForRegexInText(lineRegexp, text: source.body)

//    var match
    
//    while ((match = lineRegexp.exec(source.body)) && match.index < position) {
//        line += 1
//        column = position + 1 - (match.index + match[0].length)
//    }
    
    return SourceLocation(line: line, column: column)
}



// **Source**

struct Source {
    let body: String
    let name: String
    
    init(body: String, name: String?) {
        self.body = body
        self.name = name ?? "GraphQL"
    }
}


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
    case Name
    case Document
    case OperationDefinition
    case VariableDefinition
    case Variable
    case SelectionSet
    case Field
    case Argument
    case FragmentSpread
    case InlineFragment
    case FragmentDefinition
    case IntValue
    case FloatValue
    case StringValue
    case BooleanValue
    case EnumValue
    case ListValue
    case ObjectValue
    case ObjectField
    case Directive
    case ListType
    case NonNullType
}

class Node {
    let kind: String
    let loc: Location?
    
    init(kind: String, loc: Location? = nil) {
        self.kind = kind
        self.loc = loc
    }
}

// Name

class Name: Node {
    let value: String
    
    init(value: String, loc: Location? = nil) {
        self.value = value
        super.init(kind: "Name", loc: loc)
    }
}

// Document

class Document: Node {
    let definitions: [Definition]
    
    init(definitions: [Definition], loc: Location? = nil) {
        self.definitions = definitions
        super.init(kind: "Document", loc: loc)
    }
}

enum Definition {
    case OperationDefinition
    case FragmentDefinition
}

class OperationDefinition: Node {
    // TODO: Cleanup
    //    operation: 'query' | 'mutation';
    let operation: String
    let name: Name?
    let variableDefinitions: [VariableDefinition]?
    let directives: [Directive]?
    let selectionSet: SelectionSet
    
    init(operation: String, selectionSet: SelectionSet, loc: Location? = nil, name: Name?, variableDefinitions: [VariableDefinition]?, directives: [Directive]?) {
        self.operation = operation
        self.name = name
        self.variableDefinitions = variableDefinitions
        self.selectionSet = selectionSet
        self.directives = directives
        super.init(kind: "OperationDefinition", loc: loc)
    }
}

class VariableDefinition: Node {
    let variable: Variable
    let type: Type
    let defaultValue: Value?
    
    init(varialbe: Variable, type: Type, defaultValue: Value?, loc: Location? = nil) {
        self.type = type
        // TODO: Sort out this stupid error about assigning variable to itself
//        self.variable = variable
        self.defaultValue = defaultValue
        super.init(kind: "VariableDefinition", loc: loc)
    }
}

class Variable: Node {
    let name: Name
    
    init(name: Name, loc: Location? = nil) {
        self.name = name
        super.init(kind: "Variable", loc: loc)
    }
}

class SelectionSet: Node {
    let selections: [Selection]
    
    init(selections: [Selection], loc: Location? = nil) {
        self.selections = selections
        super.init(kind: "SelectionSet", loc: loc)
    }
}

enum Selection {
    case Field
    case FragmentSpread
    case InlineFragment
}

class Field: Node {
    let alias: Name?
    let name: Name
    let arguments: [Argument]?
    let directives: [Directive]?
    let selectionSet: SelectionSet?
    
    init(name: Name, alias: Name?, arguments: [Argument]?, directives: [Directive]?, selectionSet: SelectionSet?, loc: Location? = nil) {
        self.name = name
        self.alias = alias
        self.arguments = arguments
        self.directives = directives
        self.selectionSet = selectionSet
        super.init(kind: "Field", loc: loc)
    }
}

class Argument: Node {
    let name: Name
    let value: Value
    
    init(name: Name, value: Value, loc: Location? = nil) {
        self.name = name
        self.value = value
        super.init(kind: "Argument", loc: loc)
    }
}


// Fragments

class FragmentSpread: Node {
    let name: Name
    let directives: [Directive]?
    
    init(name: Name, directives: [Directive]?, loc: Location? = nil) {
        self.name = name
        self.directives = directives
        super.init(kind: "FragmentSpread", loc: loc)
    }
}

class InlineFragment: Node {
    let typeCondition: NamedType
    let directives: [Directive]?
    let selectionSet: SelectionSet
    
    init(name: Name, typeCondition: NamedType, selectionSet: SelectionSet, directives: [Directive]?, loc: Location? = nil) {
        self.typeCondition = typeCondition
        self.directives = directives
        self.selectionSet = selectionSet
        super.init(kind: "InlineFragment", loc: loc)
    }
}

class FragmentDefinition: Node {
    let name: Name
    let typeCondition: NamedType
    let directives: [Directive]?
    let selectionSet: SelectionSet
    
    init(name: Name, typeCondition: NamedType, selectionSet: SelectionSet, directives: [Directive]?, loc: Location? = nil) {
        self.typeCondition = typeCondition
        self.directives = directives
        self.selectionSet = selectionSet
        super.init(kind: "FragmentDefinition", loc: loc)
    }
}


// Values

enum Value {
    case Variable
    case IntValue
    case FloatValue
    case StringValue
    case BooleanValue
    case EnumValue
    case ListValue
    case ObjectValue
}

class IntValue: Node {
    let value: String
    
    init(value: String, loc: Location? = nil) {
        self.value = value
        super.init(kind: "IntValue", loc: loc)
    }
}

class FloatValue: Node {
    let value: String
    
    init(value: String, loc: Location? = nil) {
        self.value = value
        super.init(kind: "FloatValue", loc: loc)
    }
}

class StringValue: Node {
    let value: String
    
    init(value: String, loc: Location? = nil) {
        self.value = value
        super.init(kind: "StringValue", loc: loc)
    }
}

class BooleanValue: Node {
    let value: Bool
    
    init(value: Bool, loc: Location? = nil) {
        self.value = value
        super.init(kind: "BooleanValue", loc: loc)
    }
}

class EnumValue: Node {
    let value: String
    
    init(value: String, loc: Location? = nil) {
        self.value = value
        super.init(kind: "EnumValue", loc: loc)
    }
}

class ListValue: Node {
    let values: [Value]
    
    init(values: [Value], loc: Location? = nil) {
        self.values = values
        super.init(kind: "ListValue", loc: loc)
    }
}

class ObjectValue: Node {
    let fields: [ObjectField]
    
    init(fields: [ObjectField], loc: Location? = nil) {
        self.fields = fields
        super.init(kind: "ObjectValue", loc: loc)
    }
}

class ObjectField: Node {
    let name: Name
    let value: Value
    
    init(name: Name, value: Value, loc: Location? = nil) {
        self.name = name
        self.value = value
        super.init(kind: "ObjectField", loc: loc)
    }
}


// Directives

class Directive: Node {
    let name: Name
    let arguments: [Argument]?
    
    init(name: Name, arguments: [Argument]?, loc: Location? = nil) {
        self.name = name
        self.arguments = arguments
        super.init(kind: "Directive", loc: loc)
    }
}


// Types

enum Type {
    case NamedType
    case ListType
    case NonNullType
}

class NamedType: Node {
    let name: Name
    
    init(name: Name, loc: Location? = nil) {
        self.name = name
        super.init(kind: "NamedType", loc: loc)
    }
}

class ListType: Node {
    let type: Type
    
    init(type: Type, loc: Location? = nil) {
        self.type = type
        super.init(kind: "ListType", loc: loc)
    }
}

class NonNullType: Node {
    // TODO: Sort out selection of subset of enum (probably just use an initialiser - check out where NonNullType is being created)
    let type: Type
    
    init(type: Type, loc: Location? = nil) {
        self.type = type
        super.init(kind: "NonNullType", loc: loc)
    }
}




// **Lexer**

/**
* A representation of a lexed Token. Value is optional, is it is
* not needed for punctuators like BANG or PAREN_L.
*/
struct Token {
    let kind: Int
    let start: Int
    let end: Int
    let value: String?
}

// type Lexer = (resetPosition?: number) => Token;

typealias Lexer = (Int?) -> Token

/**
* Given a Source object, this returns a Lexer for that source.
* A Lexer is a function that acts like a generator in that every time
* it is called, it returns the next token in the Source. Assuming the
* source lexes, the final Token emitted by the lexer will be of kind
* EOF, after which the lexer will repeatedly return EOF tokens whenever
* called.
*
* The argument to the lexer function is optional, and can be used to
* rewind or fast forward the lexer to a new position in the source.
*/
func lex(source: Source) -> Lexer {
    var prevPosition = 0
    func nextToken(resetPosition: Int?) -> Token {
        var position: Int
        
        if let resetPosition = resetPosition {
            position = resetPosition
        } else {
            position = prevPosition
        }
        
        let token = readToken(source, fromPosition: position)
        
        prevPosition = token.end
        return token
    }
    return nextToken
}

/**
* An enum describing the different kinds of tokens that the lexer emits.
*/
enum TokenKind: Int {
    case EOF = 1,
    BANG,
    DOLLAR,
    PAREN_L,
    PAREN_R,
    SPREAD,
    COLON,
    EQUALS,
    AT,
    BRACKET_L,
    BRACKET_R,
    BRACE_L,
    PIPE,
    BRACE_R,
    NAME,
    VARIABLE,
    INT,
    FLOAT,
    STRING
}

/**
* A helper function to describe a token as a string for debugging
*/
func getTokenDesc(token: Token) -> String {
    if let value = token.value {
        return "\(getTokenKindDesc(token.kind)) \"\(value)\""
    } else {
        return getTokenKindDesc(token.kind)
    }
}

/**
* A helper function to describe a token kind as a string for debugging
*/
func getTokenKindDesc(kind: Int) -> String {
    return tokenDescription[kind]!
}

var tokenDescription = [
    TokenKind.EOF.rawValue: "EOF",
    TokenKind.BANG.rawValue: "!",
    TokenKind.DOLLAR.rawValue: "$",
    TokenKind.PAREN_L.rawValue: "(",
    TokenKind.PAREN_R.rawValue: ")",
    TokenKind.SPREAD.rawValue: "...",
    TokenKind.COLON.rawValue: ":",
    TokenKind.EQUALS.rawValue: "=",
    TokenKind.AT.rawValue: "@",
    TokenKind.BRACKET_L.rawValue: "[",
    TokenKind.BRACKET_R.rawValue: "]",
    TokenKind.BRACE_L.rawValue: "{",
    TokenKind.PIPE.rawValue: "|",
    TokenKind.BRACE_R.rawValue: "}",
    TokenKind.NAME.rawValue: "Name",
    TokenKind.VARIABLE.rawValue: "Variable",
    TokenKind.INT.rawValue: "Int",
    TokenKind.FLOAT.rawValue: "Float",
    TokenKind.STRING.rawValue: "String"
]


extension String {
    subscript (i: Int) -> Character? {
        if (self.characters.count - 1 < i) {
            return nil
        } else {
            return self[self.startIndex.advancedBy(i)]
        }
    }
}

// TODO: Sort out these
//var charCodeAt = String.prototype.charCodeAt;
//var fromCharCode = String.fromCharCode;
//var slice = String.prototype.slice;

func charCodeAt(body: String, position: Int) -> Int? {
    if let char = body[position] {
        return Int(String(char), radix: 16)
    } else {
        return nil
    }
}

func slice(str: String, start: Int, position: Int) -> String {
    return str.substringWithRange(Range(start: str.startIndex.advancedBy(start), end: str.startIndex.advancedBy(position)))
}

/**
* Helper function for constructing the Token object.
*/
func makeToken(kind: Int, start: Int, end: Int, value: String? = nil) -> Token {
    return Token(kind: kind, start: start, end: end, value: value)
}

/**
* Gets the next token from the source starting at the given position.
*
* This skips over whitespace and comments until it finds the next lexable
* token, then lexes punctuators immediately or calls the appropriate helper
* function for more complicated tokens.
*/
func readToken(source: Source, fromPosition: Int) -> Token {
    var body = source.body
    let bodyLength = body.characters.count
    
    let position = positionAfterWhitespace(body, startPosition: fromPosition)
    var code: Int
    
    if let charCode = charCodeAt(body, position: position) {
        code = charCode
    }
    
    if position >= bodyLength {
        return makeToken(TokenKind.EOF.rawValue, start: position, end: position)
    }
    
    switch code {
        // !
    case 33: return makeToken(TokenKind.BANG.rawValue, start: position, end: position + 1)
        // $
    case 36: return makeToken(TokenKind.DOLLAR.rawValue, start: position, end: position + 1)
        // (
    case 40: return makeToken(TokenKind.PAREN_L.rawValue, start: position, end: position + 1)
        // )
    case 41: return makeToken(TokenKind.PAREN_R.rawValue, start: position, end: position + 1)
        // .
    case 46:
        if let code = charCodeAt(body, position: position + 1), secondCode = charCodeAt(body, position: position + 2) where code == 46 && secondCode == 46 {
            return makeToken(TokenKind.SPREAD.rawValue, start: position, end: position + 3)
        }
        break;
        // :
    case 58: return makeToken(TokenKind.COLON.rawValue, start: position, end: position + 1)
        // =
    case 61: return makeToken(TokenKind.EQUALS.rawValue, start: position, end: position + 1)
        // @
    case 64: return makeToken(TokenKind.AT.rawValue, start: position, end: position + 1)
        // [
    case 91: return makeToken(TokenKind.BRACKET_L.rawValue, start: position, end: position + 1)
        // ]
    case 93: return makeToken(TokenKind.BRACKET_R.rawValue, start: position, end: position + 1)
        // {
    case 123: return makeToken(TokenKind.BRACE_L.rawValue, start: position, end: position + 1)
        // |
    case 124: return makeToken(TokenKind.PIPE.rawValue, start: position, end: position + 1)
        // }
    case 125: return makeToken(TokenKind.BRACE_R.rawValue, start: position, end: position + 1)
        // A-Z
    case 65...90: break
        // _
    case 95: break
        // a-z
    case 97...122:
        return readName(source, position: position)
        // -
    case 45: break
        // 0-9
    case 48...57:
        return readNumber(source, start: position, firstCode: code)
        // "
    case 34: return readString(source, start: position)
    }
    
    throw syntaxError(source, position, "Unexpected character \"\(fromCharCode(code))\".")
}

/**
* Reads from body starting at startPosition until it finds a non-whitespace
* or commented character, then returns the position of that character for
* lexing.
*/
func positionAfterWhitespace(body: String, startPosition: Int) -> Int {
    let bodyLength = body.characters.count
    var position = startPosition;
    while (position < bodyLength) {
        var code = charCodeAt(body, position: position)
        // Skip whitespace
        if (
                code == 32 || // space
                code == 44 || // comma
                code == 160 || // '\xa0'
                code == 0x2028 || // line separator
                code == 0x2029 || // paragraph separator
                code > 8 && code < 14 // whitespace
            ) {
                ++position;
                // Skip comments
        } else if (code == 35) { // #
            ++position
            code = charCodeAt(body, position: position)
            while (position < bodyLength && code != 10 && code != 13 && code != 0x2028 && code != 0x2029) {
                ++position;
            }
        } else {
            break;
        }
    }
    return position
}

/**
* Reads a number token from the source file, either a float
* or an int depending on whether a decimal point appears.
*
* Int:   -?(0|[1-9][0-9]*)
* Float: -?(0|[1-9][0-9]*)(\.[0-9]+)?((E|e)(+|-)?[0-9]+)?
*/
func readNumber(source: Source, start: Int, firstCode: Int) -> Token {
    var code = firstCode
    var body = source.body
    var position = start
    var isFloat = false
    
    if code == 45 { // -
        code = charCodeAt(body, position: position++)!
    }
    
    if code == 48 { // 0
        code = charCodeAt(body, position: position++)!
    } else if (code >= 49 && code <= 57) { // 1 - 9
        repeat {
            code = charCodeAt(body, position: position++)!
        } while (code >= 48 && code <= 57); // 0 - 9
    } else {
        throw syntaxError(source, position, "Invalid number.")
    }
    
    if code == 46 { // .
        isFloat = true
        
        code = charCodeAt(body, position: position++)!
        if code >= 48 && code <= 57 { // 0 - 9
            repeat {
                code = charCodeAt(body, position: position++)!
            } while code >= 48 && code <= 57 // 0 - 9
        } else {
            throw syntaxError(source, position, "Invalid number.")
        }
    }
    
    if (code == 69 || code == 101) { // E e
        isFloat = true
        
        code = charCodeAt(body, position: position++)!
        if code == 43 || code == 45 { // + -
            code = charCodeAt(body, position: position++)!
        }
        if code >= 48 && code <= 57 { // 0 - 9
            repeat {
                code = charCodeAt(body, position: position++)!
            } while code >= 48 && code <= 57 // 0 - 9
        } else {
            throw syntaxError(source, position, "Invalid number.")
        }
    }
    
    return makeToken(
        isFloat ? TokenKind.FLOAT.rawValue : TokenKind.INT.rawValue,
        start: start ,
        end: position,
        value: slice(body, start: start, position: position)
    )
}

/**
* Reads a string token from the source file.
*
* "([^"\\\u000A\u000D\u2028\u2029]|(\\(u[0-9a-fA-F]{4}|["\\/bfnrt])))*"
*/
func readString(source: Source, start: Int) -> Token {
    var body = source.body
    var position = start + 1
    var chunkStart = position
    var code = charCodeAt(body, position: position)
    var value = ""
    
    while (
        position < body.characters.count &&
            code != nil && code != 34 &&
            code != 10 && code != 13 && code != 0x2028 && code != 0x2029
        ) {
            position++
            if code == 92 { // \
                value += slice(body, start: chunkStart, position: position - 1)
                code = charCodeAt(body, position: position)!
                switch code! {
                case 34: value += "\""; break
                case 47: value += "\u{47}"; break
                case 92: value += "\\"; break
                case 98: value += "\u{8}"; break
                case 102: value += "\u{12}"; break
                case 110: value += "\n"; break
                case 114: value += "\r"; break
                case 116: value += "\t"; break
                case 117:
//                    returns nil now instead of -1
                    var charCode = uniCharCode(
                        charCodeAt(body, position: position + 1),
                        charCodeAt(body, position: position + 2),
                        charCodeAt(body, position: position + 3),
                        charCodeAt(body, position: position + 4)
                    )
                    if let charCode = charCode {
                        throw syntaxError(
                            source,
                            position,
                            "Bad character escape sequence."
                        )
                    }
                    value += fromCharCode(charCode)
                    position += 4
                    break
                default:
                    throw syntaxError(
                        source,
                        position,
                        "Bad character escape sequence."
                    )
                }
                position++
                chunkStart = position
            }
        code = charCodeAt(body, position: position)!
    }
    
    if code != 34 {
        throw syntaxError(source, position, "Unterminated string.")
    }
    
    value += slice(body, start: chunkStart, position: position)
    return makeToken(TokenKind.STRING.rawValue, start: start, end: position + 1, value: value)
}

/**
* Converts four hexidecimal chars to the integer that the
* string represents. For example, uniCharCode('0','0','0','f')
* will return 15, and uniCharCode('0','0','f','f') returns 255.
*
* Returns nil on error, if a char was invalid.
*
* This is implemented by noting that char2hex() returns -1 on error,
* which means the result of ORing the char2hex() will also be negative.
*/
func uniCharCode(a: String, b: String, c: String, d: String) -> Int? {
    if let a = Int(a, radix: 16), b = Int(b, radix: 16), c = Int(c, radix: 16), d = Int(d, radix: 16) {
        return a << 12 | b << 8 | c << 4 | d
    } else {
        return nil
    }
}


/**
* Reads an alphanumeric + underscore name from the source.
*
* [_A-Za-z][_0-9A-Za-z]*
*/
func readName(source: Source, position: Int) -> Token {
    let body = source.body
    let bodyLength = body.characters.count
    var end = position + 1
    var code = charCodeAt(body, position: end)
    
    while (
        end != bodyLength &&
        (
            code == 95 || // _
            code >= 48 && code <= 57 || // 0-9
            code >= 65 && code <= 90 || // A-Z
            code >= 97 && code <= 122 // a-z
        )
    ) {
        end++
        code = charCodeAt(body, position: end)
    }
    return makeToken(
        TokenKind.NAME.rawValue,
        start: position,
        end: end,
        value: slice(body, start: position, position: end)
    )
}




// **ParserCore**

/**
* Returns the parser object that is used to store state throughout the
* process of parsing.
*/
// TODO: Figure out WTF a _lexToken is
func makeParser(source: Source, options: ParseOptions?) -> Parser {
    var _lexToken = lex(source)
    return Parser(_lexToken, source, options, prevEnd: 0, token: _lexToken())
}


// TODO: This ain't legit, figure out what I reall need
struct Parser {
    let _lexToken: Lexer
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

/**
* Moves the internal parser object to the next lexed token.
*/
func advance(var parser: Parser) {
    let prevEnd = parser.token.end
    parser.prevEnd = prevEnd
    parser.token = parser._lexToken(prevEnd)
}

// TODO: Whether to use getTokenKindDesc or getTokenDesc

/**
* Determines if the next token is of a given kind
*/
func peek(parser: Parser, kind: String) -> Bool {
    return getTokenKindDesc(parser.token.kind) == kind
}

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

/**
* Helper export function for creating an error when an unexpected lexed token
* is encountered.
*/
// TODO: BaseError correct?
func unexpected(parser: Parser, atToken: Token?) -> BaseError {
    let token = atToken ?? parser.token
    return syntaxError(
        parser.source,
        token.start,
        "Unexpected \(getTokenDesc(token))"
    )
}

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




// **Parser**


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
func parseValue(source: Source, options: ParseOptions?) -> Value {
    let parser = makeParser(source, options: options)
    return parseValueLiteral(parser)
}

func parseValue(source: String, options: ParseOptions?) -> Value {
    let sourceObj = Source(body: source, name: nil)
    let parser = makeParser(sourceObj, options: options)
    return parseValueLiteral(parser)
}

/**
* Converts a name lex token into a name parse node.
*/
func parseName(parser: Parser) -> Name {
    // TODO: Fix this
    let token = expect(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue))
    return Name(value: token.value!, loc: loc(parser, start: token.start))
}

// Implements the parsing rules in the Document section.

func parseDocument(parser: Parser) -> Document {
    var start = parser.token.start
    // TODO: Make it not anyobject
    var definitions: [Definition]
    repeat {
        if peek(parser, kind: getTokenKindDesc(TokenKind.BRACE_L.rawValue)) {
            definitions.append(parseOperationDefinition(parser))
        } else if peek(parser, kind: getTokenKindDesc(TokenKind.NAME.rawValue)) {
            if parser.token.value == "query" || parser.token.value == "mutation" {
                definitions.append(parseOperationDefinition(parser))
            } else if parser.token.value == "fragment" {
                definitions.append(parseFragmentDefinition(parser))
            } else {
                throw unexpected(parser)
            }
        } else {
            throw unexpected(parser)
        }
    } while !skip(parser, kind: getTokenKindDesc(TokenKind.EOF.rawValue))
    return Document(definitions: definitions, loc: loc(parser, start: start))
}


// Implements the parsing rules in the Operations section.

func parseOperationDefinition(parser: Parser) -> OperationDefinition {
    let start = parser.token.start
    if peek(parser, TokenKind.BRACE_L) {
        return {
            kind: OPERATION_DEFINITION,
            operation: 'query',
            name: null,
            variableDefinitions: null,
            directives: [],
            selectionSet: parseSelectionSet(parser),
            loc: loc(parser, start)
        };
    }
    var operationToken = expect(parser, TokenKind.NAME);
    var operation = operationToken.value;
    return {
        kind: OPERATION_DEFINITION,
        operation,
        name: parseName(parser),
        variableDefinitions: parseVariableDefinitions(parser),
        directives: parseDirectives(parser),
        selectionSet: parseSelectionSet(parser),
        loc: loc(parser, start)
    };
}

func parseVariableDefinitions(parser: Parser) -> [VariableDefinition] {
    return peek(parser, TokenKind.PAREN_L) ?
        many(
            parser,
            TokenKind.PAREN_L,
            parseVariableDefinition,
            TokenKind.PAREN_R
        ) :
        [];
}

func parseVariableDefinition(parser: Parser) -> VariableDefinition {
    var start = parser.token.start;
    return {
        kind: VARIABLE_DEFINITION,
        variable: parseVariable(parser),
        type: (expect(parser, TokenKind.COLON), parseType(parser)),
        defaultValue:
        skip(parser, TokenKind.EQUALS) ? parseValueLiteral(parser, true) : null,
        loc: loc(parser, start)
    };
}

func parseVariable(parser: Parser) -> Variable {
    var start = parser.token.start;
    expect(parser, TokenKind.DOLLAR)
    return {
        kind: VARIABLE,
        name: parseName(parser),
        loc: loc(parser, start)
    }
}

func parseSelectionSet(parser: Parser) -> SelectionSet {
    var start = parser.token.start
    return {
        kind: SELECTION_SET,
        selections:
        many(parser, TokenKind.BRACE_L, parseSelection, TokenKind.BRACE_R),
        loc: loc(parser, start)
    };
}

func parseSelection(parser: Parser) -> Selection {
    return peek(parser, TokenKind.SPREAD) ?
        parseFragment(parser) :
        parseField(parser);
}

/**
* Corresponds to both Field and Alias in the spec
*/
func parseField(parser: Parser) -> Field {
    var start = parser.token.start
    
    var nameOrAlias = parseName(parser)
    var alias
    var name
    if (skip(parser, TokenKind.COLON)) {
        alias = nameOrAlias
        name = parseName(parser)
    } else {
        alias = nil
        name = nameOrAlias
    }
    
    return {
        kind: FIELD,
        alias,
        name,
        arguments: parseArguments(parser),
        directives: parseDirectives(parser),
        selectionSet:
        peek(parser, TokenKind.BRACE_L) ? parseSelectionSet(parser) : null,
        loc: loc(parser, start)
    }
}

func parseArguments(parser: Parser) -> [Argument] {
    return peek(parser, TokenKind.PAREN_L) ?
        many(parser, TokenKind.PAREN_L, parseArgument, TokenKind.PAREN_R) :
        []
}

func parseArgument(parse: Parserr) -> Argument {
    var start = parser.token.start;
    return {
        kind: ARGUMENT,
        name: parseName(parser),
        value: (expect(parser, TokenKind.COLON), parseValueLiteral(parser, false)),
        loc: loc(parser, start)
    };
}


// Implements the parsing rules in the Fragments section.

/**
* Corresponds to both FragmentSpread and InlineFragment in the spec
*/
func parseFragment(parser: Parser) -> FragmentSpread | InlineFragment {
    var start = parser.token.start;
    expect(parser, TokenKind.SPREAD);
    if (parser.token.value === 'on') {
        advance(parser);
        return {
            kind: INLINE_FRAGMENT,
            typeCondition: parseNamedType(parser),
            directives: parseDirectives(parser),
            selectionSet: parseSelectionSet(parser),
            loc: loc(parser, start)
        };
    }
    return {
        kind: FRAGMENT_SPREAD,
        name: parseFragmentName(parser),
        directives: parseDirectives(parser),
        loc: loc(parser, start)
    };
}

func parseFragmentName(parser: Parser) -> Name {
    if parser.token.value == "on" {
        throw unexpected(parser)
    }
    return parseName(parser)
}

func parseFragmentDefinition(parser: Parser) -> FragmentDefinition {
    var start = parser.token.start;
    expectKeyword(parser, 'fragment');
    return {
        kind: FRAGMENT_DEFINITION,
        name: parseFragmentName(parser),
        typeCondition: (expectKeyword(parser, 'on'), parseNamedType(parser)),
        directives: parseDirectives(parser),
        selectionSet: parseSelectionSet(parser),
        loc: loc(parser, start)
    }
}


// Implements the parsing rules in the Values section.

func parseConstValue(parser: Parser) -> Value {
    return parseValueLiteral(parser, isConst: true)
}

func parseValueValue(parser: Parser) -> Value {
    return parseValueLiteral(parser, isConst: false)
}

func parseValueLiteral(parser: Parser, isConst: Bool) -> Value {
    let token = parser.token
    switch token.kind {
    case TokenKind.BRACKET_L.rawValue:
        return parseList(parser, isConst: isConst)
    case TokenKind.BRACE_L.rawValue:
        return parseObject(parser, isConst: isConst)
    case TokenKind.INT.rawValue:
        advance(parser)
        return IntValue(value: token.value!, loc: loc(parser, start: token.start))
    case TokenKind.FLOAT.rawValue:
        advance(parser)
        return FloatValue(value: token.value!, loc: loc(parser, start: token.start))
    case TokenKind.STRING.rawValue:
        advance(parser)
        return StringValue(value: token.value!, loc: loc(parser, start: token.start))
    case TokenKind.NAME.rawValue:
        if token.value == "true" || token.value == "false" {
            advance(parser)
            return BooleanValue(value: token.value! == "true", loc: loc(parser, start: token.start))
        } else if token.value != "null" {
            advance(parser)
            return EnumValue(value: token.value!, loc: loc(parser, start: token.start))
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

func parseList(parser: Parser, isConst: Bool) -> ListValue {
    var start = parser.token.start
    var item = isConst ? parseConstValue : parseValueValue
    return ListValue(
        values: any(
                    parser,
                    openKind: TokenKind.BRACKET_L.rawValue,
                    item,
                    closeKind: TokenKind.BRACKET_R.rawValue
                ),
        loc: loc(parser, start: token.start)
    )
}

func parseObject(parser: Parser, isConst: Bool) -> ObjectValue {
    let start = parser.token.start
    expect(parser, kind: getTokenDesc(TokenKind.BRACE_L))
    // TODO: Figure this out
//    var fieldNames
//    var fields = []
    while !skip(parser, kind: getTokenDesc(TokenKind.BRACE_R)) {
        fields.append(parseObjectField(parser, isConst, fieldNames));
    }
    return ObjectValue(fields: fields, loc: loc(parser, start: start))
}

func parseObjectField(parser: Parser, isConst: Bool, var fieldNames: [String:Bool]) -> ObjectField {
    let start = parser.token.start
    let name = parseName(parser)
    // TOOD: Check what hasOwnProperty does
    if fieldNames.hasOwnProperty(name.value) {
        throw syntaxError(
            parser.source,
            start,
            "Duplicate input object field \(name.value)."
        )
    }
    fieldNames[name.value] = true
    return ObjectField(name: name, value: (expect(parser, kind: getTokenDesc(TokenKind.COLON)), parseValueLiteral(parser, isConst)), loc: loc(parser, start: start))
}

// Implements the parsing rules in the Directives section.

func parseDirectives(parser: Parser) -> [Directive] {
    var directives: [Directive]
    while peek(parser, kind: getTokenDesc(TokenKind.AT)) {
        directives.append(parseDirective(parser))
    }
    return directives
}

func parseDirective(parser: Parser) -> Directive {
    let start = parser.token.start
    expect(parser, kind: getTokenDesc(TokenKind.AT))
    return Directive(name: parseName(parser), arguments: parseArguments(parser), loc: loc(parser, start: start))
}


// Implements the parsing rules in the Types section.

/**
* Handles the Type: NamedType, ListType, and NonNullType parsing rules.
*/
// TODO: Make generic if possible or setup multi functions to return different types
// Might have to do some casting after returning AnyObject
func parseType(parser: Parser) -> Type {
    let start = parser.token.start
    var type: Type
    if skip(parser, kind: getTokenKindDesc(TokenKind.BRACKET_L.rawValue)) {
        type = parseType(parser)
        expect(parser, kind: getTokenKindDesc(TokenKind.BRACKET_R.rawValue))
        type = ListType(type: type, loc: loc(parser, start: start))
    } else {
        type = parseNamedType(parser)
    }
    if skip(parser, kind: getTokenKindDesc(TokenKind.BANG.rawValue)) {
        return NonNullType(type: type, loc: loc(parser, start: start))
    }
    return type
}

func parseNamedType(parser: Parser) -> NamedType {
    let start = parser.token.start
    return NamedType(name: parseName(parser), loc: loc(parser, start: start))
}



// **Visitor**

var QueryDocumentKeys = {
    Name: [],
    
    Document: [ "definitions" ],
    OperationDefinition:
    [ "name", "variableDefinitions", "directives", "selectionSet" ],
    VariableDefinition: [ "variable", "type", "defaultValue" ],
    Variable: [ "name" ],
    SelectionSet: [ "selections" ],
    Field: [ "alias", "name", "arguments", "directives", "selectionSet" ],
    Argument: [ "name", "value" ],
    
    FragmentSpread: [ "name", "directives" ],
    InlineFragment: [ "typeCondition", "directives", "selectionSet" ],
    FragmentDefinition: [ "name", "typeCondition", "directives", "selectionSet" ],
    
    IntValue: [],
    FloatValue: [],
    StringValue: [],
    BooleanValue: [],
    EnumValue: [],
    ListValue: [ "values" ],
    ObjectValue: [ "fields" ],
    ObjectField: [ "name", "value" ],
    
    Directive: [ "name", "arguments" ],
    
    NamedType: [ "name" ],
    ListType: [ "type" ],
    NonNullType: [ "type" ],
}

export const BREAK = {}

/**
* visit() will walk through an AST using a depth first traversal, calling
* the visitor's enter function at each node in the traversal, and calling the
* leave function after visiting that node and all of it's child nodes.
*
* By returning different values from the enter and leave functions, the
* behavior of the visitor can be altered, including skipping over a sub-tree of
* the AST (by returning false), editing the AST by returning a value or null
* to remove the value, or to stop the whole traversal by returning BREAK.
*
* When using visit() to edit an AST, the original AST will not be modified, and
* a new version of the AST with the changes applied will be returned from the
* visit function.
*
*     var editedAST = visit(ast, {
*       enter(node, key, parent, path, ancestors) {
*         // @return
*         //   undefined: no action
*         //   false: skip visiting this node
*         //   visitor.BREAK: stop visiting altogether
*         //   null: delete this node
*         //   any value: replace this node with the returned value
*       },
*       leave(node, key, parent, path, ancestors) {
*         // @return
*         //   undefined: no action
*         //   false: no action
*         //   visitor.BREAK: stop visiting altogether
*         //   null: delete this node
*         //   any value: replace this node with the returned value
*       }
*     });
*
* Alternatively to providing enter() and leave() functions, a visitor can
* instead provide functions named the same as the kinds of AST nodes, or
* enter/leave visitors at a named key, leading to four permutations of
* visitor API:
*
* 1) Named visitors triggered when entering a node a specific kind.
*
*     visit(ast, {
*       Kind(node) {
*         // enter the "Kind" node
*       }
*     })
*
* 2) Named visitors that trigger upon entering and leaving a node of
*    a specific kind.
*
*     visit(ast, {
*       Kind: {
*         enter(node) {
*           // enter the "Kind" node
*         }
*         leave(node) {
*           // leave the "Kind" node
*         }
*       }
*     })
*
* 3) Generic visitors that trigger upon entering and leaving any node.
*
*     visit(ast, {
*       enter(node) {
*         // enter any node
*       },
*       leave(node) {
*         // leave any node
*       }
*     })
*
* 4) Parallel visitors for entering and leaving nodes of a specific kind.
*
*     visit(ast, {
*       enter: {
*         Kind(node) {
*           // enter the "Kind" node
*         }
*       },
*       leave: {
*         Kind(node) {
*           // leave the "Kind" node
*         }
*       }
*     })
*/
func visit(root: Node, visitor: Visitor, keyMap: KeyMap?) -> SchemaDocument {
    var visitorKeys = keyMap ?? QueryDocumentKeys
    
    var stack: Stack? = nil
    
    
    // TODO: Work out how to check if root is an array of some sort
    var inArray: Bool
//    var inArray: Bool = Array.isArray(root)

    var keys: [AnyObject] = [root]
    var index = -1
    // TODO: Figure out something better than AnyObjects
    var edits: [AnyObject] = []
    var parent: Node?
    var path: [AnyObject] = []
    var ancestors: [Node] = []
    var newRoot = root
    
    repeat {
        index++
        var isLeaving = index == keys.count
        var key: AnyObject?
        var node: Node?
        var isEdited = isLeaving && edits.count != 0
        if isLeaving {
            key = ancestors.count == 0 ? nil : path.popLast()
            node = parent
            parent = ancestors.popLast()
            if isEdited {
                let nodeCopy = node
                node = nodeCopy
                // TODO: Figure out if I need any of this - if a node is a Struct with only value types inside of it then I don't think I do
//                if inArray {
//                    let nodeCopy = node
//                    node = nodeCopy
//                } else {
//                    var clone = {}
//                    for (var k in node) {
//                        if (node.hasOwnProperty(k)) {
//                            clone[k] = node[k]
//                        }
//                    }
//                    node = clone
//                }
                var editOffset = 0
                for (var ii = 0; ii < edits.count; ii++) {
                    let [editKey, editValue] = edits[ii]
                    if inArray {
                        editKey -= editOffset
                    }
                    if inArray && editValue == nil {
                        node.removeAtIndex(editKey)
                        node.splice(editKey, 1)
                        editOffset++
                    } else {
                        node[editKey] = editValue
                    }
                }
            }
            if let stackCopy = stack {
                index = stackCopy.index
                keys = stackCopy.keys
                edits = stackCopy.edits
                inArray = stackCopy.inArray
                stack = stackCopy.prev
            }
        } else {
            key = parent ? inArray ? index : keys[index] : nil
            node = parent ? parent[key] : newRoot
            if node == nil || node == nil {
                continue
            }
            if parent != nil {
                path.append(key)
            }
        }
        
        var result
        if !Array.isArray(node) {
            if !isNode(node) {
                throw Error("Invalid AST Node: " + JSON.stringify(node))
            }
            var visitFn = getVisitFn(visitor, isLeaving, node.kind)
            if visitFn {
                result = visitFn.call(visitor, node, key, parent, path, ancestors)
                
                if result == BREAK {
                    break
                }
                
                if result == false {
                    if !isLeaving {
                        path.popLast()
                        continue
                    }
                } else if result != nil {
                    edits.append([ key, result ])
                    if !isLeaving {
                        if isNode(result) {
                            node = result
                        } else {
                            path.popLast()
                            continue
                        }
                    }
                }
            }
        }
        
        if result == nil && isEdited {
            edits.append([ key, node ])
        }
        
        if !isLeaving {
            stack = Stack(inArray: inArray, index: index, keys: keys, edits: edits, prev: stack)
            inArray = Array.isArray(node)
            keys = inArray ? node : visitorKeys[node.kind] ?? []
            index = -1
            edits = []
            if parent {
                ancestors.append(parent)
            }
            parent = node
        }
    } while stack != nil
    
    if edits.count != 0 {
        newRoot = edits[0][1]
    }
    
    return newRoot
}


struct Stack {
    var inArray: Bool
    var index: Int
    var keys: [AnyObject]
    var edits: []
    var prev: Stack
}

func isNode(maybeNode: Node?) {
    return maybeNode != nil && maybeNode.kind == "string"
}

func getVisitFn(visitor, isLeaving, kind) {
    var kindVisitor = visitor[kind]
    if (kindVisitor) {
        if (!isLeaving && typeof kindVisitor === 'function') {
            // { Kind() {} }
            return kindVisitor;
        }
        var kindSpecificVisitor = isLeaving ? kindVisitor.leave : kindVisitor.enter;
        if (typeof kindSpecificVisitor === 'function') {
            // { Kind: { enter() {}, leave() {} } }
            return kindSpecificVisitor;
        }
        return;
    }
    var specificVisitor = isLeaving ? visitor.leave : visitor.enter;
    if (specificVisitor) {
        if (typeof specificVisitor === 'function') {
            // { enter() {}, leave() {} }
            return specificVisitor;
        }
        var specificKindVisitor = specificVisitor[kind];
        if (typeof specificKindVisitor === 'function') {
            // { enter: { Kind() {} }, leave: { Kind() {} } }
            return specificKindVisitor;
        }
    }
}

