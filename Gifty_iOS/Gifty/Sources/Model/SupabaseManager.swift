import Foundation
import Supabase
import UIKit

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private let supabaseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("Supabase URL not found in Info.plist")
        }
        return url
    }()
    
    private let supabaseKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("Supabase Key not found in Info.plist")
        }
        return key
    }()
    
    private lazy var client: SupabaseClient = {
        return SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }()
    
    private init() {}
    
    func shareGift(_ gift: Gift, completion: @escaping (Result<String, Error>) -> Void) {
        print("===== Supabase 기프티콘 공유 시작 =====")
        
        let sharedGiftId = UUID().uuidString
        print("✅ 공유 ID 생성: \(sharedGiftId)")
        
        uploadImage(gift: gift, sharedGiftId: sharedGiftId) { [weak self] result in
            switch result {
            case .success(let imageUrl):
                print("✅ 이미지 업로드 성공: \(imageUrl)")
                self?.saveGiftToDatabase(
                    gift: gift,
                    sharedGiftId: sharedGiftId,
                    imageUrl: imageUrl,
                    completion: completion
                )
                
            case .failure(let error):
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
                self?.saveGiftToDatabase(
                    gift: gift,
                    sharedGiftId: sharedGiftId,
                    imageUrl: nil,
                    completion: completion
                )
            }
        }
    }

    private func uploadImage(gift: Gift, sharedGiftId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appendingPathComponent(gift.imagePath)
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            completion(.failure(NSError(domain: "SupabaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지를 읽을 수 없습니다"])))
            return
        }
        
        print("📤 Supabase Storage에 이미지 업로드 중...")
        
        let fileName = "\(sharedGiftId).jpg"
        
        Task {
            do {
                let uploadedFile = try await client.storage
                    .from("gifts")
                    .upload(
                        path: fileName,
                        file: imageData,
                        options: FileOptions(
                            contentType: "image/jpeg"
                        )
                    )

                let publicURL = try client.storage
                    .from("gifts")
                    .getPublicURL(path: fileName)
                
                print("✅ Supabase 이미지 업로드 성공")
                completion(.success(publicURL.absoluteString))
                
            } catch {
                print("❌ Supabase 이미지 업로드 실패: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func saveGiftToDatabase(gift: Gift, sharedGiftId: String, imageUrl: String?, completion: @escaping (Result<String, Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        struct SharedGift: Encodable {
            let id: String
            let name: String
            let usage: String
            let expiry_date: String
            let memo: String
            let image_url: String?
        }
        
        let giftData = SharedGift(
            id: sharedGiftId,
            name: gift.name,
            usage: gift.usage,
            expiry_date: dateFormatter.string(from: gift.expiryDate),
            memo: gift.memo ?? "",
            image_url: imageUrl
        )
        
        print("💾 Supabase Database에 저장 중...")
        
        Task {
            do {
                try await client.database
                    .from("shared_gifts")
                    .insert(giftData)
                    .execute()
                
                print("✅ Supabase Database 저장 성공: \(sharedGiftId)")
                print("===========================")
                completion(.success(sharedGiftId))
                
            } catch {
                print("❌ Supabase Database 저장 실패: \(error.localizedDescription)")
                print("===========================")
                completion(.failure(error))
            }
        }
    }
    
    func receiveGift(sharedGiftId: String, completion: @escaping (Result<Gift, Error>) -> Void) {
        print("===== Supabase 기프티콘 받기 시작 =====")
        print("공유 ID: \(sharedGiftId)")
        
        Task {
            do {
                struct SharedGiftResponse: Decodable {
                    let id: String
                    let name: String
                    let usage: String
                    let expiry_date: String
                    let memo: String?
                    let image_url: String?
                }

                let response: SharedGiftResponse = try await client.database
                    .from("shared_gifts")
                    .select()
                    .eq("id", value: sharedGiftId)
                    .single()
                    .execute()
                    .value
                
                print("✅ Supabase 데이터 조회 성공")
                
                let name = response.name
                let usage = response.usage
                let expiryDateString = response.expiry_date
                let imageUrl = response.image_url
                let memo = response.memo
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let expiryDate = dateFormatter.date(from: expiryDateString) else {
                    print("❌ 날짜 변환 실패")
                    throw NSError(domain: "SupabaseManager", code: -5, userInfo: [NSLocalizedDescriptionKey: "유효기간 데이터가 손상되었습니다"])
                }
                
                if let imageUrl = imageUrl {
                    print("📥 이미지 다운로드 중...")
                    
                    self.downloadImage(from: imageUrl) { result in
                        switch result {
                        case .success(let localImagePath):
                            self.saveGiftToRealm(
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
                    
                    self.saveGiftToRealm(
                        name: name,
                        usage: usage,
                        expiryDate: expiryDate,
                        memo: memo,
                        imagePath: defaultImagePath,
                        completion: completion
                    )
                }
                
            } catch {
                print("❌ Supabase 조회 실패: \(error.localizedDescription)")
                print("===========================")
                completion(.failure(NSError(domain: "SupabaseManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "공유된 기프티콘을 찾을 수 없습니다. 링크가 만료되었거나 잘못되었습니다."])))
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
            completion(.failure(NSError(domain: "SupabaseManager", code: -6, userInfo: [NSLocalizedDescriptionKey: "잘못된 이미지 URL입니다"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(NSError(domain: "SupabaseManager", code: -7, userInfo: [NSLocalizedDescriptionKey: "이미지 데이터를 읽을 수 없습니다"])))
                return
            }
            
            let fileName = "\(UUID().uuidString).jpg"
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(NSError(domain: "SupabaseManager", code: -8, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])))
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
