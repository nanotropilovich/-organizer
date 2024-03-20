import SwiftUI
import Speech
import EventKit

struct ContentView: View {
    @StateObject var speechRecognizerManager = SpeechRecognizerManager()
    @EnvironmentObject var recordsManager: RecordsManager

    var body: some View {
        VStack {
            CalendarView() 
            Text(speechRecognizerManager.text).padding()
            Button(action: {
                speechRecognizerManager.isListening.toggle()
                if speechRecognizerManager.isListening {
                    speechRecognizerManager.startListening()
                } else {
                    speechRecognizerManager.stopListening()
                }
            }) {
                Text(speechRecognizerManager.isListening ? "Остановить" : "Говорить")
            }
        }
        .onAppear {
            speechRecognizerManager.configure(with: recordsManager)
        }
    }
}
