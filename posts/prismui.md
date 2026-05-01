---
title: "PrismUI — Controlling MSI RGB Keyboard on macOS"
date: "08-08-2021"
kind: project
links:
  - label: "PrismUI on GitHub"
    href: "https://github.com/erikbdev/PrismUI"
    role: primary
  - label: "SSKeyboardHue on GitHub"
    href: "https://github.com/erikbdev/SSKeyboardHue"
    role: secondary
---

## PrismUI — Controlling MSI RGB Keyboard on macOS

When I configured my Hackintosh, I was unable to control the RGB keyboard on my MSI laptop due to the software only being supported on Windows. To resolve this issue, my first approach was to build an app using AppKit, C++, and Objective-C to communicate with the HID keyboard, which was ultimately called [SSKeyboardHue](https://github.com/erikbdev/SSKeyboardHue).

Later, I decided to switch the communication protocol to Swift and redesign the front end using SwiftUI.

Both projects are available on GitHub — feel free to check them out!
