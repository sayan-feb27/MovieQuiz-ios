import Foundation


protocol StatisticsService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }

    func store(correct count: Int, total amount: Int)
}

private enum StatisticsKeys: String {
    case correct, total, bestGame, gamesCount
}


final class StatisticsServiceImplementation: StatisticsService {
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: StatisticsKeys.total.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: StatisticsKeys.total.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: StatisticsKeys.gamesCount.rawValue)
        }
        
        set {
            userDefaults.set(newValue, forKey: StatisticsKeys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: StatisticsKeys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: StatisticsKeys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let newGameRecord = GameRecord(correct: count, total: amount, date: Date())
        if newGameRecord.isBetterThan(bestGame) {
            bestGame = newGameRecord
        }
        
        var accuracy = Double(count) / Double(amount)
        if gamesCount > 0 {
            let totalQuestions = amount * gamesCount
            let totalCorrectAnswers = Int(totalAccuracy * Double(totalQuestions))
            
            accuracy = Double(totalCorrectAnswers + count) / Double(amount + totalQuestions)
        }
        gamesCount += 1
        totalAccuracy = accuracy
    }
    
}
