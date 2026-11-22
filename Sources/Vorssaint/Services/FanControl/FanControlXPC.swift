// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation
import Security
import CryptoKit

enum FanControlIdentifiers {
    static let teamID = "3D485NHW29"

    #if VORSSAINT_DEVELOPMENT
    static let appBundleID = "com.vorssaint.utils.dev"
    #else
    static let appBundleID = "com.vorssaint.utils"
    #endif

    static let helperID = "\(appBundleID).fan-control"
    static let plistName = "\(helperID).plist"

    static var appCodeRequirement: String {
        #if VORSSAINT_DEVELOPMENT
        guard let hash = self.currentLeafCertificateSHA1() else {
            return "identifier \"\(appBundleID)\" and certificate leaf = H\"0000000000000000000000000000000000000000\""
        }
        return "identifier \"\(appBundleID)\" and certificate leaf = H\"\(hash)\""
        #else
        return releaseCodeRequirement(identifier: appBundleID)
        #endif
    }

    static var helperCodeRequirement: String {
        #if VORSSAINT_DEVELOPMENT
        guard let hash = self.currentLeafCertificateSHA1() else {
            return "identifier \"\(helperID)\" and certificate leaf = H\"0000000000000000000000000000000000000000\""
        }
        return "identifier \"\(helperID)\" and certificate leaf = H\"\(hash)\""
        #else
        return releaseCodeRequirement(identifier: helperID)
        #endif
    }

    // Fork customization: the upstream release rules pin the Apple-issued
    // chain (anchor apple generic + team ID), which a locally self-signed
    // build can never satisfy — every XPC handshake between the app and the
    // daemon is rejected in both directions and Fan Control always reports
    // the helper as unavailable. When the running process is not signed by
    // the upstream team certificate, fall back to pinning the leaf
    // certificate that actually signed this build. The validation target
    // stays exact (one specific certificate); only "issued by Apple" is
    // traded for "the very certificate on this build". Ad-hoc binaries have
    // no certificates at all and keep the impossible upstream rule (fail
    // closed). Restore upstream behavior: make releaseCodeRequirement
    // return the anchor-apple-generic string unconditionally.
    private static func releaseCodeRequirement(identifier: String) -> String {
        if currentTeamIdentifier() != teamID,
           let leafHash = currentLeafCertificateSHA1() {
            return "identifier \"\(identifier)\" and certificate leaf = H\"\(leafHash)\""
        }
        return "anchor apple generic and certificate leaf[subject.OU] = \"\(teamID)\" and identifier \"\(identifier)\""
    }

    private static func currentTeamIdentifier() -> String? {
        guard let info = currentSigningInformation() else { return nil }
        return info[kSecCodeInfoTeamIdentifier as String] as? String
    }

    private static func currentSigningInformation() -> [String: Any]? {
        var dynamicCode: SecCode?
        guard SecCodeCopySelf([], &dynamicCode) == errSecSuccess,
              let selfCode = dynamicCode else {
            return nil
        }

        var staticCode: SecStaticCode?
        guard SecCodeCopyStaticCode(selfCode, [], &staticCode) == errSecSuccess,
              let staticSelfCode = staticCode else {
            return nil
        }

        var signingInfo: CFDictionary?
        guard SecCodeCopySigningInformation(staticSelfCode, SecCSFlags(rawValue: kSecCSSigningInformation), &signingInfo) == errSecSuccess,
              let info = signingInfo as? [String: Any] else {
            return nil
        }
        return info
    }

    private static func currentLeafCertificateSHA1() -> String? {
        guard let info = currentSigningInformation(),
              let certificates = info[kSecCodeInfoCertificates as String] as? [SecCertificate],
              let leaf = certificates.first else {
            return nil
        }

        let data = SecCertificateCopyData(leaf) as Data
        let digest = Insecure.SHA1.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

@objc protocol FanControlXPCProtocol {
    func status(withReply reply: @escaping (Data) -> Void)
    func startMaximumCooling(withReply reply: @escaping (Data) -> Void)
    func applyConfiguration(_ configuration: Data, withReply reply: @escaping (Data) -> Void)
    func heartbeat(withReply reply: @escaping (Data) -> Void)
    func restoreAutomatic(withReply reply: @escaping (Data) -> Void)
}

enum FanControlIPC {
    static func encode(_ response: FanControlResponse) -> Data {
        // Every value in this closed response model is JSON encodable. Keeping
        // one deterministic fallback avoids ever violating the XPC reply shape.
        (try? JSONEncoder().encode(response))
            ?? Data(#"{"succeeded":false,"snapshot":{"fans":[],"isCooling":false},"error":"controlFailed"}"#.utf8)
    }

    static func decode(_ data: Data) -> FanControlResponse? {
        try? JSONDecoder().decode(FanControlResponse.self, from: data)
    }

    static func encode(_ configuration: FanControlConfiguration) -> Data? {
        try? JSONEncoder().encode(configuration)
    }

    static func decodeConfiguration(_ data: Data) -> FanControlConfiguration? {
        guard let configuration = try? JSONDecoder().decode(FanControlConfiguration.self,
                                                              from: data),
              FanControlPolicy.validConfiguration(configuration) else { return nil }
        return configuration
    }
}
