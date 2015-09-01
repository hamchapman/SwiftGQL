//
//  Error.swift
//  SwiftGQL
//
//  Created by Hamilton Chapman on 20/08/2015.
//  Copyright © 2015 hc.gg. All rights reserved.
//

import Foundation

class GraphQLError {
    // TODO: remove forced unwrapped optionals
    
    let message: String
    let stack: String
    let nodes: [Node]?
    let source: Source
    let positions: [Int]
    let locations: [SourceLocation]?
    
    init(message: String, nodes: [Node]?, stack: String?, source: Source?, positions: [Int]?) {
        self.message = message
        
        if let source = source {
            self.source = source
            
            if let positions = positions {
                self.locations = positions.map({ getLocation(source, position: $0) })
            }
        } else {
            self.locations = nil
            if let nodes = nodes where nodes.count > 0 {
                let node = nodes[0]
                self.source = node.loc!.source!
            }
        }
        if let nodes = nodes {
            self.nodes = nodes
        }
        
        if let stack = stack {
            self.stack = stack
        } else {
            self.stack = message
        }
        
        if let positions = positions {
            self.positions = positions
        } else {
            if let nodes = nodes {
                let nodePositions = nodes.map({ $0.loc!.start })
                self.positions = nodePositions
            }
        }
    }
}

struct BaseError {
    let message: String?
    let stack: String?
}

enum GraphQLErrorType: ErrorType {
    case LocatedError(error: BaseError?, nodes: [AnyObject])
    case SyntaxError(source: Source, position: Int, description: String)
    // TODO: Probs remove
//    case Error(message: String)
}


/**
* Given a GraphQLError, format it according to the rules described by the
* Response Format, Errors section of the GraphQL Specification.
*/
func formatError(error: GraphQLError) -> GraphQLFormattedError {
    invariant(error, "Received null or undefined error.")
    if error.locations != nil {
        return GraphQLFormattedError(message: error.message, locations: error.locations.map({ GraphQLErrorLocation($0.line, $0.column) }))
    } else {
        return GraphQLFormattedError(message: error.message, locations: nil)
    }
}

struct GraphQLFormattedError {
    let message: String
    let locations: [GraphQLErrorLocation]?
};

struct GraphQLErrorLocation {
    let line: Int
    let column: Int
};

/**
* Given an arbitrary Error, presumably thrown while attempting to execute a
* GraphQL operation, produce a new GraphQLError aware of the location in the
* document responsible for the original Error.
*/
func locatedError(error: BaseError?, nodes: [Node]) -> GraphQLError {
    let message = (error != nil) ?
        error!.message ?? String(error) :
        "An unknown error occurred."
    let stack = error?.stack
    return GraphQLError(message: message, nodes: nodes, stack: stack, source: nil, positions: nil)
}


/**
* Produces a GraphQLError representing a syntax error, containing useful
* descriptive information about the syntax error's position in the source.
*/
func syntaxError(source: Source, position: Int, description: String) -> GraphQLError {
    let location = getLocation(source, position: position)
    let error = GraphQLError(
        message: "Syntax Error \(source.name) (\(location.line):\(location.column)) " +
        description + "\n\n" + highlightSourceAtLocation(source, location: location),
        nodes: nil,
        stack: nil,
        source: source,
        positions: [position]
    )
    return error
}

/**
* Render a helpful description of the location of the error in the GraphQL
* Source document.
*/
func highlightSourceAtLocation(source: Source, location: SourceLocation) -> String {
    var line = location.line
    var prevLineNum = "\(line - 1)"
    var lineNum = "\(line)"
    var nextLineNum = "\(line + 1)"
    var padLen = nextLineNum.characters.count
    // TODO: More regex
    var lines = source.body.split(/\r\n|[\n\r\u2028\u2029]/g)
    return (
        (line >= 2 ?
        lpad(padLen, str: prevLineNum) + ": " + lines[line - 2] + "\n" : "") +
        lpad(padLen, str: lineNum) + ": " + lines[line - 1] + "\n" +
        Array(count: 1 + padLen + location.column, repeatedValue: " ").joinWithSeparator("") +
        (line < lines.length ?
        lpad(padLen, nextLineNum) + ": " + lines[line] + "\n" : "")
    );
}

func lpad(len: Int, str: String) -> String {
    return Array(count: len - str.characters.count, repeatedValue: " ").joinWithSeparator("") + str
}