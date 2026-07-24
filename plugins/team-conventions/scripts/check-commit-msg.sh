#!/usr/bin/env bash
#
# PreToolUse(Bash) フック。`git commit -m "..."` に Redmine 参照 `refs #<番号>` が
# 無いとき、非ブロッキングで注意を文脈に注入する。
# - 決してブロックしない（常に exit 0）。あくまでリマインド。
# - Redmine 管理外リポジトリでは無視してよい旨も添える。
# - python3 が無い環境では静かに何もしない（安全側）。
#
set -euo pipefail

command -v python3 >/dev/null 2>&1 || exit 0

input="$(cat)"

cmd="$(printf '%s' "$input" | python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception:
    pass' 2>/dev/null || true)"

# git commit 以外は対象外
case "$cmd" in
  *"git commit"*) : ;;
  *) exit 0 ;;
esac

# -m / --message 付き（メッセージを指定するコミット）だけを対象にする
printf '%s' "$cmd" | grep -qiE 'git commit[^|;&]*(-m|--message)' || exit 0

# すでに refs #<番号> があれば何もしない
printf '%s' "$cmd" | grep -qE 'refs #[0-9]+' && exit 0

reason="コミットメッセージ規約: 先頭に 'refs #<Redmine番号>' を付けてください（例: refs #604 タイトル）。このコミットには見当たりません。Redmine 管理外のリポジトリなら無視して構いません。"

python3 -c 'import json,sys
print(json.dumps({"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":sys.argv[1]}}))' "$reason"

exit 0
