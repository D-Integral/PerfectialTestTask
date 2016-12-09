//
//  TableViewController.swift
//  PerfectialTestTask
//
//  Created by Dmytro Skorokhod on 12/9/16.
//  Copyright © 2016 Dima Skorokhod. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
	
	var hits: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "reuseIdentifier")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		let url = URL(string: "https://pixabay.com/api/?key=3777329-97c398c7e896d9c63f6ef1c0b&per_page=200")
		URLSession.shared.dataTask(with:url!, completionHandler: {(data, response, error) in
			guard let data = data, error == nil else { return }
			
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
				self.hits = json["hits"] as? [[String: Any]] ?? []
				var index = 0
				for hit: Dictionary in self.hits {
					print(index)
					for key in hit.keys {
						print(key, ":", hit[key]! as Any)
					}
					print("\n")
					index += 1
				}
				
				self.tableView.reloadData()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		
		DispatchQueue.global(qos: .userInitiated).async {
			let url = URL(string: self.hits[indexPath.row]["previewURL"] as! String)
			if let data = NSData(contentsOf: url!) {
				DispatchQueue.main.sync {
					cell.imageView?.image = UIImage(data: data as Data)
					cell.layoutSubviews()
				}
			}
		}

        return cell
    }

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.hits[indexPath.row]["previewHeight"] as! CGFloat
	}
	
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
	
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

}
