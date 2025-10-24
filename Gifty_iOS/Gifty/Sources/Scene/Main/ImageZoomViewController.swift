import UIKit
import SnapKit
import Then

class ImageZoomViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage?
    private var originalBrightness: CGFloat = UIScreen.main.brightness

    private let scrollView = UIScrollView().then {
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 4.0
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
    }

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private let closeButton = UIButton(type: .system).then {
        $0.setTitle("닫기", for: .normal)
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        scrollView.delegate = self
        
        imageView.image = image
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(closeButton)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Setting brightness to max.")
        UIScreen.main.brightness = 1.0
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = originalBrightness
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
