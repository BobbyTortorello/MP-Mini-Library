//
//  LibraryViewController.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 12/26/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import MapKit

class LibrariesViewController: UIViewController, UITableViewDelegate {

     @IBOutlet var libraryTableView: UITableView!
     
     private var libraires: [Library] = []
     
     var library: Library?
     
     let firestore = Firestore.firestore()
          
     @IBOutlet weak var filterOptions: UIPickerView!
               
     override func viewDidLoad() {
     super.viewDidLoad()
          libraryTableView.delegate = self
          libraryTableView.dataSource = self
          getData()
                    
          filterOptions.isHidden = true
     }
     
     func getData() {
          firestore.collection("miniLibraries").getDocuments { (querySnapshot, err) in
               if let err = err {
                    print("Could not get files: \(err)")
               } else {
                    for document in querySnapshot!.documents {
                         let document = Library(dictionary: document.data())
                         self.libraires.append(document!)
                         print(self.libraires.count)
                         self.libraryTableView.reloadData()
                    }
               }
          }
     }
     
     @IBAction func librairesButton(_ sender: UIBarButtonItem) {
          libraires.removeAll()
          getData()
     }
     
     @IBAction func filterButton(_ sender: UIBarButtonItem) {
          
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          let nvc = segue.destination as? LibraryViewController
          let indexPath = libraryTableView.indexPathForSelectedRow
          nvc!.libraryNumber = libraires[(indexPath?.row)!].number
          print(libraires[(indexPath?.row)!].number)
     }
}

// MARK: TableView Functions
extension LibrariesViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return libraires.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LibraryTableViewCell
          let library = libraires[indexPath.row]
          cell?.populate(library: library)
          return cell ?? LibraryTableViewCell()
     }
}

// MARK: TableViewCell Class
class LibraryTableViewCell: UITableViewCell {
     
     @IBOutlet var libraryNumberLabel: UILabel!
     @IBOutlet var libraryAddressLabel: UILabel!
     @IBOutlet var libraryDistanceLabel: UILabel!
     
     func populate(library: Library) {
          libraryNumberLabel.text = "Library Number \(library.number)"
          libraryAddressLabel.text = library.location
          libraryDistanceLabel.text = "Distance Away from User 0.5 Miles"
     }
}
