import Foundation

class CalorieData: ObservableObject {
    // Singleton instance for easy access
    static let shared = CalorieData()
    
    // Keys for UserDefaults
    private let targetKey = "dailyCaloriesTarget"
    private let todayKey = "todayCalories"
    private let dateKey = "lastCaloriesDate"
    
    // Published properties that trigger updates
    @Published var dailyTarget: Double {
        didSet { save() }
    }
    
    @Published var todayCalories: Double {
        didSet { save() }
    }
    
    @Published var lastUpdated: Date {
        didSet { save() }
    }
    
    private init() {
        // Load values from UserDefaults
        let defaults = UserDefaults.standard
        self.dailyTarget = defaults.double(forKey: targetKey)
        self.todayCalories = defaults.double(forKey: todayKey)
        self.lastUpdated = defaults.object(forKey: dateKey) as? Date ?? Date()
        checkDateReset()
    }
    
    // Save data to UserDefaults
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(dailyTarget, forKey: targetKey)
        defaults.set(todayCalories, forKey: todayKey)
        defaults.set(lastUpdated, forKey: dateKey)
    }
    
    // Reset today's calories if it's a new day
    func checkDateReset() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastUpdated) {
            todayCalories = 0
            lastUpdated = Date()
        }
    }
    
    // Add calories (e.g., after completing a game)
    func addCalories(_ amount: Double) {
        checkDateReset()
        todayCalories += amount
    }
    
    // Return todays' target
    func getTodayCalories() -> Double {
        return todayCalories
    }
    
    // Set the daily target
    func setTarget(_ target: Double) {
        dailyTarget = target
    }
    
    // Check if the target has been set
    var isTargetSet: Bool {
        return dailyTarget > 0
    }
    
    // Reset all user preferences
    func resetAllData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: targetKey)
        defaults.removeObject(forKey: todayKey)
        defaults.removeObject(forKey: dateKey)
        
        // Reset the local properties
        dailyTarget = 0
        todayCalories = 0
        lastUpdated = Date()
    }
} 
