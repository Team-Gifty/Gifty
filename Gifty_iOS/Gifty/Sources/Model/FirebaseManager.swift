import Foundation
import FirebaseFirestore
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    func shareGift(_ gift: Gift, completion: @escaping (Result<String, Error>) -> Void) {
        print("===== 기프티콘 공유 시작 =====")
        
        let sharedGiftId = UUID().uuidString
        print("✅ 공유 ID 생성: \(sharedGiftId)")
        
        saveGiftToFirestore(
            gift: gift,
            sharedGiftId: sharedGiftId,
            imageUrl: nil,
            completion: completion
        )
    }
    
    private func uploadImage(gift: Gift, sharedGiftId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 읽을 수 없습니다"])))
            return
        }
        
        print("📤 이미지 업로드 중...")
        
        let storageRef = storage.reference().child("shared_gifts/\(sharedGiftId).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ 이미지 URL 가져오기 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "FirebaseManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "다운로드 URL이 없습니다"])))
                    return
                }
                
                print("✅ 이미지 업로드 성공: \(downloadURL)")
                completion(.success(downloadURL))
            }
        }
    }
    
    private func saveGiftToFirestore(gift: Gift, sharedGiftId: String, imageUrl: String?, completion: @escaping (Result<String, Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var giftData: [String: Any] = [
            "id": sharedGiftId,
            "name": gift.name,
            "usage": gift.usage,
            "expiryDate": dateFormatter.string(from: gift.expiryDate),
            "memo": gift.memo ?? "",
            "createdAt": FieldValue.serverTimestamp(),
            "expiresAt": Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        ]
        
        if let imageUrl = imageUrl {
            giftData["imageUrl"] = imageUrl
        }
        
        print("💾 Firestore에 저장 중...")
        
        db.collection("shared_gifts").document(sharedGiftId).setData(giftData) { error in
            if let error = error {
                print("❌ Firestore 저장 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            print("✅ Firestore 저장 성공: \(sharedGiftId)")
            print("===========================")
            completion(.success(sharedGiftId))
        }
    }
    
    func receiveGift(sharedGiftId: String, completion: @escaping (Result<Gift, Error>) -> Void) {
        print("===== 기프티콘 받기 시작 =====")
        print("공유 ID: \(sharedGiftId)")
        
        db.collection("shared_gifts").document(sharedGiftId).getDocument { [weak self] document, error in
            if let error = error {
                print("❌ Firestore 조회 실패: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists,
                  let data = document.data() else {
                print("❌ 공유된 기프티콘을 찾을 수 없습니다")
                completion(.failure(NSError(domain: "FirebaseManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "공유된 기프티콘을 찾을 수 없습니다. 링크가 만료되었거나 잘못되었습니다."])))
                return
            }
            
            print("✅ Firestore 데이터 조회 성공")
            
            guard let name = data["name"] as? String,
                  let usage = data["usage"] as? String,
                  let expiryDateString = data["expiryDate"] as? String else {
                print("❌ 데이터 파싱 실패")
                completion(.failure(NSError(domain: "FirebaseManager", code: -4, userInfo: [NSLocalizedDescriptionKey: "기프티콘 데이터가 손상되었습니다"])))
                return
            }
            
            let imageUrl = data["imageUrl"] as? String
            let memo = data["memo"] as? String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let expiryDate = dateFormatter.date(from: expiryDateString) else {
                print("❌ 날짜 변환 실패")
                completion(.failure(NSError(domain: "FirebaseManager", code: -5, userInfo: [NSLocalizedDescriptionKey: "유효기간 데이터가 손상되었습니다"])))
                return
            }
            
            if let imageUrl = imageUrl {
                print("📥 이미지 다운로드 중...")
                
                self?.downloadImage(from: imageUrl) { result in
                    switch result {
                    case .success(let localImagePath):
                        self?.saveGiftToRealm(
                            name: name,
                            usage: usage,
                            expiryDate: expiryDate,
                            memo: memo,
                            imagePath: localImagePath,
                            completion: completion
                        )
                        
                    case .failure(let error):
                        print("❌ 이미지 다운로드 실패: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            } else {
                print("ℹ️ 이미지 없음 - 기본 이미지 사용")
                let defaultImagePath = "default_gift.jpg"
                
                self?.saveGiftToRealm(
                    name: name,
                    usage: usage,
                    expiryDate: expiryDate,
                    memo: memo,
                    imagePath: defaultImagePath,
                    completion: completion
                )
            }
        }
    }
    
    private func saveGiftToRealm(name: String, usage: String, expiryDate: Date, memo: String?, imagePath: String, completion: @escaping (Result<Gift, Error>) -> Void) {
        let gift = Gift()
        gift.name = name
        gift.usage = usage
        gift.expiryDate = expiryDate
        gift.memo = memo
        gift.imagePath = imagePath
        
        _ = RealmManager.shared.saveGift(
            name: gift.name,
            usage: gift.usage,
            expiryDate: gift.expiryDate,
            memo: gift.memo,
            imagePath: gift.imagePath
        )
        
        print("✅ 기프티콘 저장 완료!")
        print("===========================")
        completion(.success(gift))
    }
    
    private func downloadImage(from urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -6, userInfo: [NSLocalizedDescriptionKey: "잘못된 이미지 URL입니다"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -7, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터를 읽을 수 없습니다"])))
                return
            }
            
            let fileName = "\(UUID().uuidString).jpg"
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(NSError(domain: "FirebaseManager", code: -8, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
                return
            }
            
            do {
                try jpegData.write(to: fileURL)
                print("✅ 이미지 로컬 저장 완료: \(fileName)")
                completion(.success(fileName))
            } catch {
                print("❌ 이미지 로컬 저장 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
}
