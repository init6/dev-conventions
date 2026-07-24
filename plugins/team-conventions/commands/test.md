---
description: コンテナ内で RSpec を実行する（テスト DB 準備込み）
argument-hint: "(任意) spec のパス or パス:行（例 spec/models/foo_spec.rb:42）"
---

このリポジトリのテスト（RSpec）を**コンテナ内で**実行する。

## 0. 前提
- 開発は `compose.yml` のコンテナ内で行う（docker-workflow 規約）。`bundle`/`rails`/`rspec` はホストで直接実行しない。
- 対象サービス名はリポジトリにより異なる（`web` / `backend` 等。Rails アプリ本体のサービス）。不明なら `compose.yml` を見て判断し、迷えばユーザーに確認する。

## 1. 実行
- 引数 `$ARGUMENTS` があればそのパス（`spec/...` または `spec/...:行`）を、無ければ全体を対象にする。
- コンテナが起動していなければ先に `docker compose up -d <service>`（または `docker compose run --rm <service> ...`）。
- test DB を用意してから実行する（準備済みなら `db:prepare` は速い no-op）:
  ```sh
  docker compose exec <service> bash -lc "RAILS_ENV=test bin/rails db:prepare && bundle exec rspec $ARGUMENTS"
  ```

## 2. 報告
- 結果（例数・失敗数）を要約する。失敗があれば該当 example とエラー出力をそのまま共有する。
- 振る舞いを変える変更なら、対応する spec があるか（`spec/` 配下）も併せて確認する。
