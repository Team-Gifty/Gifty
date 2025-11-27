import UIKit
import SnapKit
import Then

class CompleteModalViewController: BaseViewController {
    let modalView = UIView().then {
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.cgColor
        $0.backgroundColor = UIColor.FFF_7_EC
    }

    let titleLabel = UILabel().then {
        $0.text = "사용 완료"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .giftyFont(size: 25)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    let messageLabel = UILabel().then {
        $0.text = "이 교환권을 간직함에\n보관하시겠어요?"
        $0.textColor = ._6_A_4_C_4_C
        $0.font = .giftyFont(size: 20)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    let buttoncontainerView = UIView()
    var onArchive: (() -> Void)?
    var onDelete: (() -> Void)?

    let archiveButton = UIButton().then {
        $0.backgroundColor = ._6_A_4_C_4_C
        $0.setTitle("예", for: .normal)
        $0.setTitleColor(.FFF_7_EC, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 22)
        $0.layer.borderWidth = 2.3
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.cgColor
        $0.layer.cornerRadius = 7.5
        $0.addTarget(self, action: #selector(archiveButtonTapped), for: .touchUpInside)
    }

    let deleteButton = UIButton().then {
        $0.backgroundColor = .FFF_7_EC
        $0.setTitle("아니오", for: .normal)
        $0.setTitleColor(._6_A_4_C_4_C, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 22)
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor._6_A_4_C_4_C.cgColor
        $0.layer.cornerRadius = 7.5
        $0.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    let cancelButton = UIButton().then {
        $0.backgroundColor = .FFF_7_EC
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(._6_A_4_C_4_C, for: .normal)
        $0.titleLabel?.font = .giftyFont(size: 18)
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

    @objc private func archiveButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onArchive?()
        }
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
            titleLabel,
            messageLabel,
            buttoncontainerView,
            cancelButton
        ].forEach { modalView.addSubview($0) }

        [
            archiveButton,
            deleteButton
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
            $0.height.equalTo(260)
            $0.centerX.equalTo(view)
            $0.top.equalToSuperview().inset(260)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(30)
        }

        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
        }

        buttoncontainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(messageLabel.snp.bottom).offset(20)
        }

        archiveButton.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(115)
            $0.height.equalTo(49)
        }

        deleteButton.snp.makeConstraints {
            $0.leading.equalTo(archiveButton.snp.trailing).offset(14)
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(115)
            $0.height.equalTo(49)
        }

        cancelButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(buttoncontainerView.snp.bottom).offset(12)
            $0.width.equalTo(244)
            $0.height.equalTo(45)
        }
    }
}
