---
description: 自分が担当（または進行中）の Redmine チケット一覧を表示する
argument-hint: "(任意) all=全プロジェクト / 進行中=進行中のみ"
---

現在のリポジトリの Redmine プロジェクトで、自分に割り当てられたオープンなチケットを一覧する。

## 手順
- ホスト/プロジェクトは各リポジトリの `CLAUDE.md` から解決（`redmine` スキル参照）。認証は `source ~/.zshrc` + `REDMINE_KEY`、**キーは出さない**。
- 取得（自分担当・オープンのみ、更新日降順）:
  ```sh
  source ~/.zshrc && curl -sS -H "X-Redmine-API-Key: $REDMINE_KEY" \
    "{host}/issues.json?project_id={project}&assigned_to_id=me&status_id=open&limit=100&sort=updated_on:desc"
  ```
  ※ Redmine は `assigned_to_id=me` をサポート（API キーの本人）。
- 引数対応:
  - `all` … プロジェクト横断（`project_id` を外す）。
  - `進行中` … 進行中ステータスのみ（`issue_statuses.json` で id を引いて `status_id=<進行中>`）。

## 表示
- 番号・ステータス・トラッカー・件名を表形式で簡潔に。件数も添える。
- 着手するチケットがあれば `/start-task <番号>` を案内する。
