# Description
Simple Networking layer for communication via HTTP for iOS and macOS. Implement the `Requestable` protocol and use the `Requester` to send a HTTP request and get a response. See `RequestableSample` as an example.  

# Swift Package Manager
Add https://github.com/Valentin-Kalchev/networking as a Swift Package Repository in Xcode and follow the instructions to add Networking as a Swift Package.

# Example usecase inside an API module
```
public struct AccountsAPI {
    
    // MARK: - Constants.
    
    private let requestable: Requestable
    private let baseURL: String
    
    // MARK: - Life Cycle.
    
    public init(requestable: Requestable, baseURL: String) {
        
        self.requestable = requestable
        self.baseURL = baseURL
    }
}

// MARK: - Public Methods.

extension AccountsAPI: AccountsAPIProtocol {
    
    public func getAccounts() async throws -> [Account] {
        
        let url = baseURL + APIVersion.v2.rawValue + Paths.accounts.rawValue
        
        return try await requestable.performRequest(to: url, httpMethod: .get)
    }
}
```
