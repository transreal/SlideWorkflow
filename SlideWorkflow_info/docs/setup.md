# SlideWorkflow セットアップガイド

## 1. 前提条件

- **Mathematica / Wolfram Engine**: バージョン 13.0 以降を推奨します。ノートブック式の操作、`Rasterize`、`ScreenStyleEnvironment` を使用します。
- **OS**: Windows 11 を想定しています。macOS/Linux ではパス区切りやシェルコマンドを適宜読み替えてください。
- **外部ツール**:
  - `SlideDeckExportVideo` で mp4 を書き出すには、環境によって FFmpeg が必要です。未インストールの場合は事前にインストールし、PATH に追加してください。
  - クリップボードやウィンドウのスナップショットには依存しないため、ヘッドレス (wolframscript) 環境でも同じ結果になります。
  - 対話編集レイヤーの `SlideExpand[]` を既定の `$SlideExpandMode="Agent"` で使うには、[ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) 経由で `ClaudeEval` を呼べる環境が必要です。なくても `$SlideExpandMode = "Direct"` に切り替えれば動作します (第 7 章参照)。
  - 発表機能 (SlideTalk 系、`SlidePlay`、音声対話、手元リモコン用の `SlideRemoteStart`、QA セル、読みの辞書、ポスター原稿など) を使うには [SourceVault](https://github.com/transreal/SourceVault) が必要です。スライド生成や画像・動画の書き出しなどの基本機能は、SourceVault なしでも動作します。手元リモコン連携は Windows 専用です。
  - Sliden 用 mp4 (またはポスター PDF) を `SlideDeckUpload` / `SlideDeckRegister` でアップロードするには、sftp の送り先 (指示セルの `Host: sftp://user@host/dir` 行) が必要です。加えて、組込みの遠隔ファイルへの `CopyFile` か、sftp 対応の `curl` (Git for Windows 同梱のものなど) のどちらかが必要です。パスワードは NBAccess 経由でシステムの資格情報ストアに保存されます。
- **フォント** (任意): タイトルの強調には、既定で「ヒラギノ角ゴ Std」("Hiragino Kaku Gothic Std") を使用します。お使いの Windows 環境にこのフォントがない場合は、`$SlideHeavyFontFamily` をお使いの環境にあるフォント名で上書きしてください。

## 2. インストール

1. リポジトリを取得します。

   ```
   git clone https://github.com/transreal/SlideWorkflow.git
   ```

2. `SlideWorkflow.wl` を、他の `.wl` パッケージと同じディレクトリ (以下 `$packageDirectory`) に直接配置します。サブフォルダは作らず、フラットな構成にしてください。

3. Notebook 側で `$packageDirectory` を `$Path` に追加します (パッケージ名のサブパスは書きません)。

   ```wolfram
   AppendTo[$Path, $packageDirectory];
   ```

   claudecode をすでに使っている場合は `$Path` が自動設定されるため、この手順は不要です。

4. UTF-8 環境でパッケージを読み込みます。

   ```wolfram
   Block[{$CharacterEncoding = "UTF-8"},
     Needs["SlideWorkflow`", "SlideWorkflow.wl"]];
   ```

   `$packageDirectory` が `$Path` に含まれているため、ファイル名だけの指定で動作します。

   旧 `SlideWorkflow_interactive.wl` (パレット、スライド展開、翻訳などの対話編集機能) は、2026-07-13 に `SlideWorkflow.wl` へ統合されました。別途 `Needs` する必要はありません。

## 3. 依存パッケージ (任意)

- [NotebookExtensions](https://github.com/transreal/NotebookExtensions): `NotebookExtensions`$fontFamily` が定義されていれば、`$SlideFontFamily` が自動的にそれを使います。なくても動作しますが、フォントの統一のためにインストールを推奨します。`$packageDirectory` に直接配置し、`Needs` で読み込んでください。
- [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime): 既定の `"Agent"` モードで `SlideExpand[]` を使うために必要です (`ClaudeEval` の実行経路)。使わない場合は `$SlideExpandMode = "Direct"` にしてください。
- [NBAccess](https://github.com/transreal/NBAccess): `"Direct"` モードでの LLM 呼び出し (`NBAccess`\`$NBLLMQueryFunc`) と、sftp パスワードの SystemCredential への保存 (`SlideUploadCredential`) に使います。
- [SourceVault](https://github.com/transreal/SourceVault): 発表原稿のローカル音声合成と再生 (`SlideTalkFromMarkdown` など)、音声対話、発表の登録簿と QA パック、共有の読みの辞書 (`slidedecks/readings.txt`)、文献・PDF の参照 (`SlidePDFFigure` など) に使います。スライド生成や画像・動画の書き出しは、なくても通常どおり動作します。`$packageDirectory` に直接配置し、`Needs` で読み込んでください。音声機能は [SourceVault_voice](https://github.com/transreal/SourceVault_voice) と [SourceVault_realtime](https://github.com/transreal/SourceVault_realtime) に、QA パックは [SourceVault_talkqa](https://github.com/transreal/SourceVault_talkqa) に依存します。

## 4. API キー設定

SlideWorkflow 自体はローカルの Notebook 操作と画像・動画の書き出しだけを行い、独自の外部 API キーは使用しません。そのため、これらの機能に設定は不要です。`SlideExpand[]` の `"Agent"` モードを使う場合、認証と承認ゲートは `ClaudeRuntime`/`ClaudeEval` の設定に従います。音声合成、音声対話、QA パックの設定は `SourceVault` に従います。sftp アップロードでは、`SlideUploadCredential[url]` を一度実行して、パスワードを NBAccess 経由で保存します。保存済みかどうかは `SlideUploadCredentialQ[url]` で確認でき、`SlideUploadCredential[url, None]` で削除できます。

## 5. 基本設定変数 (必要に応じて調整)

```wolfram
$SlideImageSize = {1920, 1080};
$SlideStyleDefinitions = "Normal use.nb";
$SlideMargins = {{0, 0}, {0, 0}};
$SlideExpandMode = "Agent";
$SlideTranslationLanguage = "English";
```

- `$SlideTheme`: 図の色を統一するための配色の連想です。
- `$SlideStyleDefinitions`: デッキ生成に使うスタイルシート名です。既定は "Normal use.nb" で、`Templates/slides-template.nb` に従います。
- `$SlideIncludeInput`: 書き出しに Input/Code セルを含めるかどうかの既定です。`Automatic` (既定) はノートブックの表示どおりで、折りたたまれたセルや `CellOpen->False` のセルだけが除かれます。`True` は `Automatic` と同じです。`False` は Input/Code セルをすべて除きます。`"Visual"` は図を含む Input セルだけを残します (旧既定)。`CellTags` に `"ShowInput"` を持つセルは、常に残ります。
- `$SlideExpandMode`: `SlideExpand[]` の実行経路です。既定の `"Agent"` は `ClaudeEval`/`ClaudeRuntime` を経由し、文献検索、図の生成、複雑な処理の承認ゲートに対応します。軽量な `"Direct"` は `NBAccess`\`$NBLLMQueryFunc` を直接呼びます。
- `$SlideTranslationLanguage`: `SlideTranslate[]`/`SlideTranslateDeck[]` の翻訳先言語です。日本語環境での既定は `"English"` です。
- `$SlideVisualsPerSlide`: True (既定) のとき、`SlideExpand[]` の展開プロンプトが「原則すべてのスライドに図か表を 1 つ以上」を要求します。False にすると、文章中心の生成に戻ります。
- `$SlideTalkPerSlide`: True (既定) のとき、展開プロンプトが各スライドの末尾に発表原稿 (`talk:`、です・ます調、2〜6 文) を要求します。スライド本体は図表と体言止めの句に絞られ、スライドと原稿の両方で説明が完成する分業になります。False にすると従来の動作に戻ります。
- `$SlideExportExternal`: パレットの画像・mp4 書き出しを別プロセス (wolframscript) で行うかどうかです。既定の `Automatic` は 1 度試し、起動できなければ (ライセンス席不足など) 以降は FE 内処理にフォールバックします。そのとき状態欄に、ライセンス席の案内が表示されます。`True`/`False` は動作を固定します。登録用 mp4 の作り直しには FE 内へのフォールバックがないため、毎回別プロセスで再試行されます (第 6 章「ライセンス席のトラブルシューティング」参照)。
- `$SlideHideToolbarInSlideshow`: True (既定) のとき、`SlideToggleScreenEnvironment[]` は SlideShow への切り替え時にノートブックのツールバーとドックセルを一時的に隠し、Working に戻すときに復元します。

### 発表 (原稿・音声) 関連の変数

これらは SourceVault をインストールしている場合にのみ有効です。

- `$SlideTalkLanguage`: 発表を読み上げる既定の言語です (`"en"`、`"English"` など)。`Automatic` (既定) は `$Language` を使います。デッキの指示セルの `Language:` 行が優先されます。`SlideTalkLanguage[nb]` は解決済みのコードを返し、`SlideTalkLanguages[nb]` は言語ごとの翻訳状況を報告します。
- `$SlideTalkSecondsPerSlide`: 発表シナリオの 1 枚あたり秒数の既定です (既定 25)。
- `$SlideVoice`: 読み上げに使う声のモデル名です。既定の `Automatic` は `SourceVaultVoice[]` の既定に従います。候補は `SlideVoices[]` で一覧でき、`SlideCycleVoice[]` で切り替えられます。
- `$SlideRealtimeVoices`: 声のトグルに並ぶクラウド音声 (OpenAI Realtime) です (既定 `{"marin", "cedar"}`)。一覧には `realtime:<声>` として現れます。
- `$SlideVoiceProvider` / `$SlideVoiceModel` / `$SlideVoiceDefaultModel`: 音声会話のプロバイダとモデルです。既定のプロバイダは登録簿の先頭 (`"OpenAI"`) です。既定のモデルは `$SlideVoiceDefaultModel` (`"gpt-live-1"`) です。確認と切り替えには `SlideVoiceModels[]`、`SlideCycleVoiceProvider[]`、`SlideCycleVoiceModel[]`、`SlideSetVoiceModel[model]` を使います。
- `$SlideQuestionMode`: 発表中の質問の受け方です。`"QuestionTime"` (既定) は 1 枚読むごとに質問時間を取り、読み上げ中はマイクを切ります。`"Words"` は読み上げ中も聞き、`$SlideInterruptWords` が聞こえたときだけ止まります。`"Detect"` は聞き手の声を検知すると止まり、質問かどうかは gpt-live が判断します。`"Words"` と `"Detect"` は gpt-live-1 のときだけ有効です。`SlideCycleQuestionMode[]` または `SlideSetQuestionMode[mode]` で切り替えます。
- `$SlideInterruptWords`: `"Words"` モードで発表を止めてよい語です (既定 `Automatic` = `$SourceVaultRealtimeInterruptWords`、つまり「質問」「スライド」)。認識にはローカルの Vosk を使うため、`SourceVaultRealtimeInstall["Vosk" -> True]` と `SourceVaultSpeechModel[]` が必要です。
- `$SlidePlayAnswering`: `realtime:` の声で再生するときに、質問 (音声対話) を受けるかどうかです。`Automatic` (既定) は再生開始時の状態に従います。音声対話がオンでマイクもオンなら質問を受け (各枚のあとの質問時間)、そうでなければ原稿を読み上げるだけでマイクは閉じたままです。再生は「対話 on/off」の表示を変えません。対話がオフの状態から再生を始めた場合、音声セッションは読み上げのためだけに開き、再生が終わると閉じます。再生中は、マイクボタン (と手元リモコン) で質問を受けるかどうかを切り替えます (マイクオン = 質問時間あり、マイクオフ = 読み上げだけ)。`True` は常に質問を受けます (v1.51 までの動き)。`False` は常に読み上げだけです (再生の間はマイクを閉じ、終了後に戻します)。
- `$SlideQuestionSeconds` (既定 3)、`$SlideQuestionMaxSeconds` (既定 60)、`$SlideVoiceInputGate` (既定 0、制限なし): 質問時間、その上限、マイクを受け付ける最低入力音量を制御します。
- `$SlideVoiceGap` (既定 0.8 秒)、`$SlideRenderSettle` (既定 0.6 秒)、`$SlideVoiceTick` (既定 0.3 秒): それぞれスライド間の間、描画が落ち着くまでの待ち、カーネル側 ScheduledTask の周期です。
- `$SlidePrepareBeforePlay`: True (既定) のとき、`SlidePlay` は再生開始前に全スライド分のローカル音声を合成します (未合成のものだけ)。これにより、再生中に合成で音が途切れません。
- `$SlideSpeechRate` / `$SlideSpeechLatency`: `SlideTalkDuration` が使う、エンジンごとの話速と 1 枚あたりの待ちです。
- `$SlideReadingFile`: `SlideReadingApply` が使う、共有の読みの辞書ファイルです。`Automatic` (既定) は SourceVault の `slidedecks/readings.txt` (PC 間で共有) で、SourceVault が使えなければ `$UserBaseDirectory/ApplicationData/SlideWorkflow/readings.txt` です。
- `$SlideRemoteBindings` / `$SlideRemoteTick` / `$SlideRemoteAuto`: 手元リモコン用です (Windows 専用)。既定では "MediaPrevTrack" が "Mic" に、"MediaPlayPause" が "Play" に対応します。ボタンの仮想キーは `SlideRemoteProbe[]` で実測できます。見張りの開始と停止は `SlideRemoteStart[]`/`SlideRemoteStop[]`、状態確認は `SlideRemoteStatus[]` です。`$SlideRemoteAuto = True` (既定) では、音声対話と連動して見張りが開始・停止します。
- `$SlideQAPerSlide` (既定 3) と `$SlideQAVision` (既定 True): `SlideQAGenerate` が作る 1 枚あたりの想定質問数と、図・写真・表のあるスライドの描画画像を LLM に添付するかどうかです。画像は `<deck>_qa_images/` にキャッシュされます。
- `$SlideUploadMethod`: mp4 アップロードの転送手段です。`Automatic` (既定) は `"Native"` (遠隔ファイルへの `CopyFile`) を試し、使えなければ `"curl"` にフォールバックします。

## 6. 動作確認

1. パッケージが読み込まれていることを確認します。

   ```wolfram
   ?SlideDeckBuild
   ```

   usage メッセージが表示されれば、読み込みは成功です。

2. サンプルのシナリオからデッキを生成します。

   ```wolfram
   md = "--- Title: Test / Event: Demo / Author: Imai / Date: 2026-07-13 ---\n## Slide1 {expected=30}\n- Hello";
   scenario = SlideScenarioFromMarkdown[md];
   nbfile = SlideDeckBuild[scenario, FileNameJoin[{$TemporaryDirectory, "test-slides.nb"}]];
   ```

   エラーなくファイルパスが返れば、動作しています。

3. 生成したデッキの一覧とサムネイルを確認します。

   ```wolfram
   SlideDeckOverview[nbfile]
   SlideDeckImages[nbfile]
   ```

   Dataset と 16:9 の画像リストが得られれば、インストールと設定は完了です。

4. mp4 書き出しを使う場合は、次も確認します。

   ```wolfram
   SlideDeckExportVideo[nbfile, FileNameJoin[{$TemporaryDirectory, "test.mp4"}]]
   ```

   ファイルが作られなければ、FFmpeg のインストールと PATH の設定を見直してください。

5. 対話編集レイヤーを使う場合は、パレットが開くことを確認します。

   ```wolfram
   ShowSlidePalette[]
   ```

   パレットが表示され、`?SlideAddSlide` などで usage メッセージが表示されれば、統合された対話編集機能が利用できます。

6. 発表機能 (SourceVault が必要) を使う場合は、発表パレットが開くことと、声の一覧が出ることを確認します。

   ```wolfram
   ShowSlideTalkPalette[]
   SlideVoices[]
   ```

   SourceVault_voice が読み込まれていないと、`SlideVoices[]` は `{}` を返します。`SlideInfo[]` は、デッキ、原稿、見積り時間、声、音声対話の状態をまとめたウインドウを開きます。

7. 読みの辞書を使う場合は、共有辞書ファイルの場所を確認します。

   ```wolfram
   SlideReadingFile[]
   SlideReadings[]
   ```

   `SlideReadingFile[]` は共有辞書のパスを返します (なければ、よく誤読される語を入れて作成されます)。`SlideReadings[]` は、有効な辞書 `<|語 -> よみ|>` を返します。

### ライセンス席のトラブルシューティング (別プロセス書き出し)

パレットの画像・mp4 書き出しは、既定で別の Wolfram プロセス (wolframscript) で実行されます (`$SlideExportExternal` 参照)。ライセンス席 (同時に動かせる Wolfram プロセスの数) を使い切っていると、別プロセスを起動できず、状態欄に「アクティベートされていません」と表示されます (席が単に足りないだけのときもこの表示になります)。その場合は次のようにします。

1. 案内に表示される、動いている Wolfram プロセスの一覧 (このフロントエンドのものも含みます) を確認し、閉じてよいものを探します。
2. 使っていない `WolframKernel.exe` / `wolframscript.exe` を終了して、席を空けます。
3. パレットの操作をもう一度実行します。

`$SlideExportExternal = Automatic` では、通常の画像・mp4 書き出しは、最初の失敗のあとで FE 内処理にフォールバックします。一方、登録用 mp4 の作り直しはフォールバックしません。mp4 がスライドより古く、デッキの未保存の変更のため別プロセスで作り直せない場合や、別プロセスが無効 (`$SlideExportExternal = False`) の場合、古い mp4 は決してアップロードされず、登録は理由と次の手順を添えた `Failure` を返します。その場合は、デッキを保存し、パレットの「mp4」ボタンで mp4 を作り直し (FE 内で描画するので数分かかります)、もう一度「登録」を押してください。別プロセスは一度失敗しても永久には諦められず、作り直しのたびに再試行されます。復旧できない失敗は、理由が `Failure` として返ります。プロセス一覧を表示したくない場合は、`$iSWListWolframProcesses = False` で案内を抑制できます。

## 7. 対話編集レイヤー (パレット)

`SlideWorkflow` には、スライド Notebook を対話的に編集するためのパレット機能が統合されています (旧 `SlideWorkflow_interactive.wl`。2026-07-13 に本体へ統合)。

```wolfram
ShowSlidePalette[]
```

でパレットが表示されます。`"Safe"->True` を指定すると、ClaudeCode に完全に干渉しない状態でパレットが開きます (フリーズの切り分け用)。現在のバージョンは `$SlideWorkflowInteractiveVersion` で取得できます。発表パレット (スライドショー、再生、音声対話、カメラ、声・言語・質問の設定) は `ShowSlideTalkPalette[]` で開き、作成パレットのボタンからも開けます。

パレットの主な操作です (すべて、スライド Notebook の現在のセル選択に対して働きます)。

- `SlideAddSlide[]`: 現在のスライドの直後に、新規スライド骨格 (navbar + タイトル + プロンプトセル) を挿入します。プロンプトに「N 枚構成で」などと書けば、「展開」で複数スライドに一括展開できます (`SlideApplyScenario` が複数の `##` を複数枚に分割します)。
- `SlideExpand[]`: 選択した `SlidePrompt` セル (なければ選択セルの本文) を指示として、スライドを展開・更新します。既定 (`$SlideExpandMode="Agent"`) では `ClaudeEval` (`ClaudeRuntime` 経由で、文献検索、図の生成、承認ゲート付き) に委譲し、エージェントが最後に `SlideApplyScenario` を呼んで適用します。エージェントの作業ログは、終端マーカー以降 (Appendix) に記録されます。指示 (Directive) セルと辞書 (Dictionary) セルは厳守され、既存の図・コードセルは `<<FIGn>>` トークンで保持されます。
- `SlideApplyScenario[slideNo, md]`: 対象スライドをシナリオ Markdown で差し替える決定的な関数です (展開エージェントの唯一の書込み口)。`md` には複数の `##` を含められます (複数枚展開)。`<<FIGn>>` は、既存の図・コードセル (n=1..k) か、`"Figures"` オプションで渡した新規の図 (Graphics/Image、n=k+1..) を指します。成功時は `Success`、失敗時は `Failure` を返します。新規の図が `Failure` / `$Failed` であったり、評価されずに残った画像処理の式であったりした場合は、何も書かずに `Failure["BadFigures"]` を返します。`SlidePrompt` セルは、自動的に先頭スライドへ戻されます。
- `SlideTranslate[]` / `SlideTranslateRevert[]` / `SlideTranslateDeck[]`: 現在のスライド、またはデッキ全体 (非同期で 1 枚ずつ) のテキストセル (見出し・箇条書き・本文) を `$SlideTranslationLanguage` に翻訳し、また原文に戻します。原文は消えず、セルの TaggingRules に残ります (`"documentation"` -> translationSrc / translation / showTranslation で、documentation.wl と同じです。書式つきセルの原文は `SWOrigContent` に保持されます)。そのため、元に戻しても翻訳は残り、翻訳への手直しも残ります。翻訳済みのセルは表示を切り替えるだけで、翻訳のないセルと原文を直したセルだけを、1 枚ずつ LLM に渡します。同じスライド内の図 (Output / Print / Graphics セル) の中の日本語の文字列も翻訳されます。原文の図は `SWOrigContent`、翻訳した図は `SWTransContent` に持ちます。フォント名などのオプション値と、画像に埋め込まれた文字は翻訳されません。発表原稿 (talk セル) はこれらの関数では翻訳されません。`SlideTalkTranslate` を使ってください。
- `SlideShowLanguage[]` / `SlideShowLanguage[nb, "Toggle" | "Original" | "Translation"]`: LLM を呼ばずに、デッキ全体の表示を原文と翻訳で切り替えます。翻訳のないセルは原文のままです。画像・mp4 の書き出しは、現在表示している言語に従います。
- `SlideInsertPrompt[]`: カーソル位置に `SlidePrompt` セルを挿入します (ラスタライズから除外されます)。
- `SlideInsertCitation[]`: カーソル位置に出典セル (小フォント) を挿入します。図や引用の直後に置き、URL または (著者, 年) を記入します。
- `SlideInsertReferences[]`: 文献リストセル (パレットの「文献」) を挿入します。1 行に 1 文献を `[key] locator | メモ` の形で書きます。`locator` は URL / arxiv:ID / sv://URI / eagle:ID / PDF・ノートブックのパス (過去スライドも可) です。スライドの指示 (プロンプト) からは `[key]` で参照し、展開エージェントが取得・引用します。`#` で始まる行はコメントです。
- `SlideInsertTalk[]`: トークセル (`SlideTalk` スタイル、そのスライドの発表原稿) を挿入します。各スライドの末尾に置きます。Working では見え、SlideShow 環境では非表示で、書き出しからは除外されます。md では `talk:` の原稿行に対応します。全スライドにトークがあれば、`SlideTalkBuild` が LLM なしで `<deck>_talk.md` にまとめられます。
- `SlideInsertQA[]`: 質疑応答セル (`SlideQA` スタイル、そのスライドの想定問答) を挿入します。各スライドの末尾の、トークセルの隣に置きます。Working では見え、SlideShow では非表示で、画像・mp4 の書き出しからも除外されます。md では `qa:` 行に対応します。1 問ごとに、`Q: 想定質問` と `A: 読み上げる回答` の 2 行で書きます (任意で `cite: 出典`、`PL: 0.6`)。
- `SlideInsertReading[]`: 読みセル (`SlideReading` スタイル) を挿入します。読み上げ (gpt-realtime かローカルの声) のときだけ、語を仮名に置き換える辞書です。1 行に 1 語を `語 = よみ` の形で書きます (区切りは `＝` や `→` / `->`、タブでも構いません)。`#` から行末まではコメントです。スライド、字幕、原稿は書き換えません。全デッキ共通の読みの辞書 (`SlideReadingFile[]`) より優先されます。Working では見え、SlideShow と書き出しでは隠れます。
- `SlideInsertEndMarker[]`: カーソル位置にスライド終端マーカーを挿入します。以降のセルは、スライドにも書き出しにも含まれません。
- `SlideInsertNote[]`: メモセルを挿入します (`documentation.wl` 互換、書き出しから除外)。Working では見え、SlideShow (スライドショー環境) では非表示です。
- `SlideInsertDirective[]`: 指示セルを挿入します。LLM が展開・翻訳時に厳守します。Working では見え、SlideShow では非表示です。デッキの先頭では、`Key: value` 行 (`Title:`、`SlideURL:`、`Host: sftp://user@host/dir`、`PosterURL:`、`PosterHost:`、`Language:`、`Id:`) が、`SlideTalkMeta` から読まれるデッキ単位の発表メタになります。
- `SlideInsertDictionary[]`: 翻訳の用語対応を指定する辞書セルを挿入します。
- `SlideInsertBibliography[]`: 文献セルを挿入します (`documentation.wl` 互換)。
- `SlideToggleScreenEnvironment[]`: 対象ノートブックのスクリーン環境を Working と SlideShow で切り替えます (書式メニューの「スクリーンスタイル環境」と同じです)。メモ、指示、辞書、文献、文献リスト、プロンプト、トーク、QA、読みの各セルは、Working で見え、SlideShow では非表示になります。
- `SlideTogglePrompts[]`: すべての `SlidePrompt` セルの表示/非表示を切り替えます。
- `SlideEnsureDeckStyles[nb]`: メタセル用のスタイル定義 (Note / Directive / Dictionary / Bibliography / References / SlidePrompt / SlideTalk / SlideQA / SlideReading) をデッキに埋め込みます。挿入、展開、表示切替のときに自動で呼ばれます。

シナリオやコードで使える図のヘルパーです。

- `SlideTable[rows]`: デッキ配色 (`$SlideTheme`) の表を返します。`"HeaderRows"->n` (既定 1) でヘッダー行を強調します。シナリオ md の `| a | b |` 表も同じ表になります (2 行目に `| --- | --- |` を置くと、1 行目がヘッダーになります)。
- `SlidePDFFigure[src, page]` (SourceVault が必要): PDF のページを Image として切り出します。`src` には、ファイルパス、`eagle:ID`、`sv://URI`、`src-ID`、URL、`arxiv:ID`、文献リストの key が使えます。URL、arXiv、Google Slides は、自動でダウンロードされキャッシュされます。オプションは `"Crop"`、`"Trim"` (既定 `Automatic`)、`ImageResolution` (既定 144) などです。文献 PDF の図をスライドに引用するときは、直後に `cite:` を付けます。

グラフ (知識グラフ・アウトライン) からのデッキ構築です。

- `SlideGraphSeed` は、グラフから種ノートブック (グラフのソースごとに分割した 1 つ以上) を作ります。オプションは `"Graph"` (既定 `Automatic`)、`"Title"` (既定 `Automatic`)、`"Language"` (既定 `"ja"`)、`"Notebook"`、`"Talks"`、`"Outline"`、`"Realize"` (既定 True) などです。複数ノートブックの種では、先頭のノートブックだけがタイトルを持ち、残りはそのスライド番号と ID 接頭辞を引き継ぎます。
- `SlideGraphSectionText` はグラフのノードの節の本文を返し、`SlideGraphBuildDeck[src, nbfile]` はグラフから直接デッキを構築します (`"TitleSlide"` は `SlideDeckBuild` と同じです)。逆に `SlideGraphFromSlides` は、既存のスライドからグラフを作ります。
- 知識グラフからの生成では、「生成」の前に準備段階があります。準備では、節どうしの関係づけを LLM に 1 回だけ見せて関係の辺を提案させます (自動)。そのあと「周辺知識」「図解」を整えてから「生成」へ進みます。関係づけは、同じ KG・同じ未推敲の節の集合・同じ節の集合ではこのセッションで一度しか試しません。この準備は、`$SlideGraphPrepareAuto` か `"Prepare" -> False` で省略できます。省略したときは、準備を省いてそのまま生成します。LLM がないときと、KG の作業が実行中のときは、何もしません。
- 発表の順序は、計画のスライドの並び (NodeId の初出) に従い、計画にないノードは Order の順で後ろに回されます。
- ポスター原稿 (前置き = Opening、枚ごと = Slides) は、登録簿の原稿の形へ変換されます。原稿のない枚は入りません。

QA セルの道具です。

- `SlideQAEntries[nb]` は、デッキの QA セルを返します。`SlideQAView[nb]` は、その内容を Dataset で表示します。`SlideQAStateView[nb]` は、スライドごとの状態 (未作成 / 要更新 / 最新 / 判定不能) を表示します。
- `SlideQAGenerate[nb]` は、想定問答の LLM 下書きを QA セルに書き込みます (非同期で、1 枚ずつ)。`"Mode"` は、`"Regenerate"` (全部作り直す)、`"Update"` (既存を LLM に見直させる)、`"Changed"` (既定。QA セルのないスライドと、その後に直したスライド) のいずれかです。ほかのオプションは `"QuestionsPerSlide"`、`"Vision"`、`"Slides"` です。`SlideQAGenerateAll` と `SlideQAUpdateAll` は、最初の 2 つのモードのショートカットです。生成された文章は、人が直す下書きとして扱ってください。
- `SlideQAMarkCurrent[nb]` は、LLM を呼ばず、また文面を変えずに、既存の QA セルへ現在のスライドのハッシュを刻みます。内容を確認したあとにだけ使ってください。
- `SlideQAFromPack[nb]` は、登録済みの QA パックをスライドの QA セルに書き戻します (LLM なし)。`"Rebuild"` の既定は False です。
- `SlideQABuild[nb|deck.nb]` は、QA セルを SourceVault の QA パックに焼き込み、発表中に gpt-realtime が引けるようにします。オプションは `"PrivacyLevel"`、`"Ingest"` (既定 True)、`"Enrich"` (既定 True) です。

読みの辞書 (SourceVault 推奨) です。

- `SlideReadings[]` / `SlideReadings[nb]` は、読み上げに使う読みの辞書 `<|語 -> よみ|>` を返します (全デッキ共通の読みとデッキの読みセル。同じ語はデッキ側が優先されます)。`SlideReadings["Global"]` は、共通の読みだけを返します。
- `SlideReadingApply[text]` / `SlideReadingApply[nb, text]` / `SlideReadingApply[text, readings]` は、声に渡す文を返します。数式と強調の印は外され、辞書の語は仮名に置き換えられます。置き換えるのは日本語の文だけです。長い語から置き換えられ、1 文字の語 (節など) は前後が漢字でないときだけ、英字だけの語は単語の境目でだけ置き換えられます。
- `SlideReadingFile[]` は、全デッキ共通の辞書ファイル (UTF-8 テキスト、1 行に `語 = よみ` を 1 つ) のパスを返します。なければ、よく誤読される語を入れて作成されます。既定は SourceVault の `slidedecks/readings.txt` (PC 間で共有) で、`$SlideReadingFile` で変えられます。
- `SlideReadingAdd["語" -> "よみ"]` / `SlideReadingAdd[{rules..}]` は、共通の辞書に語を足します (既存の語は読みが置き換えられます)。1 つのデッキだけの読みは、読みセルに書きます。
- `SlideReadingCheck[]` / `SlideReadingCheck[nb]` (パレットの「読みチェック」) は、原稿 (トークセル) を LLM に見せ、声に出すと読み間違えやすい語 (専門用語、同じ字で読みが変わる語、固有名詞) を、読みの案とともにデッキの読みセルへ書き足します。非同期で動き、辞書にある語は除かれます。案は確かめてから使ってください (要らない行は消すか、先頭に `#` を付けます)。

発表原稿と再生 (SourceVault が必要) です。

- 原稿: `SlideTalkFromMarkdown[md]` / `SlideTalkToMarkdown[talk]` は、発表シナリオ Markdown と連想を相互に変換します。`SlideTalkSkeleton[deck]` は LLM なしで決定的な骨格を作り、`SlideTalkPrompt[deck]` は流れのある原稿用の LLM プロンプトを返し、`SlideTalkBuild[deck]` は `<deck>_talk.md` を書き出します (正本はトークセルで、原稿のない枚は `SlideTalkFill` で埋めます)。`SlideTalkFile[deck]` は `<deck>_talk.md` のフォールバックのパスを返します。`SlideTalkMeta[nb]` は、デッキ単位のメタを読み出し、または永続化します。`SlideTalkTranslate[nb]` は、LLM で原稿を翻訳し、`SWTalkLang` を付けたトークセルとして保存するので、複数の言語を共存させられます。
- 再生: `SlidePlay[]` は、スライドを進めながら (スクリーン環境が SlideShow のとき)、原稿をローカルの声 (または `realtime:` の声) で読み上げます。`SlidePause[]` は一時停止し、`SlideStop[]` は停止して初期状態に戻し、`SlidePlayStatus[]` は状態を報告します。読み上げ時には、上記の辞書の読みが適用されます。`SlideShowSlide[spec]` は、番号、`"Next"`/`"Previous"`/`"First"`/`"Last"`、見出しや本文の語で表示スライドを変えます。`SlideTitles[]` は見出しを一覧し、`SlideCurrentNumber[]` は表示中のスライド番号を返し、`SlideSpeakSlide[n]` は n 枚目を読み上げます。
- 索引と見積り: `SlideIndex[]` は、行ごとに Show と Play のボタンがある Dataset として、発表の索引を返します。`SlideTalkDuration[]` は所要時間を見積もります (オプション `"Voice"`、`"Questions"`、`"View"`)。`SlideVoicePrepare[]` は、全スライドの音声を合成して `<deck>_voice/` にキャッシュします。`SlideInfo[]` は、情報ウインドウを開きます。
- 音声対話: `SlideToggleRealtime[]` は音声対話を切り替え、`SlideToggleMic[]` はマイクのミュート/解除を行います (`"Quiet" -> True` で通知ダイアログを抑制します)。`realtime:` の声の再生中は、`SlideToggleMic[]` が質問を受けるかどうかを切り替え (`$SlidePlayAnswering` 参照)、「対話 on/off」の表示は変えません。音声対話が動いていないときは、何もしません。
- 登録とアップロード: `SlideDeckRegister[...]` は、発表を SourceVault の登録簿に登録し、指示セルに `Host:` 行があれば Sliden 用 mp4 をアップロードします。オプションは `"SlideURL"`、`"Title"`、`"Id"`、`"DeckFile"`、`"PrivacyLevel"`、`"SlideCount"`、`"Upload"` などです。再度実行すると、与えた値だけが上書きされます (前回のエントリは Id > DeckFile > SlideURL > PosterURL の順で特定されます)。戻り値は、`RegistryStatus` (Created|Updated) と `ChangedKeys` を報告します。指示セルに `PosterURL:` 行があれば、`<deck>_poster.pdf` も配置されます (結果は `"PosterUpload"` キー。配置先は `PosterHost:`、なければ `Host:`)。登録は `SlideURL` か `PosterURL` のどちらかがあれば可能です。`SlideDeckRegistry[]` は、登録済みのエントリを一覧します。`SlideDeckUpload[...]` は、`<deck>.mp4` を sftp で送り、`SlideURL` への HEAD で配信を確認します。同じサイズがすでに配信されていれば、`"Force"->True` でない限り転送を省きます。デッキが新しければ、mp4 を書き出し直します (`"ExportVideo"` で制御)。mp4 を作り直せない場合 (別プロセスでの作り直しがオフ、またはプロセスを起動できない場合) は、古い mp4 を決してアップロードせず、理由と次の手順を添えた `Failure` を返します (第 6 章「ライセンス席のトラブルシューティング」参照)。`SlideDeckChangeStatus[nb]` は、登録でやり直される内容を報告し、`SlideDeckMarkVideoCurrent[nb]` は、既存の mp4 を現在のスライドに対して最新として記録します。後者は、見た目が本当に一致するときにだけ使ってください。

ポスター原稿 (SourceVault が必要) です。

- ポスター原稿は、ポスターを説明するための原稿で、`SlidePosterTalk` セルに書きます。その前に置いた前置き (Opening) は、最初の 1 枚目の頭になります。発表の設定 (発表の声 + 音声モデル) で読み上げられるので、たとえば QR コードから来た聞き手に対して、発表者が前に立たなくてもポスターを説明できます。
- `SlidePosterTalkFill` はポスター原稿セルに下書きを書き込み、`SlidePosterTalks` はそれを一覧し、`SlidePosterTalkDuration` は所要時間を見積もります。`SlideSetTalkMode` と `SlideSetPosterTalkMinutes` は、スライドの原稿とポスター原稿の切り替えと、目標の分数の設定を行います。`SlidePosterTalkRestyle` は、既存の原稿の文体を書き直します。
- 音声は、`<deck>_poster_talk.m4a` という 1 つのファイルになります。ローカルの声 (Piper / AivisSpeech) は、動画のナレーションと同じ方法で合成され、1 つのファイルに結合されます (音声の部分を 1 つの wav に並べてから変換します)。`gpt-realtime-*` の `realtime:` の声は、`SourceVaultRealtimeRender` を通り、再生はされません。音声エンジンが動いていなければ、声は使えず、メッセージでそれが知らされます。
- `SlidePosterUpload` は、ポスター PDF と音声を送ります。声、読みの辞書、音声キャッシュ (`<deck>_voice/`) は、読み上げ動画 (`SlideTalkVideo`) と同じです。すでに動画を作ってあれば、音声を合成し直す必要はありません。

関連する設定変数です (詳細は第 5 章)。

- `$SlideExpandMode`: `"Agent"` (既定) か `"Direct"` です。
- `$SlideTranslationLanguage`: 翻訳先言語です。日本語環境での既定は `"English"` です。
- `$SlideVisualsPerSlide` / `$SlideTalkPerSlide`: 展開プロンプトが図表と発表原稿をどこまで要求するかを切り替えます。
- `$SlideExportExternal` / `$SlideHideToolbarInSlideshow`: パレットの書き出しと画面切り替えの動作を制御します。
- `$SlidePlayAnswering` / `$SlideReadingFile`: 再生中に質問を受けるかどうかと、共有の読みの辞書の場所を制御します。

`"Agent"` モードを使うには、[ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) 経由で `ClaudeEval` を呼べる環境が必要です。インストールされていない場合や軽量にしたい場合は、`$SlideExpandMode = "Direct"` に切り替えると、`SlideExpand[]` が `NBAccess`\`$NBLLMQueryFunc` を直接呼びます (そのほかのパレット機能に外部依存はありません)。原稿の読み上げと音声対話 (`SlidePlay`、`SlideIndex`、`SlideRemoteStart` など) を使うには、[SourceVault](https://github.com/transreal/SourceVault) が必要です。