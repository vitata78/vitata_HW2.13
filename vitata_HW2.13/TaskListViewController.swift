//
//  TaskListViewController.swift
//  vitata_HW2.13
//
//  Created by Andrew Tolstov on 7/1/20.
//

import UIKit


class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        tasks = StorageManager.shared.fetchData()
        tableView.reloadData()
        
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
   
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        
        saveAlert(with: "New Task", and: "What do you want to do?")
        
    }
    
    private func saveAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text else { return }
            StorageManager.shared.saveTask(name: taskName)
            guard let newTask = StorageManager.shared.fetchData().last else { return }
            self.tasks.append(newTask)
            let indexPath = IndexPath(row: self.tasks.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        saveAction.isEnabled = false
        
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in

            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    saveAction.isEnabled = textIsNotEmpty
                
            })
        }
        
        present(alert, animated: true)
    }
    
    private func editAlert(with title: String, and message: String, and id: Int) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            self.tasks[id].name = taskName
            StorageManager.shared.saveContext()
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(editAction)
        editAction.isEnabled = false
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            
            textField.text = self.tasks[id].name
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    editAction.isEnabled = textIsNotEmpty && textField.text != self.tasks[id].name
                
            })
        }
        
        present(alert, animated: true)
    }

}

// MARK: - Table view data source

extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = tasks[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        editAlert(with: "Edit Task", and: "Click Update once finished", and: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        StorageManager.shared.deleteTask(task: tasks[indexPath.row])
        tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}
