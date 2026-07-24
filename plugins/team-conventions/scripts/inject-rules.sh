#!/usr/bin/env bash
#
# SessionStart フックから呼ばれ、rules/*.md を連結して stdout に出力する。
# SessionStart フックの stdout は Claude Code の文脈に additionalContext として注入される。
# → プラグインには「常時自動で載る rules」が無いため、この方式で規約を毎セッション効かせる。
#
set -euo pipefail

RULES_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/rules"

# rules ディレクトリが無ければ何も注入しない（フック自体は正常終了させる）
[ -d "$RULES_DIR" ] || exit 0

cat <<'EOF'
# チーム共通ルール（team-conventions プラグイン）

以下はチームの全プロジェクト共通の規約です。プロジェクト固有の指示（各リポジトリの CLAUDE.md 等）が優先されますが、そこに記載が無い限りこの規約に従ってください。

EOF

for f in "$RULES_DIR"/*.md; do
  [ -e "$f" ] || continue
  cat "$f"
  echo
done
