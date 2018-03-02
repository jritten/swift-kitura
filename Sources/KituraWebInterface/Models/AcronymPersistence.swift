/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CouchDB
import SwiftyJSON

extension Acronym {
  
  class Persistence {
    
    static func getAll(from database: Database, callback: @escaping (_ acronyms: [Acronym]?, _ error: NSError?) -> Void) {
      database.retrieveAll(includeDocuments: true) { documents, error in
        guard let documents = documents else {
          callback(nil, error)
          return
        }
        var acronyms: [Acronym] = []
        for document in documents["rows"].arrayValue {
          let id = document["id"].stringValue
          let short = document["doc"]["short"].stringValue
          let long = document["doc"]["long"].stringValue
          
          if let acronym = Acronym(id: id, short: short, long: long) {
            acronyms.append(acronym)
          }
        }
        callback(acronyms, nil)
      }
    }
    
    static func save(_ acronym: Acronym, to database: Database, callback: @escaping (_ acronymID: String?, _ error: NSError?) -> Void) {
      getAll(from: database) { acronyms, error in
        guard let acronyms = acronyms else {
          return callback(nil, error)
        }
        guard !acronyms.contains(acronym) else {
          return callback(nil, NSError(domain: "Kitura-TIL", code: 400, userInfo: ["localizedDescription": "Duplicate entry"]))
        }
        database.create(JSON(["short": acronym.short, "long": acronym.long])) { id, _, _, error in
          callback(id, error)
        }
      }
    }
    
    static func get(from database: Database, with id: String, callback: @escaping (_ acronym: Acronym?, _ error: NSError?) -> Void) {
      database.retrieve(id) { document, error in
        guard let document = document else {
          return callback(nil, error)
        }
        guard let acronym = Acronym(id: document["_id"].stringValue, short: document["short"].stringValue, long: document["long"].stringValue) else {
          return callback(nil, error)
        }
        callback(acronym, nil)
      }
    }
    
    static func delete(with id: String, from database: Database, callback: @escaping (_ error: NSError?) -> Void) {
      database.retrieve(id) { document, error in
        guard let document = document else {
          return callback(error)
        }
        let id = document["_id"].stringValue
        let revision = document["_rev"].stringValue
        database.delete(id, rev: revision) { error in
          callback(error)
        }
      }
    }
  }
}

