//
//  NetworkManager.swift
//  CombineNetwokring
//
//  Created by Marin Tutuc on 05.02.2023.
//

import Combine
import Foundation

class NetworkManager {

    // Create a shared instance of the class
    public static let shared = NetworkManager()

    // Private initializer to enforce singleton pattern
    private init() { }

    // MARK: HTTP Methods
    /**
      *  Makes a HTTP request with the given URL, HTTP Method, query parameters, body, and response type.
      *  - parameter url: URL string to make the request to
      *  - parameter method: HTTP method (GET, POST, PUT, etc.) to use in the request
      *  - parameter query: query parameters to add to the URL
      *  - parameter body: request body to send with the request
      *  - parameter responseType: Codable type to parse the response as
      *  - returns: AnyPublisher that wraps the request response or an error if one occurs
      */

    func request<T: Codable>(_ url: String,
        method: HTTPMethod,
        query: [String: String] = [:],
        body: [String: Any] = [:],
        responseType: T.Type) -> AnyPublisher<RequestResponse<T>, Error> {

        // Create a URL request with the given URL and HTTP method
        let request = createRequest(url: url, method: method, query: query, body: body)

        // Perform the request and return the response
        return performRequest(request, responseType: responseType)
    }

    /**
        *  Creates a URL request with the given URL, HTTP method, query parameters, and body
        *  - parameter url: URL string to make the request to
        *  - parameter method: HTTP method (GET, POST, PUT, etc.) to use in the request
        *  - parameter query: query parameters to add to the URL
        *  - parameter body: request body to send with the request
        *  - returns: URLRequest with the given parameters
    */
    internal func createRequest(url: String, method: HTTPMethod, query: [String: String], body: [String: Any]) -> URLRequest {
        // Attach the query parameters to the URL
        let formattedUrl = attachQueryToUrl(url, query: query)

        // Create a URL from the formatted URL string
        guard let url = URL(string: formattedUrl) else {
            // If the URL creation fails, raise a fatal error
            fatalError("Failed to create URL from \(formattedUrl)")
        }

        // Create the URL request with the URL and HTTP method
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Add headers to the request
        request.allHTTPHeaderFields = headers()

        // If there is a request body, serialize it to JSON and add it to the request
        if !body.isEmpty {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                // If the JSON serialization fails, raise a fatal error
                fatalError("Failed to serialize JSON object: \(error)")
            }
        }

        // Return the URL request
        return request
    }
    
    
    /**
     *  This is a private method that performs the actual request, given the URLRequest and the response type.
     *  It returns a Publisher with type `AnyPublisher<RequestResponse<T>, Error>`.
     *
     *  The method starts by creating a `dataTaskPublisher` from `URLSession.shared` with the provided `URLRequest`.
     *  The subscriber for the `dataTaskPublisher` is set to receive the data on a background thread.
     *  The method then maps over the received data and tries to decode it as JSON into the specified response type T,
     *  using JSONDecoder().decode().
     *  If the decoding is successful, it returns a RequestResponse with the decoded response.
     *  If decoding fails, it returns a RequestResponse with the error.
     *
     *  Finally, the publisher is erased to an AnyPublisher using eraseToAnyPublisher().
     *
     *  - Parameter request: The URLRequest to be performed.
     *  - Parameter responseType: The Codable type of the response expected from the API call.
     *  - Returns: A Publisher with type `AnyPublisher<RequestResponse<T>, Error>`.
     */

    private func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) -> AnyPublisher<RequestResponse<T>, Error> {
        return URLSession
            .shared
            .dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.global(qos: .background))
            .tryMap { element -> RequestResponse<T> in
            if let json = String(data: element.data, encoding: .utf8) {
                print("RESPONSE BODY: ------------------START------------------")
                print("RESPONSE BODY: \(String(describing: json))")
                print("RESPONSE BODY: ==================FINISH==================")
            }

            do {
                let response = try JSONDecoder().decode(T.self, from: element.data)
                return RequestResponse(response: response)
            } catch {
                return RequestResponse(error: error)
            }
        }
            .eraseToAnyPublisher()
    }

    /// Returns an empty dictionary of HTTP headers.
    internal func headers() -> [String: String] {
        return [:]
    }
    
    /// Attaches a query to a given URL as a string.
    ///
    /// - Parameters:
    ///   - url: The base URL string to which the query will be attached.
    ///   - query: A dictionary of key-value pairs that will be attached to the URL as a query.
    /// - Returns: The full URL string with the query attached.
    private func attachQueryToUrl(_ url: String, query: [String: String]) -> String {
        guard var urlComponents = URLComponents(string: url) else {
            // If the URL string can't be converted to a URL components object, return the original URL string.
            return url
        }

        let queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        // Set the query items on the URL components object.
        urlComponents.queryItems = queryItems

        // Return the full URL string, or the original URL string if the URL components object can't be converted back to a string.
        return urlComponents.string ?? url
    }

}
