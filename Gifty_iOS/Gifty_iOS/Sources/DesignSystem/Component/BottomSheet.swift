import UIKit
import SnapKit
import Then



final class BottomSheetViewController: UIViewController {
    
    
        
    private var bottomHeight: CGFloat = 100
        
    private var insertView = UIView()
    private let dimmedBackView = UIView()
    private let bottomSheetView = UIView()
    
    private let titleLabel = UILabel()
    private let closeButton = UIButton()
    
    
    init(bottomTitle: String,
         height: CGFloat,
         insertView: UIView) {
        super.init(nibName: nil, bundle: nil)
        
        self.bottomSheetView.backgroundColor = UIColor.FFF_7_EC
        self.titleLabel.text = bottomTitle
        self.bottomHeight = height
        self.insertView = insertView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDismissAction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showBottomSheet()
    }
}


extension BottomSheetViewController {

    func showBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.dimmedBackView.backgroundColor = ._5_C_5_C_5_C.withAlphaComponent(0.45)
            self.bottomSheetView.snp.remakeConstraints {
                $0.bottom.leading.trailing.equalToSuperview()
                $0.top.equalToSuperview().inset(self.view.frame.height - self.bottomHeight)
            }
            self.view.layoutIfNeeded()
        })
    }

}

private extension BottomSheetViewController {
    
    func setupStyle() {
        bottomSheetView.do {
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.layer.cornerRadius = 16
            $0.backgroundColor = .white
        }
        
        titleLabel.do {
            $0.font = .boldSystemFont(ofSize: 18)
            $0.textColor = .black
        }
        
        closeButton.do {
            $0.setImage(UIImage(named: "Back"), for: .normal)
        }
    }
    
    func setupHierarchy() {
        [dimmedBackView, bottomSheetView].forEach { view.addSubview($0) }
        [titleLabel, closeButton, insertView].forEach { bottomSheetView.addSubview($0) }
        
    }
    
    func setupLayout() {
        dimmedBackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        insertView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(64)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setupDismissAction() {
        // x 버튼 누를 때, 바텀시트를 내리는 Action Target
        closeButton.addTarget(self, action: #selector(hideBottomSheetAction), for: .touchUpInside)
    }
    
    func updateBottomSheetLayout() {
        bottomSheetView.snp.remakeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(self.view.frame.height - self.bottomHeight)
        }
    }
    
    @objc
    func hideBottomSheetAction() {
    }
}
