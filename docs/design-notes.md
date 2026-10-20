# Netomox 設計ノート

## Firewall 情報の L3 層拡張 (2026-09-06)

### 背景

ool-mddo プロジェクトで扱うトポロジデータにファイアウォール固有の情報
(セキュリティゾーン、ゾーン間ポリシー、クラスタペア) を持たせる必要が生じた。
入力データは機器ごとの JSON ファイル (`site-a-fw-1.json` 等) として別途提供される。

### 採用方針: 既存 L3 層の拡張

**検討した選択肢:**

| 案 | 内容 | 採否 |
|---|---|---|
| A | 新しい FW 専用層 (`mddo-topology:firewall-network`) を追加 | 不採用 |
| B | 既存 L3 層 (`mddo-topology:l3-network`) を拡張 | **採用** |

**B を採用した理由:**
FW はルーティング上は L3 ノードとして扱われるため、新しい層を追加するとトポロジの
複雑さが増す。FW 固有情報を `firewall` セクションに集約することで既存フィールドと
明確に分離できる。

---

### `firewall` セクション設計

FW 関連データをすべて `firewall` キー 1 つに束ねる設計を採用。

```json
"mddo-topology:l3-node-attributes": {
  "node-type": "node",
  "flag": ["firewall"],
  "prefix": [],
  "static-route": [],
  "firewall": {
    "node": "site-a-fw-1",
    "pair": {
      "primary": {
        "name": "site-a-fw-1",
        "atypical_interfaces": [
          { "name": "ae0", "role": "fabric",
            "fabric_options": { "member_interfaces": ["ge-0/0/0"] } },
          { "name": "ge-0/0/1", "role": "control" }
        ]
      },
      "secondary": {
        "name": "site-a-fw-2",
        "atypical_interfaces": [
          { "name": "ae0", "role": "fabric",
            "fabric_options": { "member_interfaces": ["ge-0/0/0"] } },
          { "name": "ge-0/0/1", "role": "control" }
        ]
      }
    },
    "zones": [
      { "name": "WAN", "interfaces": ["ge-0/0/1.0", "ge-7/0/1.0"] },
      { "name": "LAN", "interfaces": ["ge-0/0/2.0", "ge-7/0/2.0"] }
    ],
    "policies": [
      {
        "from_zone": "LAN", "to_zone": "WAN",
        "rules": [
          { "name": "DEFAULT", "action": "permit", "application": "any",
            "source_address": "any", "destination_address": "any" }
        ]
      }
    ]
  }
}
```

既存フィールド (`node-type`, `static-route`, `prefix`, `flag`) との混在を防ぐため、
FW 関連データは `firewall` キー配下にまとめる。

非 FW ノードの `to_data` では `firewall` キーを出力しない
(`MddoL3NodeAttribute#to_data` をオーバーライドして実現)。

---

### TP の zone フィールド: 不採用

TP 側に `zone: String` を持たせる案を検討したが不採用。

**理由:** ゾーン所属は `zones[].interfaces` から辿れるため冗長になる。
管理の一元化を優先し、ゾーン情報はノード側のみで持つ。

---

### FW ノード識別: `flags` のみ使用

`node_type: 'firewall'` とする案もあったが不採用。

**理由:** `node_type` は L3 トポロジ上の役割 (`'node'`/`'segment'`) を表す。
FW はあくまで `'node'` ロールであり、FW 識別は `flags: ['firewall']` で行う。

---

### クラスタペア情報 (2026-09-11 改訂、2026-09-20 再改訂)

HA クラスタの情報を `pair` 単一オブジェクトで保持する。
`pair` はプライマリ・セカンダリの 2 ノードを直接持ち、それぞれが非典型インタフェース
(`atypical_interfaces`) リストを持つ。

**atypical_interfaces の role:**
- `'fabric'`: HA クラスタのファブリックリンク。`fabric_options` を持つ
- `'control'`: HA クラスタの制御リンク。`fabric_options` は出力しない

**`fabric_options` の条件出力:**
`role == 'fabric'` のときのみ `fabric_options` キーを `to_data` / `topo_data` に含める。
`MddoL3FirewallAtypicalInterface#to_data` がこの制御を担う。

---

### クラス構造

```
MddoL3NodeAttribute
  └── firewall: MddoL3Firewall                          (ext key: 'firewall', default: {})
        ├── node: String                                 (ext: 'node')
        ├── pair: Hash (raw)                             (ext: 'pair')  ← MddoL3FirewallClusterPair 構造を raw Hash として保持
        │     ├── primary: MddoL3FirewallClusterNode
        │     │     └── atypical_interfaces: Array<MddoL3FirewallAtypicalInterface>  (ext: 'atypical_interfaces')
        │     │           ├── name: String
        │     │           ├── role: String  ('fabric' | 'control')
        │     │           └── fabric_options: MddoL3FirewallFabricOptions  (role='fabric' のみ出力)
        │     │                 └── member_interfaces: Array<String>
        │     └── secondary: MddoL3FirewallClusterNode  (primary と同構造)
        ├── zones: Array<MddoL3FirewallZone>             (ext: 'zones')
        │     └── name, interfaces                       (interfaces ext: 'interfaces')
        └── policies: Array<MddoL3FirewallPolicy>        (ext: 'policies')
              ├── from_zone (ext: 'from_zone'), to_zone (ext: 'to_zone')
              └── rules: Array<MddoL3FirewallPolicyRule> (ext: 'rules')
                    (name, action, application, source_address, destination_address)
```

---

### 未決事項

- **diff 対応:** 現状 `MddoL3Firewall` は `Diffable` を include していない。
  将来的に diff 対応が必要な場合は `include Diffable` を追加する必要がある。
- **application フィールドの型:** 現状フリーテキスト。将来的に列挙型化の可能性がある。
- **クラスタペアの整合性検証:** `primary`/`secondary` に対応するノードの存在確認は未実装。

---

## L3 term-point の FHRP (VRRP/HSRP) 属性 (2026-10)

### 背景

インタフェースに設定された VRRP/HSRP の情報 (グループ ID、仮想 IP、priority など) を、
トポロジモデルの L3 term-point に持たせる必要が生じた。入力は Batfish の `vrrpProperties` / `hsrpProperties`
(インタフェース × グループ単位の表) で、playground の `docs/work/plans/fhrp_termination_point_attributes.md` に全体計画がある。

### 採用方針

| 検討項目 | 採用 | 理由 |
|---|---|---|
| 置き場所 | 既存の `mddo-topology:l3-termination-point-attributes` に `fhrp` キーを追加 | FHRP は「そのインタフェース上のグループ」の情報で、L3 の term-point に紐づく。専用の名前空間 (`*-attributes`) を増やす理由が薄い |
| VRRP と HSRP | キーを分けず `fhrp` に統合し、要素内の `protocol` で区別 | 両者でパラメータに差がない。差が出ても要素に任意キーを足せば拡張できる |
| 空のとき | `fhrp` キー自体を出力しない | FHRP を持たない既存の topology.json に差分を出さない (`firewall` キーと同じ方針) |
| キー名 | kebab-case (`group-id`, `virtual-address`, `source-address`) | 同じ term-point 属性の既存キー (`ip-address` 等) に合わせる |
| `source-address` | 残す | term-point が複数の IP アドレスを持つとき、どのアドレスに属するグループかを示せる |

### 構造

```
MddoL3TPAttribute
  └── fhrp: Array<MddoFhrp>                 (ext key: 'fhrp', default: [])
        ├── protocol: String                (ext: 'protocol')          'vrrp' | 'hsrp'
        ├── group_id: Integer               (ext: 'group-id')          文字列入力は to_i
        ├── virtual_addresses: Array<String>(ext: 'virtual-address')
        ├── priority: Integer               (ext: 'priority')          文字列入力は to_i
        ├── preempt: Boolean                (ext: 'preempt')
        ├── source_address: String          (ext: 'source-address')
        └── active: Boolean                 (ext: 'active')
```

- クラス名は `MddoFhrp` (Topology/DSL 同名)。`fhrp` は JSON キーとしてプロジェクトで決めた名称で、
  「略語を使わない」規約の例外とする。
- PseudoDSL の属性 Hash では `fhrp:` (キー名そのまま) の配列として渡す。要素は `MddoFhrp` DSL のキーワード引数。
  `Netomox.convert_attr_topo2dsl` では、配列の `virtual-address` が `PLURAL_ATTR_KEY_TABLE` により `virtual_addresses` になる。
  `fhrp` 自体は配列でも複数形に変換しない。
- diff: `MddoL3TPAttribute` は `Diffable` を include していない。属性の比較 (`compare_attribute`) は
  `to_data` の Hashdiff なので、`fhrp` の追加・削除・変更は検出される。配列は位置で比較されるため、
  要素の並び順が変わると変更として検出される。

### 未決事項

- `(protocol, group-id)` の一意性検証は未実装。
- `protocol` の値の検証 (`vrrp`/`hsrp` 以外の拒否) は未実装。

