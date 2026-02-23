//
//  PlaceTableViewCell.swift
//  AroundMe
//
//  Created by Mykola Zabrotskyi on 20.02.2026.
//

import UIKit
import Kingfisher

final class PlaceTableViewCell: UITableViewCell {
    
    static let identifier = "PlaceTableViewCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Labels.Fonts.name
        label.textColor = Constants.Labels.Colors.name
        label.numberOfLines = Constants.Labels.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Labels.Fonts.adress
        label.textColor = Constants.Labels.Colors.adress
        label.numberOfLines = Constants.Labels.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Labels.Fonts.rating
        label.textColor = Constants.Labels.Colors.rating
        label.numberOfLines = Constants.Labels.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.Labels.Fonts.distance
        label.textColor = Constants.Labels.Colors.distance
        label.textAlignment = .right
        label.numberOfLines = Constants.Labels.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var ratingAndDistanceHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ratingLabel, distanceLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var labelsVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, addressLabel, ratingAndDistanceHStackView])
        stackView.axis = .vertical
        stackView.spacing = Constants.StackConstants.spacingForVStack
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var cellHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, labelsVStackView])
        stackView.axis = .horizontal
        stackView.spacing = Constants.StackConstants.spacingForHStack
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with place: PlaceModel) {
        nameLabel.text = place.name
        addressLabel.text = place.fullAddress.isEmpty ? Constants.Labels.EmptyText.adress : place.fullAddress
        
        if let rating = place.rating {
            ratingLabel.text = "★ " + String(format: "%.1f", rating)
        } else {
            ratingLabel.text = Constants.Labels.EmptyText.rating
        }
        
        if let distance = place.distance {
            if distance < 1000 {
                distanceLabel.text = String((Int(distance))) + " m"
            } else {
                let kilometers = distance / 1000.0
                distanceLabel.text = String(format: "%.1f", kilometers) + " km"
            }
        } else {
            distanceLabel.text = Constants.Labels.EmptyText.distance
        }
        
        iconImageView.kf.setImage(
            with: place.iconURL,
            placeholder: UIImage(systemName: Constants.iconImage.placeHolderSystemImage)
        )
    }
    
    private func setupLayout() {
        contentView.addSubview(cellHStackView)
        
        NSLayoutConstraint.activate([
            
            cellHStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.StackConstants.Layout.verticalAnchor
            ),
            cellHStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.StackConstants.Layout.horizontalAnchor
            ),
            cellHStackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.StackConstants.Layout.horizontalAnchor
            ),
            cellHStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constants.StackConstants.Layout.verticalAnchor
            ),
            
            iconImageView.widthAnchor.constraint(equalToConstant: Constants.iconImage.layoutSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Constants.iconImage.layoutSize)
        ])
    }
}

private extension PlaceTableViewCell {
    
    enum Constants {
        
        enum Labels {
            static let numberOfLines: Int = 0
            
            enum EmptyText {
                static let adress: String = "Address not available"
                static let rating: String = "Rating not available"
                static let distance: String = "Distance not available"
            }
            
            enum Fonts {
                static let name: UIFont = .systemFont(ofSize: 16, weight: .bold)
                static let adress: UIFont = .systemFont(ofSize: 14, weight: .regular)
                static let rating: UIFont = .systemFont(ofSize: 14, weight: .semibold)
                static let distance: UIFont = .systemFont(ofSize: 14, weight: .light)
            }
            
            enum Colors {
                static let name: UIColor = .label
                static let adress: UIColor = .secondaryLabel
                static let rating: UIColor = .systemOrange
                static let distance: UIColor = .lightGray
            }
        }
        
        enum StackConstants {
            static let spacingForVStack: CGFloat = 6.0
            static let spacingForHStack: CGFloat = spacingForVStack * 2
            
            enum Layout {
                static let verticalAnchor: CGFloat = 12.0
                static let horizontalAnchor: CGFloat = 16.0
            }
        }
        
        enum iconImage {
            static let placeHolderSystemImage: String = "arrow.down.circle.dotted"
            static let layoutSize: CGFloat = 40.0
        }
    }
}

