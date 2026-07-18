# SlideWorkflow セットアップ手順書

## 1. 前提条件

- **Mathematica / Wolfram Engine**: バージョン 13.0 以降を推奨します(Notebook 式操作・`Rasterize`・`ScreenStyleEnvironment` を使用します)。
- **OS**: Windows 11 を前提とします。macOS/Linux ではパス区切りやシェルコマンドを適宜読み替えてください。
- **外部ツール**:
  - `SlideDeckExportVideo` で mp4 を書き出す場合、環境によっては FFmpeg が必要です。未インストールの場合は事前に導入し、PATH に通しておいてください。
  - クリップボードやウィンドウスナップショットには依存していないため、headless(wolframscript)環境でも同じ結果が得られます。
  - インタラクティブ編集レイヤーの `SlideExpand[]` を既定の `$SlideExpandMode="Agent"` で使う場合は、[ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) 経由で `ClaudeEval` が呼び出せる環境が必要です。未導入でも `$SlideExpandMode = "Direct"` に切り替えれば動作します(詳細は 7 章)。
- **フォント**(任意): タイトル強調に既定で "Hiragino Kaku Gothic Std" を使用します。Windows 環境で同フォントがない場合は `$SlideHeavyFontFamily` を手元のフォント名に上書きしてください。

## 2. インストール手順

1. リポジトリを取得します。

   ```
   git clone https://github.com/transreal/SlideWorkflow.git
   ```

2. `SlideWorkflow.wl` を、他の `.wl` パッケージと同じディレクトリ(以下 `$packageDirectory`)に直接配置します。サブフォルダは作らず、フラットに置いてください。

3. Notebook 側で `$Path` に `$packageDirectory` を追加します(パッケージ名のサブパスは書きません)。

   ```wolfram
   AppendTo[$Path, $packageDirectory];
   ```

   すでに claudecode をお使いの場合、`$Path` は自動的に設定されるためこの手順は不要です。

4. UTF-8 環境でパッケージを読み込みます。

   ```wolfram
   Block[{$CharacterEncoding = "UTF-8"},
     Needs["SlideWorkflow`", "SlideWorkflow.wl"]];
   ```

   ファイル名のみの指定で読み込めるのは、`$packageDirectory` が `$Path` に含まれているためです。

   なお、旧 `SlideWorkflow_interactive.wl`(パレット・スライド展開・翻訳などの対話編集機能)は 2026-07-13 に `SlideWorkflow.wl` 本体へ統合されました。個別に `Needs` する必要はありません。

## 3. 依存パッケージ(任意)

- [NotebookExtensions](https://github.com/transreal/NotebookExtensions): `NotebookExtensions`$fontFamily` が定義されていれば `$SlideFontFamily` が自動でそれを利用します。未導入でも動作しますが、フォント統一のため導入を推奨します。導入する場合も同様に `$packageDirectory` へ直接配置し、`Needs` で読み込んでください。
- [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime): `SlideExpand[]` を既定の `"Agent"` モードで使う場合に必要です(`ClaudeEval` の実行経路)。使わない場合は `$SlideExpandMode = "Direct"` に設定してください。

## 4. APIキー設定

SlideWorkflow はローカルの Notebook 操作と画像/動画書き出しのみを行うパッケージで、外部 API キーは使用しません。設定は不要です。`SlideExpand[]` の `"Agent"` モードを使う場合の認証・承認ゲートは `ClaudeRuntime`/`ClaudeEval` 側の設定に従います。

## 5. 基本設定変数(必要に応じて調整)

```wolfram
$SlideImageSize = {1920, 1080};
$SlideStyleDefinitions = "Normal use.nb";
$SlideMargins = {{0, 0}, {0, 0}};
$SlideExpandMode = "Agent";
$SlideTranslationLanguage = "English";
```

- `$SlideTheme`: 図の配色を統一したい場合に使う色パレットの連想配列です。
- `$SlideStyleDefinitions`: デッキ生成に使うスタイルシート名です。既定は `Templates/slides-template.nb` に準拠した "Normal use.nb" です。
- `$SlideExpandMode`: `SlideExpand[]` の実行経路。既定 `"Agent"`(`ClaudeEval`/`ClaudeRuntime` 経由、文献検索・図生成・承認ゲート付きで複雑な処理が可能)、または軽量な `"Direct"`(`NBAccess`\`$NBLLMQueryFunc` を直接呼ぶ)。
- `$SlideTranslationLanguage`: `SlideTranslate[]`/`SlideTranslateDeck[]` の翻訳先言語。既定は日本語環境なら `"English"`。

## 6. 動作確認

1. パッケージが読み込めているか確認します。

   ```wolfram
   ?SlideDeckBuild
   ```

   使用方法(usage)メッセージが表示されれば読み込み成功です。

2. サンプルシナリオからデッキを生成してみます。

   ```wolfram
   md = "--- Title: Test / Event: Demo / Author: Imai / Date: 2026-07-13 ---\n## Slide1 {expected=30}\n- Hello";
   scenario = SlideScenarioFromMarkdown[md];
   nbfile = SlideDeckBuild[scenario, FileNameJoin[{$TemporaryDirectory, "test-slides.nb"}]];
   ```

   エラーなくファイルパスが返れば正常です。

3. 生成したデッキの概要とサムネイルを確認します。

   ```wolfram
   SlideDeckOverview[nbfile]
   SlideDeckImages[nbfile]
   ```

   Dataset と 16:9 の画像リストが得られれば、インストールとセットアップは完了です。

4. mp4 書き出しを利用する場合は、以下も確認してください。

   ```wolfram
   SlideDeckExportVideo[nbfile, FileNameJoin[{$TemporaryDirectory, "test.mp4"}]]
   ```

   ファイルが生成されない場合は、FFmpeg のインストールと PATH 設定を見直してください。

5. インタラクティブ編集レイヤーを使う場合は、パレットが開けることを確認します。

   ```wolfram
   ShowSlidePalette[]
   ```

   パレットが表示され、`?SlideAddSlide` などで usage メッセージが表示されれば、統合済みの対話編集機能も利用可能です。

## 7. インタラクティブ編集レイヤー(パレット)

`SlideWorkflow` には、スライド Notebook 上で対話的に編集を行うためのパレット機能が統合されています(旧 `SlideWorkflow_interactive.wl`、2026-07-13 に本体へ統合)。

```wolfram
ShowSlidePalette[]
```

でパレットを表示します。`"Safe"->True` を指定すると、ClaudeCode から完全に非干渉な状態でパレットを開けます(フリーズ切り分け用)。現在のバージョンは `$SlideWorkflowInteractiveVersion` で確認できます。

主なパレット操作(いずれもスライド Notebook 上のセル選択位置に対して動作します):

- `SlideAddSlide[]`: 現在のスライド直後に新規スライド骨格(navbar+タイトル+プロンプトセル)を挿入する。
- `SlideExpand[]`: 選択中の `SlidePrompt` セル(なければ選択セルの本文)を指示として、スライドを展開・更新する。既定(`$SlideExpandMode="Agent"`)では `ClaudeEval`(`ClaudeRuntime` 経由、文献検索・図生成・承認ゲート付き)に処理を委譲し、エージェントが最後に `SlideApplyScenario` を呼んで適用する。指示(Directive)・辞書(Dictionary)セルは厳守され、既存の図・コードセルは `<<FIGn>>` トークンで保持される。
- `SlideApplyScenario[slideNo, md]`: シナリオ Markdown で対象スライドを差し替える決定的適用関数(展開エージェントの唯一の書き込み口)。`md` は複数 `##` 可(複数枚展開)。`<<FIGn>>` は既存図・コードセル(n=1..k)または `"Figures"` オプションで渡した新規図(Graphics/Image、n=k+1..)に対応する。適用成功時 `Success`、失敗時 `Failure` を返す。
- `SlideTranslate[]` / `SlideTranslateRevert[]` / `SlideTranslateDeck[]`: 現在のスライド(またはデッキ全体)のテキストセルを `$SlideTranslationLanguage` へ一括翻訳・原文復帰する。原文は `TaggingRules "SWOrigText"` に保存される。
- `SlideInsertPrompt[]`: カーソル位置に `SlidePrompt` セルを挿入する(ラスタライズからは除外される)。
- `SlideInsertCitation[]`: カーソル位置に出典セル(小フォント)を挿入する。図・引用の直後に置き、URL または (著者, 年) を記入する。
- `SlideInsertEndMarker[]`: カーソル位置にスライド終端マーカーを挿入する。以降のセルはスライド・書き出しに含まれない。
- `SlideInsertNote[]`: メモセルを挿入する(`documentation.wl` 互換、書き出し除外)。
- `SlideInsertDirective[]`: 指示セルを挿入する。展開・翻訳時に LLM が厳守する。
- `SlideInsertDictionary[]`: 辞書セルを挿入する。翻訳時の用語対応を指定する。
- `SlideInsertBibliography[]`: 文献セルを挿入する(`documentation.wl` 互換)。
- `SlideTogglePrompts[]`: 全 `SlidePrompt` セルの表示/非表示を切り替える。

関連する設定変数(詳細は 5 章):

- `$SlideExpandMode`: `"Agent"`(既定)または `"Direct"`。
- `$SlideTranslationLanguage`: 翻訳先言語。既定は日本語環境なら `"English"`。

`"Agent"` モードを使う場合は [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) 経由で `ClaudeEval` が呼び出せる環境が必要です。未導入・軽量に使いたい場合は `$SlideExpandMode = "Direct"` に切り替えれば `SlideExpand[]` は `NBAccess`\`$NBLLMQueryFunc` を直接呼ぶ経路で動作します(パレットのその他の機能に外部依存はありません)。