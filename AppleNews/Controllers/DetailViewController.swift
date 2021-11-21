//
//  DetailViewController.swift
//  AppleNews
//
//  Created by jazeps.ivulis on 20/11/2021.
//

import UIKit
import SDWebImage
import CoreData

class DetailViewController: UIViewController {

    var savedItems = [Items]()
    var context: NSManagedObjectContext?
    var webUrlString = String()
    var titleString = String()
    var contentString = String()
    var newsImage = String()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleString
        contentTextView.text = contentString
        newsImageView.sd_setImage(with: URL(string: newsImage), placeholderImage: UIImage(named: "news.png"))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - Saving data
    func saveData() {
        do {
            try context?.save()
            basicAlert(title: "Article saved!", message: "Please, go to \"Saved articles\" tab bar to see your saved articles.")
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Save button action
    @IBAction func saveButtonTapped(_ sender: Any) {
        let newItem = Items(context: context!)
        newItem.newsTitle = titleString
        newItem.newsContent = contentString
        newItem.url = webUrlString
        newItem.image = newsImage
        
        savedItems.append(newItem)
        saveData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC: WebViewController = segue.destination as! WebViewController
        destinationVC.urlString = webUrlString
    }
}
