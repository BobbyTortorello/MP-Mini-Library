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
import CoreData

class LibrariesViewController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate {
// MARK: Variables
     @IBOutlet var libraryTableView: UITableView!
     @IBOutlet weak var favoritesCollectionView: UICollectionView!
     private var libraires: [Library] = []
     private var books: [Books] = []
     
     var favorites = [String]()
     @IBOutlet weak var favoriteNumberImageView: UIImageView!
     
     var library: Library?
     
     let firestore = Firestore.firestore()
     let geoCoder = CLGeocoder()
     let locationManager = CLLocationManager()
     
     var libraryDistance = Double()
     var libraryIndicator = Int()
     
     let userDefaults = UserDefaults.standard
     let favorite = Bool()
     
     private let spacing:CGFloat = 16.0
    
     override func viewDidLoad() {
     super.viewDidLoad()
          libraryTableView.delegate = self
          libraryTableView.dataSource = self
          favoritesCollectionView.delegate = self
          favoritesCollectionView.dataSource = self
          
          favorites.removeAll()
          getData()
          
          locationManager.delegate = self
          locationManager.requestWhenInUseAuthorization()
          locationManager.startUpdatingLocation()
          
          libraryTableView.reloadData()
          favoritesCollectionView.reloadData()
     }
     
// MARK: Custom Functions
     func moveTableView() {
          let simplifiedFavorites = favorites.uniqued()
          if simplifiedFavorites.count >= 1 {
               libraryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 213.5).isActive = true
               print("This works")
          }
          if simplifiedFavorites.count == 0 {
               libraryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 66.5).isActive = true
          }
     }
     
     func addFavorites(libraryNumber: String) {
          favorites.append(libraryNumber)
          favoritesCollectionView.reloadData()
     }
     
     func getData() {
          libraires.removeAll()
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
     
// MARK: Library Button
     @IBAction func librairesButton(_ sender: UIBarButtonItem) {
          libraires.removeAll()
          getData()
          moveTableView()
          favoritesCollectionView.reloadData()
          libraryTableView.reloadData()
     }
     
     @IBAction func filterButton(_ sender: UIBarButtonItem) {
          
     }
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          switch segue.identifier {
          case "collectionView":
               guard let indexPath = (sender as? UIView)?.findCollectionViewIndexPath() else { return }
               guard let nvc = segue.destination as? LibraryViewController else { return }
               nvc.libraryNumber = favorites[indexPath.row]
          default: return
          }
          
          switch segue.identifier {
          case "tableView":
               guard let indexPath = libraryTableView.indexPathForSelectedRow else {return}
               guard let nvc = segue.destination as? LibraryViewController else {return}
               nvc.libraryNumber = libraires[indexPath.row].number
          default: return
          }
     }
}

// MARK: TableView Datasource
extension LibrariesViewController: UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return libraires.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LibraryTableViewCell
          let library = libraires[indexPath.row]
          cell?.populate(library: library)
          cell?.favorite()
          
          if userDefaults.bool(forKey: "favorite-\(library.number)") == true {
               addFavorites(libraryNumber: library.number)
               moveTableView()
               favoritesCollectionView.reloadData()
          }
          
          if libraryIndicator == 1 {
               cell?.libraryDistanceLabel.text = "The library is \(String(libraryDistance)) miles away from you."
          }
          if libraryIndicator == 2 {
               cell?.libraryDistanceLabel.text = "The library is \(String(libraryDistance)) feet away from you."
          }
          if libraryIndicator == 3 {
               cell?.libraryDistanceLabel.text = "The Library is \(String(libraryDistance)) inches away from you."
          }
          
          return cell ?? LibraryTableViewCell()
     }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          guard let cell = libraryTableView.cellForRow(at: indexPath) else { return }
          performSegue(withIdentifier: "tableView", sender: cell)
     }
}

// MARK: CollectionView DataSource
extension LibrariesViewController: UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          let simplifiedFavorites = favorites.uniqued()
          return simplifiedFavorites.count
     }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? FavoriteCollectionViewCell
          let simplifiedFavorites = favorites.uniqued()
          cell?.populate(libraryNumber: simplifiedFavorites[indexPath.row])
          return cell ?? FavoriteCollectionViewCell()
     }
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          guard let cell = favoritesCollectionView.cellForItem(at: indexPath) else { return }
          performSegue(withIdentifier: "collectionView", sender: cell)
     }
}

// MARK: Array Extension
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

// MARK: TableViewCell Class
class LibraryTableViewCell: UITableViewCell {
     @IBOutlet var libraryNumberLabel: UILabel!
     @IBOutlet var libraryAddressLabel: UILabel!
     @IBOutlet var libraryDistanceLabel: UILabel!
     @IBOutlet var booksAvailableLabel: UILabel!
     @IBOutlet var favoriteButton: UIButton!
     let userDefaults = UserDefaults.standard
     
     func populate(library: Library) {
          libraryNumberLabel.text = "\(library.number)"
          libraryAddressLabel.text = library.location
          booksAvailableLabel.text = "Number of Books at Library: \(library.books)"
     }
     
     func favorite() {
          if userDefaults.bool(forKey: "favorite-\(libraryNumberLabel.text!)") == true {
               favoriteButton.setImage(#imageLiteral(resourceName: "favoriteFilled"), for: .normal)
          } else {
               favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
          }
     }
    
     @IBAction func favoriteButtonAct(_ sender: UIButton) {
          if favoriteButton.currentImage == #imageLiteral(resourceName: "favorite") {
               favoriteButton.setImage(#imageLiteral(resourceName: "favoriteFilled"), for: .normal)
               userDefaults.set(true, forKey: "favorite-\(libraryNumberLabel.text!)")
               let alert = UIAlertController(title: "Library Number \(libraryNumberLabel.text!)",
                                             message: "Added to Favorites! :)", preferredStyle: .actionSheet)
               parentViewController?.present(alert, animated: true, completion: nil)
               let secondsToDelay = 1.5
               DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                    self.parentViewController?.dismiss(animated: true, completion: nil)
                    self.parentViewController?.viewDidLoad()
               }
          } else {
               favoriteButton.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
               userDefaults.setValue(false, forKey: "favorite-\(libraryNumberLabel.text!)")
               let alert = UIAlertController(title: "Library Number \(libraryNumberLabel.text!)",
                                             message: "Has Been Removed from Favorites! :(", preferredStyle: .actionSheet)
               parentViewController?.present(alert, animated: true, completion: nil)
               let secondsToDelay = 1.5
               DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                    self.parentViewController?.dismiss(animated: true, completion: nil)
                    self.parentViewController?.viewDidLoad()
               }
          }
     }
}

// MARK: CollectionViewCell Class
class FavoriteCollectionViewCell: UICollectionViewCell {
     @IBOutlet weak var favoriteImageView: UIImageView!
     
     func populate(libraryNumber: String) {
          favoriteImageView.image = UIImage(named: "LibraryNumber\(libraryNumber)")
     }
}

//If Looking for UIView Extension go to Local_Collection
