//
//  LibraryViewController.swift
//  MP Mini Library
//
//  Created by Bobby Tortorello on 12/27/20.
//

import UIKit
import MapKit
import FirebaseFirestore

class LibraryViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate {

     @IBOutlet var libraryNumberLabel: UILabel!
     @IBOutlet var libraryNameLabel: UILabel!
     @IBOutlet var libraryImageView: UIImageView!
     @IBOutlet var libraryLocationLabel: UILabel!
     @IBOutlet var libraryMapView: MKMapView!
     @IBOutlet var libraryAddressLabel: UILabel!
     
     @IBOutlet weak var bookButton: UIStepper!
     @IBOutlet var bookTableView: UITableView!
     var libraryNumber = String()
     
     var libraryAddress = String()
     let geoCoder = CLGeocoder()

     let db = Firestore.firestore()

     private var books : [Books] = []
     
     var locationManager = CLLocationManager()

     //ViewDidLoad()
     override func viewDidLoad() {
          super.viewDidLoad()
          
          bookTableView.delegate = self
          bookTableView.dataSource = self
          
          locationManager.delegate = self
          locationManager.requestWhenInUseAuthorization()
          locationManager.startUpdatingLocation()
          
          getData()
     }
     
     func getData() {
          if libraryNumber.count < 2 {
               let docRef = db.collection("miniLibraries").document("miniLibrary#0\(libraryNumber)")
               docRef.getDocument { (document, err) in
                    if let err = err {
                         print("Failure to get document: \(err)")
                    } else {
                         if let document = document, document.exists {
                              self.libraryNumberLabel.text = "Library Number \((document.get("number") as? String) ?? String())"
                              self.libraryNameLabel.text = (document.get("name") as? String)
                              self.libraryAddressLabel.text = (document.get("location") as? String)
                              self.libraryAddress = (document.get("location") as? String ?? String())
                              self.getLocation()
                         }
                    }
               }
               
               docRef.collection("books").getDocuments { (querySnapshot, err) in
                    if let err = err {
                         print("Could not get files: \(err)")
                    } else {
                         for document in querySnapshot!.documents {
                              let document = Books(dictionary: document.data())
                              self.books.append(document!)
                              print(self.books.count)
                              self.bookTableView.reloadData()
                         }
                    }
               }
          } else {
               let docRef = db.collection("miniLibraries").document("miniLibrary#\(libraryNumber)")
               docRef.getDocument { (document, err) in
                    if let err = err {
                         print("Failure to get document: \(err)")
                    } else {
                         if let document = document, document.exists {
                              self.libraryNumberLabel.text = "Library Number \((document.get("number") as? String) ?? String())"
                              self.libraryNameLabel.text = (document.get("name") as? String)
                              self.libraryAddressLabel.text = (document.get("location") as? String)
                              self.libraryAddress = (document.get("location") as? String ?? String())
                              self.getLocation()
                         }
                    }
               }
               
               docRef.collection("books").getDocuments { (querySnapshot, err) in
                    if let err = err {
                         print("Could not get files: \(err)")
                    } else {
                         for document in querySnapshot!.documents {
                              let document = Books(dictionary: document.data())
                              self.books.append(document!)
                              print(self.books.count)
                              self.bookTableView.reloadData()
                         }
                    }
               }
          }
     }
     
     func spaceInBetween() {
          self.geoCoder.geocodeAddressString(libraryAddress) { (placemarks, err) in
               if let err = err {
                    print(err)
               } else {
                    let libraryLocation = placemarks?.first?.location
                    let userLocation = self.libraryMapView.userLocation
                    
                    let distanceInM = userLocation.location?.distance(from: libraryLocation ?? CLLocation())
                    print(distanceInM!)
                    if distanceInM! > 160.934 {
                         let distanceInMi = distanceInM! / 1609.34
                         let simplifiedDistance = Double(round(100*distanceInMi)/100)
                         self.libraryLocationLabel.text = "The library is \(String(simplifiedDistance)) miles away from you."
                       
                    } else {
                         let distanceInFt = distanceInM! * 3.281
                         let simplifiedDistance = Double(round(100*distanceInFt)/100)
                         self.libraryLocationLabel.text = "The library is \(String(simplifiedDistance)) feet away from you."
                         
                         if distanceInFt < 1 {
                              let distanceInIn = 12 / distanceInFt
                              let simplifiedDistance = Double(round(100*distanceInIn)/100)
                              self.libraryLocationLabel.text = "The Library is \(String(simplifiedDistance)) inches away from you."
                              
                              if distanceInIn == 1 {
                                   self.libraryLocationLabel.text = "The Library is \(String(simplifiedDistance)) inch away from you."

                              }
                         }
                    }
                    
               }
          }
     }
     
     func getLocation() {
          // Setting MapView From Locatation Within Firebase
          self.geoCoder.geocodeAddressString(libraryAddress) { (placemarks, err) in
               if let err = err {
                    print(err)
                    
                    let alert = UIAlertController(title: "Sorry There Was a Problem Getting the Locaton", message: "Please Try Again Later", preferredStyle: .alert)
                    let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    let tryAgain = UIAlertAction(title: "Try Again", style: .default) { (action) in
                         self.getData()
                    }
                    alert.addAction(okay)
                    alert.addAction(tryAgain)
               } else {
                    let libraryLocation = placemarks?.first?.location
                    let center = libraryLocation?.coordinate
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: center!, span: span)
                    self.libraryMapView.setRegion(region, animated: false)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = libraryLocation?.coordinate ?? CLLocationCoordinate2D()
                    annotation.title = "Books: \(self.books.count)"
                    self.libraryMapView.addAnnotation(annotation)
                    self.spaceInBetween()
               }
          }
     }

     @IBAction func librariesButton(_ sender: UIBarButtonItem) {
          let vc =  storyboard?.instantiateViewController(identifier: "librariesVC")
          navigationController?.pushViewController(vc!, animated: false)
     }
     
     func loadingError() {
         let alert = UIAlertController(title: "Error loading", message: "Bobby sucks", preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
         present(alert, animated: true, completion: nil)
     }
}

// MARK: TableViewDataSource
extension LibraryViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          print("This is book count: \(books.count)")
          return books.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BooksTableViewCell
          let book = books[indexPath.row]
          cell.populate(book: book)
          return cell
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
     }
}

// MARK: TableViewCell Class
class BooksTableViewCell: UITableViewCell {
     
     @IBOutlet var bookTitleLabel: UILabel!
     @IBOutlet var bookAuthorLabel: UILabel!
     
     func populate(book: Books) {
          bookTitleLabel.text = "Title: \(book.title)"
          bookAuthorLabel.text = "By: \(book.author)"
     }
}
