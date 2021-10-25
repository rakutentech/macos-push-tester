import Foundation

enum ShellRunnerError: Error {
    case taskInitError(Error)
    case commandError(String)
    case unknown
}

enum ShellRunner {

    static func run(command: String) -> Result<String, ShellRunnerError> {
        let task = Process()
        let errorPipe = Pipe()
        let outputPipe = Pipe()

        task.standardError = errorPipe
        task.standardOutput = outputPipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        do {
            try task.run()
        }
        catch {
            return .failure(.taskInitError(error))
        }

        task.waitUntilExit()

        if task.terminationStatus != 0 {
            let error = errorPipe.fileHandleForReading.readDataToEndOfFile()
            guard let resultString = String(data: error, encoding: .utf8) else {
                return .failure(.unknown)
            }
            return .failure(.commandError(resultString))
        } else {
            let output = outputPipe.fileHandleForReading.readDataToEndOfFile()
            guard let resultString = String(data: output, encoding: .utf8) else {
                return .failure(.unknown)
            }
            return .success(resultString)
        }
    }
}

