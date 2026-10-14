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
Options: `"TitleSlide" -> True` (先頭にタイトルスライドを付与するか), StyleDefinitions -> Automatic ($SlideStyleDefinitionsに解決), `"EndMarker" -> True` (末尾に終端マーカー(SlideDeckEnd)を付与するか。`False`で抑止), WindowSize -> `{960, 540}` (ノートブックウインドウサイズ)

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

## 読み上げ付きの動画 (録画) と YouTube の限定公開 (v1.59)
発表パレットの「動画」節: **動画作成** (`SlideTalkVideo`) と **YouTube** (`SlideYouTubeUpload`)。

### SlideTalkVideo[] / SlideTalkVideo[nb, opts] → Association
発表の設定で選んだ声 (発表ボイス `$SlideVoice` + 音声モデル `$SlideVoiceModel`) で原稿を読んだ音声と、スライドの画像を合わせて `<デッキ>_narrated.mp4` を作る。原稿はライブの再生と同じ (話す言語の訳、無ければ元の原稿。原稿モードがポスターならポスター原稿の枚だけ) で、読みの辞書も当てる。
- ローカルの声 (Piper / AivisSpeech): 合成した wav をそのまま使う (再生しない。`<デッキ>_voice/` は再生と共通のキャッシュ)。
- `realtime:` の声 + gpt-realtime-*: `SourceVaultRealtimeRender` が **再生せずに** wav へ書く (実時間より速い。1 枚 1 セッションを `$SlideTalkVideoParallel` 本並べる)。キャッシュ名は `rt-<モデル>-<声>`。
- `realtime:` の声 + gpt-live-1: GPT-Live は実時間でしか話さないので、押すと「gpt-live-1 で録る (実時間) / 同じ声の gpt-realtime で速く作る / やめる」を聞く。録るときは原稿を読み上げながら 1 枚ずつ録音し (質問は受けない、ワーカー 1.13 の narrate `"record"`)、読み終えると自動で動画にする。止めても録れた枚は残り、次は続きから録る。
- 枚の長さ = `$SlideTalkVideoLeadIn` (0.5 s) + 声 + `$SlideVoiceGap` (0.8 s)。原稿の無い枚は 3 秒、最後の枚に `$SlideTalkVideoTail` (1.5 s)。
- 画像は `<デッキ>_slides/NN.png` (保存済みなら別プロセスで描く)。描画のハッシュ (`<デッキ>_state.json` の `ImagesSlidesDigest`) が同じなら描き直さない。
- 合成は ffmpeg 1 回 (`iSWFFmpegExe` = 完全なパス、無ければ `winget install Gyan.FFmpeg` か `$SlideFFmpegPath`): 画像は concat demuxer、声はカーネルが枚の長さどおりに 1 本の wav (48 kHz) にまとめる、H.264 (`-tune stillimage`, CRF `$SlideTalkVideoQuality`) + AAC 48 kHz、`$SlideTalkVideoFrameRate` fps。ffmpeg には ASCII のパスだけを渡す (作業フォルダへ写す)。実測: 47 枚・29 分の発表 (ほのか) で 70 秒、57 MB。
- 隣に時刻表 `<デッキ>_narrated.json` (各枚の Start / Duration / Title / Narrated、SlidesDigest) を書く。YouTube のチャプターの元。
Options: `"Output"`, `"Voice"`, `"Model"`, `"Live"` (Automatic = 聞く | `"Record"` | `"Fast"`), `"Parallel"`, `"Interactive"`。
戻り値: `<|"Status" -> "Done", "File", "Duration", "Slides", "Missing" (声の無い枚), "Timeline", ...|>`、録音を始めたときは `<|"Status" -> "Recording", "From", "Slides"|>`。

### SlideTalkVideoStatus[] → Association
`<|"Recording" (gpt-live-1 で録っている最中), "Encoding" (ffmpeg の進み), "Last" (最後の結果)|>`。

### SlidePosterAudio[] / SlidePosterAudio[nb, opts] → <|"Status" -> "Done", "File", "Format", "Duration", "Slides", "Timeline", "Synthesized", "Reused"|> (v1.61)
ポスター原稿 (SlidePosterTalk セル。前置きの Opening は最初の枚の頭) を、発表の設定の声 (発表ボイス + 音声モデル) で読んだ **1 本の音声ファイル**
`<デッキ>_poster_talk.m4a` にする。作成パレット「確認・書き出し」の **ポスター音声** (「登録」の右)。
- 声・読みの辞書・声のキャッシュ (`<デッキ>_voice/`) は `SlideTalkVideo` と同じ。動画を作った後なら合成しない (戻り値の `"Reused"`)。
  ローカルの声は合成、`realtime:` + gpt-realtime-* は `SourceVaultRealtimeRender` (再生しない)、gpt-live-1 は同じ声の gpt-realtime で作る。
- 長さは動画と同じ: 枚ごとに `$SlideTalkVideoLeadIn` + 声 + `$SlideVoiceGap`、最後に `$SlideTalkVideoTail`。ポスター原稿のある枚だけを並べる。
- 形式: `"Format" -> "m4a"` (AAC、既定 `$SlidePosterAudioFormat`) / `"mp3"` / `"wav"`。m4a と mp3 は ffmpeg で 1 回変換 (ASCII の作業フォルダで変換してから写す)、
  ffmpeg が無ければ wav。ビットレート `"Bitrate"` (既定 `$SlidePosterAudioBitrate = "96k"`)。
- 隣に時刻表 `<出力>.json` (枚・題目・ポスターのブロック・開始・長さ・原稿)。同じデッキの wav と m4a は同じ時刻表を共有し、最後に書いたものを表す。
- opts: `"Output"` / `"Format"` / `"Voice"` / `"Model"` / `"Parallel"` / `"Bitrate"`。テスト: slideworkflow_test T56 (声を差し替えて 4 件)。

### SlideYouTubeUpload[] / SlideYouTubeUpload[nb | deck.nb | video.mp4, opts] → Association
読み上げ付きの動画を YouTube Data API v3 で **限定公開 (unlisted)** でアップロードする (再開可能アップロード、8 MiB ずつ、5xx は位置を訊いて続きから)。
- 題 = 指示セルの `Title:` (無ければデッキ名)。説明欄 = 題・集会と日付・著者 + 時刻表から作る **チャプター** (同じ題目の続きはまとめ、10 秒未満の章は次の題目に譲る。3 つ未満なら付けない)。
- 動画が無い / スライドが動画より新しいときは作り直すかを聞く。同じファイルを前に上げていれば知らせる (`"Force" -> True` で上げる)。
- **上げない**: 指示セルの `PrivacyLevel:` が 0.5 以上の発表、非公開 (TaggingRules SourceVault/CloudPublishable = False) と宣言したノート。上げる前に必ず確認のダイアログを出す。
- 上げた記録は `<デッキ>_narrated_youtube.json`、URL はクリップボードへ。
Options: `"File"`, `"Title"`, `"Description"`, `"Tags"`, `"Privacy"` (既定 `$SlideYouTubePrivacy = "unlisted"`), `"Category"` (既定 `$SlideYouTubeCategory = "27"` 教育), `"Language"`, `"MadeForKids"` (False), `"Chapters"` (True), `"Interactive"`, `"Force"`。
戻り値: `<|"Status" -> "Uploaded", "VideoId", "URL", "Privacy", "Title", ...|>`。

### SlideYouTubeClient[] / SlideYouTubeClient[id, secret] / SlideYouTubeClient[File[json]] / SlideYouTubeClient[None]
OAuth クライアント (Google Cloud の「OAuth クライアント ID」、種類は **テレビと入力が限られたデバイス**) を NBAccess 管轄の SystemCredential に保存する。`SlideYouTubeClientQ[]` で登録の有無 (値は返さない)。

### SlideYouTubeAuthorize[opts] / SlideYouTubeSignOut[]
デバイスコードで許可をもらう (ブラウザで表示されたコードを入れる。ローカルにサーバを立てない。スコープ `https://www.googleapis.com/auth/youtube`)。リフレッシュトークンは SystemCredential に保存。初回のアップロードで自動的に呼ばれる。テスト中 (Testing) の OAuth 同意画面ではリフレッシュトークンが 7 日で切れるので、そのときは自動で許可をやり直す。

### $SlideYouTubeHTTPHandler
HTTP の差し込み口 (テスト用)。`<|Method, URL, Headers, Body, TimeConstraint|>` を受けて `<|StatusCode, Headers (小文字), BodyBytes|>` を返す関数。

## ポスター (v1.54): 生成したスライドを KG の部で束ねて A0 に組む
スライド (≤ 32 枚) とポスターは同じ KG の 2 つの投影。ポスターはデッキから作る: 枚の題目セルの CellTags `KGNode:<id>` で
KG の部 (目次の根の子) に束ね、列 (facet) と段に二次元配置し、各枚をポスター幅で再組版して 1 つの `Graphics` に組む。LLM は呼ばない。
仕様: `SlideWorkflow_info/design/slide_poster_spec_v0_1.md`。パレット「確認・書き出し」の「ポスター設定」(セル挿入) と「ポスター」(書き出し)。

### SlideInsertPoster[]
ポスター設定セル (`SlidePoster`、Working で可視・SlideShow と書き出しで非表示) を挿入する。`Key: value` 行:
`Size` (A0|A1|A2|A3|841x1189 mm) / `Orientation` (Portrait|Landscape) / `Columns` (既定 2) / `Blocks` (Automatic = 部の数を 3〜10 に丸める) /
`Panels` (1 ブロックの枚の上限、既定 4) / `Layout` (Flow = 列ごとに上から | Rows = 段ごとに左から | Pairs = KG の辺で対応する部を同じ段に) /
`Axis` (列の見出し、`|` 区切り) / `Column 1:` (その列に置く部の Id・題目・番号) / `Grid: <Id>=段,列` / `PanelMode` (Reflow | Slides) / `Scale` /
`Title` `Subtitle` `Author` `Affiliation` `Event` `Date` `Abstract` `QR` `Footer` `Resolution` (PNG dpi) / `PanelColumns` (ブロック内の列数 1〜3、既定は自動。v1.57)。無い行は指示セルから補う。日本語キーも可。

### SlidePosterSpec[nb | path | Notebook] → Association
設定 (ポスターセル + 指示セル + 既定)。`"SizePt"` は用紙の {幅, 高さ} (pt)。

### SlidePosterPlan[nb | path | Notebook, opts] → Association
計画 (決定的)。`"Blocks" -> {<|"Id", "Title", "Gist", "Facet", "Position" -> {段, 列}, "Panels" -> {<|"Slide", "Node", "Title", "Reason"|>..}, "Folded"|>..}`、
`"Links"` (Pairs の対応)、`"Rows"`、`"Warnings"` (Folded / NoPairs / BlockCount)。枚の選び方: 必ず出す (Pinned) > 図のある枚 > 重要度 > デッキ順
(部自身の道標の枚は後回し)。外した枚は `"Folded"` で題目だけブロックに並ぶ。ブロック数が多ければ隣どうしを併合、少なければ目次の子の境で割る。
opts は設定セルの鍵と同じ (`"Blocks"` / `"Columns"` / `"Layout"` / `"Panels"` / `"Facets"` / `"Grid"` / `"PanelMode"` / `"Size"` / `"Orientation"` / `"Scale"`)、
`"Graph" -> graphId` で KG を明示 (headless)、`"Spec" -> <|...|>` で連想ごと。KG が無いデッキはパンくず「第k部」か等分で束ねる。

### SlidePosterPlanView[nb | path | plan, opts] → Dataset
番号 / 段,列 / 列 / ブロック / 枚 / ほかに。

### SlidePosterRender[nb | path | plan, opts] → Graphics
用紙サイズ (pt) の `Graphics`。題名帯 (題目・著者・集会・概要・QR) / 列の見出し / ブロック (角丸の枠、番号つき題目、一行要約 = Gist > Summary > Role、
枚の再組版画像の 2 列 masonry、「ほかに: …」) / 対応の矢印 / 脚注 (文献 `[key] メモ — locator` と Footer)。
枚は書き出しと同じセル列 (navbar・メタ・閉じたセル・NoExport・パンくずを除く) を `ScreenStyleEnvironment -> "SlideShow"` でパネル幅に再組版して
`Rasterize` (高さは内容なり)。`Scale` (既定 0.7) = SlideShow の文字に対する倍率で、升の高さの 82% も使っていなければ 1.35 倍まで大きく組み直し (`"FillHeight"`)、入らなければ縮める。補足 (ItemParagraph 系)・用語の行・パンくずは出さず、図は幅と高さ (幅の 0.72、最大 330 pt) に縦横比を保って収める (窓より広い図は描画で切れる)。対応の矢印の語 (つながる / 対比 …) と「ほかに」はデッキの言語 (KG の Language) に従う。`"PanelResolution"` (既定 `$SlidePosterPanelResolution` = 144 dpi)、
`"Notebook" -> nb` で状態行に進み具合。列の色は `$SlidePosterFacetColors` (`$SlideTheme` の鍵。既定 Dim → Title → Bullet → Arrow)、
Axis か Pairs のときだけ列で色を変える。

### SlidePosterImage[nb | path | plan | graphics, "Resolution" -> dpi] → Image

### SlidePosterExport[nb | path | plan] / SlidePosterExport[src, "file.pdf" | "file.png", opts] → {paths}
省略時は `<deck>_poster.pdf` (用紙サイズそのまま) と `<deck>_poster.png` (設定の Resolution dpi) の両方。`"Graphics" -> g` で描画済みを使う。

### SlidePosterShow[nb]
計画の一覧と縮小画像をノートブック末尾 (終端マーカーの後) に書く。パレット「ポスター」が書き出しの後に呼ぶ。

### ポスター原稿 (v1.55): SlidePosterTalkFill / SlidePosterTalks / SlidePosterTalkDuration / SlideTalkMode
スライド原稿とは別の、ポスターを見ながら数分で説明する短い原稿。同じ枚に専用スタイル `SlidePosterTalk` のセル (紫の帯、左に「ポスター」の印。TaggingRules `SWTalkKind -> "Poster"` も持つ)
として並び、前置きの Poster セルが Opening。md では `postertalk:` 行 (`talk:` とは別)。原稿の収穫 (`iTalkDeckOutline` の Talks、原稿の補完、
訳、スライドから反映) は Poster セルを数えない。
- `SlidePosterTalkFill[nb, "Minutes" -> m, "Mode" -> "LLM" | "Skeleton"]`: ポスター計画のブロックごとに、最初の枚を「課題 1『…』です」と
  **題目で指して**始め (位置「左の二番目」では指さない。列の意味は Opening で一度だけ)、各枚 1〜3 文、全体を m 分 (既定: ポスター設定セルの
  `TalkMinutes:` > `$SlidePosterTalkMinutes` = 7) に収める。説明の順は対応があれば段ごとに左 → 右。LLM が無ければ骨格。既存のポスター原稿は置き換え。
  パレット「原稿と想定問答」の「ポスター原稿」。
- `SlidePosterTalks[nb | path]` → `<|"Opening", "Slides" -> <|枚 -> 原稿|>, "Count"|>`、`SlidePosterTalkDuration[nb]` → 秒の見積もり。
- `SlideTalkMode[]` / `SlideSetTalkMode["Slides" | "Poster"]` / `SlideCycleTalkMode[]` (発表パレット「発表の設定」の「原稿: スライド | ポスター」):
  Poster では `SlidePlay` がポスター原稿のある枚だけを順に表示しながら (原稿の無い枚は飛ばす) その短い原稿を読む。訳の確認は無し、字幕は
  `$SlideSubtitles === True` のときだけ。
- `SlidePosterTalkMinutes[nb]` / `SlideSetPosterTalkMinutes[nb, m]` / `SlideCyclePosterTalkMinutes[]` (「ポスター原稿の長さ: 7 分」、3 → 5 → 7 → 10 → 15):
  ポスター設定セルがあれば `TalkMinutes:` 行にも書く (設定セルが正)。

### ブロック内の配置の最適化 (v1.57): PanelColumns / $SlidePosterScaleRange / $iSWPosterLastLayouts
v1.54〜1.56 は列数を枚数で固定し (2 枚 → 2 列、3 枚 → 3 列)、升に入らない分を一律に縮めていたので、長い枚のあるブロックは幅も一緒に縮んで
右と下が空いた (課題 4 で文字 0.35 倍)。v1.57 はブロックごとに次の順で組む (`iSWPosterBlockLayout`):
1. 描けた枚数から列数の候補 (1 枚: 幅 62 / 80 / 100%、2 枚: 2 列、3 枚: 3 列 | 2 列 masonry、4 枚以上: 2 | 3 列) と、等幅で描いた面積に
   比例させた列幅の候補 (各列は 22〜60%) を低解像度で実際に組版し、score = 到達倍率 × (0.35 + 0.65 面積率) で選ぶ。
2. 最も高い列の枚に図が 2 つ以上あれば、図を集めて 2 つずつ横に並べる (1 割以上低くなるときだけ。箇条書きを挟んで離れていても集める)。
3. 升の高さに合わせて倍率を Sqrt で寄せる (2 回まで。設定セルの `Scale` × `$SlidePosterScaleRange` = {0.6, 1.6} の範囲)。
4. それでも列の下が空いていれば、その列の枚の図を大きくする (枚の幅まで)。5. 残りのはみ出しだけ一律に縮める。
セルの左右余白のぶん組版の中身は窓より約 17% 狭い (切り抜いた画像が列より細く、列の間が空く) ので、最初の試し描きで余白を測って窓を
広げ、図は列の幅で止める。`PanelColumns: 2` (設定セル) で列数を固定、`"FillHeight" -> False` で倍率を変えない。
結果は `SlideWorkflow`Private`$iSWPosterLastLayouts` (ブロック番号 → Columns / Widths / FigureColumns / Scale / Shrink / Fill / Height /
Scores / Margins)。実測 (CIHCD9、A0 2 列 × 4 段): 面積率 0.64〜0.87 → 0.78〜0.92、課題 4 の文字 0.35 倍 → 0.73 倍、描画 19 s → 62 s。
テスト: slidegraph_test T44 (12 件、`iSWPosterPanelImage` を合成パネルに差し替えて FE 無しで)。

### $SlidePosterFacetColors / $SlidePosterPanelResolution
列の色の名前のリスト / パネルの描画解像度 (dpi、既定 144。印刷なら 200 程度)。

### ポスターの配置 (v1.56): SlidePosterUpload / PosterURL: / PosterHost:
ポスター PDF を web に置き、ポスターの QR をその URL にする。指示セルに
```
PosterURL: https://transreal.sakura.ne.jp/cn/CIHCD9-poster.pdf
PosterHost: sftp://transreal@transreal.sakura.ne.jp/home/transreal/www/cn
```
と書くと (`PosterHost:` が無ければ `Host:` と同じ場所)、「登録」(`SlideDeckRegister`) が `<deck>_poster.pdf` を `PosterURL:` の末尾の名前で sftp 配置する
(戻り値の `"PosterUpload"` キー)。`SlideURL:` + `Host:` があれば mp4 も配置する (両方あれば両方へ。`SlideURL:` が無くても `PosterURL:` だけで登録できる)。
登録簿のエントリと質疑応答 (QA) はスライドとポスターで共有 (1 デッキ = 1 エントリ。エントリに `PosterURL` も入り、前回の特定にも使う)。
- `SlidePosterUpload[nb | deck.nb, opts]` → `<|"Status" -> "Uploaded" | "Unchanged", "File", "Remote", "PosterURL", "Bytes", "Verified", "Seconds"|>`。
  PDF が無ければ `SlidePosterFileMissing` (「ポスター」で作る)、「ポスター」で書き出した後にスライドを変えていれば `SlidePosterStale`
  (古い PDF は上げない。作り直してから登録。判定は書き出し時に `<deck>_state.json` へ記録する描画ハッシュ `PosterSlidesDigest`、無ければファイル日付)。
  配信中と同サイズなら送らない (Unchanged)。資格情報は mp4 と同じ `sftp://user@host`。
  opts: `"UploadURL"` / `"PosterURL"` / `"File"` / `"Method"` / `"Password"` / `"User"` / `"Force"` / `"Verify"` / `"Interactive"`。
- ポスターの QR の既定は `PosterURL:` > `SlideURL:` (ポスター設定セルに `QR:` 行があればそれが優先。古い設定セルに mp4 の `QR:` が残っていれば消すか書き換える)。
- パレットの「登録」は状態行にポスターの結果も出す (配置 / 変更なし / 古いまま / PDF なし)。失敗しても登録簿への登録は完了している。

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
Options: `"MinSize" -> 80` (px未満の小画像(アイコン等)は除外), `"Page" -> All | n` (指定ページのみ)

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
Options: `"Style" -> "DisplayFormula"`, `FontSize -> Automatic`, `FontColor -> Automatic`

### SlideNotebookFigure[src, n, opts] → Image
素材ノートブックのn番目の図(SlideNotebookTextの`"[FIGn]"`に対応)をImageで返す。原図をそのまま引用するための入口で、`SlideApplyScenario`の`"Figures"->{...}`にそのまま渡せる(`cite:`を必ず付す)。図の総数と所在はSlideNotebookOutline / SlideNotebookTextの[FIGn]で分かる。返す画像は長辺`$SlideNotebookFigureMaxSize`(既定1200px、`"MaxSize"`で変更可)に収める — デッキのラスタ化で実際に出るのは高々1120pxなので、それ以上はノートブックを重くするだけになる。
Options: `ImageResolution -> 144`, `"MaxSize" -> Automatic` ($SlideNotebookFigureMaxSize)

### $SlideNotebookFigureMaxSize
型: Integer, 初期値: `1200`
`SlideNotebookFigure`が返す図の長辺上限px。デッキはWindowWidth 960を1920へ2倍でラスタ化し、図セルはImageSize->560なので、最終画像に出るのは高々1120px。それを超える画素はノートブックを重くするだけになる。

### $SlideNotebookRasterizeSeconds
型: Integer, 初期値: `30`
`SlideNotebookFigure`がベクタ図をRasterizeする際の上限秒。Rasterizeはフロントエンドを要求するので、必ず時間で切る。

### SlideTable[rows, opts] → 表示可能な式(Grid)
デッキ配色($SlideTheme)の表を返す。rowsは文字列の行リスト。
Options: `"HeaderRows" -> 1` (ヘッダ行として強調する行数), `FontSize -> 15`
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
Options: `SlideTalkSkeleton`と同じ + `"Instructions" -> ""`, `"Meta" -> ""`

### SlideTalkFill[] / SlideTalkFill[nb] (v1.30)
原稿 (トークセル) の無いスライドにだけ原稿を書く (パレット「発表の準備」の「原稿」)。LLM がデッキ全体の流れ (各枚の題目と既存原稿の冒頭) を見て 8 枚ずつ書き、JSON `{"Talks": [{"Slide", "Talk"}]}` で返したものを各スライドのトークセルへ入れる (質疑応答セルがあればその前、既にあるトークセルは上書き)。規則: です・ます調 2〜6 文、前の枚とのつながり、箇条書きと同じ順、スライドに無い事実を作らない、`$...$` や `**` を書かない。全枚に原稿があれば何もしない。

### 読みの辞書 (v1.51)
gpt-realtime は原稿を読んで自分で声を出す LLM なので、漢字の読みを毎回その場で決める (手錠を「しゅじょう」、音場を「おんじょう」と読む回と正しく読む回がある)。指示で読みを教えても従うかは確率的なので、**声に渡す直前の文で語を仮名に置き換える**。スライド・字幕・原稿 (トークセル) は書き換えない。効く経路: 再生 (SlidePlay、realtime もローカルの声も)、索引の試聴 (SlideSpeakSlide)、SlideVoicePrepare、発表時間の見積もり (合成済みの音声を同じ文で探す)。質疑の自由な答えは原稿を経ないので置き換えられず、発表の文脈 (応答 on・最後の枚の後の質疑で渡す) に読みの一覧を添えるだけ (効くかは確率的)。
辞書は 2 段で、同じ語はデッキ側が優先: (1) 全デッキ共通のファイル `SlideReadingFile[]` (既定は SourceVault の `slidedecks/readings.txt`、PC 間で共有。初回によく誤読される語を入れて作る)、(2) デッキの **読みセル** (スタイル `SlideReading`、パレット「原稿と想定問答」の「読み」。Working で見え、SlideShow と書き出しでは隠れる)。書式は 1 行 1 語 `語 = よみ` (区切りは `=` `＝` `→` `->` タブ)、`#` から行末はコメント。置き換えは日本語の文だけ・長い語から。1 文字の語 (節など) は前後が漢字でないときだけ、英字だけの語は単語の境目でだけ置き換える。文脈で読みが変わる語は句ごと書く (`定常波の節 = ていじょうはのふし`)。読みを直すとローカルの声の合成キャッシュも作り直される (ハッシュは置き換え後の文で取る)。

### $SlidePlayAnswering (v1.52, v1.53)
型: Automatic | True | False, 初期値: `Automatic`
realtime: の声で再生するときに質問 (音声応答) を受けるか。**Automatic (既定)** = 再生を押したときの状態に従う: 「応答on」かつマイクon なら質問を受け (各枚のあとの質問タイム)、それ以外は読み上げだけ。**再生は「応答on/off」の表示を変えない**: 応答off から再生すると音声会話は読み上げのためだけに起き、表示は「応答off」のまま、再生が終わると閉じる。**再生中はマイクボタン (と手元リモコン) で質問を受けるかを切り替える**: マイクon = 質問タイムと最後の質疑応答あり、マイクoff = 読み上げだけ (読み上げ中にマイクon にすると、読み終えたところで質問タイムが開く)。`True` = いつも質問を受ける (v1.51 までの動き)。`False` = いつも読み上げだけ。

### SlideReadings[] / SlideReadings[nb] → Association (v1.51)
読み上げに使う辞書 `<|語 -> よみ|>` (共通 + デッキの読みセル)。`SlideReadings["Global"]` は共通の読みだけ。

### SlideReadingApply[text] / SlideReadingApply[nb, text] / SlideReadingApply[text, readings] → String (v1.51)
声に渡す文 (数式・強調の印・引用番号を外し、辞書の語を仮名に置き換えたもの)。読みの確認用。

### SlideReadingFile[] → String / $SlideReadingFile (v1.51)
全デッキ共通の辞書ファイル (UTF-8 テキスト) のパス。無ければ作る。`$SlideReadingFile` (既定 Automatic。SourceVault が無ければ `$UserBaseDirectory/ApplicationData/SlideWorkflow/readings.txt`) で場所を変えられる。

### SlideReadingAdd["語" -> "よみ"] / SlideReadingAdd[{rules..}] → Association (v1.51)
共通の辞書に語を足す (同じ語は読みを置き換える)。デッキだけの読みは読みセルに書く。

### SlideInsertReading[] (v1.51)
読みセルを入れる (パレット「読み」)。

### SlideReadingCheck[] / SlideReadingCheck[nb] (v1.51)
原稿 (日本語のトークセル) を 20 枚ずつ LLM に見せ、声に出すと読み間違えやすい語 (専門用語・同じ字で読みが変わる語・固有名詞・読み方の決まった英字略語) と読みの案を JSON `{"Readings": [{"Word", "Reading", "Slide", "Why"}]}` で受け、デッキの読みセルに書き足す (無ければ指示セルの後に作る。パレット「読みチェック」、非同期)。原稿に無い語・漢字の残る読み・辞書にある語は捨てる。案は確かめてから使う (要らない行は消すか先頭に `#`)。

### 話す言語と原稿の多言語化 (v1.34)
読み上げ (SlidePlay / 索引の試聴 / SlideVoicePrepare) は **話す言語** で行う。話す言語 = 指示セルの `Language:` 行 (`en` / `English` / `英語` など) > `SlideTalkMeta[nb, "Language" -> ..]` > `$SlideTalkLanguage` (既定 Automatic = `$Language`)。質疑は従来どおり質問者の言語で答える (音声会話のセッション指示で指定)。
原稿は元の言語のトークセルを正本として残し、訳は **同じスライドに並ぶ別のトークセル** (TaggingRules `{"SWTalkLang" -> "en", "SWTalkSrc" -> 元原稿のハッシュ16桁}`、左の帯が青緑) として持つので、複数言語を併用できる。再生は話す言語の訳 → 無ければ元の原稿。元の原稿を直すと「古い訳」になる。訳セルは md (`talk:`) にも `SlideTranslate` (セル単位の英訳) にも出ず、元の原稿を書く `SlideTalkFill` も触らない。スライドを作り直す (展開・生成・ReplaceSlide) と訳セルは消えるので訳し直す。

#### SlideTalkLanguage[nb] → "ja" | "en" | ...
そのデッキの話す言語コード。指示セルの `Language:` > SlideTalkMeta の Language > `$SlideTalkLanguage` > `$Language` の順。

#### SlideTalkLanguages[nb] → <|"Language", "Base", "Slides", "Translated", "Missing", "Stale"|>
Base = 元の原稿の言語 (文字種から推定)、Translated = 言語ごとの訳の枚数、Missing / Stale = 話す言語の訳が無い / 古い枚 (0 = 前置き)。パレット「情報」の「話す言語」行と同じ内容。

#### SlideTalkTranslate[nb] / SlideTalkTranslate[nb, lang | {lang..}, opts]
元の原稿を LLM で訳して訳セルを書く (パレット「発表の準備」の「原稿訳」)。非同期・8 枚ずつ。lang 省略で話す言語。Options: `"Mode" -> "Changed"` (既定: 訳の無い枚と原稿を直した枚だけ) | `"All"`、`"Then" -> f` (完了後に `f[]`)。話す言語が原稿と同じなら何もしない (`"SameLanguage"`)。

#### $SlideTalkLanguage
型: Automatic | String, 初期値: `Automatic`
話す言語の既定 (`"en"` / `"English"` / `"英語"` など。Automatic = `$Language`)。デッキの指示セルの `Language:` 行が優先。

`SlidePlay[nb, "Translate" -> Automatic | True | False]`: 話す言語の訳が欠けている/古いとき、Automatic は「訳してから再生 / このまま再生 / やめる」を聞く。ローカルの声 (Piper / AivisSpeech は日本語) が話す言語を読めないときも知らせる (英語などは realtime: の声を選ぶ)。

### SlideTalkBuild[deck, opts] → String
(v1.30: パレットから外した。原稿を md に書き出したいときに呼ぶ) 発表シナリオを生成して`<deck>_talk.md`へ書き出す。LLMが使えるときは非同期(SlideExpandと同じ経路)で、使えないときは骨格(SlideTalkSkeleton)を同期で書く。
Options: `"Output" -> Automatic`, `"UseLLM" -> Automatic`, `"Notebook" -> Automatic`, `"OpenResult" -> False` に加えSlideTalkPromptのオプション

### SlideTalkFile[deck] → String
発表シナリオの規約パス`<deck>_talk.md`を返す(トークセルの無い旧デッキ用のフォールバック)。

### SlideTalkMeta[nb] → Association
デッキ単位の発表メタ(Title / SlideURL / UploadURL / Aliases / PrivacyLevel など)を返す。ソースの優先順は **デッキ先頭の指示(Directive)セルの `Key: value` 行** > TaggingRules `"SWTalkMeta"` > `_talk.md` front matter。指示セルには次のように書く(`Host:` / `Upload:` / `UploadURL:` は同義で `UploadURL` に正規化。`PosterURL:` / `PosterHost:` はポスター PDF を置く URL とその配置先 (v1.56。`PosterHost` は `PosterUploadURL` に正規化、無ければ `Host:` と同じ場所)。`Aliases:`(カンマ区切り) / `PrivacyLevel:` / `SecondsPerSlide:` / `Event:` / `Author:` / `Date:` も可。これらの行は LLM への指示ブロックからは除かれる):
```
Title: 計算と自然 32
SlideURL: https://transreal.sakura.ne.jp/cn/32.mp4
Host: sftp://transreal@transreal.sakura.ne.jp/home/transreal/www/cn
PosterURL: https://transreal.sakura.ne.jp/cn/32_poster.pdf
Language: en
```
`Language:` は読み上げの言語 (v1.34。空・無しなら `$SlideTalkLanguage` / `$Language`)。

### SlideTalkMeta[nb, "SlideURL" -> url, ...]
ノートブックのTaggingRulesにメタを永続化する(指示セルに同じキーがあればそちらが優先)。

### SlideDeckRegister[nb | deck.nb | talkfile | md, opts] → 登録結果
発表(トークセル + 指示セルのメタ)をSourceVaultの登録簿へ登録し、メタに `UploadURL`(指示セルの `Host:` 行)があれば続けて Sliden 用 mp4 を web サーバへアップロードする(結果は戻り値の `"Upload"` キー。登録簿への登録は mp4 の成否に関係なく完了する)。`PosterURL:` があれば `<deck>_poster.pdf` も同様に配置する (戻り値の `"PosterUpload"` キー、v1.56。両方あれば両方へ、`SlideURL:` が無くても `PosterURL:` だけで登録できる。登録簿・QA はスライドと共有)。以後VRCRealtimeが発表タイトルからスライドURLと原稿を引ける。パレットの「登録」はこの関数。
同じデッキで再度実行すると、前回のエントリを土台に今回与えた値だけを上書きする(前回の特定は `Id` > `DeckFile` > `SlideURL` > `PosterURL` の優先順。指示セルの `Id:` 行で固定できる)。何が変わったかは戻り値の`RegistryStatus`(Created|Updated)と`ChangedKeys`で分かる。
Options: `"SlideURL" -> Automatic`, `"Title" -> Automatic`, `"Id" -> Automatic`, `"DeckFile" -> Automatic`, `"PrivacyLevel" -> Automatic`, `"SlideCount" -> Automatic`, `"Upload" -> Automatic`(Automatic = UploadURL があれば送る / True = 必須 / False = 送らない), `"QA" -> Automatic` (Automaticなら質疑応答セルがあれば`SlideQABuild`を自動実行、`False`で抑止)

### SlideDeckRegistry[] → Dataset
登録済み発表エントリの一覧を返す。

### SlideDeckUpload[nb | deck.nb | deck.mp4, opts] → Association | Failure
Sliden 用 mp4(パレットの mp4 書き出しと同じ `<deck>.mp4`)を `UploadURL`(`sftp://user@host/dir`)へ sftp で送る。リモートのファイル名は `SlideURL` の末尾(例 `32.mp4`)。転送前に `SlideURL` の HEAD で「200 かつ Content-Length がローカルと同じ」なら送らず `"Status" -> "Unchanged"`(`"Force" -> True` で強制)。転送後も同じ HEAD で配信を確認し `"Verified"` に入れる。mp4 が無い、またはデッキが mp4 より新しければ既定で書き出し直してから送る(`"ExportVideo" -> False` で抑止、`True` で常に作り直す)。パスワードは NBAccess 管轄の SystemCredential(名前 `sftp://user@host`)から読み、無ければ FE ではダイアログで尋ねて保存する(`"Interactive" -> False` で抑止)。
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
Options: `"Mode" -> Automatic`, `"QuestionsPerSlide" -> Automatic` (既定 `$SlideQAPerSlide` = 3), `"Vision" -> Automatic` (既定 `$SlideQAVision`), `"Slides" -> All | {n..}`
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
図・写真を含むスライドの QA 生成で描画画像を添付するか。画像は `<deck>_qa_images/` にスライドのハッシュでキャッシュされる。

### SlideQAFromPack[nb, opts] → Association
すでに登録済みの QA パック(以前 `SourceVaultTalkQABuild` で LLM から作ったものを含む)を、スライドの質疑応答セルへ書き戻す。セルが正本になったあとも古い作り置きを捨てずに人が直せる形へ移せる。LLM は使わない。
Options: `"Rebuild" -> False` (既に質疑応答セルのあるスライドは触らない)
パレットの「QA 生成」は、質疑応答セルが 1 つも無く既存パックがある場合はこちらを先に使う(LLM を回す前に、いまあるものを捨てない)。

### SlideQABuild[nb | deck.nb, opts] → Association
質疑応答セルを SourceVault の QA パックへ焼く(`SourceVaultTalkQAImport` へ委譲)。**人が書いた答えを LLM が言い換えない**。「登録」から自動で呼ばれる。
Options: `"PrivacyLevel" -> Automatic` (デッキのメタから), `"Ingest" -> True` (KB へも取り込んで、作り置きに無い質問の受け皿を作る), `"Enrich" -> True` (回答が空の問だけ KB から補う), `"Verbose" -> False`
**パックの同一性**: 同じデッキに対して 2 つのパックが残ると、`SourceVaultTalkQASelectForDeck` が古いほう(別の発表の作り置き)を掴んで答えてしまう。そのため `SourceVaultTalkQAImport` は、そのデッキのパックが既にあれば**その `PackId` / `KBId` / `SourceId` を引き継ぐ**(`cn31` のような手で付けた id を保つ)。それでも複数残っている場合は、最後に書かれたものを使う(パックに `SavedAt` を焼いてある)。

### $SlideQAPerSlide
型: Integer, 初期値: `3`
`SlideQAGenerate` が 1 枚あたりに作る想定質問の数。

## 発表の記録 (カメラ・進行・質問) と質問からの想定問答の候補 (v1.37)
再生 (SlidePlay)・音声応答 on・カメラ on のどれかで **発表セッション** (`slidetalk-<UTC>-<id>`) が始まり、SourceVault の MultimodalEvent として残る。後から発表を振り返るための、進行のタイムスタンプと対応したデータの組。全部止まって `$SlideRecordIdleSeconds` (既定 120 秒) で閉じる。どの事象にも SessionID / Deck / At (UTC) / Elapsed (開始からの秒) / Slide が付く。

| Kind | 中身 | PL 既定 |
|---|---|---|
| SessionMarker | Event = Start / End / CameraOn / CameraOff (Start に Title・DeckFile・Language・Voice・Model、End に Counts・Seconds) | 0.6 (`$SlideRecordPrivacyLevel`) |
| SlideChange | 表示したスライドと題目。Source = Play (読み上げ) / Display (画面の番号) | 0.6 |
| CameraFrame | カメラ画像 (JPEG) の BlobRef・CapturedAt・Device。**保存するだけで LLM には渡さない** | 0.6 (`$SlideCameraPrivacyLevel`) |
| UserQuestion / ResponseDraft | 発表中に受けた質問 (音声応答の ask 経路) と答え (Route: deck / pack / kb …、Status) | 0.7 (`$SlideQuestionPrivacyLevel`) |
| FAQCandidate | 想定問答の候補。Type = Add (新しい問い) / Revise (既存の問いに似ている・想定問答に当たった)、TargetSlide、MatchedQuestion。採否は同じ Kind に Decision = Accepted / Rejected を追記 | 0.7 |

カメラは ffmpeg (dshow) を 1 本起動して `$SlideCameraInterval` 秒 (既定 30) ごとに時刻入りの JPEG を書かせ、2 秒ごとに取り込む (撮るたびにカーネルを止めない)。ffmpeg は `$SlideFFmpegPath` → PresentationListener の設定 → PATH → WinGet の順に探す。

### SlideCameraToggle[] / SlideCameraStart[nb] / SlideCameraStop[] / SlideCameraStatus[]
パレット「発表」の **カメラon/off**。`SlideCameraStatus[]` → `<|Camera, Device, IntervalSeconds, Frames, PrivacyLevel, Session|>`。

### SlideCameraDevices[] / SlideCameraSelect[]
カメラ一覧 (dshow 映像デバイス名) / カメラと間隔を選ぶダイアログ (パレット「カメラ設定」)。`$SlideCameraDevice` (Automatic = 仮想カメラでない最初のカメラ、None = 使わない)、`$SlideCameraInterval`、`$SlideCameraWidth` (既定 1280)。

### SlideTalkSessions[] → Dataset
記録した発表セッションの一覧 (Session, Deck, Title, Start, Seconds, Slides, Frames, Questions, Candidates)。

### SlideTalkSessionData[sessionId] → Dataset
その発表の時系列 (At 順: Elapsed, At, Kind, Slide, Text, BlobRef, PrivacyLevel)。画像は `SlideTalkSessionFrame[blobRef]` → Image。

### SlideQACandidates[nb, "Status" -> "Pending" | "Accepted" | "Rejected" | All] → Dataset
このデッキの想定問答の候補。同じセッションの同じ問い (ウェブ許可の前後など) は 1 件にまとめる。

### SlideQACandidateView[nb] / SlideQACandidateAccept[nb, id] / SlideQACandidateReject[id]
パレット「発表の準備」の **質問候補**。採用すると、そのスライドの質疑応答セルの末尾に足す (Add は `Q:`/`A:`、Revise は既存の問答を書き換えずに `#` のコメントで並べる)。

## 構造・版・発表 (v1.38)
- **知識グラフ = 構造 (正本)**: SourceVault の `knowledgegraph/graphs/<id>.json`。改訂は内容 (ノードと辺) のハッシュ GraphRev で指す。想定問答の正本もノード (QA)。
- **版 (rendition) = 生成したデッキ**: .nb は作業場所 ($onWork など)、版の情報は SourceVault の `slidetalk/renditions/<Id>.json` (Id / Parent / DeckName / Graph / Spec / PrivacyLevel = 知識グラフの PL / Revisions)。デッキの TaggingRules `"SWRendition"` が Id を持つ。.nb の絶対パスは記録しない。
  - **言語は版を分けない**: 訳は同じ .nb の訳セル (documentation.wl と同じ考え方)。
  - 生成条件 (Graph / Audience / Slides / Minutes / Strategy) を変えて生成、または別名で保存したコピー → **親 (Parent) を持つ新しい版**。
  - パレットの「生成」は、条件が前回と違えば「新しい版 (`<名前>_v2.nb` に写してそちらに生成) / このノートブックで / やめる」を聞く。
  - Revisions には生成と発表のたびに DeckRev (描画ハッシュ。未保存なら "unsaved")・GraphRev・枚ごとの KG ノードが追記される。
- **発表 = 1 回ごとの別のイベント**: 発表セッション (上の「発表の記録」) の Start に Rendition・DeckRev・GraphRev・話した言語 (Language)・声・モデル。どの事象にも Rendition・Graph・Node (その枚の KG ノード) が付く。同じ .nb を別の言語で発表すれば別のセッション。
- **質問 → 想定問答**: 候補は TargetNode (KG ノード) を持つ。同じ知識グラフから作った版の候補はどの版からも見え、採用すると**この版でそのノードを扱う枚**の質疑応答セルに書き、知識グラフのノードにも保存する (生成し直すとどの版にも戻る)。KG から作っていないデッキは同じ版 (無ければ同じデッキ名) の候補だけ、枚番号で戻す。

### SlideRendition[nb | renditionId] → Association
版のマニフェスト。

### SlideRenditions[] / SlideRenditions[graphId] → Dataset
版の一覧 (Id, Parent, DeckName, Title, Graph, Audience, Slides, Revisions, Created, PrivacyLevel)。
`SlideTalkSessions[]` の行には Rendition と Language が付く。`SlideQACandidates[nb]` の行には Node / Rendition / Graph が付き、`SlideQACandidateAccept` は `"KnowledgeGraph" -> "Saved" | "Unchanged" | "NoGraph"` を返す。

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

### $SlideVoiceProvider
型: String | Automatic, 初期値: `Automatic`
音声会話(応答on、および`realtime:`の声での読み上げ)のプロバイダ。`Automatic`は登録簿の先頭(`"OpenAI"`)。候補は`SlideVoiceModels[]`のキー。

### $SlideVoiceModel
型: String | Automatic, 初期値: `Automatic`
音声会話(読み上げと質疑)のモデル。既定`Automatic`は`$SlideVoiceDefaultModel`(v1.36から`"gpt-live-1"`。そのプロバイダの一覧に無ければ`$SourceVaultRealtimeModel`)。`"gpt-realtime-2.1"`などを直接指定もできる。`"gpt-live-1"`はGPT-Live(全二重: 聞きながら話す)。GPT-Liveはクライアント委譲で動き、スライド操作(次/前/最初/最後/N枚目/「〜のスライド」)と発表内容の質問はワーカーが書き起こしから読み取って、Realtimeと同じハンドラ(スライド操作 / SourceVault / 許可を得てウェブ)で答える。原稿の読み上げ・質問受付・マイク制御はどちらのモデルでも同じ操作。動いている音声応答のモデルは途中で変えられないので、応答off→on(または次の再生)から効く。

### $SlideVoiceDefaultModel
型: String, 初期値: `"gpt-live-1"`
`$SlideVoiceModel`が`Automatic`のときに使うモデル。SourceVault全体の既定(`$SourceVaultRealtimeModel`)は変えない。

### SlideVoiceModels[] → Association
プロバイダ → 選べるモデル名の一覧(`SourceVaultRealtimeModels["ByProvider"]`。SourceVault_realtime未ロードなら組み込みの`<|"OpenAI" -> {"gpt-realtime-2.1", "gpt-realtime-2.1-mini", "gpt-live-1"}|>`)。

### $SlideQuestionMode / $SlideInterruptWords
型: String, 初期値: `"QuestionTime"` / `Automatic`
発表中の質問の受け方。`"QuestionTime"`(既定、全モデル)=1枚読むごとに質問時間を取り、読み上げ中はマイクを切る。`"Words"`(特定ワード、gpt-live-1のみ)=読み上げ中もワーカーがマイクをローカルで聞き、エコーより大きい聞き手の声で`$SlideInterruptWords`(既定 `$SourceVaultRealtimeInterruptWords` = 質問 / スライド)が聞こえたときだけ発表を止めて質疑(質疑中は何でも受け付ける)。`"Detect"`(二段構え、gpt-live-1のみ)=聞き手の声を検知したら止め、質問かどうかはgpt-liveが判断(独り言なら黙って再開)。質疑が静かになったら中断した文から「それでは、説明に戻ります」で再開し、質疑中にスライドが動いていれば元のスライドへ戻す。特定ワードには`SourceVaultRealtimeInstall["Vosk" -> True]`と`SourceVaultSpeechModel[]`が要る(無い間は二段構えで動く)。Words/Detectはgpt-live-1以外では質問タイムで動く。

### SlideCycleQuestionMode[] / SlideSetQuestionMode[mode]
パレットの設定欄「質問: <モード>」と同じ(質問タイム → 特定ワード → 二段構え)。`SlideSetQuestionMode["QuestionTime"|"Words"|"Detect"]`で直接指定。今のモデルで効かないモードには「*」が付く。

### SlideCycleVoiceProvider[] / SlideCycleVoiceModel[] / SlideSetVoiceModel[model]
パレットの設定欄「音声プロバイダ: <名前>」「音声モデル: <短縮名>」と同じ(押すたびに次へ)。`SlideCycleVoiceProvider[]`はモデルがそのプロバイダに無ければ既定に戻す。`SlideSetVoiceModel["gpt-live-1"]`で直接指定(登録簿にあればプロバイダも合わせる)、`SlideSetVoiceModel[Automatic]`で既定に戻す。動いている音声応答が別モデルなら、ステータスバーに「応答off→onで切り替わる」と出す。

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
音声応答のマイクをmute / unmuteで切り替える(パレットの「マイクon/off」ボタン、手元リモコンの「前の曲」ボタンと同じ動作)。音声応答が動いていないときは何もしない。realtime: の声で再生中は質問を受けるかの切り替えになる(v1.53)。`"Quiet" -> False`(既定)。`"Quiet" -> True`で知らせのダイアログも出さない(手元リモコンからはこちらで呼ぶ)。

### SlideCurrentNumber[] → Integer
今画面に出ているスライド番号を返す。

### SlideIndex[] / SlideIndex[nb, opts] → Dataset
発表の索引をDatasetで返す(番号・見出し・字数・推定秒数・累計)。各行のShowボタンでそのスライドを表示、Playボタンでそのスライドの音声を試聴できる。
Options: `"Voice" -> Automatic`, `"Questions" -> False` (Trueで質問受付の待ちも累計に入れる)

### SlideSpeakSlide[n]
n枚目の原稿を今の声で読み上げる(索引のPlayボタンと同じ)。ローカルの声なら合成してその場で再生し、realtime:の声なら動いている音声会話に読ませる。

### SlideInfo[]
デッキと発表の情報(枚数・原稿・見積時間・声・音声会話の状態)をまとめたウインドウを開く(パレットの「情報」と同じ)。

### SlideTalkDuration[] / SlideTalkDuration[nb | "deck.nb" | "deck_talk.md", opts] → 秒数
発表シナリオ`<deck>_talk.md`から発表にかかる時間を見積もる(質問は無いものとする)。
Options: `"Voice" -> Automatic` (選択中の声), `"Questions" -> False` (Trueで質問受付の待ち時間も足す), `"View" -> False` (Trueで Dataset表示)
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
Options: `"Seconds" -> 10.`, `"IncludeMouse" -> False` (マウスボタンも候補に含める), `"View" -> False`

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
- **設定**: 展開時のトーク生成 on/off、「発表ボイス: <名前>」(押すと次のボイスへ)、v1.32 から「音声プロバイダ: <名前>」「音声モデル: <短縮名>」(音声会話のモデル。gpt-realtime-2.1 / rt-2.1-mini / live-1 を押すたびに順に。ツールチップに完全名)、v1.33 から「質問: 質問タイム / 特定ワード / 二段構え」(発表中の質問の受け方)。**LLM の P:/M: は Claude Code パレットで設定する**。
主なボタンにはツールチップ (`iSWTip`、静的) で何をするかを書いた。v1.29 までの発表欄「シナリオ」(`SlideTalkBuild` = トークセルを `<deck>_talk.md` に束ねる書き出し) はパレットから外した (トークセルが原稿の正本で、発表にも登録にも md は要らない。スライドのシナリオ = プロンプトと紛らわしかった)。`"Safe"->True` は互換のため残る (v1.21 で ClaudeCode を呼ぶ要素は無くなった)。FE セッションではパッケージロード時に自動表示され、FE の「パレット」メニューにも "SlideWorkflow" として登録される(headless ロードでは両方スキップ)。

### ShowSlideTalkPalette[]
発表パレット(Slideshow・再生・音声応答・カメラ・声や言語や質問の受け方の設定)を開く。作成パレット(`ShowSlidePalette`)の上のボタンからも開ける。

### SlideAddSlide[]
現在スライドの直後に新規スライド骨格(navbar+タイトル+SlidePrompt セル)を挿入。プロンプトに「◯枚構成で」等と書けば「展開」で複数スライドに一括展開できる(SlideApplyScenario は複数 ## を複数枚に分割する)。

### SlideExpand[] / SlideExpand[nb]
現在スライドの SlidePrompt セル(無ければ選択セルの本文=自動で SlidePrompt セルに変換)を指示としてスライドを展開・更新する。**既定(`$SlideExpandMode="Agent"`)は ClaudeEval(ClaudeRuntime アダプタ)へ委譲**: 終端マーカー以降(Appendix)に `ClaudeEval["…タスク…"]` セルを書いて評価し、エージェントが文献検索(SourceVault/pdfSearch/web)・WL Graphics での図生成・出典付与を行った後、**`SlideApplyScenario` を一度だけ呼んで適用**する(安全な書込み口を一点に限定)。指示(Directive)・辞書(Dictionary)セルを厳守し、既存の図・コードセルは `<<FIGn>>` トークンで保持される。`$SlideExpandMode="Direct"` で旧来の軽量直接 LLM(NBAccess`$NBLLMQueryFunc`、ツール無し)。

### $SlideExpandMode
型: String, 初期値: `"Agent"`
`SlideExpand`の実行経路。`"Agent"`(既定: ClaudeEval/ClaudeRuntime 経由、文献検索・図生成・承認ゲート付きの複雑処理が可能) | `"Direct"`(軽量: `NBAccess\`$NBLLMQueryFunc`直接呼び出し、ツール無し)。

### SlideApplyScenario[slideNo, md] / SlideApplyScenario[nb, slideNo, md] → Success | Failure
シナリオ Markdown で対象スライドを差し替える**決定的適用関数(展開エージェントの唯一の書込み手段)**。
- md に複数 `##` があれば複数スライドに展開される。
- `<<FIGn>>`: n=1..k は既存の図・コードセル(現スライド内の出現順)、n=k+1.. は `"Figures"` オプションで渡した新規図。
- Options: `"Figures" -> {}` (Graphics/Graphics3D/Image/Cell のリスト。Graphics は ImageSize 560pt で貼付)
- SlidePrompt セルは自動で先頭スライドのタイトル直後に戻される。
- 失敗時は `Failure["SlideOutOfRange"|"BadScenario"|"BadFigures", ...]` を返す(エージェントは md を修正して再評価する)。新規図に Failure / $Failed や評価されずに残った画像処理の式があれば、何も書かずに `Failure["BadFigures"]`。
例: `SlideApplyScenario[3, md, "Figures" -> {g1}]`

### SlideDeckInsertScenario[nb, afterN, md, opts] → Success | Failure
シナリオ Markdown のスライド群を、開いているデッキの afterN 枚目の直後へ挿入する(afterN=0 で先頭)。既存スライドには触れない(差し替えは SlideApplyScenario)。
Options: `"Figures" -> {}` (mdの`<<FIG1>>`..に対応するGraphics/Graphics3D/Image/Cellのリスト)

### SlideTranslate[] / SlideTranslateRevert[] / SlideTranslateDeck[]
現在スライド(/全スライド連鎖)のテキストセルを `$SlideTranslationLanguage` へ一括翻訳。Dictionary 厳守・出典セルは対象外。原文は消さずに TaggingRules (documentation.wl と同じ `"documentation"` キー) に残り、`SlideTranslateRevert` / `SlideShowLanguage[nb, "Original"|"Translation"|"Toggle"]` で LLM なしに切り替える (v1.36)。
**v1.40: 図も訳す** — 同じ枚の図のセル (Output / Print / Graphics = Mathematica で描いた図や表。v1.40.1: Canvas で書いた図は Input セルに入っているので、Input / Code セルも描画 (GraphicsBox) を持てば図として扱い、描画の中の文字列だけを訳す (コードの文字列には触らない)) の中の日本語の文字列 (ラベル・表の文字) を 1 枚ぶんまとめて訳し、箱の構造はそのまま文字列だけ差し替える。原文の図は `"SWOrigContent"`、訳の図は `"SWTransContent"` に持ち、上の切り替えがそのまま図にも効く。オプションの値 (フォント名など) と画像 (ラスタ) の中の文字は訳さない。入力セルを評価し直して図が描き直されたら「古い訳」になり、次の英訳で訳し直す。

### SlideShowLanguage[] / SlideShowLanguage[nb, "Toggle" | "Original" | "Translation"]
デッキ全体のスライドの表示を原文と訳で切り替える(LLM は呼ばない。訳の無いセルは原文のまま)。画像・mp4 の書き出しは表示中の言語になる。

### $SlideTranslationLanguage
型: String, 初期値: 日本語環境なら`"English"`
`SlideTranslate`/`SlideTranslateDeck`の翻訳先言語。

### SlideInsertPrompt[] / SlideInsertCitation[] / SlideInsertEndMarker[] / SlideInsertNote[] / SlideInsertDirective[] / SlideInsertDictionary[] / SlideInsertBibliography[] / SlideInsertAdjust[] / SlideTogglePrompts[]
各種セルの挿入(Documentation` ロード済みなら DocInsert* に委譲)とプロンプトセルの表示切替。`SlideInsertAdjust[]`は調整セル(`"SlideAdjust"`スタイル、青枠)を挿入する。Working で見え、SlideShow と書き出しでは隠れる(パレットの「調整」から`SlideGraphAdjust`経由でも自動的に呼ばれる)。

### SlideToggleScreenEnvironment[]
対象ノートブックのスクリーン環境をWorking⇄SlideShowで切り替える(書式メニューの「スクリーンスタイル環境」と同じ)。メモ・指示・辞書・文献・プロンプトの各セルはWorkingで可視、SlideShowで非表示になる。

### SlideEnsureDeckStyles[nb]
デッキにメタセル用スタイル定義(Note/Directive/Dictionary/Bibliography/References/SlidePrompt/SlideTalk/SlideQA。SlideShow 環境で非表示)を埋め込む。パレットの挿入・展開・表示切替から自動で呼ばれ、documentation.wl の DocInsert* もこの定義を使う。

### SlideTogglePrompts[]
全 SlidePrompt セルの表示/非表示を切り替える。

### $SlideExportExternal
型: `Automatic | True | False`, 初期値: `Automatic`
パレットの画像/mp4 書き出しを別プロセス(wolframscript)で行うかどうか。`Automatic`(既定)は 1 度試し、ライセンス席不足等で子プロセスが起動できなければ以後は FE 内処理へ自動フォールバックする (状態欄に席の案内を出す)。`True`強制 / `False`無効。v1.62: 「登録」の mp4 の作り直しは FE 内のフォールバックが無いので毎回試し直し、子が起動できなければ `SlideVideoStale` に「起動できなかった・席が埋まっている可能性 ("not activated" も出る)・使っていない WolframKernel.exe / wolframscript.exe を終了してもう一度登録」と Wolfram のプロセスの一覧を出す。mp4 が無いときは「まだありません」。
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
筋書きから第一次 KG を**決定的に**作って保存する。root (Label = 指示セルの Title、無ければ最初の部の題目。Text = 部の題目の並び) の下に、部ごとに節ノード `sc<i>` (Kind Section、Text = 部の筋書き) と筋書きノード `sc<i>_d` (本文 = 筋書き、要点なし = 「未推敲」) を置き、`sc<i-1> → sc<i>` を Precedes で結ぶ。KG の `"Kind"` は `"Scenario"`。作り直しても周辺知識 (Background 層) とその辺は残す (`"Keep" -> "Background"`)。
Options: `"Graph" -> Automatic`, `"Title" -> Automatic`, `"Language" -> Automatic`, `"Save" -> True`, `"Keep" -> "Background"`
筋書きが無ければ Failure (NoScenario)。

### SlideGraphRelated[nb | graphId, opts] (v1.30、非同期)
シナリオ KG の関連研究の候補を集めて KG に保存する。
1. LLM が筋書きから検索語を作る (`{"Queries": [..]}`、4〜8 個。題目・要約への部分一致なので 1〜3 語の短い語句、日本語と英語)。
2. 検索語ごとに `SourceVaultSummaries[q, "Providers" -> {"sources", "eagle"}, "Limit" -> 6]` (取り込み済みの論文・Web・ローカル・Eagle)。`"Web" -> True` (Story の `Survey: web`) のときだけ `SourceVaultWebSearch[q, "MaxResults" -> 5]` も使う (検索語が外に出るので、書いたときだけ)。
3. 同じ文献を 1 つにまとめ (URI > Id > URL)、当たった検索語の多い順に最大 `"MaxCandidates"` (20)。**PrivacyLevel >= 0.5 の候補はデッキの PrivacyLevel がそれ以上のときだけ残す** (公開の発表に非公開の資料を引かない。除外数は `"Excluded"`)。題目の拡張子 (.pdf など) は外す。
4. KG に `"Related"` (`<|Key, Kind, Id, URI, URL, Title, Authors, Year, Summary, PrivacyLevel, Queries|>` のリスト)、`"RelatedQueries"`、`"RelatedWeb"`、`"RelatedAtUTC"` を保存し、`"Then"` を呼ぶ。結果は `SlideWorkflow`Private`$iSWRelatedLast` (`Status` / `Queries` / `Candidates` / `Excluded` / `Web`)。
Options: `"Web" -> Automatic` (Story の `Survey: web`), `"MaxCandidates" -> 20`, `"Then" -> None` (完了後に呼ぶ関数), `"Audience" -> Automatic`, `"Story" -> Automatic`, `"PrivacyLevel" -> Automatic`
実データ (9/17): 検索語 6 個で 11 秒、候補 12 件 (非公開 5 件を除外)。「自由エネルギー」のような広い語は熱力学の教科書も拾うので、どれを紹介するかは展開の LLM が筋書きに照らして選ぶ。

### 筋書きの展開 (推敲の連鎖の Scenario 回、v1.30)
KG の Kind が `"Scenario"` なら、推敲 (`SlideGraphRefine` の Direct 連鎖) は節ごとに筋書きを発表用のノードへ**展開**する (状態欄「KG 展開」)。プロンプト = 聴き手・ストーリー・全体の筋書き (節の並び)・展開する節の筋書き・関連研究の候補 (番号. 題目 / 著者 / 年 / 種類 と要約)。LLM は節ノード (Label / Summary)、`<節>_1..` (1 ノード = 1 枚、Lead / Points / Details / Talk / Importance / Kind、候補に依拠するなら `"Ref": [番号]`)、`rw_<候補番号>` (関連研究の紹介、`"Parent"` で節)、`bg_*` (前提) を返す。受理 (`iSWScenarioSanitize`): それ以外の Id は落とす / 候補に無い番号の `rw_` は落とす / 新しい枚には節からの Contains と、節の Order + 0.01 刻みの順序 (LLM が並べた順) と Precedes / `rw_` の Cite は候補の「題目 (著者, 年) 所在」、PrivacyLevel は候補から / 同じ候補は最初に出た節にだけ置く / 枚ができた節の筋書きノード (`<節>_d`) は外す。ノードの Kind に `RelatedWork` と `Example` を足した (SourceVault_knowledgegraph)。KG の Kind に `Scenario` を足した。
KG構築 (シナリオ) の流れ: `SlideGraphSeedScenario` → `SlideGraphRelated` (`Survey: off` なら飛ばす) → 展開。途中で止まっても筋書きノードが残るので「推敲」で続きから、「図解」「調整」は先にその節を展開する (v1.29 の未推敲の節の検出がそのまま効く)。

### SlideGraphFromSlides[nb | deck.nb, opts] → Success["GraphFromSlides", <|"GraphId", "Nodes", "Parts", "Slides", "Covers", "Tail", "PrivacyLevel", "Language", "Refreshed", "Written", "KG" (, "File")|>] (v1.58)
SlideStory を書かずに作った過去のデッキ (筋を考えて作り込んだ既存のスライド) から、**枚の順と見出しの構成をそのまま写した** KG を作り、
デッキを SlideWorkflow 準拠にする。KG から枚を作り直すのではない。LLM は呼ばない。
- 読み方: 枚の先頭 3 セル以内の最初の見出し (Title・Chapter = デッキの題 > Section > Subsection > Subsubsection) がその枚の題目。
  見出しの無い枚と、同じ題目が続く枚は「続き」として同じノード。見出しが 2 段以上あれば上の段を部 (Section ノード)、1 段なら根の下に平らに並べる
  (部が要れば「階層化」)。題目が空の表紙は根の要約に、題目が `$SlideGraphTailTitles` (既定 最後尾 / Appendix / 付録) の枚から後ろは入れない。
  ノード = 題目 (Label)、最初の箇条書きより前の Text (Lead)、箇条書き (Points、無ければ Text)、副項目と箇条書きの後ろの注記 (Details)、
  トークセル (Talk)、全文 (Text)、`Source` = 枚の番号・図とコードの数。Id は題目セルに既にある KGNode / KGSync を使い、無ければ `s<最初の枚>`。
- デッキへの書き込み: スライドの中身は変えない。題目セルに `KGSync:<id>` (「生成」の置き換え対象にならない対応タグ)、前置きに指示セル
  (無ければ: Title / PrivacyLevel) と Story セル (`Graph:` / `Source: スライド` / `Slides:` / `Language:` / 既存の題目の並び)。
  ファイルを渡すと元を残して `<名前>_sw.nb` に書く (`"Output" -> path`、`"InPlace" -> True` で上書き)。
- 写し直し (`"Refresh" -> Automatic`: Story の `Graph:` がこの KG のとき): スライドから取れる項目だけ置き換え、推敲・意味付けで足された項目
  (Role など) と周辺知識 (Layer が Paper 以外) と、その辺は残す。別のデッキの同じ Id の KG があれば Id を `-2` などにずらす (`"Overwrite" -> True` で上書き)。
- PrivacyLevel: `"PrivacyLevel"` > 指示セルの `PrivacyLevel:` > 0.5 (未記入は非公開寄り)。
- パレット: **「反映」を KG の無いデッキで押す**と、確かめてからこれを呼ぶ (KG があれば従来どおり原稿と KG を合わせる)。
  Story が `Source: スライド` のデッキでは「生成」は止まり (既存のスライドが正)、「KG構築」はスライドから写し直す。
- 併せて直した既存のバグ: スタイルを 2 つ持つ区切りセル (`{"SlideShowNavigationBar", "FirstSlide"}`) を枚の区切り 2 つに数えていた
  (`iSWSlideRanges` ほか 4 か所。再生・反映・プロンプトの位置がずれていた)。ポスターは Subsection 以外の見出しと KGSync タグも読み、題目が空の枚を表紙として扱う。
- テスト: slidegraph_test T45 (9 件)。

### SlideGraphBuild[] / SlideGraphBuild[nb, "Mode" -> Automatic | "Extract"]
v1.30: 素材を選ぶ (上の「素材は 2 通り」)。シナリオなら `SlideGraphSeedScenario` → `SlideGraphRelated` → 筋書きの展開。以下は論文の場合。
Options: `"Mode" -> Automatic` (`Automatic` = `SlideGraphRefine` の Direct 連鎖、`"Agent"` = 推敲をエージェント (ClaudeEval) に委譲、`"Extract"` = 和訳ノート無しで PDF をエージェントに読ませる旧経路)
v1.22 (v1.23 で seed の規則を追加、下記): References に和訳ノートブック (.nb、`DocImportPaper` の出力) があれば `SlideGraphSeed` で第一次 KG を**決定的に**作り、続けて節ごとの推敲を行う。v1.24: 推敲は既定で `SlideGraphRefine` の Direct 連鎖 (LLM を節ごとに直接呼ぶ)、`"Mode" -> "Agent"` でエージェント委譲。.nb が無ければ Failure (`NoSourceNotebook`) で `DocImportPaper` を案内する。`"Mode" -> "Extract"` は従来の PDF 直読み抽出 (局所モデルでは途中で壊れやすい)。

### 文献の自動解決 (v1.22)
References の locator が SourceVault 取り込み済みの論文 (`src-…` / `sv://…` / `arxiv:…`) で、`SourceVault_papernb.wl` の登録簿に和訳ノートブックがあれば、その行は自動的にノートブック扱いになる (`"Notebook"` キー)。 Eagle の PDF (`sv://object/eagle-<id>` / `eagle:<id>`) も同じ: 登録簿は正準 URI で引き、PDF の資産 (`SlidePDFFigure`) は `SourceVaultEagleObjectInfo` で item の実ファイルに解決する (v1.25)。`SlideGraphSeed` / `SlideNotebookOutline/Text/Figure/Formula[key]` はそのノートを読み、PDF の資産 (`SlidePDFFigure[key, ..]`) は従来どおり原本 PDF に解決される。生成は `SourceVaultMakePaperNotebook["src-…"]` (一覧の「＋ 和訳NB」)。

### SlideGraphSeed[nb | key | path, opts] → <|"Graph", "Title", "PaperTitle", "NodeCount", "EdgeCount", "Sections", "Paragraphs", "Figures", "Formulas", "Kept", "Authors", "Skipped", "Warnings", "KG"|>
和訳ノートブックの構造から第一次 KG: 見出し → Section (階層は Contains)、段落 → Concept (本文は `"Text"`、ラベルは冒頭、要約は先頭 2 文)、図 → Figure (NotebookFigure 資産、キャプション「図 n.」「図n |」「Figure n:」「Fig. n.」がラベル。図の前後どちらにあっても合流)、数式 → Equation (Formula 資産)。同じ節の段落・式は Precedes で順序づけ、図は前後の段落へ Supports。Abstract セルは根 (Claim) の要約。
Options: `"Graph" -> Automatic`, `"Title" -> Automatic`, `"Language" -> "ja"`, `"MinCharacters" -> 40`, `"Save" -> True`, `"Notebook" -> Automatic` (対象の和訳ノートブックを直接指定、既定は References から解決), `"Reconstruction" -> False`, `"Keep" -> "Background"`
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
Options: `"Format" -> "Text"`, `"MaxCharacters" -> 4000`, `"Page" -> 1`

### SlideGraphRefine[] / SlideGraphRefine[nb, opts] / SlideGraphRefine[graphId, opts] → <|"Status" (Submitted|UpToDate|Busy), "Batches", "Sections", "PrivacyLevel"|>
`"Mode" -> "Talk"` (v1.25): 要点はあるが `Talk` の無いノードに原稿 (Points と同じ順に 1 要点 1〜2 文) だけを足す軽い回。推敲の差分 JSON も `Talk` を含む。
v1.24: 既定 (`"Mode" -> "Direct"`) は LLM を節ごとに直接呼ぶ callback 連鎖 (QA 生成と同じ仕組み)。節一覧で「済」でない節を上から順に、本文ノード合計 `"BatchNodes"` (8) 以下の隣接節を 1 リクエストにまとめ、**節本文を指示に同梱**して差分 JSON `{"Nodes", "Edges", "Remove"}` だけを返させ、`SlideGraphIngest[.., "Merge"->True]` で取り込む。受理する Id は本文に出た既存 Id と新規 `bg_*` だけ (幻覚 Id は落とす)、Remove は本文ノードだけ (節は残す)、形式違反は理由を添えて 1 回再問合せ、2 回失敗した節は飛ばして続行し末尾に記録。進捗は WindowStatusArea、完了時に終端マーカー後へ 1 行。途中で止めても「済」の節は飛ばして再開できる。LLM の経路 (CLI / 私的モデル) は `PrivacyLevel` (デッキ指示と KG ノードの最大) で `ClaudeQueryAsync` が決める。`"Sections" -> {"s3", ..}` で対象を絞る。graphId 形式 (headless) は `"Audience"` / `"Story"` を受ける。
`"Mode" -> "Agent"` は従来のエージェント委譲 (`SlideGraphSectionText` で 1 節ずつ読む)。エージェント経路は 1 実行あたり提案 4〜5 ターン (`ClaudeRuntime` の Eval 予算) で打ち切られるため、40 節の推敲には向かない。
`"Mode" -> "Enrich"` (別名 `"Detail"`): Lead / Details を後付けする回 (元の本文 Text も渡す)。
`"Mode" -> "Visual"`: 図解の回(下記「図が主役のスライド」参照)。`"Overview" -> Automatic` で最初に「全体像」の枚を補う処理を止められる (`"Overview" -> False`)。
Options: `"Mode" -> Automatic`, `"Sections" -> All`, `"BatchNodes" -> 8`, `"Audience" -> Automatic`, `"Story" -> Automatic`, `"Overview" -> Automatic`, `"PDF" -> Automatic`, `"Refine" -> Automatic`

### SlideGraphIngest[graphId, json | File[path], opts] → Success | Failure
KG の唯一の書き込み口。`"Merge"->True` (差分) / `"Language"->"en"` (訳の併記) / `"Link"->True` (周辺知識を共有層へ連結)。
Options: `"Merge" -> False`, `"Language" -> Automatic`, `"Title" -> Automatic`, `"Link" -> True`

### SlideGraphBackground[] / SlideGraphBackground[nb]
聴き手に足りない周辺知識ノードの追加をエージェントへ委譲。v1.27 から Story セルの `Story:` も委譲文に入る (「introduction は関連論文を引用して解説」のような、どの前提知識を足すかの要求はここで効く)。それ以前は聴き手しか渡しておらず、Story に書いても届かなかった。

### SlideGraphTranslate[nb, lang]
ノード単位の翻訳をエージェントへ委譲 (セル単位の `SlideTranslate` とは独立)。

### SlideGraphPlan[nb | graphId | kg, opts] → <|"Graph", "Tree", "Plan", "Verify", "Spec"|>
opts: `"Slides"` / `"Seconds"` / `"Audience"` / `"Strategy"` / `"SecondsPerSlide"` / `"Language"` (未指定は Story セル) / `"Spec"` -> Automatic

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
1. 「調整」を押すと調整セル (`SlideInsertAdjust[]`が入れる`"SlideAdjust"`スタイル、青枠。Working で見え、SlideShow と書き出しでは隠れる) が Story セルの後ろに入る。
2. 直したいことを書いて、もう一度「調整」を押す (例: 「論文の最初のページの図を説明するスライドを、結論の枚の後に入れる」「t 検定の枚は要らない」「実験系の枚の説明をもっと具体的に」)。
3. LLM が KG の差分を返し、検査してから反映する。反映したセルは灰色になり ✓ が付く (TaggingRules `SWAdjustApplied`。次に押すと、まだ反映していない次の調整セルを処理する)。
4. 古い生成スライドを消して「生成」。
LLM に渡すもの: 指示、いまのスライド構成 (番号・題目・ノード Id)、KG のノード一覧 (出現順、節の要約、図の有無、隠したノード)、使える図 (論文の図のノード / 論文 PDF の埋め込み画像 / 表 / 概念図)。
LLM が返す差分:
- `Nodes`: 新しいスライド = 新しいノード (Id は `adj_` で始める。`After` で位置、`Parent` で節、`Label` と `Points` は必須)、既存ノードの修正 (変えたいキーだけ: `Label` / `Lead` / `Points` / `Details` / `Talk` / `Importance` / `Assets` / `After` / `Hidden`)。
- `Hide`: スライドから外すノード (KG からは消さず `Hidden -> True`。計画は Hidden のノードをスライドにも詰め込みにも前提の修復にも使わない。結果の `"Hidden"`)。
- `Assets`: `{"Type": "Figure", "Of": "fig3"}` (論文の図の再掲) / `{"Type": "PDFImage", "Page": 1, "N": 1}` (論文 PDF の埋め込み画像) / `{"Type": "Table", "Rows": ..}` / `{"Type": "Code", "Code": .., "Caption": ..}` (図解と同じ検査)。使えない指定は落として注意に出す。PDF の画像の出典は「(key) p.n」。
- 新しいノードの Order は `After` の直後 (次のノードとの中点) で、`After → 新ノード` の Precedes 辺と、節からの Contains 辺を足す。
- `SlideGraphAdjust[nb | graphId, "指示"]` で直接渡せる。opts: `"PDF"` (論文 PDF の locator。既定は文献欄 → KG の出典から PDF に解決できるもの)、`"Then"` (反映後に呼ぶ関数)、`"Cell" -> None` (対象の調整セルを直接指定)、`"Audience"` / `"Story"` -> Automatic (未指定は Story セル)、`"Refine"` (v1.29。False で未推敲の節の先行推敲をしない)。結果は `SlideWorkflow`Private`$iSWAdjustLast`。
**論文 1 ページ目の図 (全体像)**: 和訳ノートはキャプション (「図n |」) のある図だけを取り込むので、キャプションのない 1 ページ目の図 (グラフィカルアブストラクト。システムの全体像を示す、論文でいちばん大事な図) が KG に入らない。「図解」は最初に、この図がどのノードにも無く論文 PDF の 1 ページ目に画像があれば、調整の仕組みで「全体像」の枚 (結論・要点の直後、Importance 0.95) を足してから図解する (`"Overview" -> False` で止める)。
- `SlidePDFImages[src, "Page" -> n]` = そのページの埋め込み画像。各ページのラスタ (と Inset の画像) を PageGraphics で数え、`Import[pdf, "Images"]` の並びに縦横比で突き合わせる (ページに現れないアイコン画像は飛ばす)。1 ページだけの PDF は全部をそのページとみなす。対応が取れなければ Failure。初回の Import が文字コードの警告を出しても画像は取れているので `Check` では判定しない。
- 資産の型 `"PDFImage"` (`"Ref"`, `"Page"`, `"N"`)。図の枚では縦長・正方形の図を高さ 360pt までに収める (幅は 560pt)。

### SlideInsertAdjust[]
調整セル (`"SlideAdjust"`スタイル) を挿入する。Working で見え、SlideShow と書き出しでは隠れる。`SlideGraphAdjust[]`は調整セルが無ければこの関数で自動的に作る。

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
資産 (NotebookFigure / Formula / PDFFigure / DeckSlide) を `SlideNotebookFigure` / `SlideNotebookFormula` / `SlidePDFFigure` / `SlideDeckFigure` で実体化。失敗した資産は落として `<<FIGn>>` を付番し直す。
Options: `SlideGraphPlan`と同じ + `"Notebook" -> Automatic` (headless時の対象ノートブック), `"Talks" -> None` (枚ごとの原稿の差し替え), `"Title" -> Automatic`, `"Outline" -> {}` (SourceVaultKGOutlineへ渡すオプション), `"Realize" -> True`

### SlideGraphApply[] / SlideGraphApply[nb, opts] → Success | Failure
デッキへ適用 (10 枚ずつ `SlideDeckInsertScenario` を呼ぶ)。
Options: `SlideGraphGenerate`と同じ + `"Mode" -> Automatic`, `"After" -> Automatic`, `"Polish" -> False`, `"ChunkSize" -> 10`
**v1.30: 前回の生成を置き換える**。KG から作った枚は md の見出しに `{expected=秒 node=<ノード Id>}` (用語ミニ辞書は `node=glossary`、目次は `node=agenda`) が付き、題目セルの CellTags `"KGNode:<id>"` になる (`SlideScenarioFromMarkdown` の `"Node"`、`iSubsectionTags`、スライド → md の見出しにも戻る)。`"Mode" -> Automatic` はこの目印のある枚があれば `"Replace"`:
1. デッキの質疑応答セルを KG のノードへ保存 (`iSWKGHarvestQA`。同じノードの枚 = 本体と「(続き)」の順のリスト、空なら消す。agenda / glossary / KG に無い Id は無視)。
2. 新しい枚を前回の最初の枚の位置に入れる (`"After"` の既定)。
3. 前回の枚を消す (`iSWDeleteSlides`、後ろから)。途中で失敗したら前回の枚は残す。
生成は KG のノードの `"QA"` を同じノードの枚へ `qa:` として戻す (`iSWKGAttachQA`。枚が減ったら残りを最後の枚にまとめる)。目印が無ければ `"Append"` (最後のスライドの後、`"After"->n`)。v1.29 以前に生成した枚は目印が無いので残り、結果のメモで手で消すよう知らせる。結果: `"Mode"` / `"Replaced"` (消した枚数) / `"QA"` (保存の結果)。
パレットの「生成」(`iSWGraphApplyAction`) は、目印のある枚があれば「置き換える / 後ろに追加 / やめる」を聞く (手で直した本文と原稿は KG から作り直される — 残したい直しは「調整」で KG に入れる)。`"Polish"->True` で talk の推敲をエージェントへ委譲 → エージェントが `SlideGraphApply["Talks"->{..}]`。

### SlideGraphBuildDeck[graphId | kg, "deck.nb", opts] → <|"File", "Slides", "Warnings", "Verify", "Plan", "GraphId"|>
KG から新しいデッキファイル (headless 可)。
Options: `SlideGraphGenerate`と同じ + `"TitleSlide"`, `"Event"`, `"Author"`, `"Date"`

### SlideGraphSurvey[{graphIds}, "deck.nb", opts]
複数 KG を合成 (`SourceVaultKGCompose`) してサーベイデッキ。
Options: `SlideGraphBuildDeck`と同じ + `"Title"`, `"Slides"`, `"Audience"`, `"Chronological"`, `"GraphId"`, `"Save" -> True` (合成 KG を保存)

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
- Options: `"View" -> "Story"`, `"Focus" -> None`, `"Radius" -> 1`, `"EdgeKinds" -> Automatic` (群 Order / Prerequisite / Support / Related / Contains か辺の種類の名前。既定: 話の流れ = 順序・前提・支え、節 = 包含以外、周辺 = すべて), `"Layers" -> All` (All か {"Paper", "Background", "Related"} の部分。節はいつも描く), `"Labels" -> Automatic` (Automatic = 節・重要度 0.75 以上・枚の本体・選択中 / All / None = 節だけ), `"Plan" -> Automatic`, `"Selected" -> None`, `"OnClick" -> None` (クリックで `f[id]`), `"Language" -> Automatic`, `"Legend" -> True`, `"Hidden" -> True` (False で隠したノードを描かない)。凡例は `SourceVaultKGLegend[lang, 1 行の項目数]`。
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