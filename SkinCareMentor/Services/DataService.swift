//
//  DataService.swift
//  SkinCareMentor
//
//  Created by Роман Главацкий on 21.11.2025.
//

import Foundation

class DataService {
    static let shared = DataService()
    
    private init() {}
    
    func getDefaultArticles() -> [KnowledgeArticle] {
        return [
            KnowledgeArticle(
                title: "How to Determine Your Skin Type",
                content: """
                Determining your skin type is the first and most important step in creating an effective skincare routine. There are five main skin types:
                
                1. **Dry Skin** - feeling of tightness, flaking, dull appearance. Pores are almost invisible.
                
                2. **Oily Skin** - shine, enlarged pores, tendency to develop blackheads and acne.
                
                3. **Combination Skin** - oily T-zone (forehead, nose, chin) and dry cheeks.
                
                4. **Normal Skin** - balanced, no special problems, pores are invisible.
                
                5. **Sensitive Skin** - tendency to redness, irritation, reactions to cosmetics.
                
                For accurate skin type determination, perform a test in the morning on clean skin without makeup.
                """,
                category: .basics,
                difficulty: .beginner
            ),
            KnowledgeArticle(
                title: "Key Skincare Ingredients",
                content: """
                Understanding active ingredients will help you choose the right products:
                
                **Hyaluronic Acid** - powerful moisturizer, attracts and retains moisture. Suitable for all skin types.
                
                **Retinol (Vitamin A)** - the gold standard of anti-aging care. Accelerates cell renewal, reduces wrinkles. Start with low concentration.
                
                **Niacinamide (Vitamin B3)** - universal ingredient: tightens pores, reduces inflammation, evens skin tone.
                
                **Vitamin C** - antioxidant, lightens pigmentation, protects against free radicals. Use in the morning.
                
                **Salicylic Acid (BHA)** - exfoliates, penetrates pores, ideal for oily skin and acne.
                
                **Glycolic Acid (AHA)** - gentle exfoliation, improves skin texture. Suitable for dry skin.
                
                **Peptides** - stimulate collagen production, strengthen skin.
                """,
                category: .ingredients,
                difficulty: .beginner
            ),
            KnowledgeArticle(
                title: "Morning vs Evening Routine",
                content: """
                Morning and evening routines have different goals:
                
                **MORNING ROUTINE:**
                - Cleansing (gentle, without aggressive products)
                - Toner (for pH balance)
                - Vitamin C serum (protection from free radicals)
                - Moisturizer
                - **Sunscreen (MANDATORY!)** - the most important step
                
                **EVENING ROUTINE:**
                - Double cleansing (if wearing makeup)
                - Toner
                - Treatment serums (retinol, acids)
                - Moisturizer (more nourishing)
                - Oil or night mask (optional)
                
                **Rule:** Morning protection, evening restoration and treatment.
                """,
                category: .routines,
                difficulty: .intermediate
            ),
            KnowledgeArticle(
                title: "How to Fight Acne",
                content: """
                Acne is one of the most common skin problems. Here's an effective approach:
                
                **Cleansing:** Use gentle products with salicylic acid or benzoyl peroxide. Avoid aggressive scrubbing.
                
                **Treatment:** 
                - Salicylic acid (BHA) 2% - for daily use
                - Retinol - start with 0.025%, gradually increase
                - Niacinamide - reduces inflammation and redness
                
                **Moisturizing:** Don't skip this step! A light non-comedogenic cream is necessary even for oily skin.
                
                **Sun Protection:** Mandatory! Many acne products increase sun sensitivity.
                
                **Patches:** Use hydrocolloid patches on inflammation at night.
                
                Remember: results appear after 4-6 weeks of regular use.
                """,
                category: .problems,
                difficulty: .intermediate
            ),
            KnowledgeArticle(
                title: "Skincare Myths",
                content: """
                Debunking popular myths:
                
                **Myth 1:** "Oily skin doesn't need moisturizing"
                Not true! Dehydrated skin can produce even more sebum. Use light non-comedogenic creams.
                
                **Myth 2:** "Expensive products are always better"
                Price doesn't guarantee quality. Look for effective active ingredients, not the brand.
                
                **Myth 3:** "Natural = safe"
                Natural ingredients can cause allergies and irritation. It all depends on your skin.
                
                **Myth 4:** "You need to change products every 3 months"
                If a product works, keep using it. Change only when necessary.
                
                **Myth 5:** "More = better"
                An overloaded routine can harm. 5-7 steps are enough for most people.
                
                **Myth 6:** "SPF is only needed in summer"
                UV rays are active year-round. Use SPF daily.
                """,
                category: .myths,
                difficulty: .beginner
            )
        ]
    }
    
    func generateRoutine(for skinType: SkinType, timeOfDay: TimeOfDay, concerns: [SkinConcern]) -> SkinCareRoutine {
        var steps: [RoutineStep] = []
        var order = 1
        
        // Базовые шаги для всех типов
        steps.append(RoutineStep(
            productType: .cleanser,
            productName: timeOfDay == .morning ? "Gentle Cleanser" : "Cleanser",
            instructions: timeOfDay == .morning ? "Wash with warm water, apply product with gentle movements, rinse." : "First remove makeup, then cleanse skin. Use double cleansing if wearing makeup.",
            order: order
        ))
        order += 1
        
        steps.append(RoutineStep(
            productType: .toner,
            productName: "Toner",
            instructions: "Apply toner to a cotton pad or palms, gently distribute over face. Don't rub skin.",
            order: order
        ))
        order += 1
        
        // Специфичные шаги в зависимости от типа кожи и времени суток
        if timeOfDay == .morning {
            if concerns.contains(.pigmentation) || concerns.contains(.wrinkles) {
                steps.append(RoutineStep(
                    productType: .serum,
                    productName: "Vitamin C Serum",
                    instructions: "Apply 2-3 drops to face, avoiding eye area. Gently pat with fingertips.",
                    order: order
                ))
                order += 1
            }
            
            steps.append(RoutineStep(
                productType: .moisturizer,
                productName: skinType == .oily ? "Light Moisturizer" : "Moisturizer",
                instructions: "Apply cream to entire face, including neck. Distribute with gentle movements.",
                order: order
            ))
            order += 1
            
            steps.append(RoutineStep(
                productType: .sunscreen,
                productName: "Sunscreen SPF 30+",
                instructions: "MANDATORY STEP! Apply sufficient amount (about 1/4 teaspoon) to face and neck. Wait 15 minutes before sun exposure.",
                order: order
            ))
        } else {
            // Вечерняя рутина
            if concerns.contains(.acne) {
                steps.append(RoutineStep(
                    productType: .treatment,
                    productName: "Salicylic Acid Treatment",
                    instructions: "Apply spot treatment to problem areas or thin layer to entire face. Start with 2-3 times per week.",
                    order: order
                ))
                order += 1
            }
            
            if concerns.contains(.wrinkles) {
                steps.append(RoutineStep(
                    productType: .serum,
                    productName: "Retinol Serum",
                    instructions: "Apply to dry skin in the evening. Start with 2-3 times per week, gradually increase frequency. Avoid eye area.",
                    order: order
                ))
                order += 1
            }
            
            if concerns.contains(.dehydration) || skinType == .dry {
                steps.append(RoutineStep(
                    productType: .moisturizer,
                    productName: "Nourishing Night Cream",
                    instructions: "Apply a thicker layer of cream before bed. You can add a few drops of oil.",
                    order: order
                ))
            } else {
                steps.append(RoutineStep(
                    productType: .moisturizer,
                    productName: "Moisturizer",
                    instructions: "Apply cream to entire face and neck.",
                    order: order
                ))
            }
            order += 1
            
            // Маска раз в неделю
            if concerns.contains(.pores) || skinType == .oily {
                steps.append(RoutineStep(
                    productType: .mask,
                    productName: "Cleansing Mask",
                    instructions: "Use 1-2 times per week. Apply for 10-15 minutes, then rinse with warm water.",
                    order: order,
                    timerDuration: 600 // 10 минут
                ))
            }
        }
        
        return SkinCareRoutine(
            timeOfDay: timeOfDay,
            steps: steps,
            scheduledDate: Date()
        )
    }
}

