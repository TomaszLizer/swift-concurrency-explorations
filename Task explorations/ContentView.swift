//
//  ContentView.swift
//  Task explorations xcode16.2
//
//  Created by Tomasz Lizer on 13/06/2025.
//

import SwiftUI

enum TaskType: String, CaseIterable {
    case `default`
    case mainActor = "Main Actor"
    case detached
}

enum CallContext: String, CaseIterable {
    case mainActor = "Main Actor"
    case nonIsolated = "Non isolated"
}

enum CallType: String, CaseIterable {
    case sync
    case async
}

struct ContextPicker<T: Hashable & RawRepresentable & CaseIterable>: View
where T.RawValue == String, T.AllCases: RandomAccessCollection {
    @Binding var selection: T
    
    var body: some View {
        Picker("", selection: $selection) {
            ForEach(T.allCases, id: \.self) { context in
                Text(context.rawValue.capitalized).tag(context)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct ContentView: View {
    @State private var taskTestNonIsolated = TaskTest()
    @State private var taskTestMainActor = TaskTestMainActor()
    
    @State var callerTask: TaskType = .mainActor
    
    @State var calleeContext: CallContext = .mainActor
    @State var calleeType: CallType = .sync
    @State var calleeTask: TaskType = .mainActor
    
    var text: String {
        let calledThread: String?
        switch calleeContext {
        case .mainActor:
            calledThread = taskTestMainActor.calledThread?.description
        case .nonIsolated:
            calledThread = taskTestNonIsolated.calledThread?.description
        }
        return calledThread ?? "Tap run to check thread"
    }
    var funcText: String {
        let calledThread: String?
        switch calleeContext {
        case .mainActor:
            calledThread = taskTestMainActor.calledFuncThread?.description
        case .nonIsolated:
            calledThread = taskTestNonIsolated.calledFuncThread?.description
        }
        return calledThread ?? "Tap run to check thread"
    }
    
    var body: some View {
        VStack {
            Section("Caller Context") {
                ContextPicker(selection: $callerTask)
            }
            Section("Callee Context") {
                ContextPicker(selection: $calleeContext)
                ContextPicker(selection: $calleeType)
                ContextPicker(selection: $calleeTask)
            }
            
            Button("Run task") {
                checkTaskThread(callerTask: callerTask)
            }
            .buttonStyle(.borderedProminent)
            
            Text(funcText)
                .padding()
            Text(text)
                .padding()
            
            Spacer()
        }
        .onChange(of: callerTask, cleanCalledThread)
        .onChange(of: calleeContext, cleanCalledThread)
        .onChange(of: calleeTask, cleanCalledThread)
        .onChange(of: calleeType, cleanCalledThread)
        .padding()
    }
    
    func cleanCalledThread() {
        taskTestMainActor.calledThread = nil
        taskTestNonIsolated.calledThread = nil
        taskTestMainActor.calledFuncThread = nil
        taskTestNonIsolated.calledFuncThread = nil
    }
    
    nonisolated func checkTaskThread(callerTask: TaskType) {
        switch callerTask {
        case .default:
            Task {
                switch await (calleeContext, calleeType, calleeTask) {
                case (.mainActor, .sync, .default):
                    await taskTestMainActor.runTask()
                case (.mainActor, .sync, .mainActor):
                    await taskTestMainActor.runTaskMainActor()
                case (.mainActor, .sync, .detached):
                    await taskTestMainActor.runTaskDetached()
                case (.mainActor, .async, .default):
                    await taskTestMainActor.runTaskAsync()
                case (.mainActor, .async, .mainActor):
                    await taskTestMainActor.runTaskMainActorAsync()
                case (.mainActor, .async, .detached):
                    await taskTestMainActor.runTaskDetachedAsync()
                case (.nonIsolated, .sync, .default):
                    await taskTestNonIsolated.runTask()
                case (.nonIsolated, .sync, .mainActor):
                    await taskTestNonIsolated.runTaskMainActor()
                case (.nonIsolated, .sync, .detached):
                    await taskTestNonIsolated.runTaskDetached()
                case (.nonIsolated, .async, .default):
                    await taskTestNonIsolated.runTaskAsync()
                case (.nonIsolated, .async, .mainActor):
                    await taskTestNonIsolated.runTaskMainActorAsync()
                case (.nonIsolated, .async, .detached):
                    await taskTestNonIsolated.runTaskDetachedAsync()
                }
            }
        case .mainActor:
            Task { @MainActor in
                switch (calleeContext, calleeType, calleeTask) {
                case (.mainActor, .sync, .default):
                    taskTestMainActor.runTask()
                case (.mainActor, .sync, .mainActor):
                    taskTestMainActor.runTaskMainActor()
                case (.mainActor, .sync, .detached):
                    taskTestMainActor.runTaskDetached()
                case (.mainActor, .async, .default):
                    await taskTestMainActor.runTaskAsync()
                case (.mainActor, .async, .mainActor):
                    await taskTestMainActor.runTaskMainActorAsync()
                case (.mainActor, .async, .detached):
                    await taskTestMainActor.runTaskDetachedAsync()
                case (.nonIsolated, .sync, .default):
                    taskTestNonIsolated.runTask()
                case (.nonIsolated, .sync, .mainActor):
                    taskTestNonIsolated.runTaskMainActor()
                case (.nonIsolated, .sync, .detached):
                    taskTestNonIsolated.runTaskDetached()
                case (.nonIsolated, .async, .default):
                    await taskTestNonIsolated.runTaskAsync()
                case (.nonIsolated, .async, .mainActor):
                    await taskTestNonIsolated.runTaskMainActorAsync()
                case (.nonIsolated, .async, .detached):
                    await taskTestNonIsolated.runTaskDetachedAsync()
                }
            }
        case .detached:
            Task.detached {
                switch await (calleeContext, calleeType, calleeTask) {
                case (.mainActor, .sync, .default):
                    await taskTestMainActor.runTask()
                case (.mainActor, .sync, .mainActor):
                    await taskTestMainActor.runTaskMainActor()
                case (.mainActor, .sync, .detached):
                    await taskTestMainActor.runTaskDetached()
                case (.mainActor, .async, .default):
                    await taskTestMainActor.runTaskAsync()
                case (.mainActor, .async, .mainActor):
                    await taskTestMainActor.runTaskMainActorAsync()
                case (.mainActor, .async, .detached):
                    await taskTestMainActor.runTaskDetachedAsync()
                case (.nonIsolated, .sync, .default):
                    await taskTestNonIsolated.runTask()
                case (.nonIsolated, .sync, .mainActor):
                    await taskTestNonIsolated.runTaskMainActor()
                case (.nonIsolated, .sync, .detached):
                    await taskTestNonIsolated.runTaskDetached()
                case (.nonIsolated, .async, .default):
                    await taskTestNonIsolated.runTaskAsync()
                case (.nonIsolated, .async, .mainActor):
                    await taskTestNonIsolated.runTaskMainActorAsync()
                case (.nonIsolated, .async, .detached):
                    await taskTestNonIsolated.runTaskDetachedAsync()
                }
            }
        }
    }
}

@Observable
final class TaskTest: Sendable {
    @MainActor
    var calledThread: ThreadType?
    @MainActor
    var calledFuncThread: ThreadType?
    
    @MainActor
    init() {}
    
    // MARK: - sync
    
    nonisolated func runTask() {
        let funcThread = checkThread()
        Task {
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }
    }
    
    nonisolated func runTaskMainActor() {
        let funcThread = checkThread()
        Task { @MainActor in
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }
    }
    
    nonisolated func runTaskDetached() {
        let funcThread = checkThread()
        Task.detached {
            let threadDesc = checkThread()
            await MainActor.run {
                self.calledThread = threadDesc
                self.calledFuncThread = funcThread
            }
        }
    }
    
    // MARK: - async
    
    nonisolated func runTaskAsync() async {
        let funcThread = checkThread()
        await Task {
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }.value
    }
    
    nonisolated func runTaskMainActorAsync() async {
        let funcThread = checkThread()
        await Task { @MainActor in
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }.value
    }
    
    nonisolated func runTaskDetachedAsync() async {
        let funcThread = checkThread()
        await Task.detached {
            let threadDesc = checkThread()
            await MainActor.run {
                self.calledThread = threadDesc
                self.calledFuncThread = funcThread
            }
        }.value
    }
}

@Observable
@MainActor
final class TaskTestMainActor {
    @MainActor
    var calledThread: ThreadType?
    @MainActor
    var calledFuncThread: ThreadType?
    
    // MARK: - sync
    
    func runTask() {
        let funcThread = checkThread()
        Task {
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }
    }
    
    func runTaskMainActor() {
        let funcThread = checkThread()
        Task { @MainActor in
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }
    }
    
    func runTaskDetached() {
        let funcThread = checkThread()
        Task.detached {
            let threadDesc = checkThread()
            await MainActor.run {
                self.calledThread = threadDesc
                self.calledFuncThread = funcThread
            }
        }
    }
    
    // MARK: - async
    
    func runTaskAsync() async {
        let funcThread = checkThread()
        await Task {
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }.value
    }
    
    func runTaskMainActorAsync() async {
        let funcThread = checkThread()
        await Task { @MainActor in
            let threadDesc = checkThread()
            await MainActor.run {
                calledThread = threadDesc
                calledFuncThread = funcThread
            }
        }.value
    }
    
    func runTaskDetachedAsync() async {
        let funcThread = checkThread()
        await Task.detached {
            let threadDesc = checkThread()
            await MainActor.run {
                self.calledThread = threadDesc
                self.calledFuncThread = funcThread
            }
        }.value
    }
}

enum ThreadType: Sendable {
    case main
    case background(String)
    
    var description: String {
        switch self {
        case .main:
            return "Main Thread"
        case .background(let thread):
            return "Background Thread: \(thread)"
        }
    }
}
nonisolated func checkThread() -> ThreadType {
    if Thread.isMainThread {
        print("Running on the main thread")
        return .main
    }   else {
        let currentThread = Thread.current
        print("Running on a background thread: \(currentThread)")
        return .background(currentThread.description)
    }
}

#Preview {
    ContentView()
}
