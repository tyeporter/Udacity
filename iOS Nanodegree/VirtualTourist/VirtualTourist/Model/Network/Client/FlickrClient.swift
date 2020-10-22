//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Tye Porter on 5/29/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import Foundation
import UIKit

fileprivate var imageCache = NSCache<NSString, UIImage>()

class FlickrClient {
    
    //  Flickr API key (Use your own API key)
    static let apiKey = ""
    
    enum Endpoints {
        
        /// Flickr base endpoint
        static let base = "https://api.flickr.com/services/rest"
        /// Flickr API method for photo search
        static let methodParam = "?method=flickr.photos.search"
        /// Flickr photo licenses parameter
        static let licenseParam = "&license=1,2,3,4,5,6,7".replacingOccurrences(of: ",", with: "%2C")
        /// Flickr API key parameter
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        /// Flickr per page paramter (Change the number if you want to retrieve more photos)
        static let perPageParam = "&per_page=\(20)"
        /// Flickr output formate paramter
        static let formatParam = "&format=json&nojsoncallback=1"
        
        // -------------------------------------------------------------------------
        
        case getPlaceBy(lat: Double, lon: Double, keyword: String)
        case downloadPhoto(farm: String, server: String, id: String, secret: String)
        
        // -------------------------------------------------------------------------
        
        var stringValue: String {
            switch self {
            case let .getPlaceBy(lat, lon, keyword):
                return Endpoints.base + Endpoints.methodParam + Endpoints.licenseParam + Endpoints.apiKeyParam + "&text=\(keyword)" + "&lat=\(lat)" + "&lon=\(lon)" + "&radius=10" + Endpoints.perPageParam + Endpoints.formatParam
            case let .downloadPhoto(farm, server, id, secret):
                return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_n.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func downloadPhoto(farm: String, server: String, id: String, secret: String, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        let url = Endpoints.downloadPhoto(farm: farm, server: server, id: id, secret: secret).stringValue as NSString
        
        if let image = imageCache.object(forKey: url) {
            completionHandler(image, nil)
        } else {
            let task = URLSession.shared.dataTask(with: Endpoints.downloadPhoto(farm: farm, server: server, id: id, secret: secret).url) { (data: Data?, response: URLResponse?, error: Error?) in
                guard error == nil else {
                    print("unsuccessful fetching photo")
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                    return
                }
                
                guard let data = data else { return }
                
                if let poster = UIImage(data: data) {
                    imageCache.setObject(poster, forKey: url)
                    DispatchQueue.main.async {
                        completionHandler(poster, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler(nil, nil)
                    }
                }
            }
            task.resume()
        }
    }
    
    class func getPhotosForPlace(latitude: Double, longitude: Double, keyword: String, completionHandler: @escaping ([PhotoCodable], Error?) -> Void) {
        self.taskForGETRequest(url: Endpoints.getPlaceBy(lat: latitude, lon: longitude, keyword: keyword).url, responseType: GETPhotoSearchResponseCodable.self) { (response: Decodable?, error: Error?) in
            if let response = response as? GETPhotoSearchResponseCodable, response.stat == "ok" {
                completionHandler(response.photos.photo, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    // -------------------------------------------------------------------------
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            guard error == nil else {
                print("unsuccessful fetching data with url: (\(url))")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            guard let data = data else { return }
            print(url)
            let decoder = JSONDecoder()
            
            do {
                let responseData = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseData, nil)
                }
            } catch {
                print("unsuccessful decoding data response")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
}
