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

