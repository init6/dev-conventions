---
description: チーム共通の許可ルール（permissions.allow）を各自のローカル設定に一発で入れる手順を案内する
argument-hint: "(任意) --global（~/.claude/settings.json へ） / プロジェクト固有ルールJSONのパス"
---

チーム共通の許可ルールのひな形を、開発者本人の Claude 設定にマージするための案内を出す。

## 重要
- **この適用はエージェント（Claude）自身では実行できない。** settings を編集して権限を昇格させる操作はブロックされるため、**ユーザー本人がターミナルで**実行する必要がある。
- したがってこのコマンドでは、実行はせず**「本人が叩く1行コマンド」を提示**する。

## 出力する内容
1. 何が入るかを簡潔に説明する（`${CLAUDE_PLUGIN_ROOT}/permissions/team-allow.json` の中身＝docker compose / rspec / git / gh などの定番許可）。
2. 以下の 1 行を、そのままコピーして自分のターミナルで実行するよう案内する（既定はプロジェクトの `.claude/settings.local.json`、gitignore 対象・冪等）:
   ```sh
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/apply-permissions.sh"
   ```
   - 全プロジェクトに効かせたい場合: 末尾に `--global`（`~/.claude/settings.json` へ）。
   - **プロジェクト固有の強い権限**（例: 本番 SSH デプロイ `Bash(ssh <host> *)`）を入れたい場合は、そのリポジトリのテンプレ JSON を引数で渡す:
     ```sh
     bash "${CLAUDE_PLUGIN_ROOT}/scripts/apply-permissions.sh" .claude/allow-rules.deploy.json
     ```
3. 引数 `$ARGUMENTS` があれば、それを上記コマンドに反映した形で提示する。
4. 適用後は設定がライブ反映される旨、及び強い権限は本人合意の上で入れるものである旨を添える。

## 補足（方式の使い分け）
- **無害な定番許可**はリポジトリの `.claude/settings.json`（コミット）に入れれば git で自動共有でき、各自の適用は不要。
- **強め/環境依存の許可**は本コマンドのひな形＋適用で、各開発者が明示的に opt-in するのが安全。
