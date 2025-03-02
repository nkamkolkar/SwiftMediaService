//
//  AIGeneratedCaptionView.swift
//  MediaVaultClient
//
//  Created by Neelesh Kamkolkar on 2/25/25.
//


import SwiftUI

struct AIGeneratedCaptionView: View {
    @State private var captionText: String = "Enjoying the perfect sunset with friends! 🌅 #BeachVibes\n#SummerMoments"
    @State private var stubAIGenText: [String]  = ["Enjoying the perfect sunset with friends! 🌅 #BeachVibes\n#SummerMoments", "Looking forward to a relaxing evening at home! 🍿🕯️ #MovieNightIn", "Capturing the beauty of nature at its finest! 🌲🌊 #NatureAtItsFinest", "Shadow dancing at sunset with family! 🌅 #SydneyHarborBridge\n#SummerMoments", "A Sea Gull catches a fish #GoldenCoast\n#Australia", "A Girls Face Swimming in water with an intense look #AIPhotography", "Water pouring from a bottle into a glass #CloseupShot", "BubbleMan #Spain"]
    
    var body: some View {
        VStack(alignment: .center) {
            // Title and Regenerate button
            HStack (alignment: .bottom){
                Text("AI Generated Caption")
                    .font(.headline)
                    //.foregroundColor(.white)
                
                Spacer()
           
                Button(action: regenerateCaption) {
                    Text("Regenerate")
                        //.foregroundColor(.blue)
                }
                
                Button(action: copyToClipboard) {
                    Image(systemName: "doc.on.doc") // Copy icon
                        //.foregroundColor(.blue)
                }
            }
            
            
            // Editable Text Field (Minimum 3 lines)
            TextEditor(text: $captionText)
            Spacer()
        }
        .padding(10)
        //.background(Color.black)
    }
    
    // Placeholder functions
    private func regenerateCaption() {
        //captionText = "Here’s a new AI-generated caption! 🚀 #NewCaption"
        captionText = stubAIGenText.randomElement()!
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = captionText
    }
}

#Preview {
    AIGeneratedCaptionView()
}
