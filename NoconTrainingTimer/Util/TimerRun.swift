//
//  TimerRun.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/29.
//

import SwiftUI

final class TimerRun: ObservableObject {
    static var shared: TimerRun = TimerRun()
    
    let setting = Setting()
    var timer = Timer()
    @Published var paramaterMode: ParamaterMode = .none
    @Published var settingParamater = SettingParamater()
    @Published var mode: TimerMode = .zero                  // タイマーモード
    @Published var elapsedTime: Double = 1                  // 時間計測用変数
    @Published var setCount: Int = 0                        // セット数カウント用変数
    // バックグラウンド用トークン
    @Published var backgroundTaskId = UIBackgroundTaskIdentifier.init(rawValue: 0)
    @Published var isTimerCountZero: Bool = false           // タイマーのカウントが0になったか否か
    var stoppedTime: Double = 0                             // ストップ時の一時保存タイム
    
    ///　タイマーをリセット
    /// - Parameters: なし
    /// - Returns: なし
    func reset() {
        timer.invalidate()
        // バックグラウンド処理終了
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
        elapsedTime = settingParamater.settingReady
        paramaterMode = .none
    }
    
    ///　タイマーを開始
    /// - Parameters: なし
    /// - Returns: なし
    func startTime() {
        // 最初からスタート時のみ、パラメータを"準備"に設定し、準備時間をセットする。そうでない場合、一時保存したタイムをセットする。
        if mode == .zero {
            paramaterMode = .ready
        } else {
            elapsedTime = stoppedTime
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {
            [self] _ in
            // タイマーをメインスレッドと別スレッドで実行。
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
            // バックグラウンド処理開始
            backgroundTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            
            // タイマーが0になったら、次のタイマーを始動する、若しくは終了する。
            if (elapsedTime - 1) < 0 {
                // パラメータによって、次にセットするタイマーを分ける。
                switch paramaterMode {
                case .none:
                    break
                case .ready:
                    elapsedTime = settingParamater.settingWorkout + 1
                    paramaterMode = .workout
                case .workout:
                    elapsedTime = settingParamater.settingInterval + 1
                    paramaterMode = .interval
                    // 全筋トレが終了したら、タイマーをリセットする。
                    if (setCount - 1) <= 0 {
                        elapsedTime = settingParamater.settingReady
                        reset()
                        setCount = settingParamater.settingSet
                        mode = .zero
                        paramaterMode = .none
                        return
                    }
                case .interval:
                    elapsedTime = settingParamater.settingWorkout + 1
                    paramaterMode = .workout
                    setCount -= 1
                }
            }
// MARK: - テスト用
//            elapsedTime -= 1.0
            elapsedTime -= 0.01
        }
    }
    
    ///　タイマーを停止
    /// - Parameters: なし
    /// - Returns: なし
    func stopTime() {
        stoppedTime = elapsedTime
        timer.invalidate()
        // バックグラウンド処理終了
        UIApplication.shared.endBackgroundTask(backgroundTaskId)
    }
}
