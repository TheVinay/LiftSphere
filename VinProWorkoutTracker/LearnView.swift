import SwiftUI
import SwiftData

struct LearnView: View {
    @State private var searchText: String = ""
    @State private var selectedMuscle: MuscleGroup? = nil
    @State private var selectedEquipment: Equipment? = nil
    @State private var bodyweightOnly: Bool = false
    
    // Favorites stored in AppStorage
    @AppStorage("favoriteExercises") private var favoriteExercisesData: Data = Data()
    @State private var favoriteExercises: Set<String> = []
    
    // Collapsible section states
    @State private var isRecentlyUsedExpanded = true
    @State private var expandedMuscleGroups: Set<MuscleGroup> = []
    
    // Help sheet
    @State private var showHelp = false
    
    // Query for recent exercises
    @Query(sort: \SetEntry.timestamp, order: .reverse)
    private var allSets: [SetEntry]

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
            
            // Equipment filter
            if let equipment = selectedEquipment, template.equipment != equipment {
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
    
    // Recently used exercises (last 7 days)
    private var recentlyUsedExercises: [ExerciseTemplate] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentSets = allSets.filter { $0.timestamp >= sevenDaysAgo }
        let uniqueNames = Array(Set(recentSets.map { $0.exerciseName }))
        
        return allExercises.filter { uniqueNames.contains($0.name) }
    }
    
    // Favorite exercises
    private var favoriteExercisesList: [ExerciseTemplate] {
        allExercises.filter { favoriteExercises.contains($0.name) }
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
                    // Favorites Section (Always Expanded - Non-collapsible)
                    if !favoriteExercisesList.isEmpty {
                        Section("⭐ Favorites") {
                            ForEach(favoriteExercisesList, id: \.name) { template in
                                exerciseRow(template: template)
                            }
                        }
                    }
                    
                    // Recently Used Section (Collapsible)
                    if !recentlyUsedExercises.isEmpty && searchText.isEmpty {
                        Section {
                            DisclosureGroup(
                                isExpanded: $isRecentlyUsedExpanded
                            ) {
                                ForEach(recentlyUsedExercises.prefix(5), id: \.name) { template in
                                    exerciseRow(template: template)
                                }
                            } label: {
                                HStack {
                                    Text("🕐 Recently Used")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(min(recentlyUsedExercises.count, 5))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    // All Exercises Grouped by Muscle (Collapsible)
                    if groupedByMuscle.isEmpty {
                        Text("No exercises match your filters yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(groupedByMuscle, id: \.muscle) { group in
                            Section {
                                DisclosureGroup(
                                    isExpanded: Binding(
                                        get: { expandedMuscleGroups.contains(group.muscle) },
                                        set: { isExpanding in
                                            if isExpanding {
                                                expandedMuscleGroups.insert(group.muscle)
                                            } else {
                                                expandedMuscleGroups.remove(group.muscle)
                                            }
                                        }
                                    )
                                ) {
                                    ForEach(group.items, id: \.name) { template in
                                        exerciseRow(template: template)
                                    }
                                } label: {
                                    HStack {
                                        Text(group.muscle.displayName)
                                            .font(.headline)
                                        Spacer()
                                        Text("\(group.items.count)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, prompt: "Search exercises")
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedMuscle)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedEquipment)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: bodyweightOnly)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: searchText)
            }
            .navigationTitle("LiftSphere Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showHelp = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.body)
                    }
                    .accessibilityLabel("Help & Guide")
                }
            }
            .sheet(isPresented: $showHelp) {
                HelpView()
            }
            .onAppear {
                loadFavorites()
            }
        }
    }

    // MARK: - Header controls

    private var headerControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Muscle group pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Text("Muscle:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                    
                    musclePill(title: "All", muscle: nil)

                    ForEach(MuscleGroup.allCases) { muscle in
                        musclePill(title: muscle.displayName, muscle: muscle)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            
            // Equipment filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    Text("Equipment:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                    
                    equipmentPill(title: "All", equipment: nil)
                    
                    ForEach(Equipment.allCases, id: \.self) { equipment in
                        equipmentPill(title: equipment.rawValue.capitalized, equipment: equipment)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
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
    
    private func equipmentPill(title: String, equipment: Equipment?) -> some View {
        let isSelected = selectedEquipment == equipment || (equipment == nil && selectedEquipment == nil)

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedEquipment = equipment
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
                            Color.blue.opacity(0.35) :
                            Color.gray.opacity(0.18)
                        )
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Exercise Row
    
    private func exerciseRow(template: ExerciseTemplate) -> some View {
        let stats = getExerciseStats(for: template.name)
        let isFavorite = favoriteExercises.contains(template.name)
        
        return NavigationLink {
            ExerciseInfoView(exerciseName: template.name)
                .transition(.move(edge: .trailing).combined(with: .opacity))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.body)
                        .fontWeight(.medium)

                    Text(templateSubtitle(for: template))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Quick Stats
                    if let last = stats.lastSet {
                        HStack(spacing: 8) {
                            Text("Last: \(String(format: "%.1f", last.weight))kg × \(last.reps)")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                            
                            if let pr = stats.prSet {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                
                                Text("PR: \(String(format: "%.1f", pr.weight))kg × \(pr.reps)")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }

                Spacer()
                
                HStack(spacing: 12) {
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
                    
                    // Favorite star
                    Button {
                        toggleFavorite(template.name)
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
            .contentTransition(.opacity)
        }
    }

    // MARK: - Helpers
    
    private struct ExerciseStats {
        var lastSet: SetEntry?
        var prSet: SetEntry?
    }
    
    private func getExerciseStats(for exerciseName: String) -> ExerciseStats {
        let exerciseSets = allSets.filter { $0.exerciseName == exerciseName }
        
        let lastSet = exerciseSets.first
        let prSet = exerciseSets.max { a, b in
            if a.weight == b.weight {
                return a.reps < b.reps
            }
            return a.weight < b.weight
        }
        
        return ExerciseStats(lastSet: lastSet, prSet: prSet)
    }
    
    private func toggleFavorite(_ exerciseName: String) {
        withAnimation {
            if favoriteExercises.contains(exerciseName) {
                favoriteExercises.remove(exerciseName)
            } else {
                favoriteExercises.insert(exerciseName)
            }
            saveFavorites()
        }
    }
    
    private func loadFavorites() {
        if let decoded = try? JSONDecoder().decode(Set<String>.self, from: favoriteExercisesData) {
            favoriteExercises = decoded
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteExercises) {
            favoriteExercisesData = encoded
        }
    }

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
        .modelContainer(for: [Workout.self, SetEntry.self], inMemory: true)
}
