//
//  HttpServiceRequest.swift
//  Docebo
//
//  Created by Ans Riaz on 05/11/2017.
//  Copyright © 2017 LawrenceM. All rights reserved.
//

import Foundation

class HttpServiceRequest {
    func getData(url: String, completionHandler: @escaping (_ response: Data) -> ()) {
        
        let session = URLSession.shared
        let url = URL(string: url)!
        let task = session.dataTask(with: url) { (data, _, _) -> Void in
            if let data = data {
                completionHandler(data)
            }
        }
        task.resume()
    }
}
