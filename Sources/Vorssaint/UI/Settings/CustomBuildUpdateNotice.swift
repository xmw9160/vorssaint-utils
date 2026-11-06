// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// Fork customization (see docs/定制改动记录.md): replaces the upstream
/// "Updates" settings section in custom builds, where the check/install
/// controls would be dead ends. Shown on the About / Updates page.
struct CustomBuildUpdateNotice: View {
    @ObservedObject private var l10n = L10n.shared

    var body: some View {
        Section(CustomBuildUpdateStrings.sectionTitle(l10n.language)) {
            VStack(alignment: .leading, spacing: 6) {
                Label(CustomBuildUpdateStrings.title(l10n.language),
                      systemImage: "lock.shield")
                    .font(.callout)
                Text(CustomBuildUpdateStrings.body(l10n.language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
