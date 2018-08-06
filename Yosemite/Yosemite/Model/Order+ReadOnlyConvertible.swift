import Foundation
import Storage


// MARK: - Storage.Order: ReadOnlyConvertible
//
extension Storage.Order: ReadOnlyConvertible {

    /// Indicates if the receiver is the Storage.Entity, backing up the specified ReadOnly.Entity.
    ///
    public func represents(readOnlyEntity: Any) -> Bool {
        guard let readOnlyOrder = readOnlyEntity as? Yosemite.Order else {
            return false
        }

        return readOnlyOrder.siteID == Int(siteID) && readOnlyOrder.orderID == Int(orderID)
    }

    /// Updates the Storage.Order with the ReadOnly.
    ///
    public func update(with order: Yosemite.Order) {
        siteID = Int64(order.siteID)
        orderID = Int64(order.orderID)
        parentID = Int64(order.parentID)
        customerID = Int64(order.customerID)
        number = order.number
        status = order.status.rawValue
        currency = order.currency
        customerNote = order.customerNote

        dateCreated = order.dateCreated
        dateModified = order.dateModified
        datePaid = order.datePaid

        discountTotal = order.discountTotal
        discountTax = order.discountTax
        shippingTotal = order.shippingTotal
        shippingTax = order.shippingTax
        total = order.total
        totalTax = order.totalTax
        paymentMethodTitle = order.paymentMethodTitle

        billingFirstName = order.billingAddress.firstName
        billingLastName = order.billingAddress.lastName
        billingCompany = order.billingAddress.company
        billingAddress1 = order.billingAddress.address1
        billingAddress2 = order.billingAddress.address2
        billingCity = order.billingAddress.city
        billingState = order.billingAddress.state
        billingPostcode = order.billingAddress.postcode
        billingCountry = order.billingAddress.country
        billingPhone = order.billingAddress.phone
        billingEmail = order.billingAddress.email

        shippingFirstName = order.shippingAddress.firstName
        shippingLastName = order.shippingAddress.lastName
        shippingCompany = order.shippingAddress.company
        shippingAddress1 = order.shippingAddress.address1
        shippingAddress2 = order.shippingAddress.address2
        shippingCity = order.shippingAddress.city
        shippingState = order.shippingAddress.state
        shippingPostcode = order.shippingAddress.postcode
        shippingCountry = order.shippingAddress.country
        shippingPhone = order.shippingAddress.phone
        shippingEmail = order.shippingAddress.email
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> Yosemite.Order {
        let orderItems = items?.map { $0.toReadOnly() } ?? [Yosemite.OrderItem]()
        let orderCoupons = coupons?.map { $0.toReadOnly() } ?? [Yosemite.OrderCouponLine]()

        return Order(siteID: Int(siteID),
                     orderID: Int(orderID),
                     parentID: Int(parentID),
                     customerID: Int(customerID),
                     number: number ?? "",
                     status: OrderStatus(rawValue: status),
                     currency: currency ?? "",
                     customerNote: customerNote ?? "",
                     dateCreated: dateCreated ?? Date(),
                     dateModified: dateModified ?? Date(),
                     datePaid: datePaid ?? Date(),
                     discountTotal: discountTotal ?? "",
                     discountTax: discountTax ?? "",
                     shippingTotal: shippingTotal ?? "",
                     shippingTax: shippingTax ?? "",
                     total: total ?? "",
                     totalTax: totalTax ?? "",
                     paymentMethodTitle: paymentMethodTitle ?? "",
                     items: orderItems,
                     billingAddress: createReadOnlyBillingAddress(),
                     shippingAddress: createReadOnlyShippingAddress(),
                     coupons: orderCoupons)
    }


    // MARK: - Private Helpers

    private func createReadOnlyBillingAddress() -> Yosemite.Address {
        return Address(firstName: billingFirstName ?? "",
                       lastName: billingLastName ?? "",
                       company: billingCompany ?? "",
                       address1: billingAddress1 ?? "",
                       address2: billingAddress2 ?? "",
                       city: billingCity ?? "",
                       state: billingState ?? "",
                       postcode: billingPostcode ?? "",
                       country: billingCountry ?? "",
                       phone: billingPhone ?? "",
                       email: billingEmail ?? "")
    }

    private func createReadOnlyShippingAddress() -> Yosemite.Address {
        return Address(firstName: shippingFirstName ?? "",
                       lastName: shippingLastName ?? "",
                       company: shippingCompany ?? "",
                       address1: shippingAddress1 ?? "",
                       address2: shippingAddress2 ?? "",
                       city: shippingCity ?? "",
                       state: shippingState ?? "",
                       postcode: shippingPostcode ?? "",
                       country: shippingCountry ?? "",
                       phone: shippingPhone ?? "",
                       email: shippingEmail ?? "")
    }
}
