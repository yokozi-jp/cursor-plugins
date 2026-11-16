# Kiro CLI で pstack と thermos を使う

[English](./README.md) | 日本語。内容が食い違うときは英語版を正とする。

このフォークは [cursor/plugins](https://github.com/cursor/plugins) に `kiro/` だけを足したもの。upstream のファイルは変えない。入るのは pstack、thermos、cursor-team-kit の `deslop`・`control-cli`・`control-ui` と、Kiro 用のエージェント、steering、権限の雛形。

## 管理者: リポジトリに入れる

```bash
git clone https://github.com/yokozi-jp/cursor-plugins.git ~/cursor-plugins   # 初回だけ
git -C ~/cursor-plugins pull
~/cursor-plugins/kiro/install.sh --repo <対象のリポジトリ>
cd <対象のリポジトリ> && git add .kiro && git commit -m "chore(kiro): add pstack and thermos" && git push
```

- 2 回目以降も同じコマンドで更新できる。前回入れたファイルが最新の版に置き換わる。
- `skip: ... already exists` と出たものは、リポジトリの既存の版が残り、こちらの版は入らない。こちらの版を使いたいなら、既存の方を消すか名前を変えてから、もう一度実行する。
- 自分のマシンの `~/.kiro/settings/permissions.yaml` がなければ、一緒に作られる。

## 利用者: 使い始める

リポジトリを clone したら、そのリポジトリの中で 1 回だけ実行する。

```bash
mkdir -p ~/.kiro/settings && [ -e ~/.kiro/settings/permissions.yaml ] || cp .kiro/kiro-permissions.yaml ~/.kiro/settings/permissions.yaml
```

Kiro CLI を起動し、「Trust this workspace?」が出たら Trust を選ぶ。更新は `git pull` だけでよい。

## 禁止事項

- リポジトリに入れたスキルやエージェントを、そのリポジトリの中で編集しない。次の更新で上書きされる。変更はこのフォークの `kiro/` で行う。
- このフォークの `kiro/` 以外のファイルを編集しない。upstream との同期で衝突する。
- 権限ファイルを `permissions.yml` という名前にしない。読み込まれるのは `.yaml` と `.json` だけ。
- `/setup-pstack` を実行しない。Kiro ではモデルをエージェントファイルで決める（入れていない）。

## 管理者: このフォークを変える

- **upstream と同期する:** GitHub の「Sync fork」を押すか、`git fetch upstream && git merge upstream/main && git push`。そのあと、入れてある各リポジトリで「リポジトリに入れる」のコマンドを実行する。
- **モデルを変える:** `kiro/agents/*.md` の `model` と `effortLevel`。使えるモデルは `kiro-cli chat --list-models` で確かめる。
- **入れるスキルを変える:** `kiro/install.sh` の `skill_dirs`。
- **Cursor の名前の読み替えを足す:** `kiro/skills/kiro-adapter/SKILL.md`。upstream のスキルに新しい Cursor の名前が出てきたら、ここに行を足す。

## 自分のマシンの全リポジトリで使う

チームと共有しない使い方。`~/.kiro/` に入る。

```bash
git clone https://github.com/yokozi-jp/cursor-plugins.git ~/cursor-plugins   # 初回だけ
git -C ~/cursor-plugins pull && ~/cursor-plugins/kiro/install.sh
```
