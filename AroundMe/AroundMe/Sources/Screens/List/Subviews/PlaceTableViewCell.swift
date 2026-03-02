//
//  PlaceTableViewCell.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 20.02.2026.
//

import UIKit
import Kingfisher

final class PlaceTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Label.Font.name
        label.textColor = Constant.Label.Color.name
        label.numberOfLines = Constant.Label.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Label.Font.adress
        label.textColor = Constant.Label.Color.adress
        label.numberOfLines = Constant.Label.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Label.Font.rating
        label.textColor = Constant.Label.Color.rating
        label.numberOfLines = Constant.Label.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = Constant.Label.Font.distance
        label.textColor = Constant.Label.Color.distance
        label.textAlignment = .right
        label.numberOfLines = Constant.Label.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var ratingAndDistanceHorizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ratingLabel, distanceLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var labelsVerticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            addressLabel,
            ratingAndDistanceHorizontalStackView
        ])
        stackView.axis = .vertical
        stackView.spacing = Constant.StackConstant.spacingForVStack
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var cellHorizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            iconImageView,
            labelsVerticalStackView
        ])
        stackView.axis = .horizontal
        stackView.spacing = Constant.StackConstant.spacingForHStack
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup / Configuration
    
    func configure(with place: PlaceModel) {
        nameLabel.text = place.name
        addressLabel.text = place.fullAddress
        ratingLabel.text = place.formattedRating
        distanceLabel.text = place.formattedDistance
        
        iconImageView.kf.setImage(
            with: place.iconURL,
            placeholder: UIImage(systemName: Constant.IconImage.placeHolderSystemImage)
        )
    }
    
    private func setupLayout() {
        contentView.addSubview(cellHorizontalStackView)
        
        NSLayoutConstraint.activate([
            cellHorizontalStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constant.StackConstant.Layout.verticalAnchor
            ),
            cellHorizontalStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constant.StackConstant.Layout.horizontalAnchor
            ),
            cellHorizontalStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constant.StackConstant.Layout.horizontalAnchor
            ),
            cellHorizontalStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constant.StackConstant.Layout.verticalAnchor
            ),
            
            iconImageView.widthAnchor.constraint(equalToConstant: Constant.IconImage.layoutSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constant.IconImage.layoutSize)
        ])
    }
}

// MARK: - Constants

private extension PlaceTableViewCell {
    enum Constant {
        enum Label {
            static let numberOfLines = 0
            
            enum Font {
                static let name: UIFont = .systemFont(ofSize: 16, weight: .bold)
                static let adress: UIFont = .systemFont(ofSize: 14, weight: .regular)
                static let rating: UIFont = .systemFont(ofSize: 14, weight: .semibold)
                static let distance: UIFont = .systemFont(ofSize: 14, weight: .light)
            }
            
            enum Color {
                static let name: UIColor = .label
                static let adress: UIColor = .secondaryLabel
                static let rating: UIColor = .systemOrange
                static let distance: UIColor = .lightGray
            }
        }
        
        enum StackConstant {
            static let spacingForVStack: CGFloat = 6.0
            static let spacingForHStack: CGFloat = spacingForVStack * 2
            
            enum Layout {
                static let verticalAnchor: CGFloat = 12.0
                static let horizontalAnchor: CGFloat = 16.0
            }
        }
        
        enum IconImage {
            static let placeHolderSystemImage = "arrow.down.circle.dotted"
            static let layoutSize: CGFloat = 40.0
        }
    }
}

