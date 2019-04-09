/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

enum AcronymUserRequestResult {
  case success(User)
  case failure
}

enum CategoryAddResult {
  case success
  case failure
}

struct AcronymRequest {
  let resource: URL
  
  init(acronymID: Int) {
    let resourceString = "http://89.173.194.229:8080/api/acronyms/\(acronymID)"
    guard let url = URL(string: resourceString) else { fatalError() }
    
    self.resource = url
  }
  
  func getUser(_ completion: @escaping (AcronymUserRequestResult) -> Void) {
    let url = resource.appendingPathComponent("user")
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
      guard let jsonData = data else {
        completion(.failure)
        return
      }
      
      do {
        let user = try JSONDecoder().decode(User.self, from: jsonData)
        completion(.success(user))
      } catch {
        completion(.failure)
      }
    }
    
    dataTask.resume()
  }
  
  func getCategories(_ completion: @escaping (GetResourcesRequest<Category>) -> Void) {
    let url = resource.appendingPathComponent("categories")
    let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
      guard let jsonData = data else {
        completion(.failure)
        return
      }
      
      do {
        let categories = try JSONDecoder().decode([Category].self, from: jsonData)
        completion(.success(categories))
      } catch {
        completion(.failure)
      }
    }
    
    dataTask.resume()
  }
  
  func update(with updateData: Acronym, _ completion: @escaping (SaveResult<Acronym>) -> Void) {
    do {
      var urlRequest = URLRequest(url: resource)
      urlRequest.httpMethod = "PUT"
      urlRequest.httpBody = try JSONEncoder().encode(updateData)
      urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
      let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else {
          completion(.failure)
          return
        }
        
        do {
          let acronym = try JSONDecoder().decode(Acronym.self, from: jsonData)
          completion(.success(acronym))
        } catch {
          completion(.failure)
        }
      }
      dataTask.resume()
    } catch {
      completion(.failure)
    }
  }
  
  func delete() {
    var urlRequest = URLRequest(url: resource)
    urlRequest.httpMethod = "DELETE"
    let dataTask = URLSession.shared.dataTask(with: urlRequest)
    dataTask.resume()
  }
  
  func add(category: Category, _ completion: @escaping (CategoryAddResult) -> Void) {
    guard let categoryId = category.id else {
      completion(.failure)
      return
    }
    
    let url = resource.appendingPathComponent("categories").appendingPathComponent("\(categoryId)")
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    let dataTask = URLSession.shared.dataTask(with: request) { _, response, _ in
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
        completion(.failure)
        return
      }
      completion(.success)
    }
    
    dataTask.resume()
  }
}
