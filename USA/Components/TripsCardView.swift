import SwiftUI

struct TripCardView: View {
    var trip: Trip
    
    var body: some View {
        HStack {
            VStack {
                Text(trip.emoji)
                    .font(.largeTitle)
            }
            
            VStack(alignment: .leading) {
                if !trip.title.isEmpty {
                    Text(trip.title)
                        .font(.title2)
                        .padding(.bottom, 2)
                }
                
                Text("\(trip.startDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .padding(.bottom, 1)

                Text("\(trip.endDate, formatter: dateFormatter)")
                    .font(.subheadline)
                    .padding(.bottom, 2)
            }
            .padding(.leading, 10)
            
            Spacer()
            
            VStack {
                Text("\(trip.duration)")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color.accentColor)
                Text("days")
                    .font(.subheadline)
                    .foregroundColor(Color.accentColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // Fill horizontal space
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.primary.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        TripCardView(trip: Trip(title: "Vacation", startDate: Date(), endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, emoji: "✈️"))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
