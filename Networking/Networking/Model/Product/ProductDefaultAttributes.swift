import Foundation


/// Represents a ProductDefaultAttribute entity.
///
public struct ProductDefaultAttribute: Decodable {
    public let attributeID: Int
    public let name: String?
    public let option: String?

    /// ProductAttribute initializer.
    ///
    public init(attributeID: Int,
                name: String?,
                option: String?) {
        self.attributeID = attributeID
        self.name = name
        self.option = option
    }

    /// Public initializer for ProductAttribute.
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let attributeID = try container.decode(Int.self, forKey: .attributeID)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let option = try container.decodeIfPresent(String.self, forKey: .option)

        self.init(attributeID: attributeID,
                  name: name,
                  option: option)
    }
}


/// Defines all the ProductAttribute CodingKeys.
///
private extension ProductDefaultAttribute {
    enum CodingKeys: String, CodingKey {
        case attributeID    = "id"
        case name           = "name"
        case option         = "option"
    }
}


// MARK: - Comparable Conformance
//
extension ProductDefaultAttribute: Comparable {
    public static func == (lhs: ProductDefaultAttribute, rhs: ProductDefaultAttribute) -> Bool {
        return lhs.attributeID == rhs.attributeID &&
            lhs.name == rhs.name &&
            lhs.option == rhs.option
    }

    public static func < (lhs: ProductDefaultAttribute, rhs: ProductDefaultAttribute) -> Bool {
        return lhs.attributeID < rhs.attributeID
    }
}
