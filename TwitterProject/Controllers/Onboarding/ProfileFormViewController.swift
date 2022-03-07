//
//  ProfileFormViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import UIKit
import FirebaseAuth
import PhotosUI

class ProfileFormViewController: UIViewController {


    private var isAvatarChanged: Bool = false
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        imageView.image = UIImage(systemName: "person")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 60
        imageView.backgroundColor = .secondarySystemFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func prepareNavbar() {
        let twitterLogoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        twitterLogoImageView.contentMode = .scaleAspectFill
        twitterLogoImageView.image = UIImage(named: "twitterLogo")
        let mview = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        mview.addSubview(twitterLogoImageView)
        navigationItem.titleView = mview
    }

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.backgroundColor = .tertiarySystemFill
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        return textField
    }()
    
    private let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.backgroundColor = .tertiarySystemFill
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.backgroundColor = .tertiarySystemFill
        return textField
    }()
    
    private let bioTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Bio",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.leftViewMode = .always
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.backgroundColor = .tertiarySystemFill
        return textField
    }()
    
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        return picker
    }()
    
    
    private let createdOnLabel: UILabel = {
        let label = UILabel()
        label.text = "  Birthday"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        label.backgroundColor = .tertiarySystemFill
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    fileprivate func prepareScrollView() {
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(bioTextField)
        scrollView.addSubview(datePicker)
        scrollView.addSubview(createdOnLabel)
    }
    
    @objc private func didTapSave() {
 
        if isAvatarChanged {
            guard let image = avatarImageView.image else {return}
            FirestoreManager.shared.uploadUserImage(image: image) { [weak self] result in
                switch result {
                case .success(let url):
                    self?.updateUserRecordWith(url)
                    self?.isAvatarChanged = false
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            let alert = UIAlertController(title: "Sorry", message: "You must choose an Avatar", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "I Understand", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updateUserRecordWith(_ url: URL) {
        
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let username = usernameTextField.text,
              let bio = bioTextField.text else {
                  return
              }
        let birthday = datePicker.date.formatted(date: .complete, time: .omitted)
        
        
        let model = ProfileFormViewModel(
            name: name,
            email: email,
            username: username,
            birthday: birthday,
            isWelcomed: true,
            avatarPath: url.absoluteString,
            bio: bio
        )
        
        DatabaseManager.shared.updateRecordForUserWith(model: model) { [weak self] result in
            switch result {
            case .success():
                self?.dismiss(animated: true)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func prepareCurrentUser() {
        guard let id = Auth.auth().currentUser?.uid else {return}
        DatabaseManager.shared.getUserWith(userID: id) { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.emailTextField.text = user.email
                    self?.nameTextField.text = user.displayName
                    self?.usernameTextField.text = user.username
                    guard let url = URL(string: user.avatarPath) else {return}
                    self?.avatarImageView.sd_setImage(with: url)
                    self?.bioTextField.text = user.bio
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    

   
    
    @objc private func presentPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit =  1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        prepareCurrentUser()
        prepareScrollView()
        prepareNavbar()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        configureConstraints()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didTapSave))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentPicker)))
        
    }
    
    
    private func configureConstraints() {
        let scrollViewConstraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        let avatarImageViewConstraints = [
            avatarImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120)
        ]
        
        let nameTextFieldConstraints = [
            nameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            nameTextField.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            nameTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            nameTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let usernameTextFieldConstraints = [
            usernameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            usernameTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            usernameTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            usernameTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            usernameTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let emailTextFieldConstraints = [
            emailTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            emailTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let bioTextFieldConstraints = [
            bioTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            bioTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            bioTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            bioTextField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            bioTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let datePickerConstraints = [
            datePicker.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            datePicker.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 20),
            datePicker.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ]
        
        let createdOnLabelConstraints = [
            createdOnLabel.topAnchor.constraint(equalTo: bioTextField.bottomAnchor, constant: 20),
            createdOnLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            createdOnLabel.heightAnchor.constraint(equalToConstant: datePicker.frame.height),
            createdOnLabel.widthAnchor.constraint(equalToConstant: 100 )
        ]
        
        NSLayoutConstraint.activate(scrollViewConstraints)
        NSLayoutConstraint.activate(avatarImageViewConstraints)
        NSLayoutConstraint.activate(nameTextFieldConstraints)
        NSLayoutConstraint.activate(usernameTextFieldConstraints)
        NSLayoutConstraint.activate(emailTextFieldConstraints)
        NSLayoutConstraint.activate(bioTextFieldConstraints)
        NSLayoutConstraint.activate(datePickerConstraints)
        NSLayoutConstraint.activate(createdOnLabelConstraints)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = scrollView.frame.size
        scrollView.showsVerticalScrollIndicator = false
    }
}

extension ProfileFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        isAvatarChanged = true
        results.forEach { item in
            item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let image = image as? UIImage,
                error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                    self?.dismiss(animated: true)
                }
                
            }
        }
    }
    
    
}
