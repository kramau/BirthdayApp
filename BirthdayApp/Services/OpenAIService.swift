import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    func generateBirthdayMessage(for birthday: Birthday, customPrompt: String = "") async throws -> String {
        guard !apiKey.isEmpty else {
            throw OpenAIError.noApiKey
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw OpenAIError.invalidURL
        }
        
        var prompt = """
        Generate a personalized birthday message for \(birthday.name).
        
        Person details:
        - Relationship: \(birthday.relationship ?? "friend")
        - Interests: \(birthday.interests ?? "various")
        - Personality: \(birthday.personalityTraits ?? "wonderful")
        - Notes: \(birthday.notes ?? "")
        
        Make the message warm, personal, and heartfelt. Keep it between 50-150 words.
        """
        
        if !customPrompt.isEmpty {
            prompt += "\n\nAdditional instructions: \(customPrompt)"
        }
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that creates warm, personal birthday messages. Focus on making each message unique and heartfelt based on the person's details."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 200,
            "temperature": 0.7
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw OpenAIError.encodingError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OpenAIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw OpenAIError.apiError(httpResponse.statusCode)
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let message = openAIResponse.choices.first?.message.content else {
                throw OpenAIError.noMessageContent
            }
            
            return message.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as OpenAIError {
            throw error
        } catch {
            throw OpenAIError.networkError(error)
        }
    }
}

enum OpenAIError: Error, LocalizedError {
    case noApiKey
    case invalidURL
    case encodingError
    case invalidResponse
    case apiError(Int)
    case noMessageContent
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .noApiKey:
            return "OpenAI API key not configured. Please set your API key in Settings."
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request data"
        case .invalidResponse:
            return "Invalid response from OpenAI API"
        case .apiError(let statusCode):
            return "OpenAI API error (Status: \(statusCode))"
        case .noMessageContent:
            return "No message content received from OpenAI"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}