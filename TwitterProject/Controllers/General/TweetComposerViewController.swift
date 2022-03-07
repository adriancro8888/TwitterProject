//
//  TweetComposerViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 15/02/2022.
//

import UIKit
import FirebaseAuth

class TweetComposerViewController: UIViewController {
    
    

    var parentReference: String?
    var referencedUser: String?
    var isReply: Bool = false
    
    private let authorAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let composerTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "What's happening?"
        textView.textColor = UIColor.lightGray
        textView.font = .systemFont(ofSize: 20)

        return textView
    }()
    
    private let tweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Tweet", for: .normal)
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.tintColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: tweetButton)
        view.addSubview(composerTextView)
        view.addSubview(authorAvatarImageView)
        composerTextView.delegate = self
        configureConstraints()
        tweetButton.addTarget(self, action: #selector(didTapTweet), for: .touchUpInside)
        configureAvatar()
    }
    
    
    private func configureAvatar() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        DatabaseManager.shared.getUserWith(userID: userID) { [weak self] result in
            switch result {
            case .success(let user):
                guard let url = URL(string: user.avatarPath) else {return}
                self?.authorAvatarImageView.sd_setImage(with: url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func didTapTweet() {
        
        guard let tweetTextContent = composerTextView.text,
              tweetTextContent.count > 0 else {
                  return
              }
        guard let userID = Auth.auth().currentUser?.uid else {return}
        
        
        
        DatabaseManager.shared.dispatchTweetToStoreWith(
            model: Tweet(id: "",
                         timestamp: NSDate().timeIntervalSince1970,
                         authorID: userID,
                         tweetTextContent: tweetTextContent,
                         likesCount: 0,
                         mediaContent: nil,
                         likers: [],
                         isReply: isReply,
                         retweetCount: 0,
                         retweeters: [],
                         parentReference: parentReference
                        ))
        { [weak self] result in
                switch result {
                case .success():
                    self?.dismiss(animated: true)
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    
    func configureAsReply() {
        composerTextView.text = "Replying to @\(referencedUser!)"
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    private func configureConstraints() {

        let authorAvatarImageViewConstraints = [
            authorAvatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authorAvatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            authorAvatarImageView.widthAnchor.constraint(equalToConstant: 40),
            authorAvatarImageView.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        let composerTextViewConstraints = [
            composerTextView.leadingAnchor.constraint(equalTo: authorAvatarImageView.trailingAnchor, constant: 20),
            composerTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            composerTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            composerTextView.heightAnchor.constraint(equalToConstant: 240)
        ]
        
        NSLayoutConstraint.activate(authorAvatarImageViewConstraints)
        NSLayoutConstraint.activate(composerTextViewConstraints)

    }
    
    
}

extension TweetComposerViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        textView.textColor = .label

        guard let text = textView.text else {return}
        if text.count > 0 {
            let start = text.startIndex
            let preStart = text.index(after: start)
            if text[preStart...] == "What's happening?" {
                textView.text = String(text[start..<preStart])
            }
        }

        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        }
    }
    
}
