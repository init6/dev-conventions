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
| コマンド | `/test [パス]` | コンテナ内で RSpec を実行（サービス名解決・test DB 準備込み、ファイル/行指定可） |
| コマンド | `/land <番号>` | マージ後処理: 紐付く Redmine issue を完了＋worktree/ブランチの片付け＋（本番がブランチ追従なら）確認付きデプロイ |
| コマンド | `/my-tickets` | 自分担当/進行中の Redmine チケット一覧 |
| コマンド | `/setup-permissions` | チーム共通の許可ルール（`permissions.allow`）を各自ローカルに入れる手順を案内 |
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
│       │   ├── deploy.md
│       │   └── parallel-work.md
│       ├── commands/                     # スラッシュコマンド
│       │   ├── start-task.md             # /start-task <番号>
│       │   ├── new-ticket.md             # /new-ticket
│       │   ├── pr-ready.md               # /pr-ready
│       │   ├── deploy.md                 # /deploy
│       │   ├── knowledge.md              # /knowledge <メモ>
│       │   ├── test.md                   # /test [パス]
│       │   ├── land.md                   # /land <番号>
│       │   ├── my-tickets.md             # /my-tickets
│       │   └── setup-permissions.md      # /setup-permissions
│       ├── skills/                       # スキル（必要時に自動で効く）
│       │   └── redmine/SKILL.md
│       ├── agents/                       # サブエージェント
│       │   └── reviewer.md               # 規約準拠＋正しさのレビュー
│       ├── permissions/                  # 許可ルールのひな形
│       │   └── team-allow.json           # チーム共通の allow ルール
│       ├── hooks/hooks.json              # SessionStart 注入 + PreToolUse コミット規約チェック
│       └── scripts/
│           ├── inject-rules.sh           # rules/*.md を連結して注入
│           ├── check-commit-msg.sh       # refs # 欠落を非ブロッキングで注意
│           └── apply-permissions.sh      # allow ルールを各自の設定にマージ（本人が実行）
└── README.md
```

## 許可ルールの共有（permissions.allow）

Claude Code の許可ルールをチームで共有し、各開発者が手早く適用するための仕組み。**プラグインは allow ルールを配布できない**（commands/skills/agents/hooks のみ）ため、以下の2方式を使う。

### A. リポジトリの `.claude/settings.json`（コミット・自動共有）
無害で高頻度の定番許可（`Bash(docker compose *)` / `Bash(bundle exec rspec *)` / `Bash(git *)` / `Bash(gh pr *)` など）は、各リポジトリの `.claude/settings.json` にコミットする。git で全員に自動共有され、**各自の操作は不要**。中身のひな形は [`permissions/team-allow.json`](plugins/team-conventions/permissions/team-allow.json)。

### B. ひな形＋適用スクリプト（各自ローカルに一発 opt-in）
本番 SSH デプロイ（`Bash(ssh <host> *)`）のような**強め/環境依存の権限**は、全員に無条件で配らず、各開発者が明示的に opt-in する。

- ひな形: [`permissions/team-allow.json`](plugins/team-conventions/permissions/team-allow.json)（またはリポジトリ固有の JSON）
- 適用（**開発者本人がターミナルで**実行。既定は `.claude/settings.local.json`＝gitignore・冪等）:
  ```sh
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/apply-permissions.sh"                 # チーム定番を local へ
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/apply-permissions.sh" --global        # ~/.claude/settings.json へ
  bash "${CLAUDE_PLUGIN_ROOT}/scripts/apply-permissions.sh" .claude/allow-rules.deploy.json  # プロジェクト固有の強い権限
  ```
- `/setup-permissions` コマンドで、上記の1行コマンドを案内表示できる。

> **なぜ本人実行なのか**: エージェント（Claude）自身が settings を編集して権限を昇格させる操作はブロックされる（自己昇格の防止）。そのため「適用」は必ず開発者本人が行う。

## 課題管理

このリポジトリ自体の課題管理先は Redmine プロジェクト `dev-conventions`。

- https://redmine.init6.co.jp/projects/dev-conventions

規約の変更・プラグインの修正は、他プロジェクトと同じくここにチケットを起票してから着手する。

## 規約の追加・編集

1. Redmine プロジェクト `dev-conventions` にチケットを起票する（`/new-ticket` でも可）。
2. `task/<チケット番号>` ブランチを切る（`/start-task <番号>`）。
3. `plugins/team-conventions/rules/` に md を追加、または既存 md を編集する。
4. **`plugins/team-conventions/.claude-plugin/plugin.json` の `version` を上げる**（下記）。
5. `refs #<番号> ...` 形式でコミットし、`main` へ PR を出してレビューを受ける（規約自体もレビュー対象）。
6. 各利用者は下記の手順で最新化する。

### 送り出す側: `version` を上げるのを忘れない

**中身だけ変えて `version` を据え置くと、利用者側の `/plugin update` は「最新です」と言って何も更新しない。** 更新判定はバージョン番号で行われ、実体もバージョン名のディレクトリ（`~/.claude/plugins/cache/<marketplace>/<plugin>/<version>/`）にキャッシュされるため。rules / commands / skills / agents のいずれかを変えたら、必ず `plugin.json` の `version` を上げる。

`claude plugin tag` を使うと、`plugin.json` とマーケットプレイス側の記載が食い違っていないか検証したうえでリリース用の git タグを作れる。

### 受け取る側: この順に実行する

```
/plugin marketplace update dev-conventions   # marketplace の clone を git pull する
/plugin update team-conventions              # 新しい version を取り込む
/reload-plugins                              # 現在のセッションに反映する
```

**1 行目を飛ばすと古いコミットのまま再インストールされる。** `/plugin update` は marketplace の clone を自分で `git pull` しないため。CLI からは `claude plugin marketplace update dev-conventions` / `claude plugin update team-conventions@dev-conventions` が同等（`/reload-plugins` の代わりにセッション再起動が要る）。反映されたかは実体を見るのが確実。

```sh
ls ~/.claude/plugins/cache/dev-conventions/team-conventions/   # 新しい version のディレクトリができているか
```

> `plugins/team-conventions/rules/` に置く**規約本文**には、Redmine のホストやプロジェクト ID など**環境ごとに異なる値を書かない**（各リポジトリの `CLAUDE.md` 側に委ねる）。上の「課題管理」は規約本文ではなく**このリポジトリ自身の運用**を示すものなので、ここに具体値を書いてよい。

## 今後の拡張（案）

- `skills/` … Redmine の起票/更新を対話的に行うスキル、PR 準備（rebase→1コミット→PR）スキル など
- `commands/` … `/redmine-issue`、`/pr-ready` などの定型コマンド
- 規約が増えたら `rules/` にファイルを追加
