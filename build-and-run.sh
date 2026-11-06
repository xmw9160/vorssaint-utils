#!/bin/bash
# 构建 -> 安装到 /Applications -> 启动新版本，一次执行完成。
#
# 参考 x-tool/build-and-run.sh 的流程。区别：本项目 build.sh 的 --install
# 已经负责「结束同名进程 -> 替换 /Applications 中的 bundle -> 重新签名」
# （并会为 /Applications 里的副本补一次稳定签名），所以这里不再自己 pkill/cp，
# 避免与它的签名收尾冲突。
#
# 用法：
#   ./build-and-run.sh              默认：构建官方同名 App，替换并启动 /Applications/Vorssaint.app
#   ./build-and-run.sh --dev        Developer 变体，独立 bundle id / 偏好 / 权限，与官方 App 共存
#   ./build-and-run.sh --official   显式指定官方同名 App（等价于默认）
#
# 自定义改动记录见 docs/定制改动记录.md。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

DEV=0
for arg in "$@"; do
    case "$arg" in
        --dev)      DEV=1 ;;
        --official) DEV=0 ;;
        # ${arg} is braced: a full-width bracket right after $arg would be
        # folded into the variable name under `set -u`.
        *) echo "未知参数：${arg}（可用：--dev / --official）" >&2; exit 2 ;;
    esac
done

if (( DEV )); then
    APP_NAME="Vorssaint (Developer)"
    # --dev 使用 com.vorssaint.utils.dev，独立偏好与权限授权，不覆盖正式版。
    BUILD_ARGS=(--dev --install)
else
    APP_NAME="Vorssaint"
    BUILD_ARGS=(--install)
fi
INSTALL_PATH="/Applications/$APP_NAME.app"

# 日志按次保存，build/ 已被 gitignore。
LOG_DIR="$ROOT_DIR/build"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build-and-run-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "📝 日志：$LOG_FILE"
echo "🔨 构建并安装 $APP_NAME ..."
./build.sh "${BUILD_ARGS[@]}"

if [[ ! -d "$INSTALL_PATH" ]]; then
    echo "错误：构建完成，但没有找到 $INSTALL_PATH" >&2
    exit 1
fi

echo "✅ 启动 $INSTALL_PATH"
open "$INSTALL_PATH"
