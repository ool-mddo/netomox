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
