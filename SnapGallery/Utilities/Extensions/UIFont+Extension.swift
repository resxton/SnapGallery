import UIKit

extension UIFont {
    static func tinkoffRegular(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "TinkoffSans-Regular", size: size) else {
            print("Шрифт TinkoffSans-Medium не найден! Используется системный")
            return .systemFont(ofSize: size, weight: .medium)
        }
        return font
    }
    
    static func tinkoffMedium(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "TinkoffSans-Medium", size: size) else {
            print("Шрифт TinkoffSans-Medium не найден! Используется системный")
            return .systemFont(ofSize: size, weight: .medium)
        }
        return font
    }
    
    static func tinkoffBold(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "TinkoffSans-Bold", size: size) else {
            print("Шрифт TinkoffSans-Medium не найден! Используется системный")
            return .systemFont(ofSize: size, weight: .medium)
        }
        return font
    }
}
