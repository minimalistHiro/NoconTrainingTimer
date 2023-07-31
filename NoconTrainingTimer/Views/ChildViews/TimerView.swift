//
//  TimerView.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/24.
//

import SwiftUI

struct TimerView: View {
    let setting = Setting()
    @ObservedObject var timerRun = TimerRun.shared
    
    // バックグラウンド用トークン
    @State private var backgroundTaskId = UIBackgroundTaskIdentifier.init(rawValue: 0)
    
    // DB保存用セッテングパラメータ
    @Binding var settingTitle: String               // タイトル
    @Binding var settingReady: Double               // 準備時間
    @Binding var settingWorkout: Double             // トレーニング時間
    @Binding var settingInterval: Double            // インターバル時間
    @Binding var settingSet: Int                    // セット数
    
    // ボタンサイズ
    let roundedRectangleCornerSize: CGFloat = 30    // ボタンコーナーサイズ
    let smallButtonWidth: CGFloat = 150             // 小ボタンの横幅
    let largeButtonWidth: CGFloat = 300             // 大ボタンの横幅
    let buttonHeight: CGFloat = 60                  // ボタンの高さ
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Gauge(value: timerRun.elapsedTime, in: 0.9...paramaterCount()) {
                    // 空白
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .frame(width: 250, height: 250)
                .scaleEffect(5)
                .tint(paramaterColor())
                .overlay {
                    VStack {
                        Text(paramaterName())
                            .font(.system(size: 20))
                            .foregroundColor(paramaterColor())
                        Text("\(Int(timerRun.elapsedTime))")
                            .font(.system(size: 100))
                            .foregroundColor(paramaterColor())
                        // タイマーを真ん中にするために空白のテキストを設置。
                        Text("")
                    }
                }
                HStack {
                    Text("Set")
                        .font(.system(size: 30))
                        .padding(.trailing, 40)
                    Text("\(timerRun.setCount)").font(.system(size: 60))
                }
                
                switch timerRun.mode {
                case .start:
                    HStack {
                        Spacer()
                        Button {
                            timerRun.reset()
                            timerRun.mode = .zero
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            RoundedRectangle(cornerSize: CGSize(
                                width: roundedRectangleCornerSize,
                                height: roundedRectangleCornerSize))
                                .frame(width: smallButtonWidth, height: buttonHeight)
                                .foregroundColor(setting.able)
                                .overlay {
                                    Image(systemName: "stop.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: setting.buttonSize, height: setting.buttonSize)
                                        .foregroundColor(setting.disable)
                                }
                        }
                        Spacer()
                        Button {
                            timerRun.stopTime()
                            timerRun.mode = .stop
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            RoundedRectangle(cornerSize: CGSize(
                                width: roundedRectangleCornerSize,
                                height: roundedRectangleCornerSize))
                                .frame(width: smallButtonWidth, height: buttonHeight)
                                .foregroundColor(setting.able)
                                .overlay {
                                    Image(systemName: "pause.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: setting.buttonSize, height: setting.buttonSize)
                                        .foregroundColor(setting.disable)
                                }
                        }
                        Spacer()
                    }
                case .stop:
                    HStack {
                        Spacer()
                        Button {
                            timerRun.reset()
                            timerRun.mode = .zero
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            RoundedRectangle(cornerSize: CGSize(
                                width: roundedRectangleCornerSize,
                                height: roundedRectangleCornerSize))
                                .frame(width: smallButtonWidth, height: buttonHeight)
                                .foregroundColor(setting.able)
                                .overlay {
                                    Image(systemName: "stop.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: setting.buttonSize, height: setting.buttonSize)
                                        .foregroundColor(setting.disable)
                                }
                        }
                        Spacer()
                        Button {
                            timerRun.startTime()
                            timerRun.mode = .start
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            RoundedRectangle(cornerSize: CGSize(
                                width: roundedRectangleCornerSize,
                                height: roundedRectangleCornerSize))
                                .frame(width: smallButtonWidth, height: buttonHeight)
                                .foregroundColor(setting.able)
                                .overlay {
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: setting.buttonSize, height: setting.buttonSize)
                                        .foregroundColor(setting.disable)
                                }
                        }
                        Spacer()
                    }
                case .zero:
                    Button {
                        timerRun.startTime()
                        timerRun.mode = .start
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        RoundedRectangle(cornerSize: CGSize(
                            width: roundedRectangleCornerSize,
                            height: roundedRectangleCornerSize))
                            .frame(width: largeButtonWidth, height: buttonHeight)
                            .foregroundColor(setting.able)
                            .overlay {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: setting.buttonSize, height: setting.buttonSize)
                                    .foregroundColor(setting.disable)
                            }
                    }
                }
                Spacer()
            }
            .onAppear {
                if settingTitle == "" {
                    // 初期起動時のデフォルト設定
                    timerRun.settingParamater.settingTitle = "タイトル"
                    timerRun.settingParamater.settingReady = 10
                    timerRun.settingParamater.settingWorkout = 10
                    timerRun.settingParamater.settingInterval = 10
                    timerRun.settingParamater.settingSet = 3
                } else {
                    // DBから取得したパラメータをタイマー始動用構造体に格納。
                    timerRun.settingParamater.settingTitle = settingTitle
                    timerRun.settingParamater.settingReady = settingReady
                    timerRun.settingParamater.settingWorkout = settingWorkout
                    timerRun.settingParamater.settingInterval = settingInterval
                    timerRun.settingParamater.settingSet = settingSet
                }
            }
            .onChange(of: timerRun.settingParamater) { paramater in
                timerRun.elapsedTime = paramater.settingReady
                timerRun.setCount = paramater.settingSet
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(timerRun.settingParamater.settingTitle)
                        .bold()
                }
            }
        }
    }
    
    /// 実行中のタイマー名を返す。
    /// - Parameters: なし
    /// - Returns: パラメーターの名前
    private func paramaterName() -> String {
        switch timerRun.paramaterMode {
        case .none:
            return ""
        case .ready:
            return "準備"
        case .workout:
            return "トレーニング"
        case .interval:
            return "休憩"
        }
    }
    
    /// 実行中のタイマーカラーを返す。
    /// - Parameters: なし
    /// - Returns: パラメーターカラー
    private func paramaterColor() -> Color {
        switch timerRun.paramaterMode {
        case .none:
            return setting.able
        case .ready:
            return .red
        case .workout:
            return .blue
        case .interval:
            return .red
        }
    }
    
    /// 実行中のタイマー最大数を返す。
    /// - Parameters: なし
    /// - Returns: パラメーターカウント数
    private func paramaterCount() -> Double {
        switch timerRun.paramaterMode {
        case .none:
            return timerRun.settingParamater.settingReady
        case .ready:
            return timerRun.settingParamater.settingReady
        case .workout:
            return timerRun.settingParamater.settingWorkout + 1
        case .interval:
            return timerRun.settingParamater.settingInterval + 1
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(settingTitle: .constant(""),
                  settingReady: .constant(10),
                  settingWorkout: .constant(10),
                  settingInterval: .constant(10),
                  settingSet: .constant(3))
    }
}
