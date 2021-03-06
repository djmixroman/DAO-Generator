//
//  ModelImplementationWriter.swift
//  DaoGenerator
//
//  Created by Andrei Rozhkov on 19/06/16.
//  Copyright © 2016 Redmadrobot. All rights reserved.
//

import Foundation


/**
 DataBase Implementation Writer
 */


class ModelImplementationWriter {

    // MARK: - Public

    /// Write Implementation
    ///
    /// - Parameters:
    ///   - klass: Klass to write
    ///   - klasses: All klasses
    ///   - projectName: name of project
    /// - Returns: content of file
    /// - Throws: exception
    internal func writeImplementation(
            klass: Klass,
            klasses: [Klass],
            projectName: String) throws -> String {
        let head: String = ""
                .addLine("//")
                .addLine("//  DB\(klass.name).swift")
                .addLine("//  \(projectName)")
                .addLine("//")
                .addLine("//  Created by Code Generator")
                .addLine("//  Copyright (c) 2017 Redmadrobot. All rights reserved.")
                .addLine("//")
                .addBlankLine()

        let headImports: String = head
                .addLine("import RealmSwift")
                .addBlankLine()
                .addBlankLine()

        var parentClassName = "RLMEntry"
        if let parentClass = klass.parents.first, parentClass != "Entity" {
            parentClassName = "DB\(parentClass)"
        }
        let headImportsModelObject: String = headImports
                .addLine("class DB\(klass.name): \(parentClassName) {")
                .addBlankLine()

        let properties: String = headImportsModelObject
                .append(try self.propertyLines(klasses: klasses, properties: klass.properties
                                .filter {
                            $0.realm()
                        })
                        .indent())
                .addBlankLine()

        return properties
                .addBlankLine()
                .addLine("}")
    }

}


private extension ModelImplementationWriter {

    func propertyLines(klasses: [Klass], properties: [Property]) throws -> String {
        return properties.reduce("") { (line: String, p: Property) -> String in
            let statement: String

            switch p.type {
            case .BoolType,
                 .IntType,
                 .FloatType,
                 .DoubleType,
                 .DateType,
                 .StringType,
                 .ObjectType,
                 .DataType:
                statement = statementForParameter(p, type: p.type)
            case .OptionalType(wrapped: let type):
                statement = statementForParameter(p, type: type)
            case .ArrayType(let objectType):
                switch objectType {
                case .ObjectType(let typename):
                    statement = "let \(p.name) = List<DB\(typename)>()"
                case .IntType:
                    statement = "let \(p.name) = List<Int>()"
                case .DateType:
                    statement = "let \(p.name) = List<Date>()"
                case .DataType:
                    statement = "let \(p.name) = List<Data>()"
                case .DoubleType:
                    statement = "let \(p.name) = List<Double>()"
                case .StringType:
                    statement = "let \(p.name) = List<String>()"
                case .FloatType:
                    statement = "let \(p.name) = List<Float>()"
                case .BoolType:
                    statement = "let \(p.name) = List<Bool>()"
                case .ArrayType, .MapType:
                    statement = "TODO"
                default:
                    fatalError()
                }
            default:
                fatalError()
            }

            return line.isEmpty ?
                    statement :
                    line
                        .addBlankLine()
                        .append(statement)
        }
    }


    private func statementForParameter(_ parameter: Property, type: Typê) -> String {
        var statement: String
        var defaultValue = ""

        switch type {
        case .BoolType:
            if type == parameter.type {
                statement = "@objc dynamic var \(parameter.name) = false"
            } else {
                statement = "let \(parameter.name) = RealmOptional<Bool>()"
            }
        case .IntType(let number):
            if type == parameter.type {
                statement = "@objc dynamic var \(parameter.name): \(parameter.type)\(number) = 0"
            } else {
                statement = "let \(parameter.name) = RealmOptional<Int\(number)>()"
            }
        case .FloatType:
            if type == parameter.type {
                statement = "@objc dynamic var \(parameter.name): Float = 0.0"
            } else {
                statement = "let \(parameter.name) = RealmOptional<Float>()"
            }
        case .DoubleType:
            if type == parameter.type {
                statement = "@objc dynamic var \(parameter.name): Double = 0.0"
            } else {
                statement = "let \(parameter.name) = RealmOptional<Double>()"
            }
        case .DateType:
            statement = "@objc dynamic var \(parameter.name): \(parameter.type.description)"
            defaultValue = "Date(timeIntervalSince1970: 1)"
        case .DataType:
            statement = "@objc dynamic var \(parameter.name): \(parameter.type.description)"
            defaultValue = "Data()"
        case .StringType:
            statement = "@objc dynamic var \(parameter.name): \(parameter.type.description)"
            defaultValue = "\"\""
        case .ObjectType:
            statement = "@objc dynamic var \(parameter.name): DB\(type)?"
            defaultValue = "nil"
        case .ArrayType(item: let t):
            switch t {
            case .ObjectType(let typename):
                statement = "let \(parameter.name) = List<DB\(typename)>()"
            case .IntType:
                statement = "let \(parameter.name) = List<Int>()"
            case .DateType:
                statement = "let \(parameter.name) = List<Date>()"
            case .DataType:
                statement = "let \(parameter.name) = List<Data>()"
            case .DoubleType:
                statement = "let \(parameter.name) = List<Double>()"
            case .StringType:
                statement = "let \(parameter.name) = List<String>()"
            case .FloatType:
                statement = "let \(parameter.name) = List<Float>()"
            case .BoolType:
                statement = "let \(parameter.name) = List<Bool>()"
            case .ArrayType, .MapType:
                statement = "TODO"
            default:
                fatalError()
            }
        default:
            fatalError()
        }

        switch parameter.type {
        case .OptionalType, .BoolType, .FloatType, .IntType, .DoubleType:
            break
        default:
            statement += " = \(defaultValue)"
        }

        return statement
    }


}
