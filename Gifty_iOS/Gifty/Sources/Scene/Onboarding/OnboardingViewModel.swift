import UIKit
import Then
import RxSwift
import RxCocoa

class OnboardingViewModel {

    struct Input {
        let buttonTap: Observable<Void>
    }

    struct Output {
        let navigateToNickname: Observable<Void>
    }

    func transform(input: Input) -> Output {
        let navigateToNickname = input.buttonTap
            .asObservable()

        return Output(
            navigateToNickname: navigateToNickname
        )
    }
}
