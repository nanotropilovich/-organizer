import Foundation
import Speech

class SpeechRecognizerManager: ObservableObject {
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
     var recognitionTask: SFSpeechRecognitionTask?
     let audioEngine = AVAudioEngine()
    
     let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))!

 
    var recordsManager: RecordsManager?

      
       func configure(with recordsManager: RecordsManager) {
           self.recordsManager = recordsManager
       }
       
    @Published var text = ""
    @Published var isListening = false

    func addRecord(date: Date, text: String) {
       
        DispatchQueue.main.async {
            self.recordsManager!.addRecord(Record(date: date, text: text))
        }
    }

    func processRecognizedText() {
        let components = text.split(separator: " ", maxSplits: 4, omittingEmptySubsequences: true)
        guard components.count >= 4, components[0] == "Добавить", components[1] == "на" else { return }

        let dateString = "\(components[2]) \(components[3])"
        let recordText = components.dropFirst(4).joined(separator: " ") 

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "d MMMM"

        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)

        dateFormatter.dateFormat = "d MMMM yyyy"
        let tempDate = dateFormatter.date(from: "\(dateString) \(currentYear)")

        var dateToUse = tempDate
        if let tempDate = tempDate {
            if tempDate < currentDate {
                dateToUse = Calendar.current.date(byAdding: .year, value: 1, to: tempDate)
            }
        }

        if let finalDate = dateToUse {
            print(finalDate,recordText)
            addRecord(date: finalDate, text: recordText)
        } else {
            print("Ошибка при преобразовании даты")
        }
    }


    func startListening() {
      
        if !isListening { return }
      
        isListening = true
       
        recognitionTask?.cancel()
        recognitionTask = nil
        
        configureAudioSession()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            isListening = false
            return
        }

        let inputNode = audioEngine.inputNode // Используйте напрямую без guard let
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let result = result {
                self.text = result.bestTranscription.formattedString
                if result.isFinal {
                    self.stopListening()
                    self.processRecognizedText()
                }
            } else if error != nil {
                self.stopListening()
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("Audio engine couldn't start because of an error: \(error)")
            stopListening()
        }
    }


    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        isListening = false
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}
