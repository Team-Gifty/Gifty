import UIKit
import SnapKit
import Then

class DeleteModalViewController: BaseViewController {
    let modalView = UIView().then {
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.cgColor
        $0.backgroundColor = UIColor.FFF_7_EC
    }

    let deleteLabel = UILabel().then {
        $0.text = "사용 완료한 교환권이 맞나요?"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .giftyFont(size: 25)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    let warningLabel = UILabel().then {
        $0.text = "한 번 삭제한 교환권은\n다시 복구할 수 없어요."
        $0.textColor = ._9_B_1_C_1_C
        $0.font = .giftyFont(size: 20)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    let buttoncontainerView = UIView()
    var onDelete: (() -> Void)?

    let deleteButton = UIButton().then {
        $0.backgroundColor = ._6_A_4_C_4_C
        $0.setTitle("네", for: .normal)
        $0.setTitleColor(.FFF_7_EC, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 22)
        $0.layer.borderWidth = 2.3
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.cgColor
        $0.layer.cornerRadius = 7.5
        $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    let cancelButton = UIButton().then {
        $0.backgroundColor = .FFF_7_EC
        $0.setTitle("아니요", for: .normal)
        $0.setTitleColor(._6_A_4_C_4_C, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 22)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.cgColor
        $0.layer.cornerRadius = 7.5
        $0.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    private let dimmingView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    @objc private func deleteButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDelete?()
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    override func addView() {
        view.addSubview(dimmingView)
        
        [
            deleteLabel,
            warningLabel,
            buttoncontainerView
        ].forEach { modalView.addSubview($0) }
        
        [
            deleteButton,
            cancelButton
        ].forEach { buttoncontainerView.addSubview($0) }
        
        [
            modalView
        ].forEach { view.addSubview($0) }
    }

    override func setLayout() {
        dimmingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        modalView.snp.makeConstraints {
            $0.width.equalTo(330)
            $0.height.equalTo(212)
            $0.centerX.equalTo(view)
            $0.top.equalToSuperview().inset(283)
        }
        deleteLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(36)
        }
        warningLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(deleteLabel.snp.bottom).offset(6)
        }
        buttoncontainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(warningLabel.snp.bottom).offset(17)
        }
        deleteButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(115.06)
            $0.height.equalTo(49.47)
        }
        
        cancelButton.snp.makeConstraints {
            $0.leading.equalTo(deleteButton.snp.trailing).offset(14)
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(115.06)
            $0.height.equalTo(49.47)
        }
    }
}
