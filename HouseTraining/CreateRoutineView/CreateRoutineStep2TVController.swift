//
//  CreateRoutineStep2TVController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 24/11/20.
//

import UIKit
import SwiftUI

enum CellModel {
    case simple(text: String)
    case availableToDrop
}

class CreateRoutineStep2TVController: UIViewController {
    
    private let reuseIdentifier = "CellReuseIdentifier"
    private lazy var collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
//    private lazy var dataSource = makeDataSource()
    private var exercises = Exercise.getAvaialableExercises()
    private let sections = 1
    private let itemsInSection: Int
    
    private lazy var data: [[CellModel]] = {
        var count = 0
        return (0 ..< sections).map { _ in
            return (0 ..< itemsInSection).map { _ -> CellModel in
                count += 1
                return .simple(text: "cell \(count)")
            }
        }
    }()
    
    init() {
        itemsInSection =  exercises.count
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CreateRoutineStep2CVCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.dragInteractionEnabled = true
        collectionView.reorderingCadence = .fast
        collectionView.dropDelegate = self
        collectionView.dragDelegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
//        updateList()
    }
    
//    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Exercise> {
//        UICollectionView.CellRegistration { cell, indexPath, exercise in
//            // Configuring each cell's content:
//            var config = cell.defaultContentConfiguration()
//            config.text = exercise.actionName
//            cell.contentConfiguration = config
//        }
//    }
//
//    func makeDataSource() -> UICollectionViewDiffableDataSource<CVSection, Exercise> {
//        let cellRegistration = makeCellRegistration()
//
//        return UICollectionViewDiffableDataSource<CVSection, Exercise>(
//            collectionView: collectionView,
//            cellProvider: { view, indexPath, item in
//                view.dequeueConfiguredReusableCell(
//                    using: cellRegistration,
//                    for: indexPath,
//                    item: item
//                )
//            }
//        )
//    }
//
//    func updateList() {
//        var snapshot = NSDiffableDataSourceSnapshot<CVSection, Exercise>()
//        snapshot.appendSections(CVSection.allCases)
//        snapshot.appendItems(exercises, toSection: .favorites)
//        dataSource.apply(snapshot)
//    }
}

extension CreateRoutineStep2TVController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch data[indexPath.section][indexPath.item] {
        case .simple(let text):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CreateRoutineStep2CVCell
            cell.hourlabel.text = text
            return cell
        case .availableToDrop:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CreateRoutineStep2CVCell
            cell.backgroundColor = UIColor.green.withAlphaComponent(0.3)
            return cell
        }
    }
}


extension CreateRoutineStep2TVController: UICollectionViewDelegate { }

extension CreateRoutineStep2TVController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = data[indexPath.section][indexPath.row]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = data[indexPath.section][indexPath.row]
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        var itemsToInsert = [IndexPath]()
        (0 ..< data.count).forEach {
            itemsToInsert.append(IndexPath(item: data[$0].count, section: $0))
            data[$0].append(.availableToDrop)
        }
        collectionView.insertItems(at: itemsToInsert)
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        var removeItems = [IndexPath]()
        for section in 0..<data.count {
            for item in  0..<data[section].count {
                switch data[section][item] {
                case .availableToDrop: removeItems.append(IndexPath(item: item, section: section))
                case .simple: break
                }
            }
        }
        removeItems.forEach { data[$0.section].remove(at: $0.item) }
        collectionView.deleteItems(at: removeItems)
    }
}

extension CreateRoutineStep2TVController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        switch coordinator.proposal.operation {
            case .move:
                reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
            case .copy:
                copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            default: return
        }
    }

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool { return true }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag, let destinationIndexPath = destinationIndexPath {
            switch data[destinationIndexPath.section][destinationIndexPath.row] {
                case .simple:
                    return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
                case .availableToDrop:
                    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
        } else { return UICollectionViewDropProposal(operation: .forbidden) }
    }

    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        if  items.count == 1, let item = items.first,
            let sourceIndexPath = item.sourceIndexPath,
            let localObject = item.dragItem.localObject as? CellModel {

            collectionView.performBatchUpdates ({
                data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
                data[destinationIndexPath.section].insert(localObject, at: destinationIndexPath.item)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
        }
    }

    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated() {
                if let localObject = item.dragItem.localObject as? CellModel {
                    let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                    data[indexPath.section].insert(localObject, at: indexPath.row)
                    indexPaths.append(indexPath)
                }
            }
            collectionView.insertItems(at: indexPaths)
        })
    }
}
struct CreateRoutineStep2ControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> CreateRoutineStep2TVController {
        //        var sb = UIStoryboard(name: "Main", bundle: nil)
        //        var vc = sb.instantiateViewController(identifier: "MasterViewController") as! MasterViewController
        return CreateRoutineStep2TVController()
    }
    
    func updateUIViewController(_ uiViewController: CreateRoutineStep2TVController, context: Context) {
    }
    
    typealias UIViewControllerType = CreateRoutineStep2TVController
}


class CreateRoutineStep2CVCell: UICollectionViewCell {
    let hourlabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.text = "00:00"
        titleLabel.textColor = .blue
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(hourlabel)
                
        NSLayoutConstraint.activate([
            hourlabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            hourlabel.topAnchor.constraint(equalTo: topAnchor),
            hourlabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            hourlabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
