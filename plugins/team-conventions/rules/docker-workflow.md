## Docker 開発環境での作業規約

開発は各リポジトリの `compose.yml` で起動するコンテナ内で行う前提。

- **Ruby / Rails / gem 系コマンド（`bundle`・`rails`・`rspec`・`bin/importmap` 等）は、ホストで直接実行せず、対象サービスのコンテナ内で実行する。** ホスト側に gem は入れない。

  ```sh
  # 起動中のコンテナで実行（サービス名はリポジトリにより異なる: web / backend など）
  docker compose exec <service> bundle install
  docker compose exec <service> bin/rails console
  # 起動していない場合は run でも可
  docker compose run --rm <service> bin/rails db:migrate
  ```

- gem は名前付きボリュームに保持する構成が多い。`Gemfile` を変更したら再 `up`（または `bundle install`）で取り込む。
- **サービス名・ポート・接続先などの環境固有値は各リポジトリの `CLAUDE.md`（および `compose.yml`）を参照する。** ここには共通の作業原則のみ記す。
