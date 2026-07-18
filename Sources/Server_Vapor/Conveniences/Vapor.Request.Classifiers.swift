import Vapor

extension Vapor.Request {
    public var isFormSubmission: Bool {
        guard let contentType = headers.contentType else { return false }
        return contentType == .urlEncodedForm || contentType == .formData
    }

    public var isAJAXRequest: Bool {
        if headers.first(name: "X-Requested-With")?.lowercased() == "xmlhttprequest" {
            return true
        }
        return headers.accept.first?.mediaType == .json
    }
}
