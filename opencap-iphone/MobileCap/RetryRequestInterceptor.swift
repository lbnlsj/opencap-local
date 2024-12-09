import Alamofire

class RetryRequestInterceptor: RequestInterceptor {
    let retryLimit: Int
    
    init(retryCount: Int) {
        self.retryLimit = retryCount
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let retryCount = request.retryCount
        
        // Only retry if we haven't hit the limit
        if retryCount < retryLimit {
            // Add exponential backoff delay
            let delay = Double(retryCount + 1)
            completion(.retryWithDelay(delay))
        } else {
            completion(.doNotRetry)
        }
    }
}
