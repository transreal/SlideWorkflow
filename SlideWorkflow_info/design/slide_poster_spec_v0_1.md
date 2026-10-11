# スライドからポスターを組む 仕様 v0.1 (SlideWorkflow v1.54)

対象: `SlideWorkflow.wl` (v1.54 拡張) / 既存の `SourceVault_knowledgegraph.wl` (読むだけ、変更なし)

作成: 2026-10-08

---

## 1. 動機と到達点

- 発表スライド (最大 32 枚) とポスター (A0 1 枚) は **同じ知識グラフ (KG) からの 2 つの投影**。
  スライドは時間軸 (順に見せる)、ポスターは二次元の面 (一目で全部見える) に投影する。
- 過去のポスターの作り方を機能にする:
  - `201909-CIHCD-poster.pdf`: 2 列 × 4 段 = **8 ブロック**。各ブロックは最大 4 枚のスライドを
    **QuadTree 的に再組版** (2×2、1+2、2+1、1) して並べる。左列 = 課題の物語、右列 = システムの物語。
  - `iwnc4-poster.pdf`: 2 列 × 3 段 = 6 ブロック。**列に意味** (左 = 既知・過去、右 = 新規) を持たせ、
    列ごとに色を変える。
  - `20251115-CIHCD8-poster.pdf`: 2 列 × 4 段 = 8 ブロック、題名帯 + QR、脚注。
- 今回 (みんなのケア情報学会 第 9 回、2026-10-18) は「CIHCD 2019 で挙げた課題 ↔ 2026 の現状 ↔ 展望」なので、
  **左右の列の対応 (左 = 2019 の課題、右 = 2026 の現状) を同じ段に置く**配置が要る。

到達点: 「まずスライドを作る (≤ 32 枚) → それをポスター化する」を**パレットのボタン 1 つ**にする。
ブロックの分け方・並べ方・各ブロックに出す枚は決定的に計算し (LLM を呼ばない)、ポスター設定セル
(`SlidePoster`) の `Key: value` 行でだけ調整する。

## 2. 責務分界

| 層 | 責務 |
|---|---|
| `SourceVault_knowledgegraph.wl` | 変更なし。目次の木 (`SourceVaultKGTocTree` / `SourceVaultKGOrderedTree`) と辺・ノードの属性 (Label / Gist / Summary / Importance / Pinned / Facet) を読むだけ |
| `SlideWorkflow.wl` v1.54 (`SlidePoster*`) | デッキ (生成済み .nb) の枚を KG の部に束ねてブロックにし、二次元に配置し、各枚を再組版して 1 枚の `Graphics` に組み、PDF / PNG に書き出す。ポスター設定セルの挿入と読み取り。パレットのボタン |

原則: **ポスターはデッキから作る** (KG → 直接ではない)。デッキの枚は題目セルの CellTags `KGNode:<id>` で
KG のノードに結ばれているので、ブロック = 部 (目次の根の子) はデッキからたどれる。KG の無い手書きのデッキでも
動く (パンくず `第k部` か等分で束ねる)。

## 3. データモデル

### 3.1 ポスター設定セル (`SlidePoster`、メタセル)

Story セルと同じ `Key: value` 行。無い行は既定。`#` 行はコメント。

```
Size: A0                 # A0 | A1 | A2 | A3 | 841x1189 (mm)
Orientation: Portrait    # Portrait | Landscape
Columns: 2               # ブロックの列数
Blocks: Automatic        # ブロック数 (Automatic = 部の数を 3〜10 に丸める)
Panels: 4                # 1 ブロックに出す枚の上限
Layout: Pairs            # Flow (列ごとに上から) | Rows (段ごとに左から) | Pairs (左右の対応を同じ段に)
Axis: 2019 の課題 | 2026 の現状   # 列の見出し ( | 区切り)。列の色もこれで決まる
Column 1: sc1, sc3       # (任意) 列に置く部 (ノード Id か題目の一部)。Column 2: ... も同様
Grid: sc1=1,1; sc2=1,2   # (任意) 部の位置 (段,列) を固定
PanelMode: Reflow        # Reflow (枚をポスター幅で再組版) | Slides (16:9 の画像のまま)
Title / Subtitle / Author / Affiliation / Event / Date / Abstract   # 無ければ指示セル (Title:/Author:/Event:/Date:) とタイトルスライド
QR: https://...          # 題名帯の右上の QR (無ければ指示セルの SlideURL:)
Footer: ...              # 脚注 (謝辞など)
Resolution: 100          # PNG の dpi
```

日本語キーも受ける (サイズ / 向き / 列 / ブロック / 枚 / 配置 / 軸 / 位置 / 題目 / 著者 / 所属 / 集会 / 日付 / 概要 / 脚注 / 解像度)。

### 3.2 ポスター計画 (`SlidePosterPlan` の戻り値)

```
<|"ObjectClass" -> "SlidePosterPlan",
  "Size" -> {W, H} (pt), "Columns" -> C, "Rows" -> R,
  "Header" -> <|"Title", "Subtitle", "Author", "Affiliation", "Event", "Date", "Abstract", "QR"|>,
  "Facets" -> {"2019 の課題", "2026 の現状"} | {},
  "Blocks" -> {<|"Id" -> 部のノード Id | "blk3", "Title", "Gist", "Facet" -> 1|2|None,
                 "Position" -> {段, 列}, "Nodes" -> {..},
                 "Panels" -> {<|"Slide" -> n, "Node", "Title", "Reason" -> "Pinned"|"Figure"|"Importance"|"Order"|>..},
                 "Folded" -> {<|"Slide", "Title"|>..}|> ..},
  "Links" -> {<|"From" -> blockId, "To" -> blockId, "Kind" -> "LeadsTo", "Weight"|>..},
  "Footer" -> <|"References" -> {..}, "Note"|>,
  "Spec" -> 設定, "Warnings" -> {..}, "GraphId"|>
```

## 4. 決定的な計画 (`SlidePosterPlan`)

1. **枚の収穫**: デッキ (`NotebookObject` | 保存済みパス | `Notebook` 式) を `SlideDeckSlides` で割り、
   枚ごとに題目 (Subsection)・`KGNode:` タグ・図の有無・パンくず・セル列を取る。タイトルスライド
   (Title セルだけで Subsection が無い枚) は題名帯の材料にして枚には数えない。目次 (`agenda`) と用語辞書
   (`glossary*`) の枚も外す (ポスターでは配置そのものが目次)。
2. **部への束ね**: KG があれば目次の木 (無ければ資料の順序木) で、各ノードの「根の直下の祖先」= 部。
   部ごとに枚 (デッキ順) を集める。部のノード自身の枚 (概要の 1 枚) も同じ部。
   KG の無いデッキ: パンくず `第k部 …` の k で束ね、無ければ 4 枚ずつ等分。
3. **ブロック数の調整**: `Blocks` が数なら、多い時は隣り合う部のうち枚の合計が最少の組を併合 (題目は「A / B」)、
   少ない時は枚の最も多い部を目次の子の境で割る (割れなければそのまま)。Automatic は部の数を
   [3, 10] に丸める (3 未満なら割る、10 超なら併合)。
4. **各ブロックの枚 (パネル)**: `Panels` を超える部は、必ず出す (`Pinned`) > 図のある枚 > ノードの
   Importance > デッキ順 の優先度で選び、デッキ順に並べる。外した枚は `Folded` (題目をブロック末尾に
   「ほかに: …」で並べる。黙って落とさない)。
5. **列 (facet) の割り当て** (列が 2 つ以上で `Axis:` か `Layout: Pairs` のとき):
   `Column k:` の指定 > 部のノードの `"Facet"` (列の見出しか列番号) > 辺による対応 (From 側 = 左) > 無し。
6. **配置**:
   - `Flow`: 列ごとに上から (左列に前半、右列に後半。2019 のポスター)。
   - `Rows`: 段ごとに左から。
   - `Pairs`: 部どうしの辺 (Contrasts / LeadsTo / Derives / Motivates / RelatedTo / Supports / Explains、
     重みの和) で、左の部に最も強く結ばれた右の部を同じ段に置く (重みの降順の貪欲一致)。相手の無い部は
     残りの段に順に入れる。対応した組は `Links` に残り、描画で矢印になる。
   - `Grid:` の指定は常に最優先で、残りの部が空いた升を順に埋める。
7. 段数 R = Ceiling[B / C] (Pairs では組の数 + 余り)。

## 5. 描画 (`SlidePosterRender` → `Graphics`)

座標は pt (A0 縦 = 2384 × 3370)。`ImageSize -> {W, H}` の `Graphics` 1 つに組む。

- **題名帯**: 題目 (大、`$SlideHeavyFontFamily`)、著者・所属、集会・日付、概要 (折り返し)、右上に QR。
- **列の見出し** (`Axis:` があるとき): 列の色で。色は `$SlidePosterFacetColors`
  (既定 {Dim, Title, Bullet, Arrow} = 灰 → 橙 → 臙脂 → 黄土、`$SlideTheme` の名前)。
- **ブロック**: 角丸の枠 (列の色の薄い塗り + 枠線)、番号つき題目 (列の色)、一行要約 (Gist > Summary > Role、灰)、
  パネル領域、最後に「ほかに: …」。
- **パネル** (`PanelMode: Reflow`): 枚のセル列 (書き出しと同じフィルタ: navbar・メタ・閉じたセル・NoExport を除く)
  を `Notebook[cells, ScreenStyleEnvironment -> "SlideShow", WindowSize -> {w, _}]` でパネル幅 w に
  **再組版**して `Rasterize` (高さは内容なり = 16:9 の空白を持ち込まない)。白い余白を落とし、
  ブロックの中を 2 列の masonry (短い列へ順に積む) に配置。1 枚だけならブロック幅の 0.8 に 1 列。
  積んだ高さが升に入らなければブロックの中身だけ等倍縮小 (拡大はしない)。
  `PanelMode: Slides` は `SlideDeckImages` の 16:9 画像をそのまま 2×2 に置く (2019 の原型)。
- **対応の矢印** (`Links`): 左ブロックの右辺中央 → 右ブロックの左辺中央に、辺の種類を小さく添える。
- **脚注**: 文献 (`References` セルの `[key] locator | メモ`、URL は短く)、`Footer:`、追加の QR。

フォントは `$SlideFontFamily` / `$SlideHeavyFontFamily` (ハードコードしない)。

## 6. API

```
SlideInsertPoster[]                       ポスター設定セルを挿入 (雛形は指示セルと Story から埋める)
SlidePosterSpec[nb | path | Notebook]     設定 (ポスターセル + 指示セル + 既定) の連想
SlidePosterPlan[src, opts]                計画 (決定的)。opts で設定を上書き ("Blocks", "Columns", "Layout", "Panels", "Facets", ...)
SlidePosterPlanView[src, opts]            計画の一覧 (Dataset: ブロック / 位置 / 枚 / 外した枚)
SlidePosterRender[src | plan, opts]       Graphics (全体)。"Panels" -> "Reflow" | "Slides"、"PanelResolution" (既定 144)
SlidePosterImage[src | plan, opts]        Image ("Resolution" dpi、既定 100)
SlidePosterExport[src, file.pdf | .png]   書き出し。拡張子無しなら <deck>_poster.pdf と .png の両方。戻り値はパスのリスト
SlidePosterShow[nb]                       計画の一覧と縮小画像をノート末尾 (Appendix) に書く
$SlidePosterFacetColors                   列の色 ($SlideTheme の名前のリスト)
$SlidePosterPanelResolution               パネルの描画解像度 (既定 144 dpi)
```

パレット「確認・書き出し」: 「ポスター設定」(挿入) | 「ポスター」(= `SlidePosterExport` → PNG を開き、
`SlidePosterShow` で一覧と縮小画像をノートに残す)。状態行にブロック数と書き出し先。

エージェントの許可 head: `SlidePosterPlan` / `SlidePosterPlanView` / `SlidePosterRender` / `SlidePosterImage` /
`SlidePosterExport` / `SlidePosterShow` / `SlidePosterSpec`。

## 7. 使い方 (今回の発表)

1. デッキ: 指示セル (Title / Author / Event / Date / SlideURL)、文献 (projects.html と GitHub の公開物 = PL 0)、
   Story、プロンプトセルの筋書き (部 = 「2019 の課題」と「2026 の現状」が対になるように節を書く) → KG構築 → 推敲 → 生成 (≤ 32 枚)。
2. 「ポスター設定」で `Layout: Pairs` / `Axis: 2019 の課題 | 2026 の現状` を書く。対応は KG の辺 (調整セルで
   「課題 X と現状 Y を対応づけて」と書けば `Contrasts` / `LeadsTo` の辺が入る) か `Column 1:` / `Grid:` で固定。
3. 「ポスター」→ `<deck>_poster.pdf` / `.png`。一覧で外した枚を見て、出したい枚には「必ず出す」(Pinned) を付けて押し直す。

## 8. 検証

- `test codes/slidegraph_test_src.wls` T42: 小さな KG (部 4、辺で 2 組の対応) → `SlideGraphBuildDeck` → 計画
  (ブロック 4、Pairs で対応が同じ段、Grid 固定、Flow の列順、Panels 上限と Folded) → 描画 (Graphics) →
  書き出し (PNG の画素数 = A0 × dpi) → KG の無いデッキの等分 → 設定セルの読み取り (日本語キー、A1 横)。
- 実データ: みんなのケア情報学会 第 9 回のデッキで A0 を描き、目視。

## 9. 罠・注意

- `Rasterize[Notebook[..], ..]` の結果の高さは内容の高さ (WindowSize の高さで切れない)。幅より広い図は
  幅に合わせて縮める。
- Graphics の `Inset[image, pos, {Left, Top}, {w, h}]` は h を画像の縦横比から出す (歪ませない)。
- 大きな PNG (A0 100 dpi = 3311 × 4681) の書き出しは数秒。FE 内で実行するときは状態行に段階を出す。
- 列 (facet) が無い `Pairs` は From 側 = 左として辺だけで組む。辺も無ければ Flow に落ちる。
