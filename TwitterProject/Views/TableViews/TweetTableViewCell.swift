//
//  TweetTableViewCell.swift
//  TwitterProject
//
//  Created by Amr Hossam on 14/02/2022.
//

import UIKit
import SDWebImage
import FirebaseAuth

protocol TweetTableViewCellDelegate: AnyObject {
    func tweetTableViewCellTappedReply(_ cell: TweetTableViewCell, indexPath: IndexPath)
    func tweetTableViewCellTappedRetweet(_ cell: TweetTableViewCell, indexPath: IndexPath)
    func tweetTableViewCellTappedLike(_ cell: TweetTableViewCell, indexPath: IndexPath)
    func tweetTableViewCellTappedShare(_ cell: TweetTableViewCell, tweetTextContent: String)
    func tweetTableViewCellTappedAvatar(_ tweetTableViewCell:TweetTableViewCell)
}

class TweetTableViewCell: UITableViewCell {
    
    static let identifier = "TweetTableViewCell"

    weak var delegate: TweetTableViewCellDelegate?
    var indexPath: IndexPath?
    var isLiked: Bool = false
    var isRetweeted: Bool = false
    
    private let avatarImageView: UIImageView = {

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 25
        guard let url = URL(string: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80") else {
            return UIImageView()
        }
        imageView.sd_setImage(with: url)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let displayNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightText
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = " "
        return label
    }()
    
    
    private let tweetTextContent: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = " "
        return label
    }()
    
    private let replyButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "bubble.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14))
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let retweetButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.2.squarepath", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14))
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14))
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14))
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func configureConstraints() {
        
        let avatarImageViewConstraints = [
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        let displayNameLabelConstraints = [
            displayNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 20),
            displayNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        ]
        
        let usernameLabelConstraints = [
            usernameLabel.leadingAnchor.constraint(equalTo: displayNameLabel.trailingAnchor, constant: 10),
            usernameLabel.centerYAnchor.constraint(equalTo: displayNameLabel.centerYAnchor)
        ]
        
        let tweetTextContentConstraints = [
            tweetTextContent.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            tweetTextContent.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 10),
            tweetTextContent.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),

        ]
        
        let replyButtonConstraints = [
            replyButton.leadingAnchor.constraint(equalTo: displayNameLabel.leadingAnchor),
            replyButton.topAnchor.constraint(equalTo: tweetTextContent.bottomAnchor, constant: 15),
            replyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ]
        
        let retweetButtonConstraints = [
            retweetButton.leadingAnchor.constraint(equalTo: replyButton.trailingAnchor, constant: 55),
            retweetButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor)
        ]
        
        let likeButtonConstraints = [
            likeButton.leadingAnchor.constraint(equalTo: retweetButton.trailingAnchor, constant: 55),
            likeButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor)
        ]
        
        let shareButtonConstraints = [
            shareButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 55),
            shareButton.centerYAnchor.constraint(equalTo: replyButton.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(avatarImageViewConstraints)
        NSLayoutConstraint.activate(displayNameLabelConstraints)
        NSLayoutConstraint.activate(usernameLabelConstraints)
        NSLayoutConstraint.activate(tweetTextContentConstraints)
        NSLayoutConstraint.activate(replyButtonConstraints)
        NSLayoutConstraint.activate(retweetButtonConstraints)
        NSLayoutConstraint.activate(likeButtonConstraints)
        NSLayoutConstraint.activate(shareButtonConstraints)
    }
    
    @objc private func didTapReply() {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.tweetTableViewCellTappedReply(self, indexPath: indexPath)
    }
    @objc private func didTapRetweet() {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.tweetTableViewCellTappedRetweet(self, indexPath: indexPath)
    }
    @objc private func didTapLike() {
        guard let indexPath = indexPath else {
            return
        }
        delegate?.tweetTableViewCellTappedLike(self, indexPath: indexPath)
    }
    @objc private func didTapShare() {
        guard let text = tweetTextContent.text else {return}
        delegate?.tweetTableViewCellTappedShare(self, tweetTextContent: text)
    }
    
    private func addingButtonsTargets() {
        replyButton.addTarget(self, action: #selector(didTapReply), for: .touchUpInside)
        retweetButton.addTarget(self, action: #selector(didTapRetweet), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
    }
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        gesture.delegate = self
        return gesture
    }()
    
    @objc private func didTapAvatar() {
        delegate?.tweetTableViewCellTappedAvatar(self)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(displayNameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(tweetTextContent)
        contentView.addSubview(replyButton)
        contentView.addSubview(retweetButton)
        contentView.addSubview(likeButton)
        contentView.addSubview(shareButton)
        addingButtonsTargets()
        configureConstraints()
        bringSubviewToFront(avatarImageView)
        avatarImageView.addGestureRecognizer(tapGesture)
        avatarImageView.isUserInteractionEnabled = true
        
    }
    
    func configureAsLiked() {
        isLiked = true
        let imageIcon = UIImage(systemName: "heart.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        likeButton.setImage(imageIcon, for: .normal)
    }
    
    func configureAsUnliked() {
        isLiked = false
        let imageIcon = UIImage(systemName: "heart")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        likeButton.setImage(imageIcon, for: .normal)
    }
    
    
    func configureAsRetweeted() {
        isRetweeted = true
        let imageIcon = UIImage(systemName: "arrow.2.squarepath")?.withTintColor(.green, renderingMode: .alwaysOriginal)
        retweetButton.setImage(imageIcon, for: .normal)
    }
    
    func configureAsUnretweeted() {
        isRetweeted = false
        let imageIcon = UIImage(systemName: "arrow.2.squarepath")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        retweetButton.setImage(imageIcon, for: .normal)
    }
    
    
    func configureWith(model: TweetViewModel) {
        usernameLabel.text = "@\(model.username)"
        displayNameLabel.text = model.displayName
        tweetTextContent.text = model.tweetTextContent
        guard let url = URL(string: model.avatarPath) else {return}
        avatarImageView.sd_setImage(with: url)
        model.isLiked ? configureAsLiked() : configureAsUnliked()
        model.isRetweeted ? configureAsRetweeted() : configureAsUnretweeted()

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

}
