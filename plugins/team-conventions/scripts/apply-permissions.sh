#!/usr/bin/env bash
#
# 許可ルール（permissions.allow）のひな形を、開発者本人の Claude 設定にマージする。
# 既存ルールは保持し、重複なく追加する（冪等）。
#
# ※ このスクリプトは「開発者本人がターミナルで実行する」もの。Claude（エージェント）が
#    自分で settings を編集して権限を昇格させる操作はブロックされるため、適用は本人が行う。
#
# 使い方:
#   bash apply-permissions.sh [RULES_JSON] [--global|--local]
#     RULES_JSON : 取り込む allow ルールの JSON（{"allow": [...]} または [...]）。
#                  省略時は同梱の permissions/team-allow.json。
#     --local    : プロジェクトの .claude/settings.local.json（既定, gitignore 対象）
#     --global   : ~/.claude/settings.json（全プロジェクト）
#
set -euo pipefail
command -v python3 >/dev/null 2>&1 || { echo "python3 が必要です" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES="$SCRIPT_DIR/../permissions/team-allow.json"
TARGET=".claude/settings.local.json"

for a in "$@"; do
  case "$a" in
    --global) TARGET="$HOME/.claude/settings.json" ;;
    --local)  TARGET=".claude/settings.local.json" ;;
    *)        RULES="$a" ;;
  esac
done

[ -f "$RULES" ] || { echo "ルールファイルが見つかりません: $RULES" >&2; exit 1; }

python3 - "$RULES" "$TARGET" <<'PY'
import json, os, sys
rules_path, target = sys.argv[1], sys.argv[2]

data = json.load(open(rules_path))
rules = data.get("allow", data) if isinstance(data, dict) else data
if not isinstance(rules, list):
    print("ルール JSON は配列か {\"allow\": [...]} 形式にしてください", file=sys.stderr); sys.exit(1)

os.makedirs(os.path.dirname(target) or ".", exist_ok=True)
cfg = {}
if os.path.exists(target):
    with open(target) as f:
        cfg = json.load(f)

allow = cfg.setdefault("permissions", {}).setdefault("allow", [])
seen = set(allow)
added = [r for r in rules if r not in seen]
allow.extend(added)

with open(target, "w") as f:
    json.dump(cfg, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"target: {target}")
if added:
    print(f"added {len(added)} rule(s):")
    for r in added:
        print("  +", r)
else:
    print("追加なし（すべて既に許可済み）")
PY
