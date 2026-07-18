# SlideWorkflow ユーザーマニュアル

`SlideWorkflow`は、Markdownや連想リストで書いたシナリオからスライドノートブックを生成し、既存デッキをスライド単位で編集し、16:9画像やSliden用mp4として安定して書き出すためのパッケージです。加えて、スライド作成用パレットからのインタラクティブな編集(スライド追加・LLMによる展開・翻訳・補助セル挿入)にも対応します。

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

オプション: `ImageSize->$SlideImageSize`、`"Slides"->All`または範囲、`"Environment"->"SlideShow"`、`"WindowWidth"->960`、`"IncludeInput"->Automatic`、`"Verbose"->False`、`"Margins"->Automatic`($SlideMarginsまたは`{{left,right},{bottom,top}}` px)

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

---

## 8. インタラクティブ編集(スライドパレット)

旧`SlideWorkflow_interactive.wl`が本パッケージに統合されたレイヤーです。スライドノートブックを実機(フロントエンド)で編集しながら、パレットのボタンからスライド追加・LLMによる本文展開・翻訳・各種補助セルの挿入を行えます。ここで挿入・生成されるセルは、既存の16:9画像/mp4書き出し(`SlideDeckImages`など)と整合するように設計されており、書き出しから除外すべきセル(プロンプト・メモ・指示・辞書)や、スライド終端マーカー以降のセルは自動的にラスタライズ対象から外れます。

### `$SlideWorkflowInteractiveVersion`

インタラクティブレイヤーのバージョン文字列。

```wolfram
$SlideWorkflowInteractiveVersion
```

### `ShowSlidePalette`

スライド作成用パレット(ボタン群)を表示します。

オプション: `"Safe"->False`(既定)。`"Safe"->True`にすると、ClaudeCodeなど外部エージェントの処理に完全に非干渉なモードで開きます(フリーズ時の切り分け用)。

```wolfram
ShowSlidePalette[]
ShowSlidePalette["Safe" -> True]
```

### `SlideAddSlide`

現在選択中のスライドの直後に、新規スライドの骨格(ナビゲーションバー+タイトル+`SlidePrompt`セル)を挿入します。挿入後、`SlidePrompt`セルに要点を書き、パレットの「展開」(`SlideExpand`)を押す運用を想定しています。

```wolfram
SlideAddSlide[]
```

### `SlideExpand` と `$SlideExpandMode`

現在スライドの`SlidePrompt`セル(無ければ選択セルの本文)を指示として読み取り、その内容でスライドを展開・更新します。実際の書き込みは常に`SlideApplyScenario`を介して行われる決定的な処理です。

```wolfram
SlideExpand[]
```

`$SlideExpandMode`で実行経路を切り替えられます。

- `"Agent"`(既定): `ClaudeEval`(`ClaudeRuntime`経由)に委譲します。文献検索・図生成・承認ゲート付きの複雑な処理が可能です。エージェントは以下を守って新しいシナリオMarkdownを構成し、最後に`SlideApplyScenario`を呼んで適用します。
  - 書式は`SlideScenarioFromMarkdown`と同じ(`"## タイトル {expected=秒}"` / `"- "`箇条書き(インデント2/4で下位項目) / `"> "`説明段落)。通常は1枚のスライドに収める。指示で明示的に求められた場合のみ複数の`##`に分割する。
  - 論文・Web・PDF由来の図・引用・データを使う場合は、直後に`cite: `行で出典(URLまたは`(著者, 年)`)を必ず明記する。内容確認が必要なら文献検索(SourceVault / pdfSearch / Web検索)を利用してよい。
  - 既存の図・コードセルは`<<FIGn>>`トークンでプレースホルダとして保持し、勝手に消さない。
  - `Directive`(指示)・`Dictionary`(辞書)セルの内容を厳守する。
  - 追跡・作業用セルは、スライド終端マーカー(`SlideInsertEndMarker`)以降(Appendix領域)に置かれ、スライド本体やエクスポートには含まれない。
- `"Direct"`: 軽量経路。`NBAccess`\``$NBLLMQueryFunc`を直接呼び出します(承認ゲートや文献検索などの複雑処理は行いません)。

```wolfram
$SlideExpandMode = "Direct";
SlideExpand[]
```

### `SlideApplyScenario`

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

### 翻訳: `SlideTranslate` / `SlideTranslateRevert` / `SlideTranslateDeck` / `$SlideTranslationLanguage`

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

### 補助セルの挿入

いずれもカーソル位置(または現在スライド)に、用途別の特殊セルを挿入するパレット向けコマンドです。多くは16:9画像/mp4の書き出しから除外されます。

- `SlideInsertPrompt[]` — `SlidePrompt`セルを挿入します。`SlideExpand`が読む入力欄であり、ラスタライズ(画像・動画書き出し)からは除外されます。
- `SlideInsertCitation[]` — 出典セル(小フォント)を挿入します。図や引用の直後に置き、URLまたは`(著者, 年)`を記入する運用です。
- `SlideInsertEndMarker[]` — スライド終端マーカーを挿入します。以降のセルはそのスライドの一部とみなされず、書き出し(`SlideDeckImages`など)にも含まれません。追跡用セルや検討メモの置き場として使えます。
- `SlideInsertNote[]` — メモセルを挿入します(`documentation.wl`のメモセルと互換)。書き出しからは除外されます。
- `SlideInsertDirective[]` — 指示セルを挿入します。`SlideExpand`(展開)・`SlideTranslate`(翻訳)実行時にLLMが厳守すべき指示を書きます。
- `SlideInsertDictionary[]` — 辞書セルを挿入します。翻訳時の用語対応(専門用語の訳語固定など)を指定します。
- `SlideInsertBibliography[]` — 文献セルを挿入します(`documentation.wl`と互換)。
- `SlideTogglePrompts[]` — デッキ内の全`SlidePrompt`セルの表示/非表示を一括で切り替えます。

```wolfram
SlideInsertDirective[]
SlideInsertDictionary[]
SlideInsertPrompt[]
SlideInsertCitation[]
SlideInsertBibliography[]
SlideInsertNote[]
SlideInsertEndMarker[]
SlideTogglePrompts[]
```

---

## 関連パッケージ

- フォント設定は [NotebookExtensions](https://github.com/transreal/NotebookExtensions) の `$fontFamily` と連携できます。
- 生成した動画はSlidenやVRChatでの発表用途に[VRChatPresentationUploader](https://github.com/transreal/VRChatPresentationUploader)と組み合わせて利用できます。

---

I added a new **§8 インタラクティブ編集(スライドパレット)** covering the layer merged from the former `SlideWorkflow_interactive.wl` (2026-07-13): `ShowSlidePalette`, `$SlideWorkflowInteractiveVersion`, `SlideAddSlide`, `SlideExpand`/`$SlideExpandMode`, `SlideApplyScenario`, the translation quartet (`SlideTranslate`/`Revert`/`Deck`/`$SlideTranslationLanguage`), and the auxiliary cell-insertion commands (`SlideInsertPrompt`/`Citation`/`EndMarker`/`Note`/`Directive`/`Dictionary`/`Bibliography`, `SlideTogglePrompts`). Sections 1–7 were left unchanged — the "removed lines" in the diff were internal `Module` implementation details, not public API removals, so nothing was deleted from the manual.