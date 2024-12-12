import UIKit
import FirebaseAuth
import PhotosUI

class ProfileViewController: UIViewController, PHPickerViewControllerDelegate {
    
    // MARK: - UI Elements
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Photo", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username: "
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editUsernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Username", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(editUsernameTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email: "
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayUserDetails()
        loadProfileImage()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(avatarImageView)
        view.addSubview(changePhotoButton)
        view.addSubview(usernameLabel)
        view.addSubview(editUsernameButton)
        view.addSubview(emailLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            changePhotoButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
            changePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            editUsernameButton.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            editUsernameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: editUsernameButton.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 40),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Display User Details
    private func displayUserDetails() {
        guard let user = Auth.auth().currentUser else {
            emailLabel.text = "No user logged in."
            return
        }
        emailLabel.text = "Email: \(user.email ?? "N/A")"
        usernameLabel.text = "Username: \(user.displayName ?? "N/A")"
    }
    
    // MARK: - Load and Save Profile
    private func loadProfileImage() {
        guard let email = Auth.auth().currentUser?.email else { return }
        let key = "profilePhoto_\(email)"
        if let imageData = UserDefaults.standard.data(forKey: key),
           let image = UIImage(data: imageData) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    private func saveProfileImage(_ image: UIImage) {
        guard let email = Auth.auth().currentUser?.email else { return }
        let key = "profilePhoto_\(email)"
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: key)
        }
    }
    
    // MARK: - Actions
    @objc private func changePhotoTapped() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func editUsernameTapped() {
        let alertController = UIAlertController(
            title: "Edit Username",
            message: "Enter a new username",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "New username"
        }
        
        let confirmAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newUsername = alertController.textFields?.first?.text, !newUsername.isEmpty else {
                self.showAlert(title: "Error", message: "Username cannot be empty.")
                return
            }
            
            // Get the current user
            guard let user = Auth.auth().currentUser else {
                self.showAlert(title: "Error", message: "No user is logged in.")
                return
            }
            
            // Create a profile change request
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = newUsername
            changeRequest.commitChanges { error in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                } else {
                    self.usernameLabel.text = "Username: \(newUsername)"
                    self.showAlert(title: "Success", message: "Username updated successfully.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    @objc private func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            
            // Update the root view controller to LoginViewController
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showLoginViewController()
            }
        } catch let error {
            showAlert(title: "Logout Error", message: error.localizedDescription)
        }
    }

    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let result = results.first else { return }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self = self else { return }
            
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                    self.saveProfileImage(image)
                }
            } else if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
