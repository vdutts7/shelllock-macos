import Foundation
import LocalAuthentication

/// shelllock - Touch ID gated shell command executor for macOS
/// Author: vdutts7 (https://vd7.io)
/// Source: https://github.com/vdutts7/shelllock-macos
/// License: MIT

let VERSION = "1.0.0"
let AUTHOR = "vdutts7"
let HOMEPAGE = "https://vd7.io"
let REPO = "https://github.com/vdutts7/shelllock-macos"

struct ShellLock {
    
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        
        guard !args.isEmpty else {
            printUsage()
            exit(1)
        }
        
        // Handle flags
        if args[0] == "--help" || args[0] == "-h" {
            printUsage()
            exit(0)
        }
        
        if args[0] == "--version" || args[0] == "-v" {
            print("shelllock \(VERSION)")
            print("Author: \(AUTHOR) (\(HOMEPAGE))")
            print("Source: \(REPO)")
            exit(0)
        }
        
        var reason = "authenticate to run command"
        var command: [String]
        
        // Parse: shelllock "reason" command... OR shelllock command...
        if args[0] == "-m" || args[0] == "--message" {
            guard args.count >= 3 else {
                fputs("Error: -m requires a message and command\n", stderr)
                exit(1)
            }
            reason = args[1]
            command = Array(args.dropFirst(2))
        } else if args[0] == "-c" {
            // Inline command mode: shelllock -c "echo hello && echo world"
            guard args.count >= 2 else {
                fputs("Error: -c requires a command string\n", stderr)
                exit(1)
            }
            reason = "authenticate to run command"
            command = ["-c", args[1]]
        } else {
            command = args
        }
        
        // Authenticate then execute
        authenticate(reason: reason) { success in
            if success {
                executeCommand(command)
            } else {
                fputs("❌ Authentication failed\n", stderr)
                exit(1)
            }
        }
        
        RunLoop.main.run()
    }
    
    static func authenticate(reason: String, completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Check biometric availability
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                fputs("Biometric auth not available: \(error.localizedDescription)\n", stderr)
            }
            
            // Fallback to password
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                evaluatePolicy(context: context, policy: .deviceOwnerAuthentication, reason: reason, completion: completion)
            } else {
                fputs("No authentication method available\n", stderr)
                completion(false)
            }
            return
        }
        
        evaluatePolicy(context: context, policy: .deviceOwnerAuthenticationWithBiometrics, reason: reason, completion: completion)
    }
    
    static func evaluatePolicy(context: LAContext, policy: LAPolicy, reason: String, completion: @escaping (Bool) -> Void) {
        context.evaluatePolicy(policy, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true)
                } else {
                    if let error = error as? LAError {
                        switch error.code {
                        case .userCancel:
                            fputs("Cancelled by user\n", stderr)
                        case .biometryLockout:
                            fputs("Biometry locked out - too many attempts\n", stderr)
                        default:
                            fputs("Auth error: \(error.localizedDescription)\n", stderr)
                        }
                    }
                    completion(false)
                }
            }
        }
    }
    
    static func executeCommand(_ args: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        
        if args.first == "-c" {
            // Inline command mode
            process.arguments = args
        } else {
            // Script/command mode
            process.arguments = ["-c", args.joined(separator: " ")]
        }
        
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError
        process.standardInput = FileHandle.standardInput
        
        do {
            try process.run()
            process.waitUntilExit()
            exit(process.terminationStatus)
        } catch {
            fputs("Failed to execute: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
    
    static func printUsage() {
        let usage = """
        shelllock - Touch ID gated shell command executor for macOS
        
        Author: \(AUTHOR) (\(HOMEPAGE))
        Source: \(REPO)
        
        USAGE:
            shelllock <command> [args...]
            shelllock -m "message" <command> [args...]
            shelllock -c "inline command string"
        
        OPTIONS:
            -m, --message   Custom Touch ID prompt message
            -c              Execute inline command string
            -h, --help      Show this help
            -v, --version   Show version
        
        EXAMPLES:
            shelllock ./deploy.sh
            shelllock -m "Deploy to production?" ./deploy.sh
            shelllock -c "npm run build && npm test"
            shelllock make install
        
        USE CASE:
            Protect sensitive scripts from accidental execution by AI agents.
            AI cannot physically touch your fingerprint sensor.
        
        EXIT CODES:
            0   Success - command executed
            1   Failure - auth failed or error
            *   Command's exit code passed through
        """
        print(usage)
    }
}

ShellLock.main()
