# SlideWorkflow ユーザーマニュアル

`SlideWorkflow`は、Markdownや連想リストで書いたシナリオからスライドノートブックを生成し、既存デッキをスライド単位で編集し、16:9画像やSliden用mp4として安定して書き出すためのパッケージです。加えて、スライド作成用パレットからのインタラクティブな編集(スライド追加・LLMによる展開・翻訳・補助セル挿入)、発表原稿(トーク)の作成とSourceVaultのローカル音声/クラウド音声応答による自動読み上げ、手元デバイス(メディアキー)でのリモート操作にも対応します。

導入・環境設定については `setup.md` を参照してください。ここでは各公開関数の使い方を機能別に説明します。

---

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

旧`SlideWorkflow_interactive.wl`が本パッケージに統合されたレイヤーです。スライドノートブックを実機(フロントエンド)で編集しながら、パレットのボタンからスライド追加・LLMによる本文展開・翻訳・各種補助セルの挿入を行えます。ここで挿入・生成されるセルは、既存の16:9画像/mp4書き出し(`SlideDeckImages`など)と整合するように設計されており、書き出しから除外すべきセル(プロンプト・メモ・指示・辞書・文献・トーク原稿)や、スライド終端マーカー以降のセルは自動的にラスタライズ対象から外れます。

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
  - 既存の図・コードセルは`<<FIGn>>`トークンでプレースホルダとして保持し、勝手に消さない。
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
- 成功時は`Success`、失敗時は`Failure`を返します。

オプション: `"Figures"->{}`(新規図のリスト)

```wolfram
SlideApplyScenario[3, "## 更新後のタイトル {expected=45}\n- 新しい要点\n<<FIG1>>\n",
  "Figures" -> {myNewGraphic}]
```

### 8.4 翻訳

`SlideTranslate` / `SlideTranslateRevert` / `SlideTranslateDeck` / `$SlideTranslationLanguage`

- `SlideTranslate[]` — 現在スライドのテキストセルを`$SlideTranslationLanguage`へ一括翻訳します。`Dictionary`セルの用語対応を厳守します。原文は`TaggingRules`の`"SWOrigText"`に保存されるため、元に戻せます。
- `SlideTranslateRevert[]` — 現在スライドの翻訳を`"SWOrigText"`に保存された原文に戻します。
- `SlideTranslateDeck[]` — 全スライドを順に(非同期的に連鎖させながら)翻訳します。
- `$SlideTranslationLanguage` — 翻訳先言語(既定は日本語環境なら`"English"`)。

```wolfram
$SlideTranslationLanguage = "English";
SlideTranslate[]
SlideTranslateRevert[]
SlideTranslateDeck[]
```

### 8.5 補助セルの挿入

いずれもカーソル位置(または現在スライド)に、用途別の特殊セルを挿入するパレット向けコマンドです。多くは16:9画像/mp4の書き出しから除外されます。

- `SlideInsertPrompt[]` — `SlidePrompt`セルを挿入します。`SlideExpand`が読む入力欄であり、ラスタライズ(画像・動画書き出し)からは除外されます。
- `SlideInsertCitation[]` — 出典セル(小フォント)を挿入します。図や引用の直後に置き、URLまたは`(著者, 年)`を記入する運用です。
- `SlideInsertEndMarker[]` — スライド終端マーカーを挿入します。以降のセルはそのスライドの一部とみなされず、書き出し(`SlideDeckImages`など)にも含まれません。追跡用セルや検討メモの置き場として使えます。
- `SlideInsertNote[]` — メモセルを挿入します(`documentation.wl`のメモセルと互換)。`Working`環境では可視、`SlideShow`(スライドショー環境)では非表示になり、書き出しからも除外されます。
- `SlideInsertDirective[]` — 指示セルを挿入します。`SlideExpand`(展開)・`SlideTranslate`(翻訳)実行時にLLMが厳守すべき指示を書きます。`Working`で可視、`SlideShow`では非表示です。
- `SlideInsertDictionary[]` — 辞書セルを挿入します。翻訳時の用語対応(専門用語の訳語固定など)を指定します。
- `SlideInsertBibliography[]` — 文献セルを挿入します(`documentation.wl`と互換)。
- `SlideInsertReferences[]` — 文献リストセルを挿入します(パレットの「文献」)。1行1文献`"[key] locator | メモ"`の書式で、`locator`はURL / `arxiv:ID` / `sv://URI` / `eagle:ID` / PDF・ノートブックのパス(過去スライド可)。スライド指示(プロンプト)からは`[key]`で参照し、展開エージェントが取得・引用します。`#`で始まる行はコメントです。
- `SlideTogglePrompts[]` — デッキ内の全`SlidePrompt`セルの表示/非表示を一括で切り替えます。

```wolfram
SlideInsertDirective[]
SlideInsertDictionary[]
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

対象ノートブックのスクリーン環境を`Working` ⇄ `SlideShow`で切り替えます(書式メニューの「スクリーンスタイル環境」と同じ)。メモ・指示・辞書・文献・プロンプトの各セルは`Working`で可視、`SlideShow`で非表示になります。

```wolfram
SlideToggleScreenEnvironment[]
```

#### `SlideEnsureDeckStyles`

デッキにメタセル用スタイル定義(`Note`/`Directive`/`Dictionary`/`Bibliography`/`References`/`SlidePrompt`。`SlideShow`環境で非表示)を埋め込みます。パレットの挿入・展開・表示切替から自動で呼ばれ、`documentation.wl`の`DocInsert*`もこの定義を共用します。

```wolfram
SlideEnsureDeckStyles[nb]
```

#### `$SlideHideToolbarInSlideshow`

既定`True`。表示切替(`SlideToggleScreenEnvironment`)で`SlideShow`へ入るときに、標準ノートブックツールバー(MultipurposeBar)とノートブック側のDockedCells(CloudPublishableのPublic/Privateバッジ等)を一時退避し、`Working`へ戻すときに復元します。ノートブック側DockedCellsはスタイルシートのスライドナビバー定義を上書きするため、退避しないとナビバーが出ません。

```wolfram
$SlideHideToolbarInSlideshow = True;
```

### 8.7 図・表・引用元PDFの補助関数

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

## 9. 発表原稿・読み上げ・リモート操作

スライドの「中身」ではなく「話す原稿」を扱うレイヤーです。1枚ずつ独立に説明文を作ると発表としての流れが出ないため、原稿はデッキ全体を1度に見て書きます。読み上げには、SourceVaultのローカル音声資産(Piper)またはクラウドのリアルタイム音声応答(OpenAI Realtime)を使えます。

### 9.1 発表原稿シナリオ(talk markdown)

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

発表原稿を生成して`<deck>_talk.md`へ書き出します。LLMが使えるときは非同期(`SlideExpand`と同じ経路)で、使えないときは骨格を同期で書きます。

オプション: `"Output"`, `"UseLLM"`, `"Notebook"`, `"OpenResult"` と`SlideTalkPrompt`のオプション。

```wolfram
SlideTalkBuild["lecture1.nb"]
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

### 9.2 発表登録簿(SourceVault連携)

#### `SlideTalkMeta`

`SlideTalkMeta[nb]`はデッキ単位の発表メタ(`SlideURL` / `Aliases` / `PrivacyLevel`など)を返します。`SlideTalkMeta[nb, "SlideURL" -> url, ...]`はノートブックの`TaggingRules`に永続化します(登録簿への登録が`_talk.md`無しで完結します)。

```wolfram
SlideTalkMeta["lecture1.nb"]
SlideTalkMeta["lecture1.nb", "SlideURL" -> "https://slide.example/1234"]
```

#### `SlideDeckRegister`

`SlideDeckRegister[deck|talkfile|md]`は発表原稿のfront matter(Title / SlideURL)を使って、発表をSourceVaultの登録簿へ登録します。以後、VRCRealtimeが発表タイトルからスライドURLと原稿を引けます。

オプション: `"SlideURL"`, `"Title"`, `"Id"`, `"DeckFile"`, `"PrivacyLevel"`, `"SlideCount"`

```wolfram
SlideDeckRegister["lecture1.nb", "SlideURL" -> "https://slide.example/1234"]
```

#### `SlideDeckRegistry`

登録済み発表エントリの一覧を返します。

```wolfram
SlideDeckRegistry[]
```

### 9.3 ローカル音声読み上げと自動ページ送り

`<deck>_talk.md`の原稿をSourceVaultのローカル音声(Piper)で読み上げながら、1枚読み終わるごとにスライドを1枚進めます。対象はスクリーン環境が`SlideShow`のノートブックです。合成結果は`<deck>_voice/`にキャッシュするため、2回目以降の再生は待たされません。ウィンドウのスナップショットやクリップボードには依存しないため、FEを止めずに裏で動きます。

#### 音声関連の定数

```wolfram
$SlideVoice              (* 読み上げに使うボイスモデル名。既定 Automatic は SourceVaultVoice[] の既定の声。SlideVoices[] で候補一覧 *)
$SlideVoiceGap            (* スライドを読み終えてから次へ送るまでの間(秒、既定 0.8) *)
$SlideQuestionSeconds     (* 1枚読み終えてから次へ送るまでに質問を待つ秒数(既定 3)。クラウド音声(realtime:)のときだけ有効 *)
$SlideVoiceInputGate      (* 質問受付でマイクを送る下限の音量(0〜1、既定 0 = 制限なし) *)
$SlideQuestionMaxSeconds  (* 1枚の合間に質疑で留まれる上限の秒数(既定 60) *)
$SlideVoiceTick           (* 読み上げ進行を見るカーネル側ScheduledTaskの周期(秒、既定 0.3) *)
$SlideRealtimeVoices      (* ボイスモデルのトグルに並べるクラウド音声(OpenAI Realtime)の声名(既定 {"marin","cedar"})。一覧には "realtime:<声>" として出る *)
$SlideSpeechRate          (* 話速(1秒あたりの文字数)をエンジンごとに持つ連想。既定 <|"Local"->6.95, "Realtime"->5.6|>。SlideTalkDuration が使う *)
$SlideSpeechLatency       (* 1枚あたり声が出るまでの待ち(秒)をエンジンごとに持つ連想(既定 Local 0.3 / Realtime 1.5) *)
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

- `SlidePlay[]` — `<deck>_talk.md`の原稿をSourceVaultのローカル音声で読み上げながらスライドを自動で進めます(ノートブックのスクリーン環境が`SlideShow`のとき)。一時停止中に呼ぶと再開します。`SlidePlay[nb]`で対象ノートブックを指定。
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

### 9.4 クラウド音声応答(Realtime)と質問受付

#### `SlideToggleRealtime` / `SlideToggleMic`

- `SlideToggleRealtime[]` — 音声応答(`SourceVaultRealtimeStart` / `Stop`)を切り替えます。パレットの「応答on/off」と同じです。
- `SlideToggleMic[]` — 音声応答のマイクをmute/unmuteで切り替えます。パレットの「マイクon/off」ボタン、および手元リモコンの「前の曲」ボタンと同じ動作です。音声応答が動いていないときは何もしません。`"Quiet"->True`で知らせのダイアログも出しません(手元リモコンからはこちらで呼ぶ)。

```wolfram
SlideToggleRealtime[]
SlideToggleMic["Quiet" -> True]
```

読み上げ中(`SlidePlay`)は、クラウド音声(`realtime:`)のときだけ`$SlideQuestionSeconds`の間、質問を待ちます。話しかけられたら`$SlideQuestionMaxSeconds`まではデッキが止まらずに待ち、答えている最中は打ち切りません。会場の物音で勝手に応答が始まるときは`$SlideVoiceInputGate`を上げて、マイクを送る下限音量を設定します。

### 9.5 手元デバイス(メディアキー)によるリモート操作

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
- 文献検索・PDF資産・ローカル音声(Piper)・クラウド音声応答・発表登録簿は [SourceVault](https://github.com/transreal/SourceVault) と連携します。
- LLMによる展開・翻訳の承認ゲート付き実行は [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) を経由します。
- 生成した動画はSlidenやVRChatでの発表用途に[VRChatPresentationUploader](https://github.com/transreal/VRChatPresentationUploader)と組み合わせて利用できます。