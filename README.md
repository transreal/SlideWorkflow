# SlideWorkflow

## 設計思想と実装の概要

**SlideWorkflow** は、Mathematicaのスライドノートブックを「シナリオ駆動」で構築・編集し、16:9画像やSliden(VRChat)互換mp4として安定に書き出すためのパッケージです(コンテキスト: `SlideWorkflow\``)。

### なぜシナリオ駆動なのか

発表資料の作成では、内容の推敲(何を話すか)とレイアウトの調整(どう見せるか)を分離できると効率が上がります。SlideWorkflowはこの分離を、Markdownベースの軽量な記法で実現します。`--- Title:/Event:/Author:/Date: ---` のメタブロック、`## タイトル {expected=秒}` によるスライド区切り、`- ` の箇条書き(インデントでItem/Subitem/Subsubitemの階層を表現)、`> ` の説明段落、`![w=幅pt](画像パス)` の画像挿入、`| a | b |` + 区切り行による表、`talk:` 行による発表原稿の埋め込み、`qa:` 行による想定問答(`SlideQA`セル)の埋め込みといった最小限の記法だけで、`SlideScenarioFromMarkdown` がスライド内容を連想リスト(シナリオ)に変換します。シナリオはMarkdownへ逆変換(`SlideScenarioToMarkdown`)できるため、テキストベースでの版管理やレビューとの相性も考慮されています。

### デッキ構造とコア関数の設計

生成されるノートブックは `Templates/slides-template.nb` の構造に従います。各スライドは `Cell["","SlideShowNavigationBar",CellTags->"SlideShowHeader"]` を区切りとして始まり、スライドタイトルは `"Subsection"` スタイル、本文は Item/Subitem/Subsubitem(および対応するParagraphスタイル)で構成されます。スタイルシートには既定で "Normal use.nb"(Hiragino系)を使用します。

この構造をもとに、`SlideDeckSlides` がノートブックをナビゲーションバーのセルタグを目印にプレリュード部とスライド単位のセル配列に分解する「コア関数」として位置づけられており、`SlideDeckOverview`(一覧参照)や `SlideDeckReplaceSlide`/`InsertSlide`/`DeleteSlide`/`MoveSlide`(スライド単位の編集)はすべてこのコア関数の上に構築されています。編集系関数は既定で元ファイルを `.bak` 付きで上書きしますが、`"Target"` オプションで別名保存もできるため、版を分けた編集フローにも対応します。デッキには `"SlideDeckEnd"` タグの終端マーカーを境に Appendix 領域(メモ・作業指示・辞書などを自由に置ける非書き出し領域)を持たせられ、`SlideDeckSlides` はこれを `"Appendix"` キーに分離します。`SlideDeckBuild` はこの終端マーカーの付与可否を `"EndMarker"` オプション(既定 `True`)で、生成ノートブックのウィンドウサイズを `"WindowSize"` オプション(既定 `{960, 540}`)で制御できます。

### ラスタライズの安定性へのこだわり

画像・動画書き出しは、クリップボードやウィンドウのスナップショットに依存しない設計になっている点が最大の特徴です。スライドのセル列からNotebook式を直接構成し、`ScreenStyleEnvironment->"SlideShow"` で `Rasterize` してから16:9キャンバスへ合成するため、FEセッションが裏で他の操作をしていても、あるいは `wolframscript` のheadless環境でも同じ結果が得られます。合成時には `$SlideMargins` に基づく余白処理(全面画像ページには適用しない)や、内容が高さに収まらない場合の自動リフロー・縮小(警告メッセージ付き)といった安定化ロジックが組み込まれています。書き出しに含めるInput/Codeセルの扱いは `$SlideIncludeInput`(既定`Automatic`)で一元制御でき、個別セルは`CellTags->"ShowInput"`で設定によらず常に残せます。動画書き出し(`SlideDeckExportVideo`)はSliden(VRChat)との互換性を重視し、既定では1枚あたり約1秒(30fps)・先頭スライドは29フレーム・末尾スライドを重複させるフレーム構成を採用しています。書き出したSliden用mp4は、sftp経由でのアップロード・登録(`SlideDeckUpload` / `SlideDeckRegister`)までを一連の流れとして扱えます。

さらに、発表原稿の読み上げ音声とスライド画像を合成した「読み上げ付き動画」(`SlideTalkVideo`)も作成できます。再生と共通の音声キャッシュと描画ハッシュによる再利用を行うため、途中で止めても続きから作成でき、できあがった動画は `SlideYouTubeUpload` で YouTube に限定公開としてアップロードできます。

### テーマとフォントの一元管理

`$SlideTheme` に色パレットを連想リストとして持たせ、`SlideThemeColor` 経由で参照させることで、スライド内に埋め込む図とスライド本体のデザインを統一しやすくしています。フォントは `$SlideFontFamily`(本文用、NotebookExtensionsパッケージの設定があれば自動追従)と `$SlideHeavyFontFamily`(タイトル強調用)に分離されており、環境ごとのフォント差異にも対応できるようになっています。

### インタラクティブ編集レイヤーの統合

旧 `SlideWorkflow_interactive.wl` は2026-07-13に本体 `SlideWorkflow.wl` へ統合され、個別に `Needs` する必要がなくなりました。`ShowSlidePalette[]` で開くパレットから、スライドの追加・LLMによる本文展開(`SlideExpand`)・翻訳・出典やメモなど補助セルの挿入までを対話的に行えます。発表用の操作は `ShowSlideTalkPalette[]` の発表パレット(Slideshow・再生・音声応答・カメラ・声や言語や質問の受け方の設定、読み上げ付き動画の作成とYouTubeへのアップロード)にまとまっています。既定の展開経路(`$SlideExpandMode="Agent"`)では `ClaudeEval`([ClaudeRuntime](https://github.com/transreal/ClaudeRuntime)経由)にエージェント処理を委譲し、文献検索・図生成・出典付与を行った上で、書き込みは常に決定的な `SlideApplyScenario` の一点に限定されます。これにより、LLMによる自由度の高い展開と、ノートブック構造を壊さない安全な適用とを両立させています。展開プロンプトの挙動は `$SlideVisualsPerSlide`(各スライドに図・表を要求)や `$SlideTalkPerSlide`(発表原稿を各スライド末尾に要求)で調整でき、発表原稿・音声応答・想定問答(QAパック)・手元リモコン連携は [SourceVault](https://github.com/transreal/SourceVault) と組み合わせて拡張できます。

---

## 詳細説明

### 動作環境

- **Mathematica / Wolfram Engine**: バージョン13.0以降を推奨します(Notebook式操作・`Rasterize`・`ScreenStyleEnvironment`を使用します)。
- **OS**: Windows 11を前提としています。macOS/Linuxではパス区切りやシェルコマンドを適宜読み替えてください。
- **外部ツール**:
  - `SlideDeckExportVideo` や `SlideTalkVideo` でmp4を書き出す場合、環境によってはFFmpegが必要です。未インストールの場合は事前に導入し、PATHに通しておいてください。
  - クリップボードやウィンドウスナップショットに依存しないため、headless(wolframscript)環境でも同じ結果が得られます。別プロセス(wolframscript)での書き出しにはWolframのライセンス席が必要で、席が埋まっている場合はFE内処理にフォールバックします(登録時のmp4作り直しは除く)。
  - インタラクティブ編集レイヤーの `SlideExpand[]` を既定の `$SlideExpandMode="Agent"` で使う場合は、[ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) 経由で `ClaudeEval` が呼び出せる環境が必要です。未導入でも `$SlideExpandMode = "Direct"` に切り替えれば軽量経路で動作します。
  - 発表原稿の読み上げ・リアルタイム音声応答・想定問答(QAパック)・手元リモコン連携(SlideTalk系列・`SlidePlay`・`SlideRemoteStart`など)・読み上げ付き動画の作成を使う場合は [SourceVault](https://github.com/transreal/SourceVault) が必要です。未導入でもスライド生成・画像/動画書き出しなど基本機能には影響しません。手元リモコン連携はWindows専用です。
  - Sliden用mp4(およびポスターPDF)を `SlideDeckUpload` / `SlideDeckRegister` でアップロードする場合は、sftpの接続先(Directiveセルの `Host: sftp://user@host/dir` 行)と、リモートファイルへの `CopyFile` またはsftp対応の `curl`(Git for Windows同梱のものなど)が必要です。パスワードは [NBAccess](https://github.com/transreal/NBAccess) 経由でシステムの資格情報ストアに保管されます。
- **フォント(任意)**: タイトル強調に既定で "Hiragino Kaku Gothic Std" を使用します。同フォントがない環境では `$SlideHeavyFontFamily` を手元のフォント名に上書きしてください。

### インストール

1. リポジトリを取得します。

   ```
   git clone https://github.com/transreal/SlideWorkflow.git
   ```

2. `SlideWorkflow.wl` を、他の `.wl` パッケージと同じディレクトリ(以下 `$packageDirectory`)に直接配置します。サブフォルダは作らず、フラットに置いてください。インタラクティブ編集機能(パレット等)は本体に統合済みのため、別ファイルの配置は不要です。

3. Notebook側で `$Path` に `$packageDirectory` そのものを追加します(パッケージ名のサブパスは書きません)。

   ```wolfram
   AppendTo[$Path, $packageDirectory];
   ```

   正しい例: `AppendTo[$Path, $packageDirectory]`
   誤った例: `AppendTo[$Path, "C:\\path\\to\\SlideWorkflow"]`(パッケージ専用パスは指定しないでください)

   すでにclaudecodeをお使いの場合、`$Path` は自動的に設定されるためこの手順は不要です。

4. UTF-8環境でパッケージを読み込みます。

   ```wolfram
   Block[{$CharacterEncoding = "UTF-8"},
     Needs["SlideWorkflow`", "SlideWorkflow.wl"]];
   ```

   ファイル名のみの指定(`"SlideWorkflow.wl"`)で読み込めるのは、`$packageDirectory` が `$Path` に含まれているためです。

5. (任意)[NotebookExtensions](https://github.com/transreal/NotebookExtensions) を導入すると、`NotebookExtensions\`$fontFamily` が定義されていれば `$SlideFontFamily` が自動でそれを利用します。未導入でも動作します。

6. (任意)`SlideExpand[]` を既定の `"Agent"` モードで使う場合は、[ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) を併せて導入してください。未導入の場合は `$SlideExpandMode = "Direct"` に設定すれば軽量経路で動作します。`"Direct"` モードでのLLM呼び出しやsftpパスワードの保管には [NBAccess](https://github.com/transreal/NBAccess) を使用します。

7. (任意)発表原稿のローカル音声合成・再生、リアルタイム音声応答、読み上げ付き動画、デッキ登録・QAパック、文献・PDF参照(`SlidePDFFigure`等)を使う場合は、[SourceVault](https://github.com/transreal/SourceVault) を同様に `$packageDirectory` へ配置し `Needs` で読み込んでください。音声機能は [SourceVault_voice](https://github.com/transreal/SourceVault_voice) と [SourceVault_realtime](https://github.com/transreal/SourceVault_realtime)、QAパックは [SourceVault_talkqa](https://github.com/transreal/SourceVault_talkqa) を利用します。未導入でもスライド生成・画像/動画書き出しは通常どおり動作します。

### クイックスタート

読者がこのREADMEだけでパッケージを使い始められるよう、必要な設定変数の既定値とあわせて最小の一連の流れを示します。

```wolfram
(* パッケージ読み込み *)
Block[{$CharacterEncoding = "UTF-8"},
  Needs["SlideWorkflow`", "SlideWorkflow.wl"]];

(* 主要な設定変数(既定値。必要に応じて調整) *)
$SlideImageSize = {1920, 1080};          (* 書き出し画像サイズ(px) *)
$SlideStyleDefinitions = "Normal use.nb"; (* 適用スタイルシート *)
$SlideMargins = {{100, 60}, {50, 64}};    (* 余白 {{left,right},{bottom,top}} px *)

(* 1. Markdownシナリオを書く *)
md = "--- Title: 発表タイトル Event: 研究会 Author: 今井 Date: 2026-07-13 ---
## 導入 {expected=60}
- 背景の説明
  - 従来手法の課題
> ここで簡単に補足説明を入れる";

(* 2. シナリオへ変換してデッキを生成 *)
scenario = SlideScenarioFromMarkdown[md];
nbfile = SlideDeckBuild[scenario, "presentation.nb"];

(* 3. スライド一覧を確認 *)
SlideDeckOverview[nbfile]

(* 4. 16:9画像として書き出す *)
SlideDeckExportImages[nbfile, "output/images"]

(* 5. Sliden互換のmp4として書き出す(FFmpeg必要な場合あり) *)
SlideDeckExportVideo[nbfile, "output/presentation.mp4"]
```

### 主な機能

- **シナリオ変換**: `SlideScenarioFromMarkdown` / `SlideScenarioToMarkdown` によるMarkdown⇔シナリオ連想の相互変換(ラウンドトリップ対応)。箇条書き・画像・全面画像ページに加え、表(`| a | b |` + 区切り行)、`talk:` 行による発表原稿の埋め込み、`qa:` 行による想定問答(`SlideQA`セル)の埋め込みにも対応。
- **デッキ構築**: `SlideDeckBuild` によるシナリオ(連想・Markdown文字列・`File[...]`のいずれか)からのスライドノートブック生成。終端マーカーの付与可否は`"EndMarker"`(既定`True`)、ノートブックのウィンドウサイズは`"WindowSize"`(既定`{960,540}`)で調整可能。
- **デッキ参照**: `SlideDeckSlides`(コア分解関数、Appendix領域も分離)、`SlideDeckOverview`(番号・タイトル・セル数・画像有無のDataset表示)。
- **スライド単位編集**: `SlideDeckReplaceSlide` / `SlideDeckInsertSlide` / `SlideDeckDeleteSlide` / `SlideDeckMoveSlide`。既定で`.bak`付き上書き、`"Target"`指定で別名保存可能。
- **安定した画像書き出し**: `SlideDeckImages` / `SlideDeckExportImages` によるクリップボード・ウィンドウ非依存の16:9ラスタライズ(headless環境対応)。内容が縦に収まらないスライドは `"Reflow"` オプション(既定 `True`、上限は`"MaxWindowWidth"`)により折返し幅を自動探索し、余白を抑えて縮小率を最小化する。書き出しに含めるInput/Codeセルは `$SlideIncludeInput`(既定`Automatic`、ノートブックの表示どおり)で制御でき、個別セルは`CellTags->"ShowInput"`で常に残せる。
- **動画書き出し・アップロード**: `SlideDeckExportVideo` によるSliden(VRChat)互換mp4の生成(表示秒数のカスタマイズ可)。パレットからの書き出しは `$SlideExportExternal`(既定`Automatic`)で別プロセス(wolframscript)実行とFE内処理を自動フォールバック切り替え(登録時のmp4作り直しはフォールバックせず、毎回別プロセスの起動を試し、失敗時はライセンス席に関する案内を表示)。生成したmp4(およびポスターPDF)はsftp経由で `SlideDeckUpload` / `SlideDeckRegister` により公開・登録でき、パスワードは `SlideUploadCredential` / `SlideUploadCredentialQ` で資格情報ストアに保管・確認・削除できる。
- **読み上げ付き動画とYouTube公開**: `SlideTalkVideo` が、発表で選んだ声(ローカル音声合成またはリアルタイム音声)で原稿を読み上げた音声とスライド画像を合成し、`<デッキ>_narrated.mp4` を作成する。リアルタイム音声は再生せずに音声ファイルへ書き出して高速に作成でき(並列数は`$SlideTalkVideoParallel`)、実時間でしか話さないモデルでは実時間録音も選べる。音声・画像はキャッシュされ、中断しても続きから再開できる。作成した動画は `SlideYouTubeUpload` でYouTubeに限定公開としてアップロードできる(いずれも発表パレットの「動画」節から操作可能。SourceVault併用)。
- **テーマ管理**: `$SlideTheme` / `SlideThemeColor` によるスライド・図の配色統一。
- **補助セル・出典・文献**: `"Note"`/`"Directive"`/`"Dictionary"`/`"Bibliography"`/`"References"`/`"SlidePrompt"`/`"SlideTalk"`/`"SlideQA"` の各メタセル(書き出し除外)と、出典明記用のCitationセルに対応。`SlideInsertReferences` で文献リストセルを挿入し、`SlidePDFFigure` でPDFページを図として切り出せる。図・コードセルは `<<FIGn>>` トークンで再展開時にも保持できる。
- **インタラクティブ編集(統合パレット)**: `ShowSlidePalette` から、スライド追加(`SlideAddSlide`)・LLMによる展開(`SlideExpand`、決定的な適用口として`SlideApplyScenario`)・翻訳(`SlideTranslate`/`SlideTranslateRevert`/`SlideTranslateDeck`)・各種補助セルの挿入をまとめて行える。`$SlideExpandMode`(既定`"Agent"`、軽量な`"Direct"`も選択可)、`$SlideTranslationLanguage`、`$SlideVisualsPerSlide`(図表の自動付与)、`$SlideTalkPerSlide`(発表原稿の自動生成)、`$SlideHideToolbarInSlideshow`(SlideShow切替時のツールバー退避)で挙動を調整。パレットは`"Safe"->True`でClaudeCodeなど外部エージェントの処理に完全に非干渉なモードでも開け(フリーズ時の切り分け用)、現在のバージョンは`$SlideWorkflowInteractiveVersion`で確認できる。
- **発表パレット**: `ShowSlideTalkPalette` で、Slideshow・再生・音声応答・カメラ・声や言語や質問の受け方の設定・動画作成とYouTubeアップロードをまとめて操作できる(作成パレットからも開ける)。
- **発表原稿・音声・想定問答・リモコン連携(SourceVault併用)**: `SlideTalk`系のローカル音声合成・再生、リアルタイム音声応答、想定問答(QAパック)、手元デバイス(メディアキー)によるリモート操作(`SlidePlay`・`SlideRemoteStart`など、Windows専用)。未導入でもスライド生成・画像/動画書き出しには影響しません。

### ドキュメント一覧

- [API リファレンス](SlideWorkflow_info/docs/api.md) — 全公開関数・定数の仕様
- [使用例集](example.md) — 実践的なコード例
- [セットアップ手順書](SlideWorkflow_info/docs/setup.md) — 導入・動作確認の詳細手順
- [ユーザーマニュアル](SlideWorkflow_info/docs/user_manual.md) — 機能別の詳しい使い方(インタラクティブ編集レイヤーの詳細を含む)

## 使用例・デモ

上記「クイックスタート」の一連の流れが基本的な使用例です。さらに詳しい例(スライドの差し替え・挿入・削除・移動、テーマカラーの取得など)は [example.md](example.md) を参照してください。インタラクティブ編集レイヤー(パレット・`SlideExpand`・翻訳・発表原稿/音声/リモコン連携・読み上げ付き動画)の使用例は [user_manual.md](SlideWorkflow_info/docs/user_manual.md) にまとめています。

### 動画

- [SlideWorkflowの使い方デモ](https://www.youtube.com/watch?v=romv4EEPnWw) — パッケージの操作を実際に動かして紹介する動画です。

---

## 免責事項

本ソフトウェアは "as is"（現状有姿）で提供されており、明示・黙示を問わずいかなる保証もありません。
本ソフトウェアの使用または使用不能から生じるいかなる損害についても責任を負いません。
今後の動作保証のための更新が行われるとは限りません。
本ソフトウェアとドキュメントはほぼすべてが生成AIによって生成されたものです。
Windows 11上での実行を想定しており、MacOS, LinuxのMathematicaでの動作検証は一切していません(生成AIの処理で対応可能と想定されます)。

---

## ライセンス

```
MIT License

Copyright (c) 2026 Katsunobu Imai

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
