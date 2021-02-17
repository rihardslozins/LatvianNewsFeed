//
//  ViewController.swift
//  LatvianNewsFeed
//
//  Created by Rihards Lozins on 17/02/2021.
//

import UIKit
import Gloss

class NewsFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Latest News"
    }
    
    @IBAction func getDataTapped(_ sender: Any) {
        handleGetData()
    }
    
    func handleGetData(){
        
        let jsonUrl = "https://newsapi.org/v2/top-headlines?country=lv&apiKey=520229ef18f146318b265616167eaa3d"
        
        guard let url = URL(string: jsonUrl) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            
            if let err = error {
                print("Error: \(err.localizedDescription)")
            }
            
            guard let data = data else {
                print("Data error")
                return
            }
            
            do{
                
                if let dictData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                    print("dictData", dictData)
                    self.populateData(dictData)
                }
                
            }catch{
                print("Error when converting Json")
            }
        }
        task.resume()
    }
    
    func populateData(_ dict: [String: Any]){
        guard let responseDict = dict["articles"] as? [Gloss.JSON] else {
            return
        }
        
        items = [Item].from(jsonArray: responseDict) ?? []
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension NewsFeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as? NewsTableViewCell else { return UITableViewCell() }
        
        //        cell.textLabel?.text = items[indexPath.row].title
        //        cell.detailTextLabel?.text = items[indexPath.row].description
        
        let item = items[indexPath.row]
        
        if let image = item.image {
            cell.newsImageView.image = image
        }
        cell.newsTitleLabel.text = item.title
        cell .newsTitleLabel.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let vc = storyboard.instantiateViewController(identifier: "DetailViewController") as? DetailViewController else {
            
            return
        }
        
        vc.contentString = items[indexPath.row].description
        vc.titleString = items[indexPath.row].title
        vc.webURLString = items[indexPath.row].url
        vc.newsImage = items[indexPath.row].image
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

