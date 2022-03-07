//
//  SearchResultTableViewCell.swift
//  TwitterProject
//
//  Created by Amr Hossam on 18/02/2022.
//

import UIKit

enum FollowButtonStates: String {
    case follow = "Follow"
    case unfollow = "Unfollow"
}

class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultTableViewCell"
    private var userID: String?
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Follow", for: .normal)
        button.tintColor = .link
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1).cgColor
        button.layer.cornerRadius = 20
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(followButton)
        configureConstraints()
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
    }
    
    private func performFollow() {
        guard let userID = userID else {
            return
        }

        DatabaseManager.shared.dispatchFollowRequestFor(userID: userID) { [weak self] result in
            switch result {
            case .success():
                self?.configureButtonAsFollowed()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func performUnfollow() {
        guard let userID = userID else {
            return
        }

        DatabaseManager.shared.dispatchUnfollowRequestFor(userID: userID) { [weak self] result in
            switch result {
            case .success():
                self?.configureButtonAsNotFollowed()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func didTapFollowButton() {
        guard let state = followButton.titleLabel?.text else {return}
        switch state {
        case FollowButtonStates.follow.rawValue:
            performFollow()
            
        case FollowButtonStates.unfollow.rawValue:
            performUnfollow()
        default:
            fatalError()
        }
    }
    
    private func configureConstraints() {
        let userImageViewConstraints = [
            userImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.heightAnchor.constraint(equalToConstant: 50),
            userImageView.widthAnchor.constraint(equalToConstant: 50)
        ]
        
        let displayNameLabelConstraints = [
            displayNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 25),
            displayNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor)
        ]
        
        let usernameLabelConstraints = [
            usernameLabel.leadingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor, constant: 5),
            usernameLabel.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor)
        ]
        
        let followButtonConstraints = [
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 120),
            followButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(userImageViewConstraints)
        NSLayoutConstraint.activate(displayNameLabelConstraints)
        NSLayoutConstraint.activate(usernameLabelConstraints)
        NSLayoutConstraint.activate(followButtonConstraints)
    }
    
    private func configureButtonAsFollowed() {
        followButton.setTitle("Unfollow", for: .normal)
        followButton.tintColor = .white
        followButton.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        followButton.isHidden = false
    }
    
    private func configureButtonAsNotFollowed() {
        followButton.setTitle("Follow", for: .normal)
        followButton.tintColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        followButton.backgroundColor = .clear
        followButton.isHidden = false
    }
    
    func configureWith(model: SearchResultViewModel) {
        guard let url = URL(string: model.avatarPath) else {return}
        userImageView.sd_setImage(with: url)
        displayNameLabel.text = model.displayName
        usernameLabel.text = "@\(model.username)"
        userID = model.userID
        switch model.followState {
            case .owner:
                followButton.isHidden = true
            case .notFollowed:
                configureButtonAsNotFollowed()
            case .followed:
                configureButtonAsFollowed()

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
