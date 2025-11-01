import UIKit
import SnapKit
import Then
import RealmSwift

class SearchViewController: BaseViewController {
    
    private var searchResults: Results<Gift>?
    private var currentFilter: SearchFilter = .productName
    private let filterDropDownView = FilterDropDownView()
    
    
    lazy var searchTextField = UITextField().then {
        $0.placeholder = "검색"
        $0.textColor = ._6_A_4_C_4_C
        $0.backgroundColor = UIColor.EFE_4_D_3
        $0.layer.cornerRadius = 8
        $0.font = .giftyFont(size: 28)
        
        $0.attributedPlaceholder = NSAttributedString(
            string: "검색",
            attributes: [
                .foregroundColor: UIColor.CAC_2_B_7,
                .font: UIFont.giftyFont(size: 28)
            ]
        )
        
        
        let leftImageView = UIImageView(image: UIImage(named: "searchField"))
        leftImageView.contentMode = .scaleAspectFit
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 24))
        leftImageView.frame = CGRect(x: 20, y: 2, width: 20, height: 20)
        leftContainer.addSubview(leftImageView)
        
        $0.leftView = leftContainer
        $0.leftViewMode = .always
        
        let rightButton = UIButton()
        rightButton.setImage(UIImage(named: "Filter"), for: .normal)
        rightButton.imageView?.contentMode = .scaleAspectFit
        let rightContainer = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        rightButton.frame = CGRect(x: 0, y: 4, width: 21.27, height: 13)
        rightContainer.addSubview(rightButton)
        rightButton.addTarget(self, action: #selector(toggleFilterDropdown), for: .touchUpInside)
        
        
        $0.rightView = rightContainer
        $0.rightViewMode = .always
        
    }
    
    let searchDescriptionLabel = UILabel().then {
        $0.text = "원하는 필터링으로 검색해보세요!"
        $0.textColor = ._7_F_7_D_7_D
        $0.font = .giftyFont(size: 28)
    }
    
    private let gifticonTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.register(GifticonTableViewCell.self, forCellReuseIdentifier: GifticonTableViewCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        gifticonTableView.dataSource = self
        gifticonTableView.delegate = self
        filterDropDownView.delegate = self
        filterDropDownView.isHidden = true
        updateUI()
        hideKeyboardWhenTappedAround()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    



    
    override func addView() {
        [
            searchTextField,
            searchDescriptionLabel,
            gifticonTableView,
            filterDropDownView
        ].forEach { view.addSubview($0) }
    }
    
    override func setLayout() {
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(25)
            $0.height.equalTo(50)
        }
        
        searchDescriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(searchTextField.snp.bottom).offset(246)
        }
        
        gifticonTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(31)
            $0.trailing.equalToSuperview().offset(-28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
        }
        
        filterDropDownView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(3)
            $0.trailing.equalTo(searchTextField.snp.trailing)
            $0.width.equalTo(94)
            $0.height.equalTo(54)
        }
    }
    
    private func updateUI() {
        let hasResults = !(searchResults?.isEmpty ?? true)
        gifticonTableView.isHidden = !hasResults
        searchDescriptionLabel.isHidden = hasResults
    }
    
    @objc private func toggleFilterDropdown() {
        filterDropDownView.isHidden.toggle()
    }
    
    private func performSearch() {
        if let searchText = searchTextField.text, !searchText.isEmpty {
            searchResults = RealmManager.shared.searchGifts(query: searchText, filter: currentFilter)
        } else {
            searchResults = nil
        }
        updateUI()
        gifticonTableView.reloadData()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GifticonTableViewCell.identifier, for: indexPath) as? GifticonTableViewCell,
              let gift = searchResults?[indexPath.row] else {
            return UITableViewCell()
        }
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        let image = UIImage(contentsOfFile: fileURL.path)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: gift.expiryDate)
        
        cell.configure(image: image, title: gift.name, usage: gift.usage, date: dateString)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let gift = searchResults?[indexPath.row] else { return }
        
        let gifticonVC = GifticonViewController()
        gifticonVC.gift = gift
        navigationController?.pushViewController(gifticonVC, animated: true)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        performSearch()
    }
}

extension SearchViewController: FilterDropDownViewDelegate {
    func filterButtonTapped(filter: SearchFilter) {
        self.currentFilter = filter
        filterDropDownView.isHidden = true
        performSearch()
    }
}
