
import UIKit
import SnapKit
import Then

protocol ModifyGiftViewControllerDelegate: AnyObject {
    func didModifyGiftInfo(name: String, usage: String, expiryDate: Date, memo: String?)
}

class ModifyGiftViewController: UIViewController {
    
    var gift: Gift?
    weak var delegate: ModifyGiftViewControllerDelegate?
    
    private let giftNameTextField = GiftyTextField(hintText: "교환권 이름")
    private let usageTextField = GiftyTextField(hintText: "사용처")
    private let expiryDatePicker = UIDatePicker().then {
        $0.datePickerMode = .date
    }
    private let memoTextField = GiftyTextField(hintText: "메모 (선택)")
    
    private let saveButton = GiftyButton(buttonText: "저장", isEnabled: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addView()
        setLayout()
        configure()
        hideKeyboardWhenTappedAround()
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func addView() {
        [giftNameTextField, usageTextField, expiryDatePicker, memoTextField, saveButton].forEach { view.addSubview($0) }
    }
    
    private func setLayout() {
        giftNameTextField.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        usageTextField.snp.makeConstraints {
            $0.top.equalTo(giftNameTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        expiryDatePicker.snp.makeConstraints {
            $0.top.equalTo(usageTextField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        memoTextField.snp.makeConstraints {
            $0.top.equalTo(expiryDatePicker.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(memoTextField.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func configure() {
        if let gift = gift {
            giftNameTextField.text = gift.name
            usageTextField.text = gift.usage
            expiryDatePicker.date = gift.expiryDate
            memoTextField.text = gift.memo
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = giftNameTextField.text, !name.isEmpty,
              let usage = usageTextField.text, !usage.isEmpty else {
            // TODO: 사용자에게 모든 필드를 채워달라는 알림 표시
            return
        }
        
        let expiryDate = expiryDatePicker.date
        let memo = memoTextField.text
        
        delegate?.didModifyGiftInfo(name: name, usage: usage, expiryDate: expiryDate, memo: memo)
        
        dismiss(animated: true, completion: nil)
    }
}
