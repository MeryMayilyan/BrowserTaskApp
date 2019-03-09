//
//  URLViewController.swift
//  BrowserApp
//
//  Created by Shahen on 3/8/19.
//  Copyright © 2019 Shahen. All rights reserved.
//

import UIKit

class URLViewController: UIViewController {
    
    @IBOutlet weak var urlSearchBar: UISearchBar!
    @IBOutlet weak var urlListTableView: UITableView!
    @IBOutlet var sortButtons: [UIButton]!
    @IBOutlet weak var sortTypeSwitch: UISwitch!
    
    var manager = URLManager()
    var isSearchActive = false
    var filtered:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupDelegates()
    }

    func setupDelegates() {
        urlListTableView.delegate = self
        urlListTableView.dataSource = self
        urlSearchBar.delegate = self
        manager.delegate = self
    }
    
    @IBAction func sortTypeSwitch(_ sender: UISwitch) {
        if sortTypeSwitch.isOn {
            manager.sortType = .Growing
        } else {
            manager.sortType = .Declining
        }
    }
    
    @IBAction func sortByNameAction(_ sender: UIButton) {
        manager.sortUrlsByName()
        urlListTableView.reloadData()
    }
    
    @IBAction func sortByReachabilityAction(_ sender: UIButton) {
        manager.sortByReachability()
        urlListTableView.reloadData()
    }
    
    @IBAction func sortByTimeAction(_ sender: UIButton) {
        manager.sortByTimeInterval()
        urlListTableView.reloadData()
    }
    
    func setupUI() {
        for button in sortButtons {
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1.0
            button.layer.cornerRadius = 10
            urlListTableView.layer.cornerRadius = 10
            urlListTableView.layer.borderWidth = 1.0
            urlListTableView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBAction func refrreshButtonAction(_ sender: UIButton) {
        manager.refreshStatus()
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        if let text = urlSearchBar.text {
            if text != " " && text != "" {
                manager.addURL(url: text)
                urlSearchBar.resignFirstResponder()
                urlListTableView.reloadData()
            }
        }
    }
    
}

//MARK: - TableView delegation methods

extension URLViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filtered.count
        }
        return manager.urls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "urlCell") as! URLTableViewCell
        if isSearchActive {
            cell.urlNameLabel.text = filtered[indexPath.row]
            if manager.urlStatus[filtered[indexPath.row]] == .Reachable {
                cell.isReachableView.backgroundColor = UIColor.green
                cell.loadingIndicatorView.isHidden = true
            } else if manager.urlStatus[filtered[indexPath.row]] == .NotReachable {
                cell.isReachableView.backgroundColor = UIColor.red
                cell.loadingIndicatorView.isHidden = true
            } else if manager.urlStatus[filtered[indexPath.row]] == .Unknown {
                cell.isReachableView.backgroundColor = UIColor.white
                cell.loadingIndicatorView.isHidden = true
            } else {
                cell.isReachableView.backgroundColor = UIColor.white
                cell.loadingIndicatorView.isHidden = false
            }
        } else {
            cell.urlNameLabel.text = manager.urls[indexPath.row]
            if manager.urlStatus[manager.urls[indexPath.row]] == .Reachable {
                cell.isReachableView.backgroundColor = UIColor.green
                cell.loadingIndicatorView.isHidden = true
            } else if manager.urlStatus[manager.urls[indexPath.row]] == .NotReachable {
                cell.isReachableView.backgroundColor = UIColor.red
                cell.loadingIndicatorView.isHidden = true
            } else if manager.urlStatus[manager.urls[indexPath.row]] == .Unknown {
                cell.isReachableView.backgroundColor = UIColor.white
                cell.loadingIndicatorView.isHidden = true
            } else {
                cell.isReachableView.backgroundColor = UIColor.white
                cell.loadingIndicatorView.isHidden = false
            }
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            manager.deleteURL(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}

//MARK: - SearchBar delegation methods

extension URLViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearchActive = false
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtered = manager.urls.filter({ (text) -> Bool in
            let tmp : NSString = text as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if(filtered.count == 0) {
            isSearchActive = false;
        } else {
            isSearchActive = true;
        }
        self.urlListTableView.reloadData()
    }
    
}

//MARK: - URLManagerDelegate methods

extension URLViewController: URLManagerDelegate {
    
    func didUpdateStatus() {
        DispatchQueue.main.async {
            self.urlListTableView.reloadData()   //UI updates must be in main thread
        }
    }
    
}
