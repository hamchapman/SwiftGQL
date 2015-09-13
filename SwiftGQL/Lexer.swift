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
// TODO: Sort out whether Lexer makes sense as a typealias
// I think NextTokenFn makes more sense
typealias Lexer = (Int?) -> Token
typealias NextTokenFn = (Int?) -> Token

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
// TODO: Blog / question about how the default value seems to get lost
// calling _lexToken() still requires nil as a param
func lex(source: Source) -> NextTokenFn {
    var prevPosition = 0
    func nextToken(resetPosition: Int? = nil) -> Token {
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
    
    // TODO: Check if required anymore
    subscript (i: Int) -> Character? {
        if (self.characters.count - 1 < i) {
            return nil
        } else {
            return self[self.startIndex.advancedBy(i)]
        }
    }
    
    func substringWithRange(range:Range<Int>) -> String {
        let start = self.startIndex.advancedBy(range.startIndex)
        let end = self.startIndex.advancedBy(range.endIndex)
        return self.substringWithRange(start..<end)
    }
}

// TODO: Sort out these
//var charCodeAt = String.prototype.charCodeAt;
//var fromCharCode = String.fromCharCode;
//var slice = String.prototype.slice;

//func charCodeAt(body: String, position: Int) -> Int? {
//    if let char = body[position] {
//        return Int(String(char), radix: 16)
//    } else {
//        return nil
//    }
//}

func charCodeAt(body: String, position: Int) -> Int {
    let char = body.substringWithRange(position...position)
    var charVals: [Int] = []
    
    for val in char.utf8 {
        charVals.append(Int(val))
    }
    return charVals.first!
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
    var code = charCodeAt(body, position: position)
    
    //    if let charCode = charCodeAt(body, position: position) {
    //        code = charCode
    //    }
    
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
        code = charCodeAt(body, position: position + 1)
        var secondCode = charCodeAt(body, position: position + 2)
        if code == 46 && secondCode == 46 {
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
        code = charCodeAt(body, position: position++)
    }
    
    if code == 48 { // 0
        code = charCodeAt(body, position: position++)
    } else if (code >= 49 && code <= 57) { // 1 - 9
        repeat {
            code = charCodeAt(body, position: position++)
        } while (code >= 48 && code <= 57); // 0 - 9
    } else {
        throw syntaxError(source, position, "Invalid number.")
    }
    
    if code == 46 { // .
        isFloat = true
        
        code = charCodeAt(body, position: position++)
        if code >= 48 && code <= 57 { // 0 - 9
            repeat {
                code = charCodeAt(body, position: position++)
            } while code >= 48 && code <= 57 // 0 - 9
        } else {
            throw syntaxError(source, position, "Invalid number.")
        }
    }
    
    if code == 69 || code == 101 { // E e
        isFloat = true
        
        code = charCodeAt(body, position: position++)
        if code == 43 || code == 45 { // + -
            code = charCodeAt(body, position: position++)
        }
        if code >= 48 && code <= 57 { // 0 - 9
            repeat {
                code = charCodeAt(body, position: position++)
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
    
    // Don't think we need the nil check anymore
    // Maybe it should be returning an optional if there was a bad character escape sequence
    // code != nil &&
    // if charCode == nil {
    //     throw syntaxError(
    //         source,
    //         position,
    //         "Bad character escape sequence."
    //     )
    // }
    while (
        position < body.characters.count &&
            code != 34 &&
            code != 10 && code != 13 && code != 0x2028 && code != 0x2029
        ) {
            position++
            if code == 92 { // \
                value += slice(body, start: chunkStart, position: position - 1)
                code = charCodeAt(body, position: position)
                switch code {
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
                        b: charCodeAt(body, position: position + 2),
                        c: charCodeAt(body, position: position + 3),
                        d: charCodeAt(body, position: position + 4)
                    )
                    value += String(Character(UnicodeScalar(charCode)))
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
            code = charCodeAt(body, position: position)
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

// TODO: Figure out which of these are needed
func uniCharCode(a: Int?, b: Int?, c: Int?, d: Int?) -> Int? {
    if let a = a, b = b, c = c, d = d {
        return a << 12 | b << 8 | c << 4 | d
    } else {
        return nil
    }
}

func uniCharCode(a: Int, b: Int, c: Int, d: Int) -> Int {
    return a << 12 | b << 8 | c << 4 | d
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