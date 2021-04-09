//
//  Local Collection.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 12/26/20.
//

import FirebaseFirestore

// A type that can be initialized from a Firestore document.
protocol DocumentSerializable {
    init?(dictionary: [String: Any])
}

final class LocalCollection<T: DocumentSerializable> {
    private(set) var items: [T]
    private(set) var documents: [DocumentSnapshot] = []
    let query: Query
    
    private let updateHandler: ([DocumentChange]) -> Void
    
    private var listener: ListenerRegistration? {
        didSet {
            oldValue?.remove()
        }
    }
    
    var count: Int {
        return self.items.count
    }
    
    subscript(index: Int) -> T {
        return self.items[index]
    }
    
    init(query: Query, updateHandler: @escaping ([DocumentChange]) -> Void) {
        self.items = []
        self.query = query
        self.updateHandler = updateHandler
    }
    
    func index(of document: DocumentSnapshot) -> Int? {
        for index in 0 ..< documents.count {
            if documents[index].documentID == document.documentID {
                return index
            }
        }
        
        return nil
    }
    
    func listen() {
        guard listener == nil else { return }
        listener = query.addSnapshotListener { [unowned self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> T in
                if let model = T(dictionary: document.data()) {
                    return model
                } else {
                    // handle error
                    fatalError("Unable to initialize type \(T.self) with dictionary \(document.data())")
                }
            }
            self.items = models
            self.documents = snapshot.documents
            self.updateHandler(snapshot.documentChanges)
        }
    }
    
    func stopListening() {
        listener = nil
    }
    
    deinit {
        stopListening()
    }
}

extension UIView {
     func findCollectionView() -> UICollectionView? {
         if let collectionView = self as? UICollectionView {
             return collectionView
         } else {
             return superview?.findCollectionView()
         }
     }

     func findCollectionViewCell() -> UICollectionViewCell? {
         if let cell = self as? UICollectionViewCell {
             return cell
         } else {
             return superview?.findCollectionViewCell()
         }
     }

     func findCollectionViewIndexPath() -> IndexPath? {
         guard let cell = findCollectionViewCell(),
               let collectionView = cell.findCollectionView() else { return nil }

         return collectionView.indexPath(for: cell)
     }
      
      func findTableView() -> UITableView? {
          if let tableView = self as? UITableView {
              return tableView
          } else {
           return superview?.findTableView()
          }
      }

      func findTableViewCell() -> UITableViewCell? {
           if let cell = self as? UITableViewCell {
                return cell
           } else {
              return superview?.findTableViewCell()
           }
      }

      func findTableViewIndexPath() -> IndexPath? {
           guard let cell = findTableViewCell(),
                 let tableView = cell.findTableView() else { return nil }

           return tableView.indexPath(for: cell)
      }
     
     var parentViewController: UIViewController? {
             var parentResponder: UIResponder? = self
             while parentResponder != nil {
                 parentResponder = parentResponder!.next
                 if parentResponder is UIViewController {
                     return parentResponder as? UIViewController
                 }
             }
             return nil
         }
}
