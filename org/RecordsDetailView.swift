
import Foundation
import SwiftUI
struct RecordsDetailView: View {
    var records: [Record]

    var body: some View {
        List {
            if records.isEmpty {
                Text("Нет записей для этой даты")
            } else {
                ForEach(records, id: \.id) { record in
                    VStack(alignment: .leading) {
                        Text(record.text)
                            .font(.headline)
                        Text("\(record.date, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Записи")
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()
