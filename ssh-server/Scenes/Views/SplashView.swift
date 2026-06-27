import Foundation
import SwiftTUI

// splash: 80 particles drift scattered → converge to form
// the "C" arc → glow → explode outward. Total duration: 5 s.
struct SplashView: View {
  let onFinish: () -> Void

  @Environment(\.terminalSize) private var terminalSize

  var body: some View {
    TimelineView(.animation) { context in
      Text(renderFrame(t: context.instant.offset.totalSeconds, W: terminalSize.width, H: terminalSize.height))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .task {
      try? await Task.sleep(nanoseconds: 5_000_000_000)
      onFinish()
    }
  }

  // ── Particle count & C geometry ───────────────────────────────
  // The C is a 270° arc (45° → 315°) leaving a gap at 0° (right side).
  private static let N        = 80
  private static let arcStart = Double.pi / 4.0         // 45°
  private static let arcSpan  = 3.0 * Double.pi / 2.0   // 270°

  // ── Phase timeline (seconds) ───────────────────────────────────────────
  // 0.0 – 0.8  : scatter  — particles drift at random positions
  // 0.8 – 3.5  : converge — particles fly to their C-arc targets
  // 3.5 – 4.5  : hold     — C glows at full brightness, slow creep
  // 4.5 – 5.0  : disperse — particles explode radially outward

  private func renderFrame(t: Double, W: Int, H: Int) -> String {
    guard W > 0, H > 0 else { return "" }

    let cx    = Double(W) / 2.0
    let cy    = Double(H) / 2.0
    // Coin radius: fit the tighter axis, correcting for 2:1 char aspect ratio
    let coinR = min(cx / 2.2, cy * 0.82)

    var zbuf  = [Int](repeating: -1, count: W * H)
    var cells = [Character](repeating: " ", count: W * H)

    // Luminance table: index 0 (dim) → 4 (bright)
    let lumin: [Character] = Array(".,:*@")
    let lumMax = lumin.count - 1

    func blit(_ col: Int, _ row: Int, _ lum: Int) {
      guard lum >= 0, col >= 0, col < W, row >= 0, row < H else { return }
      let idx = col + row * W
      guard lum > zbuf[idx] else { return }
      zbuf[idx] = lum
      cells[idx] = lumin[min(lumMax, lum)]
    }

    let N = Self.N

    for i in 0..<N {
      let fi = Double(i)

      // ── Scatter position (deterministic per particle) ──────────────────
      let scatterAngle  = rng(i, 0) * 2.0 * .pi
      let scatterRadius = 0.25 + rng(i, 1) * 0.70
      let sx = cos(scatterAngle) * scatterRadius * cx * 0.90
      let sy = sin(scatterAngle) * scatterRadius * cy * 0.85

      // Drift velocity (used in scatter + as converge start offset)
      let driftDir   = rng(i, 2) * 2.0 * .pi
      let driftSpeed = 0.10 + rng(i, 3) * 0.20

      // ── Target on C arc ───────────────────────────────────────────────
      let tA = Self.arcStart + fi / Double(N) * Self.arcSpan
      let tx =  cos(tA) * coinR
      let ty = -sin(tA) * coinR   // screen y is flipped

      let wx, wy: Double
      let lum: Int

      switch t {
      case ..<0.8:
        // Drift slowly at scatter position
        wx = sx + cos(driftDir) * driftSpeed * t
        wy = sy + sin(driftDir) * driftSpeed * t
        lum = 0

      case 0.8..<3.5:
        // Smooth convergence via smoothstep
        let s = smoothstep((t - 0.8) / 2.7)
        // Interpolate from where the particle was at t=0.8
        let ox = sx + cos(driftDir) * driftSpeed * 0.8
        let oy = sy + sin(driftDir) * driftSpeed * 0.8
        wx = lerp(ox, tx, s)
        wy = lerp(oy, ty, s)
        lum = Int(s * 3.0)   // ramps 0 → 3 as particle arrives

      case 3.5..<4.5:
        // Hold: slow orbital creep + subtle radial pulse
        let dt    = t - 3.5
        let ha    = tA + dt * 0.25
        let pulse = 1.0 + 0.05 * sin(dt * 7.0 + fi * 0.25)
        wx =  cos(ha) * coinR * pulse
        wy = -sin(ha) * coinR * pulse
        lum = lumMax   // full brightness

      default:
        // Disperse: accelerate radially outward
        let s  = smoothstep((t - 4.5) / 0.5)
        wx = lerp(tx, tx + cos(tA) * cx * 1.5, s)
        wy = lerp(ty, ty - sin(tA) * cy * 1.5, s)
        lum = max(0, 3 - Int(s * 5.0))
      }

      // Map world → screen col/row (x doubled for 2:1 terminal aspect ratio)
      let col = Int((cx + wx * 2.0).rounded())
      let row = Int((cy + wy).rounded())

      blit(col, row, lum)

      // Cross glow during converge + hold: adds a soft halo around each particle
      if t >= 0.8, t < 4.5, lum >= 2 {
        let g = lum - 2
        blit(col - 1, row,     g)
        blit(col + 1, row,     g)
        blit(col,     row - 1, g)
        blit(col,     row + 1, g)
      }
    }

    var out = ""
    out.reserveCapacity((W + 1) * H)
    for row in 0..<H {
      for col in 0..<W { out.append(cells[col + row * W]) }
      if row < H - 1 { out.append("\n") }
    }
    return out
  }

  // Classic sin-hash pseudo-random, returns [0, 1)
  private func rng(_ i: Int, _ salt: Int) -> Double {
    let x = sin(Double(i + salt * 127 + 1) * 127.1) * 43758.5453
    return x - floor(x)
  }

  private func smoothstep(_ t: Double) -> Double {
    let c = max(0.0, min(1.0, t))
    return c * c * (3.0 - 2.0 * c)
  }

  private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
    a + (b - a) * t
  }
}
