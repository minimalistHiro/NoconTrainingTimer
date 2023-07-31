//
//  SheetView.swift
//  NoconTrainingTimer
//
//  Created by 金子広樹 on 2023/07/24.
//

import SwiftUI

struct SheetView: View {
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Entity.title, ascending: true)])
    var data: FetchedResults<Entity>
    
    let setting = Setting()
    @Binding var isShowSheet: Bool
    @State private var isShowAlert: Bool = false            // アラート表示有無
    @State private var pickerNum: Double = 0                // ピッカー用変数
    
    // Model保存用パラメータ
    @State private var title: String = ""                   // タイトル
    @State private var ready: Int = 10                      // 準備時間
    @State private var workout: Int = 10                    // トレーニング時間
    @State private var interval: Int = 10                   // インターバル時間
    @State private var set: Int = 3                         // セット数
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("タイトル", text: $title)
                    .onChange(of: title) { value in
                        // 最大文字数に達したら、それ以上書き込めないようにする
                        if value.count > setting.maxTextCount {
                            title.removeLast(title.count - setting.maxTextCount)
                        }
                    }
                Picker("準備" ,selection: $ready) {
                    ForEach(0..<61) { num in
                        if (num % 5 == 0) && num > 0 {
                            Text("\(num)秒")
                        }
                    }
                }
                
                Picker("トレーニング", selection: $workout) {
                    ForEach(0..<61) { num in
                        if (num % 5 == 0) && num > 0 {
                            Text("\(num)秒")
                        }
                    }
                }
                
                Picker("休憩", selection: $interval) {
                    ForEach(0..<61) { num in
                        if (num % 5 == 0) && num > 0 {
                            Text("\(num)秒")
                        }
                    }
                }
                
                Picker("セット", selection: $set) {
                    ForEach(0..<31) { num in
                        if num > 0 {
                            Text("\(num)セット")
                        }
                    }
                }
            }
            .overlay {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            create()
                            isShowSheet = false
                        } label: {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .foregroundColor(setting.able)
                                .overlay {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20)
                                        .bold()
                                        .foregroundColor(setting.disable)
                                }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    /// Modelに新規データを保存する。
    /// - Parameters: なし
    /// - Returns: なし
    private func create() {
        let newEntity = Entity(context: viewContext)
        if title == "" {
            newEntity.title = "タイトル\(data.count + 1)"
        } else {
            newEntity.title = title
        }
        newEntity.ready = Int16(ready)
        newEntity.workout = Int16(workout)
        newEntity.interval = Int16(interval)
        newEntity.set = Int16(set)
        do {
            try viewContext.save()
        } catch {
            fatalError("セーブに失敗")
        }
    }
}

struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(isShowSheet: .constant(true))
    }
}
