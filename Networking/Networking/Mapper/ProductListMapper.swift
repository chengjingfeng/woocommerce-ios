import Foundation


/// Mapper: Product List
///
struct ProductListMapper: Mapper {
    /// Site Identifier associated to the orders that will be parsed.
    /// We're injecting this field via `JSONDecoder.userInfo` because
    /// the remote endpoints don't really return the SiteID in any of
    /// the Product Endpoints.
    ///
    let siteID: Int

    /// (Attempts) to convert a dictionary into [Product].
    ///
    func map(response: Data) throws -> [Product] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.Defaults.dateTimeFormatter)
        decoder.userInfo = [
            .siteID: siteID
        ]

        return try decoder.decode(ProductListEnvelope.self, from: response).products
    }
}


/// ProductEnvelope Disposable Entity:
/// `Load Products` endpoint returns the updated products document in the `data` key.
/// This entity allows us to do parse all the things with JSONDecoder.
///
private struct ProductListEnvelope: Decodable {
    let products: [Product]

    private enum CodingKeys: String, CodingKey {
        case products = "data"
    }
}
