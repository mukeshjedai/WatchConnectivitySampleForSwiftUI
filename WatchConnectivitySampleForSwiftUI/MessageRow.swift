import SwiftUI

struct MessageRow: View {
    let animalModel: AnimalModel  // ✅ Expect an AnimalModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(animalModel.emoji + " " + animalModel.name)
                .font(.body)
                .padding(.vertical, 4.0)

            // Timestamp for when the message was received
            Text(Date().toString())
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        MessageRow(animalModel: AnimalModel(name: "ネコ", emoji: "🐱"))
    }
}
