import Alamofire
import ReactiveSwift
import SwiftyJSON

open class ImgurDetalisator<Detail>: JsonDetalisator<Detail>
{
    open override func detail(credential: Credential) {
        let headers: HTTPHeaders = ["Authorization": "Bearer \(credential.accessToken)"]

        // Todo: check for json errors…

        Alamofire.request(Imgur.url.detail, method: HTTPMethod.get, headers: headers).reactive.responded
            .map({ JSON(data: $0) })
            .observe({ [weak self] in
                if case .value(let value) = $0 {
                    self?.detail(json: value)
                } else if case .failed(let error) = $0 {
                    self?.fail(Error.unknown(description: error.description))
                }
            })
    }
}