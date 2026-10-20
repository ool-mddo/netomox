# Netomox 機能要求

## FW ノード情報の管理 (v0.12)

### 対象

MDDO L3 ネットワーク (`mddo-topology:l3-network`) 上のファイアウォールノード。
FW 情報は機器単位の外部 JSON ファイル (`site-a-fw-1.json` 等) として別途提供され、
netomox のデータコンテナがその情報を保持できることを要求する。

---

### 機能要求

**R1: FW ノードの識別**
- L3 ノードが FW であることを `flags` フィールドで識別できること
- 識別フラグ値: `'firewall'`
- `node_type` は変更しない (`'node'` のまま)

**R2: クラスタペア情報**
- FW ノードは HA クラスタのペア情報を `pair` 単一オブジェクトで保持できること
- ペアはプライマリ・セカンダリのノード情報を持つこと
- 各ノードはノード名 (`name`) と非典型インタフェースリスト (`atypical_interfaces`) を持つこと
- 各非典型インタフェースはインタフェース名 (`name`)、役割 (`role`: `'fabric'` または `'control'`)、
  ファブリック固有オプション (`fabric_options`、`role == 'fabric'` のときのみ) を持つこと
- `fabric_options` はメンバインタフェース名リスト (`member_interfaces`) を持つこと

**R3: セキュリティゾーン定義**
- FW ノードは複数のセキュリティゾーンを定義できること
- 各ゾーンはゾーン名とそのゾーンに所属するインタフェース名リストを持つこと
- フィールド: `firewall.zones[].name`, `firewall.zones[].interfaces`

**R4: ゾーン間セキュリティポリシー**
- FW ノードはゾーン間のセキュリティポリシーを定義できること
- ポリシーは送信元ゾーン・宛先ゾーンごとにルールリストを持つこと
- 各ルールは以下のフィールドを持つこと:
  - `name`: ルール名
  - `action`: `'permit'` または `'deny'`
  - `application`: アプリケーション識別子 (例: `'any'`, `'http'`)
  - `source_address`: 送信元アドレスまたは `'any'`
  - `destination_address`: 宛先アドレスまたは `'any'`

**R5: 後方互換性**
- FW 情報を持たない既存の L3 ノードの `to_data` 出力に `firewall` キーが追加されないこと
- 既存のテスト・既存のトポロジ JSON との互換性を維持すること

**R6: DSL からの構築**
- `Netomox::DSL` を使って FW ノードを構築し、RFC8345 形式の JSON を出力できること
- `Netomox::Topology` を使って FW ノードの JSON をパースし、Ruby オブジェクトとして操作できること

---

### 実装クラス対応

| 要求 | Topology クラス | DSL クラス |
|---|---|---|
| R1 | `MddoL3NodeAttribute#flags` (既存) | 同左 |
| R2 | `MddoL3FirewallClusterPair`, `MddoL3FirewallClusterNode`, `MddoL3FirewallAtypicalInterface`, `MddoL3FirewallFabricOptions` | 同左 (DSL キーワード: `node:`, `pair:`) |
| R3 | `MddoL3FirewallZone` | `MddoL3FirewallZone` |
| R4 | `MddoL3FirewallPolicy`, `MddoL3FirewallPolicyRule` | 同左 |
| R2–R4 コンテナ | `MddoL3Firewall` | `MddoL3Firewall` |
| R5 | `MddoL3NodeAttribute#to_data` (オーバーライド) | `MddoL3NodeAttribute#topo_data` (条件出力) |

---

## L3 term-point の FHRP (VRRP/HSRP) 情報の管理 (v0.14)

### 対象

MDDO L3 ネットワーク (`mddo-topology:l3-network`) の term-point 属性
(`mddo-topology:l3-termination-point-attributes`)。
インタフェースに設定された FHRP (First Hop Redundancy Protocol: VRRP / HSRP) のグループ情報を保持する。

### 機能要求

**R1: FHRP グループ情報の保持**
- term-point 属性は `fhrp` (配列) で FHRP グループ情報を保持できること
- 1 要素が 1 グループ (インタフェース × グループ)。VRRP と HSRP は `protocol` で区別し、同じ配列に併存できること
- 1 term-point 内で `(protocol, group-id)` は一意とする (一意性の検証は netomox では行わない)

**R2: グループ情報のフィールド**

| フィールド (JSON キー) | 型 | 内容 |
|---|---|---|
| `protocol` | String | `'vrrp'` または `'hsrp'` |
| `group-id` | Integer | グループ ID (文字列入力は整数に変換する) |
| `virtual-address` | Array of String | 仮想 IP アドレス |
| `priority` | Integer | 優先度 (文字列入力は整数に変換する) |
| `preempt` | Boolean | プリエンプトの有無 |
| `source-address` | String | グループを持つインタフェースの IP アドレス/プレフィックス長 |
| `active` | Boolean | グループが有効か |

**R3: 後方互換性**
- FHRP 情報を持たない term-point の `to_data` / `topo_data` 出力に `fhrp` キーが追加されないこと
- `description`, `ip-address`, `flag` の既存の挙動を変えないこと

**R4: DSL からの構築**
- `Netomox::DSL` で `attribute(fhrp: [{ protocol: 'vrrp', group_id: 1, ... }])` のように構築できること
- `Netomox::Topology` で `fhrp` を持つ JSON をパースし、`MddoFhrp` オブジェクトとして操作できること

**R5: 変換・差分**
- Topology → PseudoDSL 属性変換 (`Netomox.convert_attr_topo2dsl`) で `fhrp` が保持されること
  (`virtual-address` は `virtual_addresses` に変換される)
- トポロジ差分 (`diff`) で `fhrp` の追加・削除・変更が検出されること

### 実装クラス対応

| 要求 | Topology クラス | DSL クラス |
|---|---|---|
| R1–R2 | `MddoFhrp` (`MddoL3TPAttribute#fhrp` の要素) | `MddoFhrp` |
| R1–R2 コンテナ | `MddoL3TPAttribute#fhrp` | `MddoL3TPAttribute#fhrp` |
| R3 | `MddoL3TPAttribute#to_data` (オーバーライド) | `MddoL3TPAttribute#topo_data` / `#empty?` (条件出力) |
| R5 | `Netomox::PLURAL_ATTR_KEY_TABLE` (`virtual_address`) | - |

