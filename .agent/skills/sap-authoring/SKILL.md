---
name: sap-authoring
description: Generates a reproducibility-focused Statistical Analysis Plan (SAP) document with BMJ Open code-review framework, Decision log, and traceability to Gate IDs.
---
# SAP Authoring — 再現性重視の解析計画書スキル

BMJ Open の「再現可能な解析コード」論文（PMC12496075）と Zenodo 付録の R Markdown 実例を踏まえ、再現性・透明性・コードレビュー前提の SAP を対話的に作成する。

> [!IMPORTANT]
> SAP は実装前の合意文書。統計的判断はユーザーに確認し、AIが勝手に確定しない。

## ワークフロー上の位置づけ

```
analysis-intake → ★ sap-authoring → analysis-hitl-plan → code → code-review-companion
（情報収集）      （SAP文書作成）    （Gate実装計画）    （実装）   （検証アーティファクト）
```

- `analysis-intake` で収集した情報を SAP の各セクションに配置する
- SAP 完成後、`analysis-hitl-plan` で Gate ID (`G<gate>-<seq>`) を付与し実装に進む
- `code-review-companion` は SAP の項目 → コード行のトレーサビリティを検証する

## 出力ファイル

| ファイル                         | 場所                                      | 用途                                |
| -------------------------------- | ----------------------------------------- | ----------------------------------- |
| `statistical_analysis_plan.md` | `<appDataDir>/brain/<conversation-id>/` | SAP 本体（artifact としてコメント・レビュー可能） |
| `code_review_checklist.md`     | `{project}/docs/`                        | 付録A: コードレビューチェックリスト |

`{project}` = `projects/<analysis_name>/`

> [!IMPORTANT]
> `statistical_analysis_plan.md` は `write_to_file` ツールで **`IsArtifact: true`**, **`ArtifactType: "other"`** として出力すること。
> これによりユーザーが UI 上でコメント・レビューを行える。
> レビュー・承認完了後、確定版を `{project}/docs/` にコピーする。

## 作成手順

### Step 1: 前提確認

1. `analysis-intake` の情報が揃っているか確認（不足時はまず intake を実施）
2. 研究デザイン（探索的／検証的）を確認 — SAP の詳細度を調整するため
3. 対象ジャーナル・ガイドライン（STROBE, CONSORT 等）を確認

### Step 2: セクション別にユーザーと対話して埋める

各セクションをユーザーに提示し、選択肢・メリット/デメリットを示しながら合意を取る。
一度にすべてを埋める必要はない — 反復的に精度を上げる。

### Step 3: Gate ID の付与

SAP の各解析項目に `analysis-hitl-plan` と整合する Gate ID を付与する。
（例: § 9.2 の主要モデル → `G2B-1`）

### Step 4: Decision log の初期化

SAP 内に Decision log セクションを設け、今後の計画変更を記録する枠を準備する。

### Step 5: レビュー・承認

SAP を artifact としてユーザーに提示し（`notify_user` で `PathsToReview` に指定）、版数・承認者を記録する。
ユーザーは artifact 上でコメントを付けてフィードバックできる。

### Step 6: 確定版のコピー

レビュー完了・承認後、artifact の `statistical_analysis_plan.md` を `{project}/docs/statistical_analysis_plan.md` にコピーし、プロジェクト内に確定版を保存する。

---

## SAP テンプレート構造

以下のセクション構造で `statistical_analysis_plan.md` を生成する。

### § 0. 文書情報（Document control）

```markdown
## 0. 文書情報

- 研究タイトル：
- 研究ID（任意）：
- 解析計画書タイトル：
- 版数：v0.1
- 作成日：YYYY-MM-DD
- 作成者：
- レビュー担当（コードレビュー担当を含む）：
- 承認者：

### 変更履歴

| 版数 | 日付 | 変更内容 | 理由 |
|------|------|---------|------|
| v0.1 | YYYY-MM-DD | 初版 | — |
```

> 変更は「変更履歴」と「Decision log（§ 13.4）」に残し、コード側にも注釈として残す。

### § 1. 背景（Background）

- 疾患・領域背景
- 既存エビデンスの要点
- なぜこの解析が必要か
- 本研究の位置づけ（探索的／検証的）

### § 2. 研究目的・仮説（Objectives and hypotheses）

- 主目的（Primary objective）
- 副目的（Secondary objectives）
- 仮説（方向性も明示）
- 事前に決める主要解析の位置づけ
- 主要な判断基準（臨床的に意味のある差、最小重要差：任意）

### § 3. 研究デザインとデータ（Study design and data source）

- デザイン（横断／コホート／症例対照／介入／二次利用等）
- データソース（名前、バージョン、抽出日、取得方法）
- 観察期間・追跡期間・インデックス日
- サンプリング設計や重み（該当時）
- 解析対象の範囲（地理・施設・集団）

> 入力データが何で、どの版かを明示。可能なら抽出クエリ・条件も記録。

### § 4. 解析対象集団（Study population）

- 適格基準（Inclusion criteria）
- 除外基準（Exclusion criteria）
- 解析対象集団の定義（Full analysis set、Per-protocol 等）
- サンプル選択フロー（除外を段階別に人数・理由で記録）

> フローチャート作成のためにカウントも保存する。

### § 5. 変数定義（Variables）

#### 5.1 主要アウトカム（Primary outcome）

- 変数名（データ上のフィールド名）
- 定義（診断コード、測定法、算出法、ウィンドウ等）
- 単位・尺度
- 解析上の扱い（連続／カテゴリ／二値／time-to-event 等）

#### 5.2 副次アウトカム（Secondary outcomes）

#### 5.3 曝露・介入・説明変数（Exposure/Index）

- 定義、測定タイミング
- カテゴリ化する場合の閾値（事前規定）

#### 5.4 共変量（Covariates）

- 交絡候補（理論・先行研究・DAG 等の根拠）
- 調整セット（最小調整、拡張調整の案）
- 効果修飾（effect modifier）候補

#### 5.5 データ辞書（Data dictionary）

- 変数名、説明、型、符号化、欠測コード、単位、取り得る範囲
- 置き場所：`{project}/docs/data_dictionary.csv` または `.md`

> 変数名やラベルを一貫させ、コードの見出し番号を原稿・SAP のセクションに対応させる。

### § 6. データハンドリング（Data processing plan）

#### 6.1 データ取得

- 取得手順（クエリ、API、ファイル）、結合キー、マージ種別、重複処理

#### 6.2 クリーニング

- 異常値・範囲外値の扱い（ルール）
- 重複・複数レコードの統合ルール
- 派生変数の算出（アルゴリズムは付録へ）

#### 6.3 欠測（Missing data）

- 欠測の定義（NA、特定コード等）
- 欠測の記述（割合、パターン）
- 対応方針（complete-case、補完、重み付け等）
- 欠測処理の感度解析（§ 12 で詳述）

#### 6.4 除外の記録

- 除外を段階別に「人数・理由・コード上の箇所」で記録する

### § 7. 統計原則（Statistical principles）

- 有意水準（例：両側 0.05）／信頼区間
- 多重比較の扱い
- 推定と解釈の優先度（p 値より効果量）
- 解析の重み付け・クラスタ・層別（該当時）
- ソフトウェアと乱数シード（再現性のために固定）

### § 8. 記述統計・探索（Descriptive and exploratory analyses）

- ベースライン（Table 1 相当）：連続は平均(SD)/中央値(IQR)、カテゴリは n(%)
- 分布の可視化（ヒストグラム、箱ひげ、散布図等）
- 変数変換の候補（log、平方根等）
- 外れ値の定義と扱い（感度解析に回す等）

### § 9. 主要解析（Primary analysis）

#### 9.1 推定したい量（Estimand/Target）

- 推定量（平均差、OR、HR、RD 等）と解釈単位

#### 9.2 モデル

- 主要モデル（線形、ロジスティック、Cox、混合効果等）
- 共変量調整
- 推定方法（最尤、GEE、ロバスト SE 等）
- 非線形・交互作用の追加仕様

#### 9.3 前提・診断（Assumption checks）

- モデル前提（線形性、等分散性、残差分布、比例ハザード等）
- 診断方法（プロット、検定、残差解析）
- 前提が怪しい場合の事前対応案

> `analysis-guardrails` と `analysis-hitl-plan` の必須/推奨チェック体系と整合させること。

#### 9.4 出力（Tables/Figures）

- Table 2：主要推定値（効果量、95%CI、p 値）
- Figure：主要関係の可視化
- どの出力が原稿のどこに対応するかを事前マッピング

### § 10. 副次解析（Secondary analyses）

- 解析1〜N を列挙（事前規定できない探索は「探索的」と明示）

### § 11. サブグループ解析（Subgroup analyses）

- 事前に限定して列挙（性別、年齢層、併存疾患等）
- 交互作用で評価か、層別で評価か
- 解釈の注意（多重性、検出力不足）

### § 12. 感度解析（Sensitivity analyses）

- 外れ値除外
- アウトカム定義・暴露定義の代替
- 欠測対応の代替（complete-case vs 補完等）
- モデル仕様の代替（ロバスト SE、別リンク関数等）
- 解析集団の代替（除外基準を緩める／厳しくする）

### § 13. 再現性・コード運用（Reproducibility plan）

> BMJ Open 論文の5提案を実装可能な形に落としたセクション。

#### 13.1 優先度・体制（Time/resources）

- 再現性確保の作業（README、辞書、テスト、レビュー）
- 担当者と締切
- 事前登録（必要時）

#### 13.2 バージョン管理（Version control）

- Git ブランチ運用・タグ・リリース
- 最終版コミット ID
- R/Python・主要パッケージのバージョン記録

#### 13.3 コード構造（Comprehensibility）

- README 必須項目（データ概要、フォルダ構造、実行手順、想定出力）
- 見出し番号付け（SAP のセクション/表/図と対応）
- 変数命名規則、データ辞書の場所
- 関数化・ループ化の方針（可読性を損なわない範囲）

> `output-and-naming-standards` スキルの規約に準拠すること。

#### 13.4 透明性・Decision log

データクリーニング・サンプル選択・除外の理由をコード内に注釈として残す。

```markdown
### Decision log

| # | 日付 | 変更点 | 理由 | 影響評価 | 実装箇所（ファイル・行・コミット） |
|---|------|--------|------|---------|--------------------------------|
| 1 | | | | | |
```

#### 13.5 コードレビュー（Code review）

- レビュータイミング（主要解析前、最終出力前）
- レビュー担当者
- レビュー手順（チェックリストは `code_review_checklist.md`）
- ユニットテスト・品質チェック

> `code-review-companion` スキルの検証アーティファクト（逆翻訳・トレーサビリティ表・QA レポート）と連動。

#### 13.6 共有・アクセシビリティ（Sharing）

- コード・データの共有方法（GitHub/Zenodo/機関リポジトリ）
- DOI 付与
- ライセンス（CC BY、MIT 等）
- データ共有が難しい場合：コード共有 + メタデータ + アクセス手順

### § 14. 参考文献（References）

- ガイドライン（STROBE 等）、統計手法の根拠文献、データ辞書 URL

---

## 付録A: コードレビューチェックリスト

SAP 作成時に `code_review_checklist.md` も同時に生成する。

### A1 再現性：透明性（Transparency）

- [ ] 版管理がある（Git、またはソフト・パッケージ版を記録）
- [ ] 入力データが明確（どのデータ、どの版、抽出条件）
- [ ] README がある（フォルダ構造、実行方法、変数の符号化）
- [ ] クリーニング手順がコードに記録されている
- [ ] サンプル選択が段階別に記録されている（人数と理由）

### A2 再現性：可読性（Comprehensibility）

- [ ] SAP／原稿の構造に沿ってコードが並んでいる（見出し・番号）
- [ ] 第三者が理解しやすい（コメント、直感的命名、辞書）
- [ ] 繰り返しが関数・ループ化されている（読みにくくしない）

### A3 概念的正しさ（Conceptual correctness）

- [ ] コードの目的（研究目的／SAP）が冒頭に書かれている
- [ ] SAP に書いた統計手法がすべて実装されている
- [ ] エラーなく実行できる（クリーン環境でも）
- [ ] 各コードブロックの目的が明確（コメント、Markdown 等）
- [ ] 自作関数や重要処理にテストがある

---

## 付録B: 推奨フォルダ構成

SAP 作成時にプロジェクトのフォルダ構成も確認・提案する。

```
{project}/
├── README.md
├── analysis_plan.md              ← Gate ID 付き（analysis-hitl-plan 用）
├── verification_config.yml       ← code-review-companion 用
├── data/
│   ├── raw/                      ← 生データ（共有不可なら非公開）
│   └── processed/
├── docs/
│   ├── statistical_analysis_plan.md  ← SAP 本体
│   ├── code_review_checklist.md      ← 付録A
│   ├── data_dictionary.csv           ← データ辞書
│   └── decision_log.md              ← 独立 Decision log（任意）
├── scripts/
│   ├── _project_config.R
│   ├── 00_setup.R
│   ├── 01_data_acquisition.R
│   ├── 02_cleaning.R
│   ├── 03_descriptives.R
│   ├── 04_primary_analysis.R
│   ├── 05_secondary_sensitivity.R
│   ├── 06_outputs.R
│   ├── run_all.R
│   └── 99_verify_data.R
├── tests/                        ← ユニットテスト
└── output/
    ├── figures/
    ├── tables/
    └── verification/
```

---

## 他スキルとの連携

| 連携先スキル                    | 連携内容                                                                                             |
| ------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `analysis-intake`             | intake で収集した情報を SAP の §1-5 に配置                                                          |
| `analysis-hitl-plan`          | SAP の §9-12 の解析項目に Gate ID を付与して `analysis_plan.md` を生成                            |
| `analysis-guardrails`         | SAP §9.3 の前提チェックが guardrails の必須/推奨チェックと整合しているか確認                        |
| `output-and-naming-standards` | SAP §13.3 のコード構造・命名規約が standards と一致しているか確認                                   |
| `code-review-companion`       | SAP §13.5 のレビュー手順が verification workflow と連動。SAP の Gate ID → コードのトレーサビリティ |
| `data-privacy-handling`       | SAP §14 の倫理・ガバナンスがプライバシー取扱と整合しているか確認                                    |

---

## 注意事項

- SAP は「生きた文書」— 版数管理と Decision log で変更を追跡する
- 探索的研究でも SAP を書く。詳細度は下げてよいが、構造は維持する
- 事前登録（OSF 等）が求められる場合は、SAP の凍結版を登録する
- 参考文献:
  - BMJ Open (PMC12496075): https://pmc.ncbi.nlm.nih.gov/articles/PMC12496075/
  - Zenodo 付録: https://zenodo.org/records/16562233
