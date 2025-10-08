import UIKit
import SnapKit
import Then

class UploadViewController: BaseViewController {
    
    private let viewModel = UploadViewModel()
    
    private var selectedImage: UIImage?
    private var selectedImageName: String?
    private var giftName: String?
    private var usage: String?
    private var expiryDate: Date?
    private var memo: String?
    
    let photoDescriptionLabel = UILabel().then {
        $0.text = "등록할 교환권 이미지를 넣어주세요 :)"
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .giftyFont(size: 25)
        $0.textColor = ._6_A_4_C_4_C
    }
    
    
    let imageuploadButton = UIButton().then {
        $0.setTitle("탭하여 교환권 넣기", for: .normal)
        $0.setTitleColor(.BFA_98_A, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 23)
        $0.backgroundColor = .F_7_EAD_8
        $0.layer.cornerRadius = 15
        $0.layer.shadowColor = UIColor.CBBDB_1.cgColor
        $0.layer.shadowOpacity = 100
        $0.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    
    let informationButton = GiftyButton(
        buttonText: "정보 작성하기",
        isEnabled: false,
        height: 50
    )
    
    
    let uploadButton = GiftyButton(
        buttonText: "등록",
        isEnabled: false,
        height: 50
    )
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageuploadButton.addTarget(self, action: #selector(imageuploadButtonTapped), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(informationButtonTapped), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
    }
    
    
    
    override func addView() {
        [
            photoDescriptionLabel,
            imageuploadButton,
            informationButton,
            uploadButton
        ].forEach { view.addSubview($0) }
        
    }
    
    override func setLayout() {
        photoDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(75)
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
        
        uploadButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(50)
            $0.top.equalTo(informationButton.snp.bottom).offset(14)
        }
    }
    
    
    @objc func imageuploadButtonTapped(){
        //이미지 피커 설정
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc func informationButtonTapped() {
        let bottomSheetVC = GiftInfoBottomSheetViewController()
        bottomSheetVC.delegate = self
        bottomSheetVC.modalPresentationStyle = .pageSheet
        if let sheet = bottomSheetVC.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        present(bottomSheetVC, animated: true, completion: nil)
    }
    
    @objc func uploadButtonTapped() {
        guard let name = self.giftName,
              let usage = self.usage,
              let expiryDate = self.expiryDate,
              let imageName = self.selectedImageName else { return }
        
        viewModel.saveGift(name: name, usage: usage, expiryDate: expiryDate, memo: self.memo, imagePath: imageName)
        
        clearInputs()
        
        self.tabBarController?.selectedIndex = 0
    }
    
    private func clearInputs() {
        self.selectedImage = nil
        self.selectedImageName = nil
        self.giftName = nil
        self.usage = nil
        self.expiryDate = nil
        self.memo = nil
        
        imageuploadButton.setImage(nil, for: .normal)
        imageuploadButton.setTitle("탭하여 교환권 넣기", for: .normal)
        
        informationButton.isEnabled = false
        informationButton.backgroundColor = .BFA_98_A
        informationButton.setTitleColor(.BFA_98_A, for: .normal)
        
        uploadButton.isEnabled = false
        uploadButton.backgroundColor = .BFA_98_A
        uploadButton.setTitleColor(.BFA_98_A, for: .normal)
    }
}

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
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

extension UploadViewController: GiftInfoBottomSheetDelegate {
    func didSaveGiftInfo(name: String, usage: String, expiryDate: Date, memo: String?) {
        self.giftName = name
        self.usage = usage
        self.expiryDate = expiryDate
        self.memo = memo
        
        uploadButton.isEnabled = true
        uploadButton.backgroundColor = .FDE_1_AD
        uploadButton.setTitleColor(.A_98_E_5_C, for: .normal)
    }
}
