//
//  Setting.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/24.
//

import SwiftUI

final class Setting {
    // 各種設定
    let maxTextCount: Int = 20                              // 最大テキスト文字数
    let maxListCount: Int = 50                              // 最大リスト数
    
    // Viewのサイズ
    let buttonSize: CGFloat = 30                            // ボタンサイズ
    
    // 固定色
    let able: Color = Color("Able")                         // 文字・ボタン色
    let disable: Color = Color("Disable")                   // 背景色
    let highlight: Color = Color("Highlight")               // 強調色
    
    // サウンドファイル名
    let countSound: String = "CountSound"                   // カウント音
    let readyCountSound: String = "ReadyCountSound"         // スタート準備時カウント音
    let startCountSound: String = "StartCountSound"         // スタート時カウント音
    let workoutSound: String = "Workout"                    // トレーニング開始音
    let intervalSound: String = "Interval"                  // 休憩開始音
}
