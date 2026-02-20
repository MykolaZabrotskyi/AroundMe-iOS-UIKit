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
    
    private lazy var labelsVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameLabel, addressLabel, ratingLabel])
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
        addressLabel.text = place.fullAddress.isEmpty ? "Address not available" : place.fullAddress
        
        if let rating = place.rating {
            ratingLabel.text = "★ \(String(format: "%.1f", rating))"
        } else {
            ratingLabel.text = "No rating"
        }
        
        iconImageView.kf.setImage(
            with: place.iconURL,
            placeholder: UIImage(systemName: Constants.iconImage.placeHolderSystemImage)
        )
    }
    
    private func setupLayout() {
        contentView.addSubview(cellHStackView)
        
        NSLayoutConstraint.activate([
            cellHStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cellHStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellHStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellHStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

private extension PlaceTableViewCell {
    
    enum Constants {
        
        enum Labels {
            static let numberOfLines: Int = 0
            
            enum EmptyText {
                static let adress: String = ""
            }
            
            enum Fonts {
                static let name: UIFont = .systemFont(ofSize: 16, weight: .bold)
                static let adress: UIFont = .systemFont(ofSize: 14, weight: .regular)
                static let rating: UIFont = .systemFont(ofSize: 14, weight: .semibold)
            }
            
            enum Colors {
                static let name: UIColor = .label
                static let adress: UIColor = .secondaryLabel
                static let rating: UIColor = .systemOrange
            }
        }
        
        enum StackConstants {
            static let spacingForVStack: CGFloat = 6
            static let spacingForHStack: CGFloat = spacingForVStack * 2
        }
        
        enum iconImage {
            static let placeHolderSystemImage = "arrow.down.circle.dotted"
        }
    }
}

