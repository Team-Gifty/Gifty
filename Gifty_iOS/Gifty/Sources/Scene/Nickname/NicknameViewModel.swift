import Foundation
import RxSwift
import RxCocoa

class NicknameViewModel {

    struct Input {
        let nicknameText: Observable<String>
        let saveButtonTap: Observable<Void>
        let viewWillAppear: Observable<Void>
    }

    struct Output {
        let isButtonEnabled: Driver<Bool>
        let saveCompleted: Observable<String>
        let loadedNickname: Observable<String?>
    }

    func transform(input: Input) -> Output {
        let savedNickname = input.viewWillAppear
            .map { [weak self] _ -> String? in
                return self?.getSavedNickname()
            }

        let isButtonEnabled = input.nicknameText
            .map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)

        let saveCompleted = input.saveButtonTap
            .withLatestFrom(input.nicknameText)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .do(onNext: { [weak self] nickname in
                self?.saveNickname(nickname: nickname)
            })

        return Output(
            isButtonEnabled: isButtonEnabled,
            saveCompleted: saveCompleted,
            loadedNickname: savedNickname
        )
    }

    private func saveNickname(nickname: String) {
        RealmManager.shared.saveNickname(nickname)
    }

    private func getSavedNickname() -> String? {
        return RealmManager.shared.getUser()?.nickname
    }

    func deleteNickname() {
        RealmManager.shared.deleteUser()
    }
}
