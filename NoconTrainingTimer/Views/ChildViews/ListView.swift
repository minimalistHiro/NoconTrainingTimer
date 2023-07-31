//
//  ListView.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/24.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity.title, ascending: true)])
    var data: FetchedResults<Entity>
    
    let setting = Setting()
    @ObservedObject var timerRun = TimerRun.shared
    
    // DB保存用セッテングパラメータ
    @Binding var settingTitle: String               // タイトル
    @Binding var settingReady: Double               // 準備時間
    @Binding var settingWorkout: Double             // トレーニング時間
    @Binding var settingInterval: Double            // インターバル時間
    @Binding var settingSet: Int                    // セット数
    
    // 仮セッテング用パラメータ
    @State private var tentativeSettingTitle: String = ""       // タイトル
    @State private var tentativeSettingReady: Double = 10       // 準備時間
    @State private var tentativeSettingWorkout: Double = 10     // トレーニング時間
    @State private var tentativeSettingInterval: Double = 10    // インターバル時間
    @State private var tentativeSettingSet: Int = 3             // セット数
    
    @State private var isShowSheet: Bool = false        // シートの表示有無
    @State private var isShowAlert: Bool = false        // アラートの表示有
    
    var body: some View {
        List {
            ForEach(data) { data in
                if let title = data.title {
                    Button {
                        // 各データを一度、仮セッテイング用パラメータに保存する。
                        tentativeSettingTitle = data.title ?? "タイトル"
                        tentativeSettingReady = Double(data.ready)
                        tentativeSettingWorkout = Double(data.workout)
                        tentativeSettingInterval = Double(data.interval)
                        tentativeSettingSet = Int(data.set)
                        isShowAlert = true
                    } label: {
                        Text(title)
                            .listRowSeparator(.hidden)
                            .font(.system(size: 25))
                    }
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            rowRemove(data: data)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
                    }
                }
            }
            
            // 最大リスト数を超えたら、プラスボタンを非表示にする。
            if data.count <= setting.maxListCount {
                // プラスボタン
                Button {
                    isShowSheet = true
                } label: {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundColor(setting.able)
                        .overlay {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .bold()
                                .foregroundColor(setting.disable)
                        }
                }
                .listRowSeparator(.hidden)
            }
        }
        .sheet(isPresented: $isShowSheet) {
            SheetView(isShowSheet: $isShowSheet)
        }
        .listStyle(.inset)
        .environment(\.defaultMinListRowHeight, 70)
        .padding()
        .alert("", isPresented: $isShowAlert) {
            Button("セット") {
                setParameter()
                timerRun.reset()
                timerRun.mode = .zero
            }
            Button("キャンセル", role: .cancel) {
                isShowAlert = false
            }
        } message: {
            Text("セットしますか？")
        }

    }
    
    /// タイマーに指定したデータをセットする。
    /// - Parameters: なし
    /// - Returns: なし
    private func setParameter() {
        // DB保存用セッテングパラメータに保存
        settingTitle = tentativeSettingTitle
        settingReady = tentativeSettingReady
        settingWorkout = tentativeSettingWorkout
        settingInterval = tentativeSettingInterval
        settingSet = tentativeSettingSet
        // 構造体に保存
        timerRun.settingParamater.settingTitle = tentativeSettingTitle
        timerRun.settingParamater.settingReady = tentativeSettingReady
        timerRun.settingParamater.settingWorkout = tentativeSettingWorkout
        timerRun.settingParamater.settingInterval = tentativeSettingInterval
        timerRun.settingParamater.settingSet = tentativeSettingSet
    }
    
    /// 行を削除する。
    /// - Parameters:
    ///   - data: 削除するデータ
    /// - Returns: なし
    func rowRemove(data: FetchedResults<Entity>.Element) {
        viewContext.delete(data)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(settingTitle: .constant(""),
                 settingReady: .constant(10),
                 settingWorkout: .constant(10),
                 settingInterval: .constant(10),
                 settingSet: .constant(3))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
