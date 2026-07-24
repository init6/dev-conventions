---
description: Redmine チケットに着手する（担当者を自分に・進行中に変更し、task/<番号> ブランチを作成）
argument-hint: "<Redmine チケット番号>"
---

Redmine チケット **#$1** に着手する。以下を順に行うこと。

## 0. 前提の確認
- 引数 `$1`（チケット番号）が無ければ、番号を尋ねて中断する。
- **Redmine のホスト・プロジェクト識別子**は、このリポジトリの `CLAUDE.md`（「Redmine」「チケット」等の節）から読み取る。見つからなければユーザーに確認する。ホストはハードコードしない。
- Redmine API キーは環境変数 `REDMINE_KEY`。**非対話シェルは `~/.zshrc` を読まない**ため、curl は必ず `source ~/.zshrc && curl ...` の形で実行する。**キーの値は出力・コミットしない。**

## 1. ブランチを作成
1. 最新のデフォルトブランチ（多くは `develop`）を取得する: `git fetch origin` → デフォルトブランチに切替 → `git pull --ff-only`。
2. そこから作業ブランチ `task/$1` を作成して切り替える（既に存在する場合はその旨を伝えて切替のみ）。

## 2. Redmine を「着手」状態に更新
1. 自分の Redmine ユーザー ID を取得する: `GET {host}/users/current.json`（`.user.id`）。
2. 「進行中」ステータスの ID を取得する: `GET {host}/issue_statuses.json` から名前が「進行中」の `id` を引く。
3. チケットを更新する:
   ```sh
   source ~/.zshrc && curl -sS -X PUT "{host}/issues/$1.json" \
     -H "X-Redmine-API-Key: $REDMINE_KEY" -H "Content-Type: application/json" \
     -d '{"issue":{"assigned_to_id":<自分のID>,"status_id":<進行中のID>}}'
   ```
4. 更新後、チケットの件名・担当者・ステータスを 1 行で報告する。

## 補足
- 担当者は**必ず作業する本人**にする（Claude を担当者にしない）。
- この操作は Redmine の状態を変更する。実行前に「#$1 に着手（担当者=自分／進行中）＋ `task/$1` 作成」でよいか一言確認してから進める。
