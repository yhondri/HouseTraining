//
//  ExercisePickerTableViewController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 16/07/2020.
//

import UIKit

class ExercisePickerTableViewController: UITableViewController {
    private let viewModel = ExercisePickerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: viewModel.reuseIdentifier)
    }
}

// MARK: - Table view data source
extension ExercisePickerTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.exercises.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = viewModel.exercises[indexPath.row]
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
