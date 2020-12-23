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
        titleLabel.textColor = .itemTextColor
        return titleLabel
    }()
    
    private let exerciseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var exercise: Exercise! {
        didSet {
            exerciseNameLabel.text = exercise.actionName
            exerciseImageView.image = UIImage(named: exercise.imageName)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let imageContentView = UIView()
        imageContentView.translatesAutoresizingMaskIntoConstraints = false
        imageContentView.addSubview(exerciseImageView)
        imageContentView.backgroundColor = UIColor.charBarBottomColor
        imageContentView.layer.cornerRadius = 20
        imageContentView.layer.masksToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [imageContentView, exerciseNameLabel])
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
            imageContentView.heightAnchor.constraint(equalToConstant: 40),
            imageContentView.widthAnchor.constraint(equalToConstant: 40),
            exerciseImageView.leadingAnchor.constraint(equalTo: imageContentView.leadingAnchor, constant: 5),
            exerciseImageView.topAnchor.constraint(equalTo: imageContentView.topAnchor, constant: 5),
            exerciseImageView.trailingAnchor.constraint(equalTo: imageContentView.trailingAnchor, constant: -5),
            exerciseImageView.bottomAnchor.constraint(equalTo: imageContentView.bottomAnchor, constant: -5)
        ])
        
        backgroundColor = .itemBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
