# SlideWorkflow 使用例集

このドキュメントでは `SlideWorkflow` パッケージの主要な使い方を、実践的なコード例で紹介します。各関数の詳細な仕様はマニュアルを参照してください。

```mathematica
Needs["SlideWorkflow`"]
```

## 1. Markdownシナリオからスライドノートブックを生成する

```mathematica
md = "--- Title: 発表タイトル Event: 研究会 Author: 今井 Date: 2026-07-13 ---
## 導入 {expected=60}
- 背景の説明
  - 従来手法の課題
> ここで簡単に補足説明を入れる";
scenario = SlideScenarioFromMarkdown[md];
SlideDeckBuild[scenario, "presentation.nb"]
```
出力: `"presentation.nb"`

## 2. シナリオ連想をMarkdownへ戻す

```mathematica
SlideScenarioToMarkdown[scenario]
```
出力: `"--- Title: 発表タイトル ..."` のMarkdown文字列

## 3. デッキ内のスライド一覧を確認する

```mathematica
SlideDeckOverview["presentation.nb"]
```
出力: 番号・タイトル・セル数・画像有無を含む `Dataset`

## 4. 指定スライドを差し替える

```mathematica
newSlide = SlideScenarioFromMarkdown["## 更新後のタイトル {expected=45}
- 新しい内容"];
SlideDeckReplaceSlide["presentation.nb", 3, newSlide,
  "Target" -> "presentation_v2.nb"]
```
出力: `"presentation_v2.nb"`

## 5. スライドを挿入・削除・移動する

```mathematica
SlideDeckInsertSlide["presentation.nb", 2, newSlide];
SlideDeckDeleteSlide["presentation.nb", 5];
SlideDeckMoveSlide["presentation.nb", 4, 1]
```
出力: 更新後のノートブックファイルパス

## 6. 全スライドを16:9画像リストとして生成する

```mathematica
images = SlideDeckImages["presentation.nb",
  "Slides" -> All, "Verbose" -> False]
```
出力: `{Image[...], Image[...], ...}`(各1920×1080)

## 7. スライド画像をファイルへ書き出す

```mathematica
SlideDeckExportImages["presentation.nb", "output/images"]
```
出力: `{"output/images/01.png", "output/images/02.png", ...}`

## 8. Sliden互換のmp4動画を書き出す

```mathematica
SlideDeckExportVideo["presentation.nb", "output/presentation.mp4",
  "Durations" -> {8, 12, 10}]
```
出力: `"output/presentation.mp4"`

## 9. テーマカラーを取得する

```mathematica
SlideThemeColor["Accent"]
SlideThemeColor[]
```
出力: `RGBColor[...]` および色名一覧の `Dataset`