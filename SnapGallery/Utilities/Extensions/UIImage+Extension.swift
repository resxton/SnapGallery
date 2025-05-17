import UIKit

extension UIImage {
    func resizeImage(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)
        
        let newWidth  = size.width * scaleFactor
        let newHeight = size.height * scaleFactor
        
        let rect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: newWidth,
                height: newHeight
            ),
            false,
            0.0
        )
        self.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
