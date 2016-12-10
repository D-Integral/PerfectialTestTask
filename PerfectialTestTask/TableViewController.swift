//
//  TableViewController.swift
//  PerfectialTestTask
//
//  Created by Dmytro Skorokhod on 12/9/16.
//  Copyright © 2016 Dmytro Skorokhod. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UITextFieldDelegate {
	
	var hits: [[String: Any]] = []
	var textField = UITextField()
	var lastLoadedPage = 1

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier:"reuseIdentifier")
		self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier:"searchCellIdentifier")

		self.clearsSelectionOnViewWillAppear = true
		
		self.requestImages(searchString: "", page: 1)
    }
	
	func requestImages(searchString: String, page: Int) {
		let url = URL(string: "https://pixabay.com/api/?key=3777329-97c398c7e896d9c63f6ef1c0b&per_page=200&q="+searchString + "&page=" + String(page))
		URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
			guard let data = data, error == nil else { return }
			
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
				
				if page>1 && page>self.lastLoadedPage {
					self.hits += json["hits"] as? [[String: Any]] ?? []
					self.lastLoadedPage = page
				} else if page == 1 {
					self.hits = json["hits"] as? [[String: Any]] ?? []
				}
				
				var index = 0
				for hit: Dictionary in self.hits {
					print(index)
					for key in hit.keys {
						print(key, ":", hit[key]! as Any)
					}
					print("\n")
					index += 1
				}
				
				DispatchQueue.main.sync {
					self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet,
					                              with: .none)
				}
			} catch let error as NSError {
				print(error)
			}
		}).resume()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0 == section ? 1 : self.hits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if 0 == indexPath.section {
			let cell = tableView.dequeueReusableCell(withIdentifier: "searchCellIdentifier", for: indexPath)
			
			let tableViewWidth = self.tableView.frame.size.width
			cell.contentView.addSubview(self.textField)
			self.textField.frame = CGRect(x: 15,
			                              y: 5,
			                              width: tableViewWidth - 30,
			                              height: 40)
			self.textField.placeholder = "Search"
			self.textField.delegate = self
			
			return cell
		}
		
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		
		DispatchQueue.global(qos: .userInitiated).async {
			let url = URL(string: self.hits[indexPath.row]["previewURL"] as! String)
			if let data = NSData(contentsOf: url!) {
				DispatchQueue.main.async {
					cell.imageView?.image = UIImage(data: data as Data)
					cell.layoutSubviews()
				}
			}
		}

        return cell
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 0 == indexPath.section ? 50 : self.hits[indexPath.row]["previewHeight"] as! CGFloat
	}
	
    // MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let viewController = DetailsViewController()
		
		DispatchQueue.global(qos: .userInitiated).async {
			let url = URL(string: self.hits[indexPath.row]["webformatURL"] as! String)
			if let data = NSData(contentsOf: url!) {
				DispatchQueue.main.sync {
					viewController.imageView.image = UIImage(data: data as Data)
					viewController.imageView.frame.size.width = self.hits[indexPath.row]["webformatWidth"] as! CGFloat
					viewController.imageView.frame.size.height = self.hits[indexPath.row]["webformatHeight"] as! CGFloat
				}
			}
		}
		
		self.navigationController?.pushViewController(viewController,
		                                              animated:true)
	}

	// MARK: - Text field delegate
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		self.requestImages(searchString: self.textField.text!,
		                   page: 1)
		return true
	}
	
	// MARK: - Scroll view delegate
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		print("scrollViewDidScroll")
		
		let actualPosition = scrollView.contentOffset.y;
		let loadMorePoint = scrollView.contentSize.height - self.tableView.frame.size.height * 2;
		
		if (actualPosition > loadMorePoint && self.textField.text == "") {
			print("new items should be loaded")
			self.requestImages(searchString: self.textField.text!,
			                   page: self.lastLoadedPage + 1)
		}
	}
}
