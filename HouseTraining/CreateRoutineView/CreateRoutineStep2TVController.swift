//
//  CreateRoutineStep2TVController.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 24/11/20.
//
// El código referente a la funcionalidad drag and drop procede de la respuesta de Vasily Bodnarchuk en https://stackoverflow.com/questions/39080807/drag-and-reorder-uicollectionview-with-sections

import UIKit
import SwiftUI

enum CellModel {
    case simple(exercise: Exercise)
    case availableToDrop
}

class CreateRoutineStep2TVController: UIViewController {
    
    private let reuseIdentifier = "CellReuseIdentifier"
    private lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: getLayout())    
    private let exercises: [Exercise]
    private let sections = 1
    private let itemsInSection: Int
    
    private lazy var data: [[CellModel]] = {
        var count = 0
        return (0 ..< sections).map { _ in
            return (0 ..< itemsInSection).map { _ -> CellModel in
                let value = CellModel.simple(exercise: exercises[count])
                count += 1
                return value
            }
        }
    }()
    
    init(exercises: [Exercise]) {
        itemsInSection =  exercises.count
        self.exercises = exercises
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .tableViewBackgroundColor
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
        collectionView.dataSource = self
        
        let nextButton = UIButton(type: .system)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle(LocalizableKey.next.localized, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.backgroundColor = .buttonMainColor
        nextButton.addTarget(self, action: #selector(goToNextView), for: .touchUpInside)
        nextButton.layer.cornerRadius = 12
        nextButton.layer.masksToBounds = true
        nextButton.addLeftPadding(35)
        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func getLayout() -> UICollectionViewCompositionalLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: size)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        section.interGroupSpacing = 0
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    @objc private func goToNextView() {
        let exercises = data[0].compactMap { (cellModel) -> Exercise? in
            switch cellModel {
            case .simple(let exercise):
                return exercise
            default:
                break
            }
            return nil
        }
        let createRoutineStep3ViewModel = CreateRoutineStep3ViewModel(exercises: exercises)
        let hostingController = UIHostingController(rootView: CreateRoutineStep3View(createRoutineViewModel: createRoutineStep3ViewModel))
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension CreateRoutineStep2TVController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch data[indexPath.section][indexPath.item] {
        case .simple(let exercise):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CreateRoutineStep2CVCell
            cell.exercise = exercise
            return cell
        case .availableToDrop:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CreateRoutineStep2CVCell
            cell.isHidden = true //Hide weird animation
            return cell
        }
    }
}

// MARK: - UICollectionViewDragDelegate
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

// MARK: - UICollectionViewDropDelegate
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
        guard items.count == 1, let item = items.first,
              let sourceIndexPath = item.sourceIndexPath,
              let localObject = item.dragItem.localObject as? CellModel else { return }
        
        collectionView.performBatchUpdates ({
            data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
            data[destinationIndexPath.section].insert(localObject, at: destinationIndexPath.item)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
        })
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
    typealias UIViewControllerType = CreateRoutineStep2TVController
    var exercises: [Exercise]
    
    func makeUIViewController(context: Context) -> CreateRoutineStep2TVController {
        return CreateRoutineStep2TVController(exercises: exercises)
    }
    
    func updateUIViewController(_ uiViewController: CreateRoutineStep2TVController, context: Context) {}
}


extension UIButton {
    func addLeftPadding(_ padding: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: padding, bottom: 0.0, right: padding)
    }
}
