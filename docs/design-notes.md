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
