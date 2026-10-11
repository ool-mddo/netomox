# Plan: layer3 termination-point に FHRP (VRRP/HSRP) 属性を追加する

(状態: 実装済み・バージョンを 0.14.0 に更新 (ブランチ `v0.14.0-dev`)。push すると CI (`packages.yaml`) が gem を GitHub Packages に公開する)

### 確認事項の決定 (2026-10-11)

- 実装ブランチは main の HEAD から `v0.14.0-dev` を切る。
- `group_id` / `priority` は文字列入力を許容する (`convert: lambda(&:to_i)`)。
- DSL の `fhrp:` は Hash の配列のみ受け付ける。
- `docs/reviews/` への変更記録は残さない。
- バージョン更新 (0.14.0) は実装〜テストの確認が済んでから行う。

### 実装結果

- 追加: `lib/netomox/{topology,dsl}/tp_attr/mddo_fhrp.rb`
- 変更: `lib/netomox/{topology,dsl}/tp_attr/mddo.rb` (`MddoL3TPAttribute`)、`lib/netomox/convert_attr.rb` (`virtual_address` → `virtual_addresses`)
- テスト追加 (20 examples): `spec/dsl/tp_attr_mddo_fhrp_spec.rb`, `spec/topology/tp_attr_mddo_fhrp_spec.rb`,
  `spec/topology/convert_attr_fhrp_spec.rb`, `spec/topology_diff/tp_fhrp_attr_diff_spec.rb`
- docs 更新: `docs/requirements.md`, `docs/design-notes.md`, `CLAUDE.md`
- 確認: `bundle exec rspec` 332 examples, 0 failures (従来 312 + 20)、`bundle exec rubocop` 違反なし。
  新規コードは Ruby 3.0 互換 (引数省略構文を未使用)。

playground リポジトリの `docs/work/plans/fhrp_termination_point_attributes.md` の Phase A に相当する。
全体計画・データモデルの検討経緯はそちらを参照。この文書は netomox 側の実装範囲だけを扱う。

## 調査の基準 (リポジトリ状態)

- 再調査日: 2026-10-11。`git fetch --all` 後、`main` = `origin/main` = `9707e27` (V0.13.0 dev (#16)、2026-09-20)。
  `origin` に `main` より新しいブランチは無い (`origin/v0.13.0-dev`, `origin/v0.12.1-dev` のみ)。
- 最初の調査はローカルの `v0.13.0-dev` (`11c2911`) 上で行ったが、`git diff 11c2911 9707e27` は差分なし。
  このため、調査結果 (コード・docs・CLAUDE.md の記述) は main 上でも同一で、結論に変更はない。
  ベースライン `bundle exec rspec` も main 上で再実行し、312 examples, 0 failures を確認。
- CI (`.github/workflows/test.yaml`) は push ごとに Ruby **3.0** で `rake spec` と rubocop を実行する。
  新規コードは Ruby 3.0 互換にする (3.1 以降の構文 (引数省略の `f(x:)` 等) を使わない)。
- 実装ブランチ: main から切る (名前は規約 `v0.14.0-dev` を想定。要確認)。

## 目的

`mddo-topology:l3-termination-point-attributes` (`MddoL3TPAttribute`) に、VRRP/HSRP などの
First Hop Redundancy Protocol のグループ情報 `fhrp` を持たせ、Topology 層・DSL 層・PseudoDSL 変換・差分比較で
取りこぼさず扱えるようにする。

## データモデル (決定済み)

```json
"mddo-topology:l3-termination-point-attributes": {
  "description": "...",
  "ip-address": ["192.168.101.2/24"],
  "flag": [],
  "fhrp": [
    {
      "protocol": "vrrp",
      "group-id": 1,
      "virtual-address": ["192.168.101.1"],
      "priority": 150,
      "preempt": true,
      "source-address": "192.168.101.2/24",
      "active": true
    }
  ]
}
```

- 新クラス名は `MddoFhrp` (Topology 層・DSL 層で同名。決定済み)。
- 1 TP 内で `(protocol, group-id)` が一意。VRRP と HSRP の併存は配列の別要素。
- **`fhrp` が空のとき、`to_data` / `topo_data` に `fhrp` キーを出力しない** (既存 topology.json を変えない)。
  - 先例: `MddoL3NodeAttribute#to_data` が `firewall` が空のとき `data.delete('firewall')`。
- キー名は kebab-case (既存の `ip-address` に合わせる。`ext:` は JSON キーと完全一致が必須)。
  - 注意: CLAUDE.md の「キーは snake_case + 複数形」は **FW 関連クラス**のスキーマに対する規約。
    TP 属性 (`ip-address`, `flag`, `network-type` 等) は従来どおり kebab-case なので、そちらに合わせる。

## 現状 (調査結果)

- Topology 層: `lib/netomox/topology/tp_attr/mddo.rb` の `MddoL3TPAttribute < AttributeBase`
  (`ATTR_DEFS`: `description`, `ip-address`→`ip_addrs`, `flag`→`flags`)。`Diffable` は include していない。
- DSL 層: `lib/netomox/dsl/tp_attr/mddo.rb` の `MddoL3TPAttribute` (`description:`, `ip_addrs:`, `flags:`)。
  `empty?` と `topo_data` を持つ。`DSL::TermPoint#attribute(**attr)` が `MddoL3TPAttribute.new(**attr)` を呼ぶ。
- 入れ子配列の参考実装: `MddoOspfAreaTPAttribute` の `neighbors` と `MddoOspfNeighbor`
  (Topology: `SubAttributeBase` 継承 + `ATTR_DEFS`、DSL: kwargs + `topo_data`)。
  親の `initialize` で `super` の後に `convert_neighbors(data)` で配列を差し替えている。
- PseudoDSL: `PNetworks` が `nmx_tp.attribute(term_point.attribute)` で Hash を DSL の `attribute(**attr)` に渡す。
  トポロジ → PseudoDSL の逆変換は `lib/netomox/convert_attr.rb` の `convert_attr_topo2dsl`
  (キーの `-`→`_`、配列値で `PLURAL_ATTR_KEY_TABLE` にあるキーは複数形に変換)。
  → `fhrp` (キー名そのまま) と `group-id`→`group_id`, `source-address`→`source_address` は変換規則で足りるが、
    **配列の `virtual-address` は `PLURAL_ATTR_KEY_TABLE` に追加しないと `virtual_address` のままになる**。
- 差分比較 (`topology_diff`): `compare_attribute` は `Hashdiff.diff(lhs.to_data, rhs.to_data)` を使う。
  `to_data` に `fhrp` が出れば、追加・削除・変更は検出される (`Diffable` の追加は不要)。
  `fhrp` が空のときキーを出さない仕様なので、片方だけ `fhrp` を持つ場合も Hashdiff の add/remove として出る。
- ベースライン: `bundle exec rspec` は 312 examples, 0 failures。

## 実装内容

### 1. Topology 層

**新規** `lib/netomox/topology/tp_attr/mddo_fhrp.rb`: `MddoFhrp < SubAttributeBase`。

| int | ext | default | 備考 |
|---|---|---|---|
| `protocol` | `protocol` | `''` | `'vrrp'` / `'hsrp'` |
| `group_id` | `group-id` | `-1` | Integer |
| `virtual_addresses` | `virtual-address` | `[]` | Array<String> |
| `priority` | `priority` | `0` | Integer |
| `preempt` | `preempt` | `false` | Boolean |
| `source_address` | `source-address` | `''` | String |
| `active` | `active` | `false` | Boolean |

- `initialize(data, type)` は `MddoOspfNeighbor` と同形。`to_s` を実装 (`"fhrp: protocol:#{protocol}, group_id:#{group_id}"` 等)。
- 値の型: `SubAttributeBase#members_value_type_check` は Integer/String の混在は warn、それ以外は error ログ。
  CSV 由来で数値が文字列で来る可能性は上流 (netomox-exp) で整数化する前提。`group_id` / `priority` に `convert: ->(d) { d.to_i }`
  を付けるかは実装時に検討 (既存の convert 利用例と合わせる)。

**変更** `lib/netomox/topology/tp_attr/mddo.rb` の `MddoL3TPAttribute`:

- `require 'netomox/topology/tp_attr/mddo_fhrp'` を追加。
- `attr_accessor` に `:fhrp` を追加。`ATTR_DEFS` に `{ int: :fhrp, ext: 'fhrp', default: [] }` を追加。
- `initialize` で `super` の後に `@fhrp = convert_fhrp(data)` (`operative_array_key?` なら `MddoFhrp.new(f, key)` の配列、そうでなければ `[]`)。
- `to_data` を override し、`@fhrp.empty?` なら `data.delete('fhrp')`。
- 既存の `description` / `ip_addrs` / `flags` の挙動は変更しない。

### 2. DSL 層

**新規** `lib/netomox/dsl/tp_attr/mddo_fhrp.rb`: `MddoFhrp`
(kwargs: `protocol: ''`, `group_id: -1`, `virtual_addresses: []`, `priority: 0`, `preempt: false`,
`source_address: ''`, `active: false`。`topo_data` で ext キー (kebab-case) の Hash を返す)。

**変更** `lib/netomox/dsl/tp_attr/mddo.rb` の `MddoL3TPAttribute`:

- `initialize(description: '', ip_addrs: [], flags: [], fhrp: [])`。`@fhrp = fhrp.map { |f| MddoFhrp.new(**f) }`
  (`MddoOspfAreaTPAttribute` の `neighbors` と同様。Hash 以外 (`MddoFhrp` インスタンス) も受けるかは実装時に検討)。
- `topo_data`: `'fhrp'` は `@fhrp` が空でないときだけ出力 (`@fhrp.map(&:topo_data)`)。
- `empty?`: `@fhrp.empty?` を条件に追加 (FHRP だけを持つ TP 属性が欠落しないように)。

### 3. 変換 (`convert_attr.rb`)

- `PLURAL_ATTR_KEY_TABLE` に `virtual_address: :virtual_addresses` を追加。
- `fhrp` は配列だが、キー名を変えずそのまま `fhrp:` として DSL に渡す (JSON キーと DSL kwargs を一致させる)。
  → `PLURAL_ATTR_KEY_TABLE` に `fhrp` は**追加しない** (決定。playground 計画の未決事項の回答)。
- 上記により `convert_attr_topo2dsl` → `DSL::TermPoint#attribute(**attr)` の往復が通ることを確認する。

### 4. バージョン

- `lib/netomox/version.rb` を `0.13.0` → `0.14.0` に更新 (新属性追加は minor)。
  `Gemfile.lock` の `netomox (0.13.0)` が更新対象に含まれるか確認する。
- gem の公開・取り込み (netomox-exp / model-conductor) は Phase B で別途指示を受けるため、今回は行わない。

## テスト計画

CLAUDE.md の方針どおり、機能ごとに専用ファイルを作り、DSL 層と Topology 層を別ファイルにする。
`spec/spec_helper.rb` と既存 spec の書式 (`Netomox::DSL::Networks.new do ... end` → `topo_data` → `Netomox::Topology::Networks.new`) に合わせる。

| ファイル | 内容 |
|---|---|
| `spec/dsl/tp_attr_mddo_fhrp_spec.rb` | DSL で `fhrp` を持つ TP を作り `topo_data` が期待どおり (kebab-case キー、値の型)。`fhrp` 無し/`[]` ではキーが出ない。VRRP+HSRP 併存の複数要素。FHRP だけを持つ属性が `empty?` で落ちない。 |
| `spec/topology/tp_attr_mddo_fhrp_spec.rb` | JSON を `Topology::Networks` でパースして `MddoFhrp` オブジェクトとして取れる (`protocol`, `group_id`, `virtual_addresses` ...)。`fhrp` 無しの TP (`fhrp == []`)。`to_data` の往復で一致、空のとき `fhrp` キー無し。`ip-address` / `description` / `flag` が従来どおり。 |
| `spec/topology/convert_attr_fhrp_spec.rb` | `Topology → convert_attr_topo2dsl → DSL → topo_data` の往復で `fhrp` が保持される (`virtual-address` の複数形変換を含む)。`convert_namespace` 相当の処理で属性が消失しないこと (ext キーと JSON キーの一致の回帰テスト)。 |
| `spec/topology_diff/` に fhrp 専用 spec | 2 つのトポロジ間で `fhrp` の追加・削除・値変更 (priority 変更など) が diff で検出される。既存 spec のうち TP 属性 diff のものの書式に合わせる。 |

確認コマンド:

```bash
cd /home/hagiwara/ool-mddo/netomox
bundle exec rspec                 # ベースライン 312 examples, 0 failures から回帰なし
bundle exec rspec spec/dsl/tp_attr_mddo_fhrp_spec.rb spec/topology/tp_attr_mddo_fhrp_spec.rb
bundle exec rubocop
```

## ドキュメント修正の調査結果

調べたもの: `README.md`, `dsl.md`, `CLAUDE.md`, `docs/requirements.md`, `docs/design-notes.md`, `docs/reviews/*`。

| ファイル | 要否 | 内容 |
|---|---|---|
| `docs/requirements.md` | **要追記** | 現在は FW 情報 (v0.12) の機能要求のみ。FHRP の節 (v0.14) を追加: 対象、機能要求 (R1: `fhrp` 属性の保持、R2: 各フィールド、R3: 空のとき出力しない後方互換、R4: DSL からの構築、R5: 差分検出)、「実装クラス対応」の表 (`MddoFhrp` Topology/DSL)。 |
| `docs/design-notes.md` | **要追記** | FW 情報の設計メモと同様に、FHRP の設計節を追加: L3 TP 属性の拡張を選んだ理由 (別名前空間にしない)、protocol を要素内フィールドに統合した理由 (VRRP/HSRP でパラメータ差が無い)、空配列時にキーを出さない理由、`source-address` を残す理由。 |
| `CLAUDE.md` | **要追記** | 「ATTR_DEFS ext キーの制約」の記述が FW 向け (snake_case + 複数形) に読めるため、「TP 属性・L3 ノード属性の既存キーは kebab-case。FHRP は TP 属性なので kebab-case」と範囲を明記。「略語を使わない」規約に対し、`fhrp` / `MddoFhrp` は JSON キー・クラス名がユーザー決定の例外であることを注記。参考実装の欄に `MddoOspfNeighbor` (TP 側の入れ子配列) も追記。 |
| `dsl.md` | 原則不要 | L2/L3 属性の一般的な説明のみで MDDO 属性の個別一覧は無い。`MddoL3TPAttribute` の例を載せたくなった場合のみ追記 (任意)。 |
| `README.md` | 不要 | 属性一覧・バージョン履歴の記述なし。 |
| `docs/reviews/*.md` | 任意 | 設計変更記録 (日付付き)。FHRP 追加の記録を `docs/reviews/<日付>.md` に残すかは運用に合わせて判断。 |
| YARD (`doc/`) | 不要 | gitignore 済みの自動生成物。新クラスに YARD コメント (`@!attribute`, `@param`) を付ければよい。 |

## 実装ステップ (順序)

1. Topology 層: `MddoFhrp` (Topology) + `MddoL3TPAttribute` 拡張 → `spec/topology/tp_attr_mddo_fhrp_spec.rb`
2. DSL 層: `MddoFhrp` (DSL) + `MddoL3TPAttribute` 拡張 → `spec/dsl/tp_attr_mddo_fhrp_spec.rb`
3. `convert_attr.rb` の更新 → `spec/topology/convert_attr_fhrp_spec.rb`
4. 差分比較の確認 → diff 専用 spec
5. 全 rspec / rubocop、バージョンを 0.14.0 に更新
6. ドキュメント更新 (`docs/requirements.md`, `docs/design-notes.md`, `CLAUDE.md`)

各ステップごとに rspec を通してから次へ進む。

## 確認したい点

- `group_id` / `priority` に `convert: ->(d) { d.to_i }` を付けて文字列入力を許容するか (上流で整数化する前提なら不要)。
- DSL の `fhrp:` が `MddoFhrp` インスタンスも受け付けるか (Hash のみで十分か)。
- `docs/reviews/` に変更記録を残すか。
- バージョン更新 (0.14.0) を Phase A のコミットに含めるか、gem 取り込み (Phase B) の指示時に行うか。
