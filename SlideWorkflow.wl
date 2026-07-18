(* ::Package:: *)

(* :Title: SlideWorkflow *)
(* :Author: Katsunobu Imai *)
(* :Summary: Scenario-driven slide deck construction, editing, and stable 16:9 image/video export for Mathematica slide notebooks *)
(* :Context: SlideWorkflow` *)
(* :Package Version: 1.0 *)

(*
  \:30b9\:30e9\:30a4\:30c9\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e3\:30ef\:30fc\:30af\:30d5\:30ed\:30fc\:3092\:63d0\:4f9b\:3059\:308b\:3002
    1. \:30b7\:30ca\:30ea\:30aa(Markdown / \:9023\:60f3\:30ea\:30b9\:30c8) \:2192 \:30b9\:30e9\:30a4\:30c9\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:751f\:6210
       SlideScenarioFromMarkdown / SlideDeckBuild
    2. \:65e2\:5b58\:30c7\:30c3\:30ad\:306e\:30b9\:30e9\:30a4\:30c9\:5358\:4f4d\:66f4\:65b0\:30fb\:5225\:30d0\:30fc\:30b8\:30e7\:30f3\:751f\:6210
       SlideDeckSlides / SlideDeckOverview / SlideDeckReplaceSlide /
       SlideDeckInsertSlide / SlideDeckDeleteSlide / SlideDeckMoveSlide
    3. 16:9 \:753b\:50cf\:30ea\:30b9\:30c8 / Sliden \:7528 mp4 \:3078\:306e\:5b89\:5b9a\:66f8\:304d\:51fa\:3057
       SlideDeckImages / SlideDeckExportImages / SlideDeckExportVideo

  \:30c7\:30c3\:30ad\:69cb\:9020\:306f Templates/slides-template.nb \:306b\:5f93\:3046:
    \:30b9\:30e9\:30a4\:30c9 = Cell["","SlideShowNavigationBar",CellTags->"SlideShowHeader"] \:533a\:5207\:308a\:3001
    \:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb = "Subsection"\:3001\:7b87\:6761\:66f8\:304d = Item/Subitem/Subsubitem(+Paragraph)\:3002
    \:30b9\:30bf\:30a4\:30eb\:30b7\:30fc\:30c8\:306f "Normal use.nb"(Hiragino \:7cfb)\:3002

  \:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:306f\:30a6\:30a3\:30f3\:30c9\:30a6\:306e\:30b9\:30ca\:30c3\:30d7\:30b7\:30e7\:30c3\:30c8\:3082\:30af\:30ea\:30c3\:30d7\:30dc\:30fc\:30c9\:3082\:4f7f\:308f\:306a\:3044:
  \:30b9\:30e9\:30a4\:30c9\:306e\:30bb\:30eb\:5217\:304b\:3089 Notebook \:5f0f\:3092\:69cb\:6210\:3057 ScreenStyleEnvironment->"SlideShow"
  \:3067 Rasterize \:3057\:300116:9 \:30ad\:30e3\:30f3\:30d0\:30b9\:3078\:5408\:6210\:3059\:308b\:3002FE \:30bb\:30c3\:30b7\:30e7\:30f3\:3067\:3082 headless
  (wolframscript + UsingFrontEnd) \:3067\:3082\:540c\:3058\:7d50\:679c\:3092\:8fd4\:3059\:3002
*)

BeginPackage["SlideWorkflow`"]

(* --- Exported $-constants --- *)

$SlideFontFamily::usage = "$SlideFontFamily \:672c\:6587/\:30bf\:30a4\:30c8\:30eb\:306e\:6a19\:6e96\:30d5\:30a9\:30f3\:30c8\:3002NotebookExtensions`$fontFamily \:307e\:305f\:306f Global`$fontFamily \:304c\:5b9a\:7fa9\:3055\:308c\:3066\:3044\:308c\:3070\:305d\:308c\:3092\:4f7f\:3046\:3002";
$SlideHeavyFontFamily::usage = "$SlideHeavyFontFamily \:30bf\:30a4\:30c8\:30eb\:30b9\:30e9\:30a4\:30c9\:306a\:3069\:5f37\:8abf\:7528\:306e\:30d5\:30a9\:30f3\:30c8(\:65e2\:5b9a \"Hiragino Kaku Gothic Std\")\:3002";
$SlideStyleDefinitions::usage = "$SlideStyleDefinitions \:30c7\:30c3\:30ad\:751f\:6210\:30fb\:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:306b\:4f7f\:3046\:30b9\:30bf\:30a4\:30eb\:30b7\:30fc\:30c8\:540d(\:65e2\:5b9a \"Normal use.nb\")\:3002";
$SlideImageSize::usage = "$SlideImageSize \:66f8\:304d\:51fa\:3057\:753b\:50cf\:306e {\:5e45, \:9ad8\:3055}(\:65e2\:5b9a {1920,1080})\:3002";
$SlideTheme::usage = "$SlideTheme \:30b9\:30e9\:30a4\:30c9\:306e\:30c7\:30b6\:30a4\:30f3\:30c8\:30fc\:30af\:30f3(\:8272)\:306e\:9023\:60f3\:3002\:56f3\:306e\:751f\:6210\:6642\:306b\:3053\:306e\:30d1\:30ec\:30c3\:30c8\:3092\:4f7f\:3046\:3068\:7d71\:4e00\:611f\:304c\:51fa\:308b\:3002";
$SlideMargins::usage = "$SlideMargins \:30b9\:30e9\:30a4\:30c9\:4f59\:767d\:306e\:65e2\:5b9a {{left,right},{bottom,top}} (px)\:3002SlideDeckImages \:306e \"Margins\"->Automatic \:3067\:4f7f\:308f\:308c\:308b\:3002\:5168\:9762\:753b\:50cf\:30da\:30fc\:30b8\:306b\:306f\:9069\:7528\:3055\:308c\:306a\:3044\:3002";

(* --- Exported functions --- *)

SlideThemeColor::usage = "SlideThemeColor[name] $SlideTheme \:306e\:8272\:3092\:8fd4\:3059\:3002SlideThemeColor[] \:3067\:4e00\:89a7\:306e Dataset\:3002";
SlideScenarioFromMarkdown::usage = "SlideScenarioFromMarkdown[md] Markdown \:6587\:5b57\:5217(\:307e\:305f\:306f File[...])\:3092\:30b7\:30ca\:30ea\:30aa\:9023\:60f3\:306b\:5909\:63db\:3059\:308b\:3002\:66f8\:5f0f: \:5148\:982d\:306b --- Title:/Event:/Author:/Date: --- \:306e\:30e1\:30bf\:3001\"## \:30bf\:30a4\:30c8\:30eb {expected=\:79d2}\" \:30671\:30b9\:30e9\:30a4\:30c9\:3001\"- \"(\:30a4\:30f3\:30c7\:30f3\:30c82/4\:3067Subitem/Subsubitem)\:3001\"> \:8aac\:660e\:6bb5\:843d\"\:3001\"![w=\:5e45pt](\:753b\:50cf\:30d1\:30b9)\"\:3001\"## !image \:30d1\:30b9\" \:3067\:5168\:9762\:753b\:50cf\:30da\:30fc\:30b8\:3002";
SlideScenarioToMarkdown::usage = "SlideScenarioToMarkdown[scenario] \:30b7\:30ca\:30ea\:30aa\:9023\:60f3\:3092 Markdown \:6587\:5b57\:5217\:306b\:623b\:3059(\:30e9\:30a6\:30f3\:30c9\:30c8\:30ea\:30c3\:30d7\:7528)\:3002";
SlideDeckBuild::usage = "SlideDeckBuild[scenario, nbfile] \:30b7\:30ca\:30ea\:30aa(\:9023\:60f3 / Markdown \:6587\:5b57\:5217 / File[md]) \:304b\:3089\:30b9\:30e9\:30a4\:30c9\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:751f\:6210\:3057\:3066 nbfile \:306b\:4fdd\:5b58\:3057\:3001\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9\:3092\:8fd4\:3059\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"TitleSlide\"->True, StyleDefinitions->$SlideStyleDefinitions\:3002";
SlideDeckSlides::usage = "SlideDeckSlides[nbfile] \:30c7\:30c3\:30ad\:3092 <|\"Prelude\"->{cells}, \"Slides\"->{{cells}..}, \"Options\"->{...}|> \:306b\:5206\:89e3\:3057\:3066\:8fd4\:3059(\:30b3\:30a2\:95a2\:6570)\:3002";
SlideDeckOverview::usage = "SlideDeckOverview[nbfile] \:30b9\:30e9\:30a4\:30c9\:4e00\:89a7(\:756a\:53f7/\:30bf\:30a4\:30c8\:30eb/\:30bb\:30eb\:6570/\:753b\:50cf\:6709\:7121)\:306e Dataset \:3092\:8fd4\:3059(View \:95a2\:6570)\:3002";
SlideDeckReplaceSlide::usage = "SlideDeckReplaceSlide[nbfile, n, slide] n \:679a\:76ee\:3092\:30b7\:30ca\:30ea\:30aa\:5f62\:5f0f\:306e\:30b9\:30e9\:30a4\:30c9\:9023\:60f3(\:307e\:305f\:306f\:30bb\:30eb\:306e\:30ea\:30b9\:30c8)\:3067\:5dee\:3057\:66ff\:3048\:308b\:3002\:30aa\:30d7\:30b7\:30e7\:30f3 \"Target\"->\:51fa\:529b\:30d1\:30b9(\:7701\:7565\:6642\:306f\:5143\:30d5\:30a1\:30a4\:30eb\:3092 .bak \:4ed8\:304d\:3067\:4e0a\:66f8\:304d)\:3002";
SlideDeckInsertSlide::usage = "SlideDeckInsertSlide[nbfile, n, slide] n \:679a\:76ee\:306e\:4f4d\:7f6e\:306b\:30b9\:30e9\:30a4\:30c9\:3092\:633f\:5165\:3059\:308b(n=Length+1 \:3067\:672b\:5c3e)\:3002\:30aa\:30d7\:30b7\:30e7\:30f3\:306f SlideDeckReplaceSlide \:3068\:540c\:3058\:3002";
SlideDeckDeleteSlide::usage = "SlideDeckDeleteSlide[nbfile, n] n \:679a\:76ee(\:30ea\:30b9\:30c8\:53ef)\:3092\:524a\:9664\:3059\:308b\:3002";
SlideDeckMoveSlide::usage = "SlideDeckMoveSlide[nbfile, n, m] n \:679a\:76ee\:3092 m \:756a\:76ee\:3078\:79fb\:52d5\:3059\:308b\:3002";
SlideDeckImages::usage = "SlideDeckImages[nbfile] \:5168\:30b9\:30e9\:30a4\:30c9\:3092 16:9 \:753b\:50cf\:30ea\:30b9\:30c8\:3068\:3057\:3066\:5b89\:5b9a\:306b\:751f\:6210\:3059\:308b(\:30af\:30ea\:30c3\:30d7\:30dc\:30fc\:30c9/\:30a6\:30a3\:30f3\:30c9\:30a6\:975e\:4f9d\:5b58)\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: ImageSize->$SlideImageSize, \"Slides\"->All|\:7bc4\:56f2, \"Environment\"->\"SlideShow\", \"WindowWidth\"->960, \"IncludeInput\"->Automatic, \"Verbose\"->False, \"Margins\"->Automatic($SlideMargins, {{left,right},{bottom,top}} px)\:3002";
SlideDeckExportImages::usage = "SlideDeckExportImages[nbfile] / SlideDeckExportImages[nbfile, dir] \:5404\:30b9\:30e9\:30a4\:30c9\:3092 dir/01.png.. \:3068\:3057\:3066\:66f8\:304d\:51fa\:3057\:30d1\:30b9\:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\:30aa\:30d7\:30b7\:30e7\:30f3\:306f SlideDeckImages \:3068\:540c\:3058\:3002";
SlideDeckExportVideo::usage = "SlideDeckExportVideo[nbfile|images, mp4file] Sliden(VRChat) \:4e92\:63db\:306e mp4(30fps, 1\:679a\:22521\:79d2, \:5148\:982d29\:30d5\:30ec\:30fc\:30e0+\:672b\:5c3e\:30b9\:30e9\:30a4\:30c9\:91cd\:8907)\:3092\:66f8\:304d\:51fa\:3059\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Durations\"->Automatic|\:79d2\:30ea\:30b9\:30c8, FrameRate->30\:3002";

(* --- Interactive layer (\:65e7 SlideWorkflow_interactive.wl, 2026-07-13 \:7d71\:5408) --- *)

ShowSlidePalette::usage = "ShowSlidePalette[] \:306f\:30b9\:30e9\:30a4\:30c9\:4f5c\:6210\:7528\:30d1\:30ec\:30c3\:30c8\:3092\:8868\:793a\:3059\:308b\:3002\"Safe\"->True \:3067 ClaudeCode \:5b8c\:5168\:975e\:5e72\:6e09(\:30d5\:30ea\:30fc\:30ba\:5207\:308a\:5206\:3051\:7528)\:3002";
$SlideWorkflowInteractiveVersion::usage = "$SlideWorkflowInteractiveVersion interactive \:30ec\:30a4\:30e4\:30fc\:306e\:7248\:3002";
SlideAddSlide::usage = "SlideAddSlide[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:76f4\:5f8c\:306b\:65b0\:898f\:30b9\:30e9\:30a4\:30c9\:9aa8\:683c(navbar+\:30bf\:30a4\:30c8\:30eb+\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb)\:3092\:633f\:5165\:3059\:308b\:3002";
SlideExpand::usage = "SlideExpand[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e SlidePrompt \:30bb\:30eb(\:7121\:3051\:308c\:3070\:9078\:629e\:30bb\:30eb\:306e\:672c\:6587)\:3092\:6307\:793a\:3068\:3057\:3066\:30b9\:30e9\:30a4\:30c9\:3092\:5c55\:958b\:30fb\:66f4\:65b0\:3059\:308b\:3002\:65e2\:5b9a($SlideExpandMode=\"Agent\")\:3067\:306f ClaudeEval(ClaudeRuntime \:7d4c\:7531\:3001\:6587\:732e\:691c\:7d22\:30fb\:56f3\:751f\:6210\:30fb\:627f\:8a8d\:30b2\:30fc\:30c8\:4ed8\:304d)\:306b\:59d4\:8b72\:3057\:3001\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c\:6700\:5f8c\:306b SlideApplyScenario \:3092\:547c\:3093\:3067\:9069\:7528\:3059\:308b\:3002\:8ffd\:8de1\:30bb\:30eb\:306f\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d(Appendix)\:306b\:7f6e\:304b\:308c\:308b\:3002\:6307\:793a(Directive)\:30fb\:8f9e\:66f8(Dictionary)\:30bb\:30eb\:3092\:53b3\:5b88\:3057\:3001\:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:306f <<FIGn>> \:30c8\:30fc\:30af\:30f3\:3067\:4fdd\:6301\:3055\:308c\:308b\:3002";
SlideApplyScenario::usage = "SlideApplyScenario[slideNo, md] \:306f\:30b7\:30ca\:30ea\:30aa Markdown \:3067\:5bfe\:8c61\:30b9\:30e9\:30a4\:30c9\:3092\:5dee\:3057\:66ff\:3048\:308b\:6c7a\:5b9a\:7684\:9069\:7528\:95a2\:6570(\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306e\:552f\:4e00\:306e\:66f8\:8fbc\:307f\:53e3)\:3002md \:306b\:8907\:6570 ## \:53ef(\:8907\:6570\:679a\:5c55\:958b)\:3002<<FIGn>> \:306f n=1..k \:304c\:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:3001n=k+1.. \:304c \"Figures\" \:30aa\:30d7\:30b7\:30e7\:30f3\:3067\:6e21\:3057\:305f\:65b0\:898f\:56f3(Graphics/Image)\:3002SlidePrompt \:30bb\:30eb\:306f\:81ea\:52d5\:3067\:5148\:982d\:30b9\:30e9\:30a4\:30c9\:306b\:623b\:3055\:308c\:308b\:3002\:6210\:529f\:6642 Success\:3001\:5931\:6557\:6642 Failure \:3092\:8fd4\:3059\:3002";
$SlideExpandMode::usage = "$SlideExpandMode \:5c55\:958b\:306e\:5b9f\:884c\:7d4c\:8def\:3002\"Agent\"(\:65e2\:5b9a: ClaudeEval/ClaudeRuntime \:7d4c\:7531\:3001\:8907\:96d1\:51e6\:7406\:53ef) | \"Direct\"(\:8efd\:91cf: NBAccess`$NBLLMQueryFunc \:76f4\:63a5)\:3002";
SlideTranslate::usage = "SlideTranslate[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:30c6\:30ad\:30b9\:30c8\:30bb\:30eb\:3092 $SlideTranslationLanguage \:3078\:4e00\:62ec\:7ffb\:8a33\:3059\:308b(\:8f9e\:66f8\:53b3\:5b88)\:3002\:539f\:6587\:306f TaggingRules \"SWOrigText\" \:306b\:4fdd\:5b58\:3055\:308c\:308b\:3002";
SlideTranslateRevert::usage = "SlideTranslateRevert[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:7ffb\:8a33\:3092\:539f\:6587\:306b\:623b\:3059\:3002";
SlideTranslateDeck::usage = "SlideTranslateDeck[] \:306f\:5168\:30b9\:30e9\:30a4\:30c9\:3092\:9806\:306b\:7ffb\:8a33\:3059\:308b(\:975e\:540c\:671f\:9023\:9396)\:3002";
SlideInsertPrompt::usage = "SlideInsertPrompt[] \:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b SlidePrompt \:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(\:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:304b\:3089\:306f\:9664\:5916\:3055\:308c\:308b)\:3002";
SlideInsertCitation::usage = "SlideInsertCitation[] \:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b\:51fa\:5178\:30bb\:30eb(\:5c0f\:30d5\:30a9\:30f3\:30c8)\:3092\:633f\:5165\:3059\:308b\:3002\:56f3\:30fb\:5f15\:7528\:306e\:76f4\:5f8c\:306b\:7f6e\:304d\:3001URL \:307e\:305f\:306f (\:8457\:8005, \:5e74) \:3092\:8a18\:5165\:3059\:308b\:3002";
SlideInsertEndMarker::usage = "SlideInsertEndMarker[] \:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b\:30b9\:30e9\:30a4\:30c9\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:3092\:633f\:5165\:3059\:308b\:3002\:4ee5\:964d\:306e\:30bb\:30eb\:306f\:30b9\:30e9\:30a4\:30c9\:30fb\:66f8\:304d\:51fa\:3057\:306b\:542b\:307e\:308c\:306a\:3044\:3002";
SlideInsertNote::usage = "SlideInsertNote[] \:306f\:30e1\:30e2\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(documentation.wl \:4e92\:63db\:3001\:66f8\:304d\:51fa\:3057\:9664\:5916)\:3002";
SlideInsertDirective::usage = "SlideInsertDirective[] \:306f\:6307\:793a\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b\:3002\:5c55\:958b\:30fb\:7ffb\:8a33\:6642\:306b LLM \:304c\:53b3\:5b88\:3059\:308b\:3002";
SlideInsertDictionary::usage = "SlideInsertDictionary[] \:306f\:8f9e\:66f8\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b\:3002\:7ffb\:8a33\:6642\:306e\:7528\:8a9e\:5bfe\:5fdc\:3092\:6307\:5b9a\:3059\:308b\:3002";
SlideInsertBibliography::usage = "SlideInsertBibliography[] \:306f\:6587\:732e\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(documentation.wl \:4e92\:63db)\:3002";
SlideTogglePrompts::usage = "SlideTogglePrompts[] \:306f\:5168 SlidePrompt \:30bb\:30eb\:306e\:8868\:793a/\:975e\:8868\:793a\:3092\:5207\:308a\:66ff\:3048\:308b\:3002";
$SlideTranslationLanguage::usage = "$SlideTranslationLanguage \:306f\:7ffb\:8a33\:5148\:8a00\:8a9e\:3002\:65e2\:5b9a\:306f\:65e5\:672c\:8a9e\:74b0\:5883\:306a\:3089 \"English\"\:3002";

Begin["`Private`"]

(* ===================== \:8a2d\:5b9a\:30fb\:30c6\:30fc\:30de ===================== *)

$SlideStyleDefinitions = "Normal use.nb";
$SlideImageSize = {1920, 1080};
(* Templates/Slides \:306e HTML (padding 66px 110px 56px @1920x1080) \:306b\:6e96\:62e0\:3057\:305f\:4f59\:767d *)
$SlideMargins = {{100, 60}, {50, 64}};

(* NameQ \:30ac\:30fc\:30c9\:4ed8\:304d\:53c2\:7167: \:30ea\:30c6\:30e9\:30eb\:53c2\:7167\:3060\:3068 shdw \:8b66\:544a\:306e\:539f\:56e0\:306b\:306a\:308b *)
$SlideFontFamily := Module[{v},
  v = SelectFirst[{"NotebookExtensions`$fontFamily", "Global`$fontFamily"},
    NameQ[#] && StringQ[Symbol[#]] &, None];
  If[v === None, "Hiragino Kaku Gothic ProN", Symbol[v]]];

$SlideHeavyFontFamily = "Hiragino Kaku Gothic Std";

(* Templates/Slides \:306e HTML \:898b\:672c\:3068\:540c\:3058\:30c7\:30b6\:30a4\:30f3\:30c8\:30fc\:30af\:30f3 *)
$SlideTheme = <|
  "Title" -> RGBColor["#e07c14"],        (* \:30bf\:30a4\:30c8\:30eb\:6a59 *)
  "Bullet" -> RGBColor["#9d1c1c"],       (* \:7b87\:6761\:66f8\:304d\:81d9\:8102 *)
  "SubBullet" -> RGBColor["#8a8a8a"],    (* \:7b2c3\:30ec\:30d9\:30eb \:30b0\:30ec\:30fc *)
  "Text" -> RGBColor["#1c1c1c"],
  "Dim" -> RGBColor["#4a4a4a"],
  "Separator" -> RGBColor["#b06a16"],    (* \:2015 \:533a\:5207\:308a *)
  "Arrow" -> RGBColor["#c98a2c"],        (* \:30d5\:30ed\:30fc\:77e2\:5370 *)
  "PanelBackground" -> RGBColor["#faf6f0"],
  "PanelBorder" -> RGBColor["#e6d8c4"],
  "Background" -> White
|>;

SlideThemeColor[name_String] := Lookup[$SlideTheme, name,
  Failure["UnknownColor", <|"MessageTemplate" -> "unknown theme color: `1`", "MessageParameters" -> {name}|>]];
SlideThemeColor[] := Dataset[$SlideTheme];

(* ===================== \:5171\:901a\:30e6\:30fc\:30c6\:30a3\:30ea\:30c6\:30a3 ===================== *)

iNavBarCellQ[Cell[_, "SlideShowNavigationBar", ___]] := True;
iNavBarCellQ[_] := False;

iNavBarCell[] := Cell["", "SlideShowNavigationBar", CellTags -> "SlideShowHeader"];

(* \:9332\:97f3\:30bb\:30eb(AudioRecord-*.wav \:53c2\:7167)\:306f\:8868\:793a\:304b\:3089\:9664\:5916\:3059\:308b *)
iAudioCellQ[cell_Cell] := !FreeQ[cell, s_String /; StringContainsQ[s, "AudioRecord-"]];

iClosedCellQ[cell_Cell] := MatchQ[cell, Cell[___, CellOpen -> False, ___]];

(* \:7d42\:7aef\:30de\:30fc\:30ab\:30fc: CellTags \:306b "SlideDeckEnd" \:3092\:542b\:3080 navbar\:3002\:4ee5\:964d\:306f Appendix *)
iEndMarkerNavQ[cell_Cell] := iNavBarCellQ[cell] && !FreeQ[cell, "SlideDeckEnd"];
iEndMarkerCell[] := Cell["", "SlideShowNavigationBar",
  CellTags -> {"SlideShowHeader", "SlideDeckEnd"}];
iEndMarkerLabelCell[] := Cell[TextData[StyleBox[
  "\:2500\:2500 \:30b9\:30e9\:30a4\:30c9\:7d42\:7aef (\:4ee5\:964d\:306e\:30bb\:30eb\:306f\:30b9\:30e9\:30a4\:30c9\:30fb\:66f8\:304d\:51fa\:3057\:306b\:542b\:307e\:308c\:306a\:3044) \:2500\:2500",
  FontSize -> 10, FontColor -> GrayLevel[0.55]]], "Text"];

(* documentation.wl \:4e92\:63db\:306e\:30e1\:30bf\:30bb\:30eb + \:30b9\:30e9\:30a4\:30c9\:7528\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306f\:8868\:793a\:304b\:3089\:9664\:5916\:3059\:308b *)
iMetaStyleCellQ[Cell[_, "Note" | "Dictionary" | "Directive" | "Bibliography" | "SlidePrompt", ___]] := True;
iMetaStyleCellQ[_] := False;

iNoExportCellQ[cell_Cell] := MatchQ[cell,
  Cell[___, CellTags -> (t_ /; !FreeQ[{t}, "NoExport"]), ___]];

iVisualCellQ[cell_Cell] := !FreeQ[cell,
  _GraphicsBox | _Graphics3DBox | _RasterBox | TemplateBox[_, s_String /; StringStartsQ[s, "VideoBox"], ___]];

iCodeCellQ[Cell[_, "Input" | "Code" | "NaturalLanguageInput", ___]] := True;
iCodeCellQ[_] := False;

(* CellGroupData \:3092\:5c55\:958b\:3057\:3066\:8449\:30bb\:30eb\:306e\:5e73\:5766\:30ea\:30b9\:30c8\:306b\:3059\:308b *)
iFlattenCells[items_List] := Flatten[Replace[items,
  Cell[CellGroupData[g_List, ___], ___] :> iFlattenCells[g], {1}]];

iCellText[cell_Cell] := StringJoin @@ Cases[{First[cell]}, s_String :> s, {0, Infinity}];

iStringTrimLeft[s_String] := StringReplace[s, StartOfString ~~ WhitespaceCharacter .. -> "", 1];

iLookupString[assoc_Association, key_String] := With[{v = Lookup[assoc, key, ""]},
  If[StringQ[v], v, ""]];

(* ===================== \:30b7\:30ca\:30ea\:30aa: Markdown \:89e3\:6790 ===================== *)

iParseFrontMatter[lines_List] := Module[{meta = <||>, rest = lines, close},
  If[Length[lines] >= 2 && StringTrim[First[lines]] === "---",
    close = FirstPosition[Rest[lines], l_ /; StringTrim[l] === "---", {0}, {1}, Heads -> False][[1]];
    If[close > 0,
      Do[
        With[{m = StringCases[l, StartOfString ~~ k : (WordCharacter ..) ~~ ":" ~~ v___ ~~ EndOfString :> {k, StringTrim[v]}]},
          If[m =!= {}, meta[m[[1, 1]]] = m[[1, 2]]]],
        {l, lines[[2 ;; close]]}];
      rest = Drop[lines, close + 1]]];
  {meta, rest}];

iParseSlideTitle[t_String] := Module[{title = t, exp = None, m},
  m = StringCases[t, "{expected=" ~~ d : DigitCharacter .. ~~ "}" :> d];
  If[m =!= {},
    exp = ToExpression[First[m]];
    title = StringTrim[StringReplace[t, "{expected=" ~~ DigitCharacter .. ~~ "}" -> ""]]];
  {title, exp}];

iParseImageSpecs[line_String] := StringCases[line,
  "![" ~~ alt : Except["]"] ... ~~ "](" ~~ path : Except[")"] .. ~~ ")" :>
    With[{w = StringCases[alt, "w=" ~~ d : DigitCharacter .. :> ToExpression[d]]},
      <|"Path" -> StringTrim[path], "Width" -> If[w === {}, Automatic, First[w]]|>]];

SlideScenarioFromMarkdown[File[f_String]] := SlideScenarioFromMarkdown[
  Import[iResolvePath[f], "Text"]];

SlideScenarioFromMarkdown[md_String] := Module[
  {lines, meta, body, slides = {}, cur = None, curContent = {}, lastBulletLevel = 0,
   inCode = False, codeLines = {}, pushSlide, finishCode,
   inAppendix = False, appendixLines = {},
   paraStyles = {"ItemParagraph", "SubitemParagraph", "SubsubitemParagraph"},
   bulletStyles = {"Item", "Subitem", "Subsubitem"}},
  lines = StringSplit[StringReplace[md, "\r\n" -> "\n"], "\n"];
  {meta, body} = iParseFrontMatter[lines];
  pushSlide[] := If[cur =!= None,
    AppendTo[slides, Append[cur, "Content" -> curContent]]];
  finishCode[] := (
    If[codeLines =!= {}, AppendTo[curContent, {"Input", StringRiffle[codeLines, "\n"]}]];
    codeLines = {}; inCode = False);
  Do[
    Which[
      inCode && StringStartsQ[StringTrim[line], "```"], finishCode[],
      inCode, AppendTo[codeLines, line],
      StringStartsQ[line, "## "],
      Module[{t = StringTrim[StringDrop[line, 3]], title, exp},
        pushSlide[];
        lastBulletLevel = 0; curContent = {};
        Which[
          t === "!end",
          cur = None; inAppendix = True,
          StringStartsQ[t, "!image "] || StringStartsQ[t, "!imagepage "],
          cur = <|"ImagePage" -> StringTrim[StringDrop[t, StringLength[First[StringSplit[t]]] + 1]], "Title" -> ""|>,
          True,
          {title, exp} = iParseSlideTitle[t];
          cur = <|"Title" -> title|>;
          If[exp =!= None, cur["ExpectedSeconds"] = exp]]],
      cur === None,
      If[inAppendix && StringTrim[line] =!= "", AppendTo[appendixLines, StringTrim[line]]], (* \:30b9\:30e9\:30a4\:30c9\:958b\:59cb\:524d\:306e\:884c\:306f\:7121\:8996(\:30bf\:30a4\:30c8\:30eb\:306f front matter \:3067) *)
      StringStartsQ[StringTrim[line], "```"], inCode = True; codeLines = {},
      With[{t = iStringTrimLeft[line]},
        StringLength[t] >= 2 && MemberQ[{"-", "*"}, StringTake[t, 1]] && StringTake[t, {2}] === " "],
      Module[{indent, level, text},
        indent = StringLength[line] - StringLength[iStringTrimLeft[line]];
        level = Clip[Floor[indent/2] + 1, {1, 3}];
        lastBulletLevel = level;
        text = StringTrim[StringDrop[iStringTrimLeft[line], 2]];
        AppendTo[curContent, {bulletStyles[[level]], text}]],
      StringStartsQ[StringTrim[line], "> "],
      AppendTo[curContent,
        {If[lastBulletLevel >= 1, paraStyles[[lastBulletLevel]], "Text"],
         StringTrim[StringDrop[StringTrim[line], 2]]}],
      StringStartsQ[StringTrim[line], "cite:"],
      AppendTo[curContent, {"Cite", StringTrim[StringDrop[StringTrim[line], 5]]}],
      StringMatchQ[StringTrim[line], "<<FIG" ~~ DigitCharacter .. ~~ ">>"],
      AppendTo[curContent, {"Keep",
        ToExpression[First[StringCases[line, "<<FIG" ~~ d : DigitCharacter .. ~~ ">>" :> d]]]}],
      iParseImageSpecs[line] =!= {},
      With[{specs = iParseImageSpecs[line]},
        AppendTo[curContent, If[Length[specs] === 1, {"Image", specs[[1]]}, {"Images", specs}]]],
      StringTrim[line] =!= "",
      AppendTo[curContent, {"Text", StringTrim[line]}]
    ],
    {line, body}];
  If[inCode, finishCode[]];
  pushSlide[];
  <|"Title" -> Lookup[meta, "Title", ""], "Event" -> Lookup[meta, "Event", ""],
    "Author" -> Lookup[meta, "Author", ""], "Date" -> Lookup[meta, "Date", ""],
    "Slides" -> slides, "Appendix" -> appendixLines|>];

SlideScenarioToMarkdown[scenario_Association] := Module[{out = {}, meta},
  meta = Select[KeyTake[scenario, {"Title", "Event", "Author", "Date"}], StringQ[#] && # =!= "" &];
  If[meta =!= <||>,
    AppendTo[out, "---"];
    KeyValueMap[AppendTo[out, #1 <> ": " <> ToString[#2]] &, meta];
    AppendTo[out, "---"]; AppendTo[out, ""]];
  Do[
    If[KeyExistsQ[slide, "ImagePage"],
      AppendTo[out, "## !image " <> slide["ImagePage"]],
      AppendTo[out, "## " <> slide["Title"] <>
        If[KeyExistsQ[slide, "ExpectedSeconds"],
          " {expected=" <> ToString[slide["ExpectedSeconds"]] <> "}", ""]];
      Do[
        AppendTo[out, Switch[item[[1]],
          "Item", "- " <> item[[2]],
          "Subitem", "  - " <> item[[2]],
          "Subsubitem", "    - " <> item[[2]],
          "ItemParagraph" | "SubitemParagraph" | "SubsubitemParagraph", "> " <> item[[2]],
          "Text", item[[2]],
          "Image", "![" <> If[item[[2, "Width"]] === Automatic, "",
            "w=" <> ToString[item[[2, "Width"]]]] <> "](" <> item[[2, "Path"]] <> ")",
          "Images", StringJoin[("![" <> If[#["Width"] === Automatic, "", "w=" <> ToString[#["Width"]]] <>
            "](" <> #["Path"] <> ")") & /@ item[[2]]],
          "Cite", "cite: " <> item[[2]],
          "Keep", "<<FIG" <> ToString[item[[2]]] <> ">>",
          "Input", "```wl\n" <> item[[2]] <> "\n```",
          _, ""]],
        {item, slide["Content"]}]];
    AppendTo[out, ""],
    {slide, scenario["Slides"]}];
  If[Lookup[scenario, "Appendix", {}] =!= {},
    AppendTo[out, "## !end"];
    Do[AppendTo[out, l], {l, Select[Flatten[{scenario["Appendix"]}], StringQ]}];
    AppendTo[out, ""]];
  StringRiffle[out, "\n"]];

(* ===================== \:30c7\:30c3\:30ad\:751f\:6210 ===================== *)

iResolvePath[f_String] := Which[
  FileExistsQ[f], f,
  FileNameDepth[f] > 1, f,
  True, Module[{d = Quiet@Check[NotebookDirectory[], None]},
    If[StringQ[d], FileNameJoin[{d, f}],
      If[StringQ[Global`$packageDirectory], FileNameJoin[{Global`$packageDirectory, f}], f]]]];

SlideDeckBuild::noimg = "\:753b\:50cf\:30d5\:30a1\:30a4\:30eb\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093: `1` (\:30d7\:30ec\:30fc\:30b9\:30db\:30eb\:30c0\:3092\:633f\:5165\:3057\:307e\:3059)";

iImportSlideImage[path_String] := Module[{p = iResolvePath[path], img},
  img = If[FileExistsQ[p], Quiet@Check[Import[p], $Failed], $Failed];
  If[!ImageQ[img],
    Message[SlideDeckBuild::noimg, path];
    img = Image[ConstantArray[{0.93, 0.93, 0.93}, {450, 800}]]];
  img];

(* \:753b\:50cf\:3092 pt \:5e45\:6307\:5b9a\:306e Image \:3068\:3057\:3066\:8fd4\:3059\:3002\:65e2\:5b9a\:306f\:672c\:6587\:5e45 820pt\:30fb\:9ad8\:3055 360pt \:306b\:53ce\:307e\:308b\:30b5\:30a4\:30ba *)
iSizedSlideImage[spec_Association, maxW_ : 820, maxH_ : 360] := Module[{img, dims, wpt},
  img = iImportSlideImage[spec["Path"]];
  dims = ImageDimensions[img];
  wpt = If[NumberQ[spec["Width"]], spec["Width"],
    Min[maxW, 0.75*dims[[1]], maxH*dims[[1]]/dims[[2]]]];
  Image[img, ImageSize -> wpt]];

iContentCell[{style : "Item" | "Subitem" | "Subsubitem" | "ItemParagraph" | "SubitemParagraph" | "SubsubitemParagraph" | "Text", text_String}] :=
  Cell[text, style];

iContentCell[{"Input", code_String}] := Cell[code, "Input"];

iContentCell[{"Image", spec_Association}] :=
  Cell[BoxData[ToBoxes[iSizedSlideImage[spec]]], "Input", TextAlignment -> Center];

iContentCell[{"Images", specs_List}] :=
  Cell[BoxData[ToBoxes[Grid[{iSizedSlideImage[#, 0.9*820/Length[specs], 340] & /@ specs},
    Alignment -> Top, Spacings -> {2, 0}]]], "Input", TextAlignment -> Center];

(* \:51fa\:5178\:30bb\:30eb: \:5c0f\:3055\:3044\:30d5\:30a9\:30f3\:30c8\:3067\:51fa\:5178(URL / (\:8457\:8005, \:5e74))\:3092\:660e\:8a18\:3059\:308b *)
iContentCell[{"Cite", src_String}] := Cell[TextData[StyleBox[
  If[StringStartsQ[src, "\:51fa\:5178" | "Source" | "\:51fa\:6240"], src, "\:51fa\:5178: " <> src],
  FontSize -> 9, FontColor -> GrayLevel[0.45]]], "Text", CellTags -> "Citation"];

(* \:65e2\:5b58\:30bb\:30eb\:4fdd\:6301\:30c8\:30fc\:30af\:30f3: \:518d\:5c55\:958b\:6642\:306b\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:3092\:305d\:306e\:307e\:307e\:6b8b\:3059\:3002
   $iSlideKeepCells \:3092 Block \:3067\:675f\:7e1b\:3057\:3066\:304b\:3089 iBuildSlideCells \:3092\:547c\:3076 *)
$iSlideKeepCells = {};
iContentCell[{"Keep", n_Integer}] := If[1 <= n <= Length[$iSlideKeepCells],
  $iSlideKeepCells[[n]],
  Cell["<<FIG" <> ToString[n] <> ">>", "Text"]];

iSubsectionTags[slide_Association] := If[KeyExistsQ[slide, "ExpectedSeconds"],
  {"Expected:" <> ToString[slide["ExpectedSeconds"]], "Top"}, {"Top"}];

iBuildSlideCells[slide_Association] := Module[{cells},
  If[KeyExistsQ[slide, "ImagePage"],
    (* \:5168\:9762\:753b\:50cf\:30da\:30fc\:30b8: Subsection \:306f\:9589\:3058\:305f\:30bb\:30eb\:3067\:4fdd\:6301(\:679a\:6570\:8a08\:6e2c\:7cfb\:3068\:306e\:4e92\:63db) *)
    {iNavBarCell[],
     Cell[iLookupString[slide, "Title"], "Subsection", CellOpen -> False, CellTags -> iSubsectionTags[slide]],
     Cell[BoxData[ToBoxes[iSizedSlideImage[<|"Path" -> slide["ImagePage"], "Width" -> Automatic|>, 900, 500]]],
       "Input", TextAlignment -> Center, CellMargins -> {{0, 0}, {0, 0}}, CellTags -> "ImagePage"]},
    cells = iContentCell /@ Lookup[slide, "Content", {}];
    Join[{iNavBarCell[],
      Cell[iLookupString[slide, "Title"], "Subsection", CellTags -> iSubsectionTags[slide]]}, cells]]];

iBuildTitleSlideCells[scenario_Association] := Module[
  {cells = {}, title = iLookupString[scenario, "Title"], event = iLookupString[scenario, "Event"],
   author = iLookupString[scenario, "Author"], date = iLookupString[scenario, "Date"]},
  AppendTo[cells, iNavBarCell[]];
  AppendTo[cells, Cell["", "Subsection", CellTags -> {"Top"}]];
  AppendTo[cells, Cell["", "Text"]];
  If[title =!= "",
    AppendTo[cells, Cell[TextData[StyleBox[title,
      FontFamily -> $SlideHeavyFontFamily, FontSize -> 48, FontWeight -> "ExtraBold"]], "Text"]]];
  AppendTo[cells, Cell["", "Text"]];
  If[event =!= "",
    AppendTo[cells, Cell[TextData[StyleBox[event,
      FontFamily -> $SlideHeavyFontFamily, FontSize -> 28, FontWeight -> "ExtraBold"]], "Text"]]];
  If[date =!= "", AppendTo[cells, Cell[date, "Text"]]];
  If[author =!= "",
    AppendTo[cells, Cell[TextData[StyleBox[author <> "\:3000\:3000", FontSize -> 24]], "Text",
      TextAlignment -> Right]]];
  cells];

Options[SlideDeckBuild] = {
  "TitleSlide" -> True,
  "EndMarker" -> True,
  StyleDefinitions -> Automatic,
  WindowSize -> {960, 540}};

SlideDeckBuild[md_String /; StringContainsQ[md, "\n## "] || StringStartsQ[md, "## "] || StringStartsQ[md, "---"], nbfile_String, opts : OptionsPattern[]] :=
  SlideDeckBuild[SlideScenarioFromMarkdown[md], nbfile, opts];

SlideDeckBuild[File[mdfile_String], nbfile_String, opts : OptionsPattern[]] :=
  SlideDeckBuild[SlideScenarioFromMarkdown[File[mdfile]], nbfile, opts];

SlideDeckBuild[scenario_Association, nbfile_String, OptionsPattern[]] := Module[
  {cells = {}, sd, file = iResolvePath[nbfile],
   title = iLookupString[scenario, "Title"], date = iLookupString[scenario, "Date"]},
  sd = Replace[OptionValue[StyleDefinitions], Automatic -> $SlideStyleDefinitions];
  (* \:4f5c\:696d\:7528\:30d8\:30c3\:30c0: \:767a\:8868\:30bf\:30a4\:30c8\:30eb\:306e Section(\:30b9\:30e9\:30a4\:30c9\:306b\:306f\:542b\:307e\:308c\:306a\:3044) *)
  If[title =!= "",
    AppendTo[cells, Cell[TextData[StyleBox[title, FontSize -> 48, FontWeight -> "Plain"]], "Section"]]];
  If[date =!= "", AppendTo[cells, Cell[date, "Text"]]];
  If[TrueQ[OptionValue["TitleSlide"]],
    cells = Join[cells, iBuildTitleSlideCells[scenario]]];
  cells = Join[cells, Flatten[iBuildSlideCells /@ scenario["Slides"], 1]];
  If[TrueQ[OptionValue["EndMarker"]],
    cells = Join[cells, {iEndMarkerCell[], iEndMarkerLabelCell[]},
      Cell[#, "Text"] & /@ Select[Flatten[{Lookup[scenario, "Appendix", {}]}], StringQ]]];
  Export[file, Notebook[cells,
    StyleDefinitions -> sd,
    WindowSize -> OptionValue[WindowSize],
    Background -> White], "NB"];
  file];

(* ===================== \:30c7\:30c3\:30ad\:8aad\:307f\:53d6\:308a\:30fb\:7de8\:96c6 ===================== *)

SlideDeckSlides::nofile = "\:30d5\:30a1\:30a4\:30eb\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093: `1`";
SlideDeckSlides::nonav = "SlideShowNavigationBar \:30bb\:30eb\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093: `1`";

iGetNotebook[nbfile_String] := Module[{f = iResolvePath[nbfile], nb},
  If[!FileExistsQ[f], Message[SlideDeckSlides::nofile, nbfile]; Return[$Failed]];
  nb = Quiet[Get[f]];
  If[Head[nb] =!= Notebook, $Failed, nb]];

SlideDeckSlides[nb_Notebook] := Module[{flat, navPos, endPos, prelude, slides, appendix},
  flat = iFlattenCells[First[nb]];
  navPos = Flatten[Position[flat, _?iNavBarCellQ, {1}, Heads -> False]];
  (* \:7d42\:7aef\:30de\:30fc\:30ab\:30fc("SlideDeckEnd" \:30bf\:30b0\:4ed8\:304d navbar)\:4ee5\:964d\:306f Appendix \:3068\:3057\:3066\:5206\:96e2 *)
  endPos = SelectFirst[navPos, iEndMarkerNavQ[flat[[#]]] &, Length[flat] + 1];
  navPos = Select[navPos, # < endPos &];
  appendix = If[endPos <= Length[flat], flat[[endPos ;;]], {}];
  If[navPos === {},
    Message[SlideDeckSlides::nonav, "Notebook"];
    Return[<|"Prelude" -> flat[[;; Min[endPos - 1, Length[flat]]]], "Slides" -> {},
      "Appendix" -> appendix, "Options" -> Rest[List @@ nb]|>]];
  prelude = flat[[;; First[navPos] - 1]];
  slides = MapThread[flat[[#1 ;; #2]] &,
    {navPos, Append[Rest[navPos] - 1, endPos - 1]}];
  <|"Prelude" -> prelude, "Slides" -> slides, "Appendix" -> appendix,
    "Options" -> Rest[List @@ nb]|>];

SlideDeckSlides[nbfile_String] := With[{nb = iGetNotebook[nbfile]},
  If[nb === $Failed, $Failed, SlideDeckSlides[nb]]];

SlideDeckSlides[nbo_NotebookObject] := SlideDeckSlides[NotebookGet[nbo]];

iSlideTitle[cells_List] := Module[{sub},
  sub = SelectFirst[cells, MatchQ[#, Cell[_, "Subsection", ___]] &, None];
  If[sub === None, "", iCellText[sub]]];

SlideDeckOverview[source_ /; StringQ[source] || Head[source] === Notebook || Head[source] === NotebookObject] := Module[{data},
  data = SlideDeckSlides[source];
  If[data === $Failed, Return[$Failed]];
  Dataset[MapIndexed[
    <|"Number" -> #2[[1]],
      "Title" -> Style[iSlideTitle[#1], FontFamily -> $SlideFontFamily],
      "Cells" -> Length[#1],
      "Graphics" -> Count[#1, _?iVisualCellQ],
      "ImagePage" -> MemberQ[#1, Cell[___, CellTags -> (t_ /; !FreeQ[{t}, "ImagePage"]), ___]]|> &,
    data["Slides"]]]];

(* \:7de8\:96c6\:306e\:5171\:901a\:5f8c\:51e6\:7406: \:4e0a\:66f8\:304d\:6642\:306f .bak \:3092\:6b8b\:3059 *)
Options[SlideDeckReplaceSlide] = Options[SlideDeckInsertSlide] =
  Options[SlideDeckDeleteSlide] = Options[SlideDeckMoveSlide] =
  {"Target" -> Automatic, "Backup" -> True};

iWriteDeck[data_Association, srcfile_String, target_, backup_] := Module[
  {src = iResolvePath[srcfile], out, cells},
  out = If[target === Automatic, src, iResolvePath[target]];
  If[out === src && TrueQ[backup] && FileExistsQ[src],
    Quiet[DeleteFile[src <> ".bak"]];
    CopyFile[src, src <> ".bak"]];
  cells = Join[data["Prelude"], Flatten[data["Slides"], 1], Lookup[data, "Appendix", {}]];
  Export[out, Notebook[cells, Sequence @@ data["Options"]], "NB"];
  out];

iCoerceSlideCells[slide_Association] := iBuildSlideCells[slide];
iCoerceSlideCells[cells : {__Cell}] :=
  If[iNavBarCellQ[First[cells]], cells, Prepend[cells, iNavBarCell[]]];

SlideDeckReplaceSlide::range = "\:30b9\:30e9\:30a4\:30c9\:756a\:53f7 `1` \:304c\:7bc4\:56f2\:5916\:3067\:3059 (\:5168 `2` \:679a)\:3002";

SlideDeckReplaceSlide[nbfile_String, n_Integer, slide_, OptionsPattern[]] := Module[{data},
  data = SlideDeckSlides[nbfile];
  If[data === $Failed, Return[$Failed]];
  If[!(1 <= n <= Length[data["Slides"]]),
    Message[SlideDeckReplaceSlide::range, n, Length[data["Slides"]]]; Return[$Failed]];
  data["Slides"] = ReplacePart[data["Slides"], n -> iCoerceSlideCells[slide]];
  iWriteDeck[data, nbfile, OptionValue["Target"], OptionValue["Backup"]]];

SlideDeckInsertSlide[nbfile_String, n_Integer, slide_, OptionsPattern[]] := Module[{data},
  data = SlideDeckSlides[nbfile];
  If[data === $Failed, Return[$Failed]];
  If[!(1 <= n <= Length[data["Slides"]] + 1),
    Message[SlideDeckReplaceSlide::range, n, Length[data["Slides"]]]; Return[$Failed]];
  data["Slides"] = Insert[data["Slides"], iCoerceSlideCells[slide], n];
  iWriteDeck[data, nbfile, OptionValue["Target"], OptionValue["Backup"]]];

SlideDeckDeleteSlide[nbfile_String, n : (_Integer | {__Integer}), OptionsPattern[]] := Module[{data, ns},
  data = SlideDeckSlides[nbfile];
  If[data === $Failed, Return[$Failed]];
  ns = Flatten[{n}];
  If[!AllTrue[ns, 1 <= # <= Length[data["Slides"]] &],
    Message[SlideDeckReplaceSlide::range, ns, Length[data["Slides"]]]; Return[$Failed]];
  data["Slides"] = Delete[data["Slides"], List /@ ns];
  iWriteDeck[data, nbfile, OptionValue["Target"], OptionValue["Backup"]]];

SlideDeckMoveSlide[nbfile_String, n_Integer, m_Integer, OptionsPattern[]] := Module[{data, s},
  data = SlideDeckSlides[nbfile];
  If[data === $Failed, Return[$Failed]];
  If[!(1 <= n <= Length[data["Slides"]] && 1 <= m <= Length[data["Slides"]]),
    Message[SlideDeckReplaceSlide::range, {n, m}, Length[data["Slides"]]]; Return[$Failed]];
  s = data["Slides"][[n]];
  data["Slides"] = Insert[Delete[data["Slides"], n], s, m];
  iWriteDeck[data, nbfile, OptionValue["Target"], OptionValue["Backup"]]];

(* ===================== \:30e9\:30b9\:30bf\:30e9\:30a4\:30ba(\:5b89\:5b9a 16:9) ===================== *)

SlideDeckImages::ovflw = "\:30b9\:30e9\:30a4\:30c9 `1` \:306e\:5185\:5bb9\:304c\:9ad8\:3055\:306b\:53ce\:307e\:3089\:306a\:3044\:305f\:3081\:7e2e\:5c0f\:3057\:307e\:3057\:305f (`2`px)\:3002";
SlideDeckImages::emptyslide = "\:30b9\:30e9\:30a4\:30c9 `1` \:306b\:8868\:793a\:30bb\:30eb\:304c\:3042\:308a\:307e\:305b\:3093\:3002\:7a7a\:767d\:30da\:30fc\:30b8\:3092\:51fa\:529b\:3057\:307e\:3059\:3002";

Options[SlideDeckImages] = {
  ImageSize -> Automatic,           (* {1920,1080} *)
  "Slides" -> All,
  "Margins" -> Automatic,           (* Automatic: $SlideMargins / m / {{l,r},{b,t}} px *)
  "Environment" -> "SlideShow",
  "WindowWidth" -> 960,             (* pt: \:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:6642\:306e\:6298\:8fd4\:3057\:5e45 *)
  "Reflow" -> True,                 (* \:7e26\:3042\:3075\:308c\:6642\:306b\:6298\:8fd4\:3057\:5e45\:3092\:5e83\:3052\:3066\:5168\:5e45\:3092\:4f7f\:3046 *)
  "MaxWindowWidth" -> 1600,         (* pt: \:30ea\:30d5\:30ed\:30fc\:6642\:306e\:6298\:8fd4\:3057\:5e45\:4e0a\:9650 *)
  "IncludeInput" -> Automatic,      (* Automatic: \:56f3\:3092\:542b\:3080 Input \:306e\:307f\:6b8b\:3059 / True: \:5168\:90e8\:6b8b\:3059 *)
  "Verbose" -> False,
  StyleDefinitions -> Automatic,
  Background -> White};

iRasterFilterCells[cells_List, includeInput_] := Select[cells,
  And[!iNavBarCellQ[#], !iAudioCellQ[#], !iClosedCellQ[#], !iNoExportCellQ[#],
      !iMetaStyleCellQ[#],
      Or[TrueQ[includeInput], !iCodeCellQ[#], iVisualCellQ[#]]] &];

iSingleGraphicsSlideQ[cells_List] :=
  Length[cells] === 1 && MatchQ[First[cells], Cell[BoxData[_GraphicsBox], ___]];

(* \:5185\:5bb9\:753b\:50cf\:3092 16:9 \:30ad\:30e3\:30f3\:30d0\:30b9\:306b\:5408\:6210\:3059\:308b\:3002
   upscale=True \:306a\:3089\:62e1\:5927\:3082\:8a31\:3059(\:5168\:9762\:753b\:50cf\:30da\:30fc\:30b8\:7528)\:3002align: "TopLeft"|"Center" *)
iNormalizeMargins[Automatic] := $SlideMargins;
iNormalizeMargins[m_?NumericQ] := {{m, m}, {m, m}};
iNormalizeMargins[m : {{_?NumericQ, _?NumericQ}, {_?NumericQ, _?NumericQ}}] := m;
iNormalizeMargins[_] := $SlideMargins;

iComposeCanvas[img_Image, {tw_, th_}, bg_, align_ : "TopLeft", slideno_ : 0, upscale_ : False,
   margins_ : {{0, 0}, {0, 0}}] := Module[
  {ras = img, w, h, scale, mL, mR, mB, mT, availW, availH},
  {{mL, mR}, {mB, mT}} = margins;
  availW = tw - mL - mR; availH = th - mB - mT;
  {w, h} = ImageDimensions[ras];
  scale = Min[availW/w, availH/h];
  If[scale < 1 || (upscale && scale > 1),
    If[h > availH && slideno > 0, Message[SlideDeckImages::ovflw, slideno, h]];
    ras = ImageResize[ras, Floor[scale*{w, h}]];
    {w, h} = ImageDimensions[ras]];
  If[align === "Center",
    ImagePad[ras, {{Floor[(tw - w)/2], Ceiling[(tw - w)/2]}, {Floor[(th - h)/2], Ceiling[(th - h)/2]}}, bg],
    ImagePad[ras, {{mL, tw - w - mL}, {th - h - mT, mT}}, bg]]];

iRasterizeSlide[cells_List, opts_Association] := Module[
  {filtered, nbExpr, ras, scale, res, target = opts["Target"], g},
  filtered = iRasterFilterCells[cells, opts["IncludeInput"]];
  If[filtered === {},
    Message[SlideDeckImages::emptyslide, opts["Number"]];
    Return[Image[ConstantArray[1., Reverse[target]]]]];
  (* \:5168\:9762 1 \:753b\:50cf\:306e\:30da\:30fc\:30b8\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:4f59\:767d\:3092\:901a\:3055\:305a\:30d4\:30af\:30bb\:30eb\:5408\:6210\:3059\:308b *)
  If[iSingleGraphicsSlideQ[filtered],
    g = ToExpression[First[Cases[filtered, Cell[BoxData[b_GraphicsBox], ___] :> b, {1}, 1]]];
    ras = Rasterize[g, "Image", ImageSize -> {target[[1]], Automatic}, ImageResolution -> 72];
    Return[iComposeCanvas[ras, target, opts["Background"], "Center", opts["Number"], True]]];
  (* \:7e26\:3042\:3075\:308c\:6642\:306e\:81ea\:52d5\:30ea\:30d5\:30ed\:30fc (2026-07-13):
     \:5185\:5bb9\:304c\:9ad8\:3055\:306b\:53ce\:307e\:3089\:306a\:3044\:3068 iComposeCanvas \:304c\:7e26\:6a2a\:4e00\:5f8b\:306b\:7e2e\:5c0f\:3059\:308b\:305f\:3081\:3001
     \:5e45\:3082\:4e00\:7dd2\:306b\:7e2e\:3093\:3067\:53f3\:306b\:5927\:304d\:306a\:4f59\:767d\:304c\:6b8b\:308b (\:5b9f\:6e2c: 1215px \:9ad8\:306e\:30b9\:30e9\:30a4\:30c9\:3067
     0.79 \:500d\:7e2e\:5c0f \[RightArrow] \:53f3\:4f59\:767d 439px)\:3002\:6298\:8fd4\:3057\:5e45(WindowWidth)\:3092\:5e83\:3052\:3066\:518d\:63cf\:753b\:3059\:308c\:3070
     \:884c\:6570\:304c\:6e1b\:3063\:3066\:9ad8\:3055\:304c\:53ce\:307e\:308a\:3001\:5e45\:3092\:4f7f\:3044\:5207\:308c\:308b\:3002\:305f\:3060\:3057\:5e83\:3052\:3059\:304e\:308b\:3068\:56f3\:7b49\:306e
     \:4e0d\:52d5\:8981\:7d20\:304c\:76f8\:5bfe\:7684\:306b\:5c0f\:3055\:304f\:306a\:308a\:518d\:3073\:4f59\:767d\:304c\:5897\:3048\:308b\:305f\:3081\:3001
     \:300c\:6700\:7d42\:5e45\:304c\:6700\:5927\:306b\:306a\:308b W\:300d\:3092\:63a2\:7d22\:3059\:308b\:3002\:53ce\:307e\:3063\:3066\:3044\:308b\:30b9\:30e9\:30a4\:30c9\:306f
     \:521d\:56de\:63cf\:753b\:3067\:78ba\:5b9a\:3059\:308b\:306e\:3067\:5f93\:6765\:306e\:51fa\:529b\:30fb\:6027\:80fd\:3068\:5909\:308f\:3089\:306a\:3044\:3002 *)
  Module[{margins = opts["Margins"], availW, availH, ratio, w0, maxW, maxIter,
          render, finalWidth, best, bestW, bestFW, cur, curW, dims, f, iter = 0,
          mL, mR, mB, mT},
    {{mL, mR}, {mB, mT}} = margins;
    availW = target[[1]] - mL - mR;
    availH = target[[2]] - mB - mT;
    ratio = availH/availW;
    w0 = opts["WindowWidth"];
    maxW = Replace[opts["MaxWindowWidth"], Except[_?NumericQ] -> 1600];
    maxIter = If[TrueQ[opts["Reflow"]], 3, 0];
    render[W_] := Rasterize[
      Notebook[filtered,
        StyleDefinitions -> opts["StyleDefinitions"],
        ScreenStyleEnvironment -> opts["Environment"],
        WindowSize -> {Round[W], Round[W*target[[2]]/target[[1]]]},
        Background -> opts["Background"]],
      "Image", ImageResolution -> Round[72*target[[1]]/W],
      Background -> opts["Background"]];
    (* \:6700\:7d42\:5e45 = \:30ad\:30e3\:30f3\:30d0\:30b9\:306b\:53ce\:3081\:305f\:5f8c\:306e\:5e45\:3002\:3053\:308c\:3092\:6700\:5927\:5316\:3059\:308b *)
    finalWidth[d_] := d[[1]]*Min[1, availW/d[[1]], availH/d[[2]]];
    curW = w0; cur = render[curW]; dims = ImageDimensions[cur];
    best = cur; bestW = curW; bestFW = finalWidth[dims];
    While[iter < maxIter && dims[[2]]/dims[[1]] > ratio && curW < maxW,
      iter++;
      f = Clip[Sqrt[(dims[[2]]/dims[[1]])/ratio], {1.05, 1.5}];
      curW = Min[curW*f, maxW];
      cur = render[curW]; dims = ImageDimensions[cur];
      If[finalWidth[dims] > bestFW, best = cur; bestW = curW; bestFW = finalWidth[dims]]];
    If[TrueQ[opts["Verbose"]] && bestW =!= w0,
      Print["  slide ", opts["Number"], ": reflow ", w0, "pt -> ", Round[bestW],
        "pt (final width ", Round[bestFW], "/", availW, "px)"]];
    iComposeCanvas[best, target, opts["Background"], "TopLeft", opts["Number"], False, margins]]];

SlideDeckImages[source_ /; StringQ[source] || Head[source] === Notebook || Head[source] === NotebookObject, OptionsPattern[]] := Module[
  {data, slides, sel, target, sd, imgs},
  data = SlideDeckSlides[source];
  If[data === $Failed, Return[$Failed]];
  slides = data["Slides"];
  sel = Flatten[{Range[Length[slides]][[OptionValue["Slides"]]]}];
  target = Replace[OptionValue[ImageSize], Automatic -> $SlideImageSize];
  sd = Replace[OptionValue[StyleDefinitions], Automatic :>
    FirstCase[data["Options"], HoldPattern[StyleDefinitions -> s_] :> s, $SlideStyleDefinitions]];
  UsingFrontEnd[
    imgs = Table[
      If[TrueQ[OptionValue["Verbose"]], Print["slide ", n, " / ", Length[slides]]];
      iRasterizeSlide[slides[[n]],
        <|"Target" -> target, "WindowWidth" -> OptionValue["WindowWidth"],
          "Margins" -> iNormalizeMargins[OptionValue["Margins"]],
          "Reflow" -> OptionValue["Reflow"],
          "MaxWindowWidth" -> OptionValue["MaxWindowWidth"],
          "Verbose" -> OptionValue["Verbose"],
          "Environment" -> OptionValue["Environment"],
          "IncludeInput" -> OptionValue["IncludeInput"],
          "StyleDefinitions" -> sd,
          "Background" -> OptionValue[Background],
          "Number" -> n|>],
      {n, sel}]];
  imgs];

(* ===================== \:66f8\:304d\:51fa\:3057 ===================== *)

Options[SlideDeckExportImages] = Options[SlideDeckImages];

SlideDeckExportImages[nbfile_String, opts : OptionsPattern[]] :=
  SlideDeckExportImages[nbfile,
    FileNameJoin[{DirectoryName[iResolvePath[nbfile]], FileBaseName[nbfile] <> "_slides"}], opts];

SlideDeckExportImages[nbfile_String, dir_String, opts : OptionsPattern[]] := Module[{imgs, d = dir},
  imgs = SlideDeckImages[nbfile, opts];
  If[imgs === $Failed, Return[$Failed]];
  If[!DirectoryQ[d], CreateDirectory[d, CreateIntermediateDirectories -> True]];
  MapIndexed[
    Export[FileNameJoin[{d, StringPadLeft[ToString[#2[[1]]], 2, "0"] <> ".png"}], #1] &,
    imgs]];

SlideDeckExportVideo::ext = "Sliden \:7528\:52d5\:753b\:306f .mp4 \:3067\:4fdd\:5b58\:3057\:3066\:304f\:3060\:3055\:3044: `1`";
SlideDeckExportVideo::len = "Durations \:306e\:9577\:3055 `1` \:304c\:30b9\:30e9\:30a4\:30c9\:6570 `2` \:3068\:4e00\:81f4\:3057\:307e\:305b\:3093\:3002";

Options[SlideDeckExportVideo] = Join[{
  "Durations" -> Automatic,   (* Automatic: Sliden \:4e92\:63db 1\:679a\:22521\:79d2 / \:79d2\:6570\:30ea\:30b9\:30c8 *)
  FrameRate -> 30},
  Options[SlideDeckImages]];

SlideDeckExportVideo[nbfile_String, mp4file_String, opts : OptionsPattern[]] := Module[{imgs},
  imgs = SlideDeckImages[nbfile, Sequence @@ FilterRules[{opts}, Options[SlideDeckImages]]];
  If[imgs === $Failed, Return[$Failed]];
  SlideDeckExportVideo[imgs, mp4file, opts]];

SlideDeckExportVideo[imgs : {__Image}, mp4file_String, OptionsPattern[]] := Module[
  {out = iResolvePath[mp4file], fr, durations, framespec, v},
  If[ToLowerCase[FileExtension[out]] =!= "mp4",
    Message[SlideDeckExportVideo::ext, out]; Return[$Failed]];
  fr = OptionValue[FrameRate];
  durations = OptionValue["Durations"];
  framespec = If[durations === Automatic,
    (* Sliden \:4e92\:63db: NotebookExtensions`slidenVideo \:3068\:540c\:3058 29+30n+\:672b\:5c3e\:91cd\:8907 *)
    Prepend[Thread[Append[imgs[[2 ;;]], imgs[[-1]]] -> Quantity[fr, "Frames"]],
      imgs[[1]] -> Quantity[fr - 1, "Frames"]],
    If[Length[durations] =!= Length[imgs],
      Message[SlideDeckExportVideo::len, Length[durations], Length[imgs]]; Return[$Failed]];
    Thread[imgs -> (Quantity[#, "Seconds"] & /@ durations)]];
  If[framespec === $Failed, Return[$Failed]];
  Quiet[DeleteFile[out]];
  v = SlideShowVideo[framespec, FrameRate -> fr, GeneratedAssetLocation -> out];
  If[Head[v] === Video, out, $Failed]];

(* ===================== \:30a4\:30f3\:30bf\:30e9\:30af\:30c6\:30a3\:30d6\:7de8\:96c6\:5c64 (\:65e7 _interactive.wl) ===================== *)

iSL[ja_String, en_String] := If[$Language === "Japanese", ja, en];

If[!ValueQ[$SlideTranslationLanguage],
  $SlideTranslationLanguage = If[$Language === "English", "Japanese", "English"]];

(* ===================== \:5171\:901a\:30e6\:30fc\:30c6\:30a3\:30ea\:30c6\:30a3 (FE) ===================== *)

iSWLLMReadyQ[] := TrueQ[Quiet[ValueQ[NBAccess`$NBLLMQueryFunc]]];

iSWRequireLLM[] := If[iSWLLMReadyQ[], True,
  MessageDialog[iSL[
    "LLM \:6a5f\:80fd\:306b\:306f NBAccess/claudecode \:306e\:30ed\:30fc\:30c9\:304c\:5fc5\:8981\:3067\:3059\:3002",
    "LLM features require NBAccess/claudecode to be loaded."]]; False];

iSWFallback[] := If[Length[DownValues[ClaudeCode`GetPaletteFallback]] > 0,
  Quiet[ClaudeCode`GetPaletteFallback[]], False];

iSWDocLoadedQ[sym_String] :=
  Length[Quiet[DownValues[Symbol["Documentation`" <> sym]]]] > 0;

iSWStatus[nb_, s_String] := Quiet[CurrentValue[nb, WindowStatusArea] = s];
iSWStatusClearLater[nb_] := Quiet[SessionSubmit[ScheduledTask[
  Quiet[CurrentValue[nb, WindowStatusArea] = ""], {4}]]];

iSWNotebook[] := Module[{nb = Quiet[InputNotebook[]]},
  If[Head[nb] === NotebookObject, nb,
    MessageDialog[iSL["\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002", "No notebook found."]]; $Failed]];

iSWCellStyles[nb_] := Quiet[Experimental`CellStyleNames /@ Cells[nb]];
iSWCellTags[cellObj_] := Quiet[CurrentValue[cellObj, CellTags]];

iSWSelectedIndex[nb_] := Module[{sel = Quiet[SelectedCells[nb]], cells},
  If[!ListQ[sel] || sel === {}, Return[None]];
  cells = Cells[nb];
  FirstCase[Position[cells, First[sel]], {i_} :> i, None]];

(* \:30b9\:30e9\:30a4\:30c9\:7bc4\:56f2: {start, end} \:306e\:30ea\:30b9\:30c8\:3002\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d\:306f\:542b\:3081\:306a\:3044 *)
iSWSlideRanges[nb_] := Module[{styles = iSWCellStyles[nb], cells = Cells[nb], nav, endIdx},
  nav = Flatten[Position[styles, "SlideShowNavigationBar"]];
  endIdx = SelectFirst[nav, !FreeQ[{iSWCellTags[cells[[#]]]}, "SlideDeckEnd"] &,
    Length[styles] + 1];
  nav = Select[nav, # < endIdx &];
  If[nav === {}, {},
    MapThread[{#1, #2} &, {nav, Append[Rest[nav] - 1, endIdx - 1]}]]];

iSWSlideOfIndex[nb_, idx_Integer] := Module[{ranges = iSWSlideRanges[nb], k},
  k = SelectFirst[Range[Length[ranges]],
    ranges[[#, 1]] <= idx <= ranges[[#, 2]] &, None];
  If[k === None, $Failed, {k, ranges[[k, 1]], ranges[[k, 2]]}]];

iSWCurrentSlideNo[nb_] := Module[{si = iSWSelectedIndex[nb], r},
  If[si === None, Return[$Failed]];
  r = iSWSlideOfIndex[nb, si];
  If[r === $Failed, $Failed, First[r]]];

iSWNoSlideDialog[] := MessageDialog[iSL[
  "\:30b9\:30e9\:30a4\:30c9\:5185\:306e\:30bb\:30eb\:3092\:9078\:629e\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
  "Please select a cell inside a slide."]];

(* ===================== \:30b9\:30e9\:30a4\:30c9\:7528\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb ===================== *)

$iSWPromptCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}},
  CellFrameColor -> RGBColor[0.878, 0.486, 0.078],
  Background -> RGBColor[0.99, 0.955, 0.9],
  FontSize -> 11,
  FontColor -> GrayLevel[0.25],
  CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.878, 0.486, 0.078]]};

iSWPromptCell[text_String] := Cell[text, "SlidePrompt", Sequence @@ $iSWPromptCellOpts];

iSWSkeletonSlideCells[] := {
  SlideWorkflow`Private`iNavBarCell[],
  Cell[iSL["\:65b0\:3057\:3044\:30b9\:30e9\:30a4\:30c9", "New Slide"], "Subsection", CellTags -> {"Top"}],
  iSWPromptCell[iSL[
    "\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:4f1d\:3048\:305f\:3044\:5185\:5bb9(\:30d7\:30ed\:30f3\:30d7\:30c8)\:3092\:66f8\:304d\:3001\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:5c55\:958b\:300d\:3092\:62bc\:3059\:3002",
    "Write the prompt for this slide here and press Expand on the palette."]]};

(* ===================== Directive / Dictionary \:53ce\:96c6 ===================== *)

iSWCollectByStyle[nb_, style_String] := Module[
  {styles = iSWCellStyles[nb], cells = Cells[nb], idxs},
  idxs = Flatten[Position[styles, style]];
  Select[StringTrim[SlideWorkflow`Private`iCellText[NotebookRead[cells[[#]]]]] & /@ idxs,
    StringQ[#] && # =!= "" &]];

iSWDirectivesBlock[nb_] := Module[{ds = iSWCollectByStyle[nb, "Directive"]},
  If[ds === {}, "",
    "=== Directives (MUST follow ALL strictly) ===\n" <>
      StringRiffle[MapIndexed["[" <> ToString[First[#2]] <> "] " <> #1 &, ds], "\n"] <>
      "\n=== End Directives ===\n\n"]];

iSWDictionaryBlock[nb_] := Module[{ds = iSWCollectByStyle[nb, "Dictionary"]},
  If[ds === {}, "",
    "=== Dictionary (MUST use these term mappings) ===\n" <>
      StringRiffle[ds, "\n"] <> "\n=== End Dictionary ===\n\n"]];

(* ===================== \:30b9\:30e9\:30a4\:30c9 \:2192 Markdown (+\:4fdd\:6301\:30bb\:30eb) ===================== *)

$iSWTranslatableStyles = {"Subsection", "Item", "Subitem", "Subsubitem",
  "ItemParagraph", "SubitemParagraph", "SubsubitemParagraph", "Text", "Section"};

iSWExpectedOf[cellExpr_Cell] := Module[{tags},
  tags = Flatten[{FirstCase[cellExpr, (CellTags -> t_) :> t, {}]}];
  FirstCase[Select[tags, StringQ],
    s_ /; StringStartsQ[s, "Expected:"] :>
      StringDrop[s, 9], None]];

iSWCitationCellQ[cellExpr_Cell] :=
  MatchQ[cellExpr, Cell[___, CellTags -> t_ /; !FreeQ[{t}, "Citation"], ___]];

(* \:30b9\:30e9\:30a4\:30c9\:306e\:30bb\:30eb\:5217\:3092 scenario Markdown \:5316\:3059\:308b\:3002
   \:56f3\:30fb\:30b3\:30fc\:30c9\:7b49\:30c6\:30ad\:30b9\:30c8\:5316\:3067\:304d\:306a\:3044\:30bb\:30eb\:306f <<FIGn>> \:3068\:3057\:3066 keeps \:306b\:9000\:907f\:3059\:308b\:3002 *)
iSWSlideToMarkdown[cellExprs_List] := Module[{lines = {}, keeps = {}, txt, exp},
  Do[
    Which[
      SlideWorkflow`Private`iNavBarCellQ[c] ||
        SlideWorkflow`Private`iAudioCellQ[c] ||
        MatchQ[c, Cell[_, "SlidePrompt", ___]],
      Null,
      MatchQ[c, Cell[_, "Subsection", ___]],
      txt = SlideWorkflow`Private`iCellText[c];
      exp = iSWExpectedOf[c];
      AppendTo[lines, "## " <> txt <>
        If[StringQ[exp], " {expected=" <> exp <> "}", ""]],
      MatchQ[c, Cell[_, "Item", ___]],
      AppendTo[lines, "- " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "Subitem", ___]],
      AppendTo[lines, "  - " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "Subsubitem", ___]],
      AppendTo[lines, "    - " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "ItemParagraph" | "SubitemParagraph" | "SubsubitemParagraph", ___]],
      AppendTo[lines, "> " <> SlideWorkflow`Private`iCellText[c]],
      iSWCitationCellQ[c],
      txt = SlideWorkflow`Private`iCellText[c];
      AppendTo[lines, "cite: " <> StringTrim[StringReplace[txt,
        StartOfString ~~ ("\:51fa\:5178:" | "\:51fa\:5178\:ff1a") -> "", 1]]],
      MatchQ[c, Cell[_, "Text" | "ItemNumbered" | "SubitemNumbered", ___]] &&
        !SlideWorkflow`Private`iVisualCellQ[c],
      AppendTo[lines, SlideWorkflow`Private`iCellText[c]],
      True, (* \:56f3\:30fb\:30b3\:30fc\:30c9\:30fb\:305d\:306e\:4ed6\:306f\:4fdd\:6301\:30bb\:30eb\:3078 *)
      AppendTo[keeps, c];
      AppendTo[lines, "<<FIG" <> ToString[Length[keeps]] <> ">>"]
    ],
    {c, cellExprs}];
  {StringRiffle[lines, "\n"], keeps}];

(* ===================== \:5c55\:958b (LLM) ===================== *)

iSWExpandPrompt[promptText_, title_, currentMd_, nKeep_, metaBlocks_] :=
  metaBlocks <>
  "\:3042\:306a\:305f\:306f Mathematica \:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad\:306e\:30b7\:30ca\:30ea\:30aa\:30e9\:30a4\:30bf\:30fc\:3067\:3059\:3002\:4ee5\:4e0b\:306e\:300c\:30b9\:30e9\:30a4\:30c9\:6307\:793a\:300d\:306b\:5f93\:3044\:3001\:30b9\:30e9\:30a4\:30c9\:3092\:53b3\:5bc6\:306a\:66f8\:5f0f\:306e Markdown \:3060\:3051\:3067\:51fa\:529b\:3057\:3066\:304f\:3060\:3055\:3044\:3002\n\n" <>
  "\:66f8\:5f0f(\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:30fb\:524d\:7f6e\:304d\:30fb\:8aac\:660e\:6587\:306f\:4e00\:5207\:51fa\:529b\:3057\:306a\:3044):\n" <>
  "## \:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb {expected=\:767a\:8868\:60f3\:5b9a\:79d2\:6570}\n" <>
  "- \:30ec\:30d9\:30eb1\:9805\:76ee\n  - \:30ec\:30d9\:30eb2\:9805\:76ee(\:30a4\:30f3\:30c7\:30f3\:30c82)\n    - \:30ec\:30d9\:30eb3\:9805\:76ee(\:30a4\:30f3\:30c7\:30f3\:30c84)\n" <>
  "> \:76f4\:524d\:306e\:9805\:76ee\:306b\:5bfe\:3059\:308b\:8aac\:660e\:6bb5\:843d\n" <>
  "\:5730\:306e\:6587\n" <>
  "cite: \:51fa\:5178 (URL \:307e\:305f\:306f (\:8457\:8005\:540d, \:5e74))\n" <>
  If[nKeep > 0,
    "<<FIG1>> \:301c <<FIG" <> ToString[nKeep] <> ">> : \:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:3092\:305d\:306e\:4f4d\:7f6e\:306b\:4fdd\:6301\:3059\:308b\:30c8\:30fc\:30af\:30f3(\:884c\:5358\:72ec\:3067\:7f6e\:304f)\n", ""] <>
  "\n\:898f\:5247:\n" <>
  "- \:901a\:5e38\:306f 1 \:679a(## \:306f 1 \:500b)\:3002\:6307\:793a\:3067\:8907\:6570\:679a\:306b\:5206\:3051\:308b\:3088\:3046\:6c42\:3081\:3089\:308c\:305f\:5834\:5408\:306e\:307f\:8907\:6570\:306e ## \:3092\:51fa\:529b\:3059\:308b\:3002\n" <>
  "- \:8ad6\:6587\:30fbweb\:30fbPDF \:7531\:6765\:306e\:56f3\:30fb\:5f15\:7528\:30fb\:30c7\:30fc\:30bf\:3092\:4f7f\:3046\:5834\:5408\:306f\:3001\:76f4\:5f8c\:306b cite: \:884c\:3067\:51fa\:5178(URL \:307e\:305f\:306f (\:8457\:8005, \:5e74))\:3092\:5fc5\:305a\:660e\:8a18\:3059\:308b\:3002\n" <>
  If[nKeep > 0,
    "- \:65e2\:5b58\:56f3\:30c8\:30fc\:30af\:30f3 <<FIGn>> \:306f\:3001\:524a\:9664\:306e\:6307\:793a\:304c\:306a\:3044\:9650\:308a\:3059\:3079\:3066\:9069\:5207\:306a\:4f4d\:7f6e\:306b\:914d\:7f6e\:3059\:308b\:3002\n", ""] <>
  "- \:7b87\:6761\:66f8\:304d\:306f\:7c21\:6f54\:306b\:30021 \:679a\:3042\:305f\:308a 6\:301c10 \:884c\:7a0b\:5ea6\:306b\:53ce\:3081\:308b\:3002\n" <>
  "- Directives / Dictionary \:304c\:3042\:308c\:3070\:53b3\:5b88\:3059\:308b\:3002\n\n" <>
  If[StringTrim[currentMd] =!= "",
    "\:73fe\:5728\:306e\:30b9\:30e9\:30a4\:30c9\:5185\:5bb9(\:3053\:308c\:3092\:5c0a\:91cd\:3057\:3064\:3064\:6307\:793a\:306b\:5f93\:3063\:3066\:66f4\:65b0\:3059\:308b):\n" <> currentMd <> "\n\n", ""] <>
  "\:30b9\:30e9\:30a4\:30c9\:6307\:793a:\n" <> promptText;

(* LLM \:5fdc\:7b54\:3092\:30b7\:30ca\:30ea\:30aa Markdown \:306b\:6b63\:898f\:5316\:3059\:308b: \:30d5\:30a7\:30f3\:30b9\:9664\:53bb + \:5148\:982d ## \:4fdd\:8a3c *)
iSWNormalizeScenarioResponse[resp_String, title_String] := Module[{t},
  t = StringRiffle[
    Select[StringSplit[StringReplace[resp, "\r\n" -> "\n"], "\n"],
      !StringStartsQ[StringTrim[#], "```"] &], "\n"];
  t = StringTrim[t];
  Module[{pos = StringPosition[t, StartOfLine ~~ "## "]},
    If[pos === {},
      t = "## " <> If[title === "", iSL["\:30b9\:30e9\:30a4\:30c9", "Slide"], title] <> "\n" <> t,
      t = StringDrop[t, First[pos][[1]] - 1]]];
  t];

(* ---- \:5c55\:958b\:306e\:5b9f\:884c\:7d4c\:8def: Agent(\:65e2\:5b9a) = ClaudeEval/ClaudeRuntime \:59d4\:8b72 / Direct = \:8efd\:91cf\:76f4\:63a5 LLM ---- *)
If[!ValueQ[$SlideExpandMode], $SlideExpandMode = "Agent"];
$SlideTargetNotebook = None;

iSWAgentAvailableQ[] := Length[DownValues[ClaudeCode`ClaudeEval]] > 0;

iSWResolveTargetNb[] := If[Head[$SlideTargetNotebook] === NotebookObject &&
    TrueQ[Quiet[MemberQ[Notebooks[], $SlideTargetNotebook]]],
  $SlideTargetNotebook, Quiet[InputNotebook[]]];

(* \:30b9\:30e9\:30a4\:30c9 slideNo \:306e\:6750\:6599\:4e00\:5f0f\:3092\:53ce\:96c6\:3059\:308b *)
iSWSlideContext[nb_, slideNo_Integer] := Module[
  {ranges, start, end, cells, exprs, promptPos, promptText, title, md, keeps},
  ranges = iSWSlideRanges[nb];
  If[!(1 <= slideNo <= Length[ranges]), Return[$Failed]];
  {start, end} = ranges[[slideNo]];
  cells = Cells[nb];
  exprs = Flatten[{NotebookRead[cells[[start ;; end]]]}];
  promptPos = FirstPosition[exprs, Cell[_, "SlidePrompt", ___], None, {1}, Heads -> False];
  promptText = If[promptPos === None, None, iCellText[exprs[[First[promptPos]]]]];
  title = iSlideTitle[exprs];
  {md, keeps} = iSWSlideToMarkdown[exprs];
  <|"SlideNo" -> slideNo, "Start" -> start, "End" -> end, "Exprs" -> exprs,
    "PromptText" -> promptText, "Title" -> title, "Md" -> md, "Keeps" -> keeps|>];

(* \:65b0\:898f\:56f3\:3092\:8cbc\:308a\:4ed8\:3051\:7528\:30bb\:30eb\:3078\:6b63\:898f\:5316\:3059\:308b *)
iSWFigureCell[g_] := Which[
  MatchQ[g, _Cell], g,
  ImageQ[g], Cell[BoxData[ToBoxes[Image[g, ImageSize -> 560]]], "Input", TextAlignment -> Center],
  MatchQ[g, _Graphics | _Graphics3D], Cell[BoxData[ToBoxes[Show[g, ImageSize -> 560]]], "Input", TextAlignment -> Center],
  True, Cell[BoxData[ToBoxes[g]], "Input", TextAlignment -> Center]];

(* ---- SlideApplyScenario: \:30b9\:30e9\:30a4\:30c9\:5dee\:3057\:66ff\:3048\:306e\:552f\:4e00\:306e\:6c7a\:5b9a\:7684\:66f8\:8fbc\:307f\:53e3 ---- *)
Options[SlideApplyScenario] = {"Figures" -> {}};

SlideApplyScenario[slideNo_Integer, md_String, opts : OptionsPattern[]] :=
  With[{nb = iSWResolveTargetNb[]},
    If[Head[nb] =!= NotebookObject,
      Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>],
      SlideApplyScenario[nb, slideNo, md, opts]]];

SlideApplyScenario[nb_NotebookObject, slideNo_Integer, md_String, OptionsPattern[]] := Module[
  {ctx, figs, allKeeps, mdText, sc, slides, newCells, cells},
  ctx = iSWSlideContext[nb, slideNo];
  If[ctx === $Failed,
    Return[Failure["SlideOutOfRange",
      <|"MessageTemplate" -> "slide `1` not found (deck has fewer slides)",
        "MessageParameters" -> {slideNo}|>]]];
  figs = iSWFigureCell /@ Flatten[{OptionValue["Figures"]}];
  allKeeps = Join[ctx["Keeps"], figs];
  mdText = iSWNormalizeScenarioResponse[md, ctx["Title"]];
  sc = Quiet[SlideScenarioFromMarkdown[mdText]];
  slides = If[AssociationQ[sc], Lookup[sc, "Slides", {}], {}];
  If[slides === {},
    Return[Failure["BadScenario",
      <|"MessageTemplate" -> "scenario md has no slides (missing \"## title\" line?)"|>]]];
  newCells = Block[{$iSlideKeepCells = allKeeps}, iBuildSlideCells /@ slides];
  If[StringQ[ctx["PromptText"]] && StringTrim[ctx["PromptText"]] =!= "",
    newCells[[1]] = Insert[newCells[[1]], iSWPromptCell[ctx["PromptText"]], 3]];
  cells = Cells[nb];
  (* \:633f\:5165\:2192\:524a\:9664\:306e\:9806\:3067\:7f6e\:63db\:3057\:3001\:6700\:5f8c\:306b\:9078\:629e\:3092\:672b\:5c3e(Appendix)\:3078\:9000\:907f\:3059\:308b\:3002
     \:524a\:9664\:5f8c\:306e\:30ad\:30e3\:30ec\:30c3\:30c8\:4f4d\:7f6e\:306b\:4f9d\:5b58\:3059\:308b\:3068\:3001runtime \:306e\:5f8c\:7d9a\:66f8\:304d\:8fbc\:307f(\:63d0\:6848\:30a8\:30b3\:30fc\:7b49)\:304c
     \:30b9\:30e9\:30a4\:30c9\:5185\:306e\:30bb\:30eb\:3078\:98df\:3044\:8fbc\:3080\:4e8b\:6545\:304c\:8d77\:304d\:308b(NB \:5b9f\:6a5f\:3067\:767a\:751f)\:3002 *)
  SelectionMove[cells[[ctx["Start"]]], Before, Cell];
  NotebookWrite[nb, Flatten[newCells, 1]];
  NotebookDelete[cells[[ctx["Start"] ;; ctx["End"]]]];
  SelectionMove[nb, After, Notebook];
  iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo] <> " \:3092\:66f4\:65b0\:3057\:307e\:3057\:305f (" <> ToString[Length[slides]] <> " \:679a)",
    "Updated slide " <> ToString[slideNo] <> " (" <> ToString[Length[slides]] <> " slides)"]];
  iSWStatusClearLater[nb];
  Success["SlideApplied", <|
    "Slides" -> Length[slides],
    "ExistingFigures" -> Length[ctx["Keeps"]],
    "NewFigures" -> Length[figs]|>]];

(* ---- \:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:7528\:30bf\:30b9\:30af\:6587 (ClaudeEval \:306b\:6e21\:3059) ---- *)
iSWExpandAgentTask[slideNo_, promptText_, title_, md_, k_] :=
  "SlideWorkflow \:306e\:30b9\:30e9\:30a4\:30c9\:7de8\:96c6\:30bf\:30b9\:30af\:3002\:3053\:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo] <>
  If[StringQ[title] && title =!= "", "(\:30bf\:30a4\:30c8\:30eb:\:300c" <> title <> "\:300d)", ""] <>
  " \:3092\:4ee5\:4e0b\:306e\:6307\:793a\:3067\:66f4\:65b0\:3059\:308b\:3002\n\n" <>
  "\:30b9\:30e9\:30a4\:30c9\:6307\:793a:\n" <> promptText <> "\n\n" <>
  If[StringTrim[md] =!= "",
    "\:73fe\:5728\:306e\:30b9\:30e9\:30a4\:30c9\:5185\:5bb9(\:30b7\:30ca\:30ea\:30aa md" <>
      If[k > 0, "\:3002<<FIG1>>\:301c<<FIG" <> ToString[k] <>
        ">> \:306f\:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb", ""] <> "):\n" <> md <> "\n\n", ""] <>
  "\:624b\:9806(\:53b3\:5b88):\n" <>
  "1. \:6307\:793a\:306b\:5f93\:3063\:3066\:65b0\:3057\:3044\:30b7\:30ca\:30ea\:30aa md \:3092\:69cb\:6210\:3059\:308b(\:66f8\:5f0f\:306f SlideWorkflow api.md \:306e\:901a\:308a: \"## \:30bf\:30a4\:30c8\:30eb {expected=\:79d2}\" / \"- \" \:7b87\:6761\:66f8\:304d(\:30a4\:30f3\:30c7\:30f3\:30c82/4\:3067\:4e0b\:4f4d) / \"> \" \:8aac\:660e\:6bb5\:843d / \:5730\:306e\:6587 / \"cite: \:51fa\:5178\" / \"<<FIGn>>\")\:3002\:901a\:5e38\:306f 1 \:679a\:3002\:6307\:793a\:3067\:6c42\:3081\:3089\:308c\:305f\:5834\:5408\:306e\:307f\:8907\:6570\:306e ## \:306b\:5206\:5272\:3059\:308b\:3002\n" <>
  "2. \:8ad6\:6587\:30fbweb\:30fbPDF \:7531\:6765\:306e\:56f3\:30fb\:5f15\:7528\:30fb\:30c7\:30fc\:30bf\:306b\:306f\:76f4\:5f8c\:306b cite: \:884c\:3067\:51fa\:5178(URL \:307e\:305f\:306f (\:8457\:8005, \:5e74))\:3092\:5fc5\:305a\:660e\:8a18\:3059\:308b\:3002\:5185\:5bb9\:306e\:78ba\:8a8d\:304c\:5fc5\:8981\:306a\:3089\:691c\:7d22(SourceVault / pdfSearch / web)\:3092\:4f7f\:3063\:3066\:3088\:3044\:3002\n" <>
  If[k > 0, "3. \:65e2\:5b58\:56f3 <<FIG1>>\:301c<<FIG" <> ToString[k] <> ">> \:306f\:524a\:9664\:306e\:6307\:793a\:304c\:306a\:3044\:9650\:308a\:9069\:5207\:306a\:4f4d\:7f6e\:306b\:6b8b\:3059\:3002\n", ""] <>
  "4. \:65b0\:3057\:3044\:56f3\:304c\:5fc5\:8981\:306a\:5834\:5408\:306e\:307f Wolfram \:8a00\:8a9e\:306e Graphics \:3067\:4f5c\:56f3\:3059\:308b(\:914d\:8272\:306f SlideThemeColor[\"Title\"|\"Bullet\"|\"SubBullet\"|\"Dim\"|\"Arrow\"|\"PanelBackground\"|\"PanelBorder\"]\:3001\:30d5\:30a9\:30f3\:30c8\:306f FontFamily->$SlideFontFamily\:3001\:88dc\:52a9\:5b9a\:7fa9\:306f\:5fc5\:305a Module \:5185)\:3002\:56f3\:306e\:751f\:6210\:306b\:8ab2\:91d1 API(LLMSynthesize / ImageSynthesize \:7b49)\:3092\:4f7f\:308f\:306a\:3044\:3053\:3068\:3002\:65b0\:898f\:56f3\:306f md \:4e2d\:3067 <<FIG" <> ToString[k + 1] <> ">> \:4ee5\:964d\:306e\:30c8\:30fc\:30af\:30f3\:3068\:3057\:3066\:53c2\:7167\:3059\:308b\:3002\n" <>
  "5. \:6700\:5f8c\:306b SlideApplyScenario[" <> ToString[slideNo] <> ", md] \:3092\:4e00\:5ea6\:3060\:3051\:8a55\:4fa1\:3057\:3066\:9069\:7528\:3059\:308b(\:65b0\:898f\:56f3\:304c\:3042\:308c\:3070 SlideApplyScenario[" <> ToString[slideNo] <> ", md, \"Figures\"->{g1, ...}] \:306e\:5f62\:3067\:3001md \:306e <<FIG" <> ToString[k + 1] <> ">> \:4ee5\:964d\:3068\:540c\:9806\:306b\:6e21\:3059)\:3002\:3053\:308c\:304c\:30b9\:30e9\:30a4\:30c9\:3078\:306e\:552f\:4e00\:306e\:66f8\:8fbc\:307f\:624b\:6bb5\:3067\:3042\:308a\:3001NotebookWrite \:7b49\:3067\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:63a5\:7de8\:96c6\:3057\:3066\:306f\:306a\:3089\:306a\:3044\:3002\n" <>
  "6. \:623b\:308a\:5024\:304c Failure \:306a\:3089 md \:3092\:4fee\:6b63\:3057\:3066 SlideApplyScenario \:3092\:518d\:8a55\:4fa1\:3059\:308b\:3002Success[\"SlideApplied\", ...] \:304c\:8fd4\:308c\:3070\:5b8c\:4e86\:3002";

(* \:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:304c\:7121\:3051\:308c\:3070\:672b\:5c3e\:306b\:8ffd\:52a0\:3059\:308b (\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306e\:8ffd\:8de1\:30bb\:30eb\:3092 Appendix \:306b\:7f6e\:304f\:305f\:3081) *)
iSWEnsureEndMarkerAtEnd[nb_] := Module[{styles = iSWCellStyles[nb], cells = Cells[nb], nav},
  nav = Flatten[Position[styles, "SlideShowNavigationBar"]];
  If[!AnyTrue[nav, !FreeQ[{iSWCellTags[cells[[#]]]}, "SlideDeckEnd"] &],
    SelectionMove[nb, After, Notebook];
    NotebookWrite[nb, {iEndMarkerCell[], iEndMarkerLabelCell[]}]]];

(* prompt \:30bb\:30eb\:304c\:7121\:3044\:30b9\:30e9\:30a4\:30c9\:3067\:306f\:9078\:629e\:30bb\:30eb\:3092 SlidePrompt \:30bb\:30eb\:306b\:5909\:63db\:3059\:308b *)
iSWEnsurePromptCell[nb_, selIdx_, ctx_] := Module[{text, cells},
  If[StringQ[ctx["PromptText"]], Return[ctx]];
  text = iCellText[ctx["Exprs"][[selIdx - ctx["Start"] + 1]]];
  If[!StringQ[text] || StringTrim[text] === "", Return[$Failed]];
  cells = Cells[nb];
  SelectionMove[cells[[selIdx]], All, Cell];
  NotebookWrite[nb, iSWPromptCell[text], All];
  iSWSlideContext[nb, ctx["SlideNo"]]];

SlideExpand[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideExpand[nb]]];

SlideExpand[nb_NotebookObject] := Module[{selIdx, r, slideNo, ctx},
  selIdx = iSWSelectedIndex[nb];
  If[selIdx === None, iSWNoSlideDialog[]; Return[$Failed]];
  r = iSWSlideOfIndex[nb, selIdx];
  If[r === $Failed, iSWNoSlideDialog[]; Return[$Failed]];
  slideNo = First[r];
  ctx = iSWSlideContext[nb, slideNo];
  ctx = iSWEnsurePromptCell[nb, selIdx, ctx];
  If[ctx === $Failed,
    MessageDialog[iSL[
      "\:30d7\:30ed\:30f3\:30d7\:30c8\:304c\:7a7a\:3067\:3059\:3002SlidePrompt \:30bb\:30eb\:306b\:6307\:793a\:3092\:66f8\:304f\:304b\:3001\:6307\:793a\:3092\:66f8\:3044\:305f\:30bb\:30eb\:3092\:9078\:629e\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
      "Empty prompt. Write instructions in a SlidePrompt cell or select a cell containing them."]];
    Return[$Failed]];
  If[$SlideExpandMode === "Agent" && iSWAgentAvailableQ[],
    iSWExpandViaAgent[nb, slideNo, ctx],
    iSWExpandDirect[nb, slideNo, ctx]]];

(* Agent \:7d4c\:8def: ClaudeEval \:30bb\:30eb\:3092 Appendix \:306b\:66f8\:3044\:3066\:8a55\:4fa1\:3059\:308b\:3002
   ClaudeRuntime \:30a2\:30c0\:30d7\:30bf(\:30c4\:30fc\:30eb\:30fb\:691c\:7d22\:30fb\:627f\:8a8d\:30b2\:30fc\:30c8\:30fbSourceVault \:8a18\:9332)\:7d4c\:7531\:3067\:5b9f\:884c\:3055\:308c\:3001
   \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306f\:6700\:5f8c\:306b SlideApplyScenario \:3092\:547c\:3093\:3067\:9069\:7528\:3059\:308b\:3002 *)
(* ClaudeEval \:547c\:3073\:51fa\:3057\:30bb\:30eb\:3002PromptRouter/\:81ea\:7136\:30c7\:30a3\:30b9\:30d1\:30c3\:30c1\:3092 Block \:3067\:78ba\:5b9f\:306b
   \:30d0\:30a4\:30d1\:30b9\:3059\:308b(\:30bf\:30b9\:30af\:6587\:4e2d\:306e\:300c\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:300d\:7b49\:306b\:6c7a\:5b9a\:8ad6\:30eb\:30fc\:30c8\:304c\:8aa4\:53cd\:5fdc\:3057\:3066
   \:30b9\:30b1\:30b8\:30e5\:30fc\:30eb\:4e00\:89a7\:7b49\:3078\:8aa4\:30eb\:30fc\:30c6\:30a3\:30f3\:30b0\:3055\:308c\:305f\:5b9f\:4f8b\:3078\:306e\:5bfe\:51e6\:3002
   \:30c7\:30a3\:30b9\:30d1\:30c3\:30c1\:5224\:5b9a\:306f ClaudeEval \:5165\:53e3\:3067\:540c\:671f\:5b9f\:884c\:3055\:308c\:308b\:305f\:3081 Block \:304c\:52b9\:304f)\:3002 *)
iSWAgentEvalCell[task_String] := Module[{boxes},
  boxes = With[{t = task},
    MakeBoxes[Block[{ClaudeCode`$ClaudeEvalPromptRouterDispatch = False,
        ClaudeCode`$ClaudeEvalNaturalDispatch = False,
        ClaudeCode`$ClaudeEvalMode = "Single"},
      ClaudeCode`ClaudeEval[t]], StandardForm]];
  Cell[BoxData[boxes], "Input"]];

iSWExpandViaAgent[nb_, slideNo_, ctx_] := Module[{task},
  $SlideTargetNotebook = nb;
  iSWEnsureEndMarkerAtEnd[nb];
  task = iSWExpandAgentTask[slideNo, StringTrim[ctx["PromptText"]], ctx["Title"],
    ctx["Md"], Length[ctx["Keeps"]]];
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, iSWAgentEvalCell[task], All];
  SelectionEvaluate[nb];
  iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo] <> " \:306e\:5c55\:958b\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72 (\:8ffd\:8de1\:306f\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d)",
    "Delegated slide " <> ToString[slideNo] <> " expansion to agent (see cells after end marker)"]];
];

(* Direct \:7d4c\:8def: \:8efd\:91cf\:306a\:76f4\:63a5 LLM (\:65e7\:65b9\:5f0f)\:3002\:30c4\:30fc\:30eb\:7121\:3057\:30fb\:30c6\:30ad\:30b9\:30c8\:751f\:6210\:306e\:307f *)
iSWExpandDirect[nb_, slideNo_, ctx_] := Module[{meta, prompt},
  If[!iSWRequireLLM[], Return[$Failed]];
  meta = iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb];
  prompt = iSWExpandPrompt[StringTrim[ctx["PromptText"]], ctx["Title"], ctx["Md"],
    Length[ctx["Keeps"]], meta];
  iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9\:5c55\:958b\:4e2d...", "Expanding slide..."]];
  With[{nb2 = nb, sn = slideNo},
    NBAccess`$NBLLMQueryFunc[prompt,
      Function[resp, iSWApplyExpand[nb2, sn, resp]],
      nb2, Fallback -> iSWFallback[]]];
];

iSWApplyExpand[nb_, slideNo_, resp_] := Module[{res},
  If[!StringQ[resp] || StringStartsQ[resp, "Error"] || StringStartsQ[resp, "[ERROR]"],
    iSWStatus[nb, iSL["\:5c55\:958b\:30a8\:30e9\:30fc", "Expand error"]]; iSWStatusClearLater[nb];
    Return[$Failed]];
  res = SlideApplyScenario[nb, slideNo, resp];
  If[!MatchQ[res, _Success],
    iSWStatus[nb, iSL["\:5c55\:958b\:30a8\:30e9\:30fc(\:66f8\:5f0f\:4e0d\:6b63)", "Expand error (bad format)"]];
    iSWStatusClearLater[nb]];
  res];

(* ===================== \:82f1\:8a33 (LLM) ===================== *)

iSWTranslatePrompt[numbered_, lang_, metaBlocks_] :=
  metaBlocks <>
  "\:4ee5\:4e0b\:306e\:756a\:53f7\:4ed8\:304d\:5404\:30a8\:30f3\:30c8\:30ea\:3092 " <> lang <> " \:306b\:7ffb\:8a33\:3057\:3066\:304f\:3060\:3055\:3044\:3002\n" <>
  "- \:51fa\:529b\:306f\:5404\:30a8\:30f3\:30c8\:30ea\:306b\:3064\:304d 1 \:884c\:3001\"[n] \:8a33\:6587\" \:306e\:5f62\:5f0f\:3002\:756a\:53f7\:3092\:5909\:3048\:306a\:3044\:30fb\:5897\:6e1b\:3057\:306a\:3044\:3002\n" <>
  "- \:8a33\:6587\:5185\:306e\:6539\:884c\:306f \\n \:3068\:66f8\:304f\:3002\n" <>
  "- \:8a18\:53f7\:30fb\:6570\:5f0f\:30fb\:30b3\:30fc\:30c9\:65ad\:7247\:30fb\:6570\:5024\:30fb\:56fa\:6709\:540d\:8a5e\:306e\:8868\:8a18\:306f\:4fdd\:6301\:3059\:308b\:3002\n" <>
  "- Dictionary \:306e\:7528\:8a9e\:5bfe\:5fdc\:3092\:53b3\:5b88\:3059\:308b\:3002\n" <>
  "- \:7ffb\:8a33\:4ee5\:5916\:306e\:8aac\:660e\:30fb\:524d\:7f6e\:304d\:3092\:51fa\:529b\:3057\:306a\:3044\:3002\n\n" <>
  numbered;

iSWParseNumbered[resp_String] := Module[{parts, assoc = <||>, i},
  parts = StringSplit[StringReplace[resp, "\r\n" -> "\n"],
    StartOfLine ~~ "[" ~~ d : DigitCharacter .. ~~ "]" :> ToExpression[d]];
  (* parts = {\:524d\:7f6e\:304d?, n1, seg1, n2, seg2, ...} *)
  i = SelectFirst[Range[Length[parts]], IntegerQ[parts[[#]]] &, None];
  If[i === None, Return[<||>]];
  Do[
    If[IntegerQ[parts[[k]]] && k + 1 <= Length[parts] && StringQ[parts[[k + 1]]],
      assoc[parts[[k]]] = StringReplace[StringTrim[parts[[k + 1]]], "\\n" -> "\n"]],
    {k, i, Length[parts]}];
  assoc];

SlideTranslate[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideTranslate[nb]]];

SlideTranslate[nb_NotebookObject] := Module[{sn = iSWCurrentSlideNo[nb]},
  If[!iSWRequireLLM[], Return[$Failed]];
  If[sn === $Failed, iSWNoSlideDialog[]; Return[$Failed]];
  iSWTranslateSlideNo[nb, sn, None]];

iSWTranslateSlideNo[nb_, slideNo_, cont_] := Module[
  {ranges, start, end, styles, cells, idxs, texts, nonEmpty, numbered, meta, prompt},
  ranges = iSWSlideRanges[nb];
  If[slideNo > Length[ranges], If[cont =!= None, cont[]]; Return[$Failed]];
  {start, end} = ranges[[slideNo]];
  styles = iSWCellStyles[nb];
  cells = Cells[nb];
  Quiet[NBAccess`NBInvalidateCellsCache[nb]];
  idxs = Select[Range[start, end],
    MemberQ[$iSWTranslatableStyles, styles[[#]]] &&
      FreeQ[{iSWCellTags[cells[[#]]]}, "Citation"] &];
  texts = Quiet[NBAccess`NBCellGetText[nb, #]] & /@ idxs;
  nonEmpty = Select[Range[Length[idxs]],
    StringQ[texts[[#]]] && StringTrim[texts[[#]]] =!= "" &];
  If[nonEmpty === {},
    If[cont =!= None, cont[], iSWStatus[nb, iSL["\:7ffb\:8a33\:5bfe\:8c61\:304c\:3042\:308a\:307e\:305b\:3093", "Nothing to translate"]];
      iSWStatusClearLater[nb]];
    Return[Null]];
  numbered = StringRiffle[
    MapIndexed["[" <> ToString[First[#2]] <> "] " <>
      StringReplace[texts[[#1]], "\n" -> "\\n"] &, nonEmpty], "\n"];
  meta = iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb];
  prompt = iSWTranslatePrompt[numbered, $SlideTranslationLanguage, meta];
  iSWStatus[nb, iSL["\:7ffb\:8a33\:4e2d: \:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo],
    "Translating slide " <> ToString[slideNo]]];
  With[{nb2 = nb, tidxs = idxs[[nonEmpty]], torigs = texts[[nonEmpty]], c = cont},
    NBAccess`$NBLLMQueryFunc[prompt,
      Function[resp, iSWApplyTranslate[nb2, tidxs, torigs, resp, c]],
      nb2, Fallback -> iSWFallback[]]];
];

iSWApplyTranslate[nb_, idxs_, origs_, resp_, cont_] := Module[{assoc, old},
  If[!StringQ[resp] || StringStartsQ[resp, "Error"] || StringStartsQ[resp, "[ERROR]"],
    iSWStatus[nb, iSL["\:7ffb\:8a33\:30a8\:30e9\:30fc", "Translate error"]]; iSWStatusClearLater[nb];
    Return[$Failed]];
  assoc = iSWParseNumbered[resp];
  Quiet[NBAccess`NBInvalidateCellsCache[nb]];
  Do[
    If[KeyExistsQ[assoc, k] && StringTrim[assoc[k]] =!= "",
      old = Quiet[NBAccess`NBCellGetTaggingRule[nb, idxs[[k]], "SWOrigText"]];
      If[!StringQ[old] || old === "",
        Quiet[NBAccess`NBCellSetTaggingRule[nb, idxs[[k]], "SWOrigText", origs[[k]]]]];
      Quiet[NBAccess`NBCellWriteText[nb, idxs[[k]], assoc[k]]];
      Pause[0.03]],
    {k, Length[idxs]}];
  If[cont =!= None, cont[],
    iSWStatus[nb, iSL["\:7ffb\:8a33\:5b8c\:4e86", "Translation complete"]]; iSWStatusClearLater[nb]];
];

SlideTranslateRevert[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideTranslateRevert[nb]]];

SlideTranslateRevert[nb_NotebookObject] := Module[{sn, ranges, start, end, o},
  sn = iSWCurrentSlideNo[nb];
  If[sn === $Failed, iSWNoSlideDialog[]; Return[$Failed]];
  ranges = iSWSlideRanges[nb];
  {start, end} = ranges[[sn]];
  Quiet[NBAccess`NBInvalidateCellsCache[nb]];
  Do[
    o = Quiet[NBAccess`NBCellGetTaggingRule[nb, i, "SWOrigText"]];
    If[StringQ[o] && o =!= "",
      Quiet[NBAccess`NBCellWriteText[nb, i, o]];
      Quiet[NBAccess`NBCellSetTaggingRule[nb, i, "SWOrigText", ""]];
      Pause[0.03]],
    {i, start, end}];
  iSWStatus[nb, iSL["\:539f\:6587\:306b\:623b\:3057\:307e\:3057\:305f", "Reverted to original"]];
  iSWStatusClearLater[nb];
];

SlideTranslateDeck[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideTranslateDeck[nb]]];

SlideTranslateDeck[nb_NotebookObject] := Module[{n},
  If[!iSWRequireLLM[], Return[$Failed]];
  n = Length[iSWSlideRanges[nb]];
  If[n === 0, iSWNoSlideDialog[]; Return[$Failed]];
  iSWTranslateChain[nb, 1, n]];

iSWTranslateChain[nb_, k_, n_] :=
  If[k > n,
    iSWStatus[nb, iSL["\:5168 " <> ToString[n] <> " \:30b9\:30e9\:30a4\:30c9\:3092\:7ffb\:8a33\:3057\:307e\:3057\:305f",
      "Translated all " <> ToString[n] <> " slides"]];
    iSWStatusClearLater[nb],
    iSWTranslateSlideNo[nb, k,
      Function[iSWTranslateChain[nb, k + 1, n]]]];

(* ===================== \:633f\:5165\:30b3\:30de\:30f3\:30c9 ===================== *)

(* documentation.wl \:4e92\:63db\:306e\:30e1\:30bf\:30bb\:30eb\:3002Documentation` \:304c\:3042\:308c\:3070\:59d4\:8b72\:3059\:308b *)

$iSWNoteCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.7, 0.63, 0.35],
  Background -> RGBColor[0.98, 0.96, 0.9], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.7, 0.63, 0.35]]};
$iSWDirectiveCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.65, 0.35, 0.5],
  Background -> RGBColor[0.97, 0.93, 0.95], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.65, 0.35, 0.5]]};
$iSWDictionaryCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.35, 0.65, 0.65],
  Background -> RGBColor[0.92, 0.96, 0.96], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.35, 0.65, 0.65]]};
$iSWBibliographyCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.4, 0.45, 0.6],
  Background -> RGBColor[0.93, 0.94, 0.97], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.4, 0.45, 0.6]]};

iSWInsertMeta[nb_, docFn_String, style_String, text_String, opts_List] :=
  If[iSWDocLoadedQ[docFn],
    Symbol["Documentation`" <> docFn][nb],
    NotebookWrite[nb, Cell[text, style, Sequence @@ opts]]];

SlideInsertNote[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertNote[nb]]];
SlideInsertNote[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertNote", "Note",
  iSL["\:3053\:3053\:3078\:306f\:30e1\:30e2\:306a\:3069\:3092\:66f8\:304f...", "Write notes here..."], $iSWNoteCellOpts];

SlideInsertDirective[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertDirective[nb]]];
SlideInsertDirective[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertDirective", "Directive",
  iSL["\:3053\:3053\:306b LLM \:3078\:306e\:6307\:793a\:3092\:8a18\:8f09...", "Write LLM directives here..."], $iSWDirectiveCellOpts];

SlideInsertDictionary[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertDictionary[nb]]];
SlideInsertDictionary[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertDictionary", "Dictionary",
  "{{<<Japanese>>, <<English>>, <<Context>>}, {\"\:7528\:8a9e1\", \"term1\", \"\:6587\:8108\"}}",
  $iSWDictionaryCellOpts];

SlideInsertBibliography[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertBibliography[nb]]];
SlideInsertBibliography[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertBibliography", "Bibliography",
  "{{<<Key>>, <<Author>>, <<Year>>, <<Title>>}, {\"key\", \"author\", \"year\", \"title\"}}",
  $iSWBibliographyCellOpts];

SlideInsertPrompt[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertPrompt[nb]]];
SlideInsertPrompt[nb_NotebookObject] := NotebookWrite[nb, iSWPromptCell[
  iSL["\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:4f1d\:3048\:305f\:3044\:5185\:5bb9(\:30d7\:30ed\:30f3\:30d7\:30c8)\:3092\:66f8\:304d\:3001\:300c\:5c55\:958b\:300d\:3092\:62bc\:3059\:3002",
    "Write the prompt for this slide here and press Expand."]]];

SlideInsertCitation[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertCitation[nb]]];
SlideInsertCitation[nb_NotebookObject] := NotebookWrite[nb,
  SlideWorkflow`Private`iContentCell[{"Cite", "(Author, Year) / URL"}]];

SlideInsertEndMarker[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertEndMarker[nb]]];
SlideInsertEndMarker[nb_NotebookObject] := Module[{styles, cells, nav},
  styles = iSWCellStyles[nb]; cells = Cells[nb];
  nav = Flatten[Position[styles, "SlideShowNavigationBar"]];
  If[AnyTrue[nav, !FreeQ[{iSWCellTags[cells[[#]]]}, "SlideDeckEnd"] &],
    MessageDialog[iSL["\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:306f\:65e2\:306b\:5b58\:5728\:3057\:307e\:3059\:3002", "End marker already exists."]];
    Return[$Failed]];
  NotebookWrite[nb, {SlideWorkflow`Private`iEndMarkerCell[],
    SlideWorkflow`Private`iEndMarkerLabelCell[]}]];

SlideAddSlide[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideAddSlide[nb]]];
SlideAddSlide[nb_NotebookObject] := Module[{si, r, ranges, cells},
  cells = Cells[nb];
  si = iSWSelectedIndex[nb];
  r = If[si === None, $Failed, iSWSlideOfIndex[nb, si]];
  Which[
    r =!= $Failed, (* \:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:76f4\:5f8c *)
    SelectionMove[cells[[r[[3]]]], After, Cell];
    NotebookWrite[nb, iSWSkeletonSlideCells[]],
    (ranges = iSWSlideRanges[nb]) =!= {}, (* \:6700\:7d42\:30b9\:30e9\:30a4\:30c9\:306e\:76f4\:5f8c *)
    SelectionMove[cells[[ranges[[-1, 2]]]], After, Cell];
    NotebookWrite[nb, iSWSkeletonSlideCells[]],
    True, (* \:30b9\:30e9\:30a4\:30c9\:304c\:7121\:3044: \:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e *)
    NotebookWrite[nb, iSWSkeletonSlideCells[]]];
];

$iSWPromptsOpen = True;
SlideTogglePrompts[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideTogglePrompts[nb]]];
SlideTogglePrompts[nb_NotebookObject] := Module[{styles, cells, idxs},
  styles = iSWCellStyles[nb]; cells = Cells[nb];
  idxs = Flatten[Position[styles, "SlidePrompt"]];
  If[idxs === {},
    iSWStatus[nb, iSL["SlidePrompt \:30bb\:30eb\:304c\:3042\:308a\:307e\:305b\:3093", "No SlidePrompt cells"]];
    iSWStatusClearLater[nb]; Return[Null]];
  $iSWPromptsOpen = !$iSWPromptsOpen;
  Do[Quiet[SetOptions[cells[[i]], CellOpen -> $iSWPromptsOpen]], {i, idxs}];
  iSWStatus[nb, iSL["\:30d7\:30ed\:30f3\:30d7\:30c8: " <> If[$iSWPromptsOpen, "\:8868\:793a", "\:975e\:8868\:793a"],
    "Prompts: " <> If[$iSWPromptsOpen, "shown", "hidden"]]];
  iSWStatusClearLater[nb];
];

(* ===================== \:66f8\:304d\:51fa\:3057\:30a2\:30af\:30b7\:30e7\:30f3 ===================== *)

iSWDeckBaseName[nb_] := Module[{fn = Quiet[NotebookFileName[nb]]},
  If[StringQ[fn], {DirectoryName[fn], FileBaseName[fn]},
    {$TemporaryDirectory, "slides_export"}]];

iSWExportImagesAction[nb_] := Module[{dir, base, imgs, files},
  {dir, base} = iSWDeckBaseName[nb];
  iSWStatus[nb, iSL["\:753b\:50cf\:66f8\:304d\:51fa\:3057\:4e2d...", "Exporting images..."]];
  imgs = SlideDeckImages[NotebookGet[nb]];
  If[!MatchQ[imgs, {__Image}],
    iSWStatus[nb, iSL["\:66f8\:304d\:51fa\:3057\:5931\:6557", "Export failed"]]; iSWStatusClearLater[nb];
    Return[$Failed]];
  Module[{d = FileNameJoin[{dir, base <> "_slides"}]},
    If[!DirectoryQ[d], CreateDirectory[d, CreateIntermediateDirectories -> True]];
    files = MapIndexed[
      Export[FileNameJoin[{d, StringPadLeft[ToString[#2[[1]]], 2, "0"] <> ".png"}], #1] &,
      imgs];
    iSWStatus[nb, iSL[ToString[Length[files]] <> " \:679a\:66f8\:304d\:51fa\:3057\:307e\:3057\:305f",
      "Exported " <> ToString[Length[files]] <> " images"]];
    iSWStatusClearLater[nb];
    Quiet[SystemOpen[d]];
    files]];

iSWExportVideoAction[nb_] := Module[{dir, base, imgs, out},
  {dir, base} = iSWDeckBaseName[nb];
  iSWStatus[nb, iSL["mp4 \:66f8\:304d\:51fa\:3057\:4e2d...", "Exporting mp4..."]];
  imgs = SlideDeckImages[NotebookGet[nb]];
  If[!MatchQ[imgs, {__Image}],
    iSWStatus[nb, iSL["\:66f8\:304d\:51fa\:3057\:5931\:6557", "Export failed"]]; iSWStatusClearLater[nb];
    Return[$Failed]];
  out = SlideDeckExportVideo[imgs, FileNameJoin[{dir, base <> ".mp4"}]];
  iSWStatus[nb, If[StringQ[out], iSL["mp4 \:5b8c\:4e86: " <> FileNameTake[out], "mp4 done: " <> FileNameTake[out]],
    iSL["mp4 \:5931\:6557", "mp4 failed"]]];
  iSWStatusClearLater[nb];
  out];

iSWOverviewAction[nb_] := Module[{ov = SlideDeckOverview[NotebookGet[nb]]},
  If[Head[ov] === Dataset,
    CreateDocument[{Cell[BoxData[ToBoxes[ov]], "Output"]},
      WindowTitle -> "Slide Overview", WindowSize -> {760, 520}],
    MessageDialog[iSL["\:4e00\:89a7\:3092\:53d6\:5f97\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f\:3002", "Could not build overview."]]]];

iSWExportScenarioAction[nb_] := Module[{dir, base, data, mdParts, md, out},
  {dir, base} = iSWDeckBaseName[nb];
  data = SlideDeckSlides[NotebookGet[nb]];
  If[data === $Failed, Return[$Failed]];
  mdParts = First[iSWSlideToMarkdown[#]] & /@ data["Slides"];
  md = StringRiffle[mdParts, "\n\n"];
  out = FileNameJoin[{dir, base <> "_scenario.md"}];
  Export[out, md, "Text", CharacterEncoding -> "UTF-8"];
  iSWStatus[nb, iSL["\:30b7\:30ca\:30ea\:30aa\:66f8\:51fa(\:6982\:7565): " <> FileNameTake[out],
    "Scenario draft: " <> FileNameTake[out]]];
  iSWStatusClearLater[nb];
  Quiet[SystemOpen[out]];
  out];

(* ===================== \:30d1\:30ec\:30c3\:30c8 ===================== *)

SetAttributes[iSWButton, HoldRest];
iSWButton[label_String, color_, action_] :=
  Button[Style[label, Bold, 9, White],
    CompoundExpression[action,
      With[{inb = InputNotebook[]},
        If[Head[inb] === NotebookObject, SetSelectedNotebook[inb]]]],
    Appearance -> "Frameless", Background -> color,
    ImageSize -> {100, 18}, FrameMargins -> {{4, 4}, {1, 1}},
    Method -> "Queued"];

SetAttributes[iSWButton2, HoldRest];
iSWButton2[label_String, color_, action_] :=
  Button[Style[label, Bold, 7, White],
    CompoundExpression[action,
      With[{inb = InputNotebook[]},
        If[Head[inb] === NotebookObject, SetSelectedNotebook[inb]]]],
    Appearance -> "Frameless", Background -> color,
    ImageSize -> {49, 18}, FrameMargins -> {{1, 1}, {1, 1}},
    Method -> "Queued"];

iSWButtonRow[b1_, b2_] :=
  Grid[{{b1, b2}}, Spacings -> 0.1, ItemSize -> {Automatic, Automatic}];

$iSWPalette = None;

(* P:/M: \:30e9\:30d9\:30eb\:306f kernel \:5074\:3067\:6587\:5b57\:5217\:5316\:3057\:3066\:81ea\:524d\:5909\:6570\:306b\:6301\:3061\:3001
   Dynamic \:306f TrackedSymbols \:3067\:305d\:306e\:5909\:6570\:3060\:3051\:3092\:975e\:540c\:671f\:8ffd\:8de1\:3059\:308b\:3002
   \:65e2\:5b9a\:306e Dynamic(\:6bce\:63cf\:753b\:3067 ClaudeCode \:95a2\:6570\:3092 preemptive \:8a55\:4fa1)\:306f
   \:5171\:6709 polling tick \:3068\:885d\:7a81\:3057\:3066 FE \:30d5\:30ea\:30fc\:30ba\:3092\:8d77\:3053\:3059
   (claudecode.wl Phase 32h \:3068\:540c\:4e00\:75c5\:7406\:3002\:5b9f\:969b\:306b\:767a\:751f\:3057\:305f)\:3002 *)
$iSWProviderLabel = "P: -";
$iSWModelLabel = "M: -";

iSWRefreshSettingsLabels[] := If[Length[DownValues[ClaudeCode`GetPaletteProvider]] > 0,
  $iSWProviderLabel = "P: " <> ToString[Quiet[Check[
    ClaudeCode`PaletteProviderLabel[ClaudeCode`GetPaletteProvider[]], "?"]]];
  $iSWModelLabel = "M: " <> ToString[Quiet[Check[
    ClaudeCode`PaletteShortenModelName[ClaudeCode`GetPaletteModelName[]], "?"]]]];

(* v1.2: "Safe"->True \:3067 ClaudeCode \:3068\:5b8c\:5168\:975e\:5e72\:6e09
   (LoadPaletteSettings \:3082 P:/M: \:8a2d\:5b9a\:6b04\:3082\:7701\:7565)\:3002\:30d5\:30ea\:30fc\:30ba\:5207\:308a\:5206\:3051\:7528 *)
$SlideWorkflowInteractiveVersion = "1.3";
Options[ShowSlidePalette] = {"Safe" -> False};

ShowSlidePalette[OptionsPattern[]] := Module[{safe = TrueQ[OptionValue["Safe"]]},
  If[$iSWPalette =!= None, Quiet[NotebookClose[$iSWPalette]]];
  If[!safe && Length[DownValues[ClaudeCode`LoadPaletteSettings]] > 0,
    Module[{initNb = Quiet[InputNotebook[]]},
      If[Head[initNb] === NotebookObject,
        Quiet[TimeConstrained[ClaudeCode`LoadPaletteSettings[initNb], 5]]]]];
  If[!safe, iSWRefreshSettingsLabels[]];
  $iSWPalette = Quiet[CreatePalette[
    Column[{
      Style["SlideWorkflow", Bold, 11, RGBColor[0.878, 0.486, 0.078]],

      Style[iSL[" \:30b9\:30e9\:30a4\:30c9", " Slides"], Bold, 8, GrayLevel[0.3]],
      iSWButtonRow[
        iSWButton2[iSL["\:ff0b\:30b9\:30e9\:30a4\:30c9", "+Slide"],
          RGBColor[0.2, 0.55, 0.35], SlideAddSlide[]],
        iSWButton2[iSL["\:5c55\:958b", "Expand"],
          RGBColor[0.878, 0.486, 0.078], SlideExpand[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:82f1\:8a33", "Translate"],
          RGBColor[0.3, 0.4, 0.65], SlideTranslate[]],
        iSWButton2[iSL["\:00d7\:82f1\:8a33", "\[Times]Tr"],
          RGBColor[0.6, 0.35, 0.35], SlideTranslateRevert[]]],
      iSWButton[iSL["\:5168\:30b9\:30e9\:30a4\:30c9\:82f1\:8a33", "Translate All"],
        RGBColor[0.3, 0.4, 0.65], SlideTranslateDeck[]],
      Spacer[3],

      Style[iSL[" \:633f\:5165", " Insert"], Bold, 8, GrayLevel[0.3]],
      iSWButtonRow[
        iSWButton2[iSL["\:30d7\:30ed\:30f3\:30d7\:30c8", "Prompt"],
          RGBColor[0.878, 0.486, 0.078], SlideInsertPrompt[]],
        iSWButton2[iSL["\:51fa\:5178", "Cite"],
          RGBColor[0.45, 0.45, 0.55], SlideInsertCitation[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:30e1\:30e2", "Note"],
          RGBColor[0.7, 0.63, 0.35], SlideInsertNote[]],
        iSWButton2[iSL["\:6307\:793a", "Directive"],
          RGBColor[0.65, 0.35, 0.5], SlideInsertDirective[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:8f9e\:66f8", "Dict"],
          RGBColor[0.35, 0.65, 0.65], SlideInsertDictionary[]],
        iSWButton2[iSL["\:6587\:732e", "Bib"],
          RGBColor[0.4, 0.45, 0.6], SlideInsertBibliography[]]],
      iSWButton[iSL["\:7d42\:7aef\:30de\:30fc\:30ab\:30fc", "End Marker"],
        RGBColor[0.5, 0.45, 0.35], SlideInsertEndMarker[]],
      Spacer[3],

      Style[iSL[" \:8868\:793a", " View"], Bold, 8, GrayLevel[0.3]],
      iSWButton[iSL["\[LeftRightArrow] \:30d7\:30ed\:30f3\:30d7\:30c8\:8868\:793a", "\[LeftRightArrow] Prompts"],
        RGBColor[0.35, 0.45, 0.65], SlideTogglePrompts[]],
      Spacer[3],

      Style[iSL[" \:66f8\:304d\:51fa\:3057", " Export"], Bold, 8, GrayLevel[0.3]],
      iSWButton[iSL["\:4e00\:89a7", "Overview"],
        RGBColor[0.4, 0.5, 0.55],
        With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWOverviewAction[nb]]]],
      iSWButtonRow[
        iSWButton2[iSL["\:753b\:50cf", "Images"],
          RGBColor[0.3, 0.5, 0.55],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWExportImagesAction[nb]]]],
        iSWButton2[iSL["mp4", "mp4"],
          RGBColor[0.4, 0.4, 0.55],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWExportVideoAction[nb]]]]],
      iSWButton[iSL["\:30b7\:30ca\:30ea\:30aamd(\:6982\:7565)", "Scenario md"],
        RGBColor[0.45, 0.4, 0.5],
        With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWExportScenarioAction[nb]]]],
      Spacer[3],

      Sequence @@ If[!safe && Length[DownValues[ClaudeCode`GetPaletteProvider]] > 0,
        {Style[iSL[" \:8a2d\:5b9a", " Settings"], Bold, 8, GrayLevel[0.3]],
         Button[
           Dynamic[Style[$iSWProviderLabel, 9, Bold, GrayLevel[0.2]],
             TrackedSymbols :> {$iSWProviderLabel}, SynchronousUpdating -> False],
           (ClaudeCode`CyclePaletteProvider[];
            ClaudeCode`SetPaletteEffort["medium"];
            Quiet[ClaudeCode`SavePaletteSettings[InputNotebook[]]];
            iSWRefreshSettingsLabels[]),
           Appearance -> "Frameless", Method -> "Queued"],
         Button[
           Dynamic[Style[$iSWModelLabel, 9, Bold, GrayLevel[0.2]],
             TrackedSymbols :> {$iSWModelLabel}, SynchronousUpdating -> False],
           (ClaudeCode`CyclePaletteModel[];
            Quiet[ClaudeCode`SavePaletteSettings[InputNotebook[]]];
            iSWRefreshSettingsLabels[]),
           Appearance -> "Frameless", Method -> "Queued"]},
        {}]
    }, Spacings -> 0.4],
    WindowTitle -> "Slides", WindowMargins -> {{Automatic, 60}, {Automatic, 60}}]];
  $iSWPalette];

End[]

EndPackage[]

Print[Style["SlideWorkflow \:30d1\:30c3\:30b1\:30fc\:30b8\:304c\:30ed\:30fc\:30c9\:3055\:308c\:307e\:3057\:305f\:3002", Bold]];
Print["
  SlideScenarioFromMarkdown[md]            \:2192 Markdown \:30b7\:30ca\:30ea\:30aa\:3092\:89e3\:6790
  SlideDeckBuild[scenario, \"deck.nb\"]      \:2192 \:30b7\:30ca\:30ea\:30aa\:304b\:3089\:30b9\:30e9\:30a4\:30c9\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:751f\:6210
  SlideDeckOverview[\"deck.nb\"]             \:2192 \:30b9\:30e9\:30a4\:30c9\:4e00\:89a7 (Dataset)
  SlideDeckReplaceSlide[nb, n, slide]      \:2192 n \:679a\:76ee\:3092\:5dee\:3057\:66ff\:3048 (\"Target\"->\:5225\:540d\:3067\:5225\:30d0\:30fc\:30b8\:30e7\:30f3)
  SlideDeckInsertSlide / DeleteSlide / MoveSlide
  SlideDeckImages[\"deck.nb\"]               \:2192 16:9 \:753b\:50cf\:30ea\:30b9\:30c8 (\:5b89\:5b9a\:30e9\:30b9\:30bf\:30e9\:30a4\:30ba)
  SlideDeckExportImages[\"deck.nb\"]         \:2192 \:9023\:756a PNG \:66f8\:304d\:51fa\:3057
  SlideDeckExportVideo[\"deck.nb\", \"deck.mp4\"] \:2192 Sliden \:7528 mp4
  $SlideTheme / SlideThemeColor[name]      \:2192 \:30c7\:30c3\:30ad\:914d\:8272 (\:56f3\:306e\:751f\:6210\:306b\:4f7f\:7528)
"];

(* ---- ClaudeCode \:30ad\:30fc\:30ef\:30fc\:30c9\:81ea\:52d5\:6ce8\:5165\:767b\:9332 (PDFIndex \:3068\:540c\:30d1\:30bf\:30fc\:30f3) ---- *)
Print["
  ShowSlidePalette[]        \:2192 \:30b9\:30e9\:30a4\:30c9\:4f5c\:6210\:30d1\:30ec\:30c3\:30c8 (v" <> SlideWorkflow`$SlideWorkflowInteractiveVersion <> ", \"Safe\"->True \:3067\:975e\:5e72\:6e09\:30e2\:30fc\:30c9)
  SlideAddSlide[] / SlideExpand[]          \:2192 \:65b0\:898f\:9aa8\:683c / \:30d7\:30ed\:30f3\:30d7\:30c8\:2192\:30b9\:30e9\:30a4\:30c9\:5c55\:958b (LLM)
  SlideTranslate[] / SlideTranslateRevert[] / SlideTranslateDeck[]
  SlideInsertPrompt/Citation/Note/Directive/Dictionary/Bibliography/EndMarker[]
  SlideTogglePrompts[]      \:2192 \:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:8868\:793a\:5207\:66ff
"];

(* ---- NBAccess \:627f\:8a8d\:30b2\:30fc\:30c8\:306e\:8a31\:53ef head \:767b\:9332 ----
   SlideThemeColor(\:7d14\:95a2\:6570)\:3068 SlideApplyScenario(\:30b9\:30e9\:30a4\:30c9\:66f8\:8fbc\:307f\:306e\:552f\:4e00\:306e
   \:6c7a\:5b9a\:7684\:5165\:53e3\:3001\:5165\:529b\:691c\:8a3c\:4ed8\:304d)\:3092 UnknownHead \:627f\:8a8d\:304b\:3089\:5916\:3059\:3002 *)
If[ListQ[NBAccess`$NBAllowedHeads],
  NBAccess`$NBAllowedHeads = DeleteDuplicates[Join[NBAccess`$NBAllowedHeads,
    {"SlideThemeColor", "SlideApplyScenario"}]]];

If[AssociationQ[ClaudeCode`$ClaudePackageKeywordMap],
  ClaudeCode`$ClaudePackageKeywordMap["SlideWorkflow"] =
    {"SlideWorkflow", "SlideDeck", "Sliden", "slide", "slideshow", "deck",
     "presentation",
     "\:30b9\:30e9\:30a4\:30c9", "\:30c7\:30c3\:30ad", "\:30d7\:30ec\:30bc\:30f3",
     "\:767a\:8868\:8cc7\:6599", "\:30b9\:30e9\:30a4\:30c9\:30b7\:30e7\:30fc"}
];

(* ---- Palettes menu registration (documentation.wl / claudecode.wl AddToPalettesMenu pattern) ---- *)
(* FE session only: headless (wolframscript) load skips both auto-show and menu registration *)
If[TrueQ[$Notebooks],
  SlideWorkflow`ShowSlidePalette[];
  Module[{itemList, dummyFunction, tempFunction, temp},
    SetAttributes[FrontEnd`AddMenuCommands, HoldRest];
    MathLink`CallFrontEnd[FrontEnd`ResetMenusPacket[{Automatic}]];
    itemList = {
      Item["SlideWorkflow",
        FrontEnd`KernelExecute[{EvaluatePacket[
          dummyFunction["Needs[\"SlideWorkflow`\"]; SlideWorkflow`ShowSlidePalette[]"]]}],
        FrontEnd`MenuEvaluator -> Automatic]};
    temp = Function[x,
      tempFunction[{FrontEnd`AddMenuCommands["MenuListPalettesMenu",
        x]}]][itemList] /. dummyFunction -> ToExpression;
    temp /. tempFunction -> FrontEndExecute]];