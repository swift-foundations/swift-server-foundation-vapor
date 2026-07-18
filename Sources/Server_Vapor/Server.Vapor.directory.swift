public import Server
import class Vapor.Application

extension Server.Vapor {
    /// Returns the application's configured public directory.
    public static func directory(of application: Application) -> String {
        application.directory.publicDirectory
    }
}
