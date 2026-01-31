import SwiftUI

import SwiftUI
import SwiftData
import UIKit


struct CreateExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // MARK: - Form State
    
    @State private var exerciseName: String = ""
    @State private var primaryMuscle: MuscleGroup = .chest
    @State private var secondaryMuscle: MuscleGroup? = nil
    @State private var includeSecondaryMuscle: Bool = false
    @State private var equipment: Equipment = .barbell
    @State private var isCalisthenic: Bool = false
    @State private var lowBackSafe: Bool = true
    @State private var machineName: String = ""
    @State private var includesMachineName: Bool = false
    @State private var briefInfo: String = ""
    
    // Educational content
    @State private var musclesDescription: String = ""
    @State private var instructions: String = ""
    @State private var formTips: String = ""
    
    // UI State
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Basic Info Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Exercise Name")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("e.g., Overhead Press", text: $exerciseName)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                } header: {
                    Label("Basic Information", systemImage: "info.circle")
                } footer: {
                    Text("Enter a clear, descriptive name for your exercise")
                        .font(.caption)
                }
                
                // MARK: - Muscle Groups Section
                Section {
                    // Primary Muscle
                    Picker("Primary Muscle", selection: $primaryMuscle) {
                        ForEach(MuscleGroup.modernGroups) { muscle in
                            Text(muscle.displayName).tag(muscle)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Secondary Muscle Toggle
                    Toggle("Include Secondary Muscle", isOn: $includeSecondaryMuscle)
                        .tint(.blue)
                    
                    if includeSecondaryMuscle {
                        Picker("Secondary Muscle", selection: Binding(
                            get: { secondaryMuscle ?? .chest },
                            set: { secondaryMuscle = $0 }
                        )) {
                            ForEach(MuscleGroup.modernGroups) { muscle in
                                Text(muscle.displayName).tag(muscle)
                            }
                        }
                        .pickerStyle(.menu)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                } header: {
                    Label("Target Muscles", systemImage: "figure.strengthtraining.traditional")
                } footer: {
                    Text("Select the primary muscle group this exercise targets")
                        .font(.caption)
                }
                
                // MARK: - Equipment Section
                Section {
                    Picker("Equipment Type", selection: $equipment) {
                        ForEach(Equipment.allCases, id: \.self) { eq in
                            Text(eq.rawValue.capitalized).tag(eq)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: equipment) { oldValue, newValue in
                        // Auto-set calisthenic flag for bodyweight
                        if newValue == .bodyweight {
                            isCalisthenic = true
                        }
                    }
                    
                    Toggle("Calisthenic Exercise", isOn: $isCalisthenic)
                        .tint(.blue)
                    
                    // Machine Name (optional)
                    Toggle("Specify Machine Name", isOn: $includesMachineName)
                        .tint(.blue)
                    
                    if includesMachineName {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Machine Name")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                            
                            TextField("e.g., Chest Press Machine", text: $machineName)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(.systemGray6))
                                )
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                } header: {
                    Label("Equipment", systemImage: "dumbbell")
                } footer: {
                    Text("Specify what equipment is needed for this exercise")
                        .font(.caption)
                }
                
                // MARK: - Safety & Attributes Section
                Section {
                    Toggle("Low Back Safe", isOn: $lowBackSafe)
                        .tint(.green)
                } header: {
                    Label("Safety", systemImage: "checkmark.shield")
                } footer: {
                    Text("Turn off if this exercise puts significant stress on the lower back")
                        .font(.caption)
                }
                
                // MARK: - Description Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Brief Description (Optional)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("e.g., Vertical pressing movement for shoulders", text: $briefInfo, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(3...5)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                } header: {
                    Label("Additional Info", systemImage: "note.text")
                }
                
                // MARK: - Educational Content Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Muscles Worked")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("e.g., Shoulders, Triceps, Upper Chest", text: $musclesDescription, axis: .vertical)
                            .textFieldStyle(.plain)
                            .lineLimit(2...4)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to Perform (Optional)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $instructions)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                            .scrollContentBackground(.hidden)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Form Tips (Optional)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextEditor(text: $formTips)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                            .scrollContentBackground(.hidden)
                    }
                } header: {
                    Label("Exercise Details", systemImage: "book.closed")
                } footer: {
                    Text("Add detailed instructions and tips to help with proper form. Separate multiple instructions or tips with line breaks.")
                        .font(.caption)
                }
                
                // MARK: - Preview Section
                Section {
                    exercisePreview
                } header: {
                    Label("Preview", systemImage: "eye")
                }
            }
            .navigationTitle("Create Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExercise()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .alert("Validation Error", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Preview
    
    private var exercisePreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name with gradient
            if !exerciseName.isEmpty {
                Text(exerciseName)
                    .font(.title3.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            } else {
                Text("Exercise Name")
                    .font(.title3.bold())
                    .foregroundStyle(.tertiary)
            }
            
            // Subtitle
            HStack(spacing: 8) {
                // Equipment
                Text(equipment.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.15))
                    )
                
                // Calisthenic badge
                if isCalisthenic {
                    Text("BW")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.15))
                        )
                }
                
                // Low back safe badge
                if lowBackSafe {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield")
                            .font(.caption2)
                        Text("Low-back friendly")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.15))
                    )
                }
            }
            
            // Muscles
            VStack(alignment: .leading, spacing: 4) {
                Text("Target Muscles")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                if includeSecondaryMuscle, let secondary = secondaryMuscle {
                    Text("\(primaryMuscle.displayName) • \(secondary.displayName)")
                        .font(.subheadline)
                } else {
                    Text(primaryMuscle.displayName)
                        .font(.subheadline)
                }
            }
            .padding(.top, 4)
            
            // Brief info
            if !briefInfo.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(briefInfo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
    
    // MARK: - Validation
    
    private var isValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !musclesDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Save
    
    private func saveExercise() {
        // Trim whitespace
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMuscles = musclesDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInfo = briefInfo.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInstructions = instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTips = formTips.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMachineName = machineName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validation
        guard !trimmedName.isEmpty else {
            validationMessage = "Exercise name is required"
            showValidationError = true
            return
        }
        
        guard !trimmedMuscles.isEmpty else {
            validationMessage = "Muscles description is required"
            showValidationError = true
            return
        }
        
        // Save to database
        do {
            try CustomExerciseManager.saveExercise(
                name: trimmedName,
                primaryMuscle: primaryMuscle,
                secondaryMuscle: includeSecondaryMuscle ? secondaryMuscle : nil,
                equipment: equipment,
                isCalisthenic: isCalisthenic,
                lowBackSafe: lowBackSafe,
                machineName: includesMachineName && !trimmedMachineName.isEmpty ? trimmedMachineName : nil,
                info: !trimmedInfo.isEmpty ? trimmedInfo : nil,
                musclesDescription: trimmedMuscles,
                instructions: !trimmedInstructions.isEmpty ? trimmedInstructions : nil,
                formTips: !trimmedTips.isEmpty ? trimmedTips : nil,
                context: context
            )
            
            print("✅ Exercise '\(trimmedName)' created successfully!")
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Close the sheet
            dismiss()
            
        } catch CustomExerciseError.duplicateName {
            validationMessage = "An exercise with this name already exists"
            showValidationError = true
        } catch {
            validationMessage = "Failed to save exercise: \(error.localizedDescription)"
            showValidationError = true
        }
    }
}

#Preview {
    CreateExerciseView()
}
