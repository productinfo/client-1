import Foundation
import Result

// MARK: - Resource

public struct Resource<T> {
    
    // MARK: - Attributes
    
    /// Function that makes a request given some base components.
    fileprivate let makeRequest: (URLComponents) -> URLRequest
    
    /// Function that parses data into the resource object type.
    fileprivate let parse: (Data) throws -> T
    
    /// Default Resource initializer
    ///
    /// - Parameters:
    ///   - makeRequest: function that generates the request.
    ///   - parse: function that parses the response into the resource object type.
    init(makeRequest: @escaping (URLComponents) -> URLRequest,
         parse: @escaping (Data) throws -> T) {
        self.makeRequest = makeRequest
        self.parse = parse
    }
    
}

// MARK: - Resource Extension (JSON)

extension Resource where T: Decodable {
    
    /// Returns a resource that parses the data using the JSONDecoder.
    ///
    /// - Parameter makeRequest: function that generates the request.
    /// - Returns: resource.
    static func jsonResource(makeRequest: @escaping (URLComponents) -> URLRequest) -> Resource<T> {
        return Resource(makeRequest: makeRequest) { (data) -> T in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
}

// MARK: - Client Error

enum ClientError: CustomStringConvertible {
    case sessionError(Error)
    case unknown
    
    var description: String {
        switch self {
        case .sessionError(let error):
            return "Session error: \(error)"
        case .unknown:
            return "Unknown error"
        }
    }
    
    
}

// MARK: - Client

public class Client {
    
    // MARK: - Attributes
    
    /// Base URL components.
    fileprivate let baseURLComponents: URLComponents
    
    /// Function that adapts the request before sending it.
    fileprivate let requestAdapter: (URLRequest) -> URLRequest
    
    /// Session.
    fileprivate let session: URLSession
    
    // MARK: - Init
    
    public init(baseURLComponents: URLComponents,
                session: URLSession = .shared,
                requestAdapter: @escaping (URLRequest) -> URLRequest = { $0 }) {
        self.baseURLComponents = baseURLComponents
        self.requestAdapter = requestAdapter
        self.session = session
    }
    
    public func execute<T>(resource: Resource<T>) {
        var request = resource.makeRequest(baseURLComponents)
        request = requestAdapter(request)
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                
            } else if let response = response as? HTTPURLResponse, let data = data {
                
            } else {
                
            }
        }.resume()
    }
    
}


