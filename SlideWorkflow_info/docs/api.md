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
Options: `"MinSize" -> 80` (px未満の小画像(アイコン等)は除外)

### SlideDeckFigure[deck, n] → Image
既存スライドデッキ(.nb)のn枚目を1920x1080のImageとして引用する。deckはパスまたはReferencesのkey。論文紹介・過去スライド紹介で原スライドをそのまま見せるのに使う(`cite:`を付す)。

### SlideSourceFile[locator] → String
文献locator(パス / eagle:ID / sv://URI / URL / arxiv:ID / Google Slides URL / Referencesのkey)を解決してローカルファイルパスを返す(URL系は自動ダウンロード+PDF化+キャッシュ)。展開エージェントが`ClaudeAttach[SlideSourceFile[...]]`で資料を閲覧し、引用ページ・領域を決めるのに使う。

### SlideTable[rows, opts] → 表示可能な式(Grid)
デッキ配色($SlideTheme)の表を返す。rowsは文字列の行リスト。
Options: `"HeaderRows" -> 1` (ヘッダ行として強調する行数)
シナリオmdでは`|`構文(`"| a | b |"`、2行目に`"| --- | --- |"`で1行目がヘッダ)が同じ表になる。

### $SlideVisualsPerSlide
型: Boolean, 初期値: `True`
`True`(既定)なら、展開プロンプトが「原則すべてのスライドに図か表を1つ以上」を要求する。`False`で従来の文章中心生成。

## 発表シナリオ (talk)

スライドの「中身」ではなく「話す原稿」を扱う層。1枚ずつ独立に説明文を作ると発表としての流れが出ないため、原稿はデッキ全体を1度に見て書く。正本はMarkdown(front matter + `# Opening` + `## n タイトル {seconds=秒}` + `# Closing`)。

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

### SlideTalkBuild[deck, opts] → String
発表シナリオを生成して`<deck>_talk.md`へ書き出す。LLMが使えるときは非同期(SlideExpandと同じ経路)で、使えないときは骨格(SlideTalkSkeleton)を同期で書く。
Options: `"Output" -> Automatic`, `"UseLLM" -> Automatic`, `"Notebook" -> Automatic`, `"OpenResult" -> False` に加えSlideTalkPromptのオプション

### SlideTalkFile[deck] → String
発表シナリオの規約パス`<deck>_talk.md`を返す(トークセルの無い旧デッキ用のフォールバック)。

### SlideTalkMeta[nb] → Association
デッキ単位の発表メタ(SlideURL / Aliases / PrivacyLevel など)を返す。

### SlideTalkMeta[nb, "SlideURL" -> url, ...]
ノートブックのTaggingRulesにメタを永続化する(登録簿への登録が`_talk.md`無しで完結する)。

### SlideDeckRegister[deck | talkfile | md, opts] → 登録結果
発表シナリオのfront matter(Title / SlideURL)を使って発表をSourceVaultの登録簿へ登録する。以後VRCRealtimeが発表タイトルからスライドURLと原稿を引ける。
Options: `"SlideURL" -> Automatic`, `"Title" -> Automatic`, `"Id" -> Automatic`, `"DeckFile" -> Automatic`, `"PrivacyLevel" -> Automatic`, `"SlideCount" -> Automatic`

### SlideDeckRegistry[] → Dataset
登録済み発表エントリの一覧を返す。

### SlideInsertTalk[]
トークセル(SlideTalkスタイル、そのスライドの発表原稿)を各スライドの最後に挿入する。Workingで可視、SlideShow環境では非表示、書き出しからも除外。mdでは`"talk: 原文"`行。全スライドにトークがあるとSlideTalkBuild(パレット「シナリオ」)がLLM無しで`deck_talk.md`を束ねる。

### $SlideTalkPerSlide
型: Boolean, 初期値: `True`
`True`(既定)なら、展開プロンプトが各スライド末尾に`talk:`原稿(です・ます調、2〜6文)を要求し、スライド本文は図表+短い体言止めに絞る(スライドとトークで解説が完成する分業)。`False`で従来どおり。

## 音声再生・自動進行

発表シナリオをSourceVaultのローカル音声(Piper)またはクラウドRealtime音声で読み上げながらスライドを自動で進める層。FEを止めないため、パレット側に常駐Dynamicのポーリングを置かず、進行はカーネル側のScheduledTaskが回す。

### $SlideVoice
型: String | Automatic, 初期値: `Automatic`
読み上げに使うボイスモデル名(SourceVaultのローカル音声資産の声名、または`"realtime:<声>"`)。既定`Automatic`は`SourceVaultVoice[]`の既定の声。`SlideVoices[]`で候補一覧。

### $SlideVoiceGap
型: Real, 初期値: `0.8`
スライドを読み終えてから次へ送るまでの間(秒)。

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
`$SlideVoice`を次のボイスモデルへ切り替える(パレットのトグル)。

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
デッキにメタセル用スタイル定義(Note/Directive/Dictionary/Bibliography/References/SlidePrompt/SlideTalk。SlideShow 環境で非表示)を埋め込む。パレットの挿入・展開・表示切替から自動で呼ばれ、documentation.wl の DocInsert* もこの定義を使う。

### SlideTogglePrompts[]
全 SlidePrompt セルの表示/非表示を切り替える。

### $SlideExportExternal
型: `Automatic | True | False`, 初期値: `Automatic`
パレットの画像/mp4 書き出しを別プロセス(wolframscript)で行うかどうか。`Automatic`(既定)は 1 度試し、ライセンス席不足等で子プロセスが起動できなければ以後は FE 内処理へ自動フォールバックする。`True`強制 / `False`無効。

**大きなデッキで FE がフリーズする問題への対策**: パレットの書き出し・一覧・シナリオ md は、以前ノートブック全体を `NotebookGet` でカーネルへ転送していた。99MB のデッキではこの FE→カーネル転送だけで FE が長時間応答不能になる。現在は**保存済みであればファイルパスを渡し、カーネル側の `Get` で読む**(FE を介さない)。未保存の場合のみ従来経路になるため、大きなデッキでは**書き出し前に保存**すること(ステータスバーにも警告が出る)。

### $SlideHideToolbarInSlideshow
型: Boolean, 初期値: `True`
`True`(既定)なら、表示切替(SlideToggleScreenEnvironment)でSlideShowへ入るときに標準ノートブックツールバー(MultipurposeBar)とノートブック側DockedCells(CloudPublishableのPublic/Privateバッジ等)を一時退避し、Workingへ戻すときに復元する。ノートブック側DockedCellsはスタイルシートのスライドナビバー定義を上書きするため、退避しないとナビバーが出ない。