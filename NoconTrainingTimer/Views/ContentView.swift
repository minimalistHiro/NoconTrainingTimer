//
//  ContentView.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    let setting = Setting()
    let countSounds = Sounds()              // カウント音用インスタンス
    let readyCountSounds = Sounds()         // スタート準備時カウント音用インスタンス
    let startCountSounds = Sounds()         // スタート時カウント音用インスタンス
    @ObservedObject var timerRun = TimerRun.shared
    
    // DB保存用セッテングパラメータ
    @AppStorage("settingTitle") private var settingTitle: String = ""           // タイトル
    @AppStorage("settingReady") private var settingReady: Double = 10           // 準備時間
    @AppStorage("settingWorkout") private var settingWorkout: Double = 10       // トレーニング時間
    @AppStorage("settingInterval") private var settingInterval: Double = 10     // インターバル時間
    @AppStorage("settingSet") private var settingSet: Int = 3                   // セット数
    
    var body: some View {
        TabView {
            TimerView(settingTitle: $settingTitle,
                      settingReady: $settingReady,
                      settingWorkout: $settingWorkout,
                      settingInterval: $settingInterval,
                      settingSet: $settingSet)
                .tabItem {
                    Image(systemName: "timer")
                }
                .tag(1)
            ListView(settingTitle: $settingTitle,
                     settingReady: $settingReady,
                     settingWorkout: $settingWorkout,
                     settingInterval: $settingInterval,
                     settingSet: $settingSet)
                .tabItem {
                    Image(systemName: "list.bullet")
                }
                .tag(2)
        }
        .onChange(of: timerRun.mode) { mode in
            // 画面の自動ロックの有無を状態によって振り分ける。
            switch mode {
            case .zero:
                UIApplication.shared.isIdleTimerDisabled = false
            case .start:
                UIApplication.shared.isIdleTimerDisabled = true
            case .stop:
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
        .onChange(of: Int(timerRun.elapsedTime)) { time in
            // カウント音を鳴らす
            if time == 2 || time == 1 {
                // スタート準備時カウント音
                readyCountSounds.fileName = setting.readyCountSound
                readyCountSounds.playSound()
            }
            // カウント音
            countSounds.fileName = setting.countSound
            countSounds.playSound()
        }
        .onChange(of: timerRun.paramaterMode) { newValue in
            // リセット時、またはパラメーターモードが"準備"以外、パラメータモードが変わった時に実行。
            if !(timerRun.mode == .zero || timerRun.paramaterMode == .ready) {
                // スタート時カウント音
                startCountSounds.fileName = setting.startCountSound
                startCountSounds.playSound()
            }
        }
        .tint(setting.able)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
