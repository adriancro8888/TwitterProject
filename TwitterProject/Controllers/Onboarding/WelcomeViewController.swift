//
//  WelcomeViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "See what's happening in the world right now."
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Create account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.layer.cornerRadius = 30
        return button
    }()
    
    
    private let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "Have an account already?"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .gray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.tintColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.setTitle("Login", for: .normal)
        return button
    }()
    
    private func prepareNavbar() {
        let twitterLogoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        twitterLogoImageView.contentMode = .scaleAspectFill
        twitterLogoImageView.image = UIImage(named: "twitterLogo")
        let mview = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        mview.addSubview(twitterLogoImageView)
        navigationItem.titleView = mview
    }
    
    
    private func configureConstraints() {
        let welcomeLabelConstraints = [
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        let createAccountButtonConstraints = [
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            createAccountButton.widthAnchor.constraint(equalTo: welcomeLabel.widthAnchor, constant: -20),
            createAccountButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let promptLabelConstraints = [
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
        ]
        
        let loginButtonConstraints = [
            loginButton.centerYAnchor.constraint(equalTo: promptLabel.centerYAnchor),
            loginButton.leadingAnchor.constraint(equalTo: promptLabel.trailingAnchor, constant: 10)
        ]
        
        NSLayoutConstraint.activate(welcomeLabelConstraints)
        NSLayoutConstraint.activate(createAccountButtonConstraints)
        NSLayoutConstraint.activate(promptLabelConstraints)
        NSLayoutConstraint.activate(loginButtonConstraints)
        
    }

    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(welcomeLabel)
        view.addSubview(createAccountButton)
        view.addSubview(promptLabel)
        view.addSubview(loginButton)
        configureConstraints()
        prepareNavbar()
        
        loginButton.addTarget(
            self,
            action: #selector(didTapLoginButton),
            for: .touchUpInside)
        
        createAccountButton.addTarget(
            self,
            action: #selector(didTapCreateButton),
            for: .touchUpInside)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Auth.auth().currentUser != nil {
            dismiss(animated: false)
        }
        view.isHidden = false
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.isHidden = true
    }
    
    
    // MARK: - Functionality Methods
    
    @objc private func didTapCreateButton() {
        let vc = UINavigationController(rootViewController: RegisterationViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    @objc private func didTapLoginButton() {
        let vc = UINavigationController(rootViewController: LoginViewController())
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    
}
