## テスト規約

- テストフレームワークは **RSpec**（`rspec-rails`）。spec は `spec/` 配下に置く（minitest の `test/` は使わない）。
- テストは**コンテナ内で実行する**（サービス名はリポジトリにより異なる: `web` / `backend` など）。

  ```sh
  docker compose exec <service> bundle exec rspec                             # 全実行
  docker compose exec <service> bundle exec rspec spec/models/foo_spec.rb     # ファイル単位
  docker compose exec <service> bundle exec rspec spec/models/foo_spec.rb:42  # 行単位（その example のみ）
  ```

- ファクトリ（factory_bot）・サポート設定・test DB 準備などプロジェクト固有の詳細は、各リポジトリの `CLAUDE.md` / `spec/` を参照する。
