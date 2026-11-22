// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Fork customization (see docs/定制改动记录.md): copy for the switch that
/// shows or hides the brand mark at the top of the menu bar panel. This lives
/// outside the upstream localization catalogs so a merge from upstream cannot
/// conflict with its fifteen per-language initializers. Chinese interfaces get
/// their own copy; every other language falls back to the English one.
///
/// Shaped like the upstream `localized(_:)` strings types rather than free
/// functions: `SettingsSearchCoverageTests` reads each Settings row title back
/// to a strings property, and the switch this labels has to stay findable in
/// Settings search like every other row.
struct PanelBrandMarkStrings {
    let title: String
    let caption: String

    static func localized(_ language: AppLanguage) -> PanelBrandMarkStrings {
        switch language {
        case .zhHans: return .init(title: "在面板顶部显示品牌图标",
                                   caption: "关闭后隐藏顶部的土星标志，面板更紧凑。默认关闭。")
        case .zhTW, .zhHK: return .init(title: "在面板頂部顯示品牌圖示",
                                        caption: "關閉後隱藏頂部的土星標誌，面板更精簡。預設關閉。")
        default: return .init(
            title: "Show brand mark in panel",
            caption: "Hide the mark above the panel tabs for a more compact panel. Off by default.")
        }
    }
}
