import UIKit
import SnapKit
import Then
import UserNotifications
import Realm
import Combine

class UploadViewController: BaseViewController {

    // MARK: - Properties
    private let viewModel = UploadViewModel()
    private var cancellables = Set<AnyCancellable>()

    private let imageSelectedSubject = PassthroughSubject<UIImage, Never>()
    private let informationButtonTappedSubject = PassthroughSubject<Void, Never>()
    
    let photoDescriptionLabel = UILabel().then {
        $0.text = "등록할 교환권 이미지를 넣어주세요 :)"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .giftyFont(size: 25)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    let shadowView = UIView().then {
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 100
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    let imageuploadButton = UIButton().then {
        $0.setTitle("탭하여 교환권 넣기", for: .normal)
        $0.setTitleColor(.BFA_98_A, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 23)
        $0.backgroundColor = .F_7_EAD_8
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.imageView?.contentMode = .scaleAspectFill
    }
    
    
    let informationButton = GiftyButton(
        buttonText: "정보 작성하기",
        isEnabled: false,
        height: 50
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
        imageuploadButton.addTarget(self, action: #selector(imageuploadButtonTapped), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(informationButtonTapped), for: .touchUpInside)
    }

    // MARK: - Binding
    private func setupBindings() {
        let input = UploadViewModel.Input(
            imageSelected: imageSelectedSubject.eraseToAnyPublisher(),
            informationButtonTapped: informationButtonTappedSubject.eraseToAnyPublisher()
        )

        let output = viewModel.transform(input: input)

        output.selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                if let image = image {
                    self.imageuploadButton.setImage(image, for: .normal)
                    self.imageuploadButton.setTitle(nil, for: .normal)
                } else {
                    self.imageuploadButton.setImage(nil, for: .normal)
                    self.imageuploadButton.setTitle("탭하여 교환권 넣기", for: .normal)
                }
            }
            .store(in: &cancellables)

        output.isInformationButtonEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                self.informationButton.isEnabled = isEnabled
                self.informationButton.backgroundColor = isEnabled ? .FDE_1_AD : .BFA_98_A
                self.informationButton.setTitleColor(isEnabled ? .A_98_E_5_C : .BFA_98_A, for: .normal)
            }
            .store(in: &cancellables)

        output.navigationToProductName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageName in
                guard let self = self, let imageName = imageName else { return }
                let productNameVC = ProductNameViewController()
                productNameVC.selectedImageName = imageName
                self.navigationController?.pushViewController(productNameVC, animated: true)
            }
            .store(in: &cancellables)
    }

    func registrationDidComplete() {
        clearInputs()
        
        if let mainVC = self.tabBarController?.viewControllers?[0] as? MainViewController {
            mainVC.ShowCheckModal = true
        }
        
        self.navigationController?.popToRootViewController(animated: false)
        self.tabBarController?.selectedIndex = 0
    }
    
    override func addView() {
        
        shadowView.addSubview(imageuploadButton)
        
        [
            photoDescriptionLabel,
            shadowView,
            informationButton
        ].forEach { view.addSubview($0) }
        
    }
    
    override func setLayout() {
        photoDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(90)
        }
        
        shadowView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoDescriptionLabel.snp.bottom).offset(30)
            $0.width.equalTo(287)
            $0.height.equalTo(323)
        }
        
        imageuploadButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoDescriptionLabel.snp.bottom).offset(30)
            $0.width.equalTo(287)
            $0.height.equalTo(323)
        }
        
        informationButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(50)
            $0.top.equalTo(imageuploadButton.snp.bottom).offset(25)
        }
    }
    
    
    // MARK: - Actions
    @objc func imageuploadButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }

    @objc func informationButtonTapped() {
        informationButtonTappedSubject.send(())
    }

    func clearInputs() {
        viewModel.clearInputs()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageSelectedSubject.send(image)
        }
        dismiss(animated: true, completion: nil)
    }
}
