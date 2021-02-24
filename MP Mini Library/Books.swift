//
//  Books.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 1/11/21.
//

import Foundation
import Firebase

struct Books {
     var title: String
     var author: String
     
     var dicitionaryString: [String:Any] {
          return [
               "title": title,
               "author": author
          ]
     }
}

extension Books: DocumentSerializable {
     init?(dictionary: [String : Any]) {
          guard let title = dictionary["title"] as? String,
                let author = dictionary["author"] as? String else {return nil}
     
     self.init(
          title: title,
          author: author
          )
     }
}
