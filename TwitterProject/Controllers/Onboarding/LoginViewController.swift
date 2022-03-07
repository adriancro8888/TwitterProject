//
//  LoginViewController.swift
//  TwitterProject
//
//  Created by Amr Hossam on 13/02/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let screenScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    
    private let loginTitleLabel: UILabel = {
       
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login to twitter"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()

    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        return textField
    }()
    
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.isSecureTextEntry = true
        return textField
    }()
    
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(screenScrollView)
        view.backgroundColor = .systemBackground
        screenScrollView.addSubview(loginTitleLabel)
        screenScrollView.addSubview(emailTextField)
        screenScrollView.addSubview(passwordTextField)
        screenScrollView.showsVerticalScrollIndicator = false
        view.addSubview(loginButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        navigationController?.navigationBar.tintColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        prepareNavbar()
        configureConstraints()
        
        loginButton.addTarget(
            self,
            action: #selector(didTapLogin),
            for: .touchUpInside)
    }
    
    private func isValidEmail(_ email: String) -> String? {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email) ? email : nil
    }
    
    @objc private func didTapLogin() {
        
        guard let email = emailTextField.text,
              let validEmail = isValidEmail(email),
              let password = passwordTextField.text,
              password.count >= 8 else {
                  let alert = UIAlertController(title: "Error", message: "Must enter a valid email and a password of at least 8 characters", preferredStyle: .alert)
                  let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                  alert.addAction(action)
                  present(alert, animated: true)
                  return
              }
        AuthManager.shared.loginAccountWith(email: validEmail, password: password) { [weak self] result in
            switch result {
            case .success():
                self?.dismiss(animated: true)
            case .failure(_):
                let alert = UIAlertController(title: "Login failed", message: "Failed to login. Please check your credentials", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self?.present(alert, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        screenScrollView.frame = view.bounds
        screenScrollView.contentSize = CGSize(width: view.frame.size.width, height: view.frame.height*0.88)
    }
    
    private func prepareNavbar() {
        let twitterLogoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        twitterLogoImageView.contentMode = .scaleAspectFill
        twitterLogoImageView.image = UIImage(named: "twitterLogo")
        let mview = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        mview.addSubview(twitterLogoImageView)
        navigationItem.titleView = mview
    }
    
    @objc private func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
    private func configureConstraints() {
        let loginTitleLabelConstraints = [
            loginTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTitleLabel.topAnchor.constraint(equalTo: screenScrollView.topAnchor, constant: 20)
        ]
        
        let emailTextFieldConstraints = [
            emailTextField.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor, constant: 20),
            emailTextField.topAnchor.constraint(equalTo: loginTitleLabel.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            emailTextField.centerXAnchor.constraint(equalTo: screenScrollView.centerXAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let passwordTextFieldConstraints = [
            passwordTextField.leadingAnchor.constraint(equalTo: screenScrollView.leadingAnchor, constant: 20),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            passwordTextField.centerXAnchor.constraint(equalTo: screenScrollView.centerXAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        

        let loginButtonConstraints = [
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.widthAnchor.constraint(equalToConstant: 100),
            loginButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(loginTitleLabelConstraints)
        NSLayoutConstraint.activate(emailTextFieldConstraints)
        NSLayoutConstraint.activate(passwordTextFieldConstraints)
        NSLayoutConstraint.activate(loginButtonConstraints)
    }
}
