import NIOSSH
import ArgumentParser

@main
struct Terminal: AsyncParsableCommand {
  func run() async throws {
    print("Hello, world")
  }
}