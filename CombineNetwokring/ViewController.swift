//
//  ViewController.swift
//  CombineNetwokring
//
//  Created by Marin Tutuc on 05.02.2023.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    // Store cancellables to prevent retain cycles
    private var cancelables = Set<AnyCancellable>()
    // Store fetched data items
    private var items = [Datum]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch user data when the view is loaded
        fetchUsers()
    }

    private func fetchUsers() {

        // URL for the API request
        let url = "https://reqres.in/api/users"

        // Query parameters for the API request
        let query = ["page": "1"]

        // Make the API request using the network manager
        NetworkManager.shared.request(url, method: .get, query: query, responseType: Page.self)
            // Receive response on the main thread
            .receive(on: RunLoop.main)
            // Subscribe to the response using sink
            .sink { completition in

                // Handle completion of the API request
            switch completition {
                case .finished: print("RESPONSE: Finished")
                case .failure(let error): print("RESPONSE: Error - " + error.localizedDescription)
            }

        } receiveValue: { response in
            
            // Update the items array with the fetched data
            self.items = response.response?.data ?? []
            
            // Reload the table view data
            self.tableView.reloadData()
        }
        // Store the cancellable in the cancelables set
        .store(in: &cancelables)
    }

}

// Extension to conform to UITableViewDelegate and UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Returns the number of rows in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    // Configures the cell for a given index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")!
        let item = items[indexPath.row]
        
        // Set the text label and detail text label of the cell
        cell.textLabel?.text = item.fullname
        cell.detailTextLabel?.text = item.email
        
        return cell
    }
    
    // Handles the selection of a table view cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        // Deselect the selected cell
        cell?.setSelected(false, animated: true)
    }
}
