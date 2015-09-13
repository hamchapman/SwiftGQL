// **Visitor**

//let QueryDocumentKeys = [
//    "Name": [],
//
//    "Document": ["definitions"],
//    "OperationDefinition": ["name", "variableDefinitions", "directives", "selectionSet"],
//    "VariableDefinition": ["variable", "type", "defaultValue"],
//    "Variable": ["name"],
//    "SelectionSet": ["selections"],
//    "Field": ["alias", "name", "arguments", "directives", "selectionSet"],
//    "Argument": ["name", "value"],
//
//    "FragmentSpread": ["name", "directives"],
//    "InlineFragment": ["typeCondition", "directives", "selectionSet"],
//    "FragmentDefinition": ["name", "typeCondition", "directives", "selectionSet"],
//
//    "IntValue": [],
//    "FloatValue": [],
//    "StringValue": [],
//    "BooleanValue": [],
//    "EnumValue": [],
//    "ListValue": ["values"],
//    "ObjectValue": ["fields"],
//    "ObjectField": ["name", "value"],
//
//    "Directive": ["name", "arguments"],
//
//    "NamedType": ["name"],
//    "ListType": ["type"],
//    "NonNullType": ["type"]
//]
//
//// TODO: sort out what BREAK is
//let BREAK = {}
//

// TODO: Add in things from SCHEMA
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


///**
//* visit() will walk through an AST using a depth first traversal, calling
//* the visitor's enter function at each node in the traversal, and calling the
//* leave function after visiting that node and all of it's child nodes.
//*
//* By returning different values from the enter and leave functions, the
//* behavior of the visitor can be altered, including skipping over a sub-tree of
//* the AST (by returning false), editing the AST by returning a value or null
//* to remove the value, or to stop the whole traversal by returning BREAK.
//*
//* When using visit() to edit an AST, the original AST will not be modified, and
//* a new version of the AST with the changes applied will be returned from the
//* visit function.
//*
//*     var editedAST = visit(ast, {
//*       enter(node, key, parent, path, ancestors) {
//*         // @return
//*         //   undefined: no action
//*         //   false: skip visiting this node
//*         //   visitor.BREAK: stop visiting altogether
//*         //   null: delete this node
//*         //   any value: replace this node with the returned value
//*       },
//*       leave(node, key, parent, path, ancestors) {
//*         // @return
//*         //   undefined: no action
//*         //   false: no action
//*         //   visitor.BREAK: stop visiting altogether
//*         //   null: delete this node
//*         //   any value: replace this node with the returned value
//*       }
//*     });
//*
//* Alternatively to providing enter() and leave() functions, a visitor can
//* instead provide functions named the same as the kinds of AST nodes, or
//* enter/leave visitors at a named key, leading to four permutations of
//* visitor API:
//*
//* 1) Named visitors triggered when entering a node a specific kind.
//*
//*     visit(ast, {
//*       Kind(node) {
//*         // enter the "Kind" node
//*       }
//*     })
//*
//* 2) Named visitors that trigger upon entering and leaving a node of
//*    a specific kind.
//*
//*     visit(ast, {
//*       Kind: {
//*         enter(node) {
//*           // enter the "Kind" node
//*         }
//*         leave(node) {
//*           // leave the "Kind" node
//*         }
//*       }
//*     })
//*
//* 3) Generic visitors that trigger upon entering and leaving any node.
//*
//*     visit(ast, {
//*       enter(node) {
//*         // enter any node
//*       },
//*       leave(node) {
//*         // leave any node
//*       }
//*     })
//*
//* 4) Parallel visitors for entering and leaving nodes of a specific kind.
//*
//*     visit(ast, {
//*       enter: {
//*         Kind(node) {
//*           // enter the "Kind" node
//*         }
//*       },
//*       leave: {
//*         Kind(node) {
//*           // leave the "Kind" node
//*         }
//*       }
//*     })
//*/
//func visit(root: Node, visitor: Visitor, keyMap: [String:[String]]?) -> SchemaDocument {
//    var visitorKeys = keyMap ?? QueryDocumentKeys
//
//    var stack: Stack? = nil
//
//
//    // TODO: Work out how to check if root is an array of some sort
//    var inArray: Bool
////    var inArray: Bool = Array.isArray(root)
//
//    var keys: [AnyObject] = [root] // can be node, string
//    var index = -1
//    // TODO: Figure out something better than AnyObjects
//    var edits: [Edit] = []
//    var parent: Node?
//    var path: [AnyObject] = [] // Seems to be Ints or Strings
//    var ancestors: [Node] = []
//    var newRoot = root
//
//    repeat {
//        index++
//        var isLeaving = index == keys.count
//        var key: AnyObject?
//        var node: Node?
//        var isEdited = isLeaving && edits.count != 0
//        if isLeaving {
//            key = ancestors.count == 0 ? nil : path.popLast()
//            node = parent
//            parent = ancestors.popLast()
//            if isEdited {
//                let nodeCopy = node
//                node = nodeCopy
//                // TODO: Figure out if I need any of this - if a node is a Struct with only value types inside of it then I don't think I do
//                // Basically it's doing a deep clone / copy
////                if inArray {
////                    let nodeCopy = node
////                    node = nodeCopy
////                } else {
////                    var clone = {}
////                    for (var k in node) {
////                        if (node.hasOwnProperty(k)) {
////                            clone[k] = node[k]
////                        }
////                    }
////                    node = clone
////                }
//
//                var editOffset = 0
//                for (var ii = 0; ii < edits.count; ii++) {
//                    if let editKey = edits[ii].key as? Int {
//                        let editValue = edits[ii].value
//                        var edKey = editKey
//                        if inArray {
//                            edKey -= editOffset
//                        }
//                        if inArray && editValue == nil {
//                            node.removeAtIndex(edKey)
//                            node.splice(edKey, 1)
//                            editOffset++
//                        } else {
//                            node[edKey] = editValue
//                        }
//                    }
//                }
//            }
//            if let stackCopy = stack {
//                index = stackCopy.index
//                keys = stackCopy.keys
//                edits = stackCopy.edits
//                inArray = stackCopy.inArray
//                stack = stackCopy.prev
//            }
//        } else {
//            key = parent != nil ? inArray ? index : keys[index] : nil
//            node = parent != nil ? parent[key] : newRoot
//            if node == nil {
//                continue
//            }
//            if let key = key where parent != nil {
//                path.append(key)
//            }
//        }
//
//        var result: AnyObject
//        if !Array.isArray(node) {
//            if !isNode(node) {
//                // TODO: Might need to do my own serialization of the node
//                throw Error("Invalid AST Node: " + JSONStringify(node))
//            }
//            var visitFn = getVisitFn(visitor, isLeaving, node.kind)
//            if visitFn {
//                result = visitFn.call(visitor, node, key, parent, path, ancestors)
//
//                if result == BREAK {
//                    break
//                }
//
//                if result == false {
//                    if !isLeaving {
//                        path.popLast()
//                        continue
//                    }
//                } else if result != nil {
//                    edits.append([ key, result ])
//                    if !isLeaving {
//                        if isNode(result) {
//                            node = result
//                        } else {
//                            path.popLast()
//                            continue
//                        }
//                    }
//                }
//            }
//        }
//
//        if result == nil && isEdited {
//            edits.append([ key, node ])
//        }
//
//        if !isLeaving {
//            stack = Stack(inArray: inArray, index: index, keys: keys, edits: edits, prev: stack)
//            inArray = Array.isArray(node)
//            keys = inArray ? node : visitorKeys[node!.kind] ?? []
//            index = -1
//            edits = []
//            if let parent = parent {
//                ancestors.append(parent)
//            }
//            parent = node
//        }
//    } while stack != nil
//
//    if edits.count != 0 {
//        newRoot = edits[0][1]
//    }
//
//    return newRoot
//}
//
//struct Edit {
//    let key: AnyObject?
//    let value: AnyObject?
//}
//
//struct Key {
//
//}
//
//struct Visitor {
//    func enter(node: Node, key: Key?, parent: Node?, path: [AnyObject]?, ancestors: [AnyObject]?) {
//    }
//
//    func leave(node: Node, key: Key?, parent: Node?, path: [AnyObject]?, ancestors: [AnyObject]?) {
//    }
//}
//
//func JSONStringify(value: AnyObject) -> String? {
//    if NSJSONSerialization.isValidJSONObject(value) {
//        do {
//            let data = try NSJSONSerialization.dataWithJSONObject(value, options: [])
//            if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
//                return string as String
//            }
//        } catch _ {
//            // TODO: Figure out what I'm doing here
//        }
//    }
//    return nil
//}
//
//struct Stack {
//    var inArray: Bool
//    var index: Int
//    var keys: [AnyObject]
//    var edits: []
//    var prev: Stack
//}
//
//func isNode(maybeNode: Node?) -> Bool {
//    if let node = maybeNode {
//        return node.kind == "string"
//    } else {
//        return false
//    }
////    return maybeNode != nil && maybeNode.kind == "string"
//}
//
//func getVisitFn(visitor: Visitor, isLeaving: Bool, kind: String) -> Visitor? {
//    var kindVisitor = visitor[kind]
//    if kindVisitor {
//        if !isLeaving && typeof kindVisitor == "function" {
//            // { Kind() {} }
//            return kindVisitor
//        }
//        var kindSpecificVisitor = isLeaving ? kindVisitor.leave : kindVisitor.enter
//        if typeof kindSpecificVisitor == "function" {
//            // { Kind: { enter() {}, leave() {} } }
//            return kindSpecificVisitor
//        }
//        return nil
//    }
//    var specificVisitor = isLeaving ? visitor.leave : visitor.enter
//    if specificVisitor {
//        if typeof specificVisitor == "function") {
//            // { enter() {}, leave() {} }
//            return specificVisitor
//        }
//        var specificKindVisitor = specificVisitor[kind];
//        if typeof specificKindVisitor == "function" {
//            // { enter: { Kind() {} }, leave: { Kind() {} } }
//            return specificKindVisitor
//        }
//    }
//}
//
