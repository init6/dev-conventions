---
description: Capistrano で本番デプロイする（対象・ブランチを確認してから cap production deploy）
argument-hint: "(任意) production 以外のステージ名"
---

Capistrano で本番デプロイを行う。**本番は影響が大きいため、確認を挟みながら**進めること。ステージは引数があればそれ、無ければ `production`。

## 0. 手順の正本を読む
- このリポジトリの `CLAUDE.md` / `docs/knowledge.md` の**デプロイ節**を読み、以下を把握する: デプロイ用 **runner のサーバー・パス・ブランチ**、`cap` 実行コマンド、rbenv/PATH など環境固有の注意点。
- 情報が見つからなければ、勝手に実行せずユーザーに確認する。

## 1. 事前チェック
- デプロイ対象のブランチ（多くは `develop`）が最新か、意図した内容がマージ済みかを確認する。
- **`Gemfile.lock` を変更している場合**は、runner 側で先に `bundle install` を実行する（未実施だと `cap` が `Bundler::GemNotFound` で落ちる）。

## 2. 実行（要確認）
- **「どのサーバーの runner で・どのブランチを・`cap <stage> deploy` する」**を提示し、実行してよいか明示的に確認する。
- 確認が取れたら、リポジトリのデプロイ節に記載の手順どおりに実行する（例）:
  ```sh
  ssh <deploy-server>
  sudo su - deploy -c '
    <必要な環境変数（rbenv PATH 等。リポジトリのデプロイ節参照）>
    cd ~/<runner-dir> && git pull --ff-only && bundle install && bundle exec cap <stage> deploy
  '
  ```

## 3. 事後確認・報告
- デプロイ後、稼働確認（ヘルスチェック等。方法はリポジトリのデプロイ節参照）を行う。
- 結果（成功/失敗、流したブランチ・コミット）を報告する。失敗時は出力をそのまま共有する。
