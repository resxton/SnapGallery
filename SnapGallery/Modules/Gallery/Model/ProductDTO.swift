import Foundation

struct ProductDTO: Decodable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
}

extension ProductDTO {
    func toDomain() -> Product {
        return Product(title: title, url: image)
    }
}
