import NIO
import NIOSSH

final class UserAuthDelegate: NIOSSHServerUserAuthenticationDelegate, Sendable {
  var supportedAuthenticationMethods: NIOSSH.NIOSSHAvailableUserAuthenticationMethods { .all }

  func requestReceived(
    request: NIOSSH.NIOSSHUserAuthenticationRequest,
    responsePromise: NIOCore.EventLoopPromise<NIOSSH.NIOSSHUserAuthenticationOutcome>
  ) {
    responsePromise.succeed(.success)
  }
}
