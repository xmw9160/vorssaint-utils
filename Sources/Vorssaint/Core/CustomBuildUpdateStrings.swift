// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Fork customization (see docs/定制改动记录.md): copy for the notice shown
/// instead of the upstream update controls in a custom build. Kept out of the
/// upstream localization catalogs so a merge from upstream cannot conflict
/// with its fifteen per-language initializers. Chinese interfaces get their own
/// copy; every other language falls back to the English one.
enum CustomBuildUpdateStrings {
    static func sectionTitle(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans: return "更新"
        case .zhTW, .zhHK: return "更新"
        default: return "Updates"
        }
    }

    static func title(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans: return "此构建已关闭应用自更新"
        case .zhTW, .zhHK: return "此建置已關閉應用程式自更新"
        default: return "Self-update is disabled in this build"
        }
    }

    static func body(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans:
            return "自动或手动更新都会把 App 覆盖成上游官方版本，导致定制改动丢失。需要新版本时，请合并上游代码后从源码重新构建（./build-and-run.sh）。"
        case .zhTW, .zhHK:
            return "自動或手動更新都會把 App 覆蓋成上游官方版本，導致客製化改動遺失。需要新版本時，請合併上游程式碼後從原始碼重新建置（./build-and-run.sh）。"
        default:
            return "Any automatic or manual update would replace this app with the stock upstream release and drop every customization. To pick up upstream changes, merge them and rebuild from source (./build-and-run.sh)."
        }
    }
}
