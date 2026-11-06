// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Fork customization (see docs/定制改动记录.md): copy for the switch that
/// shows or hides the brand mark at the top of the menu bar panel. This lives
/// outside the upstream localization catalogs so a merge from upstream cannot
/// conflict with its fifteen per-language initializers. Chinese interfaces get
/// their own copy; every other language falls back to the English one.
enum PanelBrandMarkStrings {
    static func title(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans: return "在面板顶部显示品牌图标"
        case .zhTW, .zhHK: return "在面板頂部顯示品牌圖示"
        default: return "Show brand mark in panel"
        }
    }

    static func caption(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans: return "关闭后隐藏顶部的土星标志，面板更紧凑。默认关闭。"
        case .zhTW, .zhHK: return "關閉後隱藏頂部的土星標誌，面板更精簡。預設關閉。"
        default: return "Hide the mark above the panel tabs for a more compact panel. Off by default."
        }
    }
}
