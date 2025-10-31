import UIKit
import SnapKit
import Then
import UserNotifications
import Realm

class UploadViewController: BaseViewController {
    
    private let viewModel = UploadViewModel()
    
    private var selectedImage: UIImage?
    private var selectedImageName: String?
    
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
        
        imageuploadButton.addTarget(self, action: #selector(imageuploadButtonTapped), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(informationButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGiftRegistered), name: .giftRegistered, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .giftRegistered, object: nil)
    }

    @objc private func handleGiftRegistered() {
        clearInputs()
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
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(75)
        }
        
        shadowView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoDescriptionLabel.snp.bottom).offset(16)
            $0.width.equalTo(287)
            $0.height.equalTo(323)
        }
        
        imageuploadButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(photoDescriptionLabel.snp.bottom).offset(16)
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
    
    
    @objc func imageuploadButtonTapped(){
        //이미지 피커 설정
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func informationButtonTapped() {
        let productNameVC = ProductNameViewController()
        productNameVC.selectedImageName = selectedImageName
        self.navigationController?.pushViewController(productNameVC, animated: true)
    }
    
    private func clearInputs() {
        self.selectedImage = nil
        self.selectedImageName = nil
        
        imageuploadButton.setImage(nil, for: .normal)
        imageuploadButton.setTitle("탭하여 교환권 넣기", for: .normal)
        
        informationButton.isEnabled = false
        informationButton.backgroundColor = .BFA_98_A
        informationButton.setTitleColor(.BFA_98_A, for: .normal)
    }
}

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.selectedImage = image
            
            let imageName = UUID().uuidString
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentDirectory.appendingPathComponent(imageName)
            
            if let data = image.jpegData(compressionQuality: 1.0) {
                try? data.write(to: fileURL)
                self.selectedImageName = imageName
            }
            
            imageuploadButton.setImage(image, for: .normal)
            informationButton.isEnabled = true
            informationButton.backgroundColor = .FDE_1_AD
            informationButton.setTitleColor(.A_98_E_5_C, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
}
