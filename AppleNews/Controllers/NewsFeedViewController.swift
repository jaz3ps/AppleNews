//
//  NewsFeedViewController.swift
//  AppleNews
//
//  Created by jazeps.ivulis on 19/11/2021.
//

import UIKit
import SDWebImage

class NewsFeedViewController: UIViewController {
    
    var newsItems: [NewsItem] = []
    var searchResult = "apple"

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var apiKey = "7289e9f7edeb4a19bd148dfa514a7fcb"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Apple news"
        handleGetData()
    }

    //MARK: - Refresh data button action
    @IBAction func refreshDataTapped(_ sender: Any) {
        activityIndicator(animated: true)
        handleGetData()
    }
    
    
    @IBAction func newsFeedInfo(_ sender: Any) {
        basicAlert(title: "Apple news feed info", message: "In this section you will find latest articles about Apple, sorted by popularity.\nPress on \"refresh\" 🔄 button to reload the articles.")
    }
    
    //MARK: - Activity indicator
    func activityIndicator(animated: Bool){
        DispatchQueue.main.async {
            if animated{
                self.activityIndicatorView.isHidden = false
                self.activityIndicatorView.startAnimating()
            }else{
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
            }
        }
    }

    //MARK: - Get data
    func handleGetData(){
        activityIndicator(animated: true)
        let jsonUrl = "https://newsapi.org/v2/everything?q=\(searchResult)&from=2021-11-21&to=2021-11-05&sortBy=popularity&apiKey=\(apiKey)"
        
        guard let url = URL(string: jsonUrl) else {return}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        URLSession(configuration: config).dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print((error?.localizedDescription)!)
                self.basicAlert(title: "Error!", message: "\(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let data = data else {
                self.basicAlert(title: "Error!", message: "Something went wrong, no data.")
                return
            }
            
            do{
                let jsonData = try JSONDecoder().decode(Articles.self, from: data)
                self.newsItems = jsonData.articles
                DispatchQueue.main.async {
                    print("self.newsItems:", self.newsItems)
                    self.tblView.reloadData()
                    self.activityIndicator(animated: false)
                }
            }catch{
                print("err:", error)
            }
            
        }.resume()
    }
}

extension NewsFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "appleCell", for: indexPath) as? NewsTableViewCell else {return UITableViewCell()}
        
        let item = newsItems[indexPath.row]
        cell.newsTitleLabel.text = item.title
        cell.newsTitleLabel.numberOfLines = 0
        cell.newsImageView.sd_setImage(with:URL(string: item.urlToImage), placeholderImage: UIImage(named: "news.png"))
        
        return cell
    }
    
    //MARK: - Row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //MARK: - Navigate to article preview
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let vc = storybord.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let item = newsItems[indexPath.row]
        vc.newsImage = item.urlToImage
        vc.titleString = item.title
        vc.webUrlString = item.url
        vc.contentString = item.description
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
