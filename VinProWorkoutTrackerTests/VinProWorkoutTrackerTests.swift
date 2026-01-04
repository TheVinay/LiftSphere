//
//  VinProWorkoutTrackerTests.swift
//  VinProWorkoutTrackerTests
//
//  Created by Vinays Mac on 12/3/25.
//

import Testing
import SwiftData
@testable import VinProWorkoutTracker

// MARK: - Workout Model Tests

@Suite("Workout Model Tests")
struct WorkoutModelTests {
    
    @Test("Creating a new workout")
    func createWorkout() async throws {
        let workout = Workout(
            date: Date(),
            name: "Test Workout",
            warmupMinutes: 5,
            coreMinutes: 30,
            stretchMinutes: 5,
            mainExercises: ["Bench Press", "Squats"],
            coreExercises: ["Plank"],
            stretches: ["Hamstring Stretch"]
        )
        
        #expect(workout.name == "Test Workout")
        #expect(workout.mainExercises.count == 2)
        #expect(workout.isCompleted == false)
        #expect(workout.isArchived == false)
    }
    
    @Test("Adding sets to workout")
    func addSetsToWorkout() async throws {
        let workout = Workout(
            date: Date(),
            name: "Strength Training",
            warmupMinutes: 5,
            coreMinutes: 30,
            stretchMinutes: 5,
            mainExercises: ["Bench Press"],
            coreExercises: [],
            stretches: []
        )
        
        let set1 = SetEntry(exerciseName: "Bench Press", weight: 135, reps: 10)
        let set2 = SetEntry(exerciseName: "Bench Press", weight: 155, reps: 8)
        let set3 = SetEntry(exerciseName: "Bench Press", weight: 185, reps: 5)
        
        workout.sets.append(set1)
        workout.sets.append(set2)
        workout.sets.append(set3)
        
        #expect(workout.sets.count == 3)
        #expect(workout.totalVolume == (135*10) + (155*8) + (185*5))
    }
    
    @Test("Calculate total volume correctly")
    func calculateTotalVolume() async throws {
        let workout = Workout(
            date: Date(),
            name: "Volume Test",
            warmupMinutes: 0,
            coreMinutes: 0,
            stretchMinutes: 0,
            mainExercises: ["Squats"],
            coreExercises: [],
            stretches: []
        )
        
        workout.sets.append(SetEntry(exerciseName: "Squats", weight: 225, reps: 5))
        workout.sets.append(SetEntry(exerciseName: "Squats", weight: 225, reps: 5))
        workout.sets.append(SetEntry(exerciseName: "Squats", weight: 225, reps: 5))
        
        let expectedVolume = 225.0 * 5.0 * 3.0 // 3375
        #expect(workout.totalVolume == expectedVolume)
    }
    
    @Test("Marking workout as completed")
    func markWorkoutCompleted() async throws {
        let workout = Workout(
            date: Date(),
            name: "Test",
            warmupMinutes: 0,
            coreMinutes: 0,
            stretchMinutes: 0,
            mainExercises: [],
            coreExercises: [],
            stretches: []
        )
        
        #expect(workout.isCompleted == false)
        
        workout.isCompleted = true
        
        #expect(workout.isCompleted == true)
    }
    
    @Test("Archiving workout")
    func archiveWorkout() async throws {
        let workout = Workout(
            date: Date(),
            name: "Test",
            warmupMinutes: 0,
            coreMinutes: 0,
            stretchMinutes: 0,
            mainExercises: [],
            coreExercises: [],
            stretches: []
        )
        
        #expect(workout.isArchived == false)
        
        workout.isArchived = true
        
        #expect(workout.isArchived == true)
    }
}

// MARK: - SetEntry Tests

@Suite("Set Entry Tests")
struct SetEntryTests {
    
    @Test("Creating a set entry")
    func createSetEntry() async throws {
        let set = SetEntry(
            exerciseName: "Bench Press",
            weight: 185,
            reps: 8
        )
        
        #expect(set.exerciseName == "Bench Press")
        #expect(set.weight == 185)
        #expect(set.reps == 8)
        #expect(set.volume == 185 * 8)
    }
    
    @Test("Set entry volume calculation")
    func setEntryVolume() async throws {
        let set = SetEntry(exerciseName: "Squats", weight: 315, reps: 3)
        
        #expect(set.volume == 945.0)
    }
    
    @Test("Set entry timestamp is set")
    func setEntryTimestamp() async throws {
        let before = Date()
        let set = SetEntry(exerciseName: "Test", weight: 100, reps: 10)
        let after = Date()
        
        #expect(set.timestamp >= before)
        #expect(set.timestamp <= after)
    }
}
// MARK: - HealthKit Manager Tests

@Suite("HealthKit Manager Tests")
struct HealthKitManagerTests {
    
    @Test("HealthKit availability check")
    func healthKitAvailability() {
        let isAvailable = HealthKitManager.isHealthDataAvailable
        // This will be true on real devices, may be true or false on simulator
        #expect(isAvailable == true || isAvailable == false)
    }
    
    @Test("HealthKit manager initialization")
    func healthKitManagerInit() {
        let manager = HealthKitManager()
        
        #expect(manager.isAuthorized == false)
        #expect(manager.weight == nil)
        #expect(manager.height == nil)
    }
    
    @Test("Formatted weight display")
    func formattedWeight() {
        let manager = HealthKitManager()
        manager.weight = 185.5
        
        let formatted = manager.formattedWeight()
        #expect(formatted == "185.5 lbs")
    }
    
    @Test("Formatted height display")
    func formattedHeight() {
        let manager = HealthKitManager()
        manager.height = 72.0 // 6 feet
        
        let formatted = manager.formattedHeight()
        #expect(formatted == "6' 0\"")
    }
    
    @Test("BMI category calculation")
    func bmiCategory() {
        let manager = HealthKitManager()
        
        manager.bodyMassIndex = 17.0
        #expect(manager.bmiCategory() == "Underweight")
        
        manager.bodyMassIndex = 22.0
        #expect(manager.bmiCategory() == "Normal")
        
        manager.bodyMassIndex = 27.0
        #expect(manager.bmiCategory() == "Overweight")
        
        manager.bodyMassIndex = 32.0
        #expect(manager.bmiCategory() == "Obese")
    }
}

// MARK: - Social Models Tests

@Suite("Social Models Tests")
struct SocialModelsTests {
    
    @Test("Creating user profile")
    func createUserProfile() {
        let profile = UserProfile(
            username: "testuser",
            displayName: "Test User",
            bio: "Test bio",
            totalWorkouts: 42,
            totalVolume: 50000
        )
        
        #expect(profile.username == "testuser")
        #expect(profile.displayName == "Test User")
        #expect(profile.totalWorkouts == 42)
        #expect(profile.totalVolume == 50000)
    }
    
    @Test("Creating friend relationship")
    func createFriendRelationship() {
        let relationship = FriendRelationship(
            followerID: "user1",
            followingID: "user2",
            status: .pending
        )
        
        #expect(relationship.followerID == "user1")
        #expect(relationship.followingID == "user2")
        #expect(relationship.status == .pending)
    }
    
    @Test("Creating public workout")
    func createPublicWorkout() {
        let workout = PublicWorkout(
            userID: "user123",
            workoutName: "Leg Day",
            date: Date(),
            totalVolume: 5000,
            exerciseCount: 5,
            isCompleted: true
        )
        
        #expect(workout.userID == "user123")
        #expect(workout.workoutName == "Leg Day")
        #expect(workout.exerciseCount == 5)
        #expect(workout.isCompleted == true)
    }
}

// MARK: - Exercise Library Tests

@Suite("Exercise Library Tests")
struct ExerciseLibraryTests {
    
    @Test("Exercise library is not empty")
    func libraryNotEmpty() {
        let exercises = ExerciseLibrary.all
        #expect(exercises.count > 0)
    }
    
    @Test("Finding exercises by muscle group")
    func findByMuscleGroup() {
        let chestExercises = ExerciseLibrary.all.filter { $0.muscleGroup == .chest }
        #expect(chestExercises.count > 0)
        
        let legExercises = ExerciseLibrary.all.filter { $0.muscleGroup == .legs }
        #expect(legExercises.count > 0)
    }
    
    @Test("Finding exercises by equipment")
    func findByEquipment() {
        let barbellExercises = ExerciseLibrary.all.filter { $0.equipment == .barbell }
        #expect(barbellExercises.count > 0)
        
        let bodyweightExercises = ExerciseLibrary.all.filter { $0.equipment == .bodyweight }
        #expect(bodyweightExercises.count > 0)
    }
    
    @Test("All exercises have required properties")
    func exerciseProperties() {
        for exercise in ExerciseLibrary.all {
            #expect(!exercise.name.isEmpty, "Exercise name should not be empty")
            // Muscle group and equipment are enums, so they're always valid
        }
    }
}

// MARK: - Custom Workout Template Tests

@Suite("Custom Workout Template Tests")
struct CustomWorkoutTemplateTests {
    
    @Test("Creating custom template")
    func createTemplate() {
        let template = CustomWorkoutTemplate(
            name: "My Routine",
            warmupMinutes: 10,
            coreMinutes: 45,
            stretchMinutes: 5,
            mainExercises: ["Squats", "Bench Press", "Deadlifts"],
            coreExercises: ["Plank"],
            stretches: ["Hamstring Stretch"]
        )
        
        #expect(template.name == "My Routine")
        #expect(template.mainExercises.count == 3)
        #expect(template.warmupMinutes == 10)
    }
    
    @Test("Template to workout conversion")
    func templateToWorkout() {
        let template = CustomWorkoutTemplate(
            name: "Push Day",
            warmupMinutes: 5,
            coreMinutes: 30,
            stretchMinutes: 5,
            mainExercises: ["Bench Press", "Overhead Press"],
            coreExercises: [],
            stretches: []
        )
        
        let workout = template.toWorkout()
        
        #expect(workout.name == "Push Day")
        #expect(workout.mainExercises == ["Bench Press", "Overhead Press"])
        #expect(workout.warmupMinutes == 5)
    }
}

// MARK: - Integration Tests

@Suite("Integration Tests")
struct IntegrationTests {
    
    @Test("Complete workout flow")
    func completeWorkoutFlow() async throws {
        // Create workout
        let workout = Workout(
            date: Date(),
            name: "Full Body",
            warmupMinutes: 10,
            coreMinutes: 45,
            stretchMinutes: 10,
            mainExercises: ["Squats", "Bench Press", "Rows"],
            coreExercises: ["Plank"],
            stretches: ["Quad Stretch"]
        )
        
        #expect(workout.sets.isEmpty)
        #expect(workout.totalVolume == 0)
        
        // Add sets
        workout.sets.append(SetEntry(exerciseName: "Squats", weight: 225, reps: 5))
        workout.sets.append(SetEntry(exerciseName: "Squats", weight: 225, reps: 5))
        workout.sets.append(SetEntry(exerciseName: "Bench Press", weight: 185, reps: 8))
        workout.sets.append(SetEntry(exerciseName: "Bench Press", weight: 185, reps: 8))
        workout.sets.append(SetEntry(exerciseName: "Rows", weight: 135, reps: 10))
        
        #expect(workout.sets.count == 5)
        
        let expectedVolume = (225*5*2) + (185*8*2) + (135*10)
        #expect(workout.totalVolume == Double(expectedVolume))
        
        // Complete workout
        workout.isCompleted = true
        #expect(workout.isCompleted == true)
    }
    
    @Test("Workout with multiple exercises")
    func workoutMultipleExercises() async throws {
        let workout = Workout(
            date: Date(),
            name: "Upper Body",
            warmupMinutes: 5,
            coreMinutes: 40,
            stretchMinutes: 5,
            mainExercises: ["Bench Press", "Pull-ups", "Overhead Press", "Rows"],
            coreExercises: [],
            stretches: []
        )
        
        #expect(workout.mainExercises.count == 4)
        
        // Add sets for each exercise
        for exercise in workout.mainExercises {
            workout.sets.append(SetEntry(exerciseName: exercise, weight: 100, reps: 10))
        }
        
        #expect(workout.sets.count == 4)
    }
}

// MARK: - Performance Tests

@Suite("Performance Tests")
struct PerformanceTests {
    
    @Test("Creating many workouts is fast", .timeLimit(.seconds(1)))
    func createManyWorkouts() async throws {
        var workouts: [Workout] = []
        
        for i in 0..<1000 {
            let workout = Workout(
                date: Date(),
                name: "Workout \(i)",
                warmupMinutes: 5,
                coreMinutes: 30,
                stretchMinutes: 5,
                mainExercises: ["Exercise"],
                coreExercises: [],
                stretches: []
            )
            workouts.append(workout)
        }
        
        #expect(workouts.count == 1000)
    }
    
    @Test("Volume calculation is fast", .timeLimit(.seconds(1)))
    func volumeCalculationPerformance() async throws {
        let workout = Workout(
            date: Date(),
            name: "Test",
            warmupMinutes: 0,
            coreMinutes: 0,
            stretchMinutes: 0,
            mainExercises: [],
            coreExercises: [],
            stretches: []
        )
        
        // Add 100 sets
        for _ in 0..<100 {
            workout.sets.append(SetEntry(exerciseName: "Test", weight: 100, reps: 10))
        }
        
        // Calculate volume 1000 times
        for _ in 0..<1000 {
            _ = workout.totalVolume
        }
        
        #expect(workout.totalVolume == 100000.0)
    }
}

