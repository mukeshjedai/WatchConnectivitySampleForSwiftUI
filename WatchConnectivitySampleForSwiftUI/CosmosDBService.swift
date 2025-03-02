import SwiftUI

struct CosmosDBService {
    let cosmosDBEndpoint = "https://healthacc.documents.azure.com:443/"
    let databaseId = "ToDoList"
    let containerId = "Items"
    let authToken = "type%3Dmaster%26ver%3D1.0%26sig%3DuGDSA9XuxCDPB3e423chbiKzFDQ6FDz4/VO4S1ZspRg%3D" // Replace with the token generated from Python
    let authDate = "Sun, 02 Mar 2025 08:15:19 GMT" // Replace with the x-ms-date from Python

    func insertDataToCosmosDB(item: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(cosmosDBEndpoint)dbs/\(databaseId)/colls/\(containerId)/docs") else {
            print("Invalid URL")
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authToken, forHTTPHeaderField: "Authorization")  // Use Signed Token
        request.setValue("2018-12-31", forHTTPHeaderField: "x-ms-version")
        request.setValue(authDate, forHTTPHeaderField: "x-ms-date")  // Use the generated date
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("[\"1\"]", forHTTPHeaderField: "x-ms-documentdb-partitionkey")  // Partition Key
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: item, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding data: \(error)")
            completion(false, "Error encoding data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false, "Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    completion(true, nil)
                } else {
                    print("Failed with status code: \(httpResponse.statusCode)")
                    completion(false, "Failed with status code: \(httpResponse.statusCode)")
                }
            } else {
                completion(false, "Invalid response received")
            }
        }.resume()
    }
}

struct CosmosView: View {
    let cosmosDBService = CosmosDBService()
    
    var body: some View {
        VStack {
            Button("Insert Data") {
                let item: [String: Any] = ["id": "1", "task": "Buy groceries"]
                cosmosDBService.insertDataToCosmosDB(item: item) { success, message in
                    if success {
                        print("Data inserted successfully")
                    } else {
                        print("Failed to insert data: \(message ?? "Unknown error")")
                    }
                }
            }
        }
        .padding()
    }
}

struct CosmosView_Previews: PreviewProvider {
    static var previews: some View {
        CosmosView()
    }
}
