import Foundation
import SwiftTUI

// 3D ASCII spinning cube driven by TimelineView.
// Each face uses a distinct character so rotation is visually readable.
// Render algorithm: for every surface point, apply Rx*Ry*Rz, project with
// perspective, write to a z-buffered character grid, then emit as a String.
struct SpinnerView: View {
  private let width = 30
  private let height = 15

  var body: some View {
    TimelineView(PeriodicTimelineSchedule(by: .milliseconds(60))) { context in
      let t = context.instant.offset.totalSeconds
      Text(
        renderFrame(
          angleA: t * 0.50,
          angleB: t * 0.83,
          angleC: t * 0.31
        )
      )
    }
  }

  private func renderFrame(angleA: Double, angleB: Double, angleC: Double) -> String {
    let W = width, H = height
    var zBuf = [Double](repeating: 0, count: W * H)
    var cells = [Character](repeating: " ", count: W * H)

    // Perspective constants: K2 = camera distance, K1 = scale factor tuned
    // so the cube fills ~80 % of the 30×15 canvas after aspect-ratio doubling.
    let size: Double = 1
    let K2: Double = 5.0
    let K1: Double = 20.0

    let sA = sin(angleA), cA = cos(angleA)
    let sB = sin(angleB), cB = cos(angleB)
    let sC = sin(angleC), cC = cos(angleC)

    var s = -size
    while s <= size {
      var t = -size
      while t <= size {
        //               x       y       z        face char
        blit(s,  t,  size, "@", sA,cA, sB,cB, sC,cC, K1,K2, W,H, &zBuf,&cells)
        blit(s,  t, -size, ".", sA,cA, sB,cB, sC,cC, K1,K2, W,H, &zBuf,&cells)
        blit(-size, s, t,  "|", sA,cA, sB,cB, sC,cC, K1,K2, W,H, &zBuf,&cells)
        blit( size, s, t,  "+", sA,cA, sB,cB, sC,cC, K1,K2, W,H, &zBuf,&cells)
        blit(s,  size, t,  "o", sA,cA, sB,cB, sC,cC, K1,K2, W,H, &zBuf,&cells)
        blit(s, -size, t,  "=", sA,cA, sB,cB, sC,cC, K1,K2, W,H, &zBuf,&cells)
        t += 0.04
      }
      s += 0.04
    }

    var out = ""
    out.reserveCapacity((W + 1) * H)
    for row in 0..<H {
      for col in 0..<W { out.append(cells[col + row * W]) }
      if row < H - 1 { out.append("\n") }
    }
    return out
  }

  // Projects one surface point and writes to the z-buffer / cell grid.
  private func blit(
    _ x: Double, _ y: Double, _ z: Double, _ ch: Character,
    _ sA: Double, _ cA: Double,
    _ sB: Double, _ cB: Double,
    _ sC: Double, _ cC: Double,
    _ K1: Double, _ K2: Double,
    _ W: Int, _ H: Int,
    _ zBuf: inout [Double], _ cells: inout [Character]
  ) {
    // Rx(A) * Ry(B) * Rz(C) combined rotation
    let rx = x*(cB*cC) + y*(sA*sB*cC - cA*sC) + z*(cA*sB*cC + sA*sC)
    let ry = x*(cB*sC) + y*(sA*sB*sC + cA*cC) + z*(cA*sB*sC - sA*cC)
    let rz = x*(-sB)   + y*(sA*cB)             + z*(cA*cB)

    let depth = rz + K2
    guard depth > 0.1 else { return }

    let inv = 1.0 / depth
    // x is doubled to compensate for terminal character aspect ratio (~2:1 h:w)
    let xp = Int(Double(W) * 0.5 + K1 * inv * rx * 2.0)
    let yp = Int(Double(H) * 0.5 - K1 * inv * ry)

    guard xp >= 0, xp < W, yp >= 0, yp < H else { return }

    let idx = xp + yp * W
    if inv > zBuf[idx] {
      zBuf[idx] = inv
      cells[idx] = ch
    }
  }
}
