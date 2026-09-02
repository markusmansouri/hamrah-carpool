import SwiftUI

public struct VehicleRegistrationView: View {
    @State private var make = ""
    @State private var model = ""
    @State private var year = String(Calendar.current.component(.year, from: Date()))
    @State private var licensePlate = ""
    @State private var vin = ""
    @State private var color = ""
    @State private var capacity = 2
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text(NSLocalizedString("common.back", comment: ""))
                        }
                    }
                    Spacer()
                    Text(NSLocalizedString("vehicle.registration.title", comment: ""))
                        .font(.headline)
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Make
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.make", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField(NSLocalizedString("vehicle.make.placeholder", comment: ""), text: $make)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Model
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.model", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField(NSLocalizedString("vehicle.model.placeholder", comment: ""), text: $model)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Year
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.year", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField(NSLocalizedString("vehicle.year.placeholder", comment: ""), text: $year)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // License Plate
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.license.plate", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField(NSLocalizedString("vehicle.license.placeholder", comment: ""), text: $licensePlate)
                                .textContentType(.none)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // VIN
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.vin", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField(NSLocalizedString("vehicle.vin.placeholder", comment: ""), text: $vin)
                                .textContentType(.none)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Color
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.color", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextField(NSLocalizedString("vehicle.color.placeholder", comment: ""), text: $color)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Capacity
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("vehicle.capacity", comment: ""))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Stepper(
                                NSLocalizedString("vehicle.capacity.passengers", comment: "", arguments: capacity),
                                value: $capacity,
                                in: 1...4
                            )
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Save Button
                        Button(action: { dismiss() }) {
                            Text(NSLocalizedString("common.save", comment: ""))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}
