---
name: redmine
description: Redmine のチケットを REST API (curl) で操作する — 起票・更新・担当/ステータス変更・コメント追加・ユーザーやステータスの ID 逆引き。「Redmine」「チケット」「起票」「issue」に関わる作業や、担当者・ステータス・進捗の更新を求められたときに使う。
---

# Redmine を REST API (curl) で操作する

チームのタスクは Redmine で管理する（GitHub Issues ではない）。起票・更新・コメントは REST API を curl で実行できる。

## 接続情報の解決（ハードコードしない）
- **ホスト URL とプロジェクト識別子/ID** は、作業中リポジトリの `CLAUDE.md`（「Redmine」「チケット」節）から読み取る。プロジェクトごとに異なる（例: あるプロジェクトは `redmine.init6.co.jp`、別のプロジェクトは `redmine.nasu.ai`）。不明ならユーザーに確認する。
- 以下では解決したホストを `{host}`、プロジェクト識別子を `{project}` と表記する。

## 認証（重要）
- API キーは各自の環境変数 `REDMINE_KEY`。ヘッダ `X-Redmine-API-Key: $REDMINE_KEY` で渡す。
- **非対話シェルは `~/.zshrc` を読まない**ので、必ず `source ~/.zshrc && curl ...` の形で実行する。
- **キーの値は出力・コミット・PR 本文・チャットに絶対に出さない。**

## よく使う操作

### チケット一覧・詳細
```sh
source ~/.zshrc && curl -sS -H "X-Redmine-API-Key: $REDMINE_KEY" \
  "{host}/issues.json?project_id={project}&status_id=open&limit=50"
source ~/.zshrc && curl -sS -H "X-Redmine-API-Key: $REDMINE_KEY" \
  "{host}/issues/<番号>.json"          # .issue.subject / .status / .assigned_to など
```

### ID の逆引き（名前 → id）
```sh
source ~/.zshrc && curl -sS -H "X-Redmine-API-Key: $REDMINE_KEY" "{host}/users/current.json"      # 自分の user.id
source ~/.zshrc && curl -sS -H "X-Redmine-API-Key: $REDMINE_KEY" "{host}/issue_statuses.json"      # 「進行中」等の id
source ~/.zshrc && curl -sS -H "X-Redmine-API-Key: $REDMINE_KEY" "{host}/trackers.json"            # トラッカー（フェーズ/タスク等）の id
```

### 起票
```sh
source ~/.zshrc && curl -sS -X POST "{host}/issues.json" \
  -H "X-Redmine-API-Key: $REDMINE_KEY" -H "Content-Type: application/json" \
  -d '{"issue":{"project_id":"{project}","tracker_id":<id>,"subject":"件名","description":"本文"}}'
```
親子関係を付けるなら `"parent_issue_id":<親番号>` を `issue` に加える。

### 更新（担当者・ステータス・コメント）
```sh
# 着手: 担当者を自分に + ステータスを「進行中」に
source ~/.zshrc && curl -sS -X PUT "{host}/issues/<番号>.json" \
  -H "X-Redmine-API-Key: $REDMINE_KEY" -H "Content-Type: application/json" \
  -d '{"issue":{"assigned_to_id":<自分のID>,"status_id":<進行中のID>}}'

# コメント（notes）だけ追加
source ~/.zshrc && curl -sS -X PUT "{host}/issues/<番号>.json" \
  -H "X-Redmine-API-Key: $REDMINE_KEY" -H "Content-Type: application/json" \
  -d '{"issue":{"notes":"コメント本文"}}'
```
※ PUT は成功時に空レスポンス（204）を返す。結果は再取得して確認する。

## 運用ルール（team-conventions と一致）
- タスクはまず**起票**し、**着手時**に担当者を自分・ステータス「進行中」に更新する。
- **完了は PR マージをもって完了**とみなす（手動で「完了」に変えなくてよい）。
- Claude に作業指示する場合も担当者は**指示者本人**（Claude を担当者にしない）。
- コミットに `refs #<番号>` を付けると Redmine と自動で関連付く。
