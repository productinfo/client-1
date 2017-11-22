# Client

[![Build Status](https://travis-ci.org/pepibumur/client.svg?branch=master)](https://travis-ci.org/pepibumur/client)

Client is an HTTP client for Swift inspired by the [objc.io networking talk](https://talk.objc.io/episodes/S01E01-networking)

## Setup

Add the following line to your `Podfile` and execute `pod install`:

```ruby
pod "Client", :git => "https://github.com/pepibumur/Client.git"
```

## Usage

```swift
// Create an instance of your client
let client = Client(baseURLComponents: URLComponents(string: "https://api.myservice.com")!) { request in 
    // You can use this adapter to inject headers in the requests (e.g. session token)
    return request
}

// Define the models that we get from the API
struct User: Codable {
    let name: String
}

// Define API resources
extension User {
    // A resource defines:
    // 1: How the request is generated from base URL components.
    // 2. How the response data is parsed into the model. 
    var me: Resource<User> {
        return Resource.jsonResource { (components: URLComponents) -> URLRequest in
            var mutableComponents = components
            mutableComponents.path = "/me"
            var request = URLRequest(url: mutableComponents.url!)
            request.httpMethod = "GET"
            return request
        }
    }
}

// We pass the resource to the client with a callback that gets
// notified when the request and parsing completes
client.execute(resource: User.me) { (result) in
    if let error = result.error {
        
    } else if let value = result.value {
        
    }
}
```

## License

```
The MIT License (MIT)

Copyright (c) 2017 Pedro Piñera

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
