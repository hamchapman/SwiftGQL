// **Source**

struct Source {
    let body: String
    let name: String
    
    init(body: String, name: String?) {
        self.body = body
        self.name = name ?? "GraphQL"
    }
}