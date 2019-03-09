//
//  URLManager.swift
//  BrowserApp
//
//  Created by Shahen on 3/8/19.
//  Copyright © 2019 Shahen. All rights reserved.
//

import Foundation

@objc enum Status : Int {
    case Reachable
    case NotReachable
    case Loading
    case Unknown
}

enum SortType {
    case Declining
    case Growing
}

protocol URLManagerDelegate: class {
    func didUpdateStatus()
}

class URLManager {
    
    var urls = [String]()
    var urlStatus = [String : Status]()
    var urlTimes = [String: Int]()
    var sortType: SortType = .Growing
    var beginTime : DateComponents!
    var endTime: DateComponents!
    
    weak var delegate : URLManagerDelegate?
    
    init() {
        refreshStatus()
    }
    
    func sortUrlsByName() {
        if sortType == .Growing {
            urls.sort(by: >)
        } else {
            urls.sort(by: <)
        }
    }
    
    func sortByReachability() {
        urls.sort { (item1, item2) -> Bool in
            var check1: Int = 0
            var check2: Int = 0
            if urlStatus[item1] != nil, urlStatus[item1] == .Reachable {
                check1 = 1
            }
            if urlStatus[item2] != nil, urlStatus[item2] == .Reachable {
                check2 = 1
            }
            if sortType == .Declining {
                return check1 < check2
            }
            
            return check1 > check2
        }
    }
    
    func sortByTimeInterval() {
        urls.sort { (item1, item2) -> Bool in
            if sortType == .Growing && urlTimes[item1] != nil && urlTimes[item2] != nil {
                return urlTimes[item1]! > urlTimes[item2]!
            } else if sortType == .Declining && urlTimes[item1] != nil && urlTimes[item2] != nil  {
                return urlTimes[item1]! < urlTimes[item2]!
            }
            return false
            
        }
    }
    
    func refreshStatus() {
        
        for url in urls {
            urlStatus[url] = .Unknown
            urlTimes[url] = 0
        }
        
        self.delegate?.didUpdateStatus()
        self.urls = DBManager.sharedInstance.getDataFromDB()
        
        for url in urls {
            checkWebSite(urlString: url) { (resp) in
                if resp {
                    self.urlStatus[url] = .Reachable
                } else {
                    self.urlStatus[url] = .NotReachable
                }
                
                self.urlTimes[url] = self.countTimeInterval(begin: self.beginTime, end: self.endTime)
                
                self.delegate?.didUpdateStatus()
            }
        }
    }
    
    func addURL(url: String) {
       // urls.append(url)
        checkWebSite(urlString: url) { (resp) in
            if resp {
                self.urlStatus[url] = .Reachable
            } else {
                self.urlStatus[url] = .NotReachable
            }
            self.urlTimes[url] = self.countTimeInterval(begin: self.beginTime, end: self.endTime)
            
            DispatchQueue.main.async {
                let model = UrlModel()
                model.url = url
                DBManager.sharedInstance.addData(object: model)
                self.urls = DBManager.sharedInstance.getDataFromDB()
            }
            
            self.delegate?.didUpdateStatus()
        }
    }
    
    func deleteURL(index:Int) {
        self.urlStatus.removeValue(forKey: self.urls[index])
        let model = UrlModel()
        model.url = self.urls[index]
        DBManager.sharedInstance.deleteFromDb(index: index)
        urls.remove(at: index)
    }
    
    func checkWebSite(urlString: String,completion: @escaping (Bool) -> Void ) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 2.0
        self.urlStatus[urlString] = .Loading
        
        let calendar = Calendar.current
        beginTime = calendar.dateComponents([.hour,.minute,.second], from: Date())
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                self.endTime = calendar.dateComponents([.hour,.minute,.second], from: Date())
                completion(false)
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                self.endTime = calendar.dateComponents([.hour,.minute,.second], from: Date())
                completion(true)
            }
        }
        
        task.resume()
    }
    
    func countTimeInterval(begin: DateComponents, end: DateComponents) -> Int {
        let seconds = (end.minute! - begin.minute!) * 60 + end.second! - begin.second!
        return seconds
    }
    
}


