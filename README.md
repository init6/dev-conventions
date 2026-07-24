# dev-conventions

チームで共有する Claude Code プラグインのマーケットプレイス。
プロジェクトを跨いで使う共通ルール・スキルをここに集約する。

## 収録プラグイン

| プラグイン | 内容 |
|-----------|------|
| `team-conventions` | 共通規約（コミット/ブランチ/PR/Redmine/知識共有/Docker/テスト/デプロイ）を SessionStart フックで毎セッション注入し、着手・起票・PR準備・デプロイ・知識記録のコマンド、Redmine スキル、レビューエージェント、コミット規約フックを提供する |

### コマンド / スキル / エージェント / フック

| 種別 | 名前 | 内容 |
|------|------|------|
| コマンド | `/start-task <番号>` | Redmine チケットに着手（担当者=自分・進行中に更新）し、最新デフォルトブランチから `task/<番号>` を作成 |
| コマンド | `/new-ticket` | Redmine にチケットを起票（任意で親チケット配下の子チケットに） |
| コマンド | `/pr-ready` | デフォルトブランチへ rebase → 1コミットに集約 → push → `refs #<番号>` の PR を作成 |
| コマンド | `/deploy` | Capistrano で本番デプロイ（対象・ブランチを確認してから `cap production deploy`） |
| コマンド | `/knowledge <メモ>` | 蓄積すべき知見をリポジトリの知識ドキュメント（`docs/knowledge.md` 等）に書式を揃えて追記 |
| スキル | `redmine` | Redmine の起票/更新/コメント/ID 逆引きを curl で行うレシピ（Redmine 作業時に自動で効く） |
| エージェント | `reviewer` | 変更差分を規約準拠＋正しさの両面でレビューする読み取り専用エージェント |
| フック | commit-msg（PreToolUse/Bash） | `git commit` に `refs #<番号>` が無いとき非ブロッキングで注意を注入 |

> コマンド/スキルは Redmine のホストやプロジェクト ID・デプロイ先などの**環境固有値をハードコードせず**、作業中リポジトリの `CLAUDE.md` から解決する。

## 導入方法

任意のプロジェクトの Claude Code セッション内で、以下を実行する。

```
/plugin marketplace add init6/dev-conventions
/plugin install team-conventions@dev-conventions
/reload-plugins
```

> ※ private org リポジトリの場合、各自の GitHub 認証（`gh auth` 等）が通っている必要がある。

## 仕組み（なぜフックで注入するのか）

Claude Code のプラグインは、`CLAUDE.md` のように「常時自動で文脈に載る rules」を持てない。
プラグインが文脈に寄与できるのは `skills` / `agents` / `hooks` 経由のみ。

そのため本プラグインでは、規約を人が読みやすい **`rules/*.md`** として管理しつつ、
`SessionStart` フック（`hooks/hooks.json` → `scripts/inject-rules.sh`）が
それらを連結して stdout に出力し、`additionalContext` として毎セッション注入する。

- **規約を足す / 直す** … `plugins/team-conventions/rules/*.md` を編集するだけ。
- スクリプトは `rules/` 配下の `*.md` を自動で拾うので、ファイルを増やせばそのまま反映される。

## ディレクトリ構成

```
dev-conventions/
├── .claude-plugin/marketplace.json      # マーケットプレイス定義
├── plugins/
│   └── team-conventions/
│       ├── .claude-plugin/plugin.json    # プラグイン定義
│       ├── rules/                        # 規約 md（正本・レビュー対象／毎セッション注入）
│       │   ├── commit-and-branch.md
│       │   ├── pr-flow.md
│       │   ├── redmine.md
│       │   ├── knowledge-sharing.md
│       │   ├── docker-workflow.md
│       │   ├── testing.md
│       │   └── deploy.md
│       ├── commands/                     # スラッシュコマンド
│       │   ├── start-task.md             # /start-task <番号>
│       │   ├── new-ticket.md             # /new-ticket
│       │   ├── pr-ready.md               # /pr-ready
│       │   ├── deploy.md                 # /deploy
│       │   └── knowledge.md              # /knowledge <メモ>
│       ├── skills/                       # スキル（必要時に自動で効く）
│       │   └── redmine/SKILL.md
│       ├── agents/                       # サブエージェント
│       │   └── reviewer.md               # 規約準拠＋正しさのレビュー
│       ├── hooks/hooks.json              # SessionStart 注入 + PreToolUse コミット規約チェック
│       └── scripts/
│           ├── inject-rules.sh           # rules/*.md を連結して注入
│           └── check-commit-msg.sh       # refs # 欠落を非ブロッキングで注意
└── README.md
```

## 規約の追加・編集

1. `plugins/team-conventions/rules/` に md を追加、または既存 md を編集する。
2. `refs #<番号> ...` 形式でコミットし、PR を出してレビューを受ける（規約自体もレビュー対象）。
3. 各利用者は `/plugin update team-conventions` → `/reload-plugins` で最新化する。

> Redmine のホストやプロジェクト ID など**環境ごとに異なる値は規約に書かず**、各リポジトリの `CLAUDE.md` 側に委ねる。共通する運用・手順のみここに置く。

## 今後の拡張（案）

- `skills/` … Redmine の起票/更新を対話的に行うスキル、PR 準備（rebase→1コミット→PR）スキル など
- `commands/` … `/redmine-issue`、`/pr-ready` などの定型コマンド
- 規約が増えたら `rules/` にファイルを追加
