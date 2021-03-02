import SwiftUI

struct OCRResultsView: View {
    @EnvironmentObject var navStack: NavigationStack
    
    @Binding var message: String
    @State private var textStyle = UIFont.TextStyle.title2
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                TextView(text: $message, textStyle: $textStyle)
                    .padding(.horizontal)
                    .padding(.top, 60)
                    .padding(.leading, 40)
                HStack {
                    Button(action: {
                        self.navStack.pop()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .imageScale(.large)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .background(Color(UIColor.systemBlue))
                            .clipShape(Circle())
                    })
                    .padding()
                    Spacer()
                    Button(action: {
                        self.textStyle = (self.textStyle == .title2) ? .headline : .title2
                    }) {
                        Image(systemName: "textformat")
                            .imageScale(.large)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .background(Color(UIColor.systemBlue))
                            .clipShape(Circle())
                        
                    }
                    .padding()
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground).opacity(0.2))
        .navigationBarTitle("Results", displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct OCRResultsView_Previews: PreviewProvider {
    static var previews: some View {
        OCRResultsView(message: .constant("But how do you present it? Since SwiftUI is a declarative UI framework, you don’t present is by reacting to a user action in a callback. Instead, you declare under which state it should be presented. Remember: A SwiftUI view is a function of its state."))
    }
}
