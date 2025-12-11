import SwiftUI

struct LearnView: View {
    @State private var searchText: String = ""
    @State private var selectedMuscle: MuscleGroup? = nil
    @State private var bodyweightOnly: Bool = false

    // MARK: - Derived data

    private var allExercises: [ExerciseTemplate] {
        ExerciseLibrary.all
    }

    private var filteredExercises: [ExerciseTemplate] {
        allExercises.filter { template in
            // Muscle filter
            if let muscle = selectedMuscle, template.muscleGroup != muscle {
                return false
            }

            // Bodyweight only filter
            if bodyweightOnly && template.equipment != .bodyweight {
                return false
            }

            // Search filter
            if !searchText.isEmpty {
                return template.name.lowercased().contains(searchText.lowercased())
            }

            return true
        }
    }

    // Group filtered exercises by muscle group for sections
    private var groupedByMuscle: [(muscle: MuscleGroup, items: [ExerciseTemplate])] {
        let grouped = Dictionary(grouping: filteredExercises, by: { $0.muscleGroup })
        return grouped
            .sorted { $0.key.displayName < $1.key.displayName }
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerControls

                List {
                    if groupedByMuscle.isEmpty {
                        Text("No exercises match your filters yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(groupedByMuscle, id: \.muscle) { group in
                            Section(group.muscle.displayName) {
                                ForEach(group.items, id: \.name) { template in
                                    NavigationLink {
                                        ExerciseInfoView(exerciseName: template.name)
                                            .transition(.move(edge: .trailing).combined(with: .opacity))
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(template.name)
                                                    .font(.body)
                                                    .fontWeight(.medium)

                                                Text(templateSubtitle(for: template))
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer()

                                            if template.isCalisthenic {
                                                Text("BW")
                                                    .font(.caption2)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        Capsule()
                                                            .fill(Color.blue.opacity(0.15))
                                                    )
                                            }
                                        }
                                        .padding(.vertical, 4)
                                        .contentTransition(.opacity)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search exercises")
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedMuscle)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: bodyweightOnly)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: searchText)
            }
            .navigationTitle("LiftSphere Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header controls

    private var headerControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Muscle group pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    musclePill(title: "All", muscle: nil)

                    ForEach(MuscleGroup.allCases) { muscle in
                        musclePill(title: muscle.displayName, muscle: muscle)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }

            // Bodyweight toggle
            HStack {
                Toggle(isOn: $bodyweightOnly) {
                    Text("Bodyweight only")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .toggleStyle(.switch)
                .padding(.horizontal)
            }
            .padding(.bottom, 4)
        }
    }

    private func musclePill(title: String, muscle: MuscleGroup?) -> some View {
        let isSelected = selectedMuscle?.id == muscle?.id || (muscle == nil && selectedMuscle == nil)

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedMuscle = muscle
            }
        } label: {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(
                            isSelected ?
                            Color.purple.opacity(0.35) :
                            Color.gray.opacity(0.18)
                        )
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func templateSubtitle(for template: ExerciseTemplate) -> String {
        var parts: [String] = []

        // Equipment
        switch template.equipment {
        case .bodyweight: parts.append("Bodyweight")
        case .dumbbell:   parts.append("Dumbbell")
        case .barbell:    parts.append("Barbell")
        case .machine:    parts.append("Machine")
        case .cable:      parts.append("Cable")
        }

        // Safety / type flags
        if template.lowBackSafe {
            parts.append("Low-back friendly")
        }
        if template.isCalisthenic && template.equipment == .bodyweight {
            parts.append("Calisthenics")
        }

        return parts.joined(separator: " · ")
    }
}

#Preview {
    LearnView()
}
