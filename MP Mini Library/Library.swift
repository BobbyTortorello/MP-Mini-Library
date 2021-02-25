//
//  Library.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 12/26/20.
//

import Foundation
import Firebase

struct Library {
     var number: String
     var name: String
     var location: String
     var books: String
     
     var dicitionaryString: [String: Any] {
          return [
               "number": number,
               "name": name,
               "location": location,
               "numberOfBooks": books
          ]
     }
}

extension Library: DocumentSerializable {
     init?(dictionary: [String: Any]) {
          guard let number = dictionary["number"] as? String,
                let name = dictionary["name"] as? String,
                let location = dictionary["location"] as? String,
                let books = dictionary["numberOfBooks"] as? String else {return nil}
     
     self.init(
          number: number,
          name: name,
          location: location,
          books: books
          )
     }
}
