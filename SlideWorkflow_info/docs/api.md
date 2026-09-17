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

### $SlideIncludeInput
型: `Automatic | True | False | "Visual"`, 初期値: `Automatic`
書き出しに Input/Code セルを含めるかの既定値。`Automatic`(既定)=ノートブックの表示どおり(折りたたみ・`CellOpen->False`で隠れているセルだけが除かれる) / `True`=同上 / `False`=Input/Codeをすべて除く / `"Visual"`=図を含むInputのみ残す(旧既定)。個別セルは`CellTags`に`"ShowInput"`を付ければこの設定によらず必ず残る。

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
- `cite: 出典` で直前の図・引用に出典セルを付与
- `<<FIGn>>` で既存の図・コードセルをその位置に保持(再展開時)
- `talk: 原文` でそのスライドの発表原文(SlideTalk セル)を埋め込む
- `qa: Q: 質問` / `qa: A: 回答` でそのスライドの想定問答(SlideQA セル)を埋め込む
- `## !end` 以降はAppendix行になる
例: `SlideScenarioFromMarkdown["--- Title: 発表 ---\n## 導入 {expected=30}\n- 背景\n  - 詳細\n> 補足説明\n"]`

### SlideScenarioToMarkdown[scenario] → String
シナリオ連想をMarkdown文字列に戻す(ラウンドトリップ用)。

## デッキ構築

### SlideDeckBuild[scenario, nbfile, opts] → String
シナリオ(連想 / Markdown文字列 / `File[md]`)からスライドノートブックを生成し`nbfile`に保存、ファイルパスを返す。
Options: `"TitleSlide" -> True` (先頭にタイトルスライドを付与するか), `StyleDefinitions -> $SlideStyleDefinitions` (適用スタイルシート), `"EndMarker" -> True` (末尾に終端マーカー(SlideDeckEnd)を付与するか。`False`で抑止)

## デッキ参照・編集

### SlideDeckSlides[nbfile] → <|"Prelude"->{cells}, "Slides"->{{cells}..}, "Appendix"->{cells}, "Options"->{...}|>
デッキをプレリュード部・スライド単位のセル配列・Appendix・オプションに分解して返す(コア関数)。

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
Options: `ImageSize -> $SlideImageSize`, `"Slides" -> All | 範囲` (対象スライド指定), `"Environment" -> "SlideShow"` (ScreenStyleEnvironment), `"WindowWidth" -> 960`, `"IncludeInput" -> Automatic` (`$SlideIncludeInput`を参照。`Automatic|True|False|"Visual"`。個別セルは`CellTags->"ShowInput"`で常に残せる), `"Verbose" -> False`, `"Margins" -> Automatic` ($SlideMarginsまたは`{{left,right},{bottom,top}}` px), `"Reflow" -> True`, `"MaxWindowWidth" -> 1600`

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
- **メタセル**(documentation.wl 互換, すべて書き出し除外): `"Note"`(メモ) / `"Directive"`(展開・翻訳時に LLM が厳守する指示) / `"Dictionary"`(翻訳用語対応) / `"Bibliography"`(文献) / `"References"`(文献リスト、locator指定) / `"SlidePrompt"`(スライド展開用プロンプト) / `"SlideTalk"`(スライドごとの発表原文、書き出し除外)。
- **出典セル**: シナリオの `cite: 出典` 行 → 小フォント(9pt)の出典 Text セル(`CellTags->"Citation"`、書き出しに含まれる)。論文・web・PDF 由来の図・引用には必ず付ける。
- **保持トークン**: シナリオの `<<FIGn>>` 行 → 再展開時に既存の図・コードセルをその位置に保持する(`$iSlideKeepCells` を Block 束縛して `iBuildSlideCells`)。
- **Appendix(md)**: シナリオ Markdown の `## !end` 以降の行は Appendix の Text セルになる。

## 文献・図版

### SlideInsertReferences[]
カーソル位置に文献リストセル(`"References"`)を挿入する(パレットの「文献」)。1行1文献`"[key] locator | メモ"`。locator は URL / arxiv:ID / sv://URI / eagle:ID / PDF・ノートブックのパス(過去スライド可)。スライド指示(プロンプト)からは `[key]` で参照し、展開エージェントが取得・引用する。`#` で始まる行はコメント。

### SlidePDFFigure[src, page, opts] → Image
PDFのページを図(Image)として切り出す。srcはファイルパス / eagle:ID / sv://URI / src-ID / URL / arxiv:ID / References(文献リスト)のkey。URL・arxiv・Google Slides(プレゼンURL)は自動ダウンロードしてPDF化しキャッシュする。png等の画像ファイルもsrcに指定できる。
Options: `"Crop" -> None` (`{{x1,x2},{y1,y2}}`、左上原点のページ比率0..1で領域指定), `"Trim" -> Automatic` (余白を自動トリム), `ImageResolution -> 144`
文献PDFの図をスライドへ引用するときは直後に`cite:`を付す。

### SlidePDFImages[src, opts] → {Image...}
PDFに埋め込まれたラスタ画像(写真・ビットマップ図)をImageのリストで抽出する。srcは`SlidePDFFigure`と同じlocator(パス / eagle:ID / sv://URI / URL / arxiv:ID / Referencesのkey)。ベクタのみのPDFでは`{}`を返す(その場合は`SlidePDFFigure`でページ切り出し)。
Options: `"MinSize" -> 80` (px未満の小画像(アイコン等)は除外), `"Page" -> n` (指定ページのみ)

### SlideDeckFigure[deck, n] → Image
既存スライドデッキ(.nb)のn枚目を1920x1080のImageとして引用する。deckはパスまたはReferencesのkey。論文紹介・過去スライド紹介で原スライドをそのまま見せるのに使う(`cite:`を付す)。

### SlideSourceFile[locator] → String
文献locator(パス / eagle:ID / sv://URI / URL / arxiv:ID / Google Slides URL / Referencesのkey)を解決してローカルファイルパスを返す(URL系は自動ダウンロード+PDF化+キャッシュ)。展開エージェントが`ClaudeAttach[SlideSourceFile[...]]`で資料を閲覧し、引用ページ・領域を決めるのに使う。

### SlideNotebookOutline[src] → {<|"N", "Style", "Title", "Chars", "Figures"|>...}
素材ノートブック(論文の和訳.nbなど、スライドデッキでない一般の.nb)の見出し構成を返す。まず構成を見て、必要な節だけを`SlideNotebookText[src, 見出し]`で読むと文脈を節約できる。srcは`SlidePDFFigure`と同じlocator(パス / eagle:ID / sv://URI / Referencesのkey)。

### SlideNotebookText[src, opts] / SlideNotebookText[src, 見出し|見出し番号, opts] → String
素材ノートブックの本文を`"[Style] 本文"`行の並びで返す(図の位置は`"[FIGn]"`行)。第2引数を渡すとその節だけを返す。数式(DisplayFormula)も含み、数式セルの行頭には`"[EQn]"`が付き、本文には元のLaTeX(変換ノートがTaggingRulesに保持していれば)を出すので数式を誤読しない。そのままスライドへ引用するには`SlideNotebookFormula[src, n]`。
Options: `"MaxCharacters" -> 40000` (超過分は切り詰めて注記), `"Styles" -> Automatic` (本文系スタイル)
LLM生成コードではImport/Getが恒久禁止headなので、素材.nbを読むときはこれを使う。

### SlideNotebookFormula[src, n, opts] → Cell
素材ノートブックのn番目の数式(SlideNotebookTextの`"[EQn]"`に対応)を、**原セルの組版を保ったまま**Cellで返す。`SlideApplyScenario`の`"Figures"->{...}`にそのまま渡せば、スライドに組版された数式として載る(プレーン文字列へ潰して書き直さないこと)。
Options: `"Style" -> "DisplayFormula"`, `FontSize`, `FontColor`

### SlideNotebookFigure[src, n, opts] → Image
素材ノートブックのn番目の図(SlideNotebookTextの`"[FIGn]"`に対応)をImageで返す。原図をそのまま引用するための入口で、`SlideApplyScenario`の`"Figures"->{...}`にそのまま渡せる(`cite:`を必ず付す)。図の総数と所在はSlideNotebookOutline / SlideNotebookTextの[FIGn]で分かる。返す画像は長辺`$SlideNotebookFigureMaxSize`(既定1200px、`"MaxSize"`で変更可)に収める — デッキのラスタ化で実際に出るのは高々1120pxなので、それ以上はノートブックを重くするだけになる。

### $SlideNotebookFigureMaxSize
型: Integer, 初期値: `1200`
`SlideNotebookFigure`が返す図の長辺上限px。デッキはWindowWidth 960を1920へ2倍でラスタ化し、図セルはImageSize->560なので、最終画像に出るのは高々1120px。それを超える画素はノートブックを重くするだけになる。

### $SlideNotebookRasterizeSeconds
型: Integer, 初期値: `30`
`SlideNotebookFigure`がベクタ図をRasterizeする際の上限秒。Rasterizeはフロントエンドを要求するので、必ず時間で切る。

### SlideTable[rows, opts] → 表示可能な式(Grid)
デッキ配色($SlideTheme)の表を返す。rowsは文字列の行リスト。
Options: `"HeaderRows" -> 1` (ヘッダ行として強調する行数)
シナリオmdでは`|`構文(`"| a | b |"`、2行目に`"| --- | --- |"`で1行目がヘッダ)が同じ表になる。

### $SlideVisualsPerSlide
型: Boolean, 初期値: `True`
`True`(既定)なら、展開プロンプトが「原則すべてのスライドに図か表を1つ以上」を要求する。`False`で従来の文章中心生成。

## 発表シナリオ (talk)

**位置づけ (v1.30)**: スライドの作り方 (知識グラフから生成 / プロンプトから展開 / 手書き) によらず、発表の準備はデッキのセルが正本 — 原稿 = トークセル、想定問答 = 質疑応答セル、登録用メタ = 指示セル。パレット「発表の準備」は **原稿** (`SlideTalkFill`: 原稿の無い枚だけ LLM が書く) / **QA生成** / **QA一覧** / **登録**。知識グラフから作った枚は生成時にノードの原稿 (Talk) が入り、質疑応答は知識グラフのノードにも保存されるので「生成」し直しても消えない (下の SlideQAGenerate と SlideGraphApply)。以下の md (`<deck>_talk.md`) は書き出しと旧デッキのフォールバックで、パレットからは外した。

スライドの「中身」ではなく「話す原稿」を扱う層。1枚ずつ独立に説明文を作ると発表としての流れが出ないため、原稿はデッキ全体を1度に見て書く。**正本は各スライド末尾の SlideTalk セル**(md の `talk:` 行)と、デッキ先頭の指示(Directive)セルに書く `Key: value` 行のメタ(`Title:` / `SlideURL:` / `Host: sftp://user@host/dir` など)。Markdown(front matter + `# Opening` + `## n タイトル {seconds=秒}` + `# Closing`)は書き出し用と、トークセルの無い旧デッキのフォールバック。

### $SlideTalkSecondsPerSlide
型: Real, 初期値: `25.`
発表シナリオの既定の1枚あたり秒数。

### SlideTalkFromMarkdown[md | File[path]] → Association
発表シナリオMarkdownを連想へ解析する。戻り値: `<|Title, Aliases, Event, Author, Date, SlideURL, Deck, Language, NarrationInstructions, SecondsPerSlide, PrivacyLevel, Opening, Closing, Slides, Meta|>`(`Slides`は`<|Slide,Title,Seconds,Text|>`のリスト)。

### SlideTalkToMarkdown[talk] → String
発表シナリオ連想をMarkdownへ戻す(ラウンドトリップ用)。

### SlideTalkSkeleton[deck, opts] → String
デッキの箇条書きから決定論的な発表シナリオ骨格Markdownを作る(LLM不要)。
Options: `"Title" -> Automatic`, `"Aliases" -> {}`, `"Event" -> ""`, `"Author" -> ""`, `"Date" -> ""`, `"SlideURL" -> ""`, `"SecondsPerSlide" -> Automatic` ($SlideTalkSecondsPerSlide), `"Language" -> "Japanese"`, `"NarrationInstructions" -> ""`, `"PrivacyLevel" -> 0.`, `"Outline" -> Automatic`

### SlideTalkPrompt[deck, opts] → String
デッキ全体から「流れのある発話原稿」を書かせるLLMプロンプトを返す。

### SlideTalkFill[] / SlideTalkFill[nb] (v1.30)
原稿 (トークセル) の無いスライドにだけ原稿を書く (パレット「発表の準備」の「原稿」)。LLM がデッキ全体の流れ (各枚の題目と既存原稿の冒頭) を見て 8 枚ずつ書き、JSON `{"Talks": [{"Slide", "Talk"}]}` で返したものを各スライドのトークセルへ入れる (質疑応答セルがあればその前、既にあるトークセルは上書き)。規則: です・ます調 2〜6 文、前の枚とのつながり、箇条書きと同じ順、スライドに無い事実を作らない、`$...$` や `**` を書かない。全枚に原稿があれば何もしない。

### SlideTalkBuild[deck, opts] → String
(v1.30: パレットから外した。原稿を md に書き出したいときに呼ぶ) 発表シナリオを生成して`<deck>_talk.md`へ書き出す。LLMが使えるときは非同期(SlideExpandと同じ経路)で、使えないときは骨格(SlideTalkSkeleton)を同期で書く。
Options: `"Output" -> Automatic`, `"UseLLM" -> Automatic`, `"Notebook" -> Automatic`, `"OpenResult" -> False` に加えSlideTalkPromptのオプション

### SlideTalkFile[deck] → String
発表シナリオの規約パス`<deck>_talk.md`を返す(トークセルの無い旧デッキ用のフォールバック)。

### SlideTalkMeta[nb] → Association
デッキ単位の発表メタ(Title / SlideURL / UploadURL / Aliases / PrivacyLevel など)を返す。ソースの優先順は **デッキ先頭の指示(Directive)セルの `Key: value` 行** > TaggingRules `"SWTalkMeta"` > `_talk.md` front matter。指示セルには次のように書く(`Host:` / `Upload:` / `UploadURL:` は同義で `UploadURL` に正規化。`Aliases:`(カンマ区切り) / `PrivacyLevel:` / `SecondsPerSlide:` / `Event:` / `Author:` / `Date:` も可。これらの行は LLM への指示ブロックからは除かれる):

```
Title: 計算と自然 32
SlideURL: https://transreal.sakura.ne.jp/cn/32.mp4
Host: sftp://transreal@transreal.sakura.ne.jp/home/transreal/www/cn
```

### SlideTalkMeta[nb, "SlideURL" -> url, ...]
ノートブックのTaggingRulesにメタを永続化する(指示セルに同じキーがあればそちらが優先)。

### SlideDeckRegister[nb | deck.nb | talkfile | md, opts] → 登録結果
発表(トークセル + 指示セルのメタ)をSourceVaultの登録簿へ登録し、メタに `UploadURL`(指示セルの `Host:` 行)があれば続けて Sliden 用 mp4 を web サーバへアップロードする(結果は戻り値の `"Upload"` キー。登録簿への登録は mp4 の成否に関係なく完了する)。以後VRCRealtimeが発表タイトルからスライドURLと原稿を引ける。パレットの「登録」はこの関数。
同じデッキで再度実行すると、前回のエントリを土台に今回与えた値だけを上書きする(前回の特定は `Id` > `DeckFile` > `SlideURL` の優先順。指示セルの `Id:` 行で固定できる)。何が変わったかは戻り値の `RegistryStatus`(Created|Updated)と`ChangedKeys`で分かる。
Options: `"SlideURL" -> Automatic`, `"Title" -> Automatic`, `"Id" -> Automatic`, `"DeckFile" -> Automatic`, `"PrivacyLevel" -> Automatic`, `"SlideCount" -> Automatic`, `"Upload" -> Automatic`(Automatic = UploadURL があれば送る / True = 必須 / False = 送らない)

### SlideDeckRegistry[] → Dataset
登録済み発表エントリの一覧を返す。

### SlideDeckUpload[nb | deck.nb | deck.mp4, opts] → Association | Failure
Sliden 用 mp4(パレットの mp4 書き出しと同じ `<deck>.mp4`)を `UploadURL`(`sftp://user@host/dir`)へ sftp で送る。リモートのファイル名は `SlideURL` の末尾(例 `32.mp4`)。転送前に `SlideURL` の HEAD で「200 かつ Content-Length がローカルと同じ」なら送らず `"Status" -> "Unchanged"`(`"Force" -> True` で強制)。転送後も同じ HEAD で配信を確認し `"Verified"` に入れる。mp4 が無ければ既定で書き出してから送る(`"ExportVideo" -> False` で抑止)。パスワードは NBAccess 管轄の SystemCredential(名前 `sftp://user@host`)から読み、無ければ FE ではダイアログで尋ねて保存する(`"Interactive" -> False` で抑止)。
転送手段 `"Method"`: Automatic = `"Native"`(`CopyFile` → `RemoteFile`、WL 組込み)→ 使えなければ `"curl"`(Git for Windows 同梱の sftp 対応 curl。System32 の curl は sftp 非対応)。Windows OpenSSH の sftp.exe はコンソール無しではパスワード認証を試みないので使わない。
戻り値: `<|Status ("Uploaded"|"Unchanged"), Method, File, Bytes, Remote, SlideURL, Verified, RemoteBytes, Seconds|>`。Failure タグ: `SlideUploadURLMissing` / `SlideUploadURLInvalid` / `SlideUploadUserMissing` / `SlideUploadFileMissing` / `SlideUploadCredentialMissing` / `SlideUploadAuthFailed` / `SlideUploadFailed` / `SlideUploadMethodUnavailable` / `NBAccessUnavailable`。
Options: `"UploadURL" -> Automatic`, `"SlideURL" -> Automatic`, `"File" -> Automatic`, `"Method" -> Automatic`, `"Password" -> Automatic`(文字列で直接 / None で資格情報を使わない), `"User" -> Automatic`, `"Force" -> False`, `"Verify" -> True`, `"ExportVideo" -> Automatic`, `"Interactive" -> Automatic`

### SlideUploadCredential[url | nb] / SlideUploadCredential[url | nb, password] / SlideUploadCredential[url | nb, None]
sftp のパスワードを NBAccess 経由で SystemCredential に保存する(名前 = `sftp://user@host`。値はこの層の外へ出さない)。引数なし版は FE でダイアログ(`AuthenticationDialog`)を出す(パスワードがノートブックに残らない)。`None` で削除。nb を渡すと指示セルの `Host:` 行から URL を取る。

### SlideUploadCredentialQ[url | nb] → Boolean
パスワードが保存済みかどうか(値は返さない)。

### $SlideUploadMethod
型: Automatic | "Native" | "curl" | リスト, 初期値: `Automatic`
mp4 の転送手段の既定。

### SlideInsertTalk[]
トークセル(SlideTalkスタイル、そのスライドの発表原稿)を各スライドの最後に挿入する。Workingで可視、SlideShow環境では非表示、書き出しからも除外。mdでは`"talk: 原文"`行。全スライドにトークがあるとSlideTalkBuild(パレット「シナリオ」)がLLM無しで`deck_talk.md`を束ねる。

### $SlideTalkPerSlide
型: Boolean, 初期値: `True`
`True`(既定)なら、展開プロンプトが各スライド末尾に`talk:`原稿(です・ます調、2〜6文)を要求し、スライド本文は図表+短い体言止めに絞る(スライドとトークで解説が完成する分業)。`False`で従来どおり。

## 質疑応答 (QA)

発表中に声で聞かれた質問へ即答するための作り置きを、**スライドの中**に置く層。正本は各スライド末尾の SlideQA セル(md の `qa:` 行)で、トークセルと同じく Working で可視・SlideShow で非表示・画像/mp4 の書き出しから除外。パレットの「登録」を押すと SourceVault の QA パックへ焼かれ、発表中の gpt-realtime が数十 ms で引ける。

セルの書式(1 セルに何問でも、`Q:` ごとに 1 問):

```
Q: 想定質問
A: そのまま読み上げられる回答
cite: sv://... または出典テキスト   (省略可、複数可)
PL: 0.6                              (省略可。この 1 問だけ非公開扱いにする)
```

接頭辞の無い行は直前の項目の続き、`#` 行はコメント。`質問:` / `回答:` も使える。**回答の空な想定質問はパックに焼かない**(焼くと作り置きに当たってしまい、KB に答えがあっても届かない)。

### SlideInsertQA[]
質疑応答セル(SlideQA スタイル)を挿入する。パレットの「質疑」。

### SlideQAEntries[nb | deck.nb] → Association
デッキ内の質疑応答セルを集めて `<|"SlideCount", "Questions", "Answered", "Missing"(質疑応答セルの無いスライド番号), "Slides"|>` を返す(コア関数)。

### SlideQAView[nb | deck.nb] → Dataset
中身を 1 行 1 問の表で見る(View 関数)。パレットの「QA 一覧」はこれに登録済みパックの状態を添えて別窓に出す。

### SlideQAGenerate[nb, opts]
LLM に**1 枚ずつ**読ませ、想定問答の**下書き**を質疑応答セルとして書き込む(非同期連鎖)。書いたあとは人が直すことが前提。
**知識グラフから作った枚 (v1.30)**: 題目セルの CellTags `"KGNode:<id>"` からノードを引き、その「元の資料」(ノードの本文 = 論文の段落。無ければ親の節の筋書き、要約) と出典を添えて問答を作らせる (回答は「スライド・原稿・元の資料」にあることだけ)。LLM 呼び出しの PrivacyLevel は KG のノードと関連研究の候補から取る。終わったら**デッキの質疑応答セルを KG のノード (`"QA"`) へ保存**する (`iSWKGHarvestQA`)。次の「生成」でその問答は同じノードの枚へ `qa:` として戻る。「登録」は従来どおりデッキのセルから焼く。
Options: `"Mode"`, `"QuestionsPerSlide" -> Automatic` (既定 `$SlideQAPerSlide` = 3), `"Vision" -> Automatic` (既定 `$SlideQAVision`), `"Slides" -> All | {n..}`

**3 つの流儀** (`"Mode"`):

| Mode | 別名 | 対象 | 既存の問答 |
|---|---|---|---|
| `"Regenerate"` | 1 | 全スライド | 捨てて作り直す |
| `"Update"` | 2 | 全スライド | LLM に見せ、活かしたまま直させる |
| `"Changed"` | 3 (既定) | 未作成 + スライドを直した枚 | 同上 |

パレットの「QA 生成」は 3。質疑応答セルが 1 つも無いデッキなら結局すべて生成になる。

**変更の判定**: 質疑応答セルの先頭に `# slide: <16 桁>` として、**書いた時点のスライドのハッシュ**を残す。セルに付いて回るので、スライドを並べ替えても挿入しても対応が崩れない(番号で覚えると崩れる)。マーカーの無いセル(手書き)は「判定できない」ので 3 では**触らない**— 人が書いたものを勝手に上書きしないため。全部見直したいときは 2。

**図・写真・表**: 図や写真を含むスライドでは、そのスライドの**描画画像を LLM に添付**し、軸・系列・傾向・写っているものなど本文に現れない内容についても問答を作らせる(表は md の `|` 構文で既にテキスト化されている)。画像は `<deck>_qa_images/slide-NN-<ハッシュ>.png` にキャッシュされるので、同じスライドを二度描画しない。描画は別プロセス(必要な枚だけ)、添付は `ClaudeAttach` → 応答後に `ClaudeDetach`。未保存デッキでは描画できないのでテキストのみになる。

画像を添付する都合上、**1 枚 1 リクエスト**。全枚やり直す(1/2)とスライド数だけ呼ぶので、普段は 3 を使う。実行中は二重起動を拒む。

### SlideQAMarkCurrent[nb]
既存の質疑応答セルに、今のスライドの印(`# slide:`行)だけを打つ。LLMは使わず、問答の文面は変えない。マーカーの無い旧デッキを「QA生成」(Mode 3、変更分のみ)に乗せるための土台。**今の中身を「確認済み」と宣言する操作**なので、中身を見てから使うこと。

### SlideQAGenerateAll[nb] / SlideQAUpdateAll[nb]
それぞれ `"Mode" -> "Regenerate"` (1) と `"Mode" -> "Update"` (2) の別名。

### SlideQAStateView[nb | deck.nb] → Dataset
スライドごとの状態(未作成 / 要更新 / 最新 / 判定不能、図表の有無)を返す(View 関数)。「QA 生成」がどの枚を拾うかがこれで分かる。`SlideQAEntries` の `"Missing"` / `"Stale"` / `"Unmarked"` / `"Current"` が同じ情報のコア。

### $SlideQAVision
型: Boolean, 初期値: `True`
図・写真を含むスライドの QA 生成で描画画像を添付するか。

### SlideQAFromPack[nb, opts] → Association
すでに登録済みの QA パック(以前 `SourceVaultTalkQABuild` で LLM から作ったものを含む)を、スライドの質疑応答セルへ書き戻す。セルが正本になったあとも古い作り置きを捨てずに人が直せる形へ移せる。LLM は使わない。
Options: `"Rebuild" -> False` (既に質疑応答セルのあるスライドは触らない)

パレットの「QA 生成」は、質疑応答セルが 1 つも無く既存パックがある場合はこちらを先に使う(LLM を回す前に、いまあるものを捨てない)。

### SlideQABuild[nb | deck.nb, opts] → Association
質疑応答セルを SourceVault の QA パックへ焼く(`SourceVaultTalkQAImport` へ委譲)。**人が書いた答えを LLM が言い換えない**。「登録」から自動で呼ばれる。
Options: `"PrivacyLevel" -> Automatic` (デッキのメタから), `"Ingest" -> True` (KB へも取り込んで、作り置きに無い質問の受け皿を作る), `"Enrich" -> True` (回答が空の問だけ KB から補う)

**パックの同一性**: 同じデッキに対して 2 つのパックが残ると、`SourceVaultTalkQASelectForDeck` が古いほう(別の発表の作り置き)を掴んで答えてしまう。そのため `SourceVaultTalkQAImport` は、そのデッキのパックが既にあれば**その `PackId` / `KBId` / `SourceId` を引き継ぐ**(`cn31` のような手で付けた id を保つ)。それでも複数残っている場合は、最後に書かれたものを使う(パックに `SavedAt` を焼いてある)。

### $SlideQAPerSlide
型: Integer, 初期値: `3`
`SlideQAGenerate` が 1 枚あたりに作る想定質問の数。

## 変更検出 (登録の空振りを避ける)

「登録」は登録簿・QA パックセ・mp4 の 3 つを触るが、中身が変わっていなければやり直さない。判定は**ファイル日付ではなく、スライドとして描かれるセルを順番どおりに並べたもののハッシュ**。

- トークセル・質疑応答セル・メモ・指示などのメタセルを直しても mp4 は作り直さない(見た目が 1 ピクセルも変わらないため)。
- スライドの**並び替え・挿入・削除**は列が変わるので必ず検出され、mp4 を作り直す。
- `CellChangeTimes` / `CellID` / `ExpressionUUID` / `CellLabel` は中身ではないので落とす(触っただけで作り直しにならない)。
- 記録は `<deck>_state.json`。記録が無ければ(旧デッキ)従来どおりファイル日付で判断する。

### SlideDeckMarkVideoCurrent[nb | deck.nb] → Association
いまある `<deck>.mp4` を「いまのスライドで作られたもの」として記録する。既存デッキをこの仕組みへ移すとき、すでに配信済みの mp4 を 1 回だけ作り直すのを避けるためのもの。**スライドを直したのに呼ぶと古い mp4 が最新扱いで固定される**ので、見た目が一致しているときだけ使う。

### SlideDeckChangeStatus[nb | deck.nb] → Association
「登録」が何をやり直すかを返す(`"SlidesDigest"`, `"VideoSlidesDigest"`, `"VideoStale"`, `"QADigest"`, `"QAStale"`)。「登録しても何も起きない」ときの切り分けに使う。

## 音声再生・自動進行

発表シナリオをSourceVaultのローカル音声(Piper)またはクラウドRealtime音声で読み上げながらスライドを自動で進める層。FEを止めないため、パレット側に常駐Dynamicのポーリングを置かず、進行はカーネル側のScheduledTaskが回す。

### $SlideVoice
型: String | Automatic, 初期値: `Automatic`
読み上げに使うボイスモデル名(SourceVaultのローカル音声資産の声名、または`"realtime:<声>"`)。既定`Automatic`は`SourceVaultVoice[]`の既定の声。`SlideVoices[]`で候補一覧。

### $SlideVoiceGap
型: Real, 初期値: `0.8`
スライドを読み終えてから次へ送るまでの間(秒)。

### $SlideRenderSettle
型: Real, 初期値: `0.6`
次のスライドを表示してから読み上げを始めるまでの間(秒)。FEが重いスライドの描画で塞がっている間に鳴らし始めると音が途中で止まるため、描画が落ち着くのを待つ。0で待たない。

### $SlidePrepareBeforePlay
型: Boolean, 初期値: `True`
`True`(既定)なら、`SlidePlay`はローカルの声の音声を再生開始前に全スライド分用意する(未合成のものだけ合成)。再生中に合成を走らせると音が途切れるため。`False`で従来の1枚先読み。

### $SlideQuestionSeconds
型: Real, 初期値: `3.`
1枚読み終えてから次へ送るまでに質問を待つ秒数。クラウド音声(realtime:)のときだけ効く。この間に話しかけられたら、やり取りが終わるまで次へ送らない。0にすると待たない。

### $SlideVoiceInputGate
型: Real (0〜1), 初期値: `0.`
質問受付でマイクを送る下限の音量(0=制限なし)。会場の物音で勝手に応答が始まるときに0.05前後を入れる。いまの音量は`SourceVaultRealtimeStatus[]["InputPeak"]`で見られる。

### $SlideQuestionMaxSeconds
型: Real, 初期値: `60.`
1枚の合間に質疑で留まれる上限の秒数。部屋の物音でマイクが開き続けてもデッキが止まらないようにする上限。答えている最中は打ち切らない。

### $SlideVoiceTick
型: Real, 初期値: `0.3`
読み上げ進行を見るカーネル側ScheduledTaskの周期(秒)。

### $SlideRealtimeVoices
型: `{String...}`, 初期値: `{"marin", "cedar"}`
ボイスモデルのトグルに並べるクラウド音声(OpenAI Realtime)の声名。一覧には`"realtime:<声>"`として出る。

### $SlideSpeechRate
型: Association, 初期値: `<|"Local" -> 6.95, "Realtime" -> 5.6|>`
話速(1秒あたりの文字数)をエンジンごとに持つ連想。`SlideTalkDuration`が使う。

### $SlideSpeechLatency
型: Association, 初期値: `<|"Local" -> 0.3, "Realtime" -> 1.5|>`
1枚あたり声が出るまでの待ち(秒)をエンジンごとに持つ連想。

### SlideVoices[] → {String...}
選べるボイスモデル名の一覧を返す(SourceVault_voice.wlが読み込まれていなければ`{}`)。

### SlideCycleVoice[]
`$SlideVoice`を次のボイスモデルへ切り替える(パレットの設定欄「発表ボイス: <名前>」)。

### SlideVoicePrepare[] / SlideVoicePrepare[nb]
発表シナリオ全スライドの音声を先に合成して`<deck>_voice/`にキャッシュする。

### SlidePlay[] / SlidePlay[nb]
`<deck>_talk.md`の原稿をSourceVaultのローカル音声で読み上げながらスライドを自動で進める(対象ノートブックのスクリーン環境がSlideShowのとき)。一時停止中に呼ぶと再開する。

### SlidePause[]
読み上げを一時停止する。`SlidePlay[]`で続きから再開する。

### SlideStop[]
読み上げを止めて再生状態を初期化する。

### SlideShowSlide[spec]
表示するスライドを変える。specは番号、`"Next"`/`"Previous"`/`"First"`/`"Last"`、または見出しや本文に含まれる語(文字列)。音声からの「一つ前のスライド」「三枚目」「バードバスのスライド」もこの関数を通る。

### SlideTitles[] / SlideTitles[nb] → {String...}
開いているデッキの見出し一覧を返す。

### SlideToggleRealtime[]
音声応答(SourceVaultRealtimeStart / Stop)を切り替える(パレットの「応答on/off」)。

### SlideToggleMic[]
音声応答のマイクをmute / unmuteで切り替える(パレットの「マイクon/off」ボタン、手元リモコンの「前の曲」ボタンと同じ動作)。音声応答が動いていないときは何もしない。`"Quiet" -> True`で知らせのダイアログも出さない(手元リモコンからはこちらで呼ぶ)。

### SlideCurrentNumber[] → Integer
今画面に出ているスライド番号を返す。

### SlideIndex[] / SlideIndex[nb, opts] → Dataset
発表の索引をDatasetで返す(番号・見出し・字数・推定秒数・累計)。各行のShowボタンでそのスライドを表示、Playボタンでそのスライドの音声を試聴できる。
Options: `"Voice" -> Automatic`, `"Questions" -> True` (質問受付の待ちも累計に入れる)

### SlideSpeakSlide[n]
n枚目の原稿を今の声で読み上げる(索引のPlayボタンと同じ)。ローカルの声なら合成してその場で再生し、realtime:の声なら動いている音声会話に読ませる。

### SlideInfo[]
デッキと発表の情報(枚数・原稿・見積時間・声・音声会話の状態)をまとめたウインドウを開く(パレットの「情報」と同じ)。

### SlideTalkDuration[] / SlideTalkDuration[nb | "deck.nb" | "deck_talk.md"], opts] → 秒数
発表シナリオ`<deck>_talk.md`から発表にかかる時間を見積もる(質問は無いものとする)。
Options: `"Voice" -> Automatic` (選択中の声), `"Questions" -> True` (質問受付の待ち時間も足す), `"View" -> True` (Dataset表示)
ローカル音声で合成済みのスライドはキャッシュの実長を使い、それ以外は文字数と話速から見積もる。

### SlidePlayStatus[] → <|Status, Slide, SlideCount, Voice, Notebook, CacheDirectory, LastFailure|>
読み上げ再生の状態を返す。

## 手元リモコン

Elecom Relaconなどのメディアキー付きリモコンでスライド操作をする層。Windows専用。フロントエンドのキーイベントを経由しないためスライドを全画面表示したままでも効く。

### SlideRemoteStart[opts]
手元デバイス(Elecom Relaconなどのメディアキー)の見張りを始める。どのボタンが何をするかは`$SlideRemoteBindings`で決まる。
Options: `"Bindings" -> Automatic` ($SlideRemoteBindings), `"Tick" -> Automatic` ($SlideRemoteTick、見張りの周期)

### SlideRemoteStop[]
手元デバイスの見張りを止める。

### SlideRemoteStatus[] → <|Watching, Available, Checked, Bindings, Tick, Hint|>
手元デバイスの見張りの状態を返す(状態を見るだけでuser32.dllを開かない)。

### SlideRemoteProbe[opts] → Association | Dataset
「そのボタンがどの仮想キーを出すか」を実測する。呼んでから`"Seconds" -> 10`の間に手元デバイスのボタンを何度か押すと、反応した仮想キーが一覧で返る。`"Suggestion"`は`$SlideRemoteBindings`への割り当て例。`"View" -> True`でDataset。実測の間は見張りを一時的に止め、終わったら元の割り当てのまま戻す。
Options: `"Seconds" -> 10`, `"View" -> False`

### $SlideRemoteBindings
型: Association, 初期値: `<|"MediaPrevTrack" -> "Mic", "MediaPlayPause" -> "Play"|>`
手元デバイスのボタン(仮想キー)と動作の対応。「前の曲」でマイクのmute/unmute、「再生/一時停止」で読み上げの再生/一時停止。キーは名前(`"MediaNextTrack"`)でも番号(`16^^B0`)でも`"0xB0"`でもよい。どのボタンがどのキーを出すかは`SlideRemoteProbe[]`で実測できる。動作は`"Mic" | "Play" | "Stop" | "NextSlide" | "PreviousSlide" | "None"`。読めない指定は黙って落とす。

### $SlideRemoteTick
型: Real, 初期値: `0.15`
手元デバイスを見張るカーネル側ScheduledTaskの周期(秒)。押下はWindows側に溜まるので、この値は取りこぼしではなく反応の速さを決める。

### $SlideRemoteAuto
型: Boolean, 初期値: `True`
`True`(既定)なら、音声応答(SlideToggleRealtime)を始めると同時に手元デバイスの見張りを始め、止めると同時に止める。

## インタラクティブ編集 (SlideWorkflow.wl に統合済み)

### $SlideWorkflowInteractiveVersion
型: String, 初期値: interactive レイヤーの版番号
統合済みインタラクティブレイヤー(旧 SlideWorkflow_interactive.wl)のバージョン識別子。

### ShowSlidePalette[]
スライド作成パレットを表示する(v1.21 から Claude Code パレットと同じ詰め方: ボタン 110/54×18、見出しは素の Style、`Column[.., Alignment->Center, Spacings->0]`)。v1.30 の並び (上から):
- **作る (知識グラフ)**: ストーリー / 文献 → KG構築 / 推敲 → 周辺知識 / 図解 → 調整 / KG図 → 生成 (横幅いっぱい)。「KG図」= `SlideGraphViewer` (計画の表も窓の中。旧「計画」ボタンの `SlideGraphShow["Plan"]` は関数として残る)。工程の順 (左から右、上から下)。KG構築は文献に和訳ノートがあれば論文から、無ければプロンプトセルの筋書き (シナリオ) から作る。「生成」は前回の生成スライドがあれば置き換えるか聞く。
- **1 枚ずつ**: プロンプト / 展開 (知識グラフを使わない従来の作り方)、＋スライド / 出典、英訳 / ×英訳、全スライド英訳。
- **挿入**: メモ / 指示、辞書 / トーク、質疑 / 終端。
- **表示・書き出し**: 知識グラフを見る (v1.31、横幅いっぱい。`SlideGraphViewer` の窓を開く。「作る」欄の「KG図」と同じ)、Working⇄Slideshow / ⇄プロンプト、一覧、画像 / mp4。パレットの見出しに版数 (`$SlideWorkflowInteractiveVersion`) を出す (読み込み直したかの目印)。
- **発表の準備**: 原稿 (`SlideTalkFill` = 原稿の無い枚にだけ原稿を書く) / QA生成、QA一覧 / 登録。どれもスライドの作り方 (知識グラフ / 展開) によらない。
- **発表**: 情報 / マイク、再生 / 停止、応答 on/off (横幅いっぱい)、進捗。
- **設定**: 展開時のトーク生成 on/off と「発表ボイス: <名前>」(押すと次のボイスへ。**P:/M: は Claude Code パレットで設定する**)。
主なボタンにはツールチップ (`iSWTip`、静的) で何をするかを書いた。v1.29 までの発表欄「シナリオ」(`SlideTalkBuild` = トークセルを `<deck>_talk.md` に束ねる書き出し) はパレットから外した (トークセルが原稿の正本で、発表にも登録にも md は要らない。スライドのシナリオ = プロンプトと紛らわしかった)。`"Safe"->True` は互換のため残る (v1.21 で ClaudeCode を呼ぶ要素は無くなった)。FE セッションではパッケージロード時に自動表示され、FE の「パレット」メニューにも "SlideWorkflow" として登録される(headless ロードでは両方スキップ)。

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

### SlideDeckInsertScenario[nb, afterN, md, opts] → Success | Failure
シナリオ Markdown のスライド群を、開いているデッキの afterN 枚目の直後へ挿入する(afterN=0 で先頭)。既存スライドには触れない(差し替えは SlideApplyScenario)。
Options: `"Figures" -> {}` (mdの`<<FIG1>>`..に対応するGraphics/Graphics3D/Image/Cellのリスト)

### SlideAddSlide[]
現在スライドの直後に新規スライド骨格(navbar+タイトル+SlidePrompt セル)を挿入。プロンプトに「◯枚構成で」等と書けば「展開」で複数スライドに一括展開できる(SlideApplyScenario は複数 ## を複数枚に分割する)。

### SlideTranslate[] / SlideTranslateRevert[] / SlideTranslateDeck[]
現在スライド(/全スライド連鎖)のテキストセルを `$SlideTranslationLanguage` へ一括翻訳。Dictionary 厳守・出典セルは対象外。原文は TaggingRules `"SWOrigText"` に保存され Revert で復元。

### $SlideTranslationLanguage
型: String, 初期値: 日本語環境なら`"English"`
`SlideTranslate`/`SlideTranslateDeck`の翻訳先言語。

### SlideInsertPrompt[] / SlideInsertCitation[] / SlideInsertEndMarker[] / SlideInsertNote[] / SlideInsertDirective[] / SlideInsertDictionary[] / SlideInsertBibliography[] / SlideTogglePrompts[]
各種セルの挿入(Documentation` ロード済みなら DocInsert* に委譲)とプロンプトセルの表示切替。

### SlideToggleScreenEnvironment[]
対象ノートブックのスクリーン環境をWorking⇄SlideShowで切り替える(書式メニューの「スクリーンスタイル環境」と同じ)。メモ・指示・辞書・文献・プロンプトの各セルはWorkingで可視、SlideShowで非表示になる。

### SlideEnsureDeckStyles[nb]
デッキにメタセル用スタイル定義(Note/Directive/Dictionary/Bibliography/References/SlidePrompt/SlideTalk/SlideQA。SlideShow 環境で非表示)を埋め込む。パレットの挿入・展開・表示切替から自動で呼ばれ、documentation.wl の DocInsert* もこの定義を使う。

### SlideTogglePrompts[]
全 SlidePrompt セルの表示/非表示を切り替える。

### $SlideExportExternal
型: `Automatic | True | False`, 初期値: `Automatic`
パレットの画像/mp4 書き出しを別プロセス(wolframscript)で行うかどうか。`Automatic`(既定)は 1 度試し、ライセンス席不足等で子プロセスが起動できなければ以後は FE 内処理へ自動フォールバックする。`True`強制 / `False`無効。

**大きなデッキで FE がフリーズする問題への対策**: パレットの書き出し・一覧・シナリオ md は、以前ノートブック全体を `NotebookGet` でカーネルへ転送していた。99MB のデッキではこの FE→カーネル転送だけで FE が長時間応答不能になる。現在は**保存済みであればファイルパスを渡し、カーネル側の `Get` で読む**(FE を介さない)。未保存の場合のみ従来経路になるため、大きなデッキでは**書き出し前に保存**すること(ステータスバーにも警告が出る)。

### $SlideHideToolbarInSlideshow
型: Boolean, 初期値: `True`
`True`(既定)なら、表示切替(SlideToggleScreenEnvironment)でSlideShowへ入るときに標準ノートブックツールバー(MultipurposeBar)とノートブック側DockedCells(CloudPublishableのPublic/Privateバッジ等)を一時退避し、Workingへ戻すときに復元する。ノートブック側DockedCellsはスタイルシートのスライドナビバー定義を上書きするため、退避しないとナビバーが出ない。

## 知識グラフ駆動生成 (v1.20)

仕様: `SlideWorkflow_info/design/slide_knowledge_graph_spec_v0_1.md`。計算は `SourceVault_knowledgegraph.wl` (`SourceVaultKG*`)、ここは接合層。生成物は知識グラフ (KG) で、スライドは「聴き手 × 時間」への決定的な投影。

### 素材は 2 通り (v1.30)
- **論文 (文書)**: 文献欄に和訳ノートブック → `SlideGraphSeed` (段落・図・式を決定的に) → 推敲。
- **シナリオ (文書なし)**: プロンプトセル (`SlidePrompt`、パレット「1 枚ずつ」の「プロンプト」) に発表の筋書きを書く → `SlideGraphSeedScenario` → 関連研究の候補 (`SlideGraphRelated`) → 筋書きの展開 (推敲の連鎖の Scenario 回)。従来の「プロンプト → 展開」(1 枚ずつ、知識グラフを使わない) はそのまま使える。
- 選び方: Story の `Source:` (`シナリオ` / `文献`) > 文献欄に和訳ノートがあれば論文 > プロンプトセルに筋書きがあればシナリオ。どちらも無ければ Failure (NoReferences) で両方を案内する。
- 以後の工程 (周辺知識 → 図解 → 調整 → 計画 → 生成) と発表の準備 (原稿 / QA / 登録) は同じ。

### Story セル (`SlideStory` スタイル)
`Key: value` 行: `Graph:` (KG の id、未記入は Title から) / `Audience:` (`高校生, 電気化学=0.3, 高校数学III` のようにプリセット + 領域=理解度) / `Slides:` / `Minutes:` (または `Seconds:`) / `Language:` / `Strategy:` (Source|Coherent|Importance|Difficulty) / `Story:` (以降の行はストーリー指示)。Working 可視 / SlideShow 非表示 / 書き出し・英訳対象外。展開プロンプトにも `=== Story ===` ブロックとして注入される。

### SlideInsertStory[]
Story セルの雛形を挿入 (パレットの「ストーリー」。工程順で先頭 = KG構築・推敲・原稿のプロンプトに入るので最初に書く)。
v1.27 から雛形は**文献欄の和訳ノートから起こした奨励ストーリー**になる: 要旨 (概要 / Abstract / SUMMARY) の結びの 1 文を結論に、見出し (数の多い階層。概要・Highlights・謝辞・付録・参考文献・方法の節などは除く、最大 6) を順序に入れ、強調・図を主役にする・省く・用語・方程式の既定の方針を添える。DocImportPaper の「第二部」(計算の再構成) から先の見出しは使わない。KG が既にあれば、見出しを KG の節の題 (推敲済みの日本語。節ノードの `Source.Section` と出現順で対応) に置き換える。穴埋めの見本文 (「ここに書く」) は残さない — 書き換えないまま LLM へ渡ってしまうため。文献が無ければ節名のない一般形。言語は和訳ノートの文字から決める (UI が英語でも日本語の論文なら日本語)。
`Key: value` 以外の行はすべて Story の続きとして読まれるので、「順序:」「強調:」「省く:」も Story に入る。

### SlideGraphSpec[nb | nbExpr | path] → Association
Story + Directive (Title / Language) から `<|"Graph", "Audience", "Slides", "Minutes", "Seconds", "Language", "Strategy", "Story", "Title", "SecondsPerSlide", "Source", "Survey"|>`。v1.30 のキー: `Source:` (素材 = `シナリオ` | `文献`。別名 `素材:` / `ソース:`)、`Survey:` (関連研究の探し方 = `local` 取り込み済みの文献 (既定) | `web` Web 検索も | `off` 探さない。別名 `サーベイ:`)。
**シナリオの雛形 (v1.30)**: 文献欄に和訳ノートが無くプロンプトセルに筋書きがあれば、「ストーリー」の雛形は `Source: シナリオ` / `Survey: local` と、筋書きの部の並びを「順序:」にしたものになる (`# ` で始まる行は説明のコメント)。

### シナリオの部分け (v1.30)
デッキのプロンプトセル (前置き・各スライド、文書の順。「ここにこのスライドで伝えたい内容…」の雛形のままのセルは読まない) を部に分ける (`iSWScenarioParts`): 1 つのセルの中は **見出し (`#`〜`####`) > 行頭の番号 (`1.` `2)` が 2 行以上) > 空行で区切った塊 > 全体で 1 部** の順。見出しより前の文は最初の部になる。部の題目は見出し (番号・箇条記号を外し、最初の文で切って 40 字まで)。

### SlideGraphSeedScenario[nb | {<|"Title", "Text"|>..}, opts] → <|"Graph", "Title", "Parts", "NodeCount", "KG"|> (v1.30)
筋書きから第一次 KG を**決定的に**作って保存する。root (Label = 指示セルの Title、無ければ最初の部の題目。Text = 部の題目の並び) の下に、部ごとに節ノード `sc<i>` (Kind Section、Text = 部の筋書き) と筋書きノード `sc<i>_d` (本文 = 筋書き、要点なし = 「未推敲」) を置き、`sc<i-1> → sc<i>` を Precedes で結ぶ。KG の `"Kind"` は `"Scenario"`。作り直しても周辺知識 (Background 層) とその辺は残す (`"Keep" -> "Background"`)。opts: `"Graph"` / `"Title"` / `"Language"` / `"Save"`。筋書きが無ければ Failure (NoScenario)。

### SlideGraphRelated[nb | graphId, opts] (v1.30、非同期)
シナリオ KG の関連研究の候補を集めて KG に保存する。
1. LLM が筋書きから検索語を作る (`{"Queries": [..]}`、4〜8 個。題目・要約への部分一致なので 1〜3 語の短い語句、日本語と英語)。
2. 検索語ごとに `SourceVaultSummaries[q, "Providers" -> {"sources", "eagle"}, "Limit" -> 6]` (取り込み済みの論文・Web・ローカル・Eagle)。`"Web" -> True` (Story の `Survey: web`) のときだけ `SourceVaultWebSearch[q, "MaxResults" -> 5]` も使う (検索語が外に出るので、書いたときだけ)。
3. 同じ文献を 1 つにまとめ (URI > Id > URL)、当たった検索語の多い順に最大 `"MaxCandidates"` (20)。**PrivacyLevel >= 0.5 の候補はデッキの PrivacyLevel がそれ以上のときだけ残す** (公開の発表に非公開の資料を引かない。除外数は `"Excluded"`)。題目の拡張子 (.pdf など) は外す。
4. KG に `"Related"` (`<|Key, Kind, Id, URI, URL, Title, Authors, Year, Summary, PrivacyLevel, Queries|>` のリスト)、`"RelatedQueries"`、`"RelatedWeb"`、`"RelatedAtUTC"` を保存し、`"Then"` を呼ぶ。結果は `SlideWorkflow`Private`$iSWRelatedLast` (`Status` / `Queries` / `Candidates` / `Excluded` / `Web`)。
実データ (9/17): 検索語 6 個で 11 秒、候補 12 件 (非公開 5 件を除外)。「自由エネルギー」のような広い語は熱力学の教科書も拾うので、どれを紹介するかは展開の LLM が筋書きに照らして選ぶ。

### 筋書きの展開 (推敲の連鎖の Scenario 回、v1.30)
KG の Kind が `"Scenario"` なら、推敲 (`SlideGraphRefine` の Direct 連鎖) は節ごとに筋書きを発表用のノードへ**展開**する (状態欄「KG 展開」)。プロンプト = 聴き手・ストーリー・全体の筋書き (節の並び)・展開する節の筋書き・関連研究の候補 (番号. 題目 / 著者 / 年 / 種類 と要約)。LLM は節ノード (Label / Summary)、`<節>_1..` (1 ノード = 1 枚、Lead / Points / Details / Talk / Importance / Kind、候補に依拠するなら `"Ref": [番号]`)、`rw_<候補番号>` (関連研究の紹介、`"Parent"` で節)、`bg_*` (前提) を返す。受理 (`iSWScenarioSanitize`): それ以外の Id は落とす / 候補に無い番号の `rw_` は落とす / 新しい枚には節からの Contains と、節の Order + 0.01 刻みの順序 (LLM が並べた順) と Precedes / `rw_` の Cite は候補の「題目 (著者, 年) 所在」、PrivacyLevel は候補から / 同じ候補は最初に出た節にだけ置く / 枚ができた節の筋書きノード (`<節>_d`) は外す。ノードの Kind に `RelatedWork` と `Example` を足した (SourceVault_knowledgegraph)。KG の Kind に `Scenario` を足した。
KG構築 (シナリオ) の流れ: `SlideGraphSeedScenario` → `SlideGraphRelated` (`Survey: off` なら飛ばす) → 展開。途中で止まっても筋書きノードが残るので「推敲」で続きから、「図解」「調整」は先にその節を展開する (v1.29 の未推敲の節の検出がそのまま効く)。

### SlideGraphBuild[] / SlideGraphBuild[nb, "Mode" -> Automatic | "Extract"]
v1.30: 素材を選ぶ (上の「素材は 2 通り」)。シナリオなら `SlideGraphSeedScenario` → `SlideGraphRelated` → 筋書きの展開。以下は論文の場合。
v1.22 (v1.23 で seed の規則を追加、下記): References に和訳ノートブック (.nb、`DocImportPaper` の出力) があれば `SlideGraphSeed` で第一次 KG を**決定的に**作り、続けて節ごとの推敲を行う。v1.24: 推敲は既定で `SlideGraphRefine` の Direct 連鎖 (LLM を節ごとに直接呼ぶ)、`"Mode" -> "Agent"` でエージェント委譲。.nb が無ければ Failure (`NoSourceNotebook`) で `DocImportPaper` を案内する。`"Mode" -> "Extract"` は従来の PDF 直読み抽出 (局所モデルでは途中で壊れやすい)。

### 文献の自動解決 (v1.22)
References の locator が SourceVault 取り込み済みの論文 (`src-…` / `sv://…` / `arxiv:…`) で、`SourceVault_papernb.wl` の登録簿に和訳ノートブックがあれば、その行は自動的にノートブック扱いになる (`"Notebook"` キー)。 Eagle の PDF (`sv://object/eagle-<id>` / `eagle:<id>`) も同じ: 登録簿は正準 URI で引き、PDF の資産 (`SlidePDFFigure`) は `SourceVaultEagleObjectInfo` で item の実ファイルに解決する (v1.25)。`SlideGraphSeed` / `SlideNotebookOutline/Text/Figure/Formula[key]` はそのノートを読み、PDF の資産 (`SlidePDFFigure[key, ..]`) は従来どおり原本 PDF に解決される。生成は `SourceVaultMakePaperNotebook["src-…"]` (一覧の「＋ 和訳NB」)。

### SlideGraphSeed[nb | key | path, opts] → <|"Graph", "Title", "PaperTitle", "NodeCount", "Sections", "Paragraphs", "Figures", "Formulas", "Kept", "Authors", "Skipped", "KG"|>
和訳ノートブックの構造から第一次 KG: 見出し → Section (階層は Contains)、段落 → Concept (本文は `"Text"`、ラベルは冒頭、要約は先頭 2 文)、図 → Figure (NotebookFigure 資産、キャプション「図 n.」「図n |」「Figure n:」「Fig. n.」がラベル。図の前後どちらにあっても合流)、数式 → Equation (Formula 資産)。同じ節の段落・式は Precedes で順序づけ、図は前後の段落へ Supports。Abstract セルは根 (Claim) の要約。opts: `"Graph"` / `"Title"` / `"Language"` / `"MinCharacters"` (40) / `"Save"` / `"Reconstruction"` (False) / `"Keep"` ("Background")。

v1.23 の規則 (DocImportPaper 出力を WikiSkill で実測して追加):
- Title セルが無く、最初の見出しより深い見出しが後に続くなら、その最初の見出し (論文題名) は節にせず root に畳む (`"PaperTitle"`)。以後の章は root の直下 = 「部」。
- 題名直後の著者・所属行 (`^{1}` / † / 大学名 + カンマ) はノードにしない (`"Authors"`)。
- root 直下の最初の長い段落 (200 字以上 = Abstract 相当) は「概要」ノード (Importance 0.8) にし、root の要約にもする。
- 付録 (`A.` / `A.1.` / `Appendix` / `付録`) の節・段落・図・式は Importance 0.3 (本文 0.5 より下、かつ `PackRatio` 0.35 未満なので、枚数が足りなければ落ち、末尾の枚に箇条書きとして詰め込まれもしない。冠詞の "A Unified …" は付録ではない)。
- 参考文献・謝辞に加え AI Disclosure / Ethics / Reproducibility / Impact statement を読み飛ばす。
- DocImportPaper の第二部「計算の再構成」(派生部) は既定で除外。`"Reconstruction" -> True` で含める。
- 再 seed でも保存済み KG の Background / Shared 層 (周辺知識) のノードと、それに触れる辺を残す (`"Kept"` に個数)。辺は論文側の端点が「同じ Id で同じ内容」のときだけ残す (節は `Source.Section` の見出し、段落・式は `Text` で照合。節 Id `s*` は連番なので規則が変わると番号がずれるが、誤接続はしない)。`"Keep" -> None` で捨てる。

### SlideGraphSectionText[graphId] / SlideGraphSectionText[graphId, sectionId, opts] → String
節の一覧 (Id / Label / 本文ノード数 / 下位節) / 節**自身**の本文ノード (直下の段落・図・式。入れ子の下位節は別に扱う) と節内の非 Contains 辺。既定は読むための平文 (`"Format" -> "Text"`。局所モデルが JSON を `ReadRawJSONString` で解析しようとして承認待ちで止まったため)。長い節は `"MaxCharacters"` (4000) ごとにノード境界でページに分かれ、`"Page" -> n` で続きを読む (末尾に次ページの式)。エージェントに戻る評価結果は NBAccess の `$NBRedactedResultMaxLength` (6000) で切られるので 1 ページはそれより小さい。`"Format" -> "JSON"` で `<|"Section", "Nodes", "Nested", "Edges"|>` の JSON 文字列 (ページ無し)。

### SlideGraphRefine[] / SlideGraphRefine[nb, opts] / SlideGraphRefine[graphId, opts] → <|"Status" (Submitted|UpToDate|Busy), "Batches", "Sections", "PrivacyLevel"|>
`"Mode" -> "Talk"` (v1.25): 要点はあるが `Talk` の無いノードに原稿 (Points と同じ順に 1 要点 1〜2 文) だけを足す軽い回。推敲の差分 JSON も `Talk` を含む。
v1.24: 既定 (`"Mode" -> "Direct"`) は LLM を節ごとに直接呼ぶ callback 連鎖 (QA 生成と同じ仕組み)。節一覧で「済」でない節を上から順に、本文ノード合計 `"BatchNodes"` (8) 以下の隣接節を 1 リクエストにまとめ、**節本文を指示に同梱**して差分 JSON `{"Nodes", "Edges", "Remove"}` だけを返させ、`SlideGraphIngest[.., "Merge"->True]` で取り込む。受理する Id は本文に出た既存 Id と新規 `bg_*` だけ (幻覚 Id は落とす)、Remove は本文ノードだけ (節は残す)、形式違反は理由を添えて 1 回再問合せ、2 回失敗した節は飛ばして続行し末尾に記録。進捗は WindowStatusArea、完了時に終端マーカー後へ 1 行。途中で止めても「済」の節は飛ばして再開できる。LLM の経路 (CLI / 私的モデル) は `PrivacyLevel` (デッキ指示と KG ノードの最大) で `ClaudeQueryAsync` が決める。`"Sections" -> {"s3", ..}` で対象を絞る。graphId 形式 (headless) は `"Audience"` / `"Story"` を受ける。
`"Mode" -> "Agent"` は従来のエージェント委譲 (`SlideGraphSectionText` で 1 節ずつ読む)。エージェント経路は 1 実行あたり提案 4〜5 ターン (`ClaudeRuntime` の Eval 予算) で打ち切られるため、40 節の推敲には向かない。
`"Mode" -> "Enrich"` (別名 `"Detail"`): Lead / Details を後付けする回 (元の本文 Text も渡す)。
`"Mode" -> "Visual"`: 図解の回(下記「図が主役のスライド」参照)。

### SlideGraphIngest[graphId, json | File[path], opts] → Success | Failure
KG の唯一の書き込み口。`"Merge"->True` (差分) / `"Language"->"en"` (訳の併記) / `"Link"->True` (周辺知識を共有層へ連結)。

### SlideGraphBackground[] / SlideGraphBackground[nb]
聴き手に足りない周辺知識ノードの追加をエージェントへ委譲。v1.27 から Story セルの `Story:` も委譲文に入る (「introduction は関連論文を引用して解説」のような、どの前提知識を足すかの要求はここで効く)。それ以前は聴き手しか渡しておらず、Story に書いても届かなかった。

### SlideGraphTranslate[nb, lang]
ノード単位の翻訳をエージェントへ委譲 (セル単位の `SlideTranslate` とは独立)。

### SlideGraphPlan[nb | graphId | kg, opts] → <|"Graph", "Tree", "Plan", "Verify", "Spec"|>
opts: `"Slides"` / `"Seconds"` / `"Audience"` / `"Strategy"` / `"SecondsPerSlide"` / `"Language"` (未指定は Story セル)。

### SlideGraphPlanView[src, opts] → Dataset

### 物語の見せ方 (v1.25)
KG から生成するスライドは、階層 (順序木) を視聴者に見せる:
- **目次**: 部 (根直下で Contains の子を持つ節) が 3 つ以上なら根の直後に「全体の流れ」を 1 枚 (指定枚数に収まるよう計画は 1 枚少なく取り直す)。
- **パンくず** (`crumb:` 行 → `SlideCrumb` セル、題目の直下に小さく右寄せ): 「第k部 <部の題目> › <親スライド>」。根直下の葉 (概要・図 1) と目次には付かない。
- **道標**: 節スライドの要点はその節の子スライドの題目 (原稿は「この部では、A、B、C の順に見ていきます。」)。LLM が節に付けた要点は原稿へ。`SourceVaultKGOutline[.., "Roadmap"->False]` で従来どおり。
- **橋渡し**: 部の入口の原稿は「ここから第k部「…」に入ります。」で始まる。
- **原稿と箇条書きの対応**: 原稿はノードの `Talk` (Points と同じ順の文) を表示した要点数 + 1 文に切り詰めて使い、無ければ要点をそのまま文にする (Summary は箇条書きと対応しないことがあるので使わない)。推敲プロンプトは Talk を要求する。古い KG には `SlideGraphRefine[nb, "Mode"->"Talk"]` で原稿だけ後付けできる。
- **行数予算**: 1 枚 9 行 (折り返しは 40 字で数える、図は 4 行分)。子の要点 → 自身の要点 (2 行まで) の順に落とし、それでも入らない子は同じ題目 + (続き) のスライドへ。同じ前提ノードが複数枚に重複して詰め込まれることはない。
- **行内数式**: 和訳ノートの本文セルの数式 boxes は seed で `$tex$` (TeX) になり、tex → boxes の辞書がノードに残る。生成時に箇条書きの `$tex$` は元の boxes に戻す (完全一致)。辞書に無ければ TeX 読み込み (扱えるマクロだけ。未知のマクロは壊れた文字列になるので通さない)、それも駄目なら文字列のまま。推敲プロンプトは `$...$` を書き換えないよう指示する。

### スライドだけで伝わる構成 (v1.26)
生成スライドは「原稿が無くても内容が分かる」形にする:
- **導入文 (Lead)**: 題目の下に地の文で 1 文 (この枚で言いたいこと)。ノードの `Lead`、無ければ Summary の最初の 1 文。
- **補足 (Details)**: 各要点の直下に根拠・補足を 1 行 (ノードの `Details`、Points と同じ長さ)。推敲 JSON は `Lead` / `Details` / `Talk` を要求し、古い KG には `SlideGraphRefine[nb, "Mode"->"Enrich"]` (別名 "Talk" / "Detail") で後付けできる (元の本文 Text も渡す)。
- **強調**: `**…**` は太字になる (数式 `$…$` と併用可)。
- **その枚にある図表しか指せない**: 要点・補足・原稿に「(図2)」「(Table 1)」のような言及があり、その図がこの枚に無ければ、枠 (`MaxAssetsPerSlide` 2) があれば図を**再掲**し (出典も付く)、無理なら括弧つきの言及を消す。表は資産にならないので消す。`"ReShowFigures" -> False` で再掲を止める。図ノードは資産で見分ける (推敲で Kind が変わっていてもよい)。seed は図ノードの `Source.Caption` にキャプションの番号を残す。
- **1 行だけの枚を作らない**: 子スライドが 1 つしかない節は道標にならないので枚を畳み、秒は子へ、部の入口の橋渡しとパンくずも子が引き継ぐ (`"Collapsed"`)。道標は子スライドが 2 つ以上のときだけ。
- **原稿の長さ**: 秒数 × 話速 (`"CharsPerSecond"`: ja 7 字/秒、en 14 字/秒) と表示行数 + 2 文で切る (文の切れ目)。詰め込んだ子は Lead (無ければ要点 2 つ) を 1 行で示す。

### 1 枚で完結させる調整 (v1.27)
- **原稿の長さは分割後の秒数で決まる**: 「(続き)」に分けたあと、1 枚あたりの秒数 (`Seconds`) と行数で切る。v1.26 は分ける前の秒数 (節から引き継いだ分を含む) で上限を取っていたため、実際の KG では一度も切り詰められず 1 枚 370 字の原稿が出ていた。
- **要点 1 つだけの「(続き)」を作らない**: あふれた子が 1 つだけなら、詰め込みを解いてその子自身のスライドにする (題目・導入文・要点・図・出典・原稿は子ノードのもの)。2 つ以上あふれたときだけ「(続き)」。
- **続きの枚も図の規則に従う**: 続き・昇格した枚でも、言及された図がその枚に無ければ再掲するか言及を消す (v1.26 は親の枚の図番号をそのまま引き継いでいた)。
- **括弧の中は項目ごとに判定**: 「(図7A, 1,450 s)」は図番号だけ落として「(1,450 s)」になる。地の文を含む括弧 (「(図2 の A 区間)」) はそのまま。行頭の「Figure 9A: …」のような前置きも、その図が無ければ落とす。
- **原稿は声に出せる形で書かれる**: トークセルは読み上げ (`SlidePlay`) と mp4 の元になるので、`$...$` の数式と `**強調**` の印を残さない。複雑な式 (分数・べき・等号・総和など) は**スライドに出ているので「この式」と指し**、記号 1 つや短い和差だけ声に出す (`$u_e$` → 「u e」、`$\delta$` → 「デルタ」)。TeX のまま読ませると「frac」と発声されて伝わらない。変換はシナリオからトークセルを作るときと音声合成の直前の両方で走るので、既存デッキも作り直さずに正しく読まれる (`iSWTalkSpeakText`)。
- **式の記号はスライドで説明させる**: 推敲プロンプトに「式に現れる記号の意味を Points か Details に必ず書く」「Talk に `$...$` を書かず、画面の式を指して語る」を追加。式だけ載って記号の意味が分からない枚を作らせない。

### 図が主役のスライド (v1.28)
計算と自然 32 回 (図・写真・表が主役で、箇条書きがそれを説明する) を目標にした生成。33 回の生成では図のある枚が 44 枚中 6 枚しかなかった。
- **図の継承** (`SourceVaultKGOutline` の `"InheritFigures"` True): 図の無い本文の枚に、辺で結ばれた論文の図 (無ければ同じ節の図、出現順の近い順) を再掲する。1 段目 = 辺で結ばれた枚、2 段目 = 同じ節の枚。1 つの図を継承で見せ直すのは `"FigureReuse"` (2) 回まで。節の枚・根・詰め込んだ子に図がある枚は対象外。結果の `"FigureUse"` に図ごとの継承回数。
- **用語ミニ辞書** (`"Glossary"` Automatic): 図も子も無い周辺知識 (重要度 0.8 未満) の枚が続くところは、1 枚ずつ概念スライドにせず「用語ミニ辞書」の表 (`"GlossaryRows"` 6 行ずつ、1 行だけ余る表は前の表に足す) にまとめる。行 = 題目 (「 — 補足」を落とす) | Lead (無ければ最初の要点)。結果の `"Glossary"` にまとめたノード。
- **図と箇条の交互配置**: 図が 2 枚以上なら、箇条 (要点と詰め込んだ子) の間に図を挟む (箇条 → 図 → 箇条 → 図)。表は最後で、見出し行の下に `| --- |` を入れる。行数予算では表は行数 + 1 行、図は枚数によらず 4 行。
- **図解の回** (パレット「図解」= `SlideGraphRefine[nb, "Mode" -> "Visual"]`): 図の無いノードに、LLM が表 (`"Table"`) か概念図 (`"Code"` = Wolfram Language の作図コード) を 1 つ付ける。不要なら `"None"`。論文の実測データは作図し直させない (模式図と定性的な曲線だけ)。Story の指示 (「図を追加したほうがわかりやすいスライドには図を追加する」など) はここに効く。試したノードには `VisualDone` を付けて聞き直さない。完了メッセージに「図 / 表 / 不要 / 却下」の数。
  - 作図コードは**作図と数学の組込み関数だけ**を許す (`$iSWFigureHeadNames` + NumericFunction 属性)。隔離した文脈 (`SWFigSandbox``) で読み、大域シンボルを作らない。Import / Run / URLRead / DeleteFile / ToExpression / 他文脈の名前などが 1 つでもあれば却下。評価は 20 秒・300MB で打ち切り、Graphics / Legended / Graph / Labeled 以外は却下。
  - 生成時にデッキの字体・14pt で描き、下に Caption (「概念図: …」) を付けて 144dpi の画像にする (資産の型 `"WLFigure"`)。表は資産の型 `"Table"` (`"Rows"`、1 行目が見出し、2〜4 列、最大 8 行、1 セル 40 字)。
- 仕上げの回 (Enrich / Talk / Visual) は節の大きさに依らず `"BatchNodes"` (8) 個ずつに切る。どの節にも属さない周辺知識ノードも対象。
- `SlideGraphGenerate` / `SlideGraphApply` / `SlideGraphBuildDeck` の `"Outline" -> {opts}` で上の出力オプションを渡せる (例: `"Outline" -> {"InheritFigures" -> False, "Glossary" -> False}`)。

### 調整 — 生成したあとで直す (v1.28)
パレット「調整」= `SlideGraphAdjust[]`。スライドは KG から作り直すので、直すのは KG。
1. 「調整」を押すと調整セル (`SlideAdjust`、青枠。Working で見え、SlideShow と書き出しでは隠れる) が Story セルの後ろに入る。
2. 直したいことを書いて、もう一度「調整」を押す (例: 「論文の最初のページの図を説明するスライドを、結論の枚の後に入れる」「t 検定の枚は要らない」「実験系の枚の説明をもっと具体的に」)。
3. LLM が KG の差分を返し、検査してから反映する。反映したセルは灰色になり ✓ が付く (TaggingRules `SWAdjustApplied`。次に押すと、まだ反映していない次の調整セルを処理する)。
4. 古い生成スライドを消して「生成」。

LLM に渡すもの: 指示、いまのスライド構成 (番号・題目・ノード Id)、KG のノード一覧 (出現順、節の要約、図の有無、隠したノード)、使える図 (論文の図のノード / 論文 PDF の埋め込み画像 / 表 / 概念図)。
LLM が返す差分:
- `Nodes`: 新しいスライド = 新しいノード (Id は `adj_` で始める。`After` で位置、`Parent` で節、`Label` と `Points` は必須)、既存ノードの修正 (変えたいキーだけ: `Label` / `Lead` / `Points` / `Details` / `Talk` / `Importance` / `Assets` / `After` / `Hidden`)。
- `Hide`: スライドから外すノード (KG からは消さず `Hidden -> True`。計画は Hidden のノードをスライドにも詰め込みにも前提の修復にも使わない。結果の `"Hidden"`)。
- `Assets`: `{"Type": "Figure", "Of": "fig3"}` (論文の図の再掲) / `{"Type": "PDFImage", "Page": 1, "N": 1}` (論文 PDF の埋め込み画像) / `{"Type": "Table", "Rows": ..}` / `{"Type": "Code", "Code": .., "Caption": ..}` (図解と同じ検査)。使えない指定は落として注意に出す。PDF の画像の出典は「(key) p.n」。
- 新しいノードの Order は `After` の直後 (次のノードとの中点) で、`After → 新ノード` の Precedes 辺と、節からの Contains 辺を足す。
- `SlideGraphAdjust[nb | graphId, "指示"]` で直接渡せる。opts: `"PDF"` (論文 PDF の locator。既定は文献欄 → KG の出典から PDF に解決できるもの)、`"Then"` (反映後に呼ぶ関数)、`"Refine"` (v1.29。False で未推敲の節の先行推敲をしない)。結果は `SlideWorkflow`Private`$iSWAdjustLast`。

**論文 1 ページ目の図 (全体像)**: 和訳ノートはキャプション (「図n |」) のある図だけを取り込むので、キャプションのない 1 ページ目の図 (グラフィカルアブストラクト。システムの全体像を示す、論文でいちばん大事な図) が KG に入らない。「図解」は最初に、この図がどのノードにも無く論文 PDF の 1 ページ目に画像があれば、調整の仕組みで「全体像」の枚 (結論・要点の直後、Importance 0.95) を足してから図解する (`"Overview" -> False` で止める)。
- `SlidePDFImages[src, "Page" -> n]` = そのページの埋め込み画像。各ページのラスタ (と Inset の画像) を PageGraphics で数え、`Import[pdf, "Images"]` の並びに縦横比で突き合わせる (ページに現れないアイコン画像は飛ばす)。1 ページだけの PDF は全部をそのページとみなす。対応が取れなければ Failure。初回の Import が文字コードの警告を出しても画像は取れているので `Check` では判定しない。
- 資産の型 `"PDFImage"` (`"Ref"`, `"Page"`, `"N"`)。図の枚では縦長・正方形の図を高さ 360pt までに収める (幅は 560pt)。

### 箇条書きが「…」で切れた枚 — 推敲が途中で止まった節 (v1.29)
計算と自然33 の 43 枚目以降は、題目が英語の見出し (Interpretation など) のままで、箇条書きが「…」で切れていた。原因は、その節 (s16〜s19、段落 36 個) が推敲されていなかったこと。seed の段落ノードは、段落の書き出しを「…」で切った仮の題目しか持たない。要点が無いので図解・仕上げの対象にもならず、そのまま生成されていた。KG の履歴では、KG構築のやり直し後の推敲が s15 まで進んだところで途切れている。その後に図解が始まっていた。ノートに「KG 推敲 完了」の行が無いので、止まった理由は記録から特定できない。
- **未推敲の節** (`iSWUnrefinedSections`) = 節に要約が無く、本文 (Text) があるのに要点の無いノードを含む節 (手で作った KG の、本文の無いノードは数えない)。
- **図解・仕上げ (Enrich/Talk)・調整は先にその節を推敲する** (状態欄「推敲が済んでいない節があります (…)。先に推敲します」→ 推敲の完了行「続けて図解します」など → 本来の回)。`"Refine" -> False` で止める。結果の `"RefineFirst"` に推敲した節。
- **生成は警告する**: `Unrefined: 推敲が済んでいない節が N あります (…)`。「推敲」を押すと、済んでいない節から続きを推敲する (済みの節は飛ばす)。
- **回の種類は回が持つ**: 推敲・仕上げ・図解の種類は開始時に ctx へ写し、連鎖の各段 (問い合わせ文・取り込み・完了) はそれで動く。大域の旗は開始直後に既定へ戻す (途中で別のボタンが旗を書き換えても、動いている回は変わらない)。実行中の目印は最後の問い合わせから 20 分で切れる (応答が戻らず連鎖が止まっても、ほかのボタンが 1 時間使えなくならないように)。
- **調整でスライド番号を指定できる**: 指示に「43 以降」「17 枚目」「スライド 5」「20〜22」があれば、その枚のノード (本体と詰め込んだ子) の題目・導入文・要点・元の本文 (600 字まで) を LLM に渡す (図や式の番号は拾わない)。番号はデッキの枚番号で、計画の最初の枚の題目をデッキで探して、先頭のタイトルなどの枚数だけずらす。ノード一覧では、要点の無い本文ノードに「要点なし」と付ける。

### 引用番号 (v1.29)
和訳ノートの引用番号は、土台が空の上付き (`SuperscriptBox["", "38"]`、`RowBox[{"23", "-", "25"}]`) になっている。KG構築 (v1.25 の行内数式) はこれを式として読み、`Null^38` → `$\text{Null}^{38}$` にしていた (計算と自然33: 本文 16 段落・式の辞書 14 件・要約 1)。「,」区切りは式にならず、`^23,26` のまま残っていた。
- KG構築は引用番号を `[38]` / `[23-25]` / `[3,4]` の文字にする (式の辞書に入れない)。土台が空白で上付きが ∘ のものは度 (°)。そのほかの空の土台は式にせず `^x`。TeX に `\text{Null}` が出たら式として扱わない。
- 既存の KG は、推敲・調整の開始時に一度だけ直して保存する (`iSWKGCiteRepair`。前の版は KG の履歴に残る): `$\text{Null}^{…}$` → `[…]` (`\circ` は °)、日本語や空白の直後の `^23,26` → `[23,26]`。対象の欄は Text / Summary / Label / Lead / Points / Details / Talk。式の辞書からは Null の項を外す。
- 読み上げ原稿の `[38]` などは読まない (英数字の直後の `a[1]` は残す)。

### 生成が途中で止まったように見える件 (v1.28 で修正)
- **順序木から論文本体が落ちていた**: 推敲や周辺知識を回すたびに同じ辺が積み重なり、同じ向きの辺が 2 本ある重みつき多重グラフでは `FindCycle` が評価されずに返る (15.0 実測)。LLM が作った閉路 (p11→…→p22→p11) が切れないまま線形拡張が止まり、166 ノード中 89 (論文の結果・図・式すべて) が生成から外れて、45 枚の指定で 23 枚しか出なかった。順序グラフは (From, To) ごとに 1 本 (重みは最大) で組み、`FindCycle` が使えなければ強連結成分を歩いて閉路を見つける。Merge は (From, To, EdgeKind) ごとに 1 本 (後のもの) を残す。閉路を切るために落とした辺は検証の違反に数えない (Cycles にだけ出る)。
- **黙って少なく作らない**: 順序木から落ちたノードがあれば `BrokenTree`、指定より 4 枚以上少なければ `Shortfall` を警告に出す。「生成」は結果 (枚数・指定枚数・警告) と、途中で失敗した枚をノートブック末尾の Text セルにも書く (状態欄は 4 秒で消えるため)。
- **節の数え違い**: 推敲で節の Kind が Conclusion などに変わると、Kind だけで数えた節が 0 になり、全ノードが根の 1 行 (= 1 リクエスト) に入っていた。Contains の子を持つノードも節とみなす (`iSWKGSectionIdSet`)。
- **「生成」を押してから十数秒なにも出ない**: 経過を状態欄に出す (「計画を作成中」「スライド構成を作成中」「N 枚に合わせて計画し直し中」「(a–b / N 枚): 図を準備中 (i/M)」「スライドを挿入中 (a–b / N 枚)」)。遅さの主因は聴き手の必要度計算で、領域名の正規化を組ごとにやり直していた (166 ノードで計画 1 回 約 6 秒、枚数合わせで最大 4 回) → 正規化と別名索引を覚えておき 0.1 秒台。さらに「生成」は全部の図を一度実体化してから 10 枚ずつもう一度実体化していたので、`SlideGraphGenerate[.., "Realize" -> False]` で最初の実体化を省く (`SlideGraphBuildDeck` と単体の `SlideGraphGenerate` は従来どおり実体化する)。
- **回の種類が戻らない**: 仕上げの回が「対象なし」で終わると、仕上げの印 (`$iSWRefineTalkOnly`) が立ったまま残り、後の推敲や節の一覧が仕上げの回のまま動いていた。実行中の回があるときはフラグに触らずに Busy を返す。

### 表示切替 (v1.25)
FE のプレゼンタービュー (Slide n of m) がノート側 `DockedCells` に SlideshowToolbar を焼くと Working でもナビバーが出続ける。`SlideToggleScreenEnvironment` はこれを退避せず、Working では `Inherited` に落とす。

### SlideGraphGenerate[src, opts] → <|"Markdown", "Figures", "Plan", "Tree", "Outline", "Warnings", "SlideCount"|>
資産 (NotebookFigure / Formula / PDFFigure / DeckSlide) を `SlideNotebookFigure` / `SlideNotebookFormula` / `SlidePDFFigure` / `SlideDeckFigure` で実体化。失敗した資産は落として `<<FIGn>>` を付番し直す。`"Talks"->{..}` で原稿差し替え。`"Realize" -> True` (既定)。

### SlideGraphApply[] / SlideGraphApply[nb, opts] → Success | Failure
デッキへ適用 (10 枚ずつ `SlideDeckInsertScenario`)。
**v1.30: 前回の生成を置き換える**。KG から作った枚は md の見出しに `{expected=秒 node=<ノード Id>}` (用語ミニ辞書は `node=glossary`、目次は `node=agenda`) が付き、題目セルの CellTags `"KGNode:<id>"` になる (`SlideScenarioFromMarkdown` の `"Node"`、`iSubsectionTags`、スライド → md の見出しにも戻る)。`"Mode" -> Automatic` はこの目印のある枚があれば `"Replace"`:
1. デッキの質疑応答セルを KG のノードへ保存 (`iSWKGHarvestQA`。同じノードの枚 = 本体と「(続き)」の順のリスト、空なら消す。agenda / glossary / KG に無い Id は無視)。
2. 新しい枚を前回の最初の枚の位置に入れる (`"After"` の既定)。
3. 前回の枚を消す (`iSWDeleteSlides`、後ろから)。途中で失敗したら前回の枚は残す。
生成は KG のノードの `"QA"` を同じノードの枚へ `qa:` として戻す (`iSWKGAttachQA`。枚が減ったら残りを最後の枚にまとめる)。目印が無ければ `"Append"` (最後のスライドの後、`"After"->n`)。v1.29 以前に生成した枚は目印が無いので残り、結果のメモで手で消すよう知らせる。結果: `"Mode"` / `"Replaced"` (消した枚数) / `"QA"` (保存の結果)。
パレットの「生成」(`iSWGraphApplyAction`) は、目印のある枚があれば「置き換える / 後ろに追加 / やめる」を聞く (手で直した本文と原稿は KG から作り直される — 残したい直しは「調整」で KG に入れる)。`"Polish"->True` で talk の推敲をエージェントへ委譲 → エージェントが `SlideGraphApply["Talks"->{..}]`。

### SlideGraphBuildDeck[graphId | kg, "deck.nb", opts] → <|"File", "Slides", "Warnings", "Verify", "Plan", "GraphId"|>
KG から新しいデッキファイル (headless 可)。`"TitleSlide"` / `"Event"` / `"Author"` / `"Date"`。

### SlideGraphSurvey[{graphIds}, "deck.nb", opts]
複数 KG を合成 (`SourceVaultKGCompose`) してサーベイデッキ。`"Title"` / `"Slides"` / `"Audience"` / `"Chronological"` / `"Save"`。

### SlideGraphView[src, "Nodes" | "Map" | "Graph" | "Tree" | "Plan"] / SlideGraphShow[what] / SlideGraphLoad[src]
表示 (Show は開いているデッキの Appendix へ書き出す)。`"Map"` は SlideGraphVisualize の図 (v1.30)。

### SlideGraphVisualize[nb | graphId | kg, opts] → Graphics (凡例つきは Labeled) (v1.30)
知識グラフの図。本体は `SourceVaultKGVisualize` (SourceVault_knowledgegraph)。デッキを渡すと Story セルの聴き手・枚数で計画を立てて枚番号を重ねる (`"Plan" -> Automatic | True | False | 計画`)。
- `"View"`:
  - `"Story"` (既定) = 話の流れの地図。節を話の順 (Order) に横へ、節の中身を縦に並べ、根の直下は左端の列、どの節にも入らない周辺知識は下の帯 (つながるノードの列の近く)。節の題目は上に互い違い。
  - `"Sections"` = 節の概観。節を一列に並べ、節をまたぐ辺を弧で (太さ = 本数、色 = 多い辺の種類)、周辺知識との辺は下の弧。節の丸の大きさ = ノード数、赤枠 = 未推敲あり、ツールチップ = 要約・図・質疑応答・未推敲の数。
  - `"Focus"` (`"Focus" -> Id`、`"Radius" -> 1..3`) = そのノードの近傍 (包含も含む) をばねモデルで。
  - `"Graph"` = 全ノードをばねモデルで。
- 見た目: 色 = 種類 (主張・結論 橙 / 節 灰 / 概念・定義 青 / 方法・実験 緑青 / 結果 臙脂 / 式・図 紫 / 問い 黄土 / 周辺知識 青緑 / 関連研究 橙茶 / 聴き手が知っている 薄灰)、形 = 層 (本文 丸、周辺知識 四角、関連研究 菱形、節 角丸の札)、大きさ = 重要度、赤枠 = 未推敲、黒の太枠 = 選択中、点線枠 = 計画で他の枚に詰め込み、太枠 = 計画でその枚の本体、右上の紫の点 = 図・表あり、左上の橙の点 = 質疑応答あり、薄い = 隠す・枝刈り、名前の頭の `#n` = 計画の枚番号。辺: 順序 (灰の矢印) / 前提 (橙の破線) / 支え (緑の矢印) / 対比・関連 (紫の点線) / 包含 (薄灰)。
- ノードと辺にツールチップ (題目・Id・種類・層・重要度・導入文・要点・状態・図・出典・本文の抜粋 / 辺の種類と両端)。
- opts: `"EdgeKinds"` (群 Order / Prerequisite / Support / Related / Contains か辺の種類の名前。既定: 話の流れ = 順序・前提・支え、節 = 包含以外、周辺 = すべて)、`"Layers"` (All か {"Paper", "Background", "Related"} の部分。節はいつも描く)、`"Labels"` (Automatic = 節・重要度 0.75 以上・枚の本体・選択中 / All / None = 節だけ)、`"Selected"`、`"OnClick"` (クリックで `f[id]`)、`"Hidden"` (False で隠したノードを描かない)、`"Legend"`、`"Language"`。凡例は `SourceVaultKGLegend[lang, 1 行の項目数]`。
- 実データ (計算と自然33、182 ノード・467 辺): 話の流れ 0.65 秒 (画像 2105×651)、節 0.02 秒、周辺 0.06 秒。

### SlideGraphViewer[] / SlideGraphViewer[nb | graphId] (v1.30、パレット「KG図」)
知識グラフを見る窓 (CreateDocument、保存しない)。
- 上段: **表示** (話の流れ / 節 / 周辺 / 計画 = `SourceVaultKGPlanView` の表 / 一覧 = `SourceVaultKGView`)、**更新** (KG を読み直す。推敲や調整のあとに押す)、**辺** (順序 / 前提 / 支え / 対比・関連 / 包含)、**計画を重ねる** (デッキから開いたとき。既定 on)、**層** (本文 / 周辺知識 / 関連研究)、**名前** (主要 / すべて / 節だけ)、**周辺の半径** (1〜3)。
- 要約の行: KG の種類 (論文 / シナリオ)・節・本文・周辺知識・関連研究 (候補数)・辺・図・表のあるノード・質疑応答のあるノード・隠す・未推敲の節。
- 左: 図 (見えている表示だけを描き直す `PaneSelector`。スクロール可)。ノードをクリックすると右に中身。
- 右: 選んだノードの中身 (題目・Id・種類・層・重要度・難しさ・隠す/未推敲・導入文・要点と補足・要約・原稿の冒頭・図・質疑応答・出典・本文の抜粋・つながり (包含 / 順序 / 前提 / 支え / 関連 の ← と →))。ボタン: **周辺を見る** / **スライドへ** (そのノードの枚の題目セルを選んでデッキを前に。詰め込まれていれば計画の詰め込み先の枚、無ければ「デッキにありません」) / **調整に書く** (まだ反映していない調整セルがあれば 1 行足し、無ければ Story セルの後ろに調整セルを作って「題目」(Id): を書く。続きを書いて「調整」)。**検索**欄で一覧 (Id と題目の部分一致、300 件まで) を絞って選べる。凡例。
- KG はファイルの日付と大きさで覚える (`$iSWVizCache`)、計画は (KG・更新回数・デッキの有無) で覚える。描画の失敗は赤い一行にする。

パレット「作る (知識グラフ)」節 (v1.30): ストーリー / 文献、KG構築 / 推敲、周辺知識 / 図解、調整 / KG図、生成 (左から右、上から下。生成は横幅いっぱい。KG表示は `SlideGraphShow["Nodes"]`)。ストーリーが先頭なのは、Story セルが KG構築・推敲・原稿 (Enrich) のプロンプトに入るため (周辺知識と計画・生成には入らない)。推敲タスクは 1 節ずつ (本文ノード合計 8 以下なら隣接節をまとめてよい)、`SlideGraphSectionText` の戻り値は解析せずに読む。
エージェント許可 head: SlideGraphIngest / Spec / Plan / PlanView / Generate / Apply / View / Load / Show / Seed / SectionText。