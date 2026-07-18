# SlideWorkflow API リファレンス

Mathematica用スライドノートブックのシナリオ駆動構築・編集・16:9画像/動画書き出しパッケージ。コンテキスト: `SlideWorkflow\``

## コード生成時の規約 (IMPORTANT)

- フォント名をハードコードしない。必ず `$SlideFontFamily` を使う (`FontFamily -> $SlideFontFamily`)。
- 図の配色は `SlideThemeColor["Title"|"Bullet"|"SubBullet"|"Dim"|"Separator"|"Arrow"|"PanelBackground"|"PanelBorder"]` / `$SlideTheme` で統一する。
- 補助定義(ヘルパ関数・一時変数)は Module/With 内に置く。Global スコープの Set/SetDelayed は承認ゲート (GlobalSetRequiresApproval) で実行が停止する。
- デッキの新規作成は必ず `SlideDeckBuild`(シナリオ連想 / Markdown)経由。既存デッキの変更は `SlideDeckReplaceSlide` 等のスライド単位関数で行い、Notebook 式を手で組み立てない。
- ブラウザで HTML→PNG を作れない環境では、図は WL の Graphics で作図し、シナリオ Content の `{"Image", <|"Path"->...|>}` または `Cell[BoxData[ToBoxes[g]], "Input", TextAlignment->Center]`(raw Cell リスト)で埋め込む。図を含む Input セルはラスタライズで保持される。

## 定数

### $SlideFontFamily
型: String, 初期値: `NotebookExtensions\`$fontFamily` または `Global\`$fontFamily` が定義済みならその値
本文/タイトルの標準フォント。

### $SlideHeavyFontFamily
型: String, 初期値: `"Hiragino Kaku Gothic Std"`
タイトルスライドなど強調用フォント。

### $SlideStyleDefinitions
型: String, 初期値: `"Normal use.nb"`
デッキ生成・ラスタライズに使うスタイルシート名。

### $SlideImageSize
型: `{Integer, Integer}`, 初期値: `{1920, 1080}`
書き出し画像のサイズ(px)。

### $SlideTheme
型: Association, 初期値: 色の連想(テーマパレット)
スライドのデザイントークン(色)の連想。図の生成時にこのパレットを使うと統一感が出る。

### $SlideMargins
型: `{{left,right},{bottom,top}}` (px), 初期値: スライド余白の既定値
`SlideDeckImages`の`"Margins"->Automatic`時に使われる。全面画像ページには適用されない。

## テーマ

### SlideThemeColor[name] → Color
`$SlideTheme`中の色を返す。

### SlideThemeColor[] → Dataset
テーマ色の一覧をDatasetで返す。

## シナリオ変換

### SlideScenarioFromMarkdown[md] → Association
Markdown文字列(または`File[...]`)をシナリオ連想に変換する。
書式:
- 先頭に`--- Title:/Event:/Author:/Date: ---`のメタブロック(任意)
- `## タイトル {expected=秒}` で1スライド開始(`expected`は想定秒数、任意)
- `- ` 箇条書き(インデント2/4でSubitem/Subsubitem)
- `> ` は説明段落
- `![w=幅pt](画像パス)` でスライド内画像
- `## !image 画像パス` で全面画像ページ
例: `SlideScenarioFromMarkdown["--- Title: 発表 ---\n## 導入 {expected=30}\n- 背景\n  - 詳細\n> 補足説明\n"]`

### SlideScenarioToMarkdown[scenario] → String
シナリオ連想をMarkdown文字列に戻す(ラウンドトリップ用)。

## デッキ構築

### SlideDeckBuild[scenario, nbfile, opts] → String
シナリオ(連想 / Markdown文字列 / `File[md]`)からスライドノートブックを生成し`nbfile`に保存、ファイルパスを返す。
Options: `"TitleSlide" -> True` (先頭にタイトルスライドを付与するか), `StyleDefinitions -> $SlideStyleDefinitions` (適用スタイルシート)

## デッキ参照・編集

### SlideDeckSlides[nbfile] → <|"Prelude"->{cells}, "Slides"->{{cells}..}, "Options"->{...}|>
デッキをプレリュード部・スライド単位のセル配列・オプションに分解して返す(コア関数)。

### SlideDeckOverview[nbfile] → Dataset
スライド一覧(番号/タイトル/セル数/画像有無)のDatasetを返す(View関数)。

### SlideDeckReplaceSlide[nbfile, n, slide, opts]
n枚目をシナリオ形式のスライド連想(またはセルのリスト)で差し替える。
Options: `"Target" -> path` (出力パス。省略時は元ファイルを`.bak`付きで上書き)

### SlideDeckInsertSlide[nbfile, n, slide, opts]
n枚目の位置にスライドを挿入する(`n = Length+1`で末尾追加)。
Options: `SlideDeckReplaceSlide`と同じ(`"Target" -> path`)

### SlideDeckDeleteSlide[nbfile, n]
n枚目(リスト可)を削除する。

### SlideDeckMoveSlide[nbfile, n, m]
n枚目をm番目へ移動する。

## 画像・動画出力

### SlideDeckImages[nbfile, opts] → {Image...}
全スライドを16:9画像リストとして安定に生成する(クリップボード/ウィンドウ非依存)。
Options: `ImageSize -> $SlideImageSize`, `"Slides" -> All | 範囲` (対象スライド指定), `"Environment" -> "SlideShow"` (ScreenStyleEnvironment), `"WindowWidth" -> 960`, `"IncludeInput" -> Automatic`, `"Verbose" -> False`, `"Margins" -> Automatic` ($SlideMarginsまたは`{{left,right},{bottom,top}}` px), `"Reflow" -> True`, `"MaxWindowWidth" -> 1600`

**自動リフロー(`"Reflow"`)**: 内容が縦に収まらないスライドは、そのままでは縦横一律に縮小され幅も縮むため右に大きな余白が残る(実測: 高さ1215pxのスライドが0.79倍→右余白439px)。`"Reflow" -> True`(既定)は折返し幅 `WindowWidth` を段階的に広げて再描画し、**最終的な内容幅が最大になる幅**を探索する(広げすぎると図など不動要素が相対的に小さくなり再び余白が増えるため、単純な最大化ではなく最良点を選ぶ)。最初から収まるスライドは初回描画で確定するので出力・処理時間とも従来と同一。上限は `"MaxWindowWidth"`(pt)で、そこまで広げても収まらない場合のみ従来どおり縮小して `SlideDeckImages::ovflw` を出す。`"Verbose" -> True` でリフロー後の幅を表示。

### SlideDeckExportImages[nbfile] / SlideDeckExportImages[nbfile, dir, opts] → {String...}
各スライドを`dir/01.png`...として書き出し、パスのリストを返す。
Options: `SlideDeckImages`と同じ

### SlideDeckExportVideo[nbfile | images, mp4file, opts] → String
Sliden(VRChat)互換のmp4(30fps、1枚≒1秒、先頭29フレーム+末尾スライド重複)を書き出す。
Options: `"Durations" -> Automatic | {秒...}` (各スライドの表示秒数), `FrameRate -> 30`
例: `SlideDeckExportVideo["deck.nb", "out.mp4", "Durations" -> {3, 5, 4}]`

## デッキ構造の拡張要素

- **前置き**: 最初の navbar より前のセルはスライドに含まれない(作業ヘッダ・メモ・指示・辞書など)。
- **終端マーカー**: `CellTags` に `"SlideDeckEnd"` を含む SlideShowNavigationBar セル。これ以降は Appendix として `SlideDeckSlides` の `"Appendix"` キーに分離され、画像化・mp4・一覧から除外される(メモ・各種情報を自由に置ける)。`SlideDeckBuild` は既定で末尾に付与する(`"EndMarker"->False` で抑止)。
- **メタセル**(documentation.wl 互換, すべて書き出し除外): `"Note"`(メモ) / `"Directive"`(展開・翻訳時に LLM が厳守する指示) / `"Dictionary"`(翻訳用語対応) / `"Bibliography"`(文献) / `"SlidePrompt"`(スライド展開用プロンプト)。
- **出典セル**: シナリオの `cite: 出典` 行 → 小フォント(9pt)の出典 Text セル(`CellTags->"Citation"`、書き出しに含まれる)。論文・web・PDF 由来の図・引用には必ず付ける。
- **保持トークン**: シナリオの `<<FIGn>>` 行 → 再展開時に既存の図・コードセルをその位置に保持する(`$iSlideKeepCells` を Block 束縛して `iBuildSlideCells`)。
- **Appendix(md)**: シナリオ Markdown の `## !end` 以降の行は Appendix の Text セルになる。

## インタラクティブ編集 (SlideWorkflow.wl に統合済み)

### $SlideWorkflowInteractiveVersion
型: String, 初期値: interactive レイヤーの版番号
統合済みインタラクティブレイヤー(旧 SlideWorkflow_interactive.wl)のバージョン識別子。

### ShowSlidePalette[]
スライド作成パレットを表示する(documentation.wl のパレットと同型)。＋スライド/展開/英訳/×英訳/全英訳/挿入(プロンプト・出典・メモ・指示・辞書・文献・終端)/プロンプト表示切替/一覧・画像・mp4・シナリオmd 書き出し/P:M: 設定。`"Safe"->True` で ClaudeCode 完全非干渉モード。FE セッションではパッケージロード時に自動表示され、FE の「パレット」メニューにも "SlideWorkflow" として登録される(headless ロードでは両方スキップ)。

### SlideExpand[] / SlideExpand[nb]
現在スライドの SlidePrompt セル(無ければ選択セルの本文=自動で SlidePrompt セルに変換)を指示としてスライドを展開・更新する。**既定(`$SlideExpandMode="Agent"`)は ClaudeEval(ClaudeRuntime アダプタ)へ委譲**: 終端マーカー以降(Appendix)に `ClaudeEval["…タスク…"]` セルを書いて評価し、エージェントが文献検索(SourceVault/pdfSearch/web)・WL Graphics での図生成・出典付与を行った後、**`SlideApplyScenario` を一度だけ呼んで適用**する(安全な書込み口を一点に限定)。`$SlideExpandMode="Direct"` で旧来の軽量直接 LLM(NBAccess`$NBLLMQueryFunc、ツール無し)。

### $SlideExpandMode
型: String, 初期値: `"Agent"`
`SlideExpand`の実行経路。`"Agent"`(既定: ClaudeEval/ClaudeRuntime 経由、文献検索・図生成・承認ゲート付きの複雑処理が可能) | `"Direct"`(軽量: `NBAccess\`$NBLLMQueryFunc`直接呼び出し、ツール無し)。

### SlideApplyScenario[slideNo, md] / SlideApplyScenario[nb, slideNo, md] → Success | Failure
シナリオ Markdown で対象スライドを差し替える**決定的適用関数(展開エージェントの唯一の書込み手段)**。
- md に複数 `##` があれば複数スライドに展開される。
- `<<FIGn>>`: n=1..k は既存の図・コードセル(現スライド内の出現順)、n=k+1.. は `"Figures"` オプションで渡した新規図。
- Options: `"Figures" -> {}` (Graphics/Graphics3D/Image/Cell のリスト。Graphics は ImageSize 560pt で貼付)
- SlidePrompt セルは自動で先頭スライドのタイトル直後に戻される。
- 失敗時は `Failure["SlideOutOfRange"|"BadScenario", ...]` を返す(エージェントは md を修正して再評価する)。
例: `SlideApplyScenario[3, md, "Figures" -> {g1}]`

### SlideAddSlide[]
現在スライドの直後に新規スライド骨格(navbar+タイトル+SlidePrompt セル)を挿入。

### SlideTranslate[] / SlideTranslateRevert[] / SlideTranslateDeck[]
現在スライド(/全スライド連鎖)のテキストセルを `$SlideTranslationLanguage` へ一括翻訳。Dictionary 厳守・出典セルは対象外。原文は TaggingRules `"SWOrigText"` に保存され Revert で復元。

### $SlideTranslationLanguage
型: String, 初期値: 日本語環境なら`"English"`
`SlideTranslate`/`SlideTranslateDeck`の翻訳先言語。

### SlideInsertPrompt[] / SlideInsertCitation[] / SlideInsertEndMarker[] / SlideInsertNote[] / SlideInsertDirective[] / SlideInsertDictionary[] / SlideInsertBibliography[] / SlideTogglePrompts[]
各種セルの挿入(Documentation` ロード済みなら DocInsert* に委譲)とプロンプトセルの表示切替。