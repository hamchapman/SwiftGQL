//
//  GraphQL.swift
//  SwiftGQL
//
//  Created by Hamilton Chapman on 13/09/2015.
//  Copyright © 2015 hc.gg. All rights reserved.
//

import Foundation

func graphql(schema: SchemaDocument, requestString: String, rootValue, variableValues, operationName) {
    return new _Promise(function (resolve) {
        var source = new _languageSource.Source(requestString || "", "GraphQL request")
        var documentAST = (0, _languageParser.parse)(source)
        var validationErrors = (0, _validationValidate.validate)(schema, documentAST)
        if (validationErrors.length > 0) {
            resolve({ errors: validationErrors })
        } else {
            resolve((0, _executionExecute.execute)(schema, documentAST, rootValue, variableValues, operationName))
        }
        })['catch'](function (error) {
            return { errors: [error] }
        })
}