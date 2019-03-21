import XCTest
@testable import Networking


/// ProductMapper Unit Tests
///
class ProductMapperTests: XCTestCase {

    /// Dummy Site ID.
    ///
    private let dummySiteID = 33334444

    /// Dummy Product ID.
    ///
    private let dummyProductID = 282

    /// Verifies that all of the Product Fields are parsed correctly.
    ///
    func testProductFieldsAreProperlyParsed() {
        guard let product = mapLoadProductResponse() else {
            XCTFail("Failed to parse product")
            return
        }

        XCTAssertEqual(product.siteID, dummySiteID)
        XCTAssertEqual(product.productID, dummyProductID)
        XCTAssertEqual(product.name, "Book the Green Room")
        XCTAssertEqual(product.slug, "book-the-green-room")
        XCTAssertEqual(product.permalink, "https://example.com/product/book-the-green-room/")

        let dateCreated = DateFormatter.Defaults.dateTimeFormatter.date(from: "2019-02-19T17:33:31")
        let dateModified = DateFormatter.Defaults.dateTimeFormatter.date(from: "2019-02-19T17:48:01")
        XCTAssertEqual(product.dateCreated, dateCreated)
        XCTAssertEqual(product.dateModified, dateModified)

        XCTAssertEqual(product.productTypeKey, "booking")
        XCTAssertEqual(product.statusKey, "publish")
        XCTAssertFalse(product.featured)
        XCTAssertEqual(product.catalogVisibilityKey, "visible")

        XCTAssertEqual(product.description, "<p>This is the party room!</p>\n")
        XCTAssertEqual(product.shortDescription, """
            [contact-form]\n<p>The green room&#8217;s max capacity is 30 people. Reserving the date / time of your event is free. \
            We can also accommodate large groups, with seating for 85 board game players at a time. If you have a large group, let \
            us know and we&#8217;ll send you our large group rate.</p>\n<p>GROUP RATES</p>\n<p>Reserve your event for up to 30 guests for $100.</p>\n
            """)
        XCTAssertEqual(product.sku, "")

        XCTAssertEqual(product.price, "0")
        XCTAssertEqual(product.regularPrice, "")
        XCTAssertEqual(product.salePrice, "")
        XCTAssertFalse(product.onSale)

        XCTAssertTrue(product.purchasable)
        XCTAssertEqual(product.totalSales, 0)
        XCTAssertTrue(product.virtual)

        XCTAssertFalse(product.downloadable)
        XCTAssertEqual(product.downloadLimit, -1)
        XCTAssertEqual(product.downloadExpiry, -1)

        XCTAssertEqual(product.externalURL, "")
        XCTAssertEqual(product.taxStatusKey, "taxable")
        XCTAssertEqual(product.taxClass, "")

        XCTAssertFalse(product.manageStock)
        XCTAssertNil(product.stockQuantity)
        XCTAssertEqual(product.stockStatusKey, "instock")

        XCTAssertEqual(product.backordersKey, "no")
        XCTAssertFalse(product.backordersAllowed)
        XCTAssertFalse(product.backordered)

        XCTAssertTrue(product.soldIndividually)
        XCTAssertEqual(product.weight, "")

        XCTAssertFalse(product.shippingRequired)
        XCTAssertFalse(product.shippingTaxable)
        XCTAssertEqual(product.shippingClass, "")
        XCTAssertEqual(product.shippingClassID, 0)

        XCTAssertTrue(product.reviewsAllowed)
        XCTAssertEqual(product.averageRating, "0.00")
        XCTAssertEqual(product.ratingCount, 0)

        XCTAssertEqual(product.relatedIDs, [31, 22, 369, 414, 56])
        XCTAssertEqual(product.upsellIDs, [99, 1234566])
        XCTAssertEqual(product.crossSellIDs, [1234, 234234, 3])
        XCTAssertEqual(product.parentID, 0)

        XCTAssertEqual(product.purchaseNote, "")
        XCTAssertEqual(product.images.count, 1)

        XCTAssertEqual(product.attributes.count, 2)
        XCTAssertEqual(product.defaultAttributes.count, 2)
        XCTAssertEqual(product.variations.count, 3)
        XCTAssertEqual(product.groupedProducts, [])

        XCTAssertEqual(product.menuOrder, 0)
        XCTAssertEqual(product.productType, ProductType(rawValue: "booking"))
    }

    /// Test that ProductTypeKey converts to a ProductType enum properly.
    ///
    func testThatProductTypeKeyConvertsToEnumProperly() {
        let product = mapLoadProductResponse()

        let customType = ProductType(rawValue: "booking")
        XCTAssertEqual(product?.productTypeKey, "booking")
        XCTAssertEqual(product?.productType, customType)
    }

    /// Test that categories are properly mapped.
    ///
    func testThatProductCategoriesAreProperlyMapped() {
        let product = mapLoadProductResponse()
        let categories = product?.categories
        XCTAssertEqual(categories?.count, 1)

        guard let category = product?.categories[0] else {
            XCTFail("Failed to parse product category")
            return
        }

        XCTAssertEqual(category.categoryID, 36)
        XCTAssertEqual(category.name, "Events")
        XCTAssertEqual(category.slug, "events")
        XCTAssertTrue(category.categoryID == 36)
    }

    /// Test that tags are properly mapped.
    ///
    func testThatProductTagsAreProperlyMapped() {
        let product = mapLoadProductResponse()
        let tags = product?.tags
        XCTAssertNotNil(tags)
        XCTAssertEqual(tags?.count, 9)

        let tag = tags?[2]
        XCTAssertEqual(tag?.tagID, 45)
        XCTAssertEqual(tag?.name, "birthday party")
        XCTAssertEqual(tag?.slug, "birthday-party")
    }

    /// Test that product images are properly mapped.
    ///
    func testThatProductImagesAreProperlyMapped() {
        let product = mapLoadProductResponse()

        guard let images = product?.images else {
            XCTFail("Failed to parse product category")
            return
        }
        XCTAssertEqual(images.count, 1)

        let productImage = images[0]
        let dateCreated = DateFormatter.Defaults.dateTimeFormatter.date(from: "2018-01-26T21:49:45")
        let dateModified = DateFormatter.Defaults.dateTimeFormatter.date(from: "2018-01-26T21:50:11")
        XCTAssertEqual(productImage.imageID, 19)
        XCTAssertEqual(productImage.dateCreated, dateCreated)
        XCTAssertEqual(productImage.dateModified, dateModified)
        XCTAssertEqual(productImage.src,
                       "https://somewebsite.com/thuy-nonjtpk.mystagingwebsite.com/wp-content/uploads/2018/01/vneck-tee.jpg.png")
        XCTAssertEqual(productImage.name, "Vneck Tshirt")
        XCTAssert(productImage.alt?.isEmpty == true)
    }

    /// Test that product attributes are properly mapped
    ///
    func testThatProductAttributesAreProperlyMapped() {
        let product = mapLoadProductResponse()
        let attributes = product?.attributes
        XCTAssertEqual(attributes?.count, 2)

        guard let attribute = attributes?[0] else {
            XCTFail("Missing product attribute")
            return
        }

        XCTAssertEqual(attribute.attributeID, 0)
        XCTAssertEqual(attribute.name, "Size")
        XCTAssertEqual(attribute.position, 0)
        XCTAssertTrue(attribute.visible)
        XCTAssertTrue(attribute.variation)

        let option1 = attribute.options[0]
        let option2 = attribute.options[1]
        let option3 = attribute.options[2]
        XCTAssertEqual(option1, "Small")
        XCTAssertEqual(option2, "Medium")
        XCTAssertEqual(option3, "Large")
    }

    /// Test that the default product attributes map properly
    ///
    func testThatDefaultProductAttributesMapProperly() {
        let product = mapLoadProductResponse()
        let defaultAttributes = product?.defaultAttributes
        XCTAssertEqual(defaultAttributes?.count, 2)

        let attribute1 = defaultAttributes?[0]
        let attribute2 = defaultAttributes?[1]

        XCTAssertEqual(attribute1?.attributeID, 0)
        XCTAssertEqual(attribute1?.name, "Size")
        XCTAssertEqual(attribute1?.option, "Medium")

        XCTAssert(attribute2?.attributeID == 0)
        XCTAssertEqual(attribute2?.name, "Color")
        XCTAssertEqual(attribute2?.option, "Purple")
    }
}


/// Private Methods.
///
private extension ProductMapperTests {

    /// Returns the ProductMapper output upon receiving `filename` (Data Encoded)
    ///
    func mapProduct(from filename: String) -> Product? {
        guard let response = Loader.contentsOf(filename) else {
            return nil
        }

        return try! ProductMapper(siteID: dummySiteID).map(response: response)
    }

    /// Returns the ProductMapper output upon receiving `product`
    ///
    func mapLoadProductResponse() -> Product? {
        return mapProduct(from: "product")
    }
}
