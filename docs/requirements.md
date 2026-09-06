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
- FW ノードは HA クラスタのプライマリ・セカンダリ名を保持できること
- フィールド: `firewall.pair.primary` (String), `firewall.pair.secondary` (String)

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
| R2 | `MddoL3FirewallPair` | `MddoL3FirewallPair` |
| R3 | `MddoL3FirewallZone` | `MddoL3FirewallZone` |
| R4 | `MddoL3FirewallPolicy`, `MddoL3FirewallPolicyRule` | 同左 |
| R2–R4 コンテナ | `MddoL3Firewall` | `MddoL3Firewall` |
| R5 | `MddoL3NodeAttribute#to_data` (オーバーライド) | `MddoL3NodeAttribute#topo_data` (条件出力) |
