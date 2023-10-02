import Foundation

public final class InAppPurchaseReceipt {
    public var data: Data? {
        if let url = Bundle.main.appStoreReceiptURL,
           let data = try? Data(contentsOf: url),
           data.isEmpty == false {
            return data
        }
        return nil
    }
    
    public var modificationAttribute: Double {
        if let url = Bundle.main.appStoreReceiptURL,
           let date = try? url.resourceValues(forKeys: [URLResourceKey.attributeModificationDateKey]).attributeModificationDate {
            let t: Double = date.timeIntervalSince1970
            return round(t / 10.0) * 10.0
        }
        return 0
    }

}
