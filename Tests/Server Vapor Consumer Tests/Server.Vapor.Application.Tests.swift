private import Logging
private import enum Server.Server
private import Server_Vapor
import Testing

extension Server.Vapor.Application {
    fileprivate func configure(logger: Logger) {
        _ = Server.Vapor.directory(of: self)
        Server.Vapor.body(max: "1mb", on: self)
        logger.info("Configured")
    }
}

@Test
func `application membrane supports consumer configuration surface`() {
    let configure: (Server.Vapor.Application, Logger) -> Void = { application, logger in
        application.configure(logger: logger)
    }

    _ = configure
}
