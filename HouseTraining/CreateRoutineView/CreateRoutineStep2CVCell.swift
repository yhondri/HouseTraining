//
//  CreateRoutineStep2CVCell.swift
//  HouseTraining
//
//  Created by Yhondri Acosta Novas on 25/11/20.
//

import UIKit

class CreateRoutineStep2CVCell: UICollectionViewCell {
   private let exerciseNameLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    private let exerciseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ic_temp_activity")
        return imageView
    }()
    
    var exercise: Exercise! {
        didSet {
            exerciseNameLabel.text = exercise.actionName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stackView = UIStackView(arrangedSubviews: [exerciseImageView, exerciseNameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 10
        addSubview(stackView)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            exerciseImageView.heightAnchor.constraint(equalToConstant: 40),
            exerciseImageView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
