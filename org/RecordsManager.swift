
import Foundation
class RecordsManager: ObservableObject {
    @Published var records = [Record]()

    let recordsKey = "records"

    init() {
        loadRecords()
    }
    func addRecord(withText text: String, dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU") 
        dateFormatter.dateFormat = "d MMMM yyyy"

        if let date = dateFormatter.date(from: dateString) {
            let newRecord = Record(date: date, text: text)
            records.append(newRecord)
            saveRecords()
        } else {
            print("Ошибка преобразования даты")
        }
    }

    func addRecord(_ record: Record) {
        records.append(record)
        saveRecords()
    }

    func loadRecords() {
        if let savedRecords = UserDefaults.standard.data(forKey: recordsKey) {
            if let decodedRecords = try? JSONDecoder().decode([Record].self, from: savedRecords) {
                records = decodedRecords
                return
            }
        }
        records = []
    }

    func saveRecords() {
        if let encodedRecords = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encodedRecords, forKey: recordsKey)
        }
    }
}
