//
//  HairAnalysisService.swift
//  Hair AI
//

import UIKit

struct HairAnalysisResult {
        var overallScore:         Int
        var condition:            String
        var density:              String
        var scalpHealth:          String
        var hairLossRisk:         String
        var hairType:             String
        var mainIssues:           [String]
        var recommendations:      [String]
        var oilMassageName:       String
        var oilMassageFrequency:  String
        var oilMassageTechnique:  String
        var oilMassageDuration:   String
        var oilMassageBenefits:   String
        var routineMorning:       String
        var routineEvening:       String
        var routineWeekly:        String
        var routineShampooing:    String
        var routineConditioning:  String
        var shampooRec:           String
        var conditionerRec:       String
        var treatmentRec:         String
        var productsToAvoid:      String
        var dos:                  [String]
        var donts:                [String]
        var dietTips:             [String]
        var vitaminsNeeded:       [String]
        var whenToSeeDoctor:      String
        var mealRecipes: [MealRecipe]
    }
struct MealRecipe {
    var name:        String
    var benefit:     String
    var prepTime:    String
    var ingredients: [String]
    var steps:       [String]
    var nutrients:   [String]
}

class HairAnalysisService {

    private let apiKey = "" // Add your Anthropic API key here
    private let apiURL = "https://api.anthropic.com/v1/messages"

    func analyzeHair(image: UIImage, completion: @escaping (Result<HairAnalysisResult, Error>) -> Void) {

        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "ImageError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Could not process image"])))
            return
        }
        let base64Image = imageData.base64EncodedString()

        // Build request
        guard let url = URL(string: apiURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        // Prompt
        let prompt = """
        Analyze this hair and scalp image and provide a detailed assessment.
        Respond ONLY in this exact JSON format with no extra text:
        {
          "overallScore": <number 0-100>,
          "condition": "<Excellent/Good/Fair/Poor>",
          "density": "<High/Medium/Low>",
          "scalpHealth": "<Healthy/Dry/Oily/Irritated>",
          "hairLossRisk": "<Low/Medium/High>",
          "recommendations": ["<tip1>", "<tip2>", "<tip3>"],
          "dietTips": ["<diet1>", "<diet2>", "<diet3>"]
        }
        """

        let body: [String: Any] = [
            "model": "claude-opus-4-5",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // API call
        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "DataError", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }

            // Debug — print raw response
            if let raw = String(data: data, encoding: .utf8) {
                print("Claude raw response: \(raw)")
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let content = json["content"] as? [[String: Any]],
                   let firstContent = content.first,
                   let text = firstContent["text"] as? String {

                    // Clean markdown backticks if present
                    let cleanText = text
                        .replacingOccurrences(of: "```json", with: "")
                        .replacingOccurrences(of: "```", with: "")
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if let resultData = cleanText.data(using: .utf8),
                       let result = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] {

                        if let resultData = cleanText.data(using: .utf8),
                           let result = try? JSONSerialization.jsonObject(with: resultData) as? [String: Any] {

                            let oilMassage      = result["oilMassage"]           as? [String: Any] ?? [:]
                            let routine         = result["hairCareRoutine"]       as? [String: Any] ?? [:]
                            let products        = result["productRecommendations"] as? [String: Any] ?? [:]
                            let dosAndDonts     = result["dosAndDonts"]           as? [String: Any] ?? [:]
                            // Parse meal recipes
                            var parsedRecipes: [MealRecipe] = []
                            if let recipes = result["mealRecipes"] as? [[String: Any]] {
                                for r in recipes {
                                    parsedRecipes.append(MealRecipe(
                                        name:        r["name"]        as? String   ?? "",
                                        benefit:     r["benefit"]     as? String   ?? "",
                                        prepTime:    r["prepTime"]    as? String   ?? "",
                                        ingredients: r["ingredients"] as? [String] ?? [],
                                        steps:       r["steps"]       as? [String] ?? [],
                                        nutrients:   r["nutrients"]   as? [String] ?? []
                                    ))
                                }
                            }

                            let analysisResult = HairAnalysisResult(
                                overallScore:        result["overallScore"]    as? Int    ?? 50,
                                condition:           result["condition"]       as? String ?? "Fair",
                                density:             result["density"]         as? String ?? "Medium",
                                scalpHealth:         result["scalpHealth"]     as? String ?? "Normal",
                                hairLossRisk:        result["hairLossRisk"]    as? String ?? "Medium",
                                hairType:            result["hairType"]        as? String ?? "Normal",
                                mainIssues:          result["mainIssues"]      as? [String] ?? [],
                                recommendations:     result["recommendations"] as? [String] ?? [],
                                oilMassageName:      oilMassage["recommended"] as? String ?? "Coconut Oil",
                                oilMassageFrequency: oilMassage["frequency"]   as? String ?? "2-3 times per week",
                                oilMassageTechnique: oilMassage["technique"]   as? String ?? "Gently massage in circular motions",
                                oilMassageDuration:  oilMassage["duration"]    as? String ?? "10-15 minutes",
                                oilMassageBenefits:  oilMassage["benefits"]    as? String ?? "Nourishes scalp",
                                routineMorning:      routine["morning"]         as? String ?? "",
                                routineEvening:      routine["evening"]         as? String ?? "",
                                routineWeekly:       routine["weekly"]          as? String ?? "",
                                routineShampooing:   routine["shampooing"]      as? String ?? "",
                                routineConditioning: routine["conditioning"]    as? String ?? "",
                                shampooRec:          products["shampoo"]        as? String ?? "",
                                conditionerRec:      products["conditioner"]    as? String ?? "",
                                treatmentRec:        products["treatment"]      as? String ?? "",
                                productsToAvoid:     products["avoid"]          as? String ?? "",
                                dos:                 dosAndDonts["dos"]          as? [String] ?? [],
                                donts:               dosAndDonts["donts"]        as? [String] ?? [],
                                dietTips:            result["dietTips"]          as? [String] ?? [],
                                vitaminsNeeded:      result["vitaminsNeeded"]    as? [String] ?? [],
                                whenToSeeDoctor:     result["whenToSeeDoctor"]   as? String ?? "",
                                mealRecipes:         parsedRecipes
                            )
                            DispatchQueue.main.async { completion(.success(analysisResult)) }
                        }
                    } else {
                        // Claude responded but not valid JSON
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "ParseError", code: 0,
                                userInfo: [NSLocalizedDescriptionKey: "Image unclear. Please take a better photo of your scalp."])))
                        }
                    }

                } else {
                    // Unexpected response structure
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "ResponseError", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Unexpected response from AI. Please try again."])))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    func compareHair(before: UIImage, after: UIImage,
                     completion: @escaping (Result<String, Error>) -> Void) {

        guard let beforeData = before.jpegData(compressionQuality: 0.7),
              let afterData  = after.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "ImageError", code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Could not process images"])))
            return
        }

        let beforeBase64 = beforeData.base64EncodedString()
        let afterBase64  = afterData.base64EncodedString()

        guard let url = URL(string: apiURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let prompt = """
        You are a professional trichologist (hair and scalp specialist) analyzing a hair/scalp image. 
        Provide a comprehensive, doctor-quality hair health assessment.

        Respond ONLY in this exact JSON format with no extra text or markdown:
        {
          "overallScore": <number 0-100>,
          "condition": "<Excellent/Good/Fair/Poor>",
          "density": "<High/Medium/Low>",
          "scalpHealth": "<Healthy/Dry/Oily/Irritated/Flaky/Sensitive>",
          "hairLossRisk": "<Low/Medium/High>",
          "hairType": "<Normal/Dry/Oily/Combination/Damaged>",
          "mainIssues": ["<issue1>", "<issue2>", "<issue3>"],
          "recommendations": [
            "<Specific clinical recommendation 1>",
            "<Specific clinical recommendation 2>",
            "<Specific clinical recommendation 3>",
            "<Specific clinical recommendation 4>",
            "<Specific clinical recommendation 5>"
          ],
          "oilMassage": {
            "recommended": "<oil name e.g. Coconut Oil / Castor Oil / Argan Oil / Rosemary Oil>",
            "frequency": "<e.g. 2-3 times per week>",
            "technique": "<step by step massage technique>",
            "duration": "<e.g. 10-15 minutes>",
            "benefits": "<specific benefits for this condition>"
          },
          "hairCareRoutine": {
            "morning": "<morning hair care steps>",
            "evening": "<evening hair care steps>",
            "weekly": "<weekly deep treatment>",
            "shampooing": "<how often and technique>",
            "conditioning": "<conditioning tips specific to condition>"
          },
          "productRecommendations": {
            "shampoo": "<specific type of shampoo with key ingredients to look for>",
            "conditioner": "<specific type of conditioner>",
            "treatment": "<specific treatment product or mask>",
            "avoid": "<ingredients or products to strictly avoid>"
          },
          "dosAndDonts": {
            "dos": [
              "<do 1>",
              "<do 2>",
              "<do 3>",
              "<do 4>",
              "<do 5>"
            ],
            "donts": [
              "<dont 1>",
              "<dont 2>",
              "<dont 3>",
              "<dont 4>",
              "<dont 5>"
            ]
          },
          "dietTips": [
            "<specific food with benefit>",
            "<specific food with benefit>",
            "<specific food with benefit>",
            "<specific food with benefit>",
            "<specific food with benefit>"
          ],
          "vitaminsNeeded": [
            "<vitamin/mineral with reason>",
            "<vitamin/mineral with reason>",
            "<vitamin/mineral with reason>"
          ],
          "whenToSeeDoctor": "<specific symptoms that require professional consultation>"
        }
        "mealRecipes": [
            {
              "name": "<recipe name>",
              "benefit": "<specific hair benefit>",
              "prepTime": "<e.g. 10 mins>",
              "ingredients": ["<ingredient 1>", "<ingredient 2>", "<ingredient 3>", "<ingredient 4>"],
              "steps": ["<step 1>", "<step 2>", "<step 3>"],
              "nutrients": ["<nutrient 1>", "<nutrient 2>", "<nutrient 3>"]
            },
            {
              "name": "<recipe name 2>",
              "benefit": "<specific hair benefit>",
              "prepTime": "<e.g. 15 mins>",
              "ingredients": ["<ingredient 1>", "<ingredient 2>", "<ingredient 3>"],
              "steps": ["<step 1>", "<step 2>", "<step 3>"],
              "nutrients": ["<nutrient 1>", "<nutrient 2>", "<nutrient 3>"]
            },
            {
              "name": "<recipe name 3>",
              "benefit": "<specific hair benefit>",
              "prepTime": "<e.g. 5 mins>",
              "ingredients": ["<ingredient 1>", "<ingredient 2>", "<ingredient 3>"],
              "steps": ["<step 1>", "<step 2>", "<step 3>"],
              "nutrients": ["<nutrient 1>", "<nutrient 2>", "<nutrient 3>"]
            }
          ]
        """

        let body: [String: Any] = [
            "model": "claude-opus-4-5",
            "max_tokens": 1024,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": beforeBase64
                            ]
                        ],
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": afterBase64
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "DataError", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let content = json["content"] as? [[String: Any]],
                   let firstContent = content.first,
                   let text = firstContent["text"] as? String {
                    DispatchQueue.main.async { completion(.success(text)) }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
