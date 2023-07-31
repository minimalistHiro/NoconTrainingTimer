//
//  Data.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/24.
//

import SwiftUI
import CoreData

//final class SettingParamater: ObservableObject, Equatable {
//    static var shared: SettingParamater = SettingParamater()
//    @Published var settingTitle: String = ""            // タイトル
//    @Published var settingReady: Double = 10            // 準備時間
//    @Published var settingWorkout: Double = 10          // トレーニング時間
//    @Published var settingInterval: Double = 10         // インターバル時間
//    @Published var settingSet: Int = 3                  // セット数
//}

struct SettingParamater: Equatable {
    var settingTitle: String = ""            // タイトル
    var settingReady: Double = 10            // 準備時間
    var settingWorkout: Double = 10          // トレーニング時間
    var settingInterval: Double = 10         // インターバル時間
    var settingSet: Int = 3                  // セット数
}

// タイマーモード
enum TimerMode {
    case zero
    case start
    case stop
}

// パラメーターモード
enum ParamaterMode {
    case none
    case ready
    case workout
    case interval
}

// アラートエンティティ
struct AlertEntity {
    // アラートボタンの個数
    enum AlertButton {
        case single
        case double
    }
    let title: String
    let message: String
    let actionText: String
    let cancelText: String
    let button: AlertButton
    let isTimer: Bool           // 準備、トレーニング、休憩などのタイマー：true、セット数：false。
}

struct PersistenceController {
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for num in 0..<5 {
            let newItem = Entity(context: viewContext)
            newItem.title = "Title\(num)"
            newItem.ready = Int16(num * 10)
            newItem.workout = Int16(num * 10)
            newItem.interval = Int16(num * 10)
            newItem.set = Int16(num)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
