---
description: Redmine にチケットを起票する（任意で親チケット配下の子チケットとして）
argument-hint: "<チケット件名>（任意）"
---

Redmine に新規チケットを**起票**する。すべての作業はチケットに紐づけるため、着手前にまず起票する。

## 0. 接続情報
- **ホスト・プロジェクト識別子/ID** は、このリポジトリの `CLAUDE.md`（「Redmine」節）から読み取る。ハードコードしない。不明ならユーザーに確認する。
- 認証は `REDMINE_KEY`。curl は `source ~/.zshrc && curl ...` の形で実行し、**キー値は出力しない**。詳しい API 手順は `redmine` スキルを参照。

## 1. 起票内容を決める
- **件名** … 引数 `$ARGUMENTS` があればそれを使う。無ければユーザーに尋ねる。
- **説明**（description）… 分かる範囲で。ユーザーに補足を求めてよい。
- **トラッカー** … 種別（タスク / バグ / フェーズ 等）。不明なら `GET {host}/trackers.json` で候補を出して選ばせる。
- **親チケット**（任意）… フェーズ配下の子チケットにする場合は親番号を確認し `parent_issue_id` に入れる。

## 2. 起票する（実行前に確認）
起票内容（プロジェクト・トラッカー・件名・親）を提示し、**作成してよいか一言確認**してから実行する。

```sh
source ~/.zshrc && curl -sS -X POST "{host}/issues.json" \
  -H "X-Redmine-API-Key: $REDMINE_KEY" -H "Content-Type: application/json" \
  -d '{"issue":{"project_id":"{project}","tracker_id":<id>,"subject":"<件名>","description":"<説明>"}}'
```
親子にする場合は `issue` に `"parent_issue_id":<親番号>` を加える。

## 3. 報告
- 作成されたチケット番号（`.issue.id`）と URL（`{host}/issues/<番号>`）を報告する。
- そのまま着手するなら `/start-task <番号>` に案内する。
- 担当者は**作業する本人**にする（Claude を担当者にしない）。着手時の担当/ステータス更新は `/start-task` で行う。
