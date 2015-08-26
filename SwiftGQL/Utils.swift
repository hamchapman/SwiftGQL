//
//  Utils.swift
//  SwiftGQL
//
//  Created by Hamilton Chapman on 20/08/2015.
//  Copyright © 2015 hc.gg. All rights reserved.
//

import Foundation


func find<T>(list: [T], predicate: (item: T) -> Bool) -> T? {
    for (var i = 0; i < list.count; i++) {
        if (predicate(item: list[i])) {
            return list[i]
        }
    }
}

func invariant(condition: Bool, message: String) throws {
    if !condition {
    //  TODO: Probs remove
//      throw GraphQLError.Error(message: message)
        fatalError(message)
    }
}


// TODO: Maybe combine below functions into one with valFn as optional param
// although maybe clearer as two separate fns

/**
* Creates a keyed JS object from an array, given a function to produce the keys
* for each value in the array.
*
* This provides a convenient lookup for the array items if the key function
* produces unique results.
*
*     var phoneBook = [
*       { name: 'Jon', num: '555-1234' },
*       { name: 'Jenny', num: '867-5309' }
*     ]
*
*     // { Jon: { name: 'Jon', num: '555-1234' },
*     //   Jenny: { name: 'Jenny', num: '867-5309' } }
*     var entriesByName = keyMap(
*       phoneBook,
*       entry => entry.name
*     )
*
*     // { name: 'Jenny', num: '857-6309' }
*     var jennyEntry = entriesByName['Jenny']
*
*/
func keyMap<T>(list: [T], keyFn: (item: T) -> String) -> [String: T] {
    return list.reduce(
        [:],
        combine: { (var dict, e) in
            dict[keyFn(item: e)] = e
            return dict
        }
    )
}


/**
* Creates a keyed JS object from an array, given a function to produce the keys
* and a function to produce the values from each item in the array.
*
*     var phoneBook = [
*       { name: 'Jon', num: '555-1234' },
*       { name: 'Jenny', num: '867-5309' }
*     ]
*
*     // { Jon: '555-1234', Jenny: '867-5309' }
*     var phonesByName = keyValMap(
*       phoneBook,
*       entry => entry.name,
*       entry => entry.num
*     )
*
*/
func keyValMap<T, V>(list: [T], keyFn: (item: T) -> String, valFn: (item: T) -> V) -> [String: V] {
    return list.reduce(
        [:],
        combine: { (var dict, e) in
            dict[keyFn(item: e)] = valFn(item: e)
            return dict
        }
    )
}