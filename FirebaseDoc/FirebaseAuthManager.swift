import UIKit
import FirebaseAuth
import FirebaseFirestore
import SnapKit

class LoginViewController: UIViewController {
    
    let backImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "newintro")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вход", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Регистрация", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Забыли пароль?", for: .normal)
        button.setTitleColor(.grayCustom, for: .normal)
        button.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = backImage
        backImage.addSubview(emailTextField)
        backImage.addSubview(passwordTextField)
        backImage.addSubview(loginButton)
        backImage.addSubview(registerButton)
        backImage.addSubview(forgotPasswordButton)
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        emailTextField.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-270)
            make.leading.trailing.equalToSuperview().inset(70)
            make.height.equalTo(50) }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(70)
            make.height.equalTo(50) }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(70)
            make.height.equalTo(50) }
        
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(70)
            make.height.equalTo(50) }
        
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(30) }
    }
    
    @objc func forgotPasswordTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите адрес электронной почты")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(title: "Ошибка", message: error.localizedDescription)
            } else {
                self.showAlert(title: "Успешно", message: "Инструкции по сбросу пароля отправлены на ваш адрес электронной почты")
            }
        }
    }
    
    @objc func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите email и пароль")
            return
            
            UIView.animate(withDuration: 0.2) {
                self.loginButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.loginButton.transform = .identity
                }
            }
        }
        
        Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
            if let error = error as NSError?, error.code == AuthErrorCode.userNotFound.rawValue {
                self.showAlert(title: "Ошибка", message: "Пользователь с таким email не зарегистрирован")
            } else if let error = error {
                self.showAlert(title: "Ошибка", message: error.localizedDescription)
            } else {
                self.signInUser(email: email, password: password)
            }
        }
    }
    
    @objc func registerTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Ошибка", message: "Пожалуйста, введите email и пароль")
            return
            
            UIView.animate(withDuration: 0.2) {
                self.registerButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.registerButton.transform = .identity
                }
            }
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Ошибка", message: error.localizedDescription)
            } else if let authResult = authResult {
                self.saveUserToDatabase(user: authResult.user)
                self.transitionToMainApp()
            }
        }
    }
    
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(title: "Ошибка", message: error.localizedDescription)
            } else if let authResult = authResult {
                print(Auth.auth().currentUser?.uid ?? "No UID")
                self.transitionToMainApp()
            }
        }
    }
    
    func saveUserToDatabase(user: User) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users").document(user.uid) // Использование user.uid как идентификатора документа
        let values: [String: Any] = ["email": user.email]
        
        usersRef.setData(values) { error in
            if let error = error {
                print("Ошибка сохранения данных пользователя: \(error.localizedDescription)")
            } else {
                print("Данные пользователя успешно сохранены в базу данных")
            }
        }
    }
    
    func transitionToMainApp() {
        let tabBarController = TabBarController()
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = tabBarController
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Анимация мигания для поля ввода email
    func blinkAnimation(for textField: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            textField.alpha = 0.1
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                textField.alpha = 1.0
            }
        }
    }
    
    // Анимация изменения цвета кнопки при нажатии
    func animateButtonPress(for button: UIButton) {
        UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve, animations: {
            button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.4)
        }) { _ in
            UIView.transition(with: button, duration: 0.2, options: .transitionCrossDissolve, animations: {
                button.backgroundColor = UIColor.grayCustom.withAlphaComponent(0.2)
            }, completion: nil)
        }
    }
    
}

