# 知識グラフ駆動スライド生成 仕様 v0.1

対象: `SourceVault_knowledgegraph.wl` (新設) / `SlideWorkflow.wl` (v1.20 拡張) /
`SourceVault.wl` (ロード登録) / `SourceVault_kb.wl` (過去デッキ再利用) /
`SourceVault_oopsseed.wl` (グラフ描画の再利用)

作成: 2026-09-13

---

## 1. 動機

論文紹介スライド (例: 計算と自然 33 = Strong, Holderbaum, Hayashi 2024) は、これまで
「プロンプト → LLM が md を書く → 適用」の 1 回限りの生成だった。次の要求はこの方式では
満たせない。

1. 説明のストーリーが明示的に規定され、各スライドがそれに従う。
2. 聴き手の理解度・前提知識 (資格・領域) によって内容が変わる。
3. 発表時間 (枚数) によって内容が再配置・削減される。
4. 論文 A・B のそれぞれのスライドを作った後、「A と B のサーベイを 20 枚で」と言うだけで
   合成される。

生成物を **スライドではなく知識グラフ (KG)** にし、スライドは KG の「聴き手 × 時間」への
投影として決定的に計算する。LLM は (a) KG の抽出、(b) 周辺知識ノードの追加、
(c) 概要・原稿の推敲、(d) ノード単位の翻訳、の 4 か所にだけ使う。

## 2. 責務分界

| 層 | 責務 |
|---|---|
| `SourceVault_knowledgegraph.wl` (`SourceVault``, private `` `KGPrivate` ``) | KG のデータモデル・検証・保存、聴き手モデル、順序木、詰め込み/枝刈り、言語別アウトライン、複数 KG 合成、共有 background 層、プロンプト (純関数)、Graph 投影、View。**LLM も FrontEnd も呼ばない** |
| `SlideWorkflow.wl` (`SlideGraph*`, v1.20) | デッキとの接合: Story セル (聴き手/枚数/時間/言語) の読み取り、References から KG 抽出タスクをエージェントへ委譲、KG → シナリオ md + 図資産の実体化 (`SlidePDFFigure` / `SlideNotebookFormula` / `SlideNotebookFigure` / `SlideDeckFigure`)、デッキへの適用 (`SlideDeckInsertScenario` / `SlideDeckBuild`)、パレット |
| `SourceVault_kb.wl` | 周辺知識ノードに対する過去デッキ (KB "cn") の引用候補検索 (弱結合) |
| `SourceVault_oopsseed.wl` | `SourceVaultKGToTopicItemGraph` で同形に投影し `SourceVaultOOPSTopicGraphPlot` を再利用 |

原則: **KG は SourceVault の管轄、スライドは SlideWorkflow の管轄**。SourceVault 層は
md を「文字列と資産指定」までしか作らず、図の実体化・セルの書き込みは SlideWorkflow が行う。

## 3. データモデル (oops-ml 由来の辺レコードを踏襲)

### 3.1 KG

```
<|"ObjectClass" -> "SourceVaultKnowledgeGraph", "SchemaVersion" -> 1,
  "GraphId" -> "shh2024", "Title" -> ..., "Kind" -> "Paper" | "Survey" | "Background",
  "Language" -> "ja", "Sources" -> {<|"Key", "Locator", "Kind", "Note"|>..},
  "PrivacyLevel" -> 0.0, "Root" -> nodeId, "Nodes" -> {..}, "Edges" -> {..},
  "Warnings" -> {..}, "UpdatedAtUTC" -> ..|>
```

保存: `<SourceVaultCoreRoot>/knowledgegraph/graphs/<graphId>.json` (atomic tmp+rename、
前版は `graphs/history/` へ退避)。UTF-8 単一エンコード (slidedeck.wl と同じ ExportByteArray /
ReadByteArray)。順序木・計画は再計算可能な派生物なので保存しない。

### 3.2 ノード

```
<|"Id", "Kind" (Claim|Concept|Definition|Method|Experiment|Result|Equation|Figure|Question|
   Conclusion|Background|Section|Survey),
  "Label" | "Summary" | "Talk" | "Cite" -> String | <|"ja" -> .., "en" -> ..|>,
  "Points" -> {..} | <|lang -> {..}|>,
  "Difficulty" 0-1 (0=常識, 0.3=高校, 0.5=学部, 0.7=大学院, 0.9=専門家),
  "Importance" 0-1 (主張を伝えるのに欠かせない度合い),
  "Domains" -> {"電気化学", ..}, "Year" -> 2024 | None, "Order" -> 出現順,
  "Layer" -> "Paper" | "Background" | "Shared", "BackgroundRef" -> "bg:<slug>" | None,
  "Assets" -> {<|"Type" -> "NotebookFigure"|"Formula"|"PDFFigure"|"DeckSlide"|"Image"|"Table", ..|>},
  "Source" -> <|..|>, "Aliases" -> {..}, "PrivacyLevel" -> 0.0|>
```

テキストは言語別の連想を持てる。**翻訳はノード単位** (`SourceVaultKGMerge[kg, delta,
"Language" -> "en"]`) で、アウトライン化の `"Language"` で言語を選ぶ。デッキのセル単位英訳
(`SlideTranslate`) や documentation.wl の翻訳とは独立 (仕様要件「直交」)。

### 3.3 辺 (oopsseed TopicItemGraph と同形 + 順序)

```
<|"From", "To", "EdgeKind", "Weight" 0-1 (関連度), "Confidence", "Order" -> True|False,
  "OrderKind" -> Difficulty|Temporal|Derivation|Narrative|Causal|Hierarchy|None, "EvidenceRefs"|>
```

**順序制約のある種別はすべて「From を To より先に提示する」向き** (`$SourceVaultKGEdgeKinds`):

| EdgeKind | Order | OrderKind | 階層化の親 | 意味 |
|---|---|---|---|---|
| Prerequisite | ✓ | Difficulty | From | From は To の前提 (Lagrangian の後に F=ma が来ない) |
| Precedes | ✓ | Temporal | From | 年代・実験の順 |
| Derives | ✓ | Derivation | From | To は From から導かれる |
| Motivates | ✓ | Narrative | From | 問い → 手法 |
| LeadsTo | ✓ | Causal | From | 結果 → 結論 |
| Contains | ✓ | Hierarchy | From | 節が下位を含む |
| Supports / Explains | – | – | To | 証拠・解説は主張の下に |
| Contrasts / RelatedTo / Cites | – | – | Either | 関連度のみ |

未知の種別は RelatedTo に丸めて `Warnings` に残す。端点の無い辺・自己ループは落とす。

## 4. パイプライン (I〜VI)

| 段 | 関数 | 決定的か |
|---|---|---|
| I 抽出 | `SourceVaultKGExtractionPrompt` → (LLM) → `SourceVaultKGFromJSON` | プロンプトと検証は決定的 |
| II 周辺知識 | `SourceVaultKGBackgroundPrompt` → (LLM) → `SourceVaultKGMerge`; `SourceVaultKGBackgroundLink` (共有層と照合・登録); `SourceVaultKGSuggestPastSlides` (KB) | 照合・登録は決定的 |
| III 順序木 | `SourceVaultKGOrderGraph` (循環切断) → `SourceVaultKGLinearOrder` (戦略別線形拡張) → `SourceVaultKGOrderedTree(s)` | ✓ |
| IV 概要と検証 | `SourceVaultKGLevelSummaries` / `SourceVaultKGVerify`; `SourceVaultKGSummaryPrompt` (LLM で磨く) | 検証は決定的 |
| V 詰め込み・枝刈り | `SourceVaultKGScores` (聴き手) → `SourceVaultKGPlan` → `SourceVaultKGVerifyPlan` | ✓ |
| VI シリアライズ | `SourceVaultKGOutline` (言語別) → `SourceVaultKGOutlineToMarkdown` → SlideWorkflow が図を実体化して適用; `SourceVaultKGTalkPrompt` (原稿推敲) | md 生成は決定的 |

### 4.1 III の算法 (最小全域順序木 = 線形拡張の階層分割)

1. 順序辺だけの有向グラフを作り、循環があれば **最も弱い辺** (Weight×Confidence) から切る
   (`Dropped` に記録)。Root へ入る順序辺も落とす (Root は必ず先頭)。
2. Kahn 法で線形拡張 L を作る。ready 集合からの選択規則が戦略:
   `Source` (論文の出現順) / `Importance` / `Difficulty` (易→難) / `Coherent` (直前ノードとの関連度)。
3. **右背骨貪欲**: L を順に走査し、各ノードの親を「現在の右背骨 (root から直前ノードまでの
   経路) 上のノード」の中から親和度 (Weight × 種別係数 − 深さペナルティ) 最大で選ぶ。
   親和度 0 なら root に付けて新しい部を始める。深さ上限 `MaxDepth` (既定 3)。

この構成では **部分木が L の連続区間**になり、木の前順走査 = L (トポロジカル順) が
自動的に成り立つ。複数候補 = 戦略の違い (`SourceVaultKGOrderedTrees` は Score 降順)。
CKY 型の区間 DP (厳密最適) は将来の置換候補 (同じ「区間の階層分割」の枠内で差し替え可能)。

### 4.2 V の算法 (聴き手 × 時間)

聴き手 `SourceVaultKGAudience[spec]`: プリセット (小学生 / 中学生 / 高校生 / 大学理系学部卒 /
大学院生 / 研究者 / ITエンジニア / ネットワークエンジニア / 基本情報技術者 / 高校数学III /
一般相対論 / 電気化学 / 機械学習 …) と `領域=理解度` の併記。
`"高校生, 電気化学=0.3, 高校数学III"` のように書く。未知の語は「知っている領域 (0.7)」として扱い
`Unknown` に残す。

- `known(v)` = ノードの Domains と一致する聴き手の理解度の最大 (無ければ主題の理解度 Level)。
- `need(v)` = Difficulty − known。**need ≤ 0 の周辺知識ノードは Assumed (既知) として落とす**。
- `score(v)` = Importance × (論文ノードなら 1、周辺知識なら clip(need))。need > 0.6 は TooHard で半減。
- 枚数 N (= `Slides`、または `Seconds / SecondsPerSlide`): Root は常に 1 枚、根直下の部
  (depth 1) は N が許す限り必ず 1 枚、残りを score 上位から。閾値 θ = 最後に採った score。
- **詰め込み**: θ 未満でも θ×PackRatio 以上のノードは最寄りの採用先祖スライドの箇条書きへ
  (1 枚 `MaxPackedPerSlide` まで)。
- **前提の修復**: 提示されるノードの Prerequisite / Derives / Motivates 元が落ちていれば
  詰め込む (`Promoted`)。3 回まで反復。
- 秒配分は `1 + 0.25×詰め込み数 + 0.4×図あり` の重みで総秒数を按分。
- privacy: PrivacyLevel > `ReleaseCeiling` (既定 0.5) のノードは fail-closed で `Withheld`。

計画の提示順は L の部分列なので順序制約は自動的に守られる (`SourceVaultKGVerifyPlan` が
詰め込み先も含めて再検証する)。

### 4.3 VI (シナリオ md への投影)

1 枚 = `## Label {expected=秒}` + Points (体言止め) + 詰め込んだ子 (`- 子ラベル` + `  - 子の要点`)
+ 資産 (`<<FIGn>>` / 表 / 画像) + `cite:` + `talk:`。資産の実体化は SlideWorkflow 側:

| Asset Type | SlideWorkflow の実体化 |
|---|---|
| NotebookFigure `{Ref, N}` | `SlideNotebookFigure[Ref, N]` |
| Formula `{Ref, N}` | `SlideNotebookFormula[Ref, N]` (原式を組版のまま) |
| PDFFigure `{Ref, Page, Crop}` | `SlidePDFFigure[Ref, Page, "Crop" -> Crop]` |
| DeckSlide `{Deck, N}` | `SlideDeckFigure[Deck, N]` (過去スライドの引用) |
| Image `{Path}` / Table `{Rows}` | md の `![](path)` / `|` 行 |

`Ref` は References セルの `[key]`。実体化に失敗した資産は落として `Warnings` に残す (md の
`<<FIGn>>` は付番し直す)。

## 5. SlideWorkflow 側 (v1.20)

### 5.1 Story セル (`SlideStory` スタイル、Working 可視 / SlideShow 非表示 / 書き出し・英訳対象外)

```
Graph: shh2024                 ← KG の GraphId (未記入なら Title から自動)
Audience: 大学理系学部卒, 電気化学=0.3
Slides: 20                     ← または Minutes: 15 (SecondsPerSlide で換算)
Language: ja
Strategy: Source               ← Source | Coherent | Importance | Difficulty
Story: 結論ファースト。導電率の式は必ず入れる。   ← 自由記述 (LLM の抽出・推敲プロンプトへ)
```

`SlideGraphSpec[nb]` が読む (Directive セルの `Title:` / `Language:` も併用)。

### 5.2 関数

| 関数 | 役割 |
|---|---|
| `SlideInsertStory[]` | Story セルの雛形を挿入 |
| `SlideGraphSpec[nb]` | Story + Directive から仕様連想 |
| `SlideGraphBuild[nb]` | **エージェントに KG 抽出を委譲** (References の素材を `SlideNotebookOutline/Text` で読み、`SlideGraphIngest[graphId, json]` を呼ぶ ClaudeEval セルを Appendix に書く) |
| `SlideGraphIngest[graphId, json, opts]` | 検証つき取り込み → 保存 (`"Merge"->True` で差分)。**唯一の KG 書き込み口** |
| `SlideGraphBackground[nb]` | 聴き手に足りない周辺知識の追加をエージェントへ委譲 (+ 共有層と連結) |
| `SlideGraphPlan[nb\|graphId, opts]` / `SlideGraphPlanView` | 計画 (決定的) と一覧 |
| `SlideGraphGenerate[nb\|graphId, opts]` | 計画 → アウトライン → md + 図の実体化。`<\|"Markdown", "Figures", "Plan", "Outline", "Warnings"\|>` |
| `SlideGraphApply[nb, opts]` | 生成結果をデッキへ適用 (`"Mode"->"Append"` = 末尾に追加 / `"Polish"->True` = talk の推敲をエージェントに委譲してから適用) |
| `SlideGraphBuildDeck[graphId, "deck.nb", opts]` | KG から新しいデッキファイルを直接生成 (headless 可) |
| `SlideGraphSurvey[{graphIds}, "deck.nb", opts]` | 複数 KG を合成してサーベイデッキ生成 |
| `SlideGraphView[nb\|graphId]` / `SlideGraphTreeView` | KG / 順序木の表示 |

パレット「KG」節: `KG構築` / `周辺知識` / `計画` / `生成` / `ストーリー` / `KG表示`。
エージェント許可 head: `SlideGraphIngest`, `SlideGraphSpec`, `SlideGraphPlan`,
`SlideGraphGenerate`, `SlideGraphApply`, `SlideGraphView` (`$iSWAgentHeads` に追加)。

### 5.3 英訳との直交

- 英語スライド: KG にノード単位の英訳を入れ (`SlideGraphTranslate[nb, "en"]` = エージェント委譲 →
  `SlideGraphIngest[..., "Language"->"en"]`)、`SlideGraphGenerate[..., "Language"->"en"]`。
- 既存のセル単位英訳 (`SlideTranslate`) は生成後のセルに対して従来どおり効く。両者は
  異なる層 (KG テキスト vs セル TaggingRules) を触るので干渉しない。documentation.wl は
  一切呼ばない (SlideWorkflow の従来方針を踏襲)。

## 6. サーベイ (論文 A + B → 20 枚)

`SourceVaultKGCompose[{kgA, kgB}, "Title" -> ..]`: ノード Id を `<graphId>/<id>` にし、
`bg:` の共有 background ノードは 1 つに統合、各論文の Root を `survey` 根の Contains 子に、
論文順 (または `"Chronological"` で Year 順) に Precedes を張り、共有 bg ノードを介した
論文間 RelatedTo を付ける。以後は III〜VI が単一 KG と同じに動く。
`SlideGraphSurvey[{"shh2024", "xyz2023"}, "survey.nb", "Slides" -> 20, "Audience" -> ..]`
が入口。

## 7. 共有 background 層

`<root>/knowledgegraph/background/bg-<slug>.json` (1 ノード 1 ファイル = Dropbox 同期に耐える)。
`SourceVaultKGBackgroundLink[kg]` は Layer Background のノードをラベル/別名の bigram 類似
(≥ 0.6) で照合し、既存なら `BackgroundRef` を張って `Graphs` に追記、無ければ新規登録。
これで「過去論文で ingest 済みの周辺知識ノードへのリンク」が実現し、Compose 時に同一ノードとして
統合される。KB "cn" がロード済みなら `SourceVaultKGSuggestPastSlides` が過去デッキの
該当スライドを引用候補 (DeckSlide 資産) として返す。

## 8. privacy

KG / ノードの `PrivacyLevel` は 0.0-1.0 (大きいほど厳格)。アウトライン化は `ReleaseCeiling`
(既定 0.5) 超を fail-closed で落とす。抽出プロンプトへ渡す本文は SlideWorkflow の
`SlideNotebookText` (NBAccess 経由の許可 head) のみ。background 層には論文由来の公開知識だけを
置く (PrivacyLevel を継承)。

## 9. 検証

- `test codes/SourceVault_knowledgegraph_test.wls` (headless, ASCII): 検証・順序木の
  区間性・戦略候補・聴き手・計画 (枚数/前提修復/privacy)・md・合成・background・保存往復・
  プロンプト・Graph 投影。
- `test codes/slidegraph_test.wls` (headless): Story 解析、資産の実体化、
  `SlideGraphBuildDeck` でデッキ生成 → `SlideDeckOverview` の枚数一致、許可 head、
  スタイル版数。
- NB 実機: 第33回デッキで `KG構築` → `周辺知識` → `計画` → `生成` (ユーザー検証)。

## 10. 未決・将来

- 区間 DP による厳密な最小全域順序木 (現在は右背骨貪欲)。
- 聴き手プリセットの外部化 (SourceVault の curated knowledge と同じ人手レビュー枠)。
- 抽出の LLM 経路をローカルモデル (`SourceVaultQueryLocalLLM`) にも通す (現在はエージェント経路)。
- KG のイベント化 (`SourceVaultAppendEvent`) — 現在はスナップショット JSON + history。
