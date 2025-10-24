import UIKit

public struct TabItemInfo {
    let image: UIImage
    let selectedImage: UIImage
    let tag: Int
}

public enum GiftyTabBarStyle: Int {
    case home, add, search
    
    func tabItemTuple() -> TabItemInfo {
        switch self {
        case .home:
            return .init(
                image: .home,
                selectedImage: .homeSelected,
                tag: 0
            )
        case .add:
            return .init(
                image: .plus,
                selectedImage: .plusSelected,
                tag: 1
            )
        case .search:
            return .init(
                image: .search,
                selectedImage: .searchSelected,
                tag: 2
            )
        }
    }
}


public class GiftyTabBarItem: UITabBarItem {
    public init(_ type: GiftyTabBarStyle) {
        super.init()
        let info = type.tabItemTuple()
        
        self.image = info.image
        self.selectedImage = info.selectedImage
        self.tag = info.tag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
