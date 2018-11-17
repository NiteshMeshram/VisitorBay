//
//  ServerManager.swift
//  
//
//  Created by Nitesh Meshram on 28/06/18.
//

import Foundation
import Alamofire
import SwiftyJSON
import SKActivityIndicatorView

let requestTimeOut: TimeInterval = 45 // 45 seconds
let successStatusRange: ClosedRange = 200...299

public typealias ProgressClousure = ((Double) -> Void)?


enum Result<ValueType, ErrorType> {
    case success(ValueType)
    case failure(ErrorType)
}

enum ResultPostTextMessage<ErrorType> {
    case success()
    case failure(ErrorType)
}


let apiURLPath: String = "http://dev.visitorbay.com/api"


class ServerManager {
    
    var fnsSessionId: String?
    
    let networkReachabilityManager = NetworkReachabilityManager(host: "www.apple.com")
    
    let defaultManager: Alamofire.SessionManager = {
        
        /*
         let serverTrustPolicies: [String: ServerTrustPolicy] = [
         Configuration.sharedConfiguration.urlHost: .disableEvaluation
         ]
         */
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = requestTimeOut
        
        return Alamofire.SessionManager(
            configuration: configuration
            //serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    func suspendCurrentRequests() {
        print("suspend requests")
        
        let session = defaultManager.session
        session.getAllTasks() { tasks in
            tasks.forEach {
                $0.suspend()
            }
        }
    }
    
    func resumeCurrentRequests() {
        print("resume requests")
        let session = defaultManager.session
        session.getAllTasks() { tasks in
            tasks.forEach {
                $0.resume()
            }
        }
        
    }
    var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager?.backgroundCompletionHandler
        }
        set {
            if  let backgroundManager = backgroundManager {
                backgroundManager.backgroundCompletionHandler = newValue
            }
            
        }
    }
    private lazy var backgroundManager: Alamofire.SessionManager? = {
        let bundleIdentifier = Bundle.main.bundleIdentifier
        return Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: bundleIdentifier! + ".background"))
    }()
    
    func cancelAllRequest() {
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler {
            dataTasks, uploadTasks, downloadTasks in
            
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        
        backgroundManager?.session.getTasksWithCompletionHandler {
            dataTasks, uploadTasks, downloadTasks in
            
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        
        defaultManager.session.getTasksWithCompletionHandler {
            dataTasks, uploadTasks, downloadTasks in
            
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        
    }
    
    //    MARK: Reachablity check
    private func listenForReachability() {
        networkReachabilityManager?.listener = { status in
            print("Network Status Changed: \(status)")
            switch status {
            case .notReachable:
                print("notReachable")
                self.cancelAllRequest()
            case .reachable(_):
                print("reachable")
            case .unknown:
                print("unknown")
            }
        }
        networkReachabilityManager?.startListening()
    }
    
    //    MARK: - Singleton object
    class func sharedInstance() -> ServerManager {
        struct Static {
            // Singleton instance. Initializing Server manager.
            static let sharedInstance = ServerManager()
        }
        /** @return Returns the default singleton instance. */
        return Static.sharedInstance
    }
    init() {
        
    }
    
    
    //    MARK: - Get headers
    var headers: HTTPHeaders {
        get {
            var headers: HTTPHeaders = [
                //"appKey": appKey,
                "Content-type": "text/html",
                "Accept": "text/html"
            ]
            
            return headers
        }
    }
    
    //    MARK: - PostRequest
    func postRequest(postData: Parameters?, apiName: URI, extraHeader: JSON?, closure: @escaping (Result<JSON, String>) -> Void) {
        
        if !(networkReachabilityManager?.isReachable)! {
            closure(.failure("Check your internet connection."))
            return
        }
        var localHeaders = headers
        //        headers["sessR3s0uionId"] = sessionId
        if let extraHeader = extraHeader {
            for key in extraHeader.dictionaryValue.keys {
                print(key)
                if let keyValue = extraHeader.dictionaryValue[key] {
                    print(keyValue)
                    print(keyValue.string!)
                    localHeaders[key] = keyValue.string
                    print(localHeaders)
                }
            }
        }
        
        SKActivityIndicator.show("Loading...", userInteractionStatus: true)
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        
        defaultManager.request(urlString, method: .post, parameters: postData!, encoding: JSONEncoding.default, headers: nil).validate().responseJSON{
            response in
            
            SKActivityIndicator.dismiss()
            
            print("Response \(response)")
            
            switch response.result {
            case .success(let value):
                let swiftyJson = JSON(value)
                closure(.success(swiftyJson))
            case .failure(let error):
                closure(.failure(error.localizedDescription))
                print("Post Reponse Error")
            }
        }
    }
    
    
    //        MARK: - Get Request
    func getRequest(queryStringData: Parameters?, apiName: URI, extraHeader: JSON?, closure: @escaping (Result<JSON, String>) -> Void) {
        
        if !(networkReachabilityManager?.isReachable)! {
            //closure(.failure(.noInternet(message: noNetwork, statusCode: 000)))
            return
        }
        var localHeaders = headers
        
        if let extraHeader = extraHeader {
            for key in extraHeader.dictionaryValue.keys {
                if let keyValue = extraHeader.dictionaryValue[key] {
                    localHeaders[key] = keyValue.string
                }
            }
        }
        
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        
        defaultManager.request(urlString, method: .get, parameters: queryStringData!, headers: localHeaders).validate().responseJSON {
            response in
//                        debugPrint(response)
            switch response.result {
            case .success(let value):
//                print(value)
                let swiftyJson = JSON(value)
                closure(.success(swiftyJson))
                
            case .failure(let error):
                print("Server error \(error)")
                closure(.failure(error.localizedDescription))
                
            }
            
        }
    }
    
    //        MARK: - PUT Request
    func putRequest(toUpdateData: Parameters?, apiName: URI, closure: @escaping (Result<JSON, Error>) -> Void) {
        
        if !(networkReachabilityManager?.isReachable)! {
            //closure(.failure(.noInternet(message: noNetwork, statusCode: 000)))
            return
        }
        let localHeaders = headers
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        var updateDataParameters = toUpdateData
        
        if let updateData = toUpdateData {
            updateDataParameters = updateData
        }
        
        defaultManager.request(urlString, method: .put, parameters: updateDataParameters, encoding: JSONEncoding.default, headers: localHeaders).validate().responseData {
            response in
            
            debugPrint(response)
            
            switch response.result {
            case .success(let data):
                if let result = response.result.value {
                    if let responseData = response.data {
                        if let statusCode = response.response?.statusCode {
                            if successStatusRange.contains(statusCode) {
                                //  closure(.success(result))
                            }else {
                                //  closure(.failure(self.serverError(data: responseData)))
                            }
                        }
                    }
                }
            case .failure(let error):
                
                closure(.failure(error))
            }
        }
    }
    
    //        MARK: - DELETE Request
    func deleteRequest(toUpdateData: Parameters?, apiName: URI, closure: @escaping (Result<JSON, Error>) -> Void) {
        
        if !(networkReachabilityManager?.isReachable)! {
            //closure(.failure(.noInternet(message: noNetwork, statusCode: 000)))
            return
        }
        let localHeaders = headers
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        
        var updateDataParameters = toUpdateData
        
        if let updateData = toUpdateData {
            updateDataParameters = updateData
        }
        
        defaultManager.request(urlString, method: .delete, parameters: updateDataParameters, encoding: JSONEncoding.default, headers: localHeaders).validate().responseData {
            response in
            
            debugPrint(response)
            
            switch response.result {
            case .success(let data):
                if let result = response.result.value {
                    if let responseData = response.data {
                        if let statusCode = response.response?.statusCode {
                            if successStatusRange.contains(statusCode) {
                                //closure(.success(result))
                            }else {
                                // closure(.failure(self.serverError(data: responseData)))
                            }
                        }
                    }
                }
            case .failure(let error):
                print("\(error)")
                closure(.failure(error))
            }
            
        }
    }
    
    //        MARK: - Get Avatar Request
    func downloadRequest(toUpdateData: Parameters?, apiName: URI, closure: @escaping (Result<Data, Error>) -> Void) {
        
        if !(networkReachabilityManager?.isReachable)! {
            //closure(.failure(.noInternet(message: noNetwork, statusCode: 000)))
            return
        }
        
        
        let localHeaders: HTTPHeaders = [:
            //    "appKey": appKey,
            //  "sessionId": fnsSessionId!
        ]
        
        
        
        print(localHeaders)
        
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        
        var updateDataParameters = toUpdateData
        
        if let updateData = toUpdateData {
            updateDataParameters = updateData
        }
        
        defaultManager.request(urlString, method: .get, parameters: updateDataParameters, encoding: JSONEncoding.default, headers: localHeaders).validate().responseData(completionHandler: { (response) in
            debugPrint(response)
            switch response.result {
            case .success(let data):
                if let result = response.result.value {
                    if let responseData = response.data {
                        if let statusCode = response.response?.statusCode {
                            if successStatusRange.contains(statusCode) {
                                closure(.success(result))
                            }else {
                                //   closure(.failure(error))
                            }
                        }
                    }
                }
            case .failure(let error):
                
                closure(.failure(error))
                
            }
        })
    }
    
    //    MARK:- Upload
    
    func upload(toUpload: Parameters, apiName: URI, extraHeader: JSON?, closure: @escaping (Result<Any, Error>) -> Void, progressClosure: ProgressClousure = nil) {
        
        var localHeaders: HTTPHeaders = [
            //   "appKey": appKey,
            //  "sessionId": fnsSessionId!,
            "Content-type": "multipart/form-data"
        ]
        
        
        if let extraHeader = extraHeader {
            for key in extraHeader.dictionaryValue.keys {
                if let keyValue = extraHeader.dictionaryValue[key] {
                    localHeaders[key] = keyValue.string
                }
            }
        }
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        
        defaultManager.upload(multipartFormData: { multipartFormData in
            
            if let imageData: Data = toUpload["file"] as? Data {
                if let fileName: String = toUpload["fileName"] as? String {
                    if let mimeType: String = toUpload["mimeType"] as? String {
                        
                        
                        
                        multipartFormData.append(imageData,
                                                 withName: "file",
                                                 fileName: fileName,
                                                 mimeType: mimeType)
                        if let thumbData: Data = toUpload["fileThumb"] as? Data {
                            if let thumbFileName: String = toUpload["thumbName"] as? String {
                                multipartFormData.append(thumbData,
                                                         withName: "fileThumb",
                                                         fileName: thumbFileName,
                                                         mimeType: "image/jpg")
                            }
                        }
                    }
                    
                    
                }
            }
            
        }, to: urlString, method: .post, headers: localHeaders, encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //                    print("Upload Progress: \(progress.fractionCompleted)")
                    if let progressClosure = progressClosure {
                        progressClosure(progress.fractionCompleted)
                    }
                })
                
                upload.responseJSON {
                    response in
                    if let result = response.result.value {
                        print("JSON: \(result)")
                        if let responseData = response.data {
                            if let statusCode = response.response?.statusCode {
                                if successStatusRange.contains(statusCode) {
                                    closure(.success(result))
                                }else {
                                    //closure(.failure(self.serverError(data: responseData)))
                                }
                            }
                        }
                    }else {
                        if let objc_error = response.error as? NSError {
                            //closure(.failure(.noInternet(message: noNetwork, statusCode: 000)))
                            return
                        }
                    }
                }
            case .failure(let encodingError):
                closure(.failure(encodingError))
                //closure(.failure(.unknownError(message: unknownError, statusCode: 000)))
            }
        })
    }
}

extension ServerManager {
    
    func mediaUpload(toUploads: [Parameters], apiName: URI, extraHeader: JSON?, closure: @escaping (Result<Any, Error>) -> Void, progressClosure: ProgressClousure = nil) {
        
        var localHeaders: HTTPHeaders = [
            // "appKey": appKey,
            // "sessionId": fnsSessionId!,
            "Content-type": "multipart/form-data"
        ]
        
        
        if let extraHeader = extraHeader {
            for key in extraHeader.dictionaryValue.keys {
                if let keyValue = extraHeader.dictionaryValue[key] {
                    localHeaders[key] = keyValue.string
                }
            }
        }
        
        let urlString = "\(apiURLPath)\(apiName.uriString())"
        
        defaultManager.upload(multipartFormData: { multipartFormData in
            var uploadCount = 1
            for toUpload in toUploads {
                if let imageData: Data = toUpload["file"] as? Data {
                    if let fileName: String = toUpload["fileName"] as? String {
                        if let mimeType: String = toUpload["mimeType"] as? String {
                            multipartFormData.append(imageData,
                                                     withName: "file\(uploadCount)",
                                fileName: fileName,
                                mimeType: mimeType)
                            if let thumbData: Data = toUpload["fileThumb"] as? Data {
                                if let thumbFileName: String = toUpload["thumbName"] as? String {
                                    multipartFormData.append(thumbData,
                                                             withName: "fileThumb\(uploadCount)",
                                        fileName: thumbFileName,
                                        mimeType: "image/jpg")
                                }
                            }
                            uploadCount += 1
                        }
                    }
                }
            }
            
        }, to: urlString, method: .post, headers: localHeaders, encodingCompletion: { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    //                    print("Upload Progress: \(progress.fractionCompleted)")
                    if let progressClosure = progressClosure {
                        progressClosure(progress.fractionCompleted)
                    }
                })
                
                upload.responseJSON {
                    response in
                    if let result = response.result.value {
                        if let responseData = response.data {
                            if let statusCode = response.response?.statusCode {
                                if successStatusRange.contains(statusCode) {
                                    // closure(.success(result))
                                }else {
                                    // closure(.failure(self.serverError(data: responseData)))
                                }
                            }
                        }
                    }else {
                        if let objc_error = response.error as? NSError {
                            //closure(.failure(.noInternet(message: noNetwork, statusCode: 000)))
                            return
                        }
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                closure(.failure(encodingError))
                //closure(.failure(.unknownError(message: unknownError, statusCode: 000)))
            }
        })
        
        
    }
}
