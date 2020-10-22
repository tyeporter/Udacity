//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Tye Porter on 5/11/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static var accountKey = ""
        static var sessionId = ""
        static var firstName = ""
        static var lastName = ""
        static var emailAddress = ""
        static var objectId = ""
        static var shareLocationType: ShareLocationType = .create
    }
    
    enum HTTPMethod: String { case GET, POST, PUT, DELETE }
    enum ShareLocationType { case create, update }
    
    enum Endpoints {
        
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case getStudentLocations
        case getUserLocation(withUniqueKey: String)
        case createStudentLocation
        case updateStudentLocation
        case createSession
        case deleteSession
        case getUserData
        
        var stringValue: String {
            switch self {
            case .getStudentLocations:
                return Endpoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .getUserLocation(let uniqueKey):
                return Endpoints.base + "StudentLocation?uniqueKey=\(uniqueKey)"
            case .createStudentLocation:
                return Endpoints.base + "StudentLocation"
            case .updateStudentLocation:
                return Endpoints.base + "StudentLocation/\(Auth.objectId)"
            case .createSession:
                return Endpoints.base + "session"
            case .deleteSession:
                return Endpoints.base + "session"
            case .getUserData:
                return Endpoints.base + "users/" + Auth.accountKey
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    class func getUserData(completionHandler: @escaping (Bool, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getUserData.url) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("problem fetching user data")
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            
            guard var data = data else { return }
            let range = 5..<data.count
            data = data.subdata(in: range)
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                let emailDict = jsonData?["email"] as? [String: Any]
                Auth.firstName = jsonData?["first_name"] as? String ?? ""
                Auth.lastName = jsonData?["last_name"] as? String ?? ""
                Auth.emailAddress = emailDict?["address"] as? String ?? ""
                DispatchQueue.main.async {                    
                    completionHandler(true, nil)
                }
            } catch {
                print("unsuccessful parsing user data")
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func deleteSession(completionHandler: @escaping (Bool, Error?) -> Void) {
        var request = URLRequest(url: Endpoints.deleteSession.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("problem deleting session")
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
                return
            }
            
            guard var data = data else { return }
            let range = 5..<data.count
            data = data.subdata(in: range)
            let decoder = JSONDecoder()
            
            do {
                let responseData = try decoder.decode(DELETESessionResponseCodable.self, from: data)
                print(responseData)
                Auth.accountKey = ""; Auth.sessionId = "" ;Auth.firstName = ""
                Auth.lastName = ""; Auth.emailAddress = ""; Auth.objectId = ""
                Auth.shareLocationType = .create; StudentLocationModel.locations = []
                DispatchQueue.main.async {
                    completionHandler(true, nil)
                }
            } catch {
                print("problem parsing DELETE session response")
                DispatchQueue.main.async {
                    completionHandler(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func createSession(username: String, password: String, completionHandler: @escaping (Bool, Error?) -> Void) {
        let httpBody = POSTSessionRequestCodable(udacity: LoginCodable(username: username, password: password))
        self.taskForRequest(method: .POST, url: Endpoints.createSession.url, requestType: POSTSessionRequestCodable.self, reponseType: POSTSessionResponseCodable.self, httpBody: httpBody, secureData: true) { (response: Decodable?, error: Error?) in
            if let response = response as? POSTSessionResponseCodable {
                Auth.accountKey = response.account.key
                Auth.sessionId = response.session.id
                completionHandler(response.account.isRegistered, nil)
            } else {
                print("unsuccessful creating session")
                completionHandler(false, error)
            }
        }
    }
    
    class func putStudentLocation(locationString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (Bool, Error?) -> Void) {
        let httpBody = POSTLocationRequestCodable(uniqueKey: Auth.accountKey, firstName: Auth.firstName, lastName: Auth.lastName, mapString: locationString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        self.taskForRequest(method: .PUT, url: Endpoints.updateStudentLocation.url, requestType: POSTLocationRequestCodable.self, reponseType: PUTLocationResponseCodable.self, httpBody: httpBody, secureData: false) { (response: Decodable?, error: Error?) in
            if let response = response as? PUTLocationResponseCodable {
                print("User location updated at: \(response.updatedAt)")
                completionHandler(true, nil)
            } else {
                print("unsuccessful updating user location")
                completionHandler(false, error)
            }
        }
    }
    
    class func postStudentLocation(locationString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (Bool, Error?) -> Void) {
        let httpBody = POSTLocationRequestCodable(uniqueKey: Auth.accountKey, firstName: Auth.firstName, lastName: Auth.lastName, mapString: locationString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
        self.taskForRequest(method: .POST, url: Endpoints.createStudentLocation.url, requestType: POSTLocationRequestCodable.self, reponseType: POSTLocationResponseCodable.self, httpBody: httpBody, secureData: false) { (response: Decodable?, error: Error?) in
            if let response = response as? POSTLocationResponseCodable {
                Auth.objectId = response.objectId
                completionHandler(true, nil)
            } else {
                print("unsuccessful posting user location")
                completionHandler(false, error)
            }
        }
    }
    
    class func getUserLocation(uniqueKey: String, completionHandler: @escaping ([StudentLocationCodable], Error?) -> Void) {
        self.taskForRequest(method: .GET, url: Endpoints.getUserLocation(withUniqueKey: uniqueKey).url, requestType: AbstractCodable.self, reponseType: GETStudentLocationsResponseCodable.self, secureData: false) { (response: Decodable?, error: Error?) in
            if let response = response as? GETStudentLocationsResponseCodable {
                completionHandler(response.results, nil)
            } else {
                print("user doesn't have a location")
                completionHandler([], error)
            }
        }
    }
    
    class func getStudentLocations(completionHandler: @escaping ([StudentLocationCodable], Error?) -> Void) {
        self.taskForRequest(method: .GET, url: Endpoints.getStudentLocations.url, requestType: AbstractCodable.self, reponseType: GETStudentLocationsResponseCodable.self, secureData: false) { (response: Decodable?, error: Error?) in
            if let response = response as? GETStudentLocationsResponseCodable {
                completionHandler(response.results, nil)
            } else {
                print("unsuccessful fetching student locations")
                completionHandler([], error)
            }
        }
    }
    
    class func taskForRequest<RequestType: Encodable, ResponseType: Decodable>(method: HTTPMethod, url: URL, requestType: RequestType.Type, reponseType: ResponseType.Type, httpBody: RequestType? = nil, secureData: Bool, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var request: URLRequest? = nil
        if method != .GET {
            request = URLRequest(url: url)
            request?.httpMethod = method.rawValue
            if secureData { request?.addValue("application/json", forHTTPHeaderField: "Accept") }
            request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBodyJSON = try? JSONEncoder().encode(httpBody) else { return }
            request?.httpBody = httpBodyJSON
            
            let task = URLSession.shared.dataTask(with: request!) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                    return
                }
                
                guard var data = data else { return }
                if secureData {
                    let range = 5..<data.count
                    data = data.subdata(in: range)
                }
                let decoder = JSONDecoder()
                
                do {
                    let responseData = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(responseData, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
            task.resume()
        } else {
            let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                    return
                }
                
                guard var data = data else { return }
                if secureData {
                    let range = 5..<data.count
                    data = data.subdata(in: range)
                }
                let decoder = JSONDecoder()
                
                do {
                    let responseData = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(responseData, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
            task.resume()
        }
    }
    
}
