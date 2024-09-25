import Foundation

@discardableResult func runSubProcess(
    _ executable: String,
    _ args: [String],
    ignoreStdErr: Bool = false
) throws -> Int32 {
    let task = Process()
    var exitStatus: Int32 = 0
    var runError: Error?

    task.launchPath = executable
    task.arguments = args

    if ignoreStdErr {
        task.standardError = Pipe()
    }

    // https://github.com/swiftlang/swift-corelibs-foundation/blob/c5421808a0f907169e605674b4672b9e98390d65/Sources/Foundation/Operation.swift#L45-L51
    let backgroundQueue = DispatchQueue.global(qos: .background)

    backgroundQueue.sync {
        do {
            try task.run()
            task.waitUntilExit()
            exitStatus = task.terminationStatus
        } catch {
            runError = error
        }
    }

    if let error = runError {
        throw error
    }

    return exitStatus
}
