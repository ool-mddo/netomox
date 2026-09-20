# Netomox — プロジェクト方針

## 概要

netomox は ool-mddo プロジェクトで使うネットワークトポロジデータコンテナ gem。
RFC8345 準拠の JSON をパース・生成し、トポロジの差分検出も行う。

## コーディング規約

### 命名規則
- 略語を使わない: `fw` ではなく `firewall` のように完全な語を使う

### 層拡張のパターン
新しい属性・層を追加する場合は **Topology 層と DSL 層の両方を必ずセットで実装する**。

- **Topology 層** (`lib/netomox/topology/`): `SubAttributeBase` を継承、`ATTR_DEFS` で
  フィールドを定義、`initialize` でサブ属性オブジェクトに変換する
- **DSL 層** (`lib/netomox/dsl/`): keyword 引数 + `topo_data` / `empty?` メソッドを実装する

参考実装: `MddoL3StaticRoute`、`MddoBgpPolicy`

### デバイス種別の識別
- ノード種別の識別には `node_type` ではなく **`flags`** を使う
  - 例: ファイアウォールノードは `flags: ['firewall']`
  - `node_type` は L3 トポロジ上の役割 (`'node'`, `'segment'`) にのみ使う

## テスト方針

- 新機能のテストは既存のテストファイルに追記せず、**機能ごとに専用ファイルを作成する**
  - 例: `spec/topology/node_attr_firewall_spec.rb`
- DSL 層と Topology 層それぞれ対応するテストファイルを作成する

## ドキュメント

手書きのドキュメントは `docs/` に置く。
YARD が自動生成する HTML ドキュメントは `doc/` (gitignore 済み) に出力される。

## ATTR_DEFS ext キーの制約

Topology 層の `ATTR_DEFS` で定義する `ext:` の値は、実際のトポロジ JSON における **JSON キー名と完全一致** しなければならない。
`SubAttributeBase#select_child_attr` が ext キーでデータを読み書きするため、不一致があると
`convert_namespace` 実行時にアトリビュートが消失する。

FW 関連クラスのスキーマは playground の canonical definition に従う:
**`playground/docs/firewall_node_attributes.md`** (playground リポジトリ)

キーはすべて **snake_case + 複数形** (`zones`, `policies`, `interfaces`, `rules`, `from_zone` 等)。
ハイフン区切り・単数形 (`zone`, `from-zone`, `interface` 等) は誤り。

## 開発ツール

### rubocop
- rubocop-rspec は `plugins:` 形式でロードする (`require:` ではない)
- rubocop-rspec **3.x 以上** が必要 (`Gemfile`: `gem 'rubocop-rspec', '~> 3.0'`)
- rubocop-rspec 3.x から `RSpecRails`, `FactoryBot` 等のサブ Cop 群が独立した gem に分離された。
  使用しない場合は `.rubocop.yml` から `RSpecRails:` / `FactoryBot:` の設定を削除すること
- Capybara cops は `rubocop-capybara` gem が別途必要 (netomox は未使用のため `.rubocop.yml` に含めない)
