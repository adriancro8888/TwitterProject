//
//  ProfileTableHeaderView.swift
//  TwitterProject
//
//  Created by Amr Hossam on 14/02/2022.
//

import UIKit
import FirebaseAuth

protocol ProfileTableHeaderViewDelegate: AnyObject {
    func profileTableHeaderViewDidTapEditProfile(_ header: ProfileTableHeaderView)
}

class ProfileTableHeaderView: UIView {
    
    internal weak var delegate: ProfileTableHeaderViewDelegate?
    
    var isOwner: Bool?
    var userID: String?
    
    private let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.tintColor = .link
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1).cgColor
        button.layer.cornerRadius = 20
        return button
    }()
    
    private let followersCountTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Followers"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let followersCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    
    private let followingCountTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Following"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        guard let url = URL(string: "https://cdn.pixabay.com/photo/2017/06/05/10/15/landscape-2373649_960_720.jpg") else {
            return UIImageView()
        }
        imageView.sd_setImage(with: url)
        return imageView
    }()

    private func configureConstraints() {
        let avatarImageViewConstraints = [
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            avatarImageView.centerYAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100)
        ]
        
        let displayNameLabelConstraints = [
            displayNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: 10),
            displayNameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 15)
        ]
        
        let usernameLabelConstraints = [
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: 10),
            usernameLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 5)
        ]
        
        let bioLabelConstraints = [
            bioLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: 10),
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5)
        ]
        
        let dateLabelConstraints = [
            dateLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 5)
        ]
        
        let followingCountLabelConstraints = [
            followingCountLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: 10),
            followingCountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5)
        ]
        
        let followingCountTextLabelConstraints = [
            followingCountTextLabel.leadingAnchor.constraint(equalTo: followingCountLabel.trailingAnchor, constant: 5),
            followingCountTextLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5)
        ]
        
        let followersCountLabelConstraints = [
            followersCountLabel.leadingAnchor.constraint(equalTo: followingCountTextLabel.trailingAnchor, constant: 10),
            followersCountLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5)
        ]
        
        let followersCountTextLabelConstraints = [
            followersCountTextLabel.leadingAnchor.constraint(equalTo: followersCountLabel.trailingAnchor, constant: 5),
            followersCountTextLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5)
        ]
        
        
        let editProfileButtonConstraints = [
            editProfileButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            editProfileButton.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor),
            editProfileButton.heightAnchor.constraint(equalToConstant: 40),
            editProfileButton.widthAnchor.constraint(equalToConstant: 120)
        ]
        
        NSLayoutConstraint.activate(avatarImageViewConstraints)
        NSLayoutConstraint.activate(displayNameLabelConstraints)
        NSLayoutConstraint.activate(usernameLabelConstraints)
        NSLayoutConstraint.activate(bioLabelConstraints)
        NSLayoutConstraint.activate(dateLabelConstraints)
        NSLayoutConstraint.activate(followingCountTextLabelConstraints)
        NSLayoutConstraint.activate(followingCountLabelConstraints)
        NSLayoutConstraint.activate(followersCountLabelConstraints)
        NSLayoutConstraint.activate(followersCountTextLabelConstraints)
        NSLayoutConstraint.activate(editProfileButtonConstraints)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(avatarImageView)
        addSubview(displayNameLabel)
        addSubview(usernameLabel)
        addSubview(bioLabel)
        addSubview(dateLabel)
        addSubview(followingCountTextLabel)
        addSubview(followingCountLabel)
        addSubview(followersCountLabel)
        addSubview(followersCountTextLabel)
        addSubview(editProfileButton)
        configureConstraints()
        editProfileButton.addTarget(self, action: #selector(didTapEditProfile), for: .touchUpInside)
    }
    
    
     func configureHeader() {
        guard let userID = userID else {
            return
        }

        DatabaseManager.shared.getUserWith(userID: userID) { [weak self] result in
            switch result {
            case .success(let user):
                guard let authUserID = Auth.auth().currentUser?.uid else {return}
                if authUserID == userID {
                    print("I'm looking at my profile")
                    self?.editProfileButton.setTitle("Edit Profile", for: .normal)
                } else {
                    print("I'm not looking at my profile. let's see who's profile is this")
                    self?.editProfileButton.setTitle("Follow", for: .normal)
                }
                self?.displayNameLabel.text = user.displayName
                self?.usernameLabel.text = "@\(user.username)"
                self?.bioLabel.text = user.bio
                self?.followersCountLabel.text = "\(user.followersCount)"
                self?.followingCountLabel.text = "\(user.followingCount)"
                guard let url = URL(string: user.avatarPath) else {return}
                self?.avatarImageView.sd_setImage(with: url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
         
         guard let mainUserId = Auth.auth().currentUser?.uid else {
             return
         }
         if userID != mainUserId {
             DatabaseManager.shared.fetchFollowingListsFor(userID: mainUserId) { [weak self] result in
                 switch result {
                 case .success(let followList):
                     if followList.following.contains(userID) {
                         self?.configureButtonAsFollowed()
                     } else {
                         self?.configureButtonAsNotFollowed()
                     }
                 case .failure(let error):
                     print(error.localizedDescription)
                 }
             }
         }
    }
    
    private func configureButtonAsFollowed() {
        editProfileButton.setTitle("Unfollow", for: .normal)
        editProfileButton.tintColor = .white
        editProfileButton.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        editProfileButton.isHidden = false
    }
    
    private func configureButtonAsNotFollowed() {
        editProfileButton.setTitle("Follow", for: .normal)
        editProfileButton.tintColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        editProfileButton.backgroundColor = .clear
        editProfileButton.isHidden = false
    }
    
    @objc private func didTapEditProfile() {
        delegate?.profileTableHeaderViewDidTapEditProfile(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 200)

    }
 
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
