import SwiftUI

struct CalendarView: View {
    let calendar = Calendar.current
    @State private var currentDate = Date()
    @State private var selectedDate: Date? = nil
    @EnvironmentObject var recordsManager: RecordsManager
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }
        let dates = calendar.generateDates(inside: monthInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
      
        return dates
    }


    var body: some View {
        NavigationStack {
        VStack {
            HStack {
                Button(action: previousMonth) { Text("<") }
                Spacer()
                Text(monthHeader)
                    .font(.headline)
                Spacer()
                Button(action: nextMonth) { Text(">") }
            }.padding()

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                ForEach(["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"], id: \.self) { weekday in
                    Text(weekday).frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                ForEach(daysInMonth, id: \.self) { day in
                    NavigationLink(tag: day, selection: $selectedDate, destination: {
                        RecordsDetailView(records: recordsForDate(day))
                    }) {
                        Text("\(calendar.component(.day, from: day))")
                            .frame(width: 30, height: 30)
                            .padding(5)
                            .background(recordsContainDate(day) ? Color.red : Color.black)
                            .cornerRadius(15)
                            .foregroundColor(Color.white)
                    }

                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        self.selectedDate = day
                    }
                }
            }

            .navigationDestination(for: Date.self) { selectedDay in
                            RecordsDetailView(records: recordsForDate(selectedDay))
                        }
        }
        .padding()
        .navigationTitle("Календарь")
        .navigationBarTitleDisplayMode(.inline)
        }
    }

    var monthHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentDate)
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }

    private func recordsContainDate(_ date: Date) -> Bool {
        return recordsManager.records.contains(where: { calendar.isDate($0.date, inSameDayAs: date) })
    }

    private func recordsForDate(_ date: Date) -> [Record] {
        return recordsManager.records.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [Date]()
        
        var startDate = interval.start
        if let firstWeekday = self.date(from: self.dateComponents([.year, .month], from: interval.start)) {
            startDate = firstWeekday
        }
        
        var currentDate = startDate
        
        while currentDate < interval.end {
            dates.append(currentDate)
            currentDate = self.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
}
