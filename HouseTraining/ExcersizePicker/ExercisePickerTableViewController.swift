//
//  ExercisePickerTableViewController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit

class ExercisePickerTableViewController: UITableViewController {

    private let reuseIdentifier = "CellReuseIdentifier"
    private lazy var exercises = ["Jumping Jacks", "Abdominal Crunches"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exercises.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = exercises[indexPath.row]
        return cell
    }
}

// MARK: - Table view delegate
extension ExercisePickerTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = SetupViewController()
        navigationController?.pushViewController(view, animated: true)
    }
}
