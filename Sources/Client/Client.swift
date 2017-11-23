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
    public init(makeRequest: @escaping (URLComponents) -> URLRequest,
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
    public static func jsonResource(makeRequest: @escaping (URLComponents) -> URLRequest) -> Resource<T> {
        return Resource(makeRequest: makeRequest) { (data) -> T in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
    
}

// MARK: - Client Error

public enum ClientError: Error, CustomStringConvertible {
    case clientError(HTTPStatusCode)
    case serverError(HTTPStatusCode)
    case sessionError(Error)
    case parseError(Error)
    case unknown
    
    public var description: String {
        switch self {
        case .sessionError(let error):
            return "Session error: \(error)"
        case .unknown:
            return "Unknown error"
        case .clientError(let statusCode):
            return "Client error: \(statusCode)"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .parseError(let parseError):
            return "Parse error: \(parseError)"
        }
    }
    
}

// MARK: - Client Response

public struct ClientResponse<T> {
    
    /// HTTP status code.
    public let httpStatusCode: HTTPStatusCode
    
    /// HTTP response.
    public let httpResponse: HTTPURLResponse
    
    /// Value
    public let value: T
    
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
    
    /// Executes the resource request and parse the response using the parser defined in the resource.
    ///
    /// - Parameters:
    ///   - resource: resource whose request will be executed.
    ///   - completion: completion callback.
    public func execute<T>(resource: Resource<T>, completion: @escaping (Result<ClientResponse<T>, ClientError>) -> Void) -> URLSessionDataTask {
        var request = resource.makeRequest(baseURLComponents)
        request = requestAdapter(request)
        return session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.sessionError(error)))
            } else if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCodeEnum
                if statusCode.isServerError {
                    completion(.failure(.serverError(statusCode)))
                } else if statusCode.isClientError {
                    completion(.failure(.clientError(statusCode)))
                } else {
                    if let data = data {
                        do {
                            let value = try resource.parse(data)
                            let valueResponse = ClientResponse(httpStatusCode: statusCode,
                                                               httpResponse: response,
                                                               value: value)
                            completion(.success(valueResponse))
                        } catch {
                            completion(.failure(.parseError(error)))
                        }
                    } else {
                        completion(.failure(.unknown))
                    }
                }
            } else {
                completion(.failure(.unknown))
            }
            }
    }
    
}
