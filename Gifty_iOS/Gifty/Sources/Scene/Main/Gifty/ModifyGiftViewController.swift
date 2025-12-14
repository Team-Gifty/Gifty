
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
        $0.minimumDate = Calendar.current.startOfDay(for: Date())
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
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



    @objc private func saveButtonTapped() {
        guard let name = giftNameTextField.text, !name.isEmpty,
              let usage = usageTextField.text, !usage.isEmpty else {
            showAlert(title: "알림", message: "교환권 이름과 사용처를 모두 입력해주세요.")
            return
        }
        
        // 중복 체크 (자기 자신 제외)
        if RealmManager.shared.isDuplicateGiftName(name, excludingGift: gift) {
            showAlert(title: "중복", message: "이미 등록된 교환권 이름입니다.\n다른 이름을 사용해주세요.")
            return
        }
        
        let expiryDate = expiryDatePicker.date
        let memo = memoTextField.text
        
        delegate?.didModifyGiftInfo(name: name, usage: usage, expiryDate: expiryDate, memo: memo)
        
        dismiss(animated: true, completion: nil)
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        
        saveButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight + 20)
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        saveButton.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(40)
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
