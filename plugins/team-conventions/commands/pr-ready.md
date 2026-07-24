---
description: PR を準備する（デフォルトブランチへ rebase→1コミットに集約→push→PR 作成）
argument-hint: "(任意) PR タイトル"
---

現在の作業ブランチを、チーム規約に沿って **1タスク=1コミット** に整えて PR を作成する。

## 0. 前提
- デフォルトブランチ（多くは `develop`。`git remote show origin` の HEAD で判定）を基準にする。
- 作業ブランチ名が `task/<番号>` 形式なら、その `<番号>` を Redmine チケット番号とみなす。取れなければユーザーに確認する。
- コミット規約: 先頭 `refs #<番号>`、続けてタイトル（例 `refs #604 タスクのタイトル`）。

## 1. 最新化と rebase
1. `git fetch origin`。
2. デフォルトブランチに rebase する: `git rebase origin/<default>`。コンフリクトが出たら止めてユーザーに知らせる。

## 2. 1 コミットに集約
1. デフォルトブランチからの差分コミットが 2 つ以上なら squash して 1 つにまとめる（`git reset --soft origin/<default>` → 1 回 `git commit`）。
2. コミットメッセージは `refs #<番号> <タイトル>`。タイトルは引数があればそれ、無ければチケット件名（`GET {host}/issues/<番号>.json` の `.issue.subject`）を使う。Redmine 参照は start-task と同じ認証手順（`source ~/.zshrc`、キーは出さない）。

## 3. push と PR
1. rebase 後は `git push --force-with-lease -u origin <branch>`（初回は通常 push）。
2. **push / PR 作成の前に**、要約（ブランチ名・コミット件名・base ブランチ）を提示して実行可否を一言確認する。
3. PR を作成する: `gh pr create --base <default> --title "<タイトル>" --body "<変更概要>"`。本文末尾に PR 本文規約の 1 行（`🤖 Generated with [Claude Code](https://claude.com/claude-code)`）を含める。
4. 作成した PR の URL を報告し、レビュー/マージ依頼はリポジトリ担当者へ行う旨を添える。
5. **紐付く Redmine チケットに PR の URL をコメント追記する**（チケット番号はブランチ名 `task/<番号>` から。`redmine` スキル参照: `PUT {host}/issues/<番号>.json` の `notes`）。チケットと PR の追跡性を保つため。

## 補足
- デフォルトブランチへ直接 push しない。変更は必ずこの PR 経由で入れる。
- **マージ後**は Redmine 運用規約に従い、紐付くチケットをクローズ状態（完了扱い）へ更新する。
