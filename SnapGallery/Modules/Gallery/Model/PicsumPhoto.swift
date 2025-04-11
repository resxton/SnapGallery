import Foundation

struct PicsumPhoto: Decodable {
    let id: String
    let author: String
    let width: CGFloat
    let height: CGFloat
    let url: URL
    let downloadUrl: URL
}
