import Foundation

import Foundation
import SwiftData

/// Centralized database for exercise information
struct ExerciseDatabase {
    
    // MARK: - Primary Muscles
    
    static func primaryMuscles(for exerciseName: String) -> String? {
        primaryMusclesMap[exerciseName]
    }
    
    private static let primaryMusclesMap: [String: String] = [
        // CHEST
        "Flat Dumbbell Bench Press": "Chest, Front Shoulders, Triceps",
        "Incline Dumbbell Press": "Upper Chest, Front Shoulders, Triceps",
        "Machine Chest Press": "Chest, Front Shoulders, Triceps",
        "Cable Chest Fly": "Chest",
        "Bench Press": "Chest, Front Shoulders, Triceps",
        "Push-Up": "Chest, Front Shoulders, Triceps, Core",
        "Incline Push-Up": "Upper Chest, Front Shoulders, Triceps",
        "Diamond Push-Up": "Triceps, Chest, Front Shoulders",
        
        // SHOULDERS
        "Seated Dumbbell Shoulder Press": "Shoulders, Triceps",
        "Cable Lateral Raise": "Side Shoulders",
        "Machine Shoulder Press": "Shoulders, Triceps",
        "Dumbbell Shrugs": "Traps, Upper Back",
        "Overhead Press": "Shoulders, Triceps, Upper Chest",
        "Pike Push-Up": "Shoulders, Triceps",
        
        // BACK
        "Lat Pulldown": "Lats, Upper Back, Biceps",
        "Seated Cable Row": "Upper Back, Lats, Biceps",
        "Chest-Supported Row": "Upper Back, Lats, Rear Shoulders",
        "Face Pull": "Rear Shoulders, Upper Back, Traps",
        "Assisted Pull-Up": "Lats, Upper Back, Biceps",
        "Rope Lat Prayer": "Lats, Core",
        "Row Machine": "Upper Back, Lats, Biceps",
        "Bent Over Row": "Lats, Upper Back, Lower Back",
        "Deadlift": "Lower Back, Glutes, Hamstrings, Traps",
        "Inverted Row": "Upper Back, Lats, Biceps",
        "Inverted Row (waist height)": "Upper Back, Lats, Biceps",
        
        // ARMS
        "Triceps Rope Pushdown": "Triceps",
        "Overhead Dumbbell Triceps Extension": "Triceps",
        "EZ Bar Curl": "Biceps",
        "Dumbbell Hammer Curl": "Biceps, Forearms",
        "Bench Dip (feet on floor)": "Triceps, Chest, Front Shoulders",
        "Suspension Bicep Curl": "Biceps, Core",
        
        // LEGS
        "Leg Press": "Quads, Glutes, Hamstrings",
        "Goblet Squat": "Quads, Glutes, Core",
        "Leg Extension": "Quads",
        "Leg Curl": "Hamstrings",
        "Seated Leg Curl": "Hamstrings",
        "Calf Raise": "Calves",
        "Bodyweight Squat": "Quads, Glutes, Core",
        "Split Squat": "Quads, Glutes, Balance",
        "Bulgarian Split Squat": "Quads, Glutes, Balance",
        "Barbell Squat": "Quads, Glutes, Lower Back, Core",
        "Assisted Pistol Squat": "Quads, Glutes, Balance",
        "Lateral Lunge": "Quads, Glutes, Inner Thighs",
        
        // GLUTES
        "Glute Bridge": "Glutes, Hamstrings",
        "Hip Thrust": "Glutes, Hamstrings",
        "Single Leg Glute Bridge": "Glutes, Hamstrings, Balance",
        "Nordic Hamstring Curl": "Hamstrings, Glutes",
        
        // CORE
        "Front Plank": "Core, Shoulders",
        "Front Plank (hold)": "Core, Shoulders",
        "Side Plank": "Obliques, Core",
        "Dead Bug": "Core, Hip Flexors",
        "Bird Dog": "Core, Lower Back, Balance",
        "Pallof Press (cable/band)": "Core, Obliques",
        "Swiss Ball Plank": "Core, Shoulders, Balance",
        "Farmer Carry": "Core, Forearms, Traps",
        "Hanging Knee Raise": "Lower Abs, Hip Flexors",
        "Toe Touch Crunch": "Upper Abs",
        "Plank to Push-Up": "Core, Chest, Shoulders, Triceps",
        "Superman": "Lower Back, Glutes, Upper Back",
        "Reverse Snow Angel": "Upper Back, Rear Shoulders, Traps",
        "Mountain Climber": "Core, Hip Flexors, Cardio",
        "Burpee": "Full Body, Cardio",
        "Russian Twist": "Obliques, Core, Hip Flexors",
        "Bicycle Crunch": "Core, Obliques, Hip Flexors",
        "Plank Shoulder Tap": "Core, Shoulders, Stability",
        
        // CARDIO / PLYOMETRIC
        "Jump Squat": "Quads, Glutes, Power, Cardio",
        "High Knee": "Hip Flexors, Core, Cardio",
        "Lunge Jump": "Quads, Glutes, Power, Balance",
        "Butt Kick": "Hamstrings, Cardio",
        "Jumping Jack": "Full Body, Cardio",
        
        // ADDITIONAL
        "Incline Dumbbell Press (Neutral)": "Upper Chest, Front Shoulders, Triceps",
        "Cable Fly": "Chest",
        
        // BACKWARD COMPATIBILITY ALIASES
        "Cable Row": "Upper Back, Lats, Biceps",
        "Dumbbell Row": "Lats, Upper Back, Biceps",
        "Shoulder Press": "Shoulders, Triceps",
        "Lateral Raise": "Side Shoulders",
        "Dumbbell Lateral Raise": "Side Shoulders",
        "Cable Rear Delt Fly": "Rear Shoulders, Upper Back",
        "Romanian Deadlift": "Hamstrings, Glutes, Lower Back",
        "Calf Raise on Leg Press": "Calves",
        "Dumbbell Curl": "Biceps, Forearms",
        "Tricep Pushdown": "Triceps",
        "Band Pull-Apart": "Rear Shoulders, Upper Back",
        "Scapular Retraction": "Upper Back, Traps",
        
        // 🆕 MACHINE EXERCISES - CHEST
        "Incline Machine Press": "Upper Chest, Front Shoulders, Triceps",
        "Pec Fly (Machine)": "Chest, Front Shoulders",
        "Chest Dip (Machine)": "Lower Chest, Triceps",
        "Cable Chest Press": "Chest, Front Shoulders, Triceps",
        
        // 🆕 MACHINE EXERCISES - BACK
        "Seated Row": "Upper Back, Lats, Biceps",
        "High Row": "Upper Back, Rear Shoulders, Traps",
        "Pullover Machine": "Lats, Chest, Core",
        
        // 🆕 MACHINE EXERCISES - SHOULDERS
        "Shoulder Press (Machine)": "Shoulders, Triceps",
        "Lateral Raise (Machine)": "Side Shoulders, Traps",
        "Rear Delt Fly (Machine)": "Rear Shoulders, Upper Back",
        
        // 🆕 MACHINE EXERCISES - LEGS
        "Hack Squat": "Quads, Glutes",
        "Lying Leg Curl": "Hamstrings, Glutes",
        "Standing Leg Curl": "Hamstrings",
        "Hip Abduction": "Glutes, Outer Thighs",
        "Hip Adduction": "Inner Thighs, Adductors",
        "Glute Kickback": "Glutes, Hamstrings",
        "Standing Calf Raise": "Calves (Gastrocnemius)",
        "Seated Calf Raise": "Calves (Soleus)",
        
        // 🆕 MACHINE EXERCISES - ARMS
        "Biceps Curl (Machine)": "Biceps, Forearms",
        "Preacher Curl (Machine)": "Biceps, Forearms",
        "Triceps Pushdown": "Triceps",
        "Overhead Triceps Extension": "Triceps, Shoulders",
        "Triceps Dip (Machine)": "Triceps, Chest, Shoulders",
        
        // 🆕 MACHINE EXERCISES - CORE
        "Ab Crunch (Machine)": "Abs, Core",
        "Rotary Torso": "Obliques, Core",
        "Back Extension": "Lower Back, Glutes, Spinal Erectors",
        "Captain's Chair Knee Raise": "Lower Abs, Hip Flexors",
    ]
    
    // MARK: - Instructions
    
    static func instructions(for exerciseName: String) -> [String]? {
        instructionsMap[exerciseName]
    }
    
    private static let instructionsMap: [String: [String]] = [
        // CHEST EXERCISES
        "Flat Dumbbell Bench Press": [
            "Lie on a flat bench with a dumbbell in each hand, arms extended above your chest.",
            "Lower the dumbbells slowly to chest level with elbows at about 45 degrees.",
            "Press the dumbbells back up to starting position, squeezing your chest at the top.",
            "Keep your feet flat on the floor and maintain a slight arch in your lower back."
        ],
        "Incline Dumbbell Press": [
            "Set the bench to a 30-45 degree incline and lie back with dumbbells at shoulder level.",
            "Press the dumbbells up and slightly together until arms are extended.",
            "Lower slowly back to starting position at chest level.",
            "Focus on squeezing your upper chest throughout the movement."
        ],
        "Machine Chest Press": [
            "Adjust the seat so handles are at mid-chest level.",
            "Grip the handles and press forward until arms are extended.",
            "Slowly return to starting position without letting the weight stack touch.",
            "Keep your back pressed against the pad throughout."
        ],
        "Cable Chest Fly": [
            "Set cables to chest height and stand in the center with one foot forward.",
            "Hold handles with arms extended out to sides, slight bend in elbows.",
            "Bring handles together in front of your chest in a hugging motion.",
            "Slowly return to starting position with control."
        ],
        "Bench Press": [
            "Lie on bench with feet flat on floor, eyes under the bar.",
            "Grip the bar slightly wider than shoulder-width.",
            "Unrack the bar and lower it to mid-chest with elbows at 45 degrees.",
            "Press the bar back up to starting position, fully extending arms."
        ],
        "Push-Up": [
            "Start in plank position with hands slightly wider than shoulders.",
            "Lower your body until chest nearly touches the floor, elbows at 45 degrees.",
            "Push back up to starting position, keeping core tight throughout.",
            "Keep your body in a straight line from head to heels."
        ],
        "Incline Push-Up": [
            "Place hands on an elevated surface (bench, box, or countertop).",
            "Position body in a straight line with feet on the ground.",
            "Lower chest toward the elevated surface.",
            "Push back up to starting position, maintaining a tight core."
        ],
        "Diamond Push-Up": [
            "Start in plank position with hands together forming a diamond shape with thumbs and index fingers.",
            "Keep elbows close to your sides as you lower down.",
            "Lower your body until chest nearly touches your hands.",
            "Push back up to starting position, focusing on triceps."
        ],
        
        // SHOULDER EXERCISES
        "Seated Dumbbell Shoulder Press": [
            "Sit on a bench with back support, dumbbells at shoulder height.",
            "Press dumbbells overhead until arms are extended.",
            "Lower dumbbells back to shoulder level with control.",
            "Keep your core engaged and avoid arching your lower back."
        ],
        "Cable Lateral Raise": [
            "Stand sideways to a low cable machine, holding the handle with the far hand.",
            "Raise your arm out to the side until it's parallel to the floor.",
            "Keep a slight bend in your elbow throughout the movement.",
            "Lower slowly back to starting position."
        ],
        "Machine Shoulder Press": [
            "Adjust seat so handles align with your shoulders.",
            "Grip handles and press upward until arms are extended.",
            "Lower with control back to starting position.",
            "Keep your back pressed firmly against the pad."
        ],
        "Dumbbell Shrugs": [
            "Stand holding dumbbells at your sides with arms fully extended.",
            "Raise your shoulders straight up toward your ears.",
            "Hold briefly at the top, squeezing your traps.",
            "Lower shoulders back down slowly and repeat."
        ],
        "Overhead Press": [
            "Stand with barbell at shoulder height, hands slightly wider than shoulders.",
            "Press the bar overhead in a slight arc until arms are extended.",
            "Lower the bar back to shoulder level with control.",
            "Keep core tight and avoid leaning back excessively."
        ],
        "Pike Push-Up": [
            "Start in downward dog position with hips high and hands shoulder-width apart.",
            "Bend elbows and lower your head toward the ground.",
            "Press back up to starting position.",
            "Focus on using your shoulders rather than your chest."
        ],
        
        // BACK EXERCISES
        "Lat Pulldown": [
            "Sit at the machine with thighs secured under the pad.",
            "Grip the bar slightly wider than shoulder-width with palms facing away.",
            "Pull the bar down to your upper chest, leading with your elbows.",
            "Slowly extend arms back to starting position with control."
        ],
        "Seated Cable Row": [
            "Sit at the cable row machine with feet on footrests, knees slightly bent.",
            "Grip the handle and sit upright with arms extended.",
            "Pull the handle to your midsection, squeezing shoulder blades together.",
            "Slowly extend arms back to starting position."
        ],
        "Chest-Supported Row": [
            "Lie face-down on an incline bench with dumbbells or use a chest-supported machine.",
            "Let arms hang straight down, then pull weights up toward your ribcage.",
            "Squeeze shoulder blades together at the top.",
            "Lower weights slowly back to starting position."
        ],
        "Face Pull": [
            "Set cable to upper chest or face height with rope attachment.",
            "Grip rope with palms facing each other and step back to create tension.",
            "Pull rope toward your face, separating hands as they approach.",
            "Focus on squeezing shoulder blades together and keep elbows high."
        ],
        "Assisted Pull-Up": [
            "Step onto the assisted pull-up machine and select appropriate counterweight.",
            "Grip the bar with hands slightly wider than shoulders, palms away.",
            "Pull yourself up until chin is over the bar.",
            "Lower yourself with control back to starting position."
        ],
        "Rope Lat Prayer": [
            "Kneel facing a high cable with rope attachment overhead.",
            "Grip rope and pull down toward your forehead in a prayer-like motion.",
            "Keep elbows close to your sides and squeeze lats.",
            "Slowly return to starting position with control."
        ],
        "Row Machine": [
            "Sit at the rowing machine with feet secured and knees slightly bent.",
            "Grip the handle with arms extended forward.",
            "Pull handle toward your midsection, driving elbows back.",
            "Extend arms back to starting position in a controlled manner."
        ],
        "Bent Over Row": [
            "Stand with feet shoulder-width apart, holding barbell with overhand grip.",
            "Hinge at hips until torso is nearly parallel to floor, keeping back straight.",
            "Pull barbell to lower chest/upper abs, leading with elbows.",
            "Lower barbell back to starting position with control."
        ],
        "Deadlift": [
            "Stand with feet hip-width apart, barbell over mid-foot.",
            "Bend down and grip bar just outside your legs.",
            "Keep chest up, back straight, and drive through heels to stand up.",
            "Lower the bar by pushing hips back and bending knees."
        ],
        "Inverted Row": [
            "Set a bar at waist height and lie underneath it.",
            "Grip bar with hands shoulder-width apart, body straight.",
            "Pull chest up to the bar, keeping body in a straight line.",
            "Lower yourself back down with control."
        ],
        "Inverted Row (waist height)": [
            "Set a bar at waist height and lie underneath it.",
            "Grip bar with hands shoulder-width apart, body straight.",
            "Pull chest up to the bar, keeping body in a straight line.",
            "Lower yourself back down with control."
        ],
        
        // ARM EXERCISES
        "Triceps Rope Pushdown": [
            "Stand facing cable machine with rope attachment at upper chest height.",
            "Grip rope with palms facing each other, elbows at your sides.",
            "Push rope down until arms are fully extended, spreading rope apart at bottom.",
            "Slowly return to starting position, keeping elbows stationary."
        ],
        "Overhead Dumbbell Triceps Extension": [
            "Stand or sit holding a dumbbell with both hands overhead.",
            "Lower dumbbell behind your head by bending elbows.",
            "Keep upper arms stationary and close to your head.",
            "Extend arms back to starting position, squeezing triceps at top."
        ],
        "EZ Bar Curl": [
            "Stand holding EZ bar with underhand grip at the angled sections.",
            "Keep elbows close to your sides and curl bar toward shoulders.",
            "Squeeze biceps at the top of the movement.",
            "Lower bar slowly back to starting position."
        ],
        "Dumbbell Hammer Curl": [
            "Stand with dumbbells at your sides, palms facing each other.",
            "Curl dumbbells up toward shoulders, keeping palms facing in.",
            "Keep elbows stationary at your sides throughout.",
            "Lower dumbbells back to starting position with control."
        ],
        "Bench Dip (feet on floor)": [
            "Place hands on bench behind you, fingers pointing forward.",
            "Extend legs out with heels on ground (or bend knees for easier variation).",
            "Lower body by bending elbows until upper arms are parallel to floor.",
            "Push back up to starting position, focusing on triceps."
        ],
        "Suspension Bicep Curl": [
            "Hold TRX or suspension trainer handles with palms facing up.",
            "Lean back with arms extended, body straight.",
            "Curl your body up by bending elbows, bringing hands to shoulders.",
            "Lower yourself back with control."
        ],
        
        // LEG EXERCISES
        "Leg Press": [
            "Sit in leg press machine with back and hips against the pad.",
            "Place feet shoulder-width apart on the platform.",
            "Push platform away by extending legs, but don't lock knees.",
            "Lower platform slowly until knees are at about 90 degrees."
        ],
        "Goblet Squat": [
            "Hold a dumbbell vertically at chest level with both hands.",
            "Stand with feet slightly wider than shoulder-width.",
            "Squat down by pushing hips back and bending knees.",
            "Drive through heels to return to starting position."
        ],
        "Leg Extension": [
            "Sit on leg extension machine with back against pad.",
            "Position ankles under the pad with knees at 90 degrees.",
            "Extend legs until nearly straight, squeezing quads.",
            "Lower weight slowly back to starting position."
        ],
        "Leg Curl": [
            "Lie face down on leg curl machine with ankles under pad.",
            "Curl your heels toward your glutes.",
            "Squeeze hamstrings at the top of the movement.",
            "Lower weight slowly back to starting position."
        ],
        "Seated Leg Curl": [
            "Sit on seated leg curl machine with back against pad.",
            "Position ankles on top of the pad.",
            "Curl legs down and back by bending knees.",
            "Slowly return to starting position."
        ],
        "Calf Raise": [
            "Stand on calf raise machine or elevated surface with balls of feet.",
            "Lower heels as far as possible for a stretch.",
            "Push up onto toes as high as possible.",
            "Lower slowly back to starting position."
        ],
        "Bodyweight Squat": [
            "Stand with feet shoulder-width apart, toes slightly out.",
            "Lower down by pushing hips back and bending knees.",
            "Keep chest up and weight in heels.",
            "Drive through heels to return to standing."
        ],
        "Split Squat": [
            "Stand in a staggered stance with one foot forward, one back.",
            "Lower down by bending both knees until front thigh is parallel to ground.",
            "Keep torso upright and front knee behind toes.",
            "Push through front heel to return to starting position."
        ],
        "Bulgarian Split Squat": [
            "Place back foot on elevated surface behind you.",
            "Stand on front leg with back foot elevated.",
            "Lower down until front thigh is parallel to ground.",
            "Push through front heel to return up."
        ],
        "Barbell Squat": [
            "Position barbell on upper back (high bar) or rear delts (low bar).",
            "Stand with feet shoulder-width apart.",
            "Squat down by pushing hips back and bending knees.",
            "Drive through heels to return to standing."
        ],
        "Assisted Pistol Squat": [
            "Stand on one leg while holding TRX straps or a support.",
            "Extend the other leg straight out in front.",
            "Lower down on one leg as far as comfortable.",
            "Use assistance to return to standing position."
        ],
        "Lateral Lunge": [
            "Stand with feet together.",
            "Step out to the side, bending that knee while keeping other leg straight.",
            "Push off the bent leg to return to center.",
            "Alternate sides or complete all reps on one side first."
        ],
        
        // GLUTE EXERCISES
        "Glute Bridge": [
            "Lie on your back with knees bent, feet flat on floor hip-width apart.",
            "Push through heels to lift hips toward ceiling.",
            "Squeeze glutes hard at the top.",
            "Lower hips back down slowly and repeat."
        ],
        "Hip Thrust": [
            "Sit on ground with upper back against a bench.",
            "Place barbell or weight over hips (or use bodyweight).",
            "Drive through heels to lift hips until body forms straight line.",
            "Squeeze glutes hard at top, then lower with control."
        ],
        "Single Leg Glute Bridge": [
            "Lie on your back with one knee bent, foot flat.",
            "Extend the other leg straight out.",
            "Push through planted heel to lift hips up.",
            "Squeeze glutes at top, lower slowly, then switch legs."
        ],
        "Nordic Hamstring Curl": [
            "Kneel with ankles secured under a pad or held by partner.",
            "Keep body straight from knees to head.",
            "Lower body forward slowly, resisting with hamstrings.",
            "Use hands to catch yourself, then push back to starting position."
        ],
        
        // CORE EXERCISES
        "Front Plank": [
            "Start in forearm plank position with elbows under shoulders.",
            "Keep body in straight line from head to heels.",
            "Engage core and squeeze glutes.",
            "Hold position without letting hips sag or pike up."
        ],
        "Side Plank": [
            "Lie on side with forearm on ground, elbow under shoulder.",
            "Stack feet or stagger them for more stability.",
            "Lift hips off ground to form straight line.",
            "Hold position, then switch sides."
        ],
        "Dead Bug": [
            "Lie on back with arms extended toward ceiling, knees bent at 90°.",
            "Lower opposite arm and leg toward floor simultaneously.",
            "Keep lower back pressed to floor throughout.",
            "Return to start and repeat on other side."
        ],
        "Bird Dog": [
            "Start on hands and knees in tabletop position.",
            "Extend opposite arm and leg simultaneously.",
            "Keep hips level and core engaged.",
            "Return to start and repeat on opposite side."
        ],
        "Pallof Press (cable/band)": [
            "Stand sideways to cable machine with handle at chest height.",
            "Hold handle at chest with both hands.",
            "Press hands straight out in front, resisting rotation.",
            "Pull back to chest and repeat, then switch sides."
        ],
        "Swiss Ball Plank": [
            "Place forearms on stability ball, body in plank position.",
            "Keep body straight from head to heels.",
            "Engage core to maintain balance.",
            "Hold position without letting hips sag."
        ],
        "Farmer Carry": [
            "Hold heavy dumbbells or kettlebells at your sides.",
            "Stand tall with shoulders back and core engaged.",
            "Walk forward with controlled steps.",
            "Keep weights stable and posture upright throughout."
        ],
        "Hanging Knee Raise": [
            "Hang from pull-up bar with arms extended.",
            "Engage core and lift knees toward chest.",
            "Control the descent back to starting position.",
            "Avoid swinging or using momentum."
        ],
        "Toe Touch Crunch": [
            "Lie on back with legs extended toward ceiling.",
            "Reach arms toward toes, lifting shoulder blades off ground.",
            "Squeeze abs at the top.",
            "Lower slowly back down and repeat."
        ],
        "Plank to Push-Up": [
            "Start in forearm plank position.",
            "Press up onto hands one arm at a time.",
            "Lower back down to forearms one arm at a time.",
            "Alternate which arm leads."
        ],
        "Superman": [
            "Lie face down with arms extended overhead.",
            "Simultaneously lift arms, chest, and legs off the ground.",
            "Squeeze glutes and lower back.",
            "Lower back down with control."
        ],
        "Reverse Snow Angel": [
            "Lie face down with arms at your sides, palms facing down.",
            "Lift chest and arms slightly off the ground.",
            "Sweep arms overhead in an arc (like making a snow angel).",
            "Sweep arms back to starting position, keeping chest lifted throughout."
        ],
        "Mountain Climber": [
            "Start in push-up position with arms straight.",
            "Drive one knee toward chest, then quickly switch legs.",
            "Keep hips level and core engaged.",
            "Move at a pace you can control."
        ],
        "Burpee": [
            "Start standing, then drop into squat with hands on floor.",
            "Jump feet back into push-up position.",
            "Perform a push-up (optional), then jump feet back to squat.",
            "Jump up explosively with arms overhead."
        ],
        "Russian Twist": [
            "Sit on floor with knees bent, feet lifted off ground.",
            "Lean back slightly to engage core.",
            "Rotate torso side to side, touching floor beside hips.",
            "Keep core tight throughout movement."
        ],
        "Bicycle Crunch": [
            "Lie on back with hands behind head, legs lifted.",
            "Bring right elbow toward left knee while extending right leg.",
            "Switch sides in a pedaling motion.",
            "Keep lower back pressed to floor."
        ],
        "Plank Shoulder Tap": [
            "Start in high plank position (push-up position).",
            "Keeping hips stable, tap left shoulder with right hand.",
            "Return hand to floor, then tap right shoulder with left hand.",
            "Alternate sides while minimizing hip rotation."
        ],
        "Jump Squat": [
            "Start in standing position, feet shoulder-width apart.",
            "Lower into full squat position.",
            "Explosively jump straight up.",
            "Land softly and immediately descend into next rep."
        ],
        "High Knee": [
            "Stand tall with feet hip-width apart.",
            "Drive one knee up to hip height while opposite arm pumps forward.",
            "Quickly alternate legs in a running motion.",
            "Stay on balls of feet for maximum speed."
        ],
        "Lunge Jump": [
            "Start in lunge position with one foot forward.",
            "Jump explosively, switching legs mid-air.",
            "Land in lunge position with opposite leg forward.",
            "Immediately descend and repeat."
        ],
        "Butt Kick": [
            "Stand tall, then run in place.",
            "Kick heels up toward glutes with each step.",
            "Pump arms as if running.",
            "Move at a quick pace."
        ],
        "Jumping Jack": [
            "Start standing with feet together, arms at sides.",
            "Jump while spreading legs and raising arms overhead.",
            "Jump again to return to starting position.",
            "Repeat in a rhythmic motion."
        ],
        "Front Plank (hold)": [
            "Get into forearm plank position.",
            "Hold body in straight line from head to heels.",
            "Engage core and glutes throughout.",
            "Hold for prescribed time while breathing normally."
        ],
        
        // ADDITIONAL
        "Incline Dumbbell Press (Neutral)": [
            "Set bench to 30-45 degree incline with dumbbells at shoulder level.",
            "Hold dumbbells with palms facing each other (neutral grip).",
            "Press dumbbells up until arms are extended.",
            "Lower slowly back to starting position."
        ],
        "Cable Fly": [
            "Set cables to chest height and stand in center.",
            "Hold handles with arms extended, slight bend in elbows.",
            "Bring handles together in front of chest.",
            "Return to starting position with control."
        ],
        
        // BACKWARD COMPATIBILITY ALIASES
        "Cable Row": [
            "Sit at cable row with feet on footrests, knees slightly bent.",
            "Grip handle with arms extended.",
            "Pull handle to midsection, squeezing shoulder blades.",
            "Extend arms back slowly with control."
        ],
        "Dumbbell Row": [
            "Bend at hips with one hand supported on bench.",
            "Hold dumbbell in other hand, arm hanging straight.",
            "Pull dumbbell to ribcage, driving elbow back.",
            "Lower slowly and repeat, then switch sides."
        ],
        "Shoulder Press": [
            "Sit with dumbbells at shoulder height.",
            "Press dumbbells overhead until arms are extended.",
            "Lower back to shoulder level with control.",
            "Keep core engaged throughout."
        ],
        "Lateral Raise": [
            "Stand holding dumbbells at sides.",
            "Raise arms out to sides until parallel with floor.",
            "Keep slight bend in elbows throughout.",
            "Lower slowly back to starting position."
        ],
        "Dumbbell Lateral Raise": [
            "Stand holding dumbbells at sides.",
            "Raise arms out to sides until parallel with floor.",
            "Keep slight bend in elbows throughout.",
            "Lower slowly back to starting position."
        ],
        "Cable Rear Delt Fly": [
            "Set cables at shoulder height, cross cables.",
            "Stand in center and grip opposite handles.",
            "Pull handles apart and back, squeezing shoulder blades.",
            "Return to starting position with control."
        ],
        "Romanian Deadlift": [
            "Stand with barbell at hip level, feet hip-width apart.",
            "Push hips back while lowering bar along thighs.",
            "Keep back straight and knees slightly bent.",
            "Drive hips forward to return to standing."
        ],
        "Calf Raise on Leg Press": [
            "Sit in leg press with balls of feet on platform edge.",
            "Lower heels below platform for a stretch.",
            "Push up onto toes as high as possible.",
            "Lower slowly and repeat."
        ],
        "Dumbbell Curl": [
            "Stand with dumbbells at sides, palms facing forward.",
            "Curl dumbbells toward shoulders.",
            "Keep elbows stationary at your sides.",
            "Lower slowly back to starting position."
        ],
        "Tricep Pushdown": [
            "Stand facing cable with bar at upper chest height.",
            "Grip bar with palms down, elbows at sides.",
            "Push bar down until arms are fully extended.",
            "Return slowly to starting position."
        ],
        "Band Pull-Apart": [
            "Hold resistance band at chest height with arms extended.",
            "Pull band apart by moving hands out to sides.",
            "Squeeze shoulder blades together.",
            "Return to starting position with control."
        ],
        "Scapular Retraction": [
            "Stand or sit with arms at sides.",
            "Squeeze shoulder blades together.",
            "Hold for a moment, feeling upper back muscles.",
            "Release and repeat."
        ],
        
        // 🆕 MACHINE EXERCISES - CHEST
        "Incline Machine Press": [
            "Adjust seat height so handles align with upper chest.",
            "Grip handles and press upward and slightly together.",
            "Extend arms fully without locking elbows.",
            "Lower with control back to starting position."
        ],
        "Pec Fly (Machine)": [
            "Sit with back firmly against pad, feet flat on floor.",
            "Place forearms on pads with elbows at shoulder height.",
            "Bring pads together in front of chest by squeezing pecs.",
            "Slowly return to starting position with control."
        ],
        "Chest Dip (Machine)": [
            "Adjust seat height and select appropriate assistance weight.",
            "Grip handles and lean slightly forward.",
            "Lower body by bending elbows until upper arms are parallel to floor.",
            "Press back up to starting position, focusing on chest and triceps."
        ],
        "Cable Chest Press": [
            "Set cables to chest height and stand in the middle, one foot forward.",
            "Hold handles at chest level with elbows bent.",
            "Press handles forward until arms are extended.",
            "Slowly return to starting position with control."
        ],
        
        // 🆕 MACHINE EXERCISES - BACK
        "Seated Row": [
            "Sit with chest against pad, feet on footrests.",
            "Grip handles with arms extended forward.",
            "Pull handles toward midsection, driving elbows back.",
            "Squeeze shoulder blades together, then slowly extend arms."
        ],
        "High Row": [
            "Adjust seat so handles are at upper chest/shoulder height.",
            "Grip handles and pull toward upper chest/face.",
            "Keep elbows high and squeeze shoulder blades together.",
            "Slowly return to starting position with control."
        ],
        "Pullover Machine": [
            "Adjust seat so your shoulders align with the pivot point.",
            "Place elbows on pads with arms slightly bent.",
            "Pull pads down in an arc until they reach your sides.",
            "Slowly return to starting position, feeling lat stretch."
        ],
        
        // 🆕 MACHINE EXERCISES - SHOULDERS
        "Shoulder Press (Machine)": [
            "Adjust seat so handles are at shoulder height.",
            "Grip handles and press upward until arms are extended.",
            "Don't lock elbows at the top.",
            "Lower with control back to shoulder level."
        ],
        "Lateral Raise (Machine)": [
            "Sit with back against pad, arms positioned on pads.",
            "Raise arms out to the sides until parallel with floor.",
            "Pause at the top and squeeze shoulders.",
            "Lower slowly back to starting position."
        ],
        "Rear Delt Fly (Machine)": [
            "Adjust seat height so handles are at shoulder level.",
            "Sit facing the machine with chest against pad.",
            "Pull handles back and apart, squeezing shoulder blades.",
            "Focus on rear delts, not just arms."
        ],
        
        // 🆕 MACHINE EXERCISES - LEGS
        "Hack Squat": [
            "Position shoulders under pads, feet shoulder-width on platform.",
            "Release safety handles and lower by bending knees.",
            "Descend until thighs are parallel to platform.",
            "Drive through heels to return to starting position."
        ],
        "Lying Leg Curl": [
            "Lie face down with ankles under the pad.",
            "Grip handles for stability and curl heels toward glutes.",
            "Squeeze hamstrings at the top of the movement.",
            "Lower weight slowly back to starting position."
        ],
        "Standing Leg Curl": [
            "Stand on one leg, position other ankle under the pad.",
            "Hold handles for balance and curl heel toward glute.",
            "Squeeze hamstring at the top.",
            "Lower slowly and repeat, then switch legs."
        ],
        "Hip Abduction": [
            "Sit with back against pad, legs positioned against pads.",
            "Push legs outward against resistance.",
            "Pause at maximum abduction and squeeze glutes.",
            "Slowly return legs together with control."
        ],
        "Hip Adduction": [
            "Sit with back against pad, legs positioned wide against pads.",
            "Bring legs together against resistance.",
            "Squeeze inner thighs at the end of the movement.",
            "Slowly return to starting position with control."
        ],
        "Glute Kickback": [
            "Position knee and hands on pads for support.",
            "Place foot against the plate or pad behind you.",
            "Push leg back and up, squeezing glutes.",
            "Lower with control and repeat, then switch legs."
        ],
        "Standing Calf Raise": [
            "Stand with shoulders under pads, balls of feet on platform.",
            "Lower heels as far as possible to stretch calves.",
            "Push up onto toes as high as possible.",
            "Pause at the top, then lower slowly."
        ],
        "Seated Calf Raise": [
            "Sit with knees under pad, balls of feet on platform.",
            "Lower heels below the platform for a stretch.",
            "Push up onto toes as high as possible.",
            "Pause at top, then lower slowly and repeat."
        ],
        
        // 🆕 MACHINE EXERCISES - ARMS
        "Biceps Curl (Machine)": [
            "Sit with arms resting on pad, elbows aligned with pivot.",
            "Grip handles with underhand grip.",
            "Curl handles up toward shoulders.",
            "Lower slowly back to starting position."
        ],
        "Preacher Curl (Machine)": [
            "Adjust seat so armpits rest on top of pad.",
            "Grip handles with underhand grip, arms extended.",
            "Curl handles up, keeping upper arms on pad.",
            "Lower slowly, fully extending arms."
        ],
        "Triceps Pushdown": [
            "Stand facing cable with attachment at upper chest height.",
            "Grip bar or rope with palms down (or neutral for rope).",
            "Push down until arms are fully extended.",
            "Slowly return to starting position, keeping elbows stationary."
        ],
        "Overhead Triceps Extension": [
            "Sit or stand at machine with handles behind head.",
            "Grip handles and extend arms upward.",
            "Keep upper arms stationary throughout movement.",
            "Lower slowly back to starting position."
        ],
        "Triceps Dip (Machine)": [
            "Grip handles and position yourself on the machine.",
            "Select appropriate assistance weight if using assisted version.",
            "Lower body by bending elbows until upper arms are parallel.",
            "Push back up to starting position, focusing on triceps."
        ],
        
        // 🆕 MACHINE EXERCISES - CORE
        "Ab Crunch (Machine)": [
            "Sit with back against pad, grip handles above shoulders.",
            "Crunch forward by flexing abs and pulling handles down.",
            "Squeeze abs hard at bottom of the movement.",
            "Slowly return to starting position with control."
        ],
        "Rotary Torso": [
            "Sit with back against pad, secure legs under pads.",
            "Grip handles and rotate torso to one side.",
            "Keep hips and legs stationary, only rotate upper body.",
            "Return to center and repeat on other side."
        ],
        "Back Extension": [
            "Position hips on pad with ankles secured.",
            "Cross arms over chest or behind head.",
            "Lower upper body forward, then extend back up.",
            "Squeeze lower back and glutes at the top."
        ],
        "Captain's Chair Knee Raise": [
            "Position forearms on pads, back against pad.",
            "Grip handles and hang with legs extended.",
            "Raise knees toward chest by flexing hips.",
            "Lower legs slowly with control and repeat."
        ],
    ]
    
    // MARK: - Form Tips
    
    static func formTips(for exerciseName: String) -> [String]? {
        formTipsMap[exerciseName]
    }
    
    private static let formTipsMap: [String: [String]] = [
        // CHEST EXERCISES
        "Flat Dumbbell Bench Press": [
            "Keep your shoulder blades retracted and pressed into the bench",
            "Don't let the dumbbells drift too far apart at the top",
            "Control the descent - avoid dropping the weight",
            "Stop if you feel shoulder pain"
        ],
        "Incline Dumbbell Press": [
            "Don't set the incline too steep (over 45°) or it becomes a shoulder exercise",
            "Keep wrists straight, don't let them bend backward",
            "Press slightly back toward your head, not straight up",
            "Avoid arching your lower back excessively"
        ],
        "Machine Chest Press": [
            "Adjust seat height so movement feels natural",
            "Don't lock out elbows completely at the top",
            "Keep shoulder blades back and down",
            "Exhale as you press, inhale as you return"
        ],
        "Cable Chest Fly": [
            "Maintain a slight bend in elbows throughout the movement",
            "Don't let cables pull your shoulders forward",
            "Focus on chest contraction, not arm movement",
            "Keep core engaged and posture upright"
        ],
        "Bench Press": [
            "Keep feet flat on floor for stability",
            "Retract shoulder blades before unracking",
            "Lower the bar to your sternum, not your neck",
            "Use a spotter for heavy weights"
        ],
        "Push-Up": [
            "Don't let hips sag or pike up",
            "Keep neck neutral, don't look up",
            "Hands should be directly under shoulders",
            "If too difficult, modify with knees on ground"
        ],
        "Incline Push-Up": [
            "The higher the surface, the easier the exercise",
            "Keep core tight to avoid sagging",
            "Lower yourself slowly and with control",
            "Great low-back friendly option for beginners"
        ],
        "Diamond Push-Up": [
            "This is harder than regular push-ups",
            "Keep elbows tucked in close to your sides",
            "Focus on triceps engagement",
            "If too difficult, do them on knees or use an elevated surface"
        ],
        
        // SHOULDER EXERCISES
        "Seated Dumbbell Shoulder Press": [
            "Keep lower back pressed against the bench",
            "Don't press the dumbbells forward - keep them over your head",
            "Avoid excessive arching or leaning back",
            "Lower the weights to ear level, not all the way down"
        ],
        "Cable Lateral Raise": [
            "Don't swing or use momentum",
            "Lead with your elbow, not your hand",
            "Keep your torso still throughout",
            "Stop at shoulder height - going higher engages traps"
        ],
        "Machine Shoulder Press": [
            "Exhale as you press up, inhale as you lower",
            "Keep core engaged throughout",
            "Don't lock out elbows at the top",
            "Adjust seat so movement feels smooth and natural"
        ],
        "Dumbbell Shrugs": [
            "Don't roll your shoulders - lift straight up and down",
            "Keep arms fully extended, don't bend elbows",
            "Focus on squeezing traps at the top",
            "Use controlled movements, avoid bouncing"
        ],
        "Overhead Press": [
            "Keep core tight to protect lower back",
            "Press the bar slightly back so it clears your face",
            "Don't hyperextend your lower back",
            "Use a weight you can control without excessive leaning"
        ],
        "Pike Push-Up": [
            "Keep hips high throughout the movement",
            "Look between your hands, not forward",
            "Progress to handstand push-ups when ready",
            "Great bodyweight shoulder builder"
        ],
        
        // BACK EXERCISES
        "Lat Pulldown": [
            "Don't lean back excessively - slight lean is OK",
            "Pull with your back, not your arms",
            "Keep chest up and shoulders back",
            "Avoid using momentum or swinging"
        ],
        "Seated Cable Row": [
            "Keep torso upright, don't rock back and forth",
            "Drive elbows back, not just hands",
            "Squeeze shoulder blades at the end of each rep",
            "Maintain slight bend in knees throughout"
        ],
        "Chest-Supported Row": [
            "Excellent low-back friendly option",
            "Let chest rest fully on the bench",
            "Don't use momentum - control the weight",
            "Focus on squeezing shoulder blades together"
        ],
        "Face Pull": [
            "Keep elbows high, parallel to shoulders",
            "Pull rope to nose/forehead level, not chest",
            "Great for posture and rear shoulder health",
            "Use lighter weight and focus on form"
        ],
        "Assisted Pull-Up": [
            "Start with more assistance and gradually decrease",
            "Pull with your back, not just arms",
            "Don't swing or use momentum",
            "Full range of motion is important"
        ],
        "Rope Lat Prayer": [
            "Keep core engaged throughout",
            "Focus on lat contraction, not arm movement",
            "Great for low-back friendly lat training",
            "Don't use excessive weight"
        ],
        "Row Machine": [
            "Keep back straight throughout the movement",
            "Drive through your heels if seated",
            "Don't round your back at any point",
            "Breathe out as you pull"
        ],
        "Bent Over Row": [
            "Keep back flat, not rounded",
            "This exercise loads the lower back - use proper form",
            "Don't row too high - aim for lower chest",
            "If you have back issues, use chest-supported rows instead"
        ],
        "Deadlift": [
            "This is an advanced exercise - learn proper form first",
            "Keep bar close to your body throughout",
            "Don't round your lower back",
            "Not recommended if you have lower back problems"
        ],
        "Inverted Row": [
            "Keep body straight like a plank",
            "Pull shoulder blades together first, then pull",
            "Lower the bar for more difficulty",
            "Great low-back friendly alternative to bent over rows"
        ],
        "Inverted Row (waist height)": [
            "Keep body straight like a plank",
            "Pull shoulder blades together first, then pull",
            "Lower the bar for more difficulty",
            "Great low-back friendly alternative to bent over rows"
        ],
        
        // ARM EXERCISES
        "Triceps Rope Pushdown": [
            "Keep elbows pinned to your sides - don't let them flare",
            "Focus on triceps contraction, not pushing with shoulders",
            "Don't lean forward excessively",
            "Fully extend arms at the bottom for maximum contraction"
        ],
        "Overhead Dumbbell Triceps Extension": [
            "Keep upper arms vertical and stationary",
            "Don't let elbows flare out to the sides",
            "Use controlled movement - avoid jerking",
            "Stop if you feel elbow discomfort"
        ],
        "EZ Bar Curl": [
            "Don't swing or use momentum",
            "Keep elbows stationary - they shouldn't move forward",
            "Squeeze biceps hard at the top",
            "Lower slowly for better muscle development"
        ],
        "Dumbbell Hammer Curl": [
            "Keep palms facing each other throughout - don't rotate",
            "Don't swing the weights",
            "Targets both biceps and forearms",
            "Can be done alternating or simultaneously"
        ],
        "Bench Dip (feet on floor)": [
            "Don't go too low if you feel shoulder discomfort",
            "Keep elbows pointing back, not out to sides",
            "Straighten legs for more difficulty, bend for easier",
            "Low-back friendly tricep exercise"
        ],
        "Suspension Bicep Curl": [
            "Keep body straight and core engaged",
            "The more you lean back, the harder it gets",
            "Don't let hips sag",
            "Great for building biceps with bodyweight"
        ],
        
        // LEG EXERCISES
        "Leg Press": [
            "Excellent low-back friendly option",
            "Don't lock knees at the top",
            "Keep lower back pressed against the pad",
            "Don't go so low that hips lift off the pad"
        ],
        "Goblet Squat": [
            "Keep chest up and core engaged",
            "Great for learning squat form",
            "Low-back friendly when done properly",
            "Elbows should track inside knees at bottom"
        ],
        "Leg Extension": [
            "Don't use excessive weight - focus on control",
            "Squeeze quads hard at the top",
            "Great isolation exercise for quads",
            "Don't lock knees completely at top"
        ],
        "Leg Curl": [
            "Keep hips pressed to the pad",
            "Don't arch lower back during movement",
            "Focus on hamstring contraction",
            "Use controlled tempo"
        ],
        "Seated Leg Curl": [
            "Low-back friendly hamstring exercise",
            "Keep back against pad throughout",
            "Don't use momentum",
            "Squeeze hamstrings at bottom"
        ],
        "Calf Raise": [
            "Full range of motion is key",
            "Pause at the top for better contraction",
            "Don't bounce at the bottom",
            "Can be done seated or standing"
        ],
        "Bodyweight Squat": [
            "Keep knees tracking over toes",
            "Don't let knees cave inward",
            "Chest stays up throughout",
            "Perfect for learning proper squat mechanics"
        ],
        "Split Squat": [
            "Don't let front knee go past toes",
            "Keep torso upright",
            "Low-back friendly single-leg exercise",
            "Great for balance and stability"
        ],
        "Bulgarian Split Squat": [
            "More challenging than regular split squat",
            "Keep weight in front heel",
            "Don't let front knee collapse inward",
            "Excellent for glute and quad development"
        ],
        "Barbell Squat": [
            "This loads the spine - learn proper form first",
            "Keep chest up and core braced",
            "Not recommended if you have lower back issues",
            "Consider leg press or goblet squat as alternatives"
        ],
        "Assisted Pistol Squat": [
            "Advanced single-leg exercise",
            "Use assistance until you build strength",
            "Keep knee tracking over toes",
            "Great for balance and unilateral strength"
        ],
        "Lateral Lunge": [
            "Keep toes pointing forward",
            "Push hips back as you lunge to the side",
            "Great for inner thigh and glutes",
            "Low-back friendly movement"
        ],
        
        // GLUTE EXERCISES
        "Glute Bridge": [
            "Excellent low-back friendly glute exercise",
            "Don't hyperextend at top - stop at straight line",
            "Squeeze glutes, not just pushing with legs",
            "Can add weight on hips for progression"
        ],
        "Hip Thrust": [
            "Most effective glute exercise",
            "Upper back should rest on bench, not neck",
            "Drive through heels, not toes",
            "Low-back friendly when done correctly"
        ],
        "Single Leg Glute Bridge": [
            "Keep hips level throughout movement",
            "Don't let extended leg drop",
            "More challenging than regular glute bridge",
            "Great for addressing imbalances"
        ],
        "Nordic Hamstring Curl": [
            "Advanced exercise - start with small range of motion",
            "Very effective for hamstring strength",
            "Use hands to assist on the way up if needed",
            "Excellent for injury prevention"
        ],
        
        // CORE EXERCISES
        "Front Plank": [
            "Don't hold your breath - breathe normally",
            "Quality over duration - maintain perfect form",
            "Low-back friendly core exercise",
            "Start with shorter holds and build up"
        ],
        "Side Plank": [
            "Keep body in straight line - don't let hips sag",
            "Great for obliques and stability",
            "Can drop to knees for easier variation",
            "Build up hold time gradually"
        ],
        "Dead Bug": [
            "Excellent low-back friendly core exercise",
            "Press lower back into floor throughout",
            "Move slowly and with control",
            "Great for learning core stability"
        ],
        "Bird Dog": [
            "Perfect for low back health and core stability",
            "Keep hips and shoulders square to ground",
            "Move slowly and deliberately",
            "Focus on balance and control"
        ],
        "Pallof Press (cable/band)": [
            "Excellent anti-rotation core exercise",
            "Stand far enough from anchor for tension",
            "Keep hips and shoulders square forward",
            "Low-back friendly core training"
        ],
        "Swiss Ball Plank": [
            "More challenging than regular plank",
            "Keep ball stable by engaging core",
            "Great for improving balance",
            "Low-back friendly when done correctly"
        ],
        "Farmer Carry": [
            "Excellent functional core exercise",
            "Keep shoulders back, don't let them round forward",
            "Low-back friendly with proper posture",
            "Builds grip strength too"
        ],
        "Hanging Knee Raise": [
            "Don't swing - use controlled movement",
            "Focus on lower abs",
            "Can bend knees more for easier variation",
            "Advanced core exercise"
        ],
        "Toe Touch Crunch": [
            "Keep legs straight throughout",
            "Focus on ab contraction, not momentum",
            "Low-back friendly ab exercise",
            "Don't pull on neck"
        ],
        "Plank to Push-Up": [
            "Keep core tight to avoid hip rotation",
            "Builds both core and upper body strength",
            "Move with control, not speed",
            "Low-back friendly dynamic plank"
        ],
        "Superman": [
            "Strengthens lower back and glutes",
            "Don't overextend - lift only as high as comfortable",
            "Hold briefly at top",
            "Good for posterior chain"
        ],
        "Reverse Snow Angel": [
            "Excellent for upper back and rear shoulders",
            "Keep chest lifted throughout the entire movement",
            "Move arms slowly and with control",
            "Great for improving posture and shoulder health"
        ],
        "Mountain Climber": [
            "Great cardio and core combination",
            "Keep hips level - don't let them bounce",
            "Low-back friendly when done with control",
            "Scale pace to your fitness level"
        ],
        "Burpee": [
            "Full body cardio exercise",
            "Can modify by stepping back instead of jumping",
            "Keep core engaged throughout",
            "Great for conditioning"
        ],
        "Russian Twist": [
            "Sit with knees bent, feet off floor for harder variation",
            "Rotate torso, not just arms",
            "Keep core engaged throughout",
            "Can hold weight for added difficulty"
        ],
        "Bicycle Crunch": [
            "Focus on quality over speed",
            "Bring opposite elbow to knee",
            "Keep lower back pressed to floor",
            "Excellent for obliques and core"
        ],
        "Plank Shoulder Tap": [
            "Keep hips stable - minimize rotation",
            "Tap opposite shoulder alternating sides",
            "Widen stance for easier balance",
            "Great for core stability and anti-rotation"
        ],
        "Jump Squat": [
            "Land softly with knees slightly bent",
            "Full squat depth before jumping",
            "High intensity - use for power and cardio",
            "Rest if form breaks down"
        ],
        "High Knee": [
            "Drive knees up to hip height",
            "Pump arms for momentum",
            "Excellent cardio and hip flexor work",
            "Keep core tight and chest up"
        ],
        "Lunge Jump": [
            "Land softly in lunge position",
            "Switch legs mid-air",
            "High impact - ensure proper warmup",
            "Great for power and single-leg strength"
        ],
        "Butt Kick": [
            "Kick heels to glutes",
            "Stay on balls of feet",
            "Excellent cardio and hamstring activation",
            "Move at your own pace"
        ],
        "Jumping Jack": [
            "Classic cardio movement",
            "Land softly on each rep",
            "Low impact modification: step side-to-side",
            "Great for warmup or conditioning"
        ],
        
        // ADDITIONAL
        "Incline Dumbbell Press (Neutral)": [
            "Neutral grip reduces shoulder strain",
            "Keep elbows closer to body than regular press",
            "Good alternative if shoulders bother you",
            "Low-back friendly pressing variation"
        ],
        "Cable Fly": [
            "Keep slight bend in elbows throughout",
            "Focus on chest contraction",
            "Don't let cables pull shoulders forward",
            "Low-back friendly chest isolation"
        ],
        
        // BACKWARD COMPATIBILITY ALIASES
        "Cable Row": [
            "Keep torso upright, don't rock back and forth",
            "Drive elbows back, not just hands",
            "Squeeze shoulder blades at end of each rep",
            "Low-back friendly rowing option"
        ],
        "Dumbbell Row": [
            "Keep back flat, core engaged",
            "Pull with back, not just arm",
            "Don't rotate torso during movement",
            "Great for addressing left/right imbalances"
        ],
        "Shoulder Press": [
            "Keep core tight to protect lower back",
            "Don't arch back excessively",
            "Press slightly back, not straight up",
            "Exhale as you press up"
        ],
        "Lateral Raise": [
            "Don't swing or use momentum",
            "Lead with elbow, not hand",
            "Stop at shoulder height",
            "Light weight with perfect form is best"
        ],
        "Dumbbell Lateral Raise": [
            "Don't swing or use momentum",
            "Lead with elbow, not hand",
            "Stop at shoulder height",
            "Light weight with perfect form is best"
        ],
        "Cable Rear Delt Fly": [
            "Keep elbows slightly bent throughout",
            "Focus on rear delts, not arms",
            "Don't use momentum",
            "Great for shoulder health and posture"
        ],
        "Romanian Deadlift": [
            "Keep bar close to body throughout",
            "Don't round your back",
            "Feel stretch in hamstrings at bottom",
            "Not recommended if you have lower back issues"
        ],
        "Calf Raise on Leg Press": [
            "Use full range of motion",
            "Pause at top for better contraction",
            "Keep knees locked but not hyperextended",
            "Great alternative to standing calf raises"
        ],
        "Dumbbell Curl": [
            "Don't swing weights or use momentum",
            "Keep elbows stationary",
            "Squeeze biceps at top",
            "Lower slowly for better results"
        ],
        "Tricep Pushdown": [
            "Keep elbows pinned to sides",
            "Don't lean forward excessively",
            "Fully extend arms at bottom",
            "Focus on triceps, not shoulders"
        ],
        "Band Pull-Apart": [
            "Use light resistance band",
            "Keep arms straight throughout",
            "Excellent for shoulder health",
            "Great warm-up or finisher exercise"
        ],
        "Scapular Retraction": [
            "Focus on squeezing shoulder blades",
            "Don't shrug shoulders up",
            "Great for posture improvement",
            "Can be done throughout the day"
        ],
        
        // 🆕 MACHINE EXERCISES - CHEST
        "Incline Machine Press": [
            "Adjust seat carefully for comfortable range of motion",
            "Don't lock elbows at the top",
            "Excellent for upper chest development",
            "Low-back friendly alternative to free weight incline press"
        ],
        "Pec Fly (Machine)": [
            "Don't overstretch at the starting position",
            "Focus on squeezing chest, not pushing with arms",
            "Keep shoulder blades back against pad",
            "Great isolation exercise for chest"
        ],
        "Chest Dip (Machine)": [
            "Lean forward more to emphasize chest over triceps",
            "Don't go too deep if shoulders feel uncomfortable",
            "Assisted version helps build strength for bodyweight dips",
            "Low-back friendly compound exercise"
        ],
        "Cable Chest Press": [
            "Keep core tight for stability",
            "Stand far enough from cables to maintain tension",
            "Great for unilateral training (one arm at a time)",
            "Low-back friendly pressing variation"
        ],
        
        // 🆕 MACHINE EXERCISES - BACK
        "Seated Row": [
            "Excellent low-back friendly rowing option",
            "Chest pad prevents using momentum",
            "Focus on pulling with back, not just arms",
            "Keep chest pressed to pad throughout"
        ],
        "High Row": [
            "Targets upper back and rear shoulders",
            "Keep elbows high, don't pull down",
            "Great for posture improvement",
            "Low-back friendly upper back exercise"
        ],
        "Pullover Machine": [
            "Keep core braced throughout",
            "Don't use excessive weight - focus on form",
            "Excellent for lat development",
            "Low-back friendly lat isolation"
        ],
        
        // 🆕 MACHINE EXERCISES - SHOULDERS
        "Shoulder Press (Machine)": [
            "Machine provides stability for heavier loads",
            "Keep core engaged even though seated",
            "Don't arch lower back excessively",
            "Low-back friendly shoulder press option"
        ],
        "Lateral Raise (Machine)": [
            "Don't use momentum or swing",
            "Pause at top for better muscle activation",
            "Excellent for isolating side delts",
            "Low-back friendly shoulder isolation"
        ],
        "Rear Delt Fly (Machine)": [
            "Essential for shoulder health and posture",
            "Keep chest against pad, don't round back",
            "Use controlled movement, not momentum",
            "Low-back friendly rear delt work"
        ],
        
        // 🆕 MACHINE EXERCISES - LEGS
        "Hack Squat": [
            "Excellent low-back friendly squat variation",
            "Keep back flat against pad",
            "Don't lock knees at top",
            "Great for quad development"
        ],
        "Lying Leg Curl": [
            "Keep hips pressed to pad throughout",
            "Don't arch lower back",
            "Great hamstring isolation",
            "Low-back friendly"
        ],
        "Standing Leg Curl": [
            "Hold machine for balance",
            "Focus on hamstring contraction, not swinging",
            "Great for single-leg work",
            "Low-back friendly"
        ],
        "Hip Abduction": [
            "Don't use excessive weight",
            "Focus on glute activation",
            "Important for hip stability",
            "Low-back friendly"
        ],
        "Hip Adduction": [
            "Essential for inner thigh strength",
            "Don't slam weight down",
            "Keep torso upright",
            "Low-back friendly"
        ],
        "Glute Kickback": [
            "Squeeze glutes at top of movement",
            "Don't arch lower back excessively",
            "Focus on hip extension, not lower back",
            "Excellent for glute isolation"
        ],
        "Standing Calf Raise": [
            "Full range of motion is crucial",
            "Pause at top and bottom",
            "Primary calf exercise for size",
            "Low-back friendly"
        ],
        "Seated Calf Raise": [
            "Emphasizes soleus muscle",
            "Use full range of motion",
            "Pause at top for better contraction",
            "Complements standing calf raises"
        ],
        
        // 🆕 MACHINE EXERCISES - ARMS
        "Biceps Curl (Machine)": [
            "Keep upper arms stationary on pad",
            "Don't let elbows lift off pad",
            "Excellent for biceps isolation",
            "Low-back friendly"
        ],
        "Preacher Curl (Machine)": [
            "Prevents cheating and momentum",
            "Full stretch at bottom is important",
            "Great for bicep peak development",
            "Low-back friendly arm exercise"
        ],
        "Triceps Pushdown": [
            "Keep elbows pinned to sides",
            "Don't lean forward excessively",
            "Squeeze triceps at bottom",
            "Classic triceps isolation exercise"
        ],
        "Overhead Triceps Extension": [
            "Targets long head of triceps",
            "Keep upper arms stationary",
            "Don't use excessive weight",
            "Stop if elbows feel uncomfortable"
        ],
        "Triceps Dip (Machine)": [
            "Assisted version builds strength for bodyweight dips",
            "Lean forward slightly for more chest activation",
            "Don't go too deep if shoulders hurt",
            "Compound triceps movement"
        ],
        
        // 🆕 MACHINE EXERCISES - CORE
        "Ab Crunch (Machine)": [
            "Excellent for adding resistance to crunches",
            "Don't pull with arms, crunch with abs",
            "Keep movement controlled, no jerking",
            "Low-back friendly when done properly"
        ],
        "Rotary Torso": [
            "Start with light weight to learn movement",
            "Keep hips stationary",
            "Targets obliques effectively",
            "Can help with rotational strength"
        ],
        "Back Extension": [
            "Strengthens lower back and glutes",
            "Don't hyperextend at top",
            "Good for back health when done correctly",
            "Start with bodyweight before adding load"
        ],
        "Captain's Chair Knee Raise": [
            "Don't swing or use momentum",
            "Focus on using abs, not just hip flexors",
            "Can progress to leg raises as you get stronger",
            "Excellent lower ab exercise"
        ],
    ]
}

// MARK: - Custom Exercise Support Extension

extension ExerciseDatabase {
    /// Get primary muscles for any exercise (built-in or custom)
    /// Pass in ModelContext to check custom exercises
    static func primaryMuscles(for exerciseName: String, context: ModelContext?) -> String? {
        // Check built-in database first
        if let builtIn = primaryMuscles(for: exerciseName) {
            return builtIn
        }
        
        // Check custom exercises if context provided
        guard let context = context else { return nil }
        return CustomExerciseManager.getPrimaryMuscles(for: exerciseName, context: context)
    }
    
    /// Get instructions for any exercise (built-in or custom)
    static func instructions(for exerciseName: String, context: ModelContext?) -> [String]? {
        // Check built-in database first
        if let builtIn = instructions(for: exerciseName) {
            return builtIn
        }
        
        // Check custom exercises if context provided
        guard let context = context else { return nil }
        return CustomExerciseManager.getInstructions(for: exerciseName, context: context)
    }
    
    /// Get form tips for any exercise (built-in or custom)
    static func formTips(for exerciseName: String, context: ModelContext?) -> [String]? {
        // Check built-in database first
        if let builtIn = formTips(for: exerciseName) {
            return builtIn
        }
        
        // Check custom exercises if context provided
        guard let context = context else { return nil }
        return CustomExerciseManager.getFormTips(for: exerciseName, context: context)
    }
}

