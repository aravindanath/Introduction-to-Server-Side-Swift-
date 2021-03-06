import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    
    /*
        - /posts GET  will show us all of the posts
        - /posts POST will create a new post for us
        - /posts/:id GET will show us the post at :id
     
 
    */
    
    
    router.group("posts") { (posts) in
        // posts/
        posts.get("/") { req -> Response in
            struct Context: Content {
                var post: String
                var from: String
                // { post: "Hello World", from:"Johann" }
            }
            
            let response = Response(using: req)
            try response.content.encode(Context(post: "hello World", from: "Johann"))
            
            
            return response
        }
        
    }
  
    
    // Example of creating a Service and using it.
    router.get("hash", String.parameter) { req -> String in
        // Create a BCryptHasher using the Request's Container
        let hasher = try req.make(BCryptHasher.self)

        // Fetch the String parameter (as described in the route)
        let string = try req.parameter(String.self)

        // Return the hashed string!
        return try hasher.make(string)
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
