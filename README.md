# Komodo DeFi Framework iOS Demo

This repository contains a minimal SwiftUI application demonstrating how to embed the **Komodo DeFi Framework** (KDF) on iOS.  The app starts an instance of kdf (aka mm2) from the `libkdf.a` static library, polls the local RPC interface for the version string, and optionally enables and monitors a KMD wallet.  It features automatic polling in the foreground and background, manual version/balance fetches, log viewing, and local notifications when the KMD balance changes. The latter is demonstrate with the app in BG and the iPhone locked.

## Requirements

* **Xcode 15** or later
* **iOS 15** or later deployment target
* The KDF static library **`libkdf.a`** (not included in this repo) and its public header **`komodo_defi_framework.h`** .  Place `libkdf.a` in the project root and add it to your target’s **Link Binary With Libraries** phase.

## Getting Started

1. **Clone the repository** and open the `KdfTest.xcodeproj` in Xcode.

2. **Add the static library**:
   - Copy your `libkdf.a` file into the project root (`KdfTest/libkdf.a`).
   - In Xcode, select the `KdfTest` target, go to **General → Frameworks, Libraries & Embedded Content**, click the **“+”** button and choose **Add Other… → Add Files…**, then pick `libkdf.a` from the project root.
   - Ensure it appears under **Frameworks, Libraries & Embedded Content**.

3. **Configure the bridging header**:
   - The bridging header `KomodoDefiFramework‑Bridging‑Header.h` imports `komodo_defi_framework.h` so Swift can call `mm2_main`, `mm2_main_status`, and `mm2_stop`.
   - In the target’s **Build Settings**, set **Objective‑C Bridging Header** to the relative path of the bridging header (e.g. `KdfTest/KomodoDefiFramework‑Bridging‑Header.h` if it’s inside the `KdfTest` folder).
   - Add the folder containing `komodo_defi_framework.h` to **Header Search Paths** if needed.

4. **Build and run** the app on a simulator or device.  On first launch the app requests notification permission to send local alerts for balance updates.

## Features

* **Automatic Version Polling** – the app calls the `version` RPC method every 10 seconds in the foreground and every 60 seconds in the background.
* **KMD Wallet Controls** – enable or disable the KMD coin, fetch its balance and address, and monitor changes.  The app writes a basic coin definition to disk and embeds it in the configuration so `mm2` knows about KMD.
* **Logs** – view mm2 logs and your own app logs in separate expandable sections.
* **Background Operation** – when the app goes into the background, a background task keeps the polling timers alive.  Note that iOS limits the time a background task may run.
* **Local Notifications** – you receive a local notification whenever a new KMD balance is fetched.

## Notes

* The KMD coin is enabled using the legacy `electrum` RPC method with cipi's Electrum servers.  If you wish to enable other coins or change activation parameters, update the `enableKmd()` call in `KdfService.swift`.
* This project is intended as a starting point or integration test; it lacks user‑interface polish and secure handling of secrets.  Do not use it as a production wallet without proper hardening.

---

For more information on Komodo DeFi Framework and RPC methods, see the official documentation: <https://komodoplatform.com/en/docs/komodo-defi-framework/>.

