# SlideWorkflow ユーザーマニュアル

## 1. 定数($-記号)

スタイルやレイアウトの既定値を保持するグローバル変数です。値を直接書き換えることで以降の生成・書き出しに反映されます。

### `$SlideFontFamily`

本文・タイトルの標準フォント。`NotebookExtensions`パッケージの`$fontFamily`または`Global`\`$fontFamily`が定義されていればそれを使用します。

```wolfram
$SlideFontFamily
```

### `$SlideHeavyFontFamily`

タイトルスライドなど強調用のフォント(既定 `"Hiragino Kaku Gothic Std"`)。

```wolfram
$SlideHeavyFontFamily = "Hiragino Kaku Gothic Std";
```

### `$SlideStyleDefinitions`

デッキ生成・ラスタライズに使うスタイルシート名(既定 `"Normal use.nb"`)。

```wolfram
$SlideStyleDefinitions
```

### `$SlideImageSize`

書き出し画像のサイズ `{幅, 高さ}`(既定 `{1920,1080}`)。

```wolfram
$SlideImageSize = {1920, 1080};
```

### `$SlideTheme`

図の配色に使う連想リスト。生成する図にこのパレットを使うと統一感が出ます。

```wolfram
$SlideTheme
```

### `$SlideMargins`

スライド余白の既定値 `{{left,right},{bottom,top}}`(px)。`SlideDeckImages`の`"Margins"->Automatic`で使用され、全面画像ページには適用されません。

```wolfram
$SlideMargins
```

### `$SlideIncludeInput`

書き出しに Input/Code セルを含めるかどうかの既定値。`SlideDeckImages`などの`"IncludeInput"->Automatic`で参照されます。

- `Automatic`(既定) — ノートブックの表示どおり(折りたたみ・`CellOpen->False`で隠れているセルだけが除かれる)
- `True` — `Automatic`と同じ
- `False` — Input/Codeセルをすべて除く
- `"Visual"` — 図を含むInputのみ残す(旧既定の互換モード)

個別セルの`CellTags`に`"ShowInput"`を付けると、この設定によらず必ず書き出しに残ります。

```wolfram
$SlideIncludeInput = "Visual";
```

---

## 2. テーマ

### `SlideThemeColor`

`$SlideTheme`の色を取得します。

```wolfram
SlideThemeColor["Accent"]
SlideThemeColor[]   (* 一覧をDatasetで表示 *)
```

---

## 3. シナリオ変換

シナリオとは、スライド内容を表す連想リスト(またはMarkdown文字列)です。

### `SlideScenarioFromMarkdown`

Markdown文字列(または`File[...]`)をシナリオ連想リストに変換します。

書式:
- 先頭に `--- Title:/Event:/Author:/Date: ---` のメタ情報
- `## タイトル {expected=秒}` で1スライド
- `- ` 箇条書き(インデント2/4でSubitem/Subsubitem)
- `> 説明段落`
- `![w=幅pt](画像パス)` で画像挿入
- `## !image 画像パス` で全面画像ページ
- `| a | b |` 行が2行連続し、2行目が`| --- | --- |`のとき1行目がヘッダの表(`SlideTable`と同じ表になる)
- `cite: 出典`行で直前の図・引用の出典(URLまたは`(著者, 年)`)を明記
- `talk: 発表原稿`行で、そのスライドの発表原稿(ナレーション草稿)を`SlideTalk`スタイルとして保持

```wolfram
md = "--- Title: 講義1 ---\n## 導入 {expected=60}\n- ポイント1\n- ポイント2\n";
scenario = SlideScenarioFromMarkdown[md];
```

### `SlideScenarioToMarkdown`

シナリオ連想リストをMarkdown文字列に戻します(ラウンドトリップ用)。

```wolfram
SlideScenarioToMarkdown[scenario]
```

---

## 4. デッキ構築

### `SlideDeckBuild`

シナリオ(連想リスト・Markdown文字列・`File[md]`のいずれか)からスライドノートブックを生成し、指定パスに保存します。生成したファイルパスを返します。

オプション: `"TitleSlide"->True`、`StyleDefinitions->$SlideStyleDefinitions`

```wolfram
SlideDeckBuild[scenario, "C:\\slides\\lecture1.nb"]
```

---

## 5. デッキの閲覧

### `SlideDeckSlides`

デッキを`<|"Prelude"->{cells}, "Slides"->{{cells}..}, "Options"->{...}|>`に分解して返す、他関数の基盤となるコア関数です。

```wolfram
SlideDeckSlides["lecture1.nb"]
```

### `SlideDeckOverview`

スライド番号・タイトル・セル数・画像有無の一覧を`Dataset`で表示します。

```wolfram
SlideDeckOverview["lecture1.nb"]
```

---

## 6. デッキの編集

いずれも対象ノートブックを直接書き換えます(`"Target"`省略時は元ファイルを`.bak`付きで上書き)。

### `SlideDeckReplaceSlide`

n枚目をシナリオ形式のスライド連想リスト(またはセルのリスト)で差し替えます。

```wolfram
SlideDeckReplaceSlide["lecture1.nb", 3, newSlide]
```

### `SlideDeckInsertSlide`

n枚目の位置にスライドを挿入します(`n = Length+1`で末尾追加)。オプションは`SlideDeckReplaceSlide`と同じです。

```wolfram
SlideDeckInsertSlide["lecture1.nb", 2, newSlide]
```

### `SlideDeckDeleteSlide`

n枚目(リスト指定も可)を削除します。

```wolfram
SlideDeckDeleteSlide["lecture1.nb", {4, 5}]
```

### `SlideDeckMoveSlide`

n枚目をm番目の位置へ移動します。

```wolfram
SlideDeckMoveSlide["lecture1.nb", 5, 2]
```

---

## 7. 画像・動画の書き出し

クリップボードやウィンドウのスナップショットに依存せず、スライドのセル列からNotebook形式を構成し`ScreenStyleEnvironment->"SlideShow"`でRasterizeするため、FEセッションなしのheadless実行(wolframscript + UsingFrontEnd)でも同じ結果になります。

### `SlideDeckImages`

全スライドを16:9画像のリストとして安定生成します。

オプション: `ImageSize->$SlideImageSize`、`"Slides"->All`または範囲、`"Environment"->"SlideShow"`、`"WindowWidth"->960`、`"IncludeInput"->Automatic`($SlideIncludeInputに従う。`True`/`False`/`"Visual"`も指定可)、`"Verbose"->False`、`"Margins"->Automatic`($SlideMarginsまたは`{{left,right},{bottom,top}}` px)

```wolfram
images = SlideDeckImages["lecture1.nb", "Slides" -> {1, 2, 3}];
```

### `SlideDeckExportImages`

各スライドを`dir/01.png`のように連番で書き出し、パスのリストを返します。オプションは`SlideDeckImages`と同じです。

```wolfram
SlideDeckExportImages["lecture1.nb", "C:\\slides\\out"]
```

### `SlideDeckExportVideo`

ノートブック(または既に生成した画像リスト)から、Sliden(VRChat)互換のmp4(30fps、1枚あたり秒指定、先頭29フレーム+末尾スライド繰り返し)を書き出します。

オプション: `"Durations"->Automatic`または秒数のリスト、`FrameRate->30`

```wolfram
SlideDeckExportVideo["lecture1.nb", "C:\\slides\\lecture1.mp4"]
```

### `$SlideExportExternal`

パレットからの画像/mp4書き出しを別プロセス(wolframscript)で行うかどうかの設定です。既定`Automatic`は1度だけ別プロセス起動を試み、ライセンス席不足などで起動できなければ以後はフロントエンド内処理にフォールバックします。`True`/`False`で固定もできます。

```wolfram
$SlideExportExternal = False;
```

---

## 8. インタラクティブ編集(スライドパレット)

旧`SlideWorkflow_interactive.wl`が本パッケージに統合されたレイヤーです。スライドノートブックを実機(フロントエンド)で編集しながら、パレットのボタンからスライド追加・LLMによる本文展開・翻訳・各種補助セルの挿入を行えます。ここで挿入・生成されるセルは、既存の16:9画像/mp4書き出し(`SlideDeckImages`など)と整合するように設計されており、書き出しから除外すべきセル(プロンプト・メモ・指示・辞書・文献・トーク原稿・質疑応答・読み・調整)や、スライド終端マーカー以降のセルは自動的にラスタライズ対象から外れます。

### 8.1 バージョンとパレット表示

#### `$SlideWorkflowInteractiveVersion`

インタラクティブレイヤーのバージョン文字列。

```wolfram
$SlideWorkflowInteractiveVersion
```

#### `ShowSlidePalette`

スライド作成用パレット(ボタン群)を表示します。

オプション: `"Safe"->False`(既定)。`"Safe"->True`にすると、ClaudeCodeなど外部エージェントの処理に完全に非干渉なモードで開きます(フリーズ時の切り分け用)。

```wolfram
ShowSlidePalette[]
ShowSlidePalette["Safe" -> True]
```

#### `ShowSlideTalkPalette`

発表パレットを開きます。Slideshow・再生・音声応答・カメラ・声や言語や質問の受け方の設定がまとまっています。作成パレット(`ShowSlidePalette`)の上のボタンからも開けます。

```wolfram
ShowSlideTalkPalette[]
```

### 8.2 スライド追加

#### `SlideAddSlide`

現在選択中のスライドの直後に、新規スライドの骨格(ナビゲーションバー+タイトル+`SlidePrompt`セル)を挿入します。挿入後、`SlidePrompt`セルに要点を書き、パレットの「展開」(`SlideExpand`)を押す運用を想定しています。プロンプトに「◯枚構成で」のように書けば、「展開」で複数スライドへ一括展開できます(`SlideApplyScenario`は複数の`##`を複数枚のスライドに分割して適用します)。

```wolfram
SlideAddSlide[]
```

### 8.3 LLMによる展開

#### `SlideExpand` と `$SlideExpandMode`

現在スライドの`SlidePrompt`セル(無ければ選択セルの本文)を指示として読み取り、その内容でスライドを展開・更新します。実際の書き込みは常に`SlideApplyScenario`を介して行われる決定的な処理です。

```wolfram
SlideExpand[]
```

`$SlideExpandMode`で実行経路を切り替えられます。

- `"Agent"`(既定): `ClaudeEval`(`ClaudeRuntime`経由)に委譲します。文献検索・図生成・承認ゲート付きの複雑な処理が可能です。エージェントは以下を守って新しいシナリオMarkdownを構成し、最後に`SlideApplyScenario`を呼んで適用します。
  - 書式は`SlideScenarioFromMarkdown`と同じ(`"## タイトル {expected=秒}"` / `"- "`箇条書き(インデント2/4で下位項目) / `"> "`説明段落 / `| 表 |`構文 / `"talk: 発表原稿"`行)。通常は1枚のスライドに収める。指示で明示的に求められた場合のみ複数の`##`に分割する。
  - 論文・Web・PDF由来の図・引用・データを使う場合は、直後に`cite: `行で出典(URLまたは`(著者, 年)`)を必ず明記する。内容確認が必要なら文献検索(SourceVault / pdfSearch / Web検索)を利用してよい。
  - 既存の図・コードセルは`<<FIGn>>`トークンとしてプレースホルダとして保持し、勝手に消さない。
  - `Directive`(指示)・`Dictionary`(辞書)セルの内容を厳守する。
  - 追跡・作業用セルは、スライド終端マーカー(`SlideInsertEndMarker`)以降(Appendix領域)に置かれ、スライド本体やエクスポートには含まれない。
- `"Direct"`: 軽量経路。`NBAccess`\``$NBLLMQueryFunc`を直接呼び出します(承認ゲートや文献検索などの複雑処理は行いません)。

```wolfram
$SlideExpandMode = "Direct";
SlideExpand[]
```

#### `SlideApplyScenario`

`SlideApplyScenario[slideNo, md]`は、シナリオMarkdown `md`で`slideNo`枚目のスライドを差し替える決定的な適用関数です。`SlideExpand`が最後に呼ぶ唯一の書き込み口であり、直接呼び出すこともできます。

- `md`には複数の`##`を含められ、その場合は複数枚のスライドとして展開されます。
- `md`中の`<<FIGn>>`トークンは、`n = 1..k`が既存の図・コードセル(元の並び順で再利用)、`n = k+1..`が`"Figures"`オプションで渡した新規図(`Graphics`/`Image`)に対応します。
- `SlidePrompt`セルは適用後に自動でスライド先頭に戻されます。
- 成功時は`Success`、失敗時は`Failure`を返します。新規図に`Failure` / `$Failed`や、評価されずに残った画像処理の式が混じっている場合は、何も書かずに`Failure["BadFigures"]`を返します。

オプション: `"Figures"->{}`(新規図のリスト)

```wolfram
SlideApplyScenario[3, "## 更新後のタイトル {expected=45}\n- 新しい要点\n<<FIG1>>\n",
  "Figures" -> {myNewGraphic}]
```

#### `SlideDeckInsertScenario`

`SlideDeckInsertScenario[nb, afterN, md]`は、シナリオMarkdown `md`のスライド群を、開いているデッキの`afterN`枚目の直後へ挿入します(`afterN=0`で先頭)。`SlideApplyScenario`と違い、既存スライドには一切触れません(既存スライドを差し替えたいときは`SlideApplyScenario`を使います)。

- `md`には複数の`##`を含められ、その枚数だけスライドが挿入されます。
- `md`中の`<<FIGn>>`トークンは`"Figures"`オプションで渡した新規図(`Graphics`/`Image`)に対応します(既存セルの再利用はありません)。
- 成功時は`Success`、失敗時は`Failure`を返します。

オプション: `"Figures"->{}`

```wolfram
SlideDeckInsertScenario[nb, 3, "## 追加スライド {expected=30}\n- 新しい要点\n"]
```

### 8.4 翻訳

`SlideTranslate` / `SlideTranslateRevert` / `SlideTranslateDeck` / `SlideShowLanguage` / `$SlideTranslationLanguage`

- `SlideTranslate[]` — 現在スライドの見出し・箇条書き・本文を`$SlideTranslationLanguage`へ翻訳し、訳の表示にします(v1.36)。`Dictionary`セルの用語対応を厳守します。原文は消さず、セルの`TaggingRules`(`documentation.wl`と同じ`"documentation"` -> `translationSrc` / `translation` / `showTranslation`、書式つきの原文は`SWOrigContent`)に残るため、LLMを呼ばずに切り替えられます。訳のあるセルは表示を切り替えるだけで、訳の無いセルと原文を直したセルだけを1回にまとめてLLMへ渡します。発表原稿(トークセル)は訳しません(原稿の訳は`SlideTalkTranslate`)。
  - v1.40: 同じ枚の図(Output / Print / Graphicsセル = Mathematicaで描いた図や表)の中の日本語の文字列も訳し、原文の図(`SWOrigContent`)と訳の図(`SWTransContent`)を持って切り替えます(`SlideTranslateRevert` / `SlideShowLanguage`も図に効きます)。オプションの値(フォント名など)と画像の中の文字は訳しません。
- `SlideTranslateRevert[]` — 現在スライドを原文の表示に戻します(訳は残る。訳を手で直していればその直しも残ります)。
- `SlideTranslateDeck[]` — 全スライドを順に訳の表示にします(訳の無いセルだけLLMで訳す。非同期的に連鎖)。
- `SlideShowLanguage[]` / `SlideShowLanguage[nb, "Toggle" | "Original" | "Translation"]` — デッキ全体のスライドの表示を原文と訳で切り替えます(LLMは呼ばず、訳の無いセルは原文のまま)。画像・mp4の書き出しは表示中の言語になります。
- `$SlideTranslationLanguage` — 翻訳先言語(既定は日本語環境なら`"English"`)。

```wolfram
$SlideTranslationLanguage = "English";
SlideTranslate[]
SlideTranslateRevert[]
SlideTranslateDeck[]
SlideShowLanguage[nb, "Toggle"]
```

### 8.5 補助セルの挿入

いずれもカーソル位置(または現在スライド)に、用途別の特殊セルを挿入するパレット向けコマンドです。多くは16:9画像/mp4の書き出しから除外されます。

- `SlideInsertPrompt[]` — `SlidePrompt`セルを挿入します。`SlideExpand`が読む入力欄であり、ラスタライズ(画像・動画書き出し)からは除外されます。
- `SlideInsertCitation[]` — 出典セル(小フォント)を挿入します。図や引用の直後に置き、URLまたは`(著者, 年)`を記入する運用です。
- `SlideInsertEndMarker[]` — スライド終端マーカーを挿入します。以降のセルはそのスライドの一部とみなされず、書き出し(`SlideDeckImages`など)にも含まれません。追跡用セルや検討メモの置き場として使えます。
- `SlideInsertNote[]` — メモセルを挿入します(`documentation.wl`のメモセルと互換)。`Working`環境では可視、`SlideShow`(スライドショー環境)では非表示になり、書き出しからも除外されます。
- `SlideInsertDirective[]` — 指示セルを挿入します。`SlideExpand`(展開)・`SlideTranslate`(翻訳)実行時にLLMが厳守すべき指示を書きます。`Working`で可視、`SlideShow`では非表示です。
- `SlideInsertDictionary[]` — 辞書セルを挿入します。翻訳時の用語対応(専門用語の訳語固定など)を指定します。
- `SlideInsertReading[]` — 読みセル(`SlideReading`スタイル)を挿入します(v1.51)。読み上げ(gpt-realtime・ローカルの声)のときだけ語を仮名に置き換える辞書で、1行1語`語 = よみ`、`#`から行末はコメントです。スライド・字幕・原稿は書き換えません。全デッキ共通の読み(`SlideReadingFile[]`)より優先されます。`Working`で見え、`SlideShow`と書き出しでは隠れます。詳細は10.1の「読みの辞書」を参照してください。
- `SlideInsertBibliography[]` — 文献セルを挿入します(`documentation.wl`と互換)。
- `SlideInsertReferences[]` — 文献リストセルを挿入します(パレットの「文献」)。1行1文献`"[key] locator | メモ"`の書式で、`locator`はURL / `arxiv:ID` / `sv://URI` / `eagle:ID` / PDF・ノートブックのパス(過去スライド可)。スライド指示(プロンプト)からは`[key]`で参照し、展開エージェントが取得・引用します。`#`で始まる行はコメントです。
- `SlideTogglePrompts[]` — デッキ内の全`SlidePrompt`セルの表示/非表示を一括で切り替えます。

```wolfram
SlideInsertDirective[]
SlideInsertDictionary[]
SlideInsertReading[]
SlideInsertPrompt[]
SlideInsertCitation[]
SlideInsertBibliography[]
SlideInsertReferences[]
SlideInsertNote[]
SlideInsertEndMarker[]
SlideTogglePrompts[]
```

### 8.6 表示環境の切替とスタイル

#### `SlideToggleScreenEnvironment`

対象ノートブックのスクリーン環境を`Working` ⇄ `SlideShow`で切り替えます(書式メニューの「スクリーンスタイル環境」と同じ)。メモ・指示・辞書・読み・文献・プロンプトの各セルは`Working`で可視、`SlideShow`で非表示になります。

```wolfram
SlideToggleScreenEnvironment[]
```

#### `SlideEnsureDeckStyles`

デッキにメタセル用スタイル定義(`Note`/`Directive`/`Dictionary`/`SlideReading`/`Bibliography`/`References`/`SlidePrompt`/`SlideTalk`/`SlideQA`。`SlideShow`環境で非表示)を埋め込みます。パレットの挿入・展開・表示切替から自動で呼ばれ、`documentation.wl`の`DocInsert*`もこの定義を共用します。

```wolfram
SlideEnsureDeckStyles[nb]
```

#### `$SlideHideToolbarInSlideshow`

既定`True`。表示切替(`SlideToggleScreenEnvironment`)で`SlideShow`へ入るときに、標準ノートブックツールバー(MultipurposeBar)とノートブック側のDockedCells(CloudPublishableのPublic/Privateバッジ等)を一時退避し、`Working`へ戻すときに復元します。ノートブック側DockedCellsはスタイルシートのスライドナビバー定義を上書きするため、退避しないとナビバーが出ません。

```wolfram
$SlideHideToolbarInSlideshow = True;
```

### 8.7 図・表・引用元PDF・素材ノートブックの補助関数

#### `SlideTable`

`SlideTable[rows]`はデッキ配色(`$SlideTheme`)の表を返します。`rows`は文字列の行リスト。`"HeaderRows"->n`(既定1)でヘッダ行を強調します。シナリオmdでは`|`構文(`"| a | b |"`、2行目に`"| --- | --- |"`で1行目がヘッダ)が同じ表になります。

```wolfram
SlideTable[{{"項目", "値"}, {"精度", "98%"}}, "HeaderRows" -> 1]
```

#### `SlidePDFFigure`

`SlidePDFFigure[src, page]`はPDFのページを図(`Image`)として切り出します。`src`はファイルパス / `eagle:ID` / `sv://URI` / `src-ID` / URL / `arxiv:ID` / 文献リスト(References)のkey。URL・arxiv・Google Slides(プレゼンURL)は自動ダウンロードしてPDF化しキャッシュします。png等の画像ファイルも`src`に指定できます。`"Crop"->{{x1,x2},{y1,y2}}`(左上原点のページ比率0..1)で領域指定、`"Trim"->Automatic`(既定)で白余白を自動トリム、`ImageResolution`(既定144)。文献PDFの図をスライドへ引用するときは直後に`cite: `を付します。

```wolfram
SlidePDFFigure["arxiv:2301.00001", 3, "Crop" -> {{0, 0.5}, {0, 1}}]
```

#### `SlidePDFImages`

`SlidePDFImages[src]`はPDFに埋め込まれたラスタ画像(写真・ビットマップ図)を`Image`のリストで抽出します。`src`は`SlidePDFFigure`と同じlocator。`"MinSize"->px`(既定80)未満の小画像(アイコン等)は除外します。ベクタのみのPDFでは`{}`を返します(その場合は`SlidePDFFigure`でページ切り出しを使います)。

```wolfram
SlidePDFImages["C:\\papers\\paper.pdf", "MinSize" -> 120]
```

#### `SlideDeckFigure`

`SlideDeckFigure[deck, n]`は既存スライドデッキ(.nb)のn枚目を1920x1080の`Image`として引用します。`deck`はパスまたはReferencesのkey。論文紹介・過去スライド紹介で原スライドをそのまま見せるのに使います(`cite: `を付します)。

```wolfram
SlideDeckFigure["lecture1.nb", 5]
```

#### `SlideNotebookOutline`

`SlideNotebookOutline[src]`は素材ノートブック(論文の和訳.nbなど、スライドデッキでない一般の.nb)の見出し構成を返します。各要素は`<|"N", "Style", "Title", "Chars"(その節の本文文字数), "Figures"(その節にある図番号)|>`。まず構成を見て、必要な節だけを`SlideNotebookText[src, 見出し]`で読むと文脈を節約できます。`src`は`SlidePDFFigure`と同じlocator(パス / `eagle:ID` / `sv://URI` / Referencesのkey)。

```wolfram
SlideNotebookOutline["paper_ja.nb"]
```

#### `SlideNotebookText`

`SlideNotebookText[src]`は素材ノートブックの本文を`"[Style] 本文"`行の並びで返します(図の位置は`"[FIGn]"`行)。`SlideNotebookText[src, 見出し|見出し番号]`はその節だけを返します。数式(DisplayFormula)も含みます。セルから画像ボックスを外してから文字列化するので、生のImportと違ってRasterの圧縮データが本文に混ざりません。数式セルの行頭には`"[EQn]"`が付き、本文には元のLaTeX(変換ノートがTaggingRulesに保持していれば)を出すので、数式を誤読しません。そのままスライドへ引用するには`SlideNotebookFormula[src, n]`を使います。

オプション: `"MaxCharacters"`(既定40000、超過分は切り詰めて注記) / `"Styles"`(既定Automatic = 本文系スタイル)。LLM生成コードではImport / Getが恒久禁止headなので、素材.nbを読むときはこれを使います。

```wolfram
SlideNotebookText["paper_ja.nb", "3. 提案手法"]
```

#### `SlideNotebookFormula`

`SlideNotebookFormula[src, n]`は素材ノートブックのn番目の数式(`SlideNotebookText`の`"[EQn]"`に対応)を、**元セルの組版を保ったまま**Cellで返します。`SlideApplyScenario`の`"Figures"->{...}`にそのまま渡せば、スライドに組版済みの数式として載ります(プレーン文字列へ潰して書き直さないこと)。

オプション: `"Style"`(既定`"DisplayFormula"`) / `FontSize` / `FontColor`。

```wolfram
SlideApplyScenario[3, md, "Figures" -> {SlideNotebookFormula["paper_ja.nb", 2]}]
```

#### `SlideNotebookFigure`

`SlideNotebookFigure[src, n]`は素材ノートブックのn番目の図(`SlideNotebookText`の`"[FIGn]"`に対応)を`Image`で返します。原図をそのまま引用するための入口で、`SlideApplyScenario`の`"Figures"->{...}`にそのまま渡せます(`cite: `を必ず付します)。図の総数と所在は`SlideNotebookOutline` / `SlideNotebookText`の`[FIGn]`で分かります。返す画像は長辺`$SlideNotebookFigureMaxSize`(既定1200px、`"MaxSize"`で変更可)に収めます — デッキのラスタ化で実際に出るのは高々1120pxなので、それ以上はノートブックを重くするだけになります。

```wolfram
SlideNotebookFigure["paper_ja.nb", 1]
```

#### `$SlideNotebookFigureMaxSize` / `$SlideNotebookRasterizeSeconds`

- `$SlideNotebookFigureMaxSize` — `SlideNotebookFigure`が返す図の長辺上限px(既定1200)。デッキはWindowWidth 960を1920へ2倍でラスタ化し、図セルは`ImageSize->560`なので、最終画像に出るのは高々1120px。それを超える画素はノートブックを重くするだけです。
- `$SlideNotebookRasterizeSeconds` — `SlideNotebookFigure`がベクタ図を`Rasterize`する際の上限秒(既定30)。`Rasterize`はフロントエンドを要求するので、必ず時間で切ります。

```wolfram
$SlideNotebookFigureMaxSize = 1200;
$SlideNotebookRasterizeSeconds = 30;
```

#### `SlideSourceFile`

`SlideSourceFile[locator]`は文献locator(パス / `eagle:ID` / `sv://URI` / URL / `arxiv:ID` / Google Slides URL / Referencesのkey)を解決してローカルファイルパスを返します(URL系は自動ダウンロード+PDF化+キャッシュ)。展開エージェントが`ClaudeAttach[SlideSourceFile[...]]`で資料を閲覧し、引用するページ・領域を決めるのに使います。

```wolfram
ClaudeAttach[SlideSourceFile["ref1"]]
```

#### `$SlideVisualsPerSlide`

既定`True`。展開プロンプトが「原則すべてのスライドに図か表を1つ以上」を要求します。`False`で従来の文章中心生成に戻ります。

```wolfram
$SlideVisualsPerSlide = False;
```

---

## 9. 知識グラフによるスライド生成(Story / Graph)

論文などの素材から知識グラフ(KG)を作り、聴衆・尺・戦略を指定して順序木とスライド計画を決定的に立て、スライドMarkdownへ投影して適用するパイプラインです。図・数式・原スライドの実体化は`SlideNotebookFigure`/`SlideNotebookFormula`/`SlidePDFFigure`/`SlideDeckFigure`に委ねられ、KG自体は文章の要約・構造・話す順序だけを持ちます。

### 9.1 Story セルと仕様

#### `SlideInsertStory`

`SlideInsertStory[]`はストーリー/聴き手仕様セル(`SlideStory`スタイル)を挿入します。`Key: value`行で`Graph:` / `Audience:` / `Slides:` / `Minutes:` / `Language:` / `Strategy:` / `Story:`を書きます(`Audience`は`"高校生, 電気化学=0.3, 高校数学III"`のようにプリセットと領域=理解度の併記)。`Working`で可視、`SlideShow`では非表示、書き出し・英訳の対象外です。

```wolfram
SlideInsertStory[]
```

#### `SlideGraphSpec`

`SlideGraphSpec[nb]`はStoryセルとDirectiveセル(`Title:` / `Language:`)から知識グラフ生成の仕様連想`<|"Graph", "Audience", "Slides", "Minutes", "Seconds", "Language", "Strategy", "Story", "Title", "SecondsPerSlide"|>`を返します。`nb`はNotebookObject / Notebook式 / 保存済みパス。

```wolfram
SlideGraphSpec[nb]
```

### 9.2 第一次KGの構築(Seed)

#### `SlideGraphSeed`

`SlideGraphSeed[nb|key|path, opts]`は和訳ノートブック(`DocImportPaper`の出力など)の段落構造から**第一次の知識グラフ**を決定的に作って保存します。見出し→Section、段落→Concept(本文は`"Text"`に保持)、図→Figure(NotebookFigure資産、キャプション「図1 |」「Figure 1:」を合流)、数式→Equation(Formula資産)、Contains / Precedes / Supports辺を作ります。Titleセルが無ければ最初の見出し(論文題名)をrootに畳み、著者行は落とし、root直下の最初の長い段落を「概要」ノードにします。付録(A. / Appendix / 付録)はImportance 0.3、参考文献・謝辞・AI Disclosureなどは読み飛ばします。LLMは使いません。

オプション: `"Graph"`(GraphId、既定はStoryセル) / `"Title"` / `"Language"` / `"MinCharacters"`(40) / `"Save"` / `"Reconstruction"`(既定False: `DocImportPaper`の第二部「計算の再構成」を除外) / `"Keep"`(既定`"Background"`: 再seedでも保存済みKGのBackground/Shared層のノードと辺を残す。`None`で捨てる)。

戻り値: `<|"Graph", "Title", "PaperTitle", "NodeCount", "EdgeCount", "Sections", "Paragraphs", "Figures", "Formulas", "Kept", "Skipped", "Warnings", "KG"|>`。

```wolfram
SlideGraphSeed["paper_ja.nb"]
```

#### `SlideGraphSeedScenario`

`SlideGraphSeedScenario[nb | {<|"Title"->.., "Text"->..|>..}, opts]`は、文書(論文)の無い発表のために、プロンプトセル(`SlidePrompt`)に書いた筋書き(シナリオ)から第一次KGを決定的に作って保存します。セルは見出し(`#`)/行頭の番号/空行で部に分け、部ごとに節ノード`sc<i>`と筋書きノード`sc<i>_d`(本文=筋書き、要点なし)を置きます。KGのKindは`"Scenario"`です。続く推敲(`SlideGraphRefine`)が筋書きを発表用のノード(`sc<i>_1..`、関連研究`rw_<候補番号>`、前提`bg_*`)に展開します。

オプション: `"Graph"`, `"Title"`, `"Language"`, `"Save"`, `"Keep"`(`"Background"` = 作り直しても周辺知識を残す)。

```wolfram
SlideGraphSeedScenario[nb]
```

#### `SlideGraphSectionText`

`SlideGraphSectionText[graphId, sectionId, opts]`は知識グラフの節(Sectionノード)の**自身の本文ノード**(直下の段落・図・式。入れ子の下位節は別扱い)をId / Kind / Label / Textの読みやすいテキストで返します(エージェントが節ごとに磨くための読み口。戻り値は読むためのもので解析は不要)。長い節は`"MaxCharacters"`(既定4000)ごとにノード境界でページに分かれ、`"Page"->n`で続きを読みます(末尾に次ページの式を示す)。`SlideGraphSectionText[graphId]`は節の一覧(Id / Label / 本文ノード数 / 下位節)。`"Format"->"JSON"`でJSON文字列(`<|"Section", "Nodes", "Nested", "Edges"|>`、ページ無し)を返します。

```wolfram
SlideGraphSectionText[graphId]
SlideGraphSectionText[graphId, "s3"]
```

### 9.3 推敲・取り込み・共有知識・翻訳

#### `SlideGraphRefine`

`SlideGraphRefine[]` / `SlideGraphRefine[nb, opts]` / `SlideGraphRefine[graphId, opts]`は第一次KG(`SlideGraphSeed`)を節ごとに磨きます。既定(`"Mode"->"Direct"`)はLLMを節ごとに直接呼ぶ連鎖で、未推敲(節一覧で「済」でない)の節を一覧の順に、本文ノード合計`"BatchNodes"`(8)以下の隣接節をまとめて1リクエストにし、節本文を指示に同梱して差分JSON(Nodes(Label / Summary / Points / Talk) / Edges / Remove)を受け取り`SlideGraphIngest[.., "Merge"->True]`で取り込みます(形式違反は1回再問合せ、Idは本文に出た既存IdとBackground/Shared層のIdだけを受理、節とrootはRemoveしない)。Talkは要点(Points)と同じ順の原稿(スライドの箇条書きと原稿を対応させる)。途中で止めても「済」の節を飛ばして再開できます。

`"Mode"->"Talk"`は要点はあるがTalkの無いノードに原稿だけを足す軽い回(推敲済みの古いKG用)。`"Mode"->"Agent"`は従来のエージェント委譲。`"Sections"->{"s3", ..}`で対象を絞る。graphId形式では`"Audience"` / `"Story"`を渡せます。

```wolfram
SlideGraphRefine[nb]
```

#### `SlideGraphIngest`

`SlideGraphIngest[graphId, json, opts]`は知識グラフのJSON(文字列 / 連想)を検証して保存する唯一の書き込み口です。`"Merge"->True`で保存済みKGへの差分取り込み、`"Language"->"en"`で翻訳の併記、`"Link"->True`(既定)で周辺知識ノードを共有background層へ接続します。`Success["GraphIngested", <|NodeCount, EdgeCount, Warnings, ..|>]`またはFailureを返します。

```wolfram
SlideGraphIngest[graphId, json]
```

#### `SlideGraphBackground`

`SlideGraphBackground[]` / `SlideGraphBackground[nb]`はStoryセルの聴き手に足りない周辺知識ノード(前提知識)の追加をエージェントに委譲します。取り込みは`SlideGraphIngest[.., "Merge"->True]`で、共有background層への連結は自動です。

```wolfram
SlideGraphBackground[nb]
```

#### `SlideGraphTranslate`

`SlideGraphTranslate[nb, lang]`は知識グラフのノード単位翻訳をエージェントに委譲します(`SlideGraphIngest[.., "Merge"->True, "Language"->lang]`で併記)。以後`SlideGraphGenerate[.., "Language"->lang]`でその言語のスライドを生成できます(デッキのセル単位英訳`SlideTranslate`とは独立です)。

```wolfram
SlideGraphTranslate[nb, "English"]
```

### 9.4 計画・生成・適用・調整

#### `SlideGraphBuild`

`SlideGraphBuild[]` / `SlideGraphBuild[nb, "Mode" -> Automatic | "Agent" | "Extract"]`はReferencesの和訳ノートブックから`SlideGraphSeed`で第一次KGを決定的に作って保存し、続けて節ごとの推敲を行います。既定は`SlideGraphRefine`のDirect連鎖(LLMを節ごとに直接呼ぶ)、`"Agent"`は推敲をエージェント(ClaudeEval)に委譲、`"Extract"`は和訳ノート無しでPDFをエージェントに読ませる旧経路です。和訳ノートが無ければFailure(`NoSourceNotebook`)で`DocImportPaper`を案内します。文献に和訳ノートが無く(またはStoryに`Source:`シナリオ)、プロンプトセルに筋書きがあれば、筋書きからKGを作ります(`SlideGraphSeedScenario` → 関連研究の候補`SlideGraphRelated`(Storyの`Survey:` local | web | off) → 筋書きの展開)。

```wolfram
SlideGraphBuild[nb]
SlideGraphBuild[nb, "Mode" -> "Agent"]
```

#### `SlideGraphPlan` / `SlideGraphPlanView`

- `SlideGraphPlan[nb | graphId | kg, opts]` — 知識グラフから順序木とスライド計画を決定的に作ります。オプション: `"Slides"` / `"Seconds"` / `"Audience"` / `"Strategy"`(`Source`|`Coherent`|`Importance`|`Difficulty`) / `"SecondsPerSlide"` / `"Language"`(未指定はStoryセル)。戻り値`<|"Graph", "Tree", "Plan", "Verify", "Spec"|>`。
- `SlideGraphPlanView[nb | graphId, opts]` — 計画のDataset(番号 / タイトル / 詰め込んだ子 / 秒 / フラグ)。オプションは`SlideGraphPlan`と同じです。

```wolfram
plan = SlideGraphPlan[nb, "Slides" -> 12, "Strategy" -> "Coherent"];
SlideGraphPlanView[nb]
```

#### `SlideGraphGenerate`

`SlideGraphGenerate[nb | graphId | kg, opts]`は計画をシナリオMarkdownに投影し、図資産(NotebookFigure / Formula / PDFFigure / DeckSlide)を`SlideNotebookFigure` / `SlideNotebookFormula` / `SlidePDFFigure` / `SlideDeckFigure`で実体化します。戻り値`<|"Markdown", "Figures", "Plan", "Tree", "Outline", "Warnings", "SlideCount"|>`。オプションは`SlideGraphPlan`と同じ+`"Language"` / `"Talks"`(枚ごとの原稿の差し替え) / `"Title"`。

```wolfram
gen = SlideGraphGenerate[nb, "Slides" -> 12];
```

#### `SlideGraphApply`

`SlideGraphApply[]` / `SlideGraphApply[nb, opts]`は知識グラフから生成したスライド群をデッキへ適用します(10枚ずつ`SlideDeckInsertScenario`を呼びます)。`"Mode"->Automatic`(既定)は、前回KGから作った枚(題目セルの`CellTags`に`"KGNode:<id>"`)があれば`"Replace"`(質疑応答セルをKGのノードへ保存してから前回の枚を消し、同じ位置に作り直す。問答は新しい枚へ戻る)、無ければ`"Append"`(最後のスライドの後、`"After"->n`で位置指定)。`"Polish"->True`ならtalkの推敲をエージェントへ委譲し、エージェントが`SlideGraphApply["Talks"->{..}]`で適用します。

```wolfram
SlideGraphApply[nb]
```

#### `SlideGraphAdjust`

`SlideGraphAdjust[]` / `SlideGraphAdjust[nb]`は、生成のあとで直したいことを調整セル(`SlideAdjust`)に書いて知識グラフへ反映します(パレットの「調整」)。調整セルが無ければ入れます。`SlideGraphAdjust[nb | graphId, "指示"]`は指示を直接渡します。LLMがKGの差分(スライドの追加・文の修正・スライドから外す・図の指定)を返し、反映後に「生成」で作り直します。

オプション: `"PDF"`(論文PDFのlocator、既定は文献欄から) / `"Then"`(反映後に呼ぶ関数) / `"Refine"`(既定False = 未推敲の節を先に推敲する。v1.29: 推敲されていない節があれば先に推敲してから反映)。指示にスライド番号(「43以降」「17枚目」)があれば、その枚のノードの元の本文をLLMに渡します。

```wolfram
SlideGraphAdjust[nb]
```

#### `SlideInsertAdjust`

`SlideInsertAdjust[]`は調整セル(`SlideAdjust`)を入れます。`Working`で見え、`SlideShow`と書き出しでは隠れます。

```wolfram
SlideInsertAdjust[]
```

### 9.5 閲覧

#### `SlideGraphVisualize` / `SlideGraphViewer`

- `SlideGraphVisualize[nb | graphId | kg, opts]` — 知識グラフの図を返します(`SourceVaultKGVisualize`へのつなぎ)。デッキを渡すとStoryセルの聴き手・枚数で計画を立てて枚番号(#n)を重ねます(`"Plan"->Automatic|True|False|計画`)。オプションは`SourceVaultKGVisualize`と同じ: `"View"->"Story"|"Sections"|"Focus"|"Graph"`、`"Focus"`、`"Radius"`、`"EdgeKinds"`、`"Layers"`、`"Labels"`、`"Selected"`、`"OnClick"`、`"Legend"`、`"Hidden"`、`"Language"`。
- `SlideGraphViewer[]` / `SlideGraphViewer[nb | graphId]` — 知識グラフを見る窓を開きます(パレットの「KG図」)。表示(話の流れ / 節 / 周辺 / 計画 / 一覧)、辺と層の絞り込み、計画の重ね書き、名前の量、周辺の半径を切り替えられ、図のノードをクリックすると右に中身(導入文・要点・補足・原稿・図・質疑応答・出典・本文・つながり)が出ます。ボタン: 周辺を見る / スライドへ(その枚、詰め込まれていれば詰め込み先の枚の題目へ移動) / 調整に書く(調整セルに「題目」(Id):を足す)。検索欄で一覧を絞れます。「更新」でKGを読み直します。

```wolfram
SlideGraphViewer[nb]
```

#### `SlideGraphView` / `SlideGraphShow` / `SlideGraphLoad`

- `SlideGraphView[nb | graphId]` — 知識グラフのノード一覧Dataset。`SlideGraphView[src, "Map"]`は`SlideGraphVisualize`の図、`SlideGraphView[src, "Graph"]`はWL Graph、`"Tree"`は順序木のDataset、`"Plan"`は計画のDataset。
- `SlideGraphShow["Plan" | "Nodes" | "Graph" | "Tree"]` — 開いているデッキのAppendix(終端マーカー以降)に知識グラフの表示を書き出します(パレットの「計画」「KG表示」)。
- `SlideGraphLoad[nb | graphId]` — 保存済みの知識グラフ連想を返します(nbならStoryセルのGraph:から)。

```wolfram
SlideGraphView[nb]
SlideGraphView[nb, "Map"]
SlideGraphShow["Plan"]
```

### 9.6 デッキ生成・複数文献の統合

#### `SlideGraphBuildDeck`

`SlideGraphBuildDeck[graphId | kg, "deck.nb", opts]`は知識グラフから新しいデッキファイルを生成します(headless可)。オプションは`SlideGraphGenerate`と同じ+`"TitleSlide"` / `"Event"` / `"Author"` / `"Date"`。戻り値`<|"File", "Slides", "Warnings", "Verify", "Plan"|>`。

```wolfram
SlideGraphBuildDeck[graphId, "C:\\slides\\survey.nb", "Slides" -> 15]
```

#### `SlideGraphSurvey`

`SlideGraphSurvey[{graphId1, graphId2, ..}, "deck.nb", opts]`は複数の知識グラフを合成(共有background層を統合、論文間にRelatedTo辺を付与)してサーベイデッキを生成します。オプション: `"Title"` / `"Slides"` / `"Seconds"` / `"Audience"` / `"Language"` / `"Chronological"` / `"GraphId"` / `"Save"`(合成KGを保存、既定True)。

```wolfram
SlideGraphSurvey[{graphId1, graphId2}, "C:\\slides\\survey.nb"]
```

#### `SlideGraphRelated`

`SlideGraphRelated[nb | graphId, opts]`はシナリオKGの関連研究の候補を集めてKGの`"Related"`に保存します(非同期)。LLMが筋書きから検索語(短い語句4〜8個)を作り、`SourceVaultSummaries`(取り込み済みの論文・Eagle)で探します。`"Web"->True`(Storyの`Survey: web`)のときだけ`SourceVaultWebSearch`も使います(検索語が外に出るため)。PrivacyLevel >= 0.5の候補はデッキのPrivacyLevelがそれ以上のときだけ残します。

オプション: `"Web"`, `"MaxCandidates"`(20), `"Then"`(終わったら呼ぶ関数), `"Audience"`, `"Story"`。結果は`SlideWorkflow`\``Private`\`$iSWRelatedLast`に入ります。

```wolfram
SlideGraphRelated[nb]
```

---

## 10. 発表原稿・読み上げ・リモート操作

スライドの「中身」ではなく「話す原稿」を扱うレイヤーです。1枚ずつ独立に説明文を作ると発表としての流れが出ないため、原稿はデッキ全体を1度に見て書きます。読み上げには、SourceVaultのローカル音声資産(Piper)またはクラウドのリアルタイム音声応答(OpenAI Realtime)を使えます。

### 10.1 発表原稿シナリオ(talk markdown)

発表原稿は次のMarkdown形式で表します。

```
---
Title: / Aliases: / Event: / Author: / Date: / SlideURL: / SecondsPerSlide: ...
---
# Opening
本文...
## 1 スライドタイトル {seconds=30}
本文...
# Closing
本文...
```

#### `SlideTalkFromMarkdown` / `SlideTalkToMarkdown`

`SlideTalkFromMarkdown[md]`(`File[path]`可)は発表原稿Markdownを連想リストへ解析します。戻り値: `<|Title, Aliases, Event, Author, Date, SlideURL, Deck, Language, NarrationInstructions, SecondsPerSlide, PrivacyLevel, Opening, Closing, Slides, Meta|>`。`SlideTalkToMarkdown[talk]`は逆にMarkdownへ戻します(ラウンドトリップ用)。

```wolfram
talk = SlideTalkFromMarkdown[File["lecture1_talk.md"]];
SlideTalkToMarkdown[talk]
```

#### `SlideTalkSkeleton`

デッキの箇条書きから、LLMなしで決定論的な発表原稿の骨格Markdownを作ります。

オプション: `"Title"`, `"Aliases"`, `"Event"`, `"Author"`, `"Date"`, `"SlideURL"`, `"SecondsPerSlide"`, `"Language"`, `"NarrationInstructions"`, `"PrivacyLevel"`

```wolfram
SlideTalkSkeleton["lecture1.nb", "Title" -> "講義1"]
```

#### `SlideTalkPrompt`

デッキ全体から「流れのある発話原稿」を書かせるLLMプロンプトを返します。

```wolfram
SlideTalkPrompt["lecture1.nb"]
```

#### `SlideTalkBuild`

発表原稿を生成して`<deck>_talk.md`へ書き出します(v1.30: パレットからは外しました。原稿の正本はトークセルで、原稿の無い枚を埋めるのは`SlideTalkFill`です)。LLMが使えるときは非同期(`SlideExpand`と同じ経路)で、使えないときは骨格を同期で書きます。

オプション: `"Output"`, `"UseLLM"`, `"Notebook"`, `"OpenResult"` と`SlideTalkPrompt`のオプション。

```wolfram
SlideTalkBuild["lecture1.nb"]
```

#### `SlideTalkFill`

`SlideTalkFill[]` / `SlideTalkFill[nb]`は原稿(トークセル)の無いスライドにだけ原稿を書きます(パレットの「発表の準備」の「原稿」)。LLMがデッキ全体の流れを見て8枚ずつ書き、各スライドのトークセルに入れます(質疑応答セルがあればその前)。全枚に原稿があれば何もしません(原稿を`_talk.md`へ書き出すのは`SlideTalkBuild`)。

```wolfram
SlideTalkFill["lecture1.nb"]
```

#### `SlideTalkFile`

発表原稿の規約パス`<deck>_talk.md`を返します(トークセルの無い旧デッキ用のフォールバック)。

```wolfram
SlideTalkFile["lecture1.nb"]
```

#### `$SlideTalkSecondsPerSlide`

発表原稿シナリオの既定の1枚あたり秒数(既定25)。

```wolfram
$SlideTalkSecondsPerSlide = 25.;
```

#### `SlideInsertTalk`

トークセル(`SlideTalk`スタイル、そのスライドの発表原稿)を挿入します。各スライドの最後に置きます。`Working`で可視、`SlideShow`環境では非表示、書き出しからも除外されます。シナリオmdでは`"talk: 発表原稿"`行に対応します。全スライドにトークがあると、`SlideTalkBuild`(パレットの「シナリオ」)がLLMなしで`<deck>_talk.md`を束ねられます。

```wolfram
SlideInsertTalk[]
```

#### `$SlideTalkPerSlide`

既定`True`。展開プロンプトが各スライド末尾に`talk: `発表原稿(です・ます調 2〜6文)を要求し、スライド本文は図表+体言止め中心に絞ります(スライドとトークで解説が完成する分業)。`False`で従来どおり。

```wolfram
$SlideTalkPerSlide = False;
```

### 発表原稿の言語(多言語原稿)

原稿は元の言語を残したまま、言語ごとの訳のトークセルを同じスライドに並べて複数言語を併用できます。

#### `SlideTalkLanguage` / `$SlideTalkLanguage`

- `SlideTalkLanguage[nb]` — そのデッキを読み上げる言語コード(`"ja"` / `"en"` …)を返します。優先順は、指示セルの`Language:` > `SlideTalkMeta`の`Language` > `$SlideTalkLanguage` > `$Language`です。
- `$SlideTalkLanguage` — 発表を読み上げる言語の既定(`"en"` / `"English"` / `"英語"`など)。既定`Automatic`なら`$Language`。デッキの指示セルに`Language:`行があればそちらが優先されます。

```wolfram
SlideTalkLanguage["lecture1.nb"]
$SlideTalkLanguage = "English";
```

#### `SlideTalkLanguages`

`SlideTalkLanguages[nb]`は原稿の言語の状況`<|"Language"(話す言語), "Base"(元の原稿の言語), "Slides", "Translated"(言語ごとの訳の枚数), "Missing"(話す言語の訳が無い枚), "Stale"(元の原稿を直した後の古い訳)|>`を返します。番号0は前置きです。

```wolfram
SlideTalkLanguages["lecture1.nb"]
```

#### `SlideTalkTranslate`

`SlideTalkTranslate[nb]`は元の原稿(トークセル)をLLMで訳し、同じスライドに訳のトークセル(`TaggingRules`の`SWTalkLang`)を並べます。元の原稿は残るので複数言語を併用できます。訳す言語は、指示セルの`Language:`(または`SWTalkMeta` / `$SlideTalkLanguage`)の指定に従います。

```wolfram
SlideTalkTranslate["lecture1.nb"]
```

### 読みの辞書(読みセル)

読み上げ(gpt-realtime・ローカルの声)のときだけ、語を仮名に置き換えて誤読を防ぐ仕組みです(v1.51)。スライド・字幕・原稿の文面は書き換えません。置き換えるのは日本語の文だけで、長い語から順に置き換えます。1文字の語(「節」など)は前後が漢字でないときだけ、英字だけの語は単語の境目でだけ置き換えます。数式・強調の印は外してから置き換えます。

読みの辞書は2段構えです。

- **デッキの読みセル**(`SlideInsertReading[]`で挿入) — そのデッキだけの読み。1行1語`語 = よみ`、`#`から行末はコメントです。区切りは`=`・`＝`・`→`・`->`・タブも使えます。
- **全デッキ共通の読み**(`SlideReadingFile[]`のファイル) — UTF-8テキストで1行1語`語 = よみ`。同じ語はデッキ側が優先されます。

```
# 例
慣性モーメント = かんせいもーめんと
GPU = じーぴーゆー
```

#### `SlideReadings` / `SlideReadingApply`

- `SlideReadings[]` / `SlideReadings[nb]` — 読み上げに使う読みの辞書`<|語 -> よみ|>`を返します(全デッキ共通の読み+デッキの読みセル。同じ語はデッキ側が優先)。`SlideReadings["Global"]`は共通の読みだけです。
- `SlideReadingApply[text]` / `SlideReadingApply[nb, text]` / `SlideReadingApply[text, readings]` — 声に渡す文(数式・強調の印を外し、読みの辞書の語を仮名に置き換えたもの)を返します。

#### `SlideReadingFile` / `$SlideReadingFile` / `SlideReadingAdd`

- `SlideReadingFile[]` — 全デッキ共通の読みの辞書ファイルのパスを返します。無ければよく誤読される語を入れて作ります。
- `$SlideReadingFile` — そのファイルの場所。既定`Automatic`はSourceVaultの`slidedecks/readings.txt`(PC間で共有)で、SourceVaultが無ければ`$UserBaseDirectory/ApplicationData/SlideWorkflow/readings.txt`です。
- `SlideReadingAdd["語" -> "よみ"]` / `SlideReadingAdd[{rules..}]` — 全デッキ共通の読みに語を足します(同じ語があれば読みを置き換えます)。そのデッキだけの読みは読みセルに書きます。

#### `SlideReadingCheck`

`SlideReadingCheck[]` / `SlideReadingCheck[nb]`は、原稿(トークセル)をLLMに見せ、声に出すと読み間違えやすい語(専門用語・同じ字で読みが変わる語・固有名詞など)とその読みの案を、デッキの読みセルへ書き足します(パレットの「読みチェック」、非同期)。辞書にある語は除きます。**案は確かめてから使ってください**(要らない行は消すか、行頭に`#`を付けます)。

```wolfram
SlideInsertReading[]
SlideReadingAdd["GPU" -> "じーぴーゆー"]
SlideReadings[nb]
SlideReadingApply[nb, "GPUの慣性モーメント"]
SlideReadingCheck[nb]
```

### 質疑応答セル (パレットの「質疑」)

`SlideInsertQA[]`で、トークセルの隣にそのスライドで訊かれそうな質問と回答を書くセル(`SlideQA`スタイル、mdでは`"qa: "`行)を挿入します。見え方と書き出しの扱いはトークセルと同じです(`Working`で可視、`SlideShow`で非表示、画像・mp4の書き出しからも除外)。

```
Q: 想定質問
A: そのまま読み上げられる回答
cite: sv://... または出典テキスト
PL: 0.6
```

`Q:` が来るたびに新しい 1 問で、接頭辞の無い行は直前の項目の続きです。`cite:` と `PL:` は省略できます(`PL:` を書くとその 1 問だけ非公開扱いになり、発表モードでは答えません)。

下書きは「QA 生成」で LLM に作らせられます。内容は必ず自分で確かめて直してください。「QA 一覧」で全体と、スライドごとの状態を表で見られます。

#### `SlideQAGenerate`

`SlideQAGenerate[nb]`はLLMで想定問答の下書きを質疑応答セルへ書き込みます(非同期、1枚ずつ順に)。書いたあとは人が直すことが前提です。

`"Mode"`の3つ:
- `"Regenerate"`(パレット上は1) — 全スライドを作り直します。既存の質疑応答は捨てます(`SlideQAGenerateAll`と同じ)。
- `"Update"`(2) — 全スライドを見直します。既存をLLMに見せ、活かしたまま直させます(`SlideQAUpdateAll`と同じ)。
- `"Changed"`(3、既定) — 質疑応答セルの無いスライドと、質疑応答を書いたあとで直したスライドだけを更新します。パレットの「QA 生成」はこのモードです。

**変わった分だけ**: 変更の判定はセル先頭の`"# slide: <ハッシュ>"`行(自動で付く、書いた時点のスライドの印)で行います。セルに付いて回るので、スライドを並べ替えても対応は崩れません。このマーカーの無い手書きのセルは`"Changed"`では触りません。全枚に手を入れたいときは`SlideQAGenerateAll`/`SlideQAUpdateAll`を使います。

**図や写真のあるスライド**: そのスライドを描画した画像をLLMに渡すので、本文に書いていない「図に何が描かれているか」(軸や系列、写っているもの)についての問答も作られます(`"Vision"`、既定`$SlideQAVision = True`)。画像はデッキの隣の`<deck>_qa_images`フォルダにキャッシュされるので、二度目からは描画しません。デッキを保存してから実行してください(未保存だと描画できず、テキストだけになります)。

オプション: `"Mode"`, `"QuestionsPerSlide"`(既定`$SlideQAPerSlide = 3`), `"Vision"`, `"Slides"->All`または`{n..}`

全枚に手を入れたいときは専用関数を使います。

```wolfram
SlideQAGenerateAll[nb]   (* 全スライドを作り直す。既存は置き換え。SlideQAGenerate[nb, "Mode" -> "Regenerate"] と同じ *)
SlideQAUpdateAll[nb]     (* 全スライドを見直す。既存は活かし、ものだけ直す。SlideQAGenerate[nb, "Mode" -> "Update"] と同じ *)
SlideQAStateView[nb]     (* どの枚が未作成・要更新かを Dataset で表示 *)
```

#### `SlideQAEntries` / `SlideQAView`

- `SlideQAEntries[nb]` — デッキ内の質疑応答セルを`<|"SlideCount", "Questions", "Answered", "Missing"(質疑応答セルの無いスライド), "Slides"|>`にして返すコア関数です。
- `SlideQAView[nb]` — 質疑応答セルの中身を1行1問の`Dataset`で表示します(パレットの「QA一覧」)。

```wolfram
SlideQAEntries["lecture1.nb"]
SlideQAView["lecture1.nb"]
```

#### `SlideQAMarkCurrent`

`SlideQAMarkCurrent[nb]`は、既にある質疑応答セルに今のスライドの印(`# slide: `行)だけを打ちます。LLMを使わず、問答の文面は変えません。このマーカーの無い古いデッキを「QA生成」(変更分のみ)の対象に乗せるための土台です。**今の中身を「確認済み」と宣言する操作**なので、中身を見てから使ってください。

```wolfram
SlideQAMarkCurrent["lecture1.nb"]
```

#### `$SlideQAVision` / `$SlideQAPerSlide`

- `$SlideQAVision` — 既定`True`。図・写真・表を含むスライドのQA生成で描画画像をLLMに添付するかどうか。画像は`<deck>_qa_images/`にスライドのハッシュでキャッシュされます。
- `$SlideQAPerSlide` — `SlideQAGenerate`が1枚あたりに作る想定質問の数(既定3)。

```wolfram
$SlideQAVision = True;
$SlideQAPerSlide = 3;
```

「登録」を押すと、このセル群が gpt-realtime から引ける形(SourceVault の QA パック)に焼かれ(`SlideQABuild`)、発表中に声で訊かれたときの即答に使われます。**回答の空な問は焼かれません**(作り置きに当たってしまうと、資料側に答えがあっても届かないため)。

#### `SlideQABuild` / `SlideQAFromPack`

- `SlideQABuild[nb]` — 質疑応答セルをSourceVaultのQAパックへ焼き、発表中のgpt-realtimeが数十msで引けるようにします(`SourceVaultTalkQAImport`へ委譲)。「登録」から自動で呼ばれます。オプション: `"PrivacyLevel"`, `"Ingest"`(既定True=KBへも取り込む), `"Enrich"`(既定True=回答が空の問だけKBから補う)。
- `SlideQAFromPack[nb]` — すでに登録済みのQAパック(以前に`SourceVaultTalkQABuild`でLLMから作ったものを含む)を、スライドの質疑応答セルへ書き戻します。セルが正本になったあとも、古い作り置きを捨てずに人が直せる形へ移せます。LLMは使いません。オプション: `"Rebuild"`(既定False=既に質疑応答セルのあるスライドは触らない)。

```wolfram
SlideQABuild["lecture1.nb"]
SlideQAFromPack["lecture1.nb"]
```

### 「登録」は変わった分だけ

「登録」は登録簿・QA パック・mp4 の 3 つを見ますが、変わっていないものはやり直しません。mp4 の判定はファイル日付ではなく「スライドとして描かれるセルの並び」で行うので、トークや質疑応答セルを直しただけなら mp4 は作り直されません。スライドを並べ替えた・挿入した・削除したときは列が変わるので必ず作り直されます。何がやり直されるかは `SlideDeckChangeStatus[]` で見られます。

#### `SlideDeckChangeStatus`

`SlideDeckChangeStatus[nb|deck.nb]`は「登録」が何をやり直すか(スライドの並びのハッシュ、mp4が古いか、QAが焼き直されるか)を返します。「登録しても何も起きない」ときの切り分けに使います。

```wolfram
SlideDeckChangeStatus["lecture1.nb"]
```

#### `SlideDeckMarkVideoCurrent`

`SlideDeckMarkVideoCurrent[nb|deck.nb]`は、今ある`<deck>.mp4`を「今のスライドで作られたもの」として記録します。既存のデッキをこの仕組みへ移すとき、すでに配信済みのmp4を1回だけ作り直すのを避けるためのものです。**スライドを直したのに呼ぶと、古いmp4が最新扱いで固定される**ので、見た目が一致しているときだけ使ってください。

```wolfram
SlideDeckMarkVideoCurrent["lecture1.nb"]
```

### 10.2 発表登録簿(SourceVault連携)とアップロード

#### `SlideTalkMeta`

`SlideTalkMeta[nb]`はデッキ単位の発表メタ(`Title` / `SlideURL` / `UploadURL` / `PosterURL` / `Aliases` / `PrivacyLevel` / `Language`など)を返します。取得元は次の優先順です: デッキ先頭の指示(Directive)セルの`Key: value`行(`Title:` / `SlideURL:` / `PosterURL:` / `Language:` / `Host: sftp://user@host/dir` / `PosterHost:`) > ノートブックの`TaggingRules`の`"SWTalkMeta"` > `_talk.md`のfront matter。

`SlideTalkMeta[nb, "SlideURL" -> url, ...]`はノートブックの`TaggingRules`に永続化します(指示セルに同名の行があればそちらが優先されるため、登録簿への登録が`_talk.md`無しで完結します)。

```wolfram
SlideTalkMeta["lecture1.nb"]
SlideTalkMeta["lecture1.nb", "SlideURL" -> "https://slide.example/1234"]
```

#### `SlideDeckRegister`

`SlideDeckRegister[nb|deck.nb|talkfile|md]`は発表(トークセル+指示セルのメタ)をSourceVaultの登録簿へ登録します。メタに`UploadURL`(指示セルの`Host:`行)があれば、Sliden用mp4をwebサーバへ自動でアップロードします(結果は戻り値の`"Upload"`キー)。以後、VRCRealtimeが発表タイトルからスライドURLと原稿を引けます。

同じデッキで再度実行すると、前回のエントリを土台に今回与えた値だけを上書きします(前回の特定は`Id` > `DeckFile` > `SlideURL` > `PosterURL`の順。指示セルの`Id:`行で固定できます)。何が変わったかは戻り値の`RegistryStatus`(`"Created"`|`"Updated"`)と`ChangedKeys`で分かります。

**ポスター(v1.56)**: 指示セルに`PosterURL:`(ポスターPDFを置くURL)があれば、`<deck>_poster.pdf`も配置します(結果は戻り値の`"PosterUpload"`キー)。配置先は`PosterHost:`、無ければ`Host:`です。`SlideURL`か`PosterURL`のどちらかがあれば登録でき、両方あれば両方を扱います。

オプション: `"SlideURL"`, `"Title"`, `"Id"`, `"DeckFile"`, `"PrivacyLevel"`, `"SlideCount"`, `"Upload"`(`Automatic`|`True`|`False`)

```wolfram
SlideDeckRegister["lecture1.nb", "SlideURL" -> "https://slide.example/1234"]
```

#### `SlideDeckRegistry`

登録済み発表エントリの一覧を返します。

```wolfram
SlideDeckRegistry[]
```

#### `SlideDeckUpload`

`SlideDeckUpload[nb|deck.nb|deck.mp4]`は、Sliden用mp4(`<deck>.mp4`)を発表メタの`UploadURL`(指示セルの`Host: sftp://user@host/dir`行)へsftpで送り、`SlideURL`のHEADで配信を確認します。同じサイズで配信中のファイルは送りません(`"Force"->True`で強制送信)。`SlideDeckRegister`から`UploadURL`があれば自動で呼ばれますが、単独でも呼べます。

デッキがmp4より新しければ書き出し直してから送ります(`"ExportVideo"->False`で抑止、`True`で常に作り直します)。転送手段は`$SlideUploadMethod`に従います(既定`Automatic`は`"Native"`を試し、だめなら`"curl"`)。パスワードは`SlideUploadCredential`で保存したものをNBAccess管轄のSystemCredentialから取得します。

オプション: `"UploadURL"`, `"SlideURL"`, `"File"`, `"Method"`(`Automatic`|`"Native"`|`"curl"`), `"Password"`, `"User"`, `"Force"`, `"Verify"`, `"ExportVideo"`, `"Interactive"`

```wolfram
SlideDeckUpload["lecture1.nb"]
SlideDeckUpload["lecture1.nb", "Force" -> True]
```

#### `SlideUploadCredential` / `SlideUploadCredentialQ` / `$SlideUploadMethod`

- `SlideUploadCredential[url|nb]` — sftpのパスワードをダイアログで尋ね、NBAccess経由でSystemCredentialに保存します(名前は`sftp://user@host`)。`SlideUploadCredential[url, password]`で直接保存、`SlideUploadCredential[url, None]`で削除できます。
- `SlideUploadCredentialQ[url|nb]` — sftpのパスワードが保存済みかどうかを返します(値そのものは返しません)。
- `$SlideUploadMethod` — mp4の転送手段。既定`Automatic`は`"Native"`(`CopyFile`->`RemoteFile`、WL組込み)を試し、使えなければ`"curl"`(Git for Windows同梱のsftp対応curl)。

```wolfram
SlideUploadCredential["sftp://user@host"]
SlideUploadCredentialQ["lecture1.nb"]
$SlideUploadMethod = "curl";
```

### 10.3 ローカル音声読み上げと自動ページ送り

`<deck>_talk.md`の原稿をSourceVaultのローカル音声(Piper)で読み上げながら、1枚読み終わるごとにスライドを1枚進めます。対象はスクリーン環境が`SlideShow`のノートブックです。合成結果は`<deck>_voice/`にキャッシュするため、2回目以降の再生は待たされません。ウィンドウのスナップショットやクリップボードには依存しないため、FEを止めずに裏で動きます。声に渡す文には読みの辞書(10.1の「読みの辞書」)が適用されます。

#### 音声関連の定数

```wolfram
$SlideVoice              (* 読み上げに使うボイスモデル名。既定 Automatic は SourceVaultVoice[] の既定の声。SlideVoices[] で候補一覧 *)
$SlideVoiceGap            (* スライドを読み終えてから次へ送るまでの間(秒、既定 0.8) *)
$SlideRenderSettle        (* 次のスライドを表示してから読み上げを始めるまでの間(秒、既定 0.6)。重いスライドの描画中に鳴らし始めると音が止まるため、描画が落ち着くのを待つ。0 で待たない *)
$SlidePrepareBeforePlay   (* True(既定)なら SlidePlay は再生開始前に未合成の全スライド分をローカル音声で用意する(再生中に合成を走らせると音が途切れるため)。False で従来の1枚先読み *)
$SlideQuestionSeconds     (* 1枚読み終えてから次へ送るまでに質問を待つ秒数(既定 3)。クラウド音声(realtime:)のときだけ有効 *)
$SlideVoiceInputGate      (* 質問受付でマイクを送る下限の音量(0〜1、既定 0 = 制限なし) *)
$SlideQuestionMaxSeconds  (* 1枚の合間に質疑で留まれる上限の秒数(既定 60) *)
$SlideVoiceTick           (* 読み上げ進行を見るカーネル側ScheduledTaskの周期(秒、既定 0.3) *)
$SlidePlayAnswering       (* realtime: の声で再生するときに質問(音声応答)を受けるか。Automatic(既定) | True | False。下記参照 *)
$SlideReadingFile         (* 全デッキ共通の読みの辞書ファイル。既定 Automatic = SourceVault の slidedecks/readings.txt *)
$SlideRealtimeVoices      (* ボイスモデルのトグルに並べるクラウド音声(OpenAI Realtime)の声名(既定 {"marin","cedar"})。一覧には "realtime:<声>" として出る *)
$SlideVoiceModel          (* 音声会話のモデル。既定 Automatic = $SlideVoiceDefaultModel (gpt-live-1。v1.36 から。そのプロバイダの一覧に無ければ $SourceVaultRealtimeModel)。"gpt-realtime-2.1" などを直接指定もできる。パレット「音声モデル」行 *)
$SlideVoiceDefaultModel   (* $SlideVoiceModel が Automatic のときに使うモデル(既定 "gpt-live-1")。SourceVault 全体の既定($SourceVaultRealtimeModel)は変えない *)
$SlideVoiceProvider       (* 音声会話のプロバイダ。既定 Automatic = 登録簿の先頭("OpenAI")。候補は SlideVoiceModels[] のキー。パレット「音声プロバイダ」行 *)
$SlideQuestionMode        (* 発表中の質問の受け方。"QuestionTime"(既定) | "Words" | "Detect"。詳細は 10.4 *)
$SlideInterruptWords      (* "Words" モードで発表を止めてよい語のリスト(既定 Automatic = $SourceVaultRealtimeInterruptWords = {"質問","スライド"}) *)
$SlideSpeechRate          (* 話速(1秒あたりの文字数)をエンジンごとに持つ連想。既定 <|"Local"->6.95, "Realtime"->5.6|>。SlideTalkDuration が使う *)
$SlideSpeechLatency       (* 1枚あたり声が出るまでの待ち(秒)をエンジンごとに持つ連想(既定 Local 0.3 / Realtime 1.5) *)
```

#### `$SlidePlayAnswering`

`realtime:`の声で再生するときに質問(音声応答)を受けるかどうかです(v1.52、v1.53)。

- `Automatic`(既定) — 再生を押したときの状態に従います。「応答on」かつマイクonなら質問を受け(各枚のあとの質問タイム)、それ以外は読み上げだけです(マイクは閉じたまま)。再生は「応答on/off」の表示を変えません。応答offから再生すると、音声会話は読み上げのためだけに起き、表示は「応答off」のまま、再生が終わると閉じます。再生中はマイクボタン(と手元リモコン)で質問を受けるかを切り替えられます: マイクon = 質問タイムあり、マイクoff = 読み上げだけ。
- `True` — いつも質問を受けます(v1.51までの動き)。
- `False` — いつも読み上げだけです(再生の間はマイクを閉じ、終わったら戻します)。

```wolfram
$SlidePlayAnswering = Automatic;
```

#### `SlideVoices` / `SlideCycleVoice` / `SlideVoicePrepare`

- `SlideVoices[]` — 選べるボイスモデル名の一覧を返します(`SourceVault_voice.wl`が読み込まれていなければ`{}`)。
- `SlideCycleVoice[]` — `$SlideVoice`を次のボイスモデルへ切り替えます(パレットのトグル)。
- `SlideVoicePrepare[]` — 発表原稿全スライドの音声を先に合成して`<deck>_voice/`にキャッシュします。`SlideVoicePrepare[nb]`で対象指定。

```wolfram
SlideVoices[]
SlideCycleVoice[]
SlideVoicePrepare["lecture1.nb"]
```

#### `SlidePlay` / `SlidePause` / `SlideStop`

- `SlidePlay[]` — `<deck>_talk.md`の原稿をSourceVaultのローカル音声で読み上げながらスライドを自動で進めます(ノートブックのスクリーン環境が`SlideShow`のとき)。既定(`$SlidePrepareBeforePlay=True`)では、再生開始前に未合成のスライド分をまとめて音声合成してから読み上げを始めます(`False`で従来の1枚先読み)。一時停止中に呼ぶと再開します。`SlidePlay[nb]`で対象ノートブックを指定。
- `SlidePause[]` — 読み上げを一時停止します。`SlidePlay[]`で続きから再開します。
- `SlideStop[]` — 読み上げを止めて再生状態を初期化します。

```wolfram
SlidePlay["lecture1.nb"]
SlidePause[]
SlideStop[]
```

#### `SlideShowSlide` / `SlideCurrentNumber` / `SlideTitles` / `SlideIndex`

- `SlideShowSlide[spec]` — 表示するスライドを変えます。`spec`は番号、`"Next"`/`"Previous"`/`"First"`/`"Last"`、または見出しや本文に含まれる語(文字列)。音声からの「一つ前のスライド」「三枚目」「バードバスのスライド」もこの関数を通ります。
- `SlideCurrentNumber[]` — 今画面に出ているスライド番号を返します。
- `SlideTitles[]` — 開いているデッキの見出し一覧を返します(`SlideTitles[nb]`で対象指定)。
- `SlideIndex[]` — 発表の索引をDatasetで返します(番号・見出し・字数・推定秒数・累計)。各行のShowボタンでそのスライドを表示、Playボタンでそのスライドの音声を試聴できます。`SlideIndex[nb]`で対象指定。オプション: `"Voice"`(既定Automatic)、`"Questions"->True`で質問受付の待ちも累計に入れる。

```wolfram
SlideShowSlide["Next"]
SlideCurrentNumber[]
SlideTitles[]
SlideIndex["lecture1.nb", "Questions" -> True]
```

#### `SlideSpeakSlide` / `SlideInfo` / `SlideTalkDuration` / `SlidePlayStatus`

- `SlideSpeakSlide[n]` — n枚目の原稿を今の声で読み上げます(索引のPlayボタンと同じ)。ローカルの声なら合成してその場で再生し、`realtime:`の声なら動いている音声会話に読ませます。
- `SlideInfo[]` — デッキと発表の情報(枚数・原稿・見積時間・声・音声会話の状態)をまとめたウインドウを開きます(パレットの「情報」と同じ)。
- `SlideTalkDuration[]` — 発表原稿`<deck>_talk.md`から発表にかかる時間を見積もります(質問は無いものとする)。`SlideTalkDuration[nb]` / `SlideTalkDuration["deck.nb"]` / `SlideTalkDuration["deck_talk.md"]`も可。オプション: `"Voice"`(既定Automatic=選択中の声)、`"Questions"->True`で質問受付の待ち時間も足す、`"View"->True`でDataset。ローカル音声で合成済みのスライドはキャッシュの実長を使い、それ以外は文字数と話速から見積もります。
- `SlidePlayStatus[]` — 読み上げ再生の状態`<|Status, Slide, SlideCount, Voice, Notebook, CacheDirectory, LastFailure|>`を返します。

```wolfram
SlideSpeakSlide[3]
SlideInfo[]
SlideTalkDuration["lecture1.nb", "Questions" -> True]
SlidePlayStatus[]
```

### 10.4 クラウド音声応答(Realtime)と質問受付

#### `SlideToggleRealtime` / `SlideToggleMic`

- `SlideToggleRealtime[]` — 音声応答(`SourceVaultRealtimeStart` / `Stop`)を切り替えます。パレットの「応答on/off」と同じです。
- `SlideToggleMic[]` — 音声応答のマイクをmute/unmuteで切り替えます。パレットの「マイクon/off」ボタン、および手元リモコンの「前の曲」ボタンと同じ動作です。音声応答が動いていないときは何もしません。`"Quiet"->True`で知らせのダイアログも出しません(手元リモコンからはこちらで呼ぶ)。v1.53: `realtime:`の声で再生している間は、質問を受けるかどうかを切り替えます(マイクon = 各枚のあとの質問タイムと最後の質疑応答あり、マイクoff = 読み上げだけ)。このとき「応答on/off」の表示は変わりません。

```wolfram
SlideToggleRealtime[]
SlideToggleMic["Quiet" -> True]
```

読み上げ中(`SlidePlay`)は、クラウド音声(`realtime:`)のときだけ`$SlideQuestionSeconds`の間、質問を待ちます(`$SlidePlayAnswering`の設定により質問を受けない場合は待ちません)。話しかけられたら`$SlideQuestionMaxSeconds`まではデッキが止まらずに待ち、答えている最中は打ち切りません。会場の物音で勝手に応答が始まるときは`$SlideVoiceInputGate`を上げて、マイクを送る下限音量を設定します。

なお、スライドの表示に関する依頼(次/前/最初/最後/何枚目/特定の内容のスライド)と、発表の内容や事実についての質問は、いずれもモデルが自分で処理せずバックエンド(SourceVault)へ委譲する設計です。スライド操作と質問応答はどちらも同じ`handler`を介して答え、会話中にセッションのモデル(Realtime / Live)が途中で切り替わることはありません。

#### 音声会話のモデル(gpt-realtime / gpt-live)

パレットの「設定」欄に「音声プロバイダ: OpenAI」「音声モデル: …」の 2 行があり、押すたびに次の候補へ切り替わります。既定のモデルは v1.36 から`$SlideVoiceDefaultModel`(`"gpt-live-1"`)です。関数では次を使います。

- `SlideVoiceModels[]` — プロバイダ -> 選べる音声会話モデルの一覧(SourceVault_realtimeの登録簿。未ロードなら組み込みの既定)。
- `SlideCycleVoiceProvider[]` — `$SlideVoiceProvider`を次のプロバイダへ切り替えます(モデルがそのプロバイダに無ければ既定に戻す)。パレットの「音声プロバイダ」行。
- `SlideCycleVoiceModel[]` — `$SlideVoiceModel`を同じプロバイダの次のモデルへ切り替えます。パレットの「音声モデル」行。
- `SlideSetVoiceModel[model]` — モデルを直接選びます(登録簿にあればプロバイダも合わせる)。`SlideSetVoiceModel[Automatic]`で既定に戻します。

明示的にモデル名を指定した場合は登録簿の一覧になくてもそのまま使えます(未登録の新しいモデルも試せます)。

```wolfram
SlideVoiceModels[]
SlideCycleVoiceProvider[]
SlideCycleVoiceModel[]
SlideSetVoiceModel["gpt-live-1"]
SlideSetVoiceModel[Automatic]
```

- **gpt-realtime-2.1 / -mini**: 1 つのモデルが聞いて考えて話します。スライド操作と資料の問い合わせは関数呼び出し(`show_slide` / `ask_sourcevault`)です。
- **gpt-live-1**(GPT-Live、既定): 聞きながら話せる全二重の音声モデルです。作業は「クライアント委譲」でアプリ側へ回ってきます。スライド操作(「次のスライド」「3枚目を見せて」「〜のスライドを出して」)と発表内容の質問は、ワーカーが書き起こしから依頼を読み取り、Realtime と同じ処理(スライド操作 / SourceVault の資料 / 許可を得てからウェブ)で答えます。手元の資料に無いときは「ウェブで調べてもよいですか」と尋ね、「はい」でウェブを引きます。音声は 1 分 $0.05(秒単位の課金)。「情報」に通話秒数が出ます。モデルには、質疑を開くまで部屋の音を渡しません(スピーカー自身の音声応答の声を、スピーカーの自分の声を拾わないようにするため)。

原稿の読み上げ・質問受付・マイクの操作はどちらのモデルでも同じです。動いている音声会話のモデルは途中で変えられないので、切り替えは「応答off→on」(または次の再生)から効きます。

#### 発表中の質問の受け方(質問タイム / 特定ワード / 二段構え)

パレットの「設定」欄の「質問: …」行で切り替えます。関数では次の3つです。

- `$SlideQuestionMode` — 質問の受け方(`"QuestionTime"` | `"Words"` | `"Detect"`)。
- `SlideCycleQuestionMode[]` — 質問タイム → 特定ワード → 二段構え の順に切り替えます(パレットの「質問: …」行)。
- `SlideSetQuestionMode["QuestionTime" | "Words" | "Detect"]` — 直接指定します。

選んだモードが今のモデルで効かないとき(gpt-live-1 以外での「特定ワード」「二段構え」)は、質問タイムとして動きます。

- **質問タイム**(`"QuestionTime"`、既定・全モデル): 1枚読むごとに`$SlideQuestionSeconds`の間だけ質問を待ちます。読み上げ中はマイクを切ります。
- **特定ワード**(`"Words"`、gpt-live-1のみ): 読み上げ中もマイクを聞き、聞き手が「質問」「スライド」(`$SlideInterruptWords`)を含む言葉で話しかけたときだけ発表を止めます。gpt-liveが「はい、どうぞ」と促し、質疑中は何でも受け付けます。独り言は無視します。
- **二段構え**(`"Detect"`、gpt-live-1のみ): 聞き手の声が0.35秒続いたら発表を止め、質問かどうかはgpt-liveが判断します(独り言なら黙って数秒後に再開)。二段構えは読み上げ中も聞いているため質問タイムの待ちは取りません。

```wolfram
SlideSetQuestionMode["Words"]
$SlideInterruptWords = {"質問", "スライド"};
SlideCycleQuestionMode[]
```

どちらも、スピーカーから出ている自分の声(エコー)より大きい声だけを聞き手の声とみなします。質疑が4秒ほど静かになると、中断した文から「それでは、説明に戻ります」で再開し、質疑中にスライドを動かしていれば元のスライドへ戻します。特定ワードには`SourceVaultRealtimeInstall["Vosk" -> True]`と音声認識モデル(`SourceVaultInstallSpeechModel[]`)が要ります(無い間は二段構えで動きます)。聞き分けの良し悪しは部屋の音響(スピーカーとマイクの位置・音量)に左右されます。エコー除去付きのUSBスピーカーフォンやヘッドセットが最も確実です。マイクoffにすると割り込みも止まります。

### 10.5 手元デバイス(メディアキー)によるリモート操作

Elecom Relaconなどのメディアキーを持つ手元デバイスの見張りを行い、キー入力にマイクのmute/unmuteや読み上げの再生/一時停止を割り当てます。スライドを全画面表示したままでも効きます(フロントエンドのキーイベントを経由しないため)。Windows専用です。

#### `SlideRemoteStart` / `SlideRemoteStop` / `SlideRemoteStatus`

- `SlideRemoteStart[]` — 手元デバイスの見張りを始めます。オプション: `"Bindings"`(既定Automatic = `$SlideRemoteBindings`)、`"Tick"`(見張りの周期。既定`$SlideRemoteTick`)。
- `SlideRemoteStop[]` — 見張りを止めます。
- `SlideRemoteStatus[]` — 見張りの状態`<|Watching, Available, Checked, Bindings, Tick, Hint|>`を返します(状態を見るだけでuser32.dllは開きません)。

```wolfram
SlideRemoteStart[]
SlideRemoteStatus[]
SlideRemoteStop[]
```

#### `SlideRemoteProbe`

「そのボタンがどの仮想キーを出すか」を実測します。呼んでから`"Seconds"`(既定10)の間に手元デバイスのボタンを何度か押すと、反応した仮想キーが一覧で返ります。戻り値の`"Suggestion"`は`$SlideRemoteBindings`への割り当て例です。`"View"->True`でDataset表示。実測の間は見張りを一時的に止め、終わったら元の割り当てのまま戻します。

```wolfram
SlideRemoteProbe["Seconds" -> 15, "View" -> True]
```

#### `$SlideRemoteBindings` / `$SlideRemoteTick` / `$SlideRemoteAuto`

- `$SlideRemoteBindings` — 手元デバイスのボタン(仮想キー)と動作の対応。既定`<|"MediaPrevTrack"->"Mic", "MediaPlayPause"->"Play"|>`(「前の曲」でマイクのmute/unmute、「再生/一時停止」で読み上げの再生/一時停止)。キーは名前(`"MediaNextTrack"`)でも番号(`16^^B0`)でも`"0xB0"`でもよく、どのボタンがどのキーを出すかは`SlideRemoteProbe[]`で実測できます。動作は`"Mic"` | `"Play"` | `"Stop"` | `"NextSlide"` | `"PreviousSlide"` | `"None"`。読めない指定は黙って落とします。
- `$SlideRemoteTick` — 手元デバイスを見張るカーネル側ScheduledTaskの周期(秒、既定0.15)。押下はWindows側に滑る(取りこぼしうる)ので、この値が反応の速さを決めます。
- `$SlideRemoteAuto` — 既定`True`。音声応答(`SlideToggleRealtime`)を始めると同時に手元デバイスの見張りを始め、止めると同時に止めます。

```wolfram
$SlideRemoteBindings = <|"MediaPrevTrack" -> "Mic", "MediaPlayPause" -> "Play",
  "MediaNextTrack" -> "NextSlide"|>;
$SlideRemoteAuto = True;
```

---

## 関連パッケージ

- フォント設定は [NotebookExtensions](https://github.com/transreal/NotebookExtensions) の `$fontFamily` と連携できます。
- 文献検索・PDF資産・知識グラフ・ローカル音声(Piper)・クラウド音声応答・発表登録簿は [SourceVault](https://github.com/transreal/SourceVault) と連携します。
- LLMによる展開・翻訳・知識グラフ推敲の承認ゲート付き実行は [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) を経由します。
- 生成した動画はSlidenやVRChatでの発表用途に[VRChatPresentationUploader](https://github.com/transreal/VRChatPresentationUploader)と組み合わせて利用できます。