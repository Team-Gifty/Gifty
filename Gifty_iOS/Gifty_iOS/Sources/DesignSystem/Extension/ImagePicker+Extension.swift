import UIKit

extension UploadViewController: UIImagePickerControllerDelegate {
    // 이미지피커 선택이 완료되면 전달되는 델리게이트
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        // 이미지를 받아와서 plusPhotoButton의 Image로
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        
        //        imageuploadButton.layer.cornerRadius = 15
        //        imageuploadButton.layer.masksToBounds = true
        //        imageuploadButton.layer.shadowColor = UIColor.CBBDB_1.cgColor
        //        imageuploadButton.layer.shadowOpacity = 100
        //        imageuploadButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        //        imageuploadButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        // UIButton에 UIImageView를 올려서 그림자랑 radius 적용하기
        
        imageuploadButton.subviews.forEach { $0.removeFromSuperview() }
        
        imageuploadButton.setTitle(nil, for: .normal)
        
        // 이미지뷰 생성
        let imageView = UIImageView()
        imageView.image = selectedImage
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true // cornerRadius 적용
        imageView.frame = imageuploadButton.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageuploadButton.addSubview(imageView)
        
        state = true
        informationButton.isEnabled = state
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
