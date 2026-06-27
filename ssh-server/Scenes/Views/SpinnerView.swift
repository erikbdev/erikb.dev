import Foundation
import SwiftTUI

// 3D ASCII spinning donut driven by TimelineView.
// Torus parameterised by tube angle θ and revolution angle φ.
// Render: sample surface → RotX(A)·RotZ(B) → perspective → shade → z-buffer.
struct SpinnerView: View {
  private let width = 30
  private let height = 15

  var body: some View {
    TimelineView(.animation) { context in
      let t = context.instant.offset.totalSeconds
      Text(renderFrame(angleA: t * 0.50, angleB: t * 0.83))
    }
  }

  private func renderFrame(angleA: Double, angleB: Double) -> String {
    let W = width, H = height
    var zBuf = [Double](repeating: 0, count: W * H)
    var cells = [Character](repeating: " ", count: W * H)

    let R1: Double = 1.0, R2: Double = 0.4, K2: Double = 5.0
    let K1   = Double(H) * K2 / (2.2 * (R1 + R2))
    let K1x2 = K1 * 2.0          // pre-fold aspect-ratio factor
    let cx   = Double(W) * 0.5
    let cy   = Double(H) * 0.5

    let sA = sin(angleA), cA = cos(angleA)
    let sB = sin(angleB), cB = cos(angleB)

    // Rotation-pair products: constant for every surface point this frame.
    let sA_sB = sA * sB   // appears in px2
    let sA_cB = sA * cB   // appears in f_py

    // Incremental angle stepping — replaces cos/sin calls in the inner loop
    // with a 4-multiply recurrence: cos(φ+Δ) = cosφ·cosΔ − sinφ·sinΔ, etc.
    let thetaStep = 0.03, phiStep = 0.02
    let cosDT = cos(thetaStep), sinDT = sin(thetaStep)
    let cosDP = cos(phiStep),   sinDP = sin(phiStep)

    let lumin: [Character] = Array(".,-~:;=!*#$@")

    var theta = 0.0, cosT = 1.0, sinT = 0.0
    while theta < 2 * Double.pi {
      // ── Hoist everything that depends only on θ out of the φ loop ──
      let circR   = R1 + R2 * cosT
      let py_cA   = R2 * sinT * cA    // R2·sinθ·cosA
      let py_sA   = R2 * sinT * sA    // R2·sinθ·sinA
      let sinT_cA = sinT * cA

      // Constant addends in each projected-coordinate formula
      let px2_off = -py_cA * sB
      let py2_off =  py_cA * cB
      let pz2_off =  py_sA
      let ny2_off =  sinT_cA * cB
      let nz2_off =  sinT * sA

      var phi = 0.0, cosP = 1.0, sinP = 0.0
      while phi < 2 * Double.pi {
        // Two angle factors each shared by a point coordinate and a normal component
        let f_py = cosP * sB - sinP * sA_cB   // → py2, ny2
        let f_pz = sinP * cA                  // → pz2, nz2

        let px2 = circR * (cosP * cB + sinP * sA_sB) + px2_off
        let py2 = circR * f_py + py2_off
        let pz2 = circR * f_pz + pz2_off

        let depth = pz2 + K2
        if depth > 0.1 {
          let inv = 1.0 / depth
          let xp = Int(cx + K1x2 * inv * px2)
          let yp = Int(cy  - K1  * inv * py2)

          if xp >= 0, xp < W, yp >= 0, yp < H {
            let idx = xp + yp * W
            if inv > zBuf[idx] {
              zBuf[idx] = inv
              // Defer normal & lighting until z-test passes (skips occluded points)
              let ny2 = cosT * f_py + ny2_off
              let nz2 = cosT * f_pz + nz2_off
              // L = dot(n, (0, 0.7071, −0.7071)) ∈ [−1, 1]
              let L = (ny2 - nz2) * 0.7071
              cells[idx] = lumin[max(0, min(11, Int((L + 1.0) * 6.0)))]
            }
          }
        }

        // Incremental φ step — 4 muls + 2 adds instead of 2 trig calls
        phi += phiStep
        let nextCosP = cosP * cosDP - sinP * sinDP
        sinP = sinP * cosDP + cosP * sinDP
        cosP = nextCosP
      }

      // Incremental θ step
      theta += thetaStep
      let nextCosT = cosT * cosDT - sinT * sinDT
      sinT = sinT * cosDT + cosT * sinDT
      cosT = nextCosT
    }

    var out = ""
    out.reserveCapacity((W + 1) * H)
    for row in 0..<H {
      for col in 0..<W { out.append(cells[col + row * W]) }
      if row < H - 1 { out.append("\n") }
    }
    return out
  }
}
