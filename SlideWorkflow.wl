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
$SlideIncludeInput::usage = "$SlideIncludeInput \:66f8\:304d\:51fa\:3057\:306b Input/Code \:30bb\:30eb\:3092\:542b\:3081\:308b\:304b\:306e\:65e2\:5b9a\:3002Automatic(\:65e2\:5b9a)=\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:8868\:793a\:3069\:304a\:308a(\:6298\:308a\:305f\:305f\:307f\:30fbCellOpen->False \:3067\:96a0\:308c\:3066\:3044\:308b\:30bb\:30eb\:3060\:3051\:304c\:9664\:304b\:308c\:308b) / True=\:540c\:4e0a / False=Input/Code \:3092\:3059\:3079\:3066\:9664\:304f / \"Visual\"=\:56f3\:3092\:542b\:3080 Input \:306e\:307f\:6b8b\:3059(\:65e7\:65e2\:5b9a)\:3002\:500b\:5225\:30bb\:30eb\:306f CellTags \:306b \"ShowInput\" \:3092\:4ed8\:3051\:308c\:3070\:8a2d\:5b9a\:306b\:3088\:3089\:305a\:5fc5\:305a\:6b8b\:308b\:3002";

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
SlideDeckImages::usage = "SlideDeckImages[nbfile] \:5168\:30b9\:30e9\:30a4\:30c9\:3092 16:9 \:753b\:50cf\:30ea\:30b9\:30c8\:3068\:3057\:3066\:5b89\:5b9a\:306b\:751f\:6210\:3059\:308b(\:30af\:30ea\:30c3\:30d7\:30dc\:30fc\:30c9/\:30a6\:30a3\:30f3\:30c9\:30a6\:975e\:4f9d\:5b58)\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: ImageSize->$SlideImageSize, \"Slides\"->All|\:7bc4\:56f2, \"Environment\"->\"SlideShow\", \"WindowWidth\"->960, \"IncludeInput\"->Automatic($SlideIncludeInput)|True|False|\"Visual\", \"Verbose\"->False, \"Margins\"->Automatic($SlideMargins, {{left,right},{bottom,top}} px)\:3002";
SlideDeckExportImages::usage = "SlideDeckExportImages[nbfile] / SlideDeckExportImages[nbfile, dir] \:5404\:30b9\:30e9\:30a4\:30c9\:3092 dir/01.png.. \:3068\:3057\:3066\:66f8\:304d\:51fa\:3057\:30d1\:30b9\:306e\:30ea\:30b9\:30c8\:3092\:8fd4\:3059\:3002\:30aa\:30d7\:30b7\:30e7\:30f3\:306f SlideDeckImages \:3068\:540c\:3058\:3002";
SlideDeckExportVideo::usage = "SlideDeckExportVideo[nbfile|images, mp4file] Sliden(VRChat) \:4e92\:63db\:306e mp4(30fps, 1\:679a\:22521\:79d2, \:5148\:982d29\:30d5\:30ec\:30fc\:30e0+\:672b\:5c3e\:30b9\:30e9\:30a4\:30c9\:91cd\:8907)\:3092\:66f8\:304d\:51fa\:3059\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Durations\"->Automatic|\:79d2\:30ea\:30b9\:30c8, FrameRate->30\:3002";

(* --- \:767a\:8868\:30b7\:30ca\:30ea\:30aa (talk) / \:767a\:8868\:767b\:9332\:7c3f --- *)

$SlideTalkSecondsPerSlide::usage = "$SlideTalkSecondsPerSlide \:767a\:8868\:30b7\:30ca\:30ea\:30aa\:306e\:65e2\:5b9a\:306e 1 \:679a\:3042\:305f\:308a\:79d2\:6570 (\:65e2\:5b9a 25)\:3002";
SlideTalkFromMarkdown::usage = "SlideTalkFromMarkdown[md] \:767a\:8868\:30b7\:30ca\:30ea\:30aa Markdown (front matter + \"# Opening\" + \"## n \:30bf\:30a4\:30c8\:30eb {seconds=\:79d2}\" + \"# Closing\") \:3092\:9023\:60f3\:3078\:89e3\:6790\:3059\:308b\:3002File[path] \:3082\:53ef\:3002\:623b\:308a\:5024: <|Title, Aliases, Event, Author, Date, SlideURL, Deck, Language, NarrationInstructions, SecondsPerSlide, PrivacyLevel, Opening, Closing, Slides, Meta|>\:3002";
SlideTalkToMarkdown::usage = "SlideTalkToMarkdown[talk] \:767a\:8868\:30b7\:30ca\:30ea\:30aa\:9023\:60f3\:3092 Markdown \:3078\:623b\:3059 (\:30e9\:30a6\:30f3\:30c9\:30c8\:30ea\:30c3\:30d7)\:3002";
SlideTalkSkeleton::usage = "SlideTalkSkeleton[deck] \:30c7\:30c3\:30ad\:306e\:7b87\:6761\:66f8\:304d\:304b\:3089\:6c7a\:5b9a\:8ad6\:7684\:306a\:767a\:8868\:30b7\:30ca\:30ea\:30aa\:9aa8\:683c Markdown \:3092\:4f5c\:308b (LLM \:4e0d\:8981)\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Title\", \"Aliases\", \"Event\", \"Author\", \"Date\", \"SlideURL\", \"SecondsPerSlide\", \"Language\", \"NarrationInstructions\", \"PrivacyLevel\"\:3002";
SlideTalkPrompt::usage = "SlideTalkPrompt[deck] \:30c7\:30c3\:30ad\:5168\:4f53\:304b\:3089\:300c\:6d41\:308c\:306e\:3042\:308b\:767a\:8a71\:539f\:7a3f\:300d\:3092\:66f8\:304b\:305b\:308b LLM \:30d7\:30ed\:30f3\:30d7\:30c8\:3092\:8fd4\:3059\:3002";
SlideTalkBuild::usage = "SlideTalkBuild[deck] \:767a\:8868\:30b7\:30ca\:30ea\:30aa\:3092\:751f\:6210\:3057\:3066 <deck>_talk.md \:3078\:66f8\:304d\:51fa\:3059\:3002LLM \:304c\:4f7f\:3048\:308b\:3068\:304d\:306f\:975e\:540c\:671f (SlideExpand \:3068\:540c\:3058\:7d4c\:8def) \:3067\:3001\:4f7f\:3048\:306a\:3044\:3068\:304d\:306f\:9aa8\:683c\:3092\:540c\:671f\:3067\:66f8\:304f\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Output\", \"UseLLM\", \"Notebook\", \"OpenResult\" \:3068 SlideTalkPrompt \:306e\:30aa\:30d7\:30b7\:30e7\:30f3\:3002";
SlideTalkFile::usage = "SlideTalkFile[deck] \:767a\:8868\:30b7\:30ca\:30ea\:30aa\:306e\:898f\:7d04\:30d1\:30b9 <deck>_talk.md \:3092\:8fd4\:3059 (\:30c8\:30fc\:30af\:30bb\:30eb\:306e\:7121\:3044\:65e7\:30c7\:30c3\:30ad\:7528\:306e\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af)\:3002";

SlideTalkMeta::usage = "SlideTalkMeta[nb] \:306f\:30c7\:30c3\:30ad\:5358\:4f4d\:306e\:767a\:8868\:30e1\:30bf (SlideURL / Aliases / PrivacyLevel \:306a\:3069) \:3092\:8fd4\:3059\:3002\n" <>
  "SlideTalkMeta[nb, \"SlideURL\" -> url, ...] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e TaggingRules \:306b\:6c38\:7d9a\:5316\:3059\:308b (\:767b\:9332\:7c3f\:3078\:306e\:767b\:9332\:304c _talk.md \:7121\:3057\:3067\:5b8c\:7d50\:3059\:308b)\:3002";
SlideDeckRegister::usage = "SlideDeckRegister[deck|talkfile|md] \:767a\:8868\:30b7\:30ca\:30ea\:30aa\:306e front matter (Title / SlideURL) \:3092\:4f7f\:3063\:3066\:767a\:8868\:3092 SourceVault \:306e\:767b\:9332\:7c3f\:3078\:767b\:9332\:3059\:308b\:3002\:4ee5\:5f8c VRCRealtime \:304c\:767a\:8868\:30bf\:30a4\:30c8\:30eb\:304b\:3089\:30b9\:30e9\:30a4\:30c9 URL \:3068\:539f\:7a3f\:3092\:5f15\:3051\:308b\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"SlideURL\", \"Title\", \"Id\", \"DeckFile\", \"PrivacyLevel\", \"SlideCount\"\:3002";
SlideDeckRegistry::usage = "SlideDeckRegistry[] \:767b\:9332\:6e08\:307f\:767a\:8868\:30a8\:30f3\:30c8\:30ea\:306e\:4e00\:89a7\:3092\:8fd4\:3059\:3002";
$SlideVoice::usage = "$SlideVoice \:306f\:8aad\:307f\:4e0a\:3052\:306b\:4f7f\:3046\:30dc\:30a4\:30b9\:30e2\:30c7\:30eb\:540d (SourceVault \:306e\:30ed\:30fc\:30ab\:30eb\:97f3\:58f0\:8cc7\:7523\:306e\:58f0\:540d)\:3002\:65e2\:5b9a Automatic \:306f SourceVaultVoice[] \:306e\:65e2\:5b9a\:306e\:58f0\:3002SlideVoices[] \:3067\:5019\:88dc\:4e00\:89a7\:3002";
$SlideVoiceGap::usage = "$SlideVoiceGap \:306f\:30b9\:30e9\:30a4\:30c9\:3092\:8aad\:307f\:7d42\:3048\:3066\:304b\:3089\:6b21\:3078\:9001\:308b\:307e\:3067\:306e\:9593 (\:79d2\:3001\:65e2\:5b9a 0.8)\:3002";
$SlideQuestionSeconds::usage = "$SlideQuestionSeconds \:306f 1 \:679a\:8aad\:307f\:7d42\:3048\:3066\:304b\:3089\:6b21\:3078\:9001\:308b\:307e\:3067\:306b\:8cea\:554f\:3092\:5f85\:3064\:79d2\:6570 (\:65e2\:5b9a 3)\:3002\n" <>
  "\:30af\:30e9\:30a6\:30c9\:97f3\:58f0 (realtime:) \:306e\:3068\:304d\:3060\:3051\:52b9\:304f\:3002\:3053\:306e\:9593\:306b\:8a71\:3057\:304b\:3051\:3089\:308c\:305f\:3089\:3001\:3084\:308a\:53d6\:308a\:304c\:7d42\:308f\:308b\:307e\:3067\:6b21\:3078\:9001\:3089\:306a\:3044\:30020 \:306b\:3059\:308b\:3068\:5f85\:305f\:306a\:3044\:3002";
$SlideVoiceInputGate::usage = "$SlideVoiceInputGate \:306f\:8cea\:554f\:53d7\:4ed8\:3067\:30de\:30a4\:30af\:3092\:9001\:308b\:4e0b\:9650\:306e\:97f3\:91cf (0\:301c1\:3001\:65e2\:5b9a 0 = \:5236\:9650\:306a\:3057)\:3002
" <>
  "\:4f1a\:5834\:306e\:7269\:97f3\:3067\:52dd\:624b\:306b\:5fdc\:7b54\:304c\:59cb\:307e\:308b\:3068\:304d\:306b 0.05 \:524d\:5f8c\:3092\:5165\:308c\:308b\:3002\:3044\:307e\:306e\:97f3\:91cf\:306f SourceVaultRealtimeStatus[][\"InputPeak\"] \:3067\:898b\:3089\:308c\:308b\:3002";
$SlideQuestionMaxSeconds::usage = "$SlideQuestionMaxSeconds \:306f 1 \:679a\:306e\:5408\:9593\:306b\:8cea\:7591\:3067\:7559\:307e\:308c\:308b\:4e0a\:9650\:306e\:79d2\:6570 (\:65e2\:5b9a 60)\:3002
" <>
  "\:90e8\:5c4b\:306e\:7269\:97f3\:3067\:30de\:30a4\:30af\:304c\:958b\:304d\:7d9a\:3051\:3066\:3082\:30c7\:30c3\:30ad\:304c\:6b62\:307e\:3089\:306a\:3044\:3088\:3046\:306b\:3059\:308b\:305f\:3081\:306e\:4e0a\:9650\:3002\:7b54\:3048\:3066\:3044\:308b\:6700\:4e2d\:306f\:6253\:3061\:5207\:3089\:306a\:3044\:3002";
$SlideVoiceTick::usage = "$SlideVoiceTick \:306f\:8aad\:307f\:4e0a\:3052\:9032\:884c\:3092\:898b\:308b\:30ab\:30fc\:30cd\:30eb\:5074 ScheduledTask \:306e\:5468\:671f (\:79d2\:3001\:65e2\:5b9a 0.3)\:3002";
SlideVoices::usage = "SlideVoices[] \:306f\:9078\:3079\:308b\:30dc\:30a4\:30b9\:30e2\:30c7\:30eb\:540d\:306e\:4e00\:89a7\:3092\:8fd4\:3059 (SourceVault_voice.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:306a\:3051\:308c\:3070 {})\:3002";
SlideCycleVoice::usage = "SlideCycleVoice[] \:306f $SlideVoice \:3092\:6b21\:306e\:30dc\:30a4\:30b9\:30e2\:30c7\:30eb\:3078\:5207\:308a\:66ff\:3048\:308b (\:30d1\:30ec\:30c3\:30c8\:306e\:30c8\:30b0\:30eb)\:3002";
SlideVoicePrepare::usage = "SlideVoicePrepare[] \:306f\:767a\:8868\:30b7\:30ca\:30ea\:30aa\:5168\:30b9\:30e9\:30a4\:30c9\:306e\:97f3\:58f0\:3092\:5148\:306b\:5408\:6210\:3057\:3066 <deck>_voice/ \:306b\:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b\:3002SlideVoicePrepare[nb] \:3067\:5bfe\:8c61\:6307\:5b9a\:3002";
$SlideRealtimeVoices::usage = "$SlideRealtimeVoices \:306f\:30dc\:30a4\:30b9\:30e2\:30c7\:30eb\:306e\:30c8\:30b0\:30eb\:306b\:4e26\:3079\:308b\:30af\:30e9\:30a6\:30c9\:97f3\:58f0 (OpenAI Realtime) \:306e\:58f0\:540d (\:65e2\:5b9a {\"marin\", \"cedar\"})\:3002\:4e00\:89a7\:306b\:306f \"realtime:<\:58f0>\" \:3068\:3057\:3066\:51fa\:308b\:3002";
SlidePlay::usage = "SlidePlay[] \:306f <deck>_talk.md \:306e\:539f\:7a3f\:3092 SourceVault \:306e\:30ed\:30fc\:30ab\:30eb\:97f3\:58f0\:3067\:8aad\:307f\:4e0a\:3052\:306a\:304c\:3089\:30b9\:30e9\:30a4\:30c9\:3092\:81ea\:52d5\:3067\:9032\:3081\:308b (\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883\:304c SlideShow \:306e\:3068\:304d)\:3002\:4e00\:6642\:505c\:6b62\:4e2d\:306b\:547c\:3076\:3068\:518d\:958b\:3059\:308b\:3002SlidePlay[nb] \:3067\:5bfe\:8c61\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:6307\:5b9a\:3002";
SlidePause::usage = "SlidePause[] \:306f\:8aad\:307f\:4e0a\:3052\:3092\:4e00\:6642\:505c\:6b62\:3059\:308b\:3002SlidePlay[] \:3067\:7d9a\:304d\:304b\:3089\:518d\:958b\:3059\:308b\:3002";
SlideStop::usage = "SlideStop[] \:306f\:8aad\:307f\:4e0a\:3052\:3092\:6b62\:3081\:3066\:518d\:751f\:72b6\:614b\:3092\:521d\:671f\:5316\:3059\:308b\:3002";
SlideShowSlide::usage = "SlideShowSlide[spec] \:306f\:8868\:793a\:3059\:308b\:30b9\:30e9\:30a4\:30c9\:3092\:5909\:3048\:308b\:3002spec \:306f\:756a\:53f7\:3001\"Next\"/\"Previous\"/\"First\"/\"Last\"\:3001\:307e\:305f\:306f\:898b\:51fa\:3057\:3084\:672c\:6587\:306b\:542b\:307e\:308c\:308b\:8a9e (\:6587\:5b57\:5217)\:3002\n" <>
  "\:97f3\:58f0\:304b\:3089\:306e\:300c\:4e00\:3064\:524d\:306e\:30b9\:30e9\:30a4\:30c9\:300d\:300c\:4e09\:679a\:76ee\:300d\:300c\:30d0\:30fc\:30c9\:30d0\:30b9\:306e\:30b9\:30e9\:30a4\:30c9\:300d\:3082\:3053\:306e\:95a2\:6570\:3092\:901a\:308b\:3002";
SlideTitles::usage = "SlideTitles[] \:306f\:958b\:3044\:3066\:3044\:308b\:30c7\:30c3\:30ad\:306e\:898b\:51fa\:3057\:4e00\:89a7\:3092\:8fd4\:3059 (SlideTitles[nb] \:3067\:5bfe\:8c61\:6307\:5b9a)\:3002";
SlideToggleRealtime::usage = "SlideToggleRealtime[] \:306f\:97f3\:58f0\:5fdc\:7b54 (SourceVaultRealtimeStart / Stop) \:3092\:5207\:308a\:66ff\:3048\:308b\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:5fdc\:7b54on/off\:300d\:3068\:540c\:3058\:3002";
SlideToggleMic::usage = "SlideToggleMic[] \:306f\:97f3\:58f0\:5fdc\:7b54\:306e\:30de\:30a4\:30af\:3092 mute / unmute \:3067\:5207\:308a\:66ff\:3048\:308b\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:30de\:30a4\:30afon/off\:300d\:30dc\:30bf\:30f3\:3001\:304a\:3088\:3073\:624b\:5143\:30ea\:30e2\:30b3\:30f3\:306e\:300c\:524d\:306e\:66f2\:300d\:30dc\:30bf\:30f3\:3068\:540c\:3058\:52d5\:4f5c\:3002\n" <>
  "\:97f3\:58f0\:5fdc\:7b54\:304c\:52d5\:3044\:3066\:3044\:306a\:3044\:3068\:304d\:306f\:4f55\:3082\:3057\:306a\:3044\:3002\"Quiet\" -> True \:3067\:77e5\:3089\:305b\:306e\:30c0\:30a4\:30a2\:30ed\:30b0\:3082\:51fa\:3055\:306a\:3044 (\:624b\:5143\:30ea\:30e2\:30b3\:30f3\:304b\:3089\:306f\:3053\:3061\:3089\:3067\:547c\:3076)\:3002";
SlideRemoteStart::usage = "SlideRemoteStart[] \:306f\:624b\:5143\:30c7\:30d0\:30a4\:30b9 (Elecom Relacon \:306a\:3069\:306e\:30e1\:30c7\:30a3\:30a2\:30ad\:30fc) \:306e\:898b\:5f35\:308a\:3092\:59cb\:3081\:308b\:3002\:3069\:306e\:30dc\:30bf\:30f3\:304c\:4f55\:3092\:3059\:308b\:304b\:306f $SlideRemoteBindings \:3067\:6c7a\:307e\:308b\:3002\n" <>
  "\:30b9\:30e9\:30a4\:30c9\:3092\:5168\:753b\:9762\:8868\:793a\:3057\:305f\:307e\:307e\:3067\:3082\:52b9\:304f (\:30d5\:30ed\:30f3\:30c8\:30a8\:30f3\:30c9\:306e\:30ad\:30fc\:30a4\:30d9\:30f3\:30c8\:3092\:7d4c\:7531\:3057\:306a\:3044\:305f\:3081)\:3002Windows \:5c02\:7528\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3: \"Bindings\" (\:65e2\:5b9a Automatic = $SlideRemoteBindings), \"Tick\" (\:898b\:5f35\:308a\:306e\:5468\:671f\:3002\:65e2\:5b9a $SlideRemoteTick)\:3002";
SlideRemoteStop::usage = "SlideRemoteStop[] \:306f\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:306e\:898b\:5f35\:308a\:3092\:6b62\:3081\:308b\:3002";
SlideRemoteStatus::usage = "SlideRemoteStatus[] \:306f\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:306e\:898b\:5f35\:308a\:306e\:72b6\:614b <|Watching, Available, Checked, Bindings, Tick, Hint|> \:3092\:8fd4\:3059 (\:72b6\:614b\:3092\:898b\:308b\:3060\:3051\:3067 user32.dll \:3092\:958b\:304b\:306a\:3044)\:3002";
SlideRemoteProbe::usage = "SlideRemoteProbe[] \:306f\:300c\:305d\:306e\:30dc\:30bf\:30f3\:304c\:3069\:306e\:4eee\:60f3\:30ad\:30fc\:3092\:51fa\:3059\:304b\:300d\:3092\:5b9f\:6e2c\:3059\:308b\:3002\:547c\:3093\:3067\:304b\:3089 \"Seconds\" (\:65e2\:5b9a 10) \:306e\:9593\:306b\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:306e\:30dc\:30bf\:30f3\:3092\:4f55\:5ea6\:304b\:62bc\:3059\:3068\:3001\:53cd\:5fdc\:3057\:305f\:4eee\:60f3\:30ad\:30fc\:304c\:4e00\:89a7\:3067\:8fd4\:308b\:3002\n" <>
  "\:8fd4\:308a\:5024\:306e \"Suggestion\" \:306f $SlideRemoteBindings \:3078\:306e\:5272\:308a\:5f53\:3066\:4f8b\:3002\"View\" -> True \:3067 Dataset\:3002\n" <>
  "\:5b9f\:6e2c\:306e\:9593\:306f\:898b\:5f35\:308a\:3092\:4e00\:6642\:7684\:306b\:6b62\:3081\:3001\:7d42\:308f\:3063\:305f\:3089\:5143\:306e\:5272\:308a\:5f53\:3066\:306e\:307e\:307e\:623b\:3059\:3002";
$SlideRemoteBindings::usage = "$SlideRemoteBindings \:306f\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:306e\:30dc\:30bf\:30f3 (\:4eee\:60f3\:30ad\:30fc) \:3068\:52d5\:4f5c\:306e\:5bfe\:5fdc\:3002\n" <>
  "\:65e2\:5b9a <|\"MediaPrevTrack\" -> \"Mic\", \"MediaPlayPause\" -> \"Play\"|> = \:300c\:524d\:306e\:66f2\:300d\:3067\:30de\:30a4\:30af\:306e mute/unmute\:3001\:300c\:518d\:751f/\:4e00\:6642\:505c\:6b62\:300d\:3067\:8aad\:307f\:4e0a\:3052\:306e\:518d\:751f/\:4e00\:6642\:505c\:6b62\:3002\n" <>
  "\:30ad\:30fc\:306f\:540d\:524d (\"MediaNextTrack\") \:3067\:3082\:756a\:53f7 (16^^B0) \:3067\:3082 \"0xB0\" \:3067\:3082\:3088\:3044\:3002\:3069\:306e\:30dc\:30bf\:30f3\:304c\:3069\:306e\:30ad\:30fc\:3092\:51fa\:3059\:304b\:306f SlideRemoteProbe[] \:3067\:5b9f\:6e2c\:3067\:304d\:308b\:3002\n" <>
  "\:52d5\:4f5c\:306f \"Mic\" | \"Play\" | \"Stop\" | \"NextSlide\" | \"PreviousSlide\" | \"None\"\:3002\:8aad\:3081\:306a\:3044\:6307\:5b9a\:306f\:9ed9\:3063\:3066\:843d\:3068\:3059\:3002";
$SlideRemoteTick::usage = "$SlideRemoteTick \:306f\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:3092\:898b\:5f35\:308b\:30ab\:30fc\:30cd\:30eb\:5074 ScheduledTask \:306e\:5468\:671f (\:79d2\:3001\:65e2\:5b9a 0.15)\:3002\:62bc\:4e0b\:306f Windows \:5074\:306b\:6e9c\:307e\:308b\:306e\:3067\:3001\:3053\:306e\:5024\:306f\:53d6\:308a\:3053\:307c\:3057\:3067\:306f\:306a\:304f\:53cd\:5fdc\:306e\:901f\:3055\:3092\:6c7a\:3081\:308b\:3002";
$SlideRemoteAuto::usage = "$SlideRemoteAuto \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:97f3\:58f0\:5fdc\:7b54 (SlideToggleRealtime) \:3092\:59cb\:3081\:308b\:3068\:540c\:6642\:306b\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:306e\:898b\:5f35\:308a\:3092\:59cb\:3081\:3001\:6b62\:3081\:308b\:3068\:540c\:6642\:306b\:6b62\:3081\:308b\:3002";
$SlideSpeechRate::usage = "$SlideSpeechRate \:306f\:8a71\:901f (1 \:79d2\:3042\:305f\:308a\:306e\:6587\:5b57\:6570) \:3092\:30a8\:30f3\:30b8\:30f3\:3054\:3068\:306b\:6301\:3064\:9023\:60f3\:3002\n" <>
  "\:65e2\:5b9a <|\"Local\" -> 6.95, \"Realtime\" -> 5.6|> (\:540c\:3058\:539f\:7a3f\:3067\:306e\:5b9f\:6e2c\:5024)\:3002SlideTalkDuration \:304c\:4f7f\:3046\:3002";
$SlideSpeechLatency::usage = "$SlideSpeechLatency \:306f 1 \:679a\:3042\:305f\:308a\:58f0\:304c\:51fa\:308b\:307e\:3067\:306e\:5f85\:3061 (\:79d2) \:3092\:30a8\:30f3\:30b8\:30f3\:3054\:3068\:306b\:6301\:3064\:9023\:60f3 (\:65e2\:5b9a Local 0.3 / Realtime 1.5)\:3002";
SlideCurrentNumber::usage = "SlideCurrentNumber[] \:306f\:4eca\:753b\:9762\:306b\:51fa\:3066\:3044\:308b\:30b9\:30e9\:30a4\:30c9\:756a\:53f7\:3092\:8fd4\:3059\:3002";

SlideIndex::usage = "SlideIndex[] \:306f\:767a\:8868\:306e\:7d22\:5f15\:3092 Dataset \:3067\:8fd4\:3059 (\:756a\:53f7\:30fb\:898b\:51fa\:3057\:30fb\:5b57\:6570\:30fb\:63a8\:5b9a\:79d2\:6570\:30fb\:7d2f\:8a08)\:3002\n" <>
  "\:5404\:884c\:306e Show \:30dc\:30bf\:30f3\:3067\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:8868\:793a\:3057\:3001Play \:30dc\:30bf\:30f3\:3067\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:97f3\:58f0\:3092\:8a66\:8074\:3067\:304d\:308b\:3002\n" <>
  "SlideIndex[nb] \:3067\:5bfe\:8c61\:6307\:5b9a\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Voice\" (\:65e2\:5b9a Automatic), \"Questions\" -> True \:3067\:8cea\:554f\:53d7\:4ed8\:306e\:5f85\:3061\:3082\:7d2f\:8a08\:306b\:5165\:308c\:308b\:3002";
SlideSpeakSlide::usage = "SlideSpeakSlide[n] \:306f n \:679a\:76ee\:306e\:539f\:7a3f\:3092\:4eca\:306e\:58f0\:3067\:8aad\:307f\:4e0a\:3052\:308b (\:7d22\:5f15\:306e Play \:30dc\:30bf\:30f3\:3068\:540c\:3058)\:3002\n" <>
  "\:30ed\:30fc\:30ab\:30eb\:306e\:58f0\:306a\:3089\:5408\:6210\:3057\:3066\:305d\:306e\:5834\:3067\:518d\:751f\:3057\:3001realtime: \:306e\:58f0\:306a\:3089\:52d5\:3044\:3066\:3044\:308b\:97f3\:58f0\:4f1a\:8a71\:306b\:8aad\:307e\:305b\:308b\:3002";
SlideInfo::usage = "SlideInfo[] \:306f\:30c7\:30c3\:30ad\:3068\:767a\:8868\:306e\:60c5\:5831 (\:679a\:6570\:30fb\:539f\:7a3f\:30fb\:898b\:7a4d\:6642\:9593\:30fb\:58f0\:30fb\:97f3\:58f0\:4f1a\:8a71\:306e\:72b6\:614b) \:3092\:307e\:3068\:3081\:305f\:30a6\:30a4\:30f3\:30c9\:30a6\:3092\:958b\:304f\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:60c5\:5831\:300d\:3068\:540c\:3058\:3002";
SlideTalkDuration::usage = "SlideTalkDuration[] \:306f\:767a\:8868\:30b7\:30ca\:30ea\:30aa <deck>_talk.md \:304b\:3089\:767a\:8868\:306b\:304b\:304b\:308b\:6642\:9593\:3092\:898b\:7a4d\:3082\:308b (\:8cea\:554f\:306f\:7121\:3044\:3082\:306e\:3068\:3059\:308b)\:3002\n" <>
  "SlideTalkDuration[nb] / SlideTalkDuration[\"deck.nb\"] / SlideTalkDuration[\"deck_talk.md\"] \:3082\:53ef\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3: \"Voice\" (\:65e2\:5b9a Automatic = \:9078\:629e\:4e2d\:306e\:58f0), \"Questions\" -> True \:3067\:8cea\:554f\:53d7\:4ed8\:306e\:5f85\:3061\:6642\:9593\:3082\:8db3\:3059, \"View\" -> True \:3067 Dataset\:3002\n" <>
  "\:30ed\:30fc\:30ab\:30eb\:97f3\:58f0\:3067\:5408\:6210\:6e08\:307f\:306e\:30b9\:30e9\:30a4\:30c9\:306f\:30ad\:30e3\:30c3\:30b7\:30e5\:306e\:5b9f\:9577\:3092\:4f7f\:3044\:3001\:305d\:308c\:4ee5\:5916\:306f\:6587\:5b57\:6570\:3068\:8a71\:901f\:304b\:3089\:898b\:7a4d\:3082\:308b\:3002";
SlidePlayStatus::usage = "SlidePlayStatus[] \:306f\:8aad\:307f\:4e0a\:3052\:518d\:751f\:306e\:72b6\:614b <|Status, Slide, SlideCount, Voice, Notebook, CacheDirectory, LastFailure|> \:3092\:8fd4\:3059\:3002";

(* --- Interactive layer (\:65e7 SlideWorkflow_interactive.wl, 2026-07-13 \:7d71\:5408) --- *)

ShowSlidePalette::usage = "ShowSlidePalette[] \:306f\:30b9\:30e9\:30a4\:30c9\:4f5c\:6210\:7528\:30d1\:30ec\:30c3\:30c8\:3092\:8868\:793a\:3059\:308b\:3002\"Safe\"->True \:3067 ClaudeCode \:5b8c\:5168\:975e\:5e72\:6e09(\:30d5\:30ea\:30fc\:30ba\:5207\:308a\:5206\:3051\:7528)\:3002";
$SlideWorkflowInteractiveVersion::usage = "$SlideWorkflowInteractiveVersion interactive \:30ec\:30a4\:30e4\:30fc\:306e\:7248\:3002";
SlideAddSlide::usage = "SlideAddSlide[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:76f4\:5f8c\:306b\:65b0\:898f\:30b9\:30e9\:30a4\:30c9\:9aa8\:683c(navbar+\:30bf\:30a4\:30c8\:30eb+\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb)\:3092\:633f\:5165\:3059\:308b\:3002\:30d7\:30ed\:30f3\:30d7\:30c8\:306b\:300c\:25ef\:679a\:69cb\:6210\:3067\:300d\:7b49\:3068\:66f8\:3051\:3070\:300c\:5c55\:958b\:300d\:3067\:8907\:6570\:30b9\:30e9\:30a4\:30c9\:306b\:4e00\:62ec\:5c55\:958b\:3067\:304d\:308b(SlideApplyScenario \:306f\:8907\:6570 ## \:3092\:8907\:6570\:679a\:306b\:5206\:5272\:3059\:308b)\:3002";
SlideExpand::usage = "SlideExpand[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e SlidePrompt \:30bb\:30eb(\:7121\:3051\:308c\:3070\:9078\:629e\:30bb\:30eb\:306e\:672c\:6587)\:3092\:6307\:793a\:3068\:3057\:3066\:30b9\:30e9\:30a4\:30c9\:3092\:5c55\:958b\:30fb\:66f4\:65b0\:3059\:308b\:3002\:65e2\:5b9a($SlideExpandMode=\"Agent\")\:3067\:306f ClaudeEval(ClaudeRuntime \:7d4c\:7531\:3001\:6587\:732e\:691c\:7d22\:30fb\:56f3\:751f\:6210\:30fb\:627f\:8a8d\:30b2\:30fc\:30c8\:4ed8\:304d)\:306b\:59d4\:8b72\:3057\:3001\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c\:6700\:5f8c\:306b SlideApplyScenario \:3092\:547c\:3093\:3067\:9069\:7528\:3059\:308b\:3002\:8ffd\:8de1\:30bb\:30eb\:306f\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d(Appendix)\:306b\:7f6e\:304b\:308c\:308b\:3002\:6307\:793a(Directive)\:30fb\:8f9e\:66f8(Dictionary)\:30bb\:30eb\:3092\:53b3\:5b88\:3057\:3001\:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:306f <<FIGn>> \:30c8\:30fc\:30af\:30f3\:3067\:4fdd\:6301\:3055\:308c\:308b\:3002";
SlideApplyScenario::usage = "SlideApplyScenario[slideNo, md] \:306f\:30b7\:30ca\:30ea\:30aa Markdown \:3067\:5bfe\:8c61\:30b9\:30e9\:30a4\:30c9\:3092\:5dee\:3057\:66ff\:3048\:308b\:6c7a\:5b9a\:7684\:9069\:7528\:95a2\:6570(\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306e\:552f\:4e00\:306e\:66f8\:8fbc\:307f\:53e3)\:3002md \:306b\:8907\:6570 ## \:53ef(\:8907\:6570\:679a\:5c55\:958b)\:3002<<FIGn>> \:306f n=1..k \:304c\:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:3001n=k+1.. \:304c \"Figures\" \:30aa\:30d7\:30b7\:30e7\:30f3\:3067\:6e21\:3057\:305f\:65b0\:898f\:56f3(Graphics/Image)\:3002SlidePrompt \:30bb\:30eb\:306f\:81ea\:52d5\:3067\:5148\:982d\:30b9\:30e9\:30a4\:30c9\:306b\:623b\:3055\:308c\:308b\:3002\:6210\:529f\:6642 Success\:3001\:5931\:6557\:6642 Failure \:3092\:8fd4\:3059\:3002";
$SlideExpandMode::usage = "$SlideExpandMode \:5c55\:958b\:306e\:5b9f\:884c\:7d4c\:8def\:3002\"Agent\"(\:65e2\:5b9a: ClaudeEval/ClaudeRuntime \:7d4c\:7531\:3001\:8907\:96d1\:51e6\:7406\:53ef) | \"Direct\"(\:8efd\:91cf: NBAccess`$NBLLMQueryFunc \:76f4\:63a5)\:3002";
SlideTranslate::usage = "SlideTranslate[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:30c6\:30ad\:30b9\:30c8\:30bb\:30eb\:3092 $SlideTranslationLanguage \:3078\:4e00\:62ec\:7ffb\:8a33\:3059\:308b(\:8f9e\:66f8\:53b3\:5b88)\:3002\:539f\:6587\:306f TaggingRules \"SWOrigText\" \:306b\:4fdd\:5b58\:3055\:308c\:308b\:3002";
SlideTranslateRevert::usage = "SlideTranslateRevert[] \:306f\:73fe\:5728\:30b9\:30e9\:30a4\:30c9\:306e\:7ffb\:8a33\:3092\:539f\:6587\:306b\:623b\:3059\:3002";
SlideTranslateDeck::usage = "SlideTranslateDeck[] \:306f\:5168\:30b9\:30e9\:30a4\:30c9\:3092\:9806\:306b\:7ffb\:8a33\:3059\:308b(\:975e\:540c\:671f\:9023\:9396)\:3002";
SlideInsertPrompt::usage = "SlideInsertPrompt[] \:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b SlidePrompt \:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(\:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:304b\:3089\:306f\:9664\:5916\:3055\:308c\:308b)\:3002";
SlideInsertCitation::usage = "SlideInsertCitation[] \:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b\:51fa\:5178\:30bb\:30eb(\:5c0f\:30d5\:30a9\:30f3\:30c8)\:3092\:633f\:5165\:3059\:308b\:3002\:56f3\:30fb\:5f15\:7528\:306e\:76f4\:5f8c\:306b\:7f6e\:304d\:3001URL \:307e\:305f\:306f (\:8457\:8005, \:5e74) \:3092\:8a18\:5165\:3059\:308b\:3002";
SlideInsertEndMarker::usage = "SlideInsertEndMarker[] \:306f\:30ab\:30fc\:30bd\:30eb\:4f4d\:7f6e\:306b\:30b9\:30e9\:30a4\:30c9\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:3092\:633f\:5165\:3059\:308b\:3002\:4ee5\:964d\:306e\:30bb\:30eb\:306f\:30b9\:30e9\:30a4\:30c9\:30fb\:66f8\:304d\:51fa\:3057\:306b\:542b\:307e\:308c\:306a\:3044\:3002";
SlideInsertNote::usage = "SlideInsertNote[] \:306f\:30e1\:30e2\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(documentation.wl \:4e92\:63db\:3001\:66f8\:304d\:51fa\:3057\:9664\:5916)\:3002Working \:3067\:53ef\:8996\:3001SlideShow(\:30b9\:30e9\:30a4\:30c9\:30b7\:30e7\:30fc\:74b0\:5883)\:3067\:306f\:975e\:8868\:793a\:3002";
SlideInsertDirective::usage = "SlideInsertDirective[] \:306f\:6307\:793a\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b\:3002\:5c55\:958b\:30fb\:7ffb\:8a33\:6642\:306b LLM \:304c\:53b3\:5b88\:3059\:308b\:3002Working \:3067\:53ef\:8996\:3001SlideShow(\:30b9\:30e9\:30a4\:30c9\:30b7\:30e7\:30fc\:74b0\:5883)\:3067\:306f\:975e\:8868\:793a\:3002";
SlideInsertDictionary::usage = "SlideInsertDictionary[] \:306f\:8f9e\:66f8\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b\:3002\:7ffb\:8a33\:6642\:306e\:7528\:8a9e\:5bfe\:5fdc\:3092\:6307\:5b9a\:3059\:308b\:3002";
SlideInsertBibliography::usage = "SlideInsertBibliography[] \:306f\:6587\:732e\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(documentation.wl \:4e92\:63db)\:3002";
SlideInsertReferences::usage = "SlideInsertReferences[] \:306f\:6587\:732e\:30ea\:30b9\:30c8\:30bb\:30eb\:3092\:633f\:5165\:3059\:308b(\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:6587\:732e\:300d)\:30021 \:884c 1 \:6587\:732e \"[key] locator | \:30e1\:30e2\"\:3002locator \:306f URL / arxiv:ID / sv://URI / eagle:ID / PDF\:30fb\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30d1\:30b9(\:904e\:53bb\:30b9\:30e9\:30a4\:30c9\:53ef)\:3002\:30b9\:30e9\:30a4\:30c9\:6307\:793a(\:30d7\:30ed\:30f3\:30d7\:30c8)\:304b\:3089\:306f [key] \:3067\:53c2\:7167\:3057\:3001\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c\:53d6\:5f97\:30fb\:5f15\:7528\:3059\:308b\:3002# \:3067\:59cb\:307e\:308b\:884c\:306f\:30b3\:30e1\:30f3\:30c8\:3002";
SlideToggleScreenEnvironment::usage = "SlideToggleScreenEnvironment[] \:306f\:5bfe\:8c61\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883\:3092 Working \:21c4 SlideShow \:3067\:5207\:308a\:66ff\:3048\:308b(\:66f8\:5f0f\:30e1\:30cb\:30e5\:30fc\:306e\:300c\:30b9\:30af\:30ea\:30fc\:30f3\:30b9\:30bf\:30a4\:30eb\:74b0\:5883\:300d\:3068\:540c\:3058)\:3002\:30e1\:30e2\:30fb\:6307\:793a\:30fb\:8f9e\:66f8\:30fb\:6587\:732e\:30fb\:30d7\:30ed\:30f3\:30d7\:30c8\:306e\:5404\:30bb\:30eb\:306f Working \:3067\:53ef\:8996\:3001SlideShow \:3067\:975e\:8868\:793a\:306b\:306a\:308b\:3002";
SlideEnsureDeckStyles::usage = "SlideEnsureDeckStyles[nb] \:306f\:30c7\:30c3\:30ad\:306b\:30e1\:30bf\:30bb\:30eb\:7528\:30b9\:30bf\:30a4\:30eb\:5b9a\:7fa9(Note/Directive/Dictionary/Bibliography/References/SlidePrompt\:3002SlideShow \:74b0\:5883\:3067\:975e\:8868\:793a)\:3092\:57cb\:3081\:8fbc\:3080\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:633f\:5165\:30fb\:5c55\:958b\:30fb\:8868\:793a\:5207\:66ff\:304b\:3089\:81ea\:52d5\:3067\:547c\:3070\:308c\:3001documentation.wl \:306e DocInsert* \:3082\:3053\:306e\:5b9a\:7fa9\:3092\:4f7f\:3046\:3002";
SlideTogglePrompts::usage = "SlideTogglePrompts[] \:306f\:5168 SlidePrompt \:30bb\:30eb\:306e\:8868\:793a/\:975e\:8868\:793a\:3092\:5207\:308a\:66ff\:3048\:308b\:3002";
$SlideTranslationLanguage::usage = "$SlideTranslationLanguage \:306f\:7ffb\:8a33\:5148\:8a00\:8a9e\:3002\:65e2\:5b9a\:306f\:65e5\:672c\:8a9e\:74b0\:5883\:306a\:3089 \"English\"\:3002";
$SlideExportExternal::usage = "$SlideExportExternal \:30d1\:30ec\:30c3\:30c8\:306e\:753b\:50cf/mp4 \:66f8\:304d\:51fa\:3057\:3092\:5225\:30d7\:30ed\:30bb\:30b9(wolframscript)\:3067\:884c\:3046\:304b\:3002Automatic(\:65e2\:5b9a)=1 \:5ea6\:8a66\:3057\:3001\:30e9\:30a4\:30bb\:30f3\:30b9\:5e2d\:4e0d\:8db3\:7b49\:3067\:8d77\:52d5\:3067\:304d\:306a\:3051\:308c\:3070\:4ee5\:5f8c\:306f FE \:5185\:51e6\:7406\:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af | True | False\:3002";

SlideTable::usage = "SlideTable[rows] \:306f\:30c7\:30c3\:30ad\:914d\:8272($SlideTheme)\:306e\:8868\:3092\:8fd4\:3059\:3002rows \:306f\:6587\:5b57\:5217\:306e\:884c\:30ea\:30b9\:30c8\:3002\"HeaderRows\"->n (\:65e2\:5b9a 1) \:3067\:30d8\:30c3\:30c0\:884c\:3092\:5f37\:8abf\:3002\:30b7\:30ca\:30ea\:30aa md \:3067\:306f | \:69cb\:6587 (\"| a | b |\"\:30012 \:884c\:76ee\:306b \"| --- | --- |\" \:3067 1 \:884c\:76ee\:304c\:30d8\:30c3\:30c0) \:304c\:540c\:3058\:8868\:306b\:306a\:308b\:3002";
SlidePDFFigure::usage = "SlidePDFFigure[src, page] \:306f PDF \:306e\:30da\:30fc\:30b8\:3092\:56f3(Image)\:3068\:3057\:3066\:5207\:308a\:51fa\:3059\:3002src \:306f\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9 / eagle:ID / sv://URI / src-ID / URL / arxiv:ID / \:6587\:732e\:30ea\:30b9\:30c8(References)\:306e key\:3002URL\:30fbarxiv\:30fbGoogle Slides(\:30d7\:30ec\:30bc\:30f3 URL)\:306f\:81ea\:52d5\:30c0\:30a6\:30f3\:30ed\:30fc\:30c9\:3057\:3066 PDF \:5316\:3057\:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b\:3002png \:7b49\:306e\:753b\:50cf\:30d5\:30a1\:30a4\:30eb\:3082 src \:306b\:6307\:5b9a\:3067\:304d\:308b\:3002\"Crop\"->{{x1,x2},{y1,y2}} (\:5de6\:4e0a\:539f\:70b9\:306e\:30da\:30fc\:30b8\:6bd4\:7387 0..1) \:3067\:9818\:57df\:6307\:5b9a\:3001\"Trim\"->Automatic (\:65e2\:5b9a) \:3067\:767d\:4f59\:767d\:3092\:81ea\:52d5\:30c8\:30ea\:30e0\:3001ImageResolution (\:65e2\:5b9a 144)\:3002\:6587\:732e PDF \:306e\:56f3\:3092\:30b9\:30e9\:30a4\:30c9\:3078\:5f15\:7528\:3059\:308b\:3068\:304d\:306f\:76f4\:5f8c\:306b cite: \:3092\:4ed8\:3059\:3002";
$SlideVisualsPerSlide::usage = "$SlideVisualsPerSlide \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:5c55\:958b\:30d7\:30ed\:30f3\:30d7\:30c8\:304c\:300c\:539f\:5247\:3059\:3079\:3066\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:56f3\:304b\:8868\:3092 1 \:3064\:4ee5\:4e0a\:300d\:3092\:8981\:6c42\:3059\:308b\:3002False \:3067\:5f93\:6765\:306e\:6587\:7ae0\:4e2d\:5fc3\:751f\:6210\:3002";

SlideInsertTalk::usage = "SlideInsertTalk[] \:306f\:30c8\:30fc\:30af\:30bb\:30eb(SlideTalk \:30b9\:30bf\:30a4\:30eb\:3001\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f)\:3092\:633f\:5165\:3059\:308b\:3002\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:306b\:7f6e\:304f\:3002Working \:3067\:53ef\:8996\:3001SlideShow \:74b0\:5883\:3067\:306f\:975e\:8868\:793a\:3001\:66f8\:304d\:51fa\:3057\:304b\:3089\:3082\:9664\:5916\:3002md \:3067\:306f \"talk: \:539f\:7a3f\" \:884c\:3002\:5168\:30b9\:30e9\:30a4\:30c9\:306b\:30c8\:30fc\:30af\:304c\:3042\:308b\:3068 SlideTalkBuild(\:30d1\:30ec\:30c3\:30c8\:300c\:30b7\:30ca\:30ea\:30aa\:300d)\:304c LLM \:306a\:3057\:3067 deck_talk.md \:3092\:675f\:306d\:308b\:3002";
$SlideTalkPerSlide::usage = "$SlideTalkPerSlide \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:5c55\:958b\:30d7\:30ed\:30f3\:30d7\:30c8\:304c\:5404\:30b9\:30e9\:30a4\:30c9\:672b\:5c3e\:306b talk: \:539f\:7a3f(\:3067\:3059\:30fb\:307e\:3059\:8abf 2\:301c6 \:6587)\:3092\:8981\:6c42\:3057\:3001\:30b9\:30e9\:30a4\:30c9\:672c\:6587\:306f\:56f3\:8868+\:4f53\:8a00\:6b62\:3081\:306b\:7d5e\:308b(\:30b9\:30e9\:30a4\:30c9\:3068\:30c8\:30fc\:30af\:3067\:89e3\:8aac\:304c\:5b8c\:6210\:3059\:308b\:5206\:696d)\:3002False \:3067\:5f93\:6765\:3069\:304a\:308a\:3002";

SlidePDFImages::usage = "SlidePDFImages[src] \:306f PDF \:306b\:57cb\:3081\:8fbc\:307e\:308c\:305f\:30e9\:30b9\:30bf\:753b\:50cf(\:5199\:771f\:30fb\:30d3\:30c3\:30c8\:30de\:30c3\:30d7\:56f3)\:3092 Image \:306e\:30ea\:30b9\:30c8\:3067\:62bd\:51fa\:3059\:308b\:3002src \:306f SlidePDFFigure \:3068\:540c\:3058 locator (\:30d1\:30b9 / eagle:ID / sv://URI / URL / arxiv:ID / References \:306e key)\:3002\"MinSize\"->px (\:65e2\:5b9a 80) \:672a\:6e80\:306e\:5c0f\:753b\:50cf(\:30a2\:30a4\:30b3\:30f3\:7b49)\:306f\:9664\:5916\:3002\:30d9\:30af\:30bf\:306e\:307f\:306e PDF \:3067\:306f {} \:3092\:8fd4\:3059(\:305d\:306e\:5834\:5408\:306f SlidePDFFigure \:3067\:30da\:30fc\:30b8\:5207\:308a\:51fa\:3057)\:3002";
SlideDeckFigure::usage = "SlideDeckFigure[deck, n] \:306f\:65e2\:5b58\:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad(.nb)\:306e n \:679a\:76ee\:3092 1920x1080 \:306e Image \:3068\:3057\:3066\:5f15\:7528\:3059\:308b\:3002deck \:306f\:30d1\:30b9\:307e\:305f\:306f References \:306e key\:3002\:8ad6\:6587\:7d39\:4ecb\:30fb\:904e\:53bb\:30b9\:30e9\:30a4\:30c9\:7d39\:4ecb\:3067\:539f\:30b9\:30e9\:30a4\:30c9\:3092\:305d\:306e\:307e\:307e\:898b\:305b\:308b\:306e\:306b\:4f7f\:3046(cite: \:3092\:4ed8\:3059)\:3002";

SlideSourceFile::usage = "SlideSourceFile[locator] \:306f\:6587\:732e locator (\:30d1\:30b9 / eagle:ID / sv://URI / URL / arxiv:ID / Google Slides URL / References \:306e key) \:3092\:89e3\:6c7a\:3057\:3066\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9\:3092\:8fd4\:3059(URL \:7cfb\:306f\:81ea\:52d5\:30c0\:30a6\:30f3\:30ed\:30fc\:30c9+PDF \:5316+\:30ad\:30e3\:30c3\:30b7\:30e5)\:3002\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c ClaudeAttach[SlideSourceFile[...]] \:3067\:8cc7\:6599\:3092\:95b2\:89a7\:3057\:3001\:5f15\:7528\:3059\:308b\:30da\:30fc\:30b8\:30fb\:9818\:57df\:3092\:6c7a\:3081\:308b\:306e\:306b\:4f7f\:3046\:3002";

$SlideHideToolbarInSlideshow::usage = "$SlideHideToolbarInSlideshow \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:8868\:793a\:5207\:66ff(SlideToggleScreenEnvironment)\:3067 SlideShow \:3078\:5165\:308b\:3068\:304d\:306b\:6a19\:6e96\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:30c4\:30fc\:30eb\:30d0\:30fc(MultipurposeBar)\:3068\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5074 DockedCells(CloudPublishable \:306e Public/Private \:30d0\:30c3\:30b8\:7b49)\:3092\:4e00\:6642\:9000\:907f\:3057\:3001Working \:3078\:623b\:3059\:3068\:304d\:306b\:5fa9\:5143\:3059\:308b\:3002\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5074 DockedCells \:306f\:30b9\:30bf\:30a4\:30eb\:30b7\:30fc\:30c8\:306e\:30b9\:30e9\:30a4\:30c9\:30ca\:30d3\:30d0\:30fc\:5b9a\:7fa9\:3092\:4e0a\:66f8\:304d\:3059\:308b\:305f\:3081\:3001\:9000\:907f\:3057\:306a\:3044\:3068\:30ca\:30d3\:30d0\:30fc\:304c\:51fa\:306a\:3044\:3002";

Begin["`Private`"]

(* ===================== \:8a2d\:5b9a\:30fb\:30c6\:30fc\:30de ===================== *)

$SlideStyleDefinitions = "Normal use.nb";
$SlideImageSize = {1920, 1080};
(* Templates/Slides \:306e HTML (padding 66px 110px 56px @1920x1080) \:306b\:6e96\:62e0\:3057\:305f\:4f59\:767d *)
$SlideMargins = {{100, 60}, {50, 64}};

(* \:66f8\:304d\:51fa\:3057\:306b Input/Code \:30bb\:30eb\:3092\:542b\:3081\:308b\:304b\:306e\:65e2\:5b9a (SlideDeckImages \:306e
   "IncludeInput"->Automatic \:6642\:306b\:53c2\:7167)\:3002\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:8868\:793a\:3069\:304a\:308a\:304c\:65e2\:5b9a\:3002 *)
If[!ValueQ[$SlideIncludeInput], $SlideIncludeInput = Automatic];

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
iMetaStyleCellQ[Cell[_, "Note" | "Dictionary" | "Directive" | "Bibliography" | "References" | "SlidePrompt" | "SlideTalk", ___]] := True;
iMetaStyleCellQ[_] := False;

iNoExportCellQ[cell_Cell] := MatchQ[cell,
  Cell[___, CellTags -> (t_ /; !FreeQ[{t}, "NoExport"]), ___]];

(* CellTags "ShowInput" \:4ed8\:304d\:30bb\:30eb\:306f\:8a2d\:5b9a\:306b\:3088\:3089\:305a\:5fc5\:305a\:6b8b\:3059 (NoExport \:306e\:9006) *)
iShowInputCellQ[cell_Cell] := MatchQ[cell,
  Cell[___, CellTags -> (t_ /; !FreeQ[{t}, "ShowInput"]), ___]];

iVisualCellQ[cell_Cell] := !FreeQ[cell,
  _GraphicsBox | _Graphics3DBox | _RasterBox | TemplateBox[_, s_String /; StringStartsQ[s, "VideoBox"], ___]];

iCodeCellQ[Cell[_, "Input" | "Code" | "NaturalLanguageInput", ___]] := True;
iCodeCellQ[_] := False;

(* CellGroupData \:3092\:5c55\:958b\:3057\:3066\:8449\:30bb\:30eb\:306e\:5e73\:5766\:30ea\:30b9\:30c8\:306b\:3059\:308b *)
iFlattenCells[items_List] := Flatten[Replace[items,
  Cell[CellGroupData[g_List, ___], ___] :> iFlattenCells[g], {1}]];

(* \:6298\:308a\:305f\:305f\:307e\:308c\:305f\:30bb\:30eb\:7fa4\:306e\:8868\:793a\:30bb\:30eb\:3060\:3051\:3092\:8fd4\:3059\:3002CellGroupData[cells,Closed] \:306f
   \:5148\:982d\:306e\:307f\:3001CellGroupData[cells,{i,..}] \:306f\:6307\:5b9a\:30bb\:30eb\:306e\:307f\:304c\:8868\:793a\:3055\:308c\:308b
   (In \:3092\:96a0\:3057\:3066 Out \:3060\:3051\:898b\:305b\:308b\:5f62\:306f {2})\:3002 *)
iGroupVisibleCells[g_List, {}] := g;
iGroupVisibleCells[g_List, {Closed}] := Take[g, Min[1, Length[g]]];
iGroupVisibleCells[g_List, {idx : {___Integer}}] :=
  g[[Select[idx, 1 <= # <= Length[g] &]]];
iGroupVisibleCells[g_List, {n_Integer}] := iGroupVisibleCells[g, {{n}}];
iGroupVisibleCells[g_List, _] := g;

(* \:6298\:308a\:305f\:305f\:307f\:3067\:96a0\:308c\:3066\:3044\:308b\:30bb\:30eb\:3092\:9664\:3044\:305f\:5e73\:5766\:30ea\:30b9\:30c8\:3002\:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:7528
   (\:7de8\:96c6\:7cfb\:306f\:96a0\:308c\:305f\:30bb\:30eb\:3082\:4fdd\:6301\:3059\:308b iFlattenCells \:3092\:4f7f\:3046)\:3002 *)
iFlattenVisibleCells[items_List] := Flatten[Replace[items,
  Cell[CellGroupData[g_List, st___], ___] :>
    iFlattenVisibleCells[iGroupVisibleCells[g, {st}]], {1}]];

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
  {lines, meta, body, slides = {}, cur = None, curContent = {}, curTalk = {},
   lastBulletLevel = 0,
   inCode = False, codeLines = {}, pushSlide, finishCode,
   inAppendix = False, appendixLines = {},
   paraStyles = {"ItemParagraph", "SubitemParagraph", "SubsubitemParagraph"},
   bulletStyles = {"Item", "Subitem", "Subsubitem"}},
  lines = StringSplit[StringReplace[md, "\r\n" -> "\n"], "\n"];
  {meta, body} = iParseFrontMatter[lines];
  (* talk: \:884c\:306f\:30b9\:30e9\:30a4\:30c9\:672b\:5c3e\:306e 1 \:30a8\:30f3\:30c8\:30ea\:306b\:675f\:306d\:308b (\:30c8\:30fc\:30af\:30bb\:30eb\:306f\:5e38\:306b\:6700\:5f8c) *)
  pushSlide[] := (
    If[curTalk =!= {},
      AppendTo[curContent, {"Talk", StringRiffle[curTalk, "\n"]}]];
    curTalk = {};
    If[cur =!= None,
      AppendTo[slides, Append[cur, "Content" -> curContent]]]);
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
      StringStartsQ[StringTrim[line], "talk:"],
      AppendTo[curTalk, StringTrim[StringDrop[StringTrim[line], 5]]],
      StringStartsQ[StringTrim[line], "cite:"],
      AppendTo[curContent, {"Cite", StringTrim[StringDrop[StringTrim[line], 5]]}],
      StringStartsQ[StringTrim[line], "|"],
      (* \:8868: | \:533a\:5207\:308a\:884c\:306e\:9023\:7d9a\:3002"| --- |" \:884c\:3067\:305d\:306e\:4e0a\:307e\:3067\:304c\:30d8\:30c3\:30c0 *)
      Module[{row = iSWParseTableRow[line]},
        Which[
          row === "Separator",
          If[curContent =!= {} && curContent[[-1, 1]] === "Table",
            curContent[[-1, 2, "HeaderRows"]] =
              Length[curContent[[-1, 2, "Rows"]]]],
          curContent =!= {} && curContent[[-1, 1]] === "Table",
          curContent[[-1, 2, "Rows"]] =
            Append[curContent[[-1, 2, "Rows"]], row],
          True,
          AppendTo[curContent,
            {"Table", <|"Rows" -> {row}, "HeaderRows" -> 0|>}]]],
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
      (AppendTo[out, "## !image " <> slide["ImagePage"]];
       Do[AppendTo[out, StringRiffle[("talk: " <> #) & /@
           StringSplit[item[[2]], "\n"], "\n"]],
         {item, Cases[Lookup[slide, "Content", {}], {"Talk", _}]}]),
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
          "Table", iSWTableToMd[item[[2]]],
          "Talk", StringRiffle[("talk: " <> #) & /@ StringSplit[item[[2]], "\n"], "\n"],
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

(* \:8868\:30bb\:30eb: \:5185\:5bb9\:306f TaggingRules \:306b\:4fdd\:6301\:3057\:3066 md \:3078\:5f80\:5fa9\:53ef\:80fd\:306b\:3059\:308b\:3002
   "ShowInput" \:30bf\:30b0\:3067 IncludeInput \:8a2d\:5b9a\:306b\:3088\:3089\:305a\:66f8\:304d\:51fa\:3057\:306b\:6b8b\:308b *)
iContentCell[{"Talk", text_String}] := Cell[text, "SlideTalk"];

iContentCell[{"Table", spec_Association}] := Module[
  {rows = Lookup[spec, "Rows", {}], hdr = Lookup[spec, "HeaderRows", 0]},
  (* ShowStringCharacters->False: Input \:30bb\:30eb\:306f\:65e2\:5b9a\:3067\:6587\:5b57\:5217\:3092\:5f15\:7528\:7b26\:4ed8\:304d\:8868\:793a\:3059\:308b *)
  Cell[BoxData[ToBoxes[SlideTable[rows, "HeaderRows" -> hdr]]], "Input",
    TextAlignment -> Center, ShowStringCharacters -> False,
    CellTags -> {"SlideTable", "ShowInput"},
    TaggingRules -> {"SWTableRows" -> rows, "SWTableHeaderRows" -> hdr}]];

(* \:51fa\:5178\:30bb\:30eb: \:5c0f\:3055\:3044\:30d5\:30a9\:30f3\:30c8\:3067\:51fa\:5178(URL / (\:8457\:8005, \:5e74))\:3092\:660e\:8a18\:3059\:308b *)
iContentCell[{"Cite", src_String}] := Cell[TextData[StyleBox[
  If[StringStartsQ[src, "\:51fa\:5178" | "Source" | "\:51fa\:6240"], src, "\:51fa\:5178: " <> src],
  FontSize -> 9, FontColor -> GrayLevel[0.45]]], "Text", CellTags -> "Citation"];

(* ---- \:8868 (2026-08-26): md \:306e | \:69cb\:6587 <-> \:30c6\:30fc\:30de\:914d\:8272 Grid ---- *)
iSWParseTableRow[line_String] := Module[{t = StringTrim[line], inner, cells},
  inner = StringReplace[t, {StartOfString ~~ "|" -> "", "|" ~~ EndOfString -> ""}];
  cells = StringTrim /@ StringSplit[inner, "|", All];
  If[cells =!= {} && AllTrue[cells, StringMatchQ[#, ("-" | ":") ..] &],
    "Separator", cells]];

iSWTableToMd[spec_Association] := Module[
  {rows = Lookup[spec, "Rows", {}], hdr = Lookup[spec, "HeaderRows", 0], ncol, lines},
  If[rows === {}, Return[""]];
  ncol = Max[Length /@ rows];
  lines = ("| " <> StringRiffle[ToString /@ PadRight[#, ncol, ""], " | "] <> " |") & /@ rows;
  If[0 < hdr <= Length[rows],
    lines = Insert[lines,
      "| " <> StringRiffle[Table["---", ncol], " | "] <> " |", hdr + 1]];
  StringRiffle[lines, "\n"]];

Options[SlideTable] = {"HeaderRows" -> 1, FontSize -> 15};

SlideTable[rows_List, OptionsPattern[]] := Module[
  {hdr = OptionValue["HeaderRows"], fs = OptionValue[FontSize], ncol, items},
  ncol = Max[Length /@ rows, 1];
  items = PadRight[#, ncol, ""] & /@ rows;
  Style[Grid[items,
    Alignment -> {Left, Center},
    Frame -> All, FrameStyle -> SlideThemeColor["PanelBorder"],
    Background -> If[hdr > 0,
      {None, Table[SlideThemeColor["PanelBackground"], hdr]}, None],
    ItemStyle -> If[hdr > 0,
      {Automatic, Table[Directive[Bold, SlideThemeColor["Bullet"]], hdr]}, Automatic],
    Spacings -> {1.2, 0.6}],
    FontFamily -> $SlideFontFamily, FontSize -> fs,
    FontColor -> SlideThemeColor["Text"]]];

(* ---- \:6587\:732e PDF \:306e\:56f3\:306e\:5207\:308a\:51fa\:3057 (2026-08-26) ----
   src: \:30d5\:30a1\:30a4\:30eb\:30d1\:30b9 / eagle:ID / sv://URI / src-ID / References \:30bb\:30eb\:306e key\:3002
   "Crop" \:306f\:5de6\:4e0a\:539f\:70b9\:306e\:30da\:30fc\:30b8\:6bd4\:7387 {{x1,x2},{y1,y2}} (0..1)\:3002 *)
iSWResolveRefPath[src_String] := Which[
  FileExistsQ[src], src,
  StringStartsQ[src, "eagle:", IgnoreCase -> True],
  Module[{id = StringTrim[StringDrop[src, 6]], p},
    p = If[Length[DownValues[SourceVault`SourceVaultEagleItemPath]] > 0,
      Quiet[Check[SourceVault`SourceVaultEagleItemPath[
        SourceVault`SourceVaultEagleItem[id]], $Failed]], $Failed];
    If[StringQ[p] && FileExistsQ[p], p, $Failed]],
  StringStartsQ[src, "sv://"] || StringStartsQ[src, "src-"],
  Module[{r},
    r = If[Length[DownValues[SourceVault`SourceVaultResolveReference]] > 0,
      Quiet[Check[SourceVault`SourceVaultResolveReference[src], $Failed]], $Failed];
    If[AssociationQ[r] && StringQ[Lookup[r, "File"]] && FileExistsQ[Lookup[r, "File"]],
      r["File"], $Failed]],
  StringStartsQ[src, "http://"] || StringStartsQ[src, "https://"] ||
    StringStartsQ[src, "arxiv:", IgnoreCase -> True],
  iSWFetchURLFile[src],
  True,
  Module[{nb = iSWResolveTargetNb[], refs, hit},
    If[Head[nb] =!= NotebookObject, $Failed,
      refs = Quiet[Check[iSWReferencesList[nb], {}]];
      hit = SelectFirst[refs, #["Key"] === src &, None];
      If[hit === None || hit["Locator"] === src, $Failed,
        iSWResolveRefPath[hit["Locator"]]]]]];

Options[SlidePDFFigure] = {"Crop" -> None, "Trim" -> Automatic,
  ImageResolution -> 144};

SlidePDFFigure[src_String, page_Integer : 1, OptionsPattern[]] := Module[
  {path, img, crop = OptionValue["Crop"], dims},
  path = iSWResolveRefPath[src];
  If[!StringQ[path] || !FileExistsQ[path],
    Return[Failure["NoFile",
      <|"MessageTemplate" -> "cannot resolve `1` to a local file",
        "MessageParameters" -> {src}|>]]];
  If[MemberQ[{"png", "jpg", "jpeg", "gif", "webp", "bmp", "tif", "tiff"},
      ToLowerCase[FileExtension[path]]],
    (* \:753b\:50cf\:30d5\:30a1\:30a4\:30eb\:306f\:305d\:306e\:307e\:307e\:300c\:30da\:30fc\:30b8\:300d\:3068\:3057\:3066\:6271\:3046 (Crop/Trim \:306f\:5171\:901a) *)
    img = Quiet[Check[Import[path], $Failed]],
    (* 15.0 \:5b9f\:6e2c: {"PDF","PageImages",n} \:306f\:5931\:6557\:3057 {"PageImages",n} \:304c\:6b63 *)
    img = Quiet[Check[Import[path, {"PageImages", page},
      ImageResolution -> OptionValue[ImageResolution]], $Failed]];
    If[!ImageQ[img] && !ListQ[img],
      img = Quiet[Check[Import[path, {"PDF", "PageImages", page},
        ImageResolution -> OptionValue[ImageResolution]], $Failed]]]];
  If[ListQ[img], img = If[img === {}, $Failed, First[img]]];
  If[!ImageQ[img],
    Return[Failure["BadPage",
      <|"MessageTemplate" -> "cannot render page `1` of `2`",
        "MessageParameters" -> {page, path}|>]]];
  If[MatchQ[crop, {{_?NumericQ, _?NumericQ}, {_?NumericQ, _?NumericQ}}],
    dims = ImageDimensions[img];
    img = ImageTake[img,
      Clip[{Floor[dims[[2]]*crop[[2, 1]]] + 1, Ceiling[dims[[2]]*crop[[2, 2]]]},
        {1, dims[[2]]}],
      Clip[{Floor[dims[[1]]*crop[[1, 1]]] + 1, Ceiling[dims[[1]]*crop[[1, 2]]]},
        {1, dims[[1]]}]]];
  If[OptionValue["Trim"] === Automatic, img = Quiet[Check[ImageCrop[img], img]]];
  img];

(* ---- URL / arxiv / Google Slides \:306e\:53d6\:5f97 (2026-08-26) ----
   \:6587\:732e locator \:3092\:5c40\:6240\:30d5\:30a1\:30a4\:30eb\:3078\:6b63\:898f\:5316\:3059\:308b\:3002Google Slides \:306f /export/pdf\:3001
   arxiv:ID \:306f arxiv.org/pdf\:3002\:53d6\:5f97\:7269\:306f $TemporaryDirectory \:4e0b\:306b\:30cf\:30c3\:30b7\:30e5\:540d\:3067\:30ad\:30e3\:30c3\:30b7\:30e5 *)
iSWQuoteURL[src_String] := Which[
  StringStartsQ[src, "arxiv:", IgnoreCase -> True],
  "https://arxiv.org/pdf/" <> StringTrim[StringDrop[src, 6]],
  StringContainsQ[src, "docs.google.com/presentation/d/"],
  Module[{id = StringCases[src,
      "docs.google.com/presentation/d/" ~~ i : Except["/" | "?" | "#"] .. :> i, 1]},
    If[id === {}, src,
      "https://docs.google.com/presentation/d/" <> First[id] <> "/export/pdf"]],
  StringContainsQ[src, "arxiv.org/abs/"],
  StringReplace[src, "arxiv.org/abs/" -> "arxiv.org/pdf/"],
  True, src];

(* URLParse[..,"Path"] \:306f\:30bb\:30b0\:30e1\:30f3\:30c8\:306e\:30ea\:30b9\:30c8\:3067\:8fd4\:308b\:3053\:3068\:304c\:3042\:308b *)
iSWQuoteExt[url_String] := Module[{p, s, e},
  p = Quiet[Check[URLParse[url, "Path"], ""]];
  s = Which[StringQ[p], p, ListQ[p] && p =!= {}, ToString[Last[p]], True, ""];
  e = ToLowerCase[Quiet[Check[FileExtension[s], ""]]];
  If[MemberQ[{"pdf", "png", "jpg", "jpeg", "gif", "webp"}, e], e, "pdf"]];

iSWQuoteCacheDir[] := Module[
  {d = FileNameJoin[{$TemporaryDirectory, "SlideWorkflowQuotes"}]},
  If[!DirectoryQ[d], Quiet[CreateDirectory[d]]]; d];

iSWQuoteCacheFile[src_String] := Module[{url = iSWQuoteURL[src]},
  FileNameJoin[{iSWQuoteCacheDir[],
    StringTake[Hash[url, "SHA256", "HexString"], 16] <> "." <> iSWQuoteExt[url]}]];

iSWFetchURLFile[src_String] := Module[{url = iSWQuoteURL[src], file},
  file = iSWQuoteCacheFile[src];
  If[FileExistsQ[file] && FileByteCount[file] > 0, Return[file]];
  Quiet[Check[URLDownload[url, file, TimeConstraint -> 60], $Failed]];
  If[FileExistsQ[file] && FileByteCount[file] > 0, file, $Failed]];

(* ---- PDF \:57cb\:3081\:8fbc\:307f\:753b\:50cf\:306e\:62bd\:51fa: \:5199\:771f\:30fb\:30e9\:30b9\:30bf\:56f3\:306f\:30da\:30fc\:30b8\:5207\:308a\:51fa\:3057\:3088\:308a\:539f\:56f3\:304c\:6b63\:78ba ---- *)
Options[SlidePDFImages] = {"MinSize" -> 80};

SlidePDFImages[src_String, OptionsPattern[]] := Module[{path, imgs, im},
  path = iSWResolveRefPath[src];
  If[!StringQ[path] || !FileExistsQ[path],
    Return[Failure["NoFile",
      <|"MessageTemplate" -> "cannot resolve `1` to a local file",
        "MessageParameters" -> {src}|>]]];
  If[MemberQ[{"png", "jpg", "jpeg", "gif", "webp", "bmp", "tif", "tiff"},
      ToLowerCase[FileExtension[path]]],
    im = Quiet[Check[Import[path], $Failed]];
    Return[If[ImageQ[im], {im}, {}]]];
  imgs = Quiet[Check[Import[path, "Images"], $Failed]];
  If[!ListQ[imgs], imgs = {}];
  Select[imgs, ImageQ[#] && Min[ImageDimensions[#]] >= OptionValue["MinSize"] &]];

(* ---- \:904e\:53bb\:30c7\:30c3\:30ad\:306e\:30b9\:30e9\:30a4\:30c9 1 \:679a\:3092\:753b\:50cf\:5f15\:7528 ---- *)
SlideDeckFigure[src_String, n_Integer : 1] := Module[{path, imgs},
  path = iSWResolveRefPath[src];
  If[!StringQ[path] || !FileExistsQ[path] ||
      ToLowerCase[FileExtension[path]] =!= "nb",
    Return[Failure["NoDeck",
      <|"MessageTemplate" -> "cannot resolve `1` to a slide notebook",
        "MessageParameters" -> {src}|>]]];
  imgs = Quiet[Check[SlideDeckImages[path, "Slides" -> {n}], $Failed]];
  If[!MatchQ[imgs, {__Image}],
    Return[Failure["BadSlide",
      <|"MessageTemplate" -> "cannot render slide `1` of `2`",
        "MessageParameters" -> {n, path}|>]]];
  First[imgs]];

(* \:8cc7\:6599\:306e\:95b2\:89a7\:7528: locator \:3092\:89e3\:6c7a\:3057\:305f\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9 (ClaudeAttach \:306b\:6e21\:3059) *)
SlideSourceFile[src_String] := Module[{p = iSWResolveRefPath[src]},
  If[StringQ[p] && FileExistsQ[p], p,
    Failure["NoFile",
      <|"MessageTemplate" -> "cannot resolve `1` to a local file",
        "MessageParameters" -> {src}|>]]];

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
    Join[{iNavBarCell[],
      Cell[iLookupString[slide, "Title"], "Subsection", CellOpen -> False, CellTags -> iSubsectionTags[slide]],
      Cell[BoxData[ToBoxes[iSizedSlideImage[<|"Path" -> slide["ImagePage"], "Width" -> Automatic|>, 900, 500]]],
        "Input", TextAlignment -> Center, CellMargins -> {{0, 0}, {0, 0}}, CellTags -> "ImagePage"]},
     iContentCell /@ Cases[Lookup[slide, "Content", {}], {"Talk", _}]],
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
  sd = iSWWrapStyleDefinitions[sd];  (* \:30e1\:30bf\:30bb\:30eb\:3092 SlideShow \:3067\:975e\:8868\:793a\:306b\:3059\:308b\:57cb\:3081\:8fbc\:307f\:30b9\:30bf\:30a4\:30eb *)
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

(* \:30b9\:30e9\:30a4\:30c9\:5206\:5272\:306e\:5171\:901a\:51e6\:7406\:3002flatten \:306b iFlattenCells(\:7de8\:96c6\:7528) \:304b
   iFlattenVisibleCells(\:66f8\:304d\:51fa\:3057\:7528) \:3092\:6e21\:3059\:3002 *)
iSlideSplit[nb_Notebook, flatten_] := Module[{flat, navPos, endPos, prelude, slides, appendix},
  flat = flatten[First[nb]];
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

SlideDeckSlides[nb_Notebook] := iSlideSplit[nb, iFlattenCells];

SlideDeckSlides[nbfile_String] := With[{nb = iGetNotebook[nbfile]},
  If[nb === $Failed, $Failed, SlideDeckSlides[nb]]];

SlideDeckSlides[nbo_NotebookObject] := SlideDeckSlides[NotebookGet[nbo]];

iAsNotebook[nb_Notebook] := nb;
iAsNotebook[nbfile_String] := iGetNotebook[nbfile];
iAsNotebook[nbo_NotebookObject] := NotebookGet[nbo];

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

(* Automatic/True: \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:8868\:793a\:3069\:304a\:308a\:6b8b\:3059 / False: \:5168\:90e8\:9664\:304f / "Visual": \:56f3\:3092\:542b\:3080 Input \:306e\:307f *)
iResolveIncludeInput[Automatic] := iResolveIncludeInput2[$SlideIncludeInput];
iResolveIncludeInput[inc_] := iResolveIncludeInput2[inc];
iResolveIncludeInput2["Visual"] := "Visual";
iResolveIncludeInput2[False] := False;
iResolveIncludeInput2[_] := True;

iKeepCodeCellQ[cell_Cell, inc_] := Which[
  iShowInputCellQ[cell], True,
  inc === True, True,
  inc === "Visual", iVisualCellQ[cell],
  True, False];

iRasterFilterCells[cells_List, includeInput_] := Module[{inc = iResolveIncludeInput[includeInput]},
  Select[cells,
    And[!iNavBarCellQ[#], !iAudioCellQ[#], !iClosedCellQ[#], !iNoExportCellQ[#],
        !iMetaStyleCellQ[#],
        Or[!iCodeCellQ[#], iKeepCodeCellQ[#, inc]]] &]];

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
      Module[{fw = finalWidth[dims], gained},
        gained = fw - bestFW;
        If[fw > bestFW, best = cur; bestW = curW; bestFW = fw];
        (* \:6539\:5584\:304c\:5c0f\:3055\:3051\:308c\:3070\:6253\:3061\:5207\:308b\:3002\:56f3\:30fb\:30b3\:30fc\:30c9\:652f\:914d\:306e\:30b9\:30e9\:30a4\:30c9\:306f\:5e45\:3092\:5e83\:3052\:3066\:3082
           \:4e0d\:52d5\:8981\:7d20\:304c\:6b8b\:308b\:305f\:3081\:4f38\:3073\:305a\:3001\:518d\:63cf\:753b\:306e\:5206\:3060\:3051 FE \:3092\:5360\:6709\:3059\:308b (99MB \:30c7\:30c3\:30ad\:5bfe\:7b56) *)
        If[gained < 0.02*availW, Break[]]]];
    If[TrueQ[opts["Verbose"]] && bestW =!= w0,
      Print["  slide ", opts["Number"], ": reflow ", w0, "pt -> ", Round[bestW],
        "pt (final width ", Round[bestFW], "/", availW, "px)"]];
    iComposeCanvas[best, target, opts["Background"], "TopLeft", opts["Number"], False, margins]]];

SlideDeckImages[source_ /; StringQ[source] || Head[source] === Notebook || Head[source] === NotebookObject, OptionsPattern[]] := Module[
  {nb, data, slides, sel, target, sd, imgs},
  (* \:66f8\:304d\:51fa\:3057\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:8868\:793a\:72b6\:614b\:3092\:5c0a\:91cd\:3059\:308b:
     \:6298\:308a\:305f\:305f\:307f\:3067\:96a0\:308c\:305f\:30bb\:30eb\:306f\:51fa\:3055\:306a\:3044 *)
  nb = iAsNotebook[source];
  data = If[Head[nb] === Notebook, iSlideSplit[nb, iFlattenVisibleCells], $Failed];
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

(* 2026-08-25: \:7d20\:306e styled \:30bb\:30eb\:306b\:3059\:308b\:3002\:898b\:305f\:76ee\:306f SlideEnsureDeckStyles \:304c\:57cb\:3081\:8fbc\:3080
   StyleData["SlidePrompt"] \:304c\:4e0e\:3048\:3001SlideShow \:74b0\:5883\:3067\:306f stylesheet \:5074\:3067\:975e\:8868\:793a\:306b\:306a\:308b *)
iSWPromptCell[text_String] := Cell[text, "SlidePrompt"];

iSWSkeletonSlideCells[] := {
  SlideWorkflow`Private`iNavBarCell[],
  Cell[iSL["\:65b0\:3057\:3044\:30b9\:30e9\:30a4\:30c9", "New Slide"], "Subsection", CellTags -> {"Top"}],
  iSWPromptCell[iSL[
    "\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:4f1d\:3048\:305f\:3044\:5185\:5bb9(\:30d7\:30ed\:30f3\:30d7\:30c8)\:3092\:66f8\:304d\:3001\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:5c55\:958b\:300d\:3092\:62bc\:3059\:3002\:300c\:25ef\:679a\:69cb\:6210\:3067\:300d\:3068\:6307\:793a\:3059\:308b\:3068\:8907\:6570\:30b9\:30e9\:30a4\:30c9\:306b\:4e00\:62ec\:5c55\:958b\:3067\:304d\:308b\:3002\:6587\:732e\:30ea\:30b9\:30c8\:306e [key] \:3067\:8cc7\:6599\:3092\:53c2\:7167\:3067\:304d\:308b\:3002",
    "Write the prompt for this slide here and press Expand on the palette. Ask for 'N slides' to expand into multiple slides; refer to references as [key]."]]};

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
  "ItemParagraph", "SubitemParagraph", "SubsubitemParagraph", "Text", "Section",
  "SlideTalk"};

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
      MatchQ[c, Cell[___, TaggingRules -> {___, "SWTableRows" -> _, ___}, ___]],
      Module[{tr = FirstCase[c, (TaggingRules -> r_List) :> r, {}, {1}]},
        AppendTo[lines, iSWTableToMd[<|"Rows" -> Lookup[tr, "SWTableRows", {}],
          "HeaderRows" -> Lookup[tr, "SWTableHeaderRows", 0]|>]]],
      MatchQ[c, Cell[_, "SlideTalk", ___]],
      AppendTo[lines, StringRiffle[("talk: " <> #) & /@
        StringSplit[SlideWorkflow`Private`iCellText[c], "\n"], "\n"]],
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
  "| \:5217A | \:5217B |  (\:8868\:30022 \:884c\:76ee\:306b | --- | --- | \:3092\:7f6e\:304f\:3068 1 \:884c\:76ee\:304c\:30d8\:30c3\:30c0)\n" <>
  "talk: \:3053\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f (\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:306b 1 \:56de)\n" <>
  If[nKeep > 0,
    "<<FIG1>> \:301c <<FIG" <> ToString[nKeep] <> ">> : \:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb\:3092\:305d\:306e\:4f4d\:7f6e\:306b\:4fdd\:6301\:3059\:308b\:30c8\:30fc\:30af\:30f3(\:884c\:5358\:72ec\:3067\:7f6e\:304f)\n", ""] <>
  "\n\:898f\:5247:\n" <>
  "- \:30b9\:30bf\:30a4\:30eb(\:8a08\:7b97\:3068\:81ea\:7136\:30b7\:30ea\:30fc\:30ba\:6e96\:62e0): 1 \:679a 1 \:30e1\:30c3\:30bb\:30fc\:30b8\:3002\:30bf\:30a4\:30c8\:30eb\:306f\:77ed\:3044\:540d\:8a5e\:53e5(\:9023\:7d9a\:30b9\:30e9\:30a4\:30c9\:306f\:540c\:540d\:53ef)\:3002\:7b87\:6761\:66f8\:304d\:306f\:4f53\:8a00\:6b62\:3081\:4e2d\:5fc3 3\:301c6 \:884c\:30fb\:968e\:5c64 2 \:6bb5\:307e\:3067\:3002\:56f3\:30fb\:8868\:304c\:4e3b\:5f79\:3001\:6587\:5b57\:306f\:88dc\:8db3\:3002\n" <>
  "- \:901a\:5e38\:306f 1 \:679a(## \:306f 1 \:500b)\:3002\:6307\:793a\:3067\:8907\:6570\:679a\:306b\:5206\:3051\:308b\:3088\:3046\:6c42\:3081\:3089\:308c\:305f\:5834\:5408\:306e\:307f\:8907\:6570\:306e ## \:3092\:51fa\:529b\:3059\:308b\:3002\n" <>
  "- \:8ad6\:6587\:30fbweb\:30fbPDF \:7531\:6765\:306e\:56f3\:30fb\:5f15\:7528\:30fb\:30c7\:30fc\:30bf\:3092\:4f7f\:3046\:5834\:5408\:306f\:3001\:76f4\:5f8c\:306b cite: \:884c\:3067\:51fa\:5178(URL \:307e\:305f\:306f (\:8457\:8005, \:5e74))\:3092\:5fc5\:305a\:660e\:8a18\:3059\:308b\:3002\n" <>
  If[nKeep > 0,
    "- \:65e2\:5b58\:56f3\:30c8\:30fc\:30af\:30f3 <<FIGn>> \:306f\:3001\:524a\:9664\:306e\:6307\:793a\:304c\:306a\:3044\:9650\:308a\:3059\:3079\:3066\:9069\:5207\:306a\:4f4d\:7f6e\:306b\:914d\:7f6e\:3059\:308b\:3002\n", ""] <>
  If[TrueQ[$SlideVisualsPerSlide],
    "- \:539f\:5247\:3068\:3057\:3066\:3059\:3079\:3066\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:56f3(<<FIGn>>)\:304b\:8868(| \:69cb\:6587)\:3092 1 \:3064\:4ee5\:4e0a\:5165\:308c\:308b\:3002\:6bd4\:8f03\:30fb\:4ed5\:69d8\:30fb\:6570\:5024\:306e\:7f85\:5217\:306f\:8868\:306b\:3059\:308b\:3002\:8ad6\:6587\:30fb\:65e2\:5b58\:8cc7\:6599\:306e\:7d39\:4ecb\:3067\:306f\:539f\:56f3\:30fb\:539f\:8868\:3092\:305d\:306e\:307e\:307e\:5f15\:7528\:3057\:3066\:4f7f\:3046(<<FIGn>> \:306e\:5f15\:7528\:56f3\:3092\:512a\:5148\:3057\:3001\:4f5c\:308a\:76f4\:3055\:306a\:3044)\:3002\n", ""] <>
  If[TrueQ[$SlideTalkPerSlide],
    "- \:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:306b talk: \:884c\:3067\:767a\:8868\:539f\:7a3f\:3092\:66f8\:304f(\:3067\:3059\:30fb\:307e\:3059\:8abf 2\:301c6 \:6587\:3001\:5192\:982d\:306b\:524d\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:306e\:63a5\:7d9a\:3092\:4e00\:8a00)\:3002\:30b9\:30e9\:30a4\:30c9\:672c\:6587\:306f\:56f3\:8868+\:4f53\:8a00\:6b62\:3081\:306e\:77ed\:3044\:7b87\:6761\:66f8\:304d\:306b\:3068\:3069\:3081\:3001\:8aac\:660e\:306e\:6587\:7ae0\:306f talk \:304c\:62c5\:3046(\:30b9\:30e9\:30a4\:30c9\:3068 talk \:3067\:89e3\:8aac\:304c\:5b8c\:6210\:3002\:540c\:3058\:6587\:3092\:4e21\:65b9\:306b\:66f8\:304b\:306a\:3044)\:3002\:8a18\:53f7\:30fbURL \:306e\:8aad\:307f\:4e0a\:3052\:3092 talk \:306b\:5165\:308c\:306a\:3044\:3002\n", ""] <>
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
If[!ValueQ[$SlideVisualsPerSlide], $SlideVisualsPerSlide = True];
If[!ValueQ[$SlideTalkPerSlide], $SlideTalkPerSlide = True];
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
  True, Cell[BoxData[ToBoxes[g]], "Input", TextAlignment -> Center,
    ShowStringCharacters -> False]];

(* ---- SlideApplyScenario: \:30b9\:30e9\:30a4\:30c9\:5dee\:3057\:66ff\:3048\:306e\:552f\:4e00\:306e\:6c7a\:5b9a\:7684\:66f8\:8fbc\:307f\:53e3 ---- *)
Options[SlideApplyScenario] = {"Figures" -> {}};

SlideApplyScenario[slideNo_Integer, md_String, opts : OptionsPattern[]] :=
  With[{nb = iSWResolveTargetNb[]},
    If[Head[nb] =!= NotebookObject,
      Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>],
      SlideApplyScenario[nb, slideNo, md, opts]]];

SlideApplyScenario[nb_NotebookObject, slideNo_Integer, md_String, OptionsPattern[]] := Module[
  {ctx, figs, allKeeps, mdText, sc, slides, newCells, cells},
  Quiet[SlideEnsureDeckStyles[nb]];
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
iSWExpandAgentTask[slideNo_, promptText_, title_, md_, k_, metaBlocks_String : ""] :=
  metaBlocks <>
  "SlideWorkflow \:306e\:30b9\:30e9\:30a4\:30c9\:7de8\:96c6\:30bf\:30b9\:30af\:3002\:3053\:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo] <>
  If[StringQ[title] && title =!= "", "(\:30bf\:30a4\:30c8\:30eb:\:300c" <> title <> "\:300d)", ""] <>
  " \:3092\:4ee5\:4e0b\:306e\:6307\:793a\:3067\:66f4\:65b0\:3059\:308b\:3002\n\n" <>
  "\:30b9\:30e9\:30a4\:30c9\:6307\:793a:\n" <> promptText <> "\n\n" <>
  If[StringTrim[md] =!= "",
    "\:73fe\:5728\:306e\:30b9\:30e9\:30a4\:30c9\:5185\:5bb9(\:30b7\:30ca\:30ea\:30aa md" <>
      If[k > 0, "\:3002<<FIG1>>\:301c<<FIG" <> ToString[k] <>
        ">> \:306f\:65e2\:5b58\:306e\:56f3\:30fb\:30b3\:30fc\:30c9\:30bb\:30eb", ""] <> "):\n" <> md <> "\n\n", ""] <>
  "\:624b\:9806(\:53b3\:5b88):\n" <>
  "1. \:6307\:793a\:306b\:5f93\:3063\:3066\:65b0\:3057\:3044\:30b7\:30ca\:30ea\:30aa md \:3092\:69cb\:6210\:3059\:308b(\:66f8\:5f0f\:306f SlideWorkflow api.md \:306e\:901a\:308a: \"## \:30bf\:30a4\:30c8\:30eb {expected=\:79d2}\" / \"- \" \:7b87\:6761\:66f8\:304d(\:30a4\:30f3\:30c7\:30f3\:30c82/4\:3067\:4e0b\:4f4d) / \"> \" \:8aac\:660e\:6bb5\:843d / \:5730\:306e\:6587 / \"cite: \:51fa\:5178\" / \"<<FIGn>>\" / \:8868 = \"| a | b |\" \:884c\:306e\:9023\:7d9a\:3067 2 \:884c\:76ee\:306b \"| --- | --- |\" \:3092\:7f6e\:304f\:3068 1 \:884c\:76ee\:304c\:30d8\:30c3\:30c0 / \"talk: \:767a\:8868\:539f\:7a3f\" \:884c = \:5404 ## \:306e\:6700\:5f8c\:306b 1 \:56de)\:3002\:901a\:5e38\:306f 1 \:679a\:3002\:6307\:793a\:3067\:6c42\:3081\:3089\:308c\:305f\:5834\:5408\:306e\:307f\:8907\:6570\:306e ## \:306b\:5206\:5272\:3059\:308b\:3002\n" <>
  "1b. \:30b9\:30bf\:30a4\:30eb(\:8a08\:7b97\:3068\:81ea\:7136\:30b7\:30ea\:30fc\:30ba\:6e96\:62e0): 1 \:679a 1 \:30e1\:30c3\:30bb\:30fc\:30b8\:3002\:30bf\:30a4\:30c8\:30eb\:306f\:77ed\:3044\:540d\:8a5e\:53e5(\:9023\:7d9a\:30b9\:30e9\:30a4\:30c9\:306f\:540c\:540d\:53ef)\:3002\:7b87\:6761\:66f8\:304d\:306f\:4f53\:8a00\:6b62\:3081\:4e2d\:5fc3 3\:301c6 \:884c\:30fb\:968e\:5c64 2 \:6bb5\:307e\:3067\:3002\:56f3\:30fb\:8868\:304c\:4e3b\:5f79\:3001\:6587\:5b57\:306f\:88dc\:8db3\:3002\n" <>
  "2. \:8ad6\:6587\:30fbweb\:30fbPDF \:7531\:6765\:306e\:56f3\:30fb\:5f15\:7528\:30fb\:30c7\:30fc\:30bf\:306b\:306f\:76f4\:5f8c\:306b cite: \:884c\:3067\:51fa\:5178(URL \:307e\:305f\:306f (\:8457\:8005, \:5e74))\:3092\:5fc5\:305a\:660e\:8a18\:3059\:308b\:3002\:5185\:5bb9\:306e\:78ba\:8a8d\:304c\:5fc5\:8981\:306a\:3089\:691c\:7d22(SourceVault / pdfSearch / web)\:3092\:4f7f\:3063\:3066\:3088\:3044\:3002\n" <>
  If[StringContainsQ[metaBlocks, "=== References"],
    "2b. \:6587\:732e\:30ea\:30b9\:30c8(References)\:306e [key] \:304c\:6307\:793a\:306b\:73fe\:308c\:305f\:3089\:3001\:4e0a\:306e\:53c2\:7167\:65b9\:6cd5\:3067\:8cc7\:6599\:3092\:53d6\:5f97\:3057\:3066\:5185\:5bb9\:3092\:78ba\:8a8d\:3057\:3001\:305d\:306e\:5185\:5bb9\:306b\:57fa\:3065\:3044\:3066\:8a18\:8ff0\:3059\:308b\:3002\:7531\:6765\:3059\:308b\:56f3\:30fb\:5f15\:7528\:30fb\:30c7\:30fc\:30bf\:306b\:306f cite: \:884c\:3067\:51fa\:5178\:3092\:660e\:8a18\:3059\:308b\:3002\n", ""] <>
  If[k > 0, "3. \:65e2\:5b58\:56f3 <<FIG1>>\:301c<<FIG" <> ToString[k] <> ">> \:306f\:524a\:9664\:306e\:6307\:793a\:304c\:306a\:3044\:9650\:308a\:9069\:5207\:306a\:4f4d\:7f6e\:306b\:6b8b\:3059\:3002\n", ""] <>
  If[TrueQ[$SlideVisualsPerSlide],
    "3b. \:539f\:5247\:3068\:3057\:3066\:3059\:3079\:3066\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:56f3\:304b\:8868\:3092 1 \:3064\:4ee5\:4e0a\:5165\:308c\:308b\:3002\:6bd4\:8f03\:30fb\:4ed5\:69d8\:30fb\:6570\:5024\:306e\:7f85\:5217\:306f | \:69cb\:6587\:306e\:8868\:306b\:3059\:308b\:3002\:56f3\:306e\:5165\:624b\:512a\:5148\:9806\:4f4d: (1) \:65e2\:5b58 <<FIGn>> \:306e\:518d\:914d\:7f6e (2) \:539f\:8cc7\:6599\:304b\:3089\:306e\:5f15\:7528 \:2014 \:8ad6\:6587\:30fb\:65e2\:5b58\:30b9\:30e9\:30a4\:30c9\:30fbweb \:306e\:56f3\:8868\:30fb\:5199\:771f\:30fb\:5b9f\:9a13\:30b0\:30e9\:30d5\:306f\:4f5c\:308a\:76f4\:3055\:305a\:539f\:56f3\:3092\:305d\:306e\:307e\:307e\:5207\:308a\:51fa\:3057\:3066\:4f7f\:3046(\:5f15\:7528\:304c\:6b63\:78ba\:6027\:3092\:4fdd\:3064): SlidePDFFigure[\"<key|\:30d1\:30b9|URL>\", \:30da\:30fc\:30b8, \"Crop\"->{{x1,x2},{y1,y2}} \:5de6\:4e0a\:539f\:70b9\:6bd4\:7387] (URL\:30fbarxiv:ID\:30fbGoogle Slides \:30d7\:30ec\:30bc\:30f3 URL \:306f\:81ea\:52d5\:3067 PDF \:5316\:3055\:308c\:308b) / SlidePDFImages[\"<key>\"] = PDF \:57cb\:3081\:8fbc\:307f\:306e\:5199\:771f\:30fb\:30e9\:30b9\:30bf\:56f3\:306e\:4e00\:89a7 / SlideDeckFigure[\"<\:904e\:53bb\:30c7\:30c3\:30ad.nb>\", n] = \:904e\:53bb\:30b9\:30e9\:30a4\:30c9 1 \:679a\:306e\:753b\:50cf\:5f15\:7528\:3002\:30da\:30fc\:30b8\:756a\:53f7\:3068\:9818\:57df\:306f ClaudeAttach[SlideSourceFile[\"<key|URL>\"]] (URL \:7cfb\:306f PDF \:5316\:6e08\:307f\:306e\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:304c\:8fd4\:308b) \:3067\:8cc7\:6599\:3092\:6dfb\:4ed8\:30fb\:95b2\:89a7\:3057\:3066\:78ba\:304b\:3081\:3001\:5207\:308a\:51fa\:3057\:7d50\:679c\:306f ImageDimensions \:7b49\:3067\:691c\:8a3c\:3059\:308b\:3002\:5207\:308a\:51fa\:3057\:305f\:56f3\:306f \"Figures\" \:3067\:6e21\:3057 md \:3067\:306f <<FIGn>>\:3001\:76f4\:5f8c\:306b\:5fc5\:305a cite: (3) \:539f\:8cc7\:6599\:306b\:5b58\:5728\:3057\:306a\:3044\:6982\:5ff5\:56f3\:30fb\:307e\:3068\:3081\:56f3\:306e\:307f\:65b0\:898f\:4f5c\:56f3\:3002\n", ""] <>
  If[TrueQ[$SlideTalkPerSlide],
    "3c. \:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:306b talk: \:884c\:3067\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f\:3092\:66f8\:304f(\:3067\:3059\:30fb\:307e\:3059\:8abf\:30012\:301c6 \:6587\:30011 \:679a 25 \:79d2\:524d\:5f8c\:3002\:5192\:982d\:306b\:524d\:306e\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:306e\:63a5\:7d9a\:3092\:4e00\:8a00\:3001\:6bce\:56de\:9055\:3046\:8a00\:3044\:56de\:3057\:3067)\:3002\:30b9\:30e9\:30a4\:30c9\:672c\:6587\:306f\:56f3\:8868+\:4f53\:8a00\:6b62\:3081\:306e\:77ed\:3044\:7b87\:6761\:66f8\:304d\:306b\:3068\:3069\:3081\:3001\:8aac\:660e\:306e\:6587\:7ae0\:306f talk \:5074\:304c\:62c5\:3046 \:2014 \:30b9\:30e9\:30a4\:30c9\:3068 talk \:3092\:5408\:308f\:305b\:3066\:89e3\:8aac\:304c\:5b8c\:6210\:3059\:308b\:3088\:3046\:306b\:66f8\:304d\:3001\:540c\:3058\:6587\:3092\:4e21\:65b9\:306b\:5165\:308c\:306a\:3044\:3002\:7b87\:6761\:66f8\:304d\:8a18\:53f7\:30fbURL\:30fb\:8a18\:53f7\:5217\:306e\:8aad\:307f\:4e0a\:3052\:3092 talk \:306b\:5165\:308c\:306a\:3044\:3002\:30b9\:30e9\:30a4\:30c9\:306b\:7121\:3044\:4e8b\:5b9f\:30fb\:6570\:5024\:3092 talk \:3067\:4f5c\:3089\:306a\:3044\:3002\n", ""] <>
  "4. \:539f\:8cc7\:6599\:306b\:7121\:3044\:6982\:5ff5\:56f3\:30fb\:30d5\:30ed\:30fc\:56f3\:306e\:307f Wolfram \:8a00\:8a9e\:306e Graphics \:3067\:65b0\:898f\:4f5c\:56f3\:3059\:308b\:3002\:539f\:8cc7\:6599\:306b\:5b58\:5728\:3059\:308b\:56f3\:8868\:30fb\:5199\:771f\:30fb\:5b9f\:9a13\:30b0\:30e9\:30d5\:3092 Graphics \:3067\:4f5c\:308a\:76f4\:3057\:3066\:306f\:306a\:3089\:306a\:3044(3b \:306e\:5f15\:7528\:3092\:4f7f\:3046)\:3002\:4f5c\:56f3\:6642\:306e\:898f\:7d04(\:914d\:8272\:306f SlideThemeColor[\"Title\"|\"Bullet\"|\"SubBullet\"|\"Dim\"|\"Arrow\"|\"PanelBackground\"|\"PanelBorder\"]\:3001\:30d5\:30a9\:30f3\:30c8\:306f FontFamily->$SlideFontFamily\:3001\:88dc\:52a9\:5b9a\:7fa9\:306f\:5fc5\:305a Module \:5185)\:3002\:56f3\:306e\:751f\:6210\:306b\:8ab2\:91d1 API(LLMSynthesize / ImageSynthesize \:7b49)\:3092\:4f7f\:308f\:306a\:3044\:3053\:3068\:3002\:65b0\:898f\:56f3\:306f md \:4e2d\:3067 <<FIG" <> ToString[k + 1] <> ">> \:4ee5\:964d\:306e\:30c8\:30fc\:30af\:30f3\:3068\:3057\:3066\:53c2\:7167\:3059\:308b\:3002\n" <>
  "5. \:6700\:5f8c\:306b SlideApplyScenario[" <> ToString[slideNo] <> ", md] \:3092\:4e00\:5ea6\:3060\:3051\:8a55\:4fa1\:3057\:3066\:9069\:7528\:3059\:308b(\:65b0\:898f\:56f3\:304c\:3042\:308c\:3070 SlideApplyScenario[" <> ToString[slideNo] <> ", md, \"Figures\"->{g1, ...}] \:306e\:5f62\:3067\:3001md \:306e <<FIG" <> ToString[k + 1] <> ">> \:4ee5\:964d\:3068\:540c\:9806\:306b\:6e21\:3059)\:3002\:3053\:308c\:304c\:30b9\:30e9\:30a4\:30c9\:3078\:306e\:552f\:4e00\:306e\:66f8\:8fbc\:307f\:624b\:6bb5\:3067\:3042\:308a\:3001NotebookWrite \:7b49\:3067\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:63a5\:7de8\:96c6\:3057\:3066\:306f\:306a\:3089\:306a\:3044\:3002\n" <>
  "6. \:623b\:308a\:5024\:304c Failure \:306a\:3089 md \:3092\:4fee\:6b63\:3057\:3066 SlideApplyScenario \:3092\:518d\:8a55\:4fa1\:3059\:308b\:3002Success[\"SlideApplied\", ...] \:304c\:8fd4\:308c\:3070\:5b8c\:4e86\:3002" <>
  If[metaBlocks =!= "", "\n7. Directives / Dictionary / References \:3092\:53b3\:5b88\:3059\:308b\:3002", ""];

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
  Quiet[SlideEnsureDeckStyles[nb]];
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
    ctx["Md"], Length[ctx["Keeps"]],
    iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb] <> iSWReferencesBlock[nb]];
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, iSWAgentEvalCell[task], All];
  SelectionEvaluate[nb];
  iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo] <> " \:306e\:5c55\:958b\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72 (\:8ffd\:8de1\:306f\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d)",
    "Delegated slide " <> ToString[slideNo] <> " expansion to agent (see cells after end marker)"]];
];

(* Direct \:7d4c\:8def: \:8efd\:91cf\:306a\:76f4\:63a5 LLM (\:65e7\:65b9\:5f0f)\:3002\:30c4\:30fc\:30eb\:7121\:3057\:30fb\:30c6\:30ad\:30b9\:30c8\:751f\:6210\:306e\:307f *)
iSWExpandDirect[nb_, slideNo_, ctx_] := Module[{meta, prompt},
  If[!iSWRequireLLM[], Return[$Failed]];
  meta = iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb] <> iSWReferencesBlock[nb];
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

$iSWReferencesCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.3, 0.55, 0.5],
  Background -> RGBColor[0.92, 0.97, 0.95], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.3, 0.55, 0.5]]};

(* \:30c8\:30fc\:30af\:30bb\:30eb: \:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f\:3002\:9752\:7d2b\:7cfb *)
$iSWTalkCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.45, 0.42, 0.7],
  Background -> RGBColor[0.945, 0.94, 0.985], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.45, 0.42, 0.7]]};

(* ---- \:30c7\:30c3\:30ad\:57cb\:3081\:8fbc\:307f\:30b9\:30bf\:30a4\:30eb\:5b9a\:7fa9 (2026-08-25) ----
   \:30e1\:30bf\:30bb\:30eb(SlidePrompt/Note/Directive/Dictionary/Bibliography/References)\:3092
   Working \:3067\:306f\:5f93\:6765\:306e\:898b\:305f\:76ee\:306e\:307e\:307e\:3001SlideShow \:74b0\:5883\:3067\:306f\:975e\:8868\:793a\:306b\:3059\:308b\:3002
   \:30bb\:30eb\:5074\:306f\:7d20\:306e Cell[text, style] \:306b\:3057\:3001\:898b\:305f\:76ee\:30fb\:53ef\:8996\:6027\:306f stylesheet \:5074\:304c\:6301\:3064\:3002 *)
$iSWDeckStyleVersion = 2;  (* v2: +SlideTalk *)
$iSWOwnedStyleNames = {"SWDeckStyles", "SlidePrompt", "Note", "Directive",
  "Dictionary", "Bibliography", "References", "SlideTalk"};

$iSWHiddenInSlideShowOpts = {
  CellOpen -> False, ShowCellBracket -> False,
  CellMargins -> {{0, 0}, {0, 0}}, CellFrame -> {{0, 0}, {0, 0}},
  CellFrameMargins -> 0, CellDingbat -> None,
  CellElementSpacings -> {"CellMinHeight" -> 1, "ClosedCellHeight" -> 1}};

iSWDeckStyleCells[] := Join[
  {Cell[StyleData["SWDeckStyles"],
    TaggingRules -> {"SWDeckStyleVersion" -> $iSWDeckStyleVersion}]},
  Flatten[Map[
    {Cell[StyleData[#[[1]]], Sequence @@ #[[2]]],
     Cell[StyleData[#[[1]], "SlideShow"], Sequence @@ $iSWHiddenInSlideShowOpts]} &,
    {{"SlidePrompt", $iSWPromptCellOpts}, {"Note", $iSWNoteCellOpts},
     {"Directive", $iSWDirectiveCellOpts}, {"Dictionary", $iSWDictionaryCellOpts},
     {"Bibliography", $iSWBibliographyCellOpts},
     {"References", $iSWReferencesCellOpts},
     {"SlideTalk", $iSWTalkCellOpts}}], 1]];

iSWStyleDefsVersion[sd_Notebook] := FirstCase[First[sd],
  Cell[StyleData["SWDeckStyles"], ___,
    TaggingRules -> {___, "SWDeckStyleVersion" -> v_, ___}, ___] :> v, 0, {1}];
iSWStyleDefsVersion[_] := 0;

iSWOwnedStyleCellQ[Cell[StyleData[n_String, ___], ___]] :=
  MemberQ[$iSWOwnedStyleNames, n];
iSWOwnedStyleCellQ[_] := False;

(* \:65e2\:5b58 stylesheet (\:6587\:5b57\:5217\:540d / FrontEnd`FileName / Notebook) \:3092\:5305\:3093\:3067\:81ea\:524d\:30b9\:30bf\:30a4\:30eb\:3092\:8db3\:3059\:3002
   \:81ea\:524d\:5206\:306f\:5165\:308c\:66ff\:3048\:308b\:306e\:3067\:51aa\:7b49 *)
iSWWrapStyleDefinitions[sd_Notebook] :=
  Notebook[Join[Select[First[sd], !iSWOwnedStyleCellQ[#] &], iSWDeckStyleCells[]],
    Sequence @@ Rest[List @@ sd]];
iSWWrapStyleDefinitions[sd_] :=
  Notebook[Join[{Cell[StyleData[StyleDefinitions -> sd]]}, iSWDeckStyleCells[]],
    Visible -> False, StyleDefinitions -> "PrivateStylesheetFormatting.nb"];

SlideEnsureDeckStyles[nb_NotebookObject] := Module[{sd},
  sd = Quiet[FirstCase[Options[nb, StyleDefinitions],
    HoldPattern[StyleDefinitions -> s_] :> s, None]];
  If[!MatchQ[sd, _Notebook | _String | _FrontEnd`FileName],
    sd = Quiet[CurrentValue[nb, StyleDefinitions]]];
  If[!MatchQ[sd, _Notebook | _String | _FrontEnd`FileName],
    sd = $SlideStyleDefinitions];
  If[Head[sd] === Notebook && iSWStyleDefsVersion[sd] >= $iSWDeckStyleVersion,
    "AlreadyPresent",
    SetOptions[nb, StyleDefinitions -> iSWWrapStyleDefinitions[sd]];
    "StylesApplied"]];

(* ---- \:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883 (Working \:21c4 SlideShow) ---- *)
$iSWEnvLabel = "View: Working";
$iSWEnvColor = RGBColor[0.3, 0.5, 0.4];

iSWSetEnvLabel[env_] := If[env === "SlideShow",
  $iSWEnvLabel = iSL["\:8868\:793a: Slideshow", "View: Slideshow"];
  $iSWEnvColor = RGBColor[0.878, 0.486, 0.078],
  $iSWEnvLabel = iSL["\:8868\:793a: Working", "View: Working"];
  $iSWEnvColor = RGBColor[0.3, 0.5, 0.4]];

iSWRefreshEnvLabel[] := Module[{nb = Quiet[InputNotebook[]]},
  iSWSetEnvLabel[If[Head[nb] === NotebookObject,
    Quiet[CurrentValue[nb, ScreenStyleEnvironment]], "Working"]]];

(* SlideShow \:4e2d\:306f\:6a19\:6e96\:30c4\:30fc\:30eb\:30d0\:30fc\:3092\:9000\:907f\:3059\:308b\:3002\:5b9f\:6e2c (2026-08-26): \:30ea\:30dc\:30f3\:306e\:6b63\:4f53\:306f
   WindowToolbars -> {"MultipurposeBar"} \:3067\:3001SlideShow \:306e\:30b9\:30e9\:30a4\:30c9\:30ca\:30d3\:30d0\:30fc\:3068
   \:4e0a\:7aef\:3092\:53d6\:308a\:5408\:3046\:3002\:9000\:907f\:6642\:306f\:5143\:5024\:3092 TaggingRules \:306b\:4fdd\:5b58\:3057\:3001Working \:5fa9\:5e30\:3067\:5fa9\:5143 *)
If[!ValueQ[$SlideHideToolbarInSlideshow], $SlideHideToolbarInSlideshow = True];

iSWApplyToolbarPolicy[nb_, env_] := If[TrueQ[$SlideHideToolbarInSlideshow],
  If[env === "SlideShow",
    Module[{tb = Quiet[Check[AbsoluteCurrentValue[nb, WindowToolbars], Inherited]], dc},
      CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}] = ToString[tb, InputForm];
      SetOptions[nb, WindowToolbars -> {}];
      (* \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5074 DockedCells (CloudPublishable \:306e Public/Private \:30d0\:30c3\:30b8\:7b49\:3002
         .nb \:306b\:6c38\:7d9a\:5316\:3055\:308c\:3066\:3044\:308b) \:306f stylesheet \:306e SlideShow \:74b0\:5883\:5b9a\:7fa9 =
         \:30b9\:30e9\:30a4\:30c9\:30ca\:30d3\:30d0\:30fc\:3092\:5168\:74b0\:5883\:3067\:4e0a\:66f8\:304d\:3057\:3066\:3057\:307e\:3046\:3002\:9000\:907f\:3057\:3066 Inherited \:306b\:623b\:3059\:3068
         \:30ca\:30d3\:30d0\:30fc\:304c\:73fe\:308c\:308b\:3002Working \:5fa9\:5e30\:3067\:5fa9\:5143 *)
      dc = FirstCase[Options[nb, DockedCells],
        HoldPattern[DockedCells -> v_] :> v, Inherited];
      If[dc =!= Inherited && dc =!= {},
        CurrentValue[nb, {TaggingRules, "SWSavedDockedCells"}] =
          ToString[dc, InputForm];
        SetOptions[nb, DockedCells -> Inherited]]],
    Module[{s = Quiet[CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}]], d},
      SetOptions[nb, WindowToolbars ->
        If[StringQ[s], Quiet[Check[ToExpression[s], Inherited]], Inherited]];
      Quiet[CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}] = Inherited];
      d = Quiet[CurrentValue[nb, {TaggingRules, "SWSavedDockedCells"}]];
      If[StringQ[d],
        Quiet[Check[SetOptions[nb, DockedCells -> ToExpression[d]], Null]];
        Quiet[CurrentValue[nb, {TaggingRules, "SWSavedDockedCells"}] = Inherited]]]]];

SlideToggleScreenEnvironment[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideToggleScreenEnvironment[nb]]];

SlideToggleScreenEnvironment[nb_NotebookObject] := Module[{cur, new},
  Quiet[SlideEnsureDeckStyles[nb]];
  cur = Quiet[CurrentValue[nb, ScreenStyleEnvironment]];
  new = If[cur === "SlideShow", "Working", "SlideShow"];
  SetOptions[nb, ScreenStyleEnvironment -> new];
  iSWApplyToolbarPolicy[nb, new];
  iSWSetEnvLabel[new];
  iSWStatus[nb, iSL["\:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883: ", "Screen environment: "] <> new];
  iSWStatusClearLater[nb];
  new];

(* ---- \:6587\:732e\:30ea\:30b9\:30c8 (References) ----
   1 \:884c 1 \:6587\:732e "[key] locator | \:30e1\:30e2"\:3002# \:3067\:59cb\:307e\:308b\:884c\:306f\:30b3\:30e1\:30f3\:30c8\:3002
   locator: URL / arxiv:ID / sv://URI / src-ID / eagle:ID / .pdf / .nb \:306a\:3069 *)
iSWParseReferenceLine[l_String] := Module[
  {t = StringTrim[l], key = None, rest, parts, loc, note},
  If[t === "" || StringStartsQ[t, "#"] || StringStartsQ[t, "(*"], Return[None]];
  If[StringMatchQ[t, "[" ~~ Except["]"] .. ~~ "]" ~~ ___],
    key = First[StringCases[t,
      StartOfString ~~ "[" ~~ k : Except["]"] .. ~~ "]" :> StringTrim[k], 1]];
    rest = StringTrim[StringReplace[t,
      StartOfString ~~ "[" ~~ Except["]"] .. ~~ "]" -> "", 1]],
    rest = t];
  If[StringTrim[rest] === "", Return[None]];
  parts = StringSplit[rest, "|", 2];
  loc = StringTrim[parts[[1]]];
  note = If[Length[parts] > 1, StringTrim[parts[[2]]], ""];
  If[loc === "", None, <|"Key" -> key, "Locator" -> loc, "Note" -> note|>]];

iSWRefKind[loc_String] := Which[
  StringStartsQ[loc, "eagle:", IgnoreCase -> True], "Eagle",
  StringStartsQ[loc, "sv://"] || StringStartsQ[loc, "src-"], "SourceVault",
  StringStartsQ[loc, "arxiv:", IgnoreCase -> True] ||
    StringContainsQ[loc, "arxiv.org"], "arXiv",
  StringStartsQ[loc, "http://"] || StringStartsQ[loc, "https://"], "Web",
  StringEndsQ[loc, ".nb", IgnoreCase -> True], "Notebook",
  StringEndsQ[loc, ".pdf", IgnoreCase -> True], "PDF",
  True, "File"];

iSWParseReferences[text_String] := Module[{items, n = 0},
  items = DeleteCases[iSWParseReferenceLine /@
    StringSplit[StringReplace[text, "\r\n" -> "\n"], "\n"], None];
  Map[Function[r, n++;
    Join[r, <|"Key" -> If[StringQ[r["Key"]] && r["Key"] =!= "", r["Key"],
        "ref" <> ToString[n]],
      "Kind" -> iSWRefKind[r["Locator"]]|>]], items]];

iSWReferencesList[nb_] :=
  iSWParseReferences[StringRiffle[iSWCollectByStyle[nb, "References"], "\n"]];

iSWReferenceGuide[] :=
  "\:53c2\:7167\:65b9\:6cd5: eagle:<id> \:306f SourceVaultEagleItemPath[SourceVaultEagleItem[\"<id>\"]] \:3067\:539f\:672c\:30d1\:30b9\:3092\:53d6\:5f97\:3057\:3001PDF \:306f ClaudeAttach[\:30d1\:30b9] \:3067\:6dfb\:4ed8\:3057\:3066\:8aad\:3080\:3002sv://.. / src-.. \:306f SourceVaultResolveReference (\:307e\:305f\:306f ClaudeAttach[\"sv://..\"])\:3002arxiv:<id> \:306f https://arxiv.org/abs/<id>\:3002URL \:306f ClaudeAttach[url] \:304b web \:691c\:7d22/\:53d6\:5f97\:3002.nb (\:904e\:53bb\:30b9\:30e9\:30a4\:30c9\:306a\:3069) \:306f SlideDeckOverview / SlideDeckSlides \:3067\:69cb\:6210\:30fb\:4f53\:88c1\:3092\:53c2\:7167\:3059\:308b\:3002\:56f3\:8868\:30fb\:5199\:771f\:306e\:5f15\:7528\:5207\:308a\:51fa\:3057\:306f SlidePDFFigure(\:30da\:30fc\:30b8/\:9818\:57df) / SlidePDFImages(\:57cb\:3081\:8fbc\:307f\:753b\:50cf) / SlideDeckFigure(\:904e\:53bb\:30b9\:30e9\:30a4\:30c9 1 \:679a) \:2014 locator \:3092\:305d\:306e\:307e\:307e\:6e21\:305b\:308b\:3002SlideSourceFile[locator] \:306f\:89e3\:6c7a\:6e08\:307f\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9(ClaudeAttach \:3067\:306e\:95b2\:89a7\:7528)\:3002";

iSWReferencesBlockFromList[refs_List] := If[refs === {}, "",
  "=== References (\:6587\:732e\:30ea\:30b9\:30c8: \:6307\:793a\:4e2d\:306e [key] \:306f\:3053\:308c\:3092\:6307\:3059) ===\n" <>
  StringRiffle[Map[Function[r,
    "[" <> r["Key"] <> "] (" <> r["Kind"] <> ") " <> r["Locator"] <>
      If[r["Note"] =!= "", " -- " <> r["Note"], ""]], refs], "\n"] <>
  "\n" <> iSWReferenceGuide[] <>
  "\n=== End References ===\n\n"];

iSWReferencesBlock[nb_] := iSWReferencesBlockFromList[iSWReferencesList[nb]];

SlideInsertReferences[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideInsertReferences[nb]]];
SlideInsertReferences[nb_NotebookObject] := iSWInsertMeta[nb, "", "References",
  iSL["# 1\:884c1\:6587\:732e: [key] locator | \:30e1\:30e2  (locator: URL / arxiv:ID / sv://URI / eagle:ID / .pdf / .nb)\n[key1] https://example.org/page | \:3053\:306e\:884c\:3092\:5b9f\:969b\:306e\:6587\:732e\:306b\:7f6e\:304d\:63db\:3048\:308b",
    "# one reference per line: [key] locator | note  (URL / arxiv:ID / sv://URI / eagle:ID / .pdf / .nb)\n[key1] https://example.org/page | replace with real references"],
  $iSWReferencesCellOpts];

(* 2026-08-25: \:30b9\:30bf\:30a4\:30eb\:5b9a\:7fa9\:3092\:30c7\:30c3\:30ad\:3078\:6ce8\:5165\:3057\:3066\:7d20\:306e styled \:30bb\:30eb\:3092\:66f8\:304f\:3002documentation.wl \:306e
   DocInsert* \:306f\:300c\:30b9\:30bf\:30a4\:30eb\:5b9a\:7fa9\:304c\:3042\:308c\:3070\:7d20\:306e\:30bb\:30eb\:3092\:66f8\:304f\:300d\:5b9f\:88c5\:306a\:306e\:3067\:3001doc \:30d1\:30ec\:30c3\:30c8\:306e
   \:300c\:30e1\:30e2\:300d\:300c\:6307\:793a\:300d\:3082\:540c\:3058\:610f\:5473(Working \:53ef\:8996 / SlideShow \:975e\:8868\:793a)\:306b\:306a\:308b *)
iSWInsertMeta[nb_, docFn_String, style_String, text_String, opts_List] := (
  Quiet[SlideEnsureDeckStyles[nb]];
  NotebookWrite[nb, Cell[text, style]]);

SlideInsertNote[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertNote[nb]]];
SlideInsertNote[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertNote", "Note",
  iSL["\:3053\:3053\:3078\:306f\:30e1\:30e2\:306a\:3069\:3092\:66f8\:304f...", "Write notes here..."], $iSWNoteCellOpts];

SlideInsertDirective[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertDirective[nb]]];
SlideInsertDirective[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertDirective", "Directive",
  iSL["\:3053\:3053\:306b LLM \:3078\:306e\:6307\:793a\:3092\:8a18\:8f09...", "Write LLM directives here..."], $iSWDirectiveCellOpts];

SlideInsertTalk[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertTalk[nb]]];
SlideInsertTalk[nb_NotebookObject] := iSWInsertMeta[nb, "", "SlideTalk",
  iSL["\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f(\:30c8\:30fc\:30af)\:3092\:66f8\:304f\:3002\:30b9\:30e9\:30a4\:30c9\:306f\:56f3\:8868+\:30ad\:30fc\:30ef\:30fc\:30c9\:3001\:8aac\:660e\:306f\:30c8\:30fc\:30af\:3067\:3002",
    "Write the talk for this slide here; keep the slide itself visual and terse."],
  $iSWTalkCellOpts];

SlideInsertDictionary[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertDictionary[nb]]];
SlideInsertDictionary[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertDictionary", "Dictionary",
  "{{<<Japanese>>, <<English>>, <<Context>>}, {\"\:7528\:8a9e1\", \"term1\", \"\:6587\:8108\"}}",
  $iSWDictionaryCellOpts];

SlideInsertBibliography[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertBibliography[nb]]];
SlideInsertBibliography[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertBibliography", "Bibliography",
  "{{<<Key>>, <<Author>>, <<Year>>, <<Title>>}, {\"key\", \"author\", \"year\", \"title\"}}",
  $iSWBibliographyCellOpts];

SlideInsertPrompt[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertPrompt[nb]]];
SlideInsertPrompt[nb_NotebookObject] := (Quiet[SlideEnsureDeckStyles[nb]];
  NotebookWrite[nb, iSWPromptCell[
    iSL["\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:4f1d\:3048\:305f\:3044\:5185\:5bb9(\:30d7\:30ed\:30f3\:30d7\:30c8)\:3092\:66f8\:304d\:3001\:300c\:5c55\:958b\:300d\:3092\:62bc\:3059\:3002",
      "Write the prompt for this slide here and press Expand."]]]);

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
  Quiet[SlideEnsureDeckStyles[nb]];
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
  (* \:8868\:793a\:306b\:623b\:3059\:3068\:304d\:306f Inherited: \:660e\:793a True \:3092\:523b\:3080\:3068 SlideShow \:74b0\:5883\:306e stylesheet \:975e\:8868\:793a\:304c\:52b9\:304b\:306a\:304f\:306a\:308b *)
  Do[Quiet[SetOptions[cells[[i]],
    CellOpen -> If[$iSWPromptsOpen, Inherited, False]]], {i, idxs}];
  iSWStatus[nb, iSL["\:30d7\:30ed\:30f3\:30d7\:30c8: " <> If[$iSWPromptsOpen, "\:8868\:793a", "\:975e\:8868\:793a"],
    "Prompts: " <> If[$iSWPromptsOpen, "shown", "hidden"]]];
  iSWStatusClearLater[nb];
];

(* ===================== \:66f8\:304d\:51fa\:3057\:30a2\:30af\:30b7\:30e7\:30f3 ===================== *)

iSWDeckBaseName[nb_] := Module[{fn = Quiet[NotebookFileName[nb]]},
  If[StringQ[fn], {DirectoryName[fn], FileBaseName[fn]},
    {$TemporaryDirectory, "slides_export"}]];

(* ---- \:66f8\:304d\:51fa\:3057\:30bd\:30fc\:30b9\:306e\:89e3\:6c7a (2026-07-20) ----
   \:30d1\:30ec\:30c3\:30c8\:306f\:5f93\:6765 NotebookGet[nb] \:3067\:30bb\:30eb\:5f0f\:3092\:53d6\:5f97\:3057\:3066\:3044\:305f\:304c\:3001\:3053\:308c\:306f
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5168\:4f53\:3092 FE \[RightArrow] \:30ab\:30fc\:30cd\:30eb\:3078 MathLink \:8ee2\:9001\:3059\:308b\:300299MB \:306e\:30c7\:30c3\:30ad\:3067\:306f
   \:3053\:306e\:8ee2\:9001\:3060\:3051\:3067 FE \:304c\:9577\:6642\:9593\:5fdc\:7b54\:4e0d\:80fd\:306b\:306a\:308b\:3002\:4fdd\:5b58\:6e08\:307f\:306a\:3089\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9\:3092
   \:8fd4\:3057\:3001\:30ab\:30fc\:30cd\:30eb\:5074\:306e Get \:3067\:8aad\:307e\:305b\:308b (FE \:3092\:4ecb\:3055\:306a\:3044)\:3002 *)
iSWDeckSource[nb_NotebookObject] := Module[{fn = Quiet[NotebookFileName[nb]], modified},
  modified = TrueQ[Quiet[CurrentValue[nb, "DocumentModified"]]];
  If[StringQ[fn] && FileExistsQ[fn] && !modified, fn, NotebookGet[nb]]];

iSWUnsavedQ[nb_NotebookObject] := Module[{fn = Quiet[NotebookFileName[nb]]},
  !StringQ[fn] || !FileExistsQ[fn] || TrueQ[Quiet[CurrentValue[nb, "DocumentModified"]]]];

(* ---- \:5916\:90e8\:30d7\:30ed\:30bb\:30b9\:66f8\:304d\:51fa\:3057 ----
   Rasterize \:306f\:5229\:7528\:8005\:306e FE \:3092\:9577\:6642\:9593\:5360\:6709\:3059\:308b (\:5b9f\:6e2c: 13 \:679a\:306e\:30c7\:30c3\:30ad\:3067 30s+\:3002
   \:3055\:3089\:306b Typeset`ToBoxes \:7cfb\:306e\:30b5\:30de\:30ea\:30fc\:30dc\:30c3\:30af\:30b9\:306f\:63cf\:753b\:306b\:30ab\:30fc\:30cd\:30eb\:8a55\:4fa1\:3092\:8981\:6c42\:3059\:308b\:305f\:3081
   \:5f85\:3061\:5408\:3044\:306b\:306a\:308a\:3046\:308b)\:3002wolframscript \:306e\:5225\:30d7\:30ed\:30bb\:30b9\:3067\:5b8c\:7d50\:3055\:305b\:3001FE \:3092\:5b88\:308b\:3002 *)
(* \:5916\:90e8\:30d7\:30ed\:30bb\:30b9\:306e\:53ef\:5426\:3002Automatic = 1 \:5ea6\:8a66\:3057\:3066\:5931\:6557\:3057\:305f\:3089\:4ee5\:5f8c\:8a66\:3055\:306a\:3044\:3002
   \:3053\:306e\:74b0\:5883\:306f\:72ec\:7acb\:30d7\:30ed\:30bb\:30b9\:306e\:30e9\:30a4\:30bb\:30f3\:30b9\:5e2d\:304c 4 \:3057\:304b\:7121\:304f\:3001FE + \:30ab\:30fc\:30cd\:30eb\:304c\:57cb\:307e\:3063\:3066\:3044\:308b\:3068
   \:5b50\:30d7\:30ed\:30bb\:30b9(\:30ab\:30fc\:30cd\:30eb + \:305d\:306e FE)\:304c\:8d77\:3053\:305b\:305a
   "product is not activated or is experiencing a license-related problem" \:3067\:5373\:6b7b\:3059\:308b\:3002
   \:305d\:306e\:5834\:5408\:306f FE \:5185\:51e6\:7406\:306b\:9ed9\:3063\:3066\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3059\:308b\:3002 *)
If[!ValueQ[$SlideExportExternal], $SlideExportExternal = Automatic];
$iSWExternalBroken = False;

iSWWolframScriptPath[] := Module[{p},
  p = Quiet[Check[First[FileNames["wolframscript.exe", FileNameJoin[{$InstallationDirectory}]], None], None]];
  If[StringQ[p], p, "wolframscript"]];

iSWExternalExport[deckFile_String, kind_String, outSpec_String, optsCode_String] := Module[
  {script, tmp, res, out},
  tmp = FileNameJoin[{$TemporaryDirectory,
    "slidewf_export_" <> IntegerString[RandomInteger[{10^8, 10^9}]] <> ".wls"}];
  script = StringJoin[
    "Global`$packageDirectory = " <> ToString[Global`$packageDirectory, InputForm] <> ";\n",
    "Get[FileNameJoin[{Global`$packageDirectory, \"SlideWorkflow.wl\"}]];\n",
    (* \:89aa\:30ab\:30fc\:30cd\:30eb\:306e $SlideIncludeInput \:3092\:5b50\:30d7\:30ed\:30bb\:30b9\:306b\:3082\:5f15\:304d\:7d99\:3050 *)
    "SlideWorkflow`$SlideIncludeInput = " <> ToString[$SlideIncludeInput, InputForm] <> ";\n",
    "res = SlideWorkflow`", kind, "[",
      ToString[deckFile, InputForm], ", ", ToString[outSpec, InputForm],
      If[optsCode === "", "", ", " <> optsCode], "];\n",
    "Print[\"__SLIDEWF_RESULT__\", ToString[res, InputForm]];\n"];
  Export[tmp, script, "Text", CharacterEncoding -> "UTF-8"];
  res = RunProcess[{iSWWolframScriptPath[], "-file", tmp}];
  Quiet[DeleteFile[tmp]];
  If[!AssociationQ[res], Return[$Failed]];
  out = StringCases[Lookup[res, "StandardOutput", ""],
    "__SLIDEWF_RESULT__" ~~ r___ ~~ EndOfString :> r];
  If[out === {}, $Failed, Quiet[Check[ToExpression[StringTrim[First[out]]], $Failed]]]];

(* \:4fdd\:5b58\:6e08\:307f\:306a\:3089\:5225\:30d7\:30ed\:30bb\:30b9\:3067\:66f8\:304d\:51fa\:3059 (FE \:3092\:5360\:6709\:3057\:306a\:3044)\:3002
   \:672a\:4fdd\:5b58\:30fb\:5916\:90e8\:5931\:6557\:6642\:306f\:5f93\:6765\:306e\:30a4\:30f3\:30d7\:30ed\:30bb\:30b9\:7d4c\:8def\:3078\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3059\:308b\:3002 *)
iSWTryExternal[nb_, kind_String, outSpec_String] := Module[{src, r},
  If[$SlideExportExternal === False || TrueQ[$iSWExternalBroken], Return[$Failed]];
  If[iSWUnsavedQ[nb], Return[$Failed]];
  src = iSWDeckSource[nb];
  If[!StringQ[src], Return[$Failed]];
  iSWStatus[nb, iSL["\:5225\:30d7\:30ed\:30bb\:30b9\:3067\:66f8\:304d\:51fa\:3057\:4e2d (FE \:306f\:64cd\:4f5c\:53ef\:80fd)...",
    "Exporting in a separate process (FE stays usable)..."]];
  r = iSWExternalExport[src, kind, outSpec, ""];
  (* \:5e2d\:67af\:6e07\:7b49\:3067\:5b50\:30d7\:30ed\:30bb\:30b9\:304c\:8d77\:304d\:306a\:3044\:74b0\:5883\:3067\:306f\:4ee5\:5f8c\:8a66\:3055\:306a\:3044 *)
  If[r === $Failed && $SlideExportExternal === Automatic, $iSWExternalBroken = True];
  r];

iSWExportImagesAction[nb_] := Module[{dir, base, imgs, files, ext, outdir},
  {dir, base} = iSWDeckBaseName[nb];
  outdir = FileNameJoin[{dir, base <> "_slides"}];
  ext = iSWTryExternal[nb, "SlideDeckExportImages", outdir];
  If[MatchQ[ext, {__String}],
    iSWStatus[nb, iSL[ToString[Length[ext]] <> " \:679a\:66f8\:304d\:51fa\:3057\:307e\:3057\:305f (\:5225\:30d7\:30ed\:30bb\:30b9)",
      "Exported " <> ToString[Length[ext]] <> " images (external)"]];
    iSWStatusClearLater[nb];
    Quiet[SystemOpen[outdir]];
    Return[ext]];
  If[iSWUnsavedQ[nb],
    iSWStatus[nb, iSL["\:672a\:4fdd\:5b58\:306e\:305f\:3081 FE \:5185\:3067\:51e6\:7406\:3057\:307e\:3059 (\:4fdd\:5b58\:5f8c\:306a\:3089\:5225\:30d7\:30ed\:30bb\:30b9\:3067\:9ad8\:901f)",
      "Unsaved: processing inside FE (save first to use the external process)"]]];
  iSWStatus[nb, iSL["\:753b\:50cf\:66f8\:304d\:51fa\:3057\:4e2d...", "Exporting images..."]];
  imgs = SlideDeckImages[iSWDeckSource[nb]];
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

iSWExportVideoAction[nb_] := Module[{dir, base, imgs, out, ext, mp4},
  {dir, base} = iSWDeckBaseName[nb];
  mp4 = FileNameJoin[{dir, base <> ".mp4"}];
  ext = iSWTryExternal[nb, "SlideDeckExportVideo", mp4];
  If[StringQ[ext],
    iSWStatus[nb, iSL["mp4 \:5b8c\:4e86 (\:5225\:30d7\:30ed\:30bb\:30b9): " <> FileNameTake[ext],
      "mp4 done (external): " <> FileNameTake[ext]]];
    iSWStatusClearLater[nb];
    Return[ext]];
  If[iSWUnsavedQ[nb],
    iSWStatus[nb, iSL["\:672a\:4fdd\:5b58\:306e\:305f\:3081 FE \:5185\:3067\:51e6\:7406\:3057\:307e\:3059 (\:4fdd\:5b58\:5f8c\:306a\:3089\:5225\:30d7\:30ed\:30bb\:30b9\:3067\:9ad8\:901f)",
      "Unsaved: processing inside FE (save first to use the external process)"]]];
  iSWStatus[nb, iSL["mp4 \:66f8\:304d\:51fa\:3057\:4e2d...", "Exporting mp4..."]];
  imgs = SlideDeckImages[iSWDeckSource[nb]];
  If[!MatchQ[imgs, {__Image}],
    iSWStatus[nb, iSL["\:66f8\:304d\:51fa\:3057\:5931\:6557", "Export failed"]]; iSWStatusClearLater[nb];
    Return[$Failed]];
  out = SlideDeckExportVideo[imgs, mp4];
  iSWStatus[nb, If[StringQ[out], iSL["mp4 \:5b8c\:4e86: " <> FileNameTake[out], "mp4 done: " <> FileNameTake[out]],
    iSL["mp4 \:5931\:6557", "mp4 failed"]]];
  iSWStatusClearLater[nb];
  out];

iSWOverviewAction[nb_] := Module[{ov = SlideDeckOverview[iSWDeckSource[nb]]},
  If[Head[ov] === Dataset,
    CreateDocument[{Cell[BoxData[ToBoxes[ov]], "Output"]},
      WindowTitle -> "Slide Overview", WindowSize -> {760, 520}],
    MessageDialog[iSL["\:4e00\:89a7\:3092\:53d6\:5f97\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f\:3002", "Could not build overview."]]]];

iSWExportScenarioAction[nb_] := Module[{dir, base, data, mdParts, md, out},
  {dir, base} = iSWDeckBaseName[nb];
  data = SlideDeckSlides[iSWDeckSource[nb]];
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

(* ===================== \:767a\:8868\:30b7\:30ca\:30ea\:30aa (talk) =====================
   \:30b9\:30e9\:30a4\:30c9\:306e\:300c\:4e2d\:8eab\:300d\:3067\:306f\:306a\:304f\:300c\:8a71\:3059\:539f\:7a3f\:300d\:3092\:6271\:3046\:5c64\:3002
   1 \:679a\:305a\:3064\:72ec\:7acb\:306b\:8aac\:660e\:6587\:3092\:4f5c\:308b\:3068\:767a\:8868\:3068\:3057\:3066\:306e\:6d41\:308c\:304c\:51fa\:306a\:3044\:306e\:3067\:3001\:539f\:7a3f\:306f\:30c7\:30c3\:30ad\:5168\:4f53\:3092
   1 \:5ea6\:306b\:898b\:3066\:66f8\:304f (VRCRealtime \:306e\:5f93\:6765\:52d5\:4f5c = 1 \:679a\:3054\:3068\:306e\:753b\:50cf\:8aac\:660e\:3001\:304c\:62b1\:3048\:3066\:3044\:305f\:554f\:984c)\:3002

   \:6b63\:672c\:306f Markdown:
     ---
     Title: / Aliases: / Event: / Author: / Date: / SlideURL: / SecondsPerSlide: ...
     ---
     # Opening
     ## 1 \:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb {seconds=30}
     # Closing
   \:767b\:9332\:7c3f (SourceVault_slidedeck.wl) \:3078\:306f\:30b3\:30f3\:30d1\:30a4\:30eb\:6e08\:307f\:9023\:60f3\:3092\:6e21\:3059\:3002 *)

If[!ValueQ[$SlideTalkSecondsPerSlide], $SlideTalkSecondsPerSlide = 25.];

(* ---- front matter ---- *)

iTalkSplitFrontMatter[md_String] := Module[{lines, endPos, meta = <||>, body, p, key},
  lines = StringSplit[StringReplace[md, "\r\n" -> "\n"], "\n", All];
  If[lines === {} || StringTrim[First[lines]] =!= "---", Return[{meta, lines}]];
  endPos = SelectFirst[Range[2, Length[lines]], StringTrim[lines[[#]]] === "---" &, None];
  If[endPos === None, Return[{meta, lines}]];
  Do[
    p = StringPosition[lines[[i]], ":", 1];
    If[p =!= {},
      key = StringTrim[StringTake[lines[[i]], First[First[p]] - 1]];
      If[key =!= "", meta[key] = StringTrim[StringDrop[lines[[i]], First[First[p]]]]]],
    {i, 2, endPos - 1}];
  {meta, If[endPos < Length[lines], lines[[endPos + 1 ;;]], {}]}];

iTalkMetaString[meta_Association, keys_List, default_String] := Module[{v},
  v = SelectFirst[Lookup[meta, #, Missing[]] & /@ keys, StringQ[#] && StringTrim[#] =!= "" &,
    Missing[]];
  If[StringQ[v], StringTrim[v], default]];

iTalkMetaNumber[meta_Association, keys_List, default_] := Module[{v},
  v = iTalkMetaString[meta, keys, ""];
  If[v === "", default,
    With[{n = Quiet[Check[ToExpression[v], $Failed]]}, If[NumericQ[n], N[n], default]]]];

iTalkSplitAliases[s_String] :=
  Select[StringTrim /@ StringSplit[s, {",", "\:3001", "/", ";"}], # =!= "" &];

(* ---- \:7bc0\:306e\:7a2e\:5225 ---- *)

iTalkSectionKind[title_String] := Module[{t = ToLowerCase[title]},
  Which[
    StringContainsQ[t, "opening"] || StringContainsQ[t, "intro"] ||
      StringContainsQ[title, "\:30aa\:30fc\:30d7\:30cb\:30f3\:30b0"] || StringContainsQ[title, "\:306f\:3058\:3081\:306b"] ||
      StringContainsQ[title, "\:5c0e\:5165"] || StringContainsQ[title, "\:5192\:982d"], "Opening",
    StringContainsQ[t, "closing"] || StringContainsQ[t, "outro"] ||
      StringContainsQ[title, "\:30af\:30ed\:30fc\:30b8\:30f3\:30b0"] || StringContainsQ[title, "\:307e\:3068\:3081"] ||
      StringContainsQ[title, "\:304a\:308f\:308a\:306b"] || StringContainsQ[title, "\:7d50\:3073"], "Closing",
    True, "Other"]];

(* "## 3 \:80cc\:666f {seconds=40}" -> <|Slide->3, Title->"\:80cc\:666f", Seconds->40.|> *)
iTalkParseSlideHeader[headIn_String] := Module[{t, sec = Null, num = Null, braces, kv, d},
  t = StringTrim[StringDrop[headIn, 3]];
  braces = StringCases[t, "{" ~~ Shortest[inner___] ~~ "}" :> inner];
  If[braces =!= {},
    kv = StringDelete[ToLowerCase[First[braces]], " "];
    d = StringCases[kv, ("seconds" | "expected" | "sec") ~~ "=" ~~ v : (DigitCharacter | ".") .. :> v];
    If[d =!= {},
      With[{n = Quiet[Check[ToExpression[First[d]], $Failed]]},
        If[NumericQ[n] && N[n] > 0., sec = N[n]]]];
    t = StringTrim[StringReplace[t, "{" ~~ Shortest[___] ~~ "}" -> ""]]];
  d = StringCases[t, StartOfString ~~ v : (DigitCharacter ..) ~~ (WhitespaceCharacter | "." | ")" | ":" | "-") :> v];
  If[d =!= {},
    With[{n = Quiet[Check[ToExpression[First[d]], $Failed]]},
      If[IntegerQ[n] && n >= 1,
        num = n;
        t = StringTrim[StringReplace[t,
          StartOfString ~~ (DigitCharacter ..) ~~ (WhitespaceCharacter | "." | ")" | ":" | "-") -> "", 1]]]]];
  <|"Slide" -> num, "Title" -> t, "Seconds" -> sec|>];

iTalkJoinLines[lines_List] := StringTrim[StringRiffle[lines, "\n"]];

SlideTalkFromMarkdown[File[path_String]] :=
  SlideTalkFromMarkdown[Import[path, "Text", CharacterEncoding -> "UTF-8"]];

SlideTalkFromMarkdown[md_String] := Module[
  {meta, body, mode = "Other", cur = <||>, buffer = {}, opening = {}, closing = {},
   slides = {}, flush, header, n = 0},
  {meta, body} = iTalkSplitFrontMatter[md];
  flush[] := (
    Which[
      mode === "Opening", opening = Join[opening, buffer],
      mode === "Closing", closing = Join[closing, buffer],
      mode === "Slide" && AssociationQ[cur] && cur =!= <||>,
        AppendTo[slides, Append[cur, "Text" -> iTalkJoinLines[buffer]]]];
    buffer = {});
  Do[
    Which[
      StringStartsQ[StringTrim[line], "## "],
      flush[];
      header = iTalkParseSlideHeader[StringTrim[line]];
      n = If[IntegerQ[header["Slide"]], header["Slide"], n + 1];
      cur = <|"Slide" -> n, "Title" -> header["Title"], "Seconds" -> header["Seconds"]|>;
      mode = "Slide",
      StringStartsQ[StringTrim[line], "# "],
      flush[];
      mode = iTalkSectionKind[StringTrim[StringDrop[StringTrim[line], 2]]];
      cur = <||>,
      True, AppendTo[buffer, line]],
    {line, body}];
  flush[];
  <|"Title" -> iTalkMetaString[meta, {"Title"}, ""],
    "Aliases" -> iTalkSplitAliases[iTalkMetaString[meta, {"Aliases", "Alias"}, ""]],
    "Event" -> iTalkMetaString[meta, {"Event"}, ""],
    "Author" -> iTalkMetaString[meta, {"Author"}, ""],
    "Date" -> iTalkMetaString[meta, {"Date"}, ""],
    "SlideURL" -> iTalkMetaString[meta, {"SlideURL", "URL", "Sliden"}, ""],
    "Deck" -> iTalkMetaString[meta, {"Deck", "DeckFile"}, ""],
    "Language" -> iTalkMetaString[meta, {"Language"}, "Japanese"],
    "NarrationInstructions" -> iTalkMetaString[meta, {"NarrationInstructions", "Instructions"}, ""],
    "SecondsPerSlide" -> iTalkMetaNumber[meta, {"SecondsPerSlide"}, $SlideTalkSecondsPerSlide],
    "PrivacyLevel" -> iTalkMetaNumber[meta, {"PrivacyLevel"}, 0.],
    "Opening" -> iTalkJoinLines[opening],
    "Closing" -> iTalkJoinLines[closing],
    "Slides" -> slides, "Meta" -> meta|>];

SlideTalkToMarkdown[talk_Association] := Module[{out = {}, push, aliases},
  push[s_] := AppendTo[out, s];
  push["---"];
  Do[With[{v = Lookup[talk, k, ""]},
      If[StringQ[v] && StringTrim[v] =!= "", push[k <> ": " <> StringTrim[v]]]],
    {k, {"Title"}}];
  aliases = Select[Flatten[{Lookup[talk, "Aliases", {}]}], StringQ[#] && StringTrim[#] =!= "" &];
  If[aliases =!= {}, push["Aliases: " <> StringRiffle[aliases, ", "]]];
  Do[With[{v = Lookup[talk, k, ""]},
      If[StringQ[v] && StringTrim[v] =!= "", push[k <> ": " <> StringTrim[v]]]],
    {k, {"Event", "Author", "Date", "SlideURL", "Deck", "Language", "NarrationInstructions"}}];
  With[{sp = Lookup[talk, "SecondsPerSlide", Null]},
    If[NumericQ[sp], push["SecondsPerSlide: " <> ToString[Round[N[sp]]]]]];
  With[{pl = Lookup[talk, "PrivacyLevel", Null]},
    If[NumericQ[pl], push["PrivacyLevel: " <> ToString[N[pl]]]]];
  push["---"]; push[""];
  With[{op = Lookup[talk, "Opening", ""]},
    If[StringQ[op] && StringTrim[op] =!= "",
      push["# Opening"]; push[StringTrim[op]]; push[""]]];
  Do[
    push["## " <> ToString[Lookup[slide, "Slide", ""]] <> " " <>
      ToString[Lookup[slide, "Title", ""]] <>
      With[{s = Lookup[slide, "Seconds", Null]},
        If[NumericQ[s], " {seconds=" <> ToString[Round[N[s]]] <> "}", ""]]];
    push[StringTrim[ToString[Lookup[slide, "Text", ""]]]];
    push[""],
    {slide, Select[Lookup[talk, "Slides", {}], AssociationQ]}];
  With[{cl = Lookup[talk, "Closing", ""]},
    If[StringQ[cl] && StringTrim[cl] =!= "",
      push["# Closing"]; push[StringTrim[cl]]; push[""]]];
  StringRiffle[out, "\n"]];

(* ---- \:30c7\:30c3\:30ad\:304b\:3089\:539f\:7a3f\:306e\:6750\:6599\:3092\:96c6\:3081\:308b ---- *)

(* \:8a71\:901f (\:6587\:5b57/\:79d2)\:3002\:30c8\:30fc\:30af\:30bb\:30eb\:304b\:3089\:79d2\:6570\:3092\:898b\:7a4d\:3082\:308b\:306e\:306b\:4f7f\:3046 *)
iSWTalkCharRate[] := Quiet[Check[Lookup[$SlideSpeechRate, "Local", 6.95], 6.95]];

iTalkDeckOutline[source_] := Module[{data, slides, titles, mds, talks},
  data = SlideDeckSlides[source];
  If[!AssociationQ[data], Return[$Failed]];
  slides = Lookup[data, "Slides", {}];
  If[slides === {}, Return[$Failed]];
  titles = SlideWorkflow`Private`iSlideTitle /@ slides;
  (* \:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb (SlideTalk) \:3092\:53ce\:7a6b\:3059\:308b *)
  talks = StringTrim[StringRiffle[
    Cases[#, c : Cell[_, "SlideTalk", ___] :>
      SlideWorkflow`Private`iCellText[c], {1}], "\n"]] & /@ slides;
  mds = StringRiffle[
    Select[StringSplit[#, "\n"], !StringStartsQ[StringTrim[#], "talk:"] &],
    "\n"] & /@
    (StringReplace[First[iSWSlideToMarkdown[#]],
      "<<FIG" ~~ DigitCharacter .. ~~ ">>" -> "(\:56f3)"] & /@ slides);
  <|"Count" -> Length[slides], "Titles" -> titles, "Markdown" -> mds,
    "Talks" -> talks, "Prelude" -> Lookup[data, "Prelude", {}]|>];

Options[SlideTalkSkeleton] = {
  "Title" -> Automatic, "Aliases" -> {}, "Event" -> "", "Author" -> "", "Date" -> "",
  "SlideURL" -> "", "SecondsPerSlide" -> Automatic, "Language" -> "Japanese",
  "NarrationInstructions" -> "", "PrivacyLevel" -> 0., "Outline" -> Automatic};

(* LLM \:4e0d\:5728\:3067\:3082\:767b\:9332\:3067\:304d\:308b\:6c7a\:5b9a\:8ad6\:7684\:306a\:9aa8\:683c\:3002\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:7b87\:6761\:66f8\:304d\:3092\:305d\:306e\:307e\:307e\:539f\:7a3f\:306b\:3059\:308b
   (\:6d41\:308c\:306f\:7121\:3044\:3002\:3060\:304c\:300c\:539f\:7a3f\:304c\:7121\:3044\:300d\:3088\:308a\:72b6\:614b\:304c\:5206\:304b\:308a\:3084\:3059\:304f\:3001\:7de8\:96c6\:306e\:51fa\:767a\:70b9\:306b\:306a\:308b)\:3002 *)
SlideTalkSkeleton[source_, OptionsPattern[]] := Module[
  {outline, deckFile, title, seconds, lines, slideEntries},
  outline = Replace[OptionValue["Outline"], Automatic :> iTalkDeckOutline[source]];
  If[outline === $Failed, Return[$Failed]];
  deckFile = If[StringQ[source], source, ""];
  title = OptionValue["Title"];
  If[title === Automatic,
    title = If[StringQ[deckFile] && deckFile =!= "", FileBaseName[deckFile], "\:767a\:8868"]];
  seconds = OptionValue["SecondsPerSlide"];
  If[seconds === Automatic, seconds = $SlideTalkSecondsPerSlide];
  slideEntries = MapIndexed[
    Module[{i = First[#2], talk, body},
      talk = If[KeyExistsQ[outline, "Talks"], outline["Talks"][[i]], ""];
      If[StringQ[talk] && StringTrim[talk] =!= "",
        (* \:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb\:304c\:3042\:308c\:3070\:305d\:308c\:304c\:539f\:7a3f\:3002\:79d2\:6570\:306f\:6587\:5b57\:6570\:3068\:8a71\:901f\:304b\:3089 *)
        <|"Slide" -> i, "Title" -> outline["Titles"][[i]],
          "Seconds" -> Max[10., N[Round[StringLength[StringTrim[talk]]/iSWTalkCharRate[]]]],
          "Text" -> StringTrim[talk]|>,
        body = Select[StringTrim /@ StringSplit[#1, "\n"],
          # =!= "" && !StringStartsQ[#, "## "] && !StringStartsQ[#, "cite:"] &];
        body = StringReplace[body, StartOfString ~~ ("- " | "> ") -> ""];
        <|"Slide" -> i, "Title" -> outline["Titles"][[i]], "Seconds" -> N[seconds],
          "Text" -> If[body === {}, outline["Titles"][[i]] <> "\:306b\:3064\:3044\:3066\:8aac\:660e\:3057\:307e\:3059\:3002",
            StringRiffle[body, "\n"]]|>]] &,
    outline["Markdown"]];
  SlideTalkToMarkdown[<|
    "Title" -> title,
    "Aliases" -> OptionValue["Aliases"],
    "Event" -> OptionValue["Event"], "Author" -> OptionValue["Author"],
    "Date" -> OptionValue["Date"], "SlideURL" -> OptionValue["SlideURL"],
    "Deck" -> deckFile, "Language" -> OptionValue["Language"],
    "NarrationInstructions" -> OptionValue["NarrationInstructions"],
    "SecondsPerSlide" -> N[seconds], "PrivacyLevel" -> OptionValue["PrivacyLevel"],
    "Opening" -> "",
    "Closing" -> "",
    "Slides" -> slideEntries|>]];

Options[SlideTalkPrompt] = Join[Options[SlideTalkSkeleton], {"Instructions" -> "", "Meta" -> ""}];

SlideTalkPrompt[source_, OptionsPattern[]] := Module[
  {outline, seconds, total, deck, title},
  outline = iTalkDeckOutline[source];
  If[outline === $Failed, Return[$Failed]];
  seconds = OptionValue["SecondsPerSlide"];
  If[seconds === Automatic, seconds = $SlideTalkSecondsPerSlide];
  total = Round[outline["Count"] * N[seconds] / 60.];
  title = OptionValue["Title"];
  If[title === Automatic, title = If[StringQ[source], FileBaseName[source], "\:767a\:8868"]];
  deck = StringRiffle[
    MapIndexed["### \:30b9\:30e9\:30a4\:30c9 " <> ToString[First[#2]] <> "\n" <> #1 &, outline["Markdown"]],
    "\n\n"];
  OptionValue["Meta"] <>
  "\:3042\:306a\:305f\:306f\:7814\:7a76\:767a\:8868\:306e\:539f\:7a3f\:30e9\:30a4\:30bf\:30fc\:3067\:3059\:3002\:4ee5\:4e0b\:306e\:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad\:5168\:4f53\:3092\:8aad\:307f\:3001" <>
  "1 \:3064\:306e\:767a\:8868\:3068\:3057\:3066\:6d41\:308c\:306e\:3042\:308b\:767a\:8a71\:539f\:7a3f\:3092\:66f8\:3044\:3066\:304f\:3060\:3055\:3044\:3002\n\n" <>
  "\:91cd\:8981\:306a\:8981\:4ef6:\n" <>
  "- 1 \:679a\:305a\:3064\:72ec\:7acb\:3057\:305f\:8aac\:660e\:306e\:5bc4\:305b\:96c6\:3081\:306b\:3057\:306a\:3044\:3002\:5168\:4f53\:3092\:901a\:3057\:305f\:7b4b\:66f8\:304d (\:554f\:984c\:2192\:65b9\:6cd5\:2192\:7d50\:679c\:2192\:610f\:5473) \:3092\:4f5c\:308a\:3001" <>
  "\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:539f\:7a3f\:304c\:305d\:306e\:7b4b\:66f8\:304d\:306e\:4e2d\:306e\:3069\:3053\:304b\:304c\:5206\:304b\:308b\:3088\:3046\:306b\:3059\:308b\:3002\n" <>
  "- \:5404\:30b9\:30e9\:30a4\:30c9\:306e\:5192\:982d\:3067\:524d\:306e\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:306e\:63a5\:7d9a\:3092\:4e00\:8a00\:5165\:308c\:308b (\:300c\:3053\:3053\:307e\:3067\:304c\:2026\:3001\:6b21\:306f\:2026\:300d)\:3002" <>
  "\:305f\:3060\:3057\:6bce\:56de\:540c\:3058\:8a00\:3044\:56de\:3057\:306b\:3057\:306a\:3044\:3002\n" <>
  "- \:30b9\:30e9\:30a4\:30c9\:306b\:66f8\:304b\:308c\:3066\:3044\:306a\:3044\:4e8b\:5b9f\:30fb\:6570\:5024\:30fb\:5f15\:7528\:3092\:4f5c\:3089\:306a\:3044\:3002\:8aad\:307f\:4e0a\:3052\:3067\:306f\:306a\:304f\:8a71\:3057\:8a00\:8449\:306b\:3059\:308b\:3002\n" <>
  "- \:8074\:8846\:306f\:53e3\:982d\:3067\:3057\:304b\:805e\:304b\:306a\:3044\:3002\:7b87\:6761\:66f8\:304d\:8a18\:53f7\:30fb\:8a18\:53f7\:5217\:30fbURL \:306e\:8aad\:307f\:4e0a\:3052\:3092\:539f\:7a3f\:306b\:5165\:308c\:306a\:3044\:3002\n" <>
  "- \:60f3\:5b9a\:306f 1 \:679a\:3042\:305f\:308a " <> ToString[Round[N[seconds]]] <> " \:79d2\:524d\:5f8c\:3001\:5168\:4f53\:3067\:7d04 " <>
    ToString[total] <> " \:5206\:3002\:65e5\:672c\:8a9e\:3067\:66f8\:304f\:3002\n\n" <>
  "\:51fa\:529b\:306f\:6b21\:306e\:66f8\:5f0f\:306e Markdown \:3060\:3051\:3002\:524d\:7f6e\:304d\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:30fb\:8aac\:660e\:306f\:4e00\:5207\:51fa\:529b\:3057\:306a\:3044\:3002\n" <>
  "---\n" <>
  "Title: " <> title <> "\n" <>
  "SlideURL: " <> ToString[OptionValue["SlideURL"]] <> "\n" <>
  "SecondsPerSlide: " <> ToString[Round[N[seconds]]] <> "\n" <>
  "---\n" <>
  "# Opening\n" <>
  "(\:30b9\:30e9\:30a4\:30c9\:306b\:5165\:308b\:524d\:306e\:5c0e\:5165\:3002\:767a\:8868\:5168\:4f53\:306e\:898b\:53d6\:308a\:56f3\:3092 3 \:6587\:7a0b\:5ea6\:3067)\n" <>
  "## 1 \:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb {seconds=\:79d2}\n" <>
  "(1 \:679a\:76ee\:306e\:539f\:7a3f)\n" <>
  "## 2 \:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb {seconds=\:79d2}\n" <>
  "(2 \:679a\:76ee\:306e\:539f\:7a3f)\n" <>
  "# Closing\n" <>
  "(\:7de0\:3081\:3002\:7d50\:8ad6\:3068\:6301\:3061\:5e30\:3063\:3066\:307b\:3057\:3044 1 \:70b9)\n\n" <>
  "\:898f\:5247:\n" <>
  "- ## \:306f\:5fc5\:305a " <> ToString[outline["Count"]] <> " \:500b\:3001\:30b9\:30e9\:30a4\:30c9\:756a\:53f7 1 \:304b\:3089 " <>
    ToString[outline["Count"]] <> " \:307e\:3067\:9806\:306b\:51fa\:529b\:3059\:308b\:3002\:629c\:304b\:3055\:306a\:3044\:3002\n" <>
  "- ## \:306e\:898b\:51fa\:3057\:306f\:30b9\:30e9\:30a4\:30c9\:306e\:5b9f\:969b\:306e\:30bf\:30a4\:30c8\:30eb\:3092\:4f7f\:3046\:3002\n" <>
  "- \:539f\:7a3f\:672c\:6587\:306b\:898b\:51fa\:3057\:8a18\:53f7 (#, -, *) \:3092\:4f7f\:308f\:306a\:3044\:3002\n" <>
  If[StringTrim[OptionValue["Instructions"]] =!= "",
    "\n\:8ffd\:52a0\:6307\:793a (\:53b3\:5b88):\n" <> StringTrim[OptionValue["Instructions"]] <> "\n", ""] <>
  "\n=== \:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad ===\n" <> deck];

SlideTalkFile[source_String] :=
  FileNameJoin[{DirectoryName[source], FileBaseName[source] <> "_talk.md"}];

SlideTalkFile[nb_NotebookObject] := Module[{dir, base},
  {dir, base} = iSWDeckBaseName[nb];
  FileNameJoin[{dir, base <> "_talk.md"}]];

(* LLM \:5fdc\:7b54 -> talk md\:3002\:30d5\:30a7\:30f3\:30b9\:9664\:53bb + front matter \:88dc\:5b8c + \:679a\:6570\:306e\:8a18\:9332\:3002 *)
iTalkNormalizeResponse[resp_String, fallbackFrontMatter_String] := Module[{t, lines},
  lines = StringSplit[StringReplace[resp, "\r\n" -> "\n"], "\n", All];
  lines = Select[lines, !StringStartsQ[StringTrim[#], "```"] &];
  t = StringTrim[StringRiffle[lines, "\n"]];
  If[!StringStartsQ[t, "---"],
    t = fallbackFrontMatter <> "\n" <> t];
  t];

iTalkFrontMatterOf[md_String] := Module[{lines, endPos},
  lines = StringSplit[StringReplace[md, "\r\n" -> "\n"], "\n", All];
  If[lines === {} || StringTrim[First[lines]] =!= "---", Return["---\n---"]];
  endPos = SelectFirst[Range[2, Length[lines]], StringTrim[lines[[#]]] === "---" &, None];
  If[endPos === None, "---\n---", StringRiffle[lines[[;; endPos]], "\n"]]];

iTalkWriteFile[path_String, md_String] := (
  If[FileExistsQ[path],
    Quiet[CopyFile[path, path <> ".bak", OverwriteTarget -> True]]];
  Export[path, md, "Text", CharacterEncoding -> "UTF-8"]);

Options[SlideTalkBuild] = Join[Options[SlideTalkPrompt],
  {"Output" -> Automatic, "UseLLM" -> Automatic, "Notebook" -> Automatic,
   "OpenResult" -> False}];

(* \:539f\:7a3f\:751f\:6210\:3002LLM \:304c\:4f7f\:3048\:308c\:3070\:975e\:540c\:671f\:3067\:4f9d\:983c\:3057\:3001\:4f7f\:3048\:306a\:3051\:308c\:3070\:9aa8\:683c\:3092\:540c\:671f\:3067\:66f8\:304f\:3002
   \:975e\:540c\:671f\:306a\:306e\:306f\:3001\:30c7\:30c3\:30ad 1 \:518a\:3076\:3093\:306e\:751f\:6210\:304c FE \:3092\:6570\:5341\:79d2\:5360\:6709\:3059\:308b\:306e\:3092\:907f\:3051\:308b\:305f\:3081
   (SlideExpand / SlideTranslate \:3068\:540c\:3058\:7d4c\:8def)\:3002 *)
SlideTalkBuild[source_, opts : OptionsPattern[]] := Module[
  {out, useLLM, nb, outline, skeleton, prompt, front},
  out = OptionValue["Output"];
  If[out === Automatic,
    out = Which[
      StringQ[source], SlideTalkFile[source],
      Head[source] === NotebookObject, SlideTalkFile[source],
      True, FileNameJoin[{$TemporaryDirectory, "slide_talk.md"}]]];
  outline = iTalkDeckOutline[source];
  If[outline === $Failed,
    Return[Failure["SlideTalkNoDeck",
      <|"MessageTemplate" -> "\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093 (navbar \:533a\:5207\:308a\:304c\:7121\:3044?)\:3002"|>]]];
  skeleton = SlideTalkSkeleton[source, "Outline" -> outline,
    Sequence @@ FilterRules[{opts}, Options[SlideTalkSkeleton]]];
  If[skeleton === $Failed,
    Return[Failure["SlideTalkNoDeck",
      <|"MessageTemplate" -> "\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093 (navbar \:533a\:5207\:308a\:304c\:7121\:3044?)\:3002"|>]]];
  (* \:5168\:30b9\:30e9\:30a4\:30c9\:306b\:30c8\:30fc\:30af\:30bb\:30eb\:304c\:3042\:308c\:3070 LLM \:4e0d\:8981 \:2014 \:30bb\:30eb\:306e\:539f\:7a3f\:3092\:305d\:306e\:307e\:307e\:675f\:306d\:308b *)
  If[Lookup[outline, "Talks", {}] =!= {} &&
      AllTrue[outline["Talks"], StringQ[#] && StringTrim[#] =!= "" &],
    iTalkWriteFile[out, skeleton];
    If[TrueQ[OptionValue["OpenResult"]], Quiet[SystemOpen[out]]];
    Return[<|"Status" -> "FromCells", "Output" -> out, "UsedLLM" -> False,
      "SlideCount" -> outline["Count"]|>]];
  front = iTalkFrontMatterOf[skeleton];
  useLLM = OptionValue["UseLLM"];
  nb = OptionValue["Notebook"];
  If[nb === Automatic, nb = Quiet[iSWResolveTargetNb[]]];
  If[useLLM === Automatic, useLLM = iSWLLMReadyQ[] && Head[nb] === NotebookObject];
  If[!TrueQ[useLLM],
    iTalkWriteFile[out, skeleton];
    If[TrueQ[OptionValue["OpenResult"]], Quiet[SystemOpen[out]]];
    Return[<|"Status" -> "Skeleton", "Output" -> out, "UsedLLM" -> False|>]];
  prompt = SlideTalkPrompt[source, Sequence @@ FilterRules[{opts}, Options[SlideTalkPrompt]]];
  If[!StringQ[prompt],
    iTalkWriteFile[out, skeleton];
    Return[<|"Status" -> "Skeleton", "Output" -> out, "UsedLLM" -> False|>]];
  With[{o = out, f = front, s = skeleton, n2 = nb, open = TrueQ[OptionValue["OpenResult"]]},
    NBAccess`$NBLLMQueryFunc[prompt,
      Function[resp, iTalkApplyResponse[n2, o, resp, f, s, open]],
      n2, Fallback -> iSWFallback[]]];
  <|"Status" -> "Submitted", "Output" -> out, "UsedLLM" -> True|>];

iTalkApplyResponse[nb_, out_String, resp_, front_String, skeleton_String, open_] :=
  Module[{md, talk},
    If[!StringQ[resp] || StringStartsQ[resp, "Error"] || StringStartsQ[resp, "[ERROR]"],
      iTalkWriteFile[out, skeleton];
      iSWStatus[nb, iSL["\:539f\:7a3f\:751f\:6210\:306b\:5931\:6557\:3002\:9aa8\:683c\:3092\:66f8\:304d\:51fa\:3057\:307e\:3057\:305f: " <> FileNameTake[out],
        "Talk generation failed; wrote the skeleton: " <> FileNameTake[out]]];
      iSWStatusClearLater[nb];
      Return[$Failed]];
    md = iTalkNormalizeResponse[resp, front];
    talk = SlideTalkFromMarkdown[md];
    If[!AssociationQ[talk] || Lookup[talk, "Slides", {}] === {},
      iTalkWriteFile[out, skeleton];
      iSWStatus[nb, iSL["\:539f\:7a3f\:306e\:66f8\:5f0f\:304c\:4e0d\:6b63\:3002\:9aa8\:683c\:3092\:66f8\:304d\:51fa\:3057\:307e\:3057\:305f", "Bad talk format; wrote the skeleton"]];
      iSWStatusClearLater[nb];
      Return[$Failed]];
    iTalkWriteFile[out, md];
    iSWStatus[nb, iSL[
      "\:767a\:8868\:30b7\:30ca\:30ea\:30aa " <> ToString[Length[talk["Slides"]]] <> " \:679a: " <> FileNameTake[out],
      "Talk scenario (" <> ToString[Length[talk["Slides"]]] <> " slides): " <> FileNameTake[out]]];
    iSWStatusClearLater[nb];
    If[TrueQ[open], Quiet[SystemOpen[out]]];
    <|"Status" -> "Written", "Output" -> out, "SlideCount" -> Length[talk["Slides"]]|>];

(* ---- \:767b\:9332\:7c3f\:3078\:306e\:767b\:9332 (SourceVault_slidedeck.wl \:3078\:59d4\:8b72) ---- *)

iTalkRegistryAvailableQ[] :=
  Length[DownValues[SourceVault`SourceVaultSlideDeckRegister]] > 0;

iTalkResolveMarkdown[src_] := Which[
  StringQ[src] && FileExistsQ[src] && ToLowerCase[FileExtension[src]] === "md",
    Import[src, "Text", CharacterEncoding -> "UTF-8"],
  StringQ[src] && FileExistsQ[src] && ToLowerCase[FileExtension[src]] === "nb",
    With[{tf = SlideTalkFile[src]},
      If[FileExistsQ[tf], Import[tf, "Text", CharacterEncoding -> "UTF-8"], $Failed]],
  Head[src] === NotebookObject,
    With[{tf = SlideTalkFile[src]},
      If[FileExistsQ[tf], Import[tf, "Text", CharacterEncoding -> "UTF-8"], $Failed]],
  StringQ[src] && StringContainsQ[src, "\n"], src,
  True, $Failed];

Options[SlideDeckRegister] = {
  "SlideURL" -> Automatic, "Title" -> Automatic, "Id" -> Automatic,
  "DeckFile" -> Automatic, "PrivacyLevel" -> Automatic, "SlideCount" -> Automatic};

(* \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304b\:3089\:76f4\:63a5: \:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb + SlideTalkMeta \:3067\:767b\:9332\:304c\:5b8c\:7d50\:3059\:308b\:3002
   \:30c8\:30fc\:30af\:30bb\:30eb\:304c\:7121\:3044\:65e7\:30c7\:30c3\:30ad\:3060\:3051 _talk.md \:3078\:843d\:3061\:308b *)
SlideDeckRegister[nb_NotebookObject, opts : OptionsPattern[]] := Module[{talk, md, fn},
  talk = iSWTalkResolve[nb];
  If[!AssociationQ[talk],
    Return[Failure["SlideTalkMissing",
      <|"MessageTemplate" ->
        "\:767a\:8868\:306e\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093\:3002\:30b9\:30e9\:30a4\:30c9\:306b\:30c8\:30fc\:30af\:30bb\:30eb\:3092\:4f5c\:308b\:304b (\:633f\:5165 > \:30c8\:30fc\:30af\:3001\:307e\:305f\:306f\:5c55\:958b)\:3001\:300c\:30b7\:30ca\:30ea\:30aa\:300d\:3067 _talk.md \:3092\:4f5c\:6210\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  md = SlideTalkToMarkdown[KeyDrop[talk, {"TalkSource", "Meta"}]];
  fn = Quiet[NotebookFileName[nb]];
  iSWDeckRegisterCore[talk, md, If[StringQ[fn], fn, ""],
    {"Title" -> OptionValue["Title"], "SlideURL" -> OptionValue["SlideURL"],
     "Id" -> OptionValue["Id"], "DeckFile" -> OptionValue["DeckFile"],
     "PrivacyLevel" -> OptionValue["PrivacyLevel"],
     "SlideCount" -> OptionValue["SlideCount"]}]];

SlideDeckRegister[src_, OptionsPattern[]] := Module[{cells, md, talk, deckFileDefault},
  (* .nb path \:3067\:3082\:30c8\:30fc\:30af\:30bb\:30eb\:512a\:5148 (headless \:304b\:3089\:306e\:767b\:9332\:304c md \:7121\:3057\:3067\:901a\:308b) *)
  cells = If[StringQ[src] && FileExistsQ[src] &&
      ToLowerCase[FileExtension[src]] === "nb",
    Quiet[iSWTalkFromCellsPath[src]], $Failed];
  If[AssociationQ[cells],
    talk = cells;
    md = SlideTalkToMarkdown[KeyDrop[talk, {"TalkSource", "Meta"}]];
    deckFileDefault = src,
    md = iTalkResolveMarkdown[src];
    If[!StringQ[md],
      Return[Failure["SlideTalkMissing",
        <|"MessageTemplate" ->
          "\:767a\:8868\:306e\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093 (\:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb\:3082 _talk.md \:3082\:7121\:3057)\:3002\:30c8\:30fc\:30af\:30bb\:30eb\:3092\:4f5c\:308b\:304b\:300c\:30b7\:30ca\:30ea\:30aa\:300d\:3067\:4f5c\:6210\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
    talk = SlideTalkFromMarkdown[md];
    If[!AssociationQ[talk] || Lookup[talk, "Slides", {}] === {},
      Return[Failure["SlideTalkEmpty",
        <|"MessageTemplate" -> "\:767a\:8868\:30b7\:30ca\:30ea\:30aa\:306b ## \:3067\:59cb\:307e\:308b\:30b9\:30e9\:30a4\:30c9\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093\:3002"|>]]];
    deckFileDefault = If[StringQ[src] && FileExistsQ[src] &&
        ToLowerCase[FileExtension[src]] === "nb", src, ""]];
  iSWDeckRegisterCore[talk, md, deckFileDefault,
    {"Title" -> OptionValue["Title"], "SlideURL" -> OptionValue["SlideURL"],
     "Id" -> OptionValue["Id"], "DeckFile" -> OptionValue["DeckFile"],
     "PrivacyLevel" -> OptionValue["PrivacyLevel"],
     "SlideCount" -> OptionValue["SlideCount"]}]];

iSWDeckRegisterCore[talk_Association, md_String, deckFileDefault_String, optRules_List] :=
  Module[{opt = Association[optRules], title, url, entry, deckFile},
  title = Lookup[opt, "Title", Automatic];
  If[title === Automatic, title = talk["Title"]];
  url = Lookup[opt, "SlideURL", Automatic];
  If[url === Automatic, url = talk["SlideURL"]];
  If[!StringQ[title] || StringTrim[title] === "",
    Return[Failure["SlideTalkTitleMissing",
      <|"MessageTemplate" ->
        "\:767a\:8868\:30bf\:30a4\:30c8\:30eb\:304c\:3042\:308a\:307e\:305b\:3093\:3002SlideTalkMeta[nb, \"Title\" -> \"...\"] \:304b _talk.md \:306e front matter \:3067\:8a2d\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  If[!StringQ[url] || !StringMatchQ[url, ("http://" | "https://") ~~ __],
    Return[Failure["SlideTalkURLMissing",
      <|"MessageTemplate" ->
        "SlideURL (Sliden \:7528 mp4 \:306e URL) \:304c\:3042\:308a\:307e\:305b\:3093\:3002SlideTalkMeta[nb, \"SlideURL\" -> \"https://...\"] \:3067\:8a2d\:5b9a\:3059\:308b\:304b\:3001\"SlideURL\" \:30aa\:30d7\:30b7\:30e7\:30f3\:3067\:6e21\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
        "SlideURL" -> url|>]]];
  If[!iTalkRegistryAvailableQ[],
    Return[Failure["SlideDeckRegistryUnavailable",
      <|"MessageTemplate" ->
        "SourceVault_slidedeck.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093 (SourceVault \:3092\:30ed\:30fc\:30c9\:3057\:3066\:304f\:3060\:3055\:3044)\:3002"|>]]];
  deckFile = Lookup[opt, "DeckFile", Automatic];
  If[deckFile === Automatic,
    deckFile = Which[
      deckFileDefault =!= "", deckFileDefault,
      StringQ[talk["Deck"]] && talk["Deck"] =!= "", talk["Deck"],
      True, ""]];
  entry = <|
    "Title" -> StringTrim[title],
    "Aliases" -> talk["Aliases"],
    "SlideURL" -> StringTrim[url],
    "Event" -> talk["Event"], "Author" -> talk["Author"], "Date" -> talk["Date"],
    "DeckFile" -> deckFile,
    "SecondsPerSlide" -> talk["SecondsPerSlide"],
    "NarrationInstructions" -> talk["NarrationInstructions"],
    "SlideCount" -> With[{c = Lookup[opt, "SlideCount", Automatic]},
      If[IntegerQ[c], c, Length[talk["Slides"]]]],
    "PrivacyLevel" -> With[{p = Lookup[opt, "PrivacyLevel", Automatic]},
      If[NumericQ[p], N[p], talk["PrivacyLevel"]]],
    "TalkMarkdown" -> md|>;
  If[Lookup[opt, "Id", Automatic] =!= Automatic, entry["Id"] = ToString[opt["Id"]]];
  SourceVault`SourceVaultSlideDeckRegister[entry,
    KeyTake[talk, {"Title", "Language", "Opening", "Closing", "Slides"}]]];

SlideDeckRegistry[] := If[iTalkRegistryAvailableQ[],
  SourceVault`SourceVaultSlideDeckRegistry[],
  Failure["SlideDeckRegistryUnavailable",
    <|"MessageTemplate" -> "SourceVault_slidedeck.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093\:3002"|>]];

(* ===================== \:97f3\:58f0\:30d7\:30ec\:30bc\:30f3: \:8aad\:307f\:4e0a\:3052 + \:81ea\:52d5\:30da\:30fc\:30b8\:9001\:308a =====================
   <deck>_talk.md \:306e\:767a\:8868\:30b7\:30ca\:30ea\:30aa\:3092 SourceVault \:306e\:30ed\:30fc\:30ab\:30eb\:97f3\:58f0 (Piper) \:3067\:5408\:6210\:3057\:3001
   1 \:679a\:8aad\:307f\:7d42\:308f\:308b\:3054\:3068\:306b\:30b9\:30e9\:30a4\:30c9\:3092 1 \:679a\:9032\:3081\:308b\:3002\:5bfe\:8c61\:306f\:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883\:304c SlideShow \:306e
   \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3002\:5408\:6210\:7d50\:679c\:306f <deck>_voice/ \:306b\:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b\:306e\:3067\:30012 \:56de\:76ee\:4ee5\:964d\:306e
   \:518d\:751f\:306f\:5f85\:305f\:3055\:308c\:306a\:3044\:3002

   FE \:3092\:6b62\:3081\:306a\:3044\:305f\:3081\:306e\:7d04\:675f:
     - \:30d1\:30ec\:30c3\:30c8\:5074\:306b\:5e38\:99d0 Dynamic \:306e\:30dd\:30fc\:30ea\:30f3\:30b0\:3092\:7f6e\:304b\:306a\:3044 (\:5b9f\:7e3e\:306e\:3042\:308b\:30d5\:30ea\:30fc\:30ba\:6e90)\:3002
       \:9032\:884c\:306f\:30ab\:30fc\:30cd\:30eb\:5074\:306e ScheduledTask \:304c\:56de\:3057\:3001\:30d1\:30ec\:30c3\:30c8\:306f TrackedSymbols \:3067
       \:6587\:5b57\:5217\:5909\:6570\:3060\:3051\:3092\:8ffd\:3046 (P:/M: \:30e9\:30d9\:30eb\:3068\:540c\:3058\:5f62)\:3002
     - \:97f3\:58f0\:518d\:751f\:306f FE \:5074\:306e AudioStream \:306a\:306e\:3067\:3001\:6b21\:30b9\:30e9\:30a4\:30c9\:306e\:5148\:8aad\:307f\:5408\:6210\:3067
       \:30ab\:30fc\:30cd\:30eb\:304c\:6570\:79d2\:6b62\:307e\:3063\:3066\:3082\:518d\:751f\:306f\:9014\:5207\:308c\:306a\:3044\:3002
   ============================================================================= *)

If[!ValueQ[$SlideVoice], $SlideVoice = Automatic];
If[!ValueQ[$SlideVoiceGap], $SlideVoiceGap = 0.8];
If[!ValueQ[$SlideVoiceTick], $SlideVoiceTick = 0.3];
If[!ValueQ[$SlideRealtimeVoices], $SlideRealtimeVoices = {"marin", "cedar"}];
If[!ValueQ[$SlideQuestionSeconds], $SlideQuestionSeconds = 3.];
If[!ValueQ[$SlideQuestionMaxSeconds], $SlideQuestionMaxSeconds = 60.];
If[!ValueQ[$SlideVoiceInputGate], $SlideVoiceInputGate = 0.];
If[!ValueQ[$SlideRemoteBindings],
  $SlideRemoteBindings = <|"MediaPrevTrack" -> "Mic",
    "MediaPlayPause" -> "Play"|>];
If[!ValueQ[$SlideRemoteTick], $SlideRemoteTick = 0.15];
If[!ValueQ[$SlideRemoteAuto], $SlideRemoteAuto = True];
(* \:5b9f\:6e2c: 376 \:5b57\:306e\:540c\:3058\:539f\:7a3f\:3067 Piper 54.1 \:79d2 / gpt-realtime 67.1 \:79d2 *)
If[!ValueQ[$SlideSpeechRate],
  $SlideSpeechRate = <|"Local" -> 6.95, "Realtime" -> 5.6|>];
If[!ValueQ[$SlideSpeechLatency],
  $SlideSpeechLatency = <|"Local" -> 0.3, "Realtime" -> 1.5|>];

(* \:539f\:7a3f\:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9\:3092\:4f55\:79d2\:898b\:305b\:3066\:304b\:3089\:6b21\:3078\:884c\:304f\:304b *)
$iSWVoiceSilentSeconds = 3.;

$iSWPlayState = <|
  "Status" -> "Idle", "Notebook" -> None, "Texts" -> <||>,
  "Slide" -> 0, "Count" -> 0, "Stream" -> None, "Voice" -> None,
  "Engine" -> "Local", "Run" -> 0, "NarrationId" -> None, "WindowStart" -> 0.,
  "StartedBridge" -> False, "Instructions" -> "",
  "UseFECounter" -> True, "StartedAt" -> 0., "AudioEnd" -> 0., "Duration" -> 0.,
  "Deadline" -> 0., "Remaining" -> 0., "Task" -> None, "LastFailure" -> None,
  "LastPos" -> 0., "LastPosAt" -> 0.|>;

$iSWPlayBusy = False;
$iSWPlayBusySince = 0.;
$iSWPlayLabel = "\[FilledRightTriangle] " <> iSL["\:518d\:751f", "Play"];
$iSWVoiceLabel = "V: -";
$iSWPlayProgress = "";

(* ---- \:58f0\:306e\:9078\:629e (SourceVault \:306e\:30ed\:30fc\:30ab\:30eb\:97f3\:58f0\:8cc7\:7523) ---- *)

iSWVoiceLayerQ[] := Length[DownValues[SourceVault`SourceVaultVoiceSpeak]] > 0;

iSWVoiceReadyQ[] := iSWVoiceLayerQ[] &&
  TrueQ[Quiet[SourceVault`SourceVaultVoiceAvailableQ[]]];

iSWVoiceHint[] := If[Length[DownValues[SourceVault`SourceVaultVoiceInstallHint]] > 0,
  With[{h = Quiet[SourceVault`SourceVaultVoiceInstallHint[]]}, If[StringQ[h], h, ""]],
  iSL["SourceVault_voice.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093 (SourceVault \:3092\:30ed\:30fc\:30c9\:3057\:3066\:304f\:3060\:3055\:3044)\:3002",
    "SourceVault_voice.wl is not loaded (load SourceVault first)."]];

(* \:30c8\:30b0\:30eb\:306b\:51fa\:3059\:58f0: \:30ed\:30fc\:30ab\:30eb (Piper) \:306e\:58f0\:306b\:7d9a\:3051\:3066\:3001SourceVault \:306e Realtime \:5c64\:304c
   \:4f7f\:3048\:308b\:306a\:3089\:30af\:30e9\:30a6\:30c9\:306e\:58f0\:3092 "realtime:<\:58f0>" \:3068\:3057\:3066\:4e26\:3079\:308b\:3002\:30a8\:30f3\:30b8\:30f3\:306e\:5225\:306f\:3053\:306e
   \:63a5\:982d\:8f9e\:3060\:3051\:3067\:8868\:3057\:3001\:72b6\:614b\:306b\:4e8c\:91cd\:306b\:6301\:305f\:306a\:3044\:3002 *)
SlideVoices[] := Module[{local, def},
  local = If[!iSWVoiceLayerQ[], {},
    Module[{vs = Quiet[SourceVault`SourceVaultVoices[]]},
      If[!ListQ[vs], {},
        Select[Lookup[#, "Name", ""] & /@ Select[vs, AssociationQ],
          StringQ[#] && # =!= "" &]]]];
  (* \:65e2\:5b9a\:306e\:58f0 (voice_config.json) \:306f AivisSpeech \:30a8\:30f3\:30b8\:30f3\:672a\:8d77\:52d5\:3060\:3068
     SourceVaultVoices \:306b\:51fa\:306a\:3044\:304c\:3001\:5408\:6210\:6642\:306b\:81ea\:52d5\:8d77\:52d5\:3057\:3066\:89e3\:6c7a\:3059\:308b\:306e\:3067\:9078\:3079\:308b\:3002
     \:4e00\:89a7\:304b\:3089\:843d\:3068\:3059\:3068\:3001\:58f0\:30c8\:30b0\:30eb\:3067\:4e00\:5ea6\:5207\:308a\:66ff\:3048\:305f\:3089\:4e8c\:5ea6\:3068\:623b\:308c\:306a\:304f\:306a\:308b
     (\:5b9f\:6e2c 2026-08-26: \:30a8\:30f3\:30b8\:30f3\:505c\:6b62\:4e2d\:306b\:5207\:66ff \:2192 \:307b\:306e\:304b\:6d88\:5931)\:3002\:5148\:982d\:306b\:8db3\:3059 *)
  def = If[iSWVoiceLayerQ[],
    Quiet @ Check[SourceVault`SourceVaultVoiceDefaultName[], None], None];
  If[StringQ[def] && def =!= "" && !iSWVoiceRealtimeQ[def] && !MemberQ[local, def],
    local = Prepend[local, def]];
  Join[local,
    If[!iSWRealtimeLayerQ[], {},
      ("realtime:" <> #) & /@ Select[Flatten[{$SlideRealtimeVoices}], StringQ]]]];

iSWRealtimeLayerQ[] := Length[DownValues[SourceVault`SourceVaultRealtimeStart]] > 0;

iSWVoiceRealtimeQ[name_] := StringQ[name] && StringStartsQ[name, "realtime:"];

iSWRealtimeVoiceOf[name_] := If[iSWVoiceRealtimeQ[name], StringDrop[name, 9], name];

iSWPlayRealtimeQ[] := $iSWPlayState["Engine"] === "Realtime";

(* \:3044\:307e\:958b\:3044\:3066\:3044\:308b\:30da\:30fc\:30b8\:3092\:8cc7\:6599\:5c64\:3078\:4f1d\:3048\:308b\:3002\:8cea\:554f\:304c\:6765\:305f\:3068\:304d\:306b\:3001\:305d\:306e\:30da\:30fc\:30b8\:306e
   \:5468\:8fba\:304b\:3089\:5148\:306b\:63a2\:305b\:308b\:3088\:3046\:306b\:3059\:308b\:305f\:3081 (SourceVault_talkqa) *)
iSWNoteSlide[n_Integer] := If[
  Length[DownValues[SourceVault`SourceVaultTalkQASetSlide]] > 0,
  Quiet[SourceVault`SourceVaultTalkQASetSlide[n]]];
iSWNoteSlide[_] := Null;

(* \:3053\:306e\:30c7\:30c3\:30ad\:306e QA \:30d1\:30c3\:30af\:3092\:9078\:3076\:3002\:767a\:8868\:3054\:3068\:306b\:8cc7\:6599\:304c\:9055\:3046\:306e\:3067\:3001\:65e2\:5b9a\:30d1\:30c3\:30af\:304c
   \:672a\:8a2d\:5b9a\:306e\:307e\:307e\:4e00\:89a7\:306e\:5148\:982d\:304c\:4f7f\:308f\:308c\:308b\:3068\:3001\:5225\:306e\:767a\:8868\:306e\:8cc7\:6599\:3067\:7b54\:3048\:3066\:3057\:307e\:3046\:3002
   \:30c7\:30c3\:30ad\:304c\:5909\:308f\:3063\:305f\:3068\:304d\:3060\:3051\:9078\:3073\:76f4\:3059 *)
$iSWNotedDeck = None;
iSWNoteDeck[nb_NotebookObject] := Module[{path},
  If[Length[DownValues[SourceVault`SourceVaultTalkQASelectForDeck]] === 0, Return[Null]];
  path = Quiet[NotebookFileName[nb]];
  If[! StringQ[path] || path === $iSWNotedDeck, Return[Null]];
  $iSWNotedDeck = path;
  Quiet[SourceVault`SourceVaultTalkQASelectForDeck[path]]];
iSWNoteDeck[_] := Null;

(* \:8aad\:307f\:7d42\:3048\:3066\:304b\:3089\:6b21\:3078\:9001\:308b\:307e\:3067\:306e\:9593\:3002\:3053\:3053\:304c\:8cea\:554f\:306e\:53d7\:4ed8\:6642\:9593\:306b\:306a\:308b *)
iSWQuestionWindow[] := With[{v = $SlideQuestionSeconds},
  If[NumericQ[v] && N[v] >= 0., N[v], 3.]];

(* \:76f8\:624b\:304c\:8a71\:3057\:3066\:3044\:308b / \:3053\:3061\:3089\:304c\:7b54\:3048\:3066\:3044\:308b\:9593\:306f\:6b21\:3078\:9001\:3089\:306a\:3044 *)
iSWRealtimeBusyQ[rt_Association] :=
  TrueQ[Lookup[rt, "Speaking", False]] ||
    MemberQ[{"listening", "thinking", "answering"}, Lookup[rt, "Mode", ""]];

(* \:7b54\:3048\:3066\:3044\:308b\:6700\:4e2d\:304b (\:3053\:3053\:3092\:6253\:3061\:5207\:308b\:306e\:306f\:5931\:793c) *)
iSWRealtimeAnsweringQ[rt_Association] :=
  TrueQ[Lookup[rt, "Speaking", False]] ||
    MemberQ[{"thinking", "answering"}, Lookup[rt, "Mode", ""]];

iSWInputGate[] := With[{v = $SlideVoiceInputGate},
  If[NumericQ[v] && 0. <= N[v] < 1., N[v], 0.]];

iSWQuestionMax[] := With[{v = $SlideQuestionMaxSeconds},
  If[NumericQ[v] && N[v] > 0., N[v], 60.]];

(* \:8aad\:307f\:4e0a\:3052\:4e2d\:306f\:30de\:30a4\:30af\:3092\:9589\:3058\:308b\:3002\:534a\:4e8c\:91cd\:30b2\:30fc\:30c8\:3060\:3051\:3060\:3068\:3001\:8aad\:307f\:7d42\:3048\:305f\:76f4\:5f8c\:306e
   \:7269\:97f3\:3067\:3082\:30bf\:30fc\:30f3\:304c\:958b\:3044\:3066\:3057\:307e\:3046 *)
iSWRealtimeMic[open_] := If[iSWPlayRealtimeQ[] && iSWRealtimeLayerQ[],
  Quiet[SourceVault`SourceVaultRealtimeMute[! TrueQ[open]]]];

iSWRealtimeStatus[] := If[iSWRealtimeLayerQ[],
  With[{s = Quiet[SourceVault`SourceVaultRealtimeStatus[]]},
    If[AssociationQ[s], s, <||>]], <||>];

iSWFailureText[f_] := If[FailureQ[f],
  ToString[Lookup[Last[f], "MessageTemplate", ToString[f]]], ToString[f]];

(* \:767a\:8868\:7528\:306e\:30bb\:30c3\:30b7\:30e7\:30f3\:6307\:793a\:3002\:539f\:7a3f\:306f 1 \:679a\:305a\:3064\:6e21\:3059\:306e\:3067\:3001\:3053\:3053\:3067\:306f\:5f79\:5272\:3060\:3051\:3092\:8a00\:3046 *)
iSWRealtimeSessionInstructions[] := iSL[
  "\:3042\:306a\:305f\:306f\:767a\:8868\:306e\:9032\:884c\:5f79\:3067\:3059\:3002\:51fa\:529b\:306f\:5fc5\:305a\:65e5\:672c\:8a9e\:3067\:3059\:3002\:76f8\:624b\:304c\:82f1\:8a9e\:306a\:3069\:4ed6\:306e\:8a00\:8a9e\:3067\:8a71\:3057\:3066\:3082\:3001\:65e5\:672c\:8a9e\:3067\:7b54\:3048\:3066\:304f\:3060\:3055\:3044\:3002
\:539f\:7a3f\:3092\:6e21\:3055\:308c\:305f\:3068\:304d\:306f\:3001\:305d\:306e\:539f\:7a3f\:306e\:5185\:5bb9\:3060\:3051\:3092\:81ea\:7136\:306a\:767a\:8868\:53e3\:8abf\:3067\:8a71\:3057\:307e\:3059\:3002\:539f\:7a3f\:306b\:7121\:3044\:4e8b\:5b9f\:306f\:8db3\:3057\:307e\:305b\:3093\:3002
\:8cea\:554f\:3055\:308c\:305f\:3068\:304d\:306f\:539f\:7a3f\:306b\:7e1b\:3089\:308c\:307e\:305b\:3093\:3002\:30b9\:30e9\:30a4\:30c9\:306e\:5185\:5bb9\:3084\:3042\:306a\:305f\:306e\:77e5\:8b58\:3092\:3082\:3068\:306b\:3001\:77ed\:304f\:5206\:304b\:308a\:3084\:3059\:304f\:7b54\:3048\:3066\:304f\:3060\:3055\:3044\:3002\:300c\:539f\:7a3f\:304c\:7121\:3044\:306e\:3067\:7b54\:3048\:3089\:308c\:307e\:305b\:3093\:300d\:3068\:306f\:8a00\:308f\:306a\:3044\:3053\:3068\:3002\:5206\:304b\:3089\:306a\:3044\:3053\:3068\:306f\:6b63\:76f4\:306b\:5206\:304b\:3089\:306a\:3044\:3068\:8a00\:3063\:3066\:304f\:3060\:3055\:3044\:3002
\:76f8\:624b\:304c\:8a71\:3057\:7d42\:3048\:308b\:307e\:3067\:5f85\:3061\:307e\:3059\:3002\:8a00\:8449\:304c\:5c11\:3057\:9014\:5207\:308c\:305f\:3060\:3051\:3067\:5272\:308a\:8fbc\:307e\:306a\:3044\:3067\:304f\:3060\:3055\:3044\:3002\:805e\:304d\:53d6\:308c\:306a\:304b\:3063\:305f\:3068\:304d\:306f\:63a8\:6e2c\:3067\:7b54\:3048\:305a\:3001\:300c\:3059\:307f\:307e\:305b\:3093\:3001\:3082\:3046\:4e00\:5ea6\:304a\:9858\:3044\:3057\:307e\:3059\:300d\:3068\:77ed\:304f\:805e\:304d\:8fd4\:3057\:3066\:304f\:3060\:3055\:3044\:3002
\:8a71\:3057\:65b9\:3084\:9032\:3081\:65b9\:306b\:3064\:3044\:3066\:306e\:6307\:793a\:306f\:58f0\:306b\:51fa\:3057\:307e\:305b\:3093\:3002
\:30b9\:30e9\:30a4\:30c9\:306e\:8868\:793a\:306b\:3064\:3044\:3066\:306e\:4f9d\:983c (\:6b21/\:524d/\:6700\:521d/\:6700\:5f8c/\:4f55\:679a\:76ee/\:7279\:5b9a\:306e\:5185\:5bb9\:306e\:30b9\:30e9\:30a4\:30c9) \:306b\:306f\:3001\:7b54\:3048\:308b\:524d\:306b\:5fc5\:305a show_slide \:3092\:547c\:3093\:3067\:304f\:3060\:3055\:3044\:3002\:547c\:3070\:305a\:306b\:300c\:623b\:3057\:307e\:3059\:300d\:3068\:3060\:3051\:8a00\:3063\:3066\:306f\:3044\:3051\:307e\:305b\:3093\:3002",
  "You host a slide talk.\nWhen you are given a script, speak only what that script says, in a natural presenting voice, and add no facts of your own.\nWhen you are asked a question, you are not limited to the script: answer briefly from the slides and from what you know. Never say you cannot answer because there is no script. Say plainly when you do not know.\nWait until the person has finished speaking; do not cut in on a short pause. If you did not catch it, ask them to repeat instead of guessing.\nNever say the directions about how to speak out loud.\nWhen asked to change which slide is shown (next / previous / first / last / a number / one about something), call show_slide before answering."];

(* \:9078\:3093\:3060\:58f0\:306e\:30a8\:30f3\:30b8\:30f3\:304c\:4f7f\:3048\:308b\:72b6\:614b\:304b *)
iSWEngineReadyQ[voice_] := If[iSWVoiceRealtimeQ[voice],
  iSWRealtimeLayerQ[] && With[{r = Quiet[SourceVault`SourceVaultRealtimeRuntime[]]},
    AssociationQ[r] && r["Status"] === "OK"],
  iSWVoiceReadyQ[]];

(* \:518d\:751f\:3092\:59cb\:3081\:308b\:524d\:306b\:3001\:9078\:3093\:3060\:30ed\:30fc\:30ab\:30eb\:306e\:58f0\:3092\:5b9f\:969b\:306b\:4f7f\:3048\:308b\:72b6\:614b\:306b\:3059\:308b\:3002
   AivisSpeech \:306e\:58f0\:306f\:30a8\:30f3\:30b8\:30f3\:672a\:8d77\:52d5\:3060\:3068\:89e3\:6c7a\:3067\:304d\:306a\:3044\:306e\:3067\:3001\:3053\:3053\:3067\:4e00\:5ea6\:3060\:3051
   \:8d77\:52d5\:3092\:5f85\:3064 (\:521d\:56de 1\:301c2 \:5206)\:3002\:518d\:751f\:4e2d\:306e\:30bf\:30b9\:30af\:5185\:3067\:5f85\:305f\:3055\:308c\:3066 1 \:679a\:76ee\:304c
   \:300c\:5408\:6210\:5931\:6557\:300d\:306b\:306a\:308b\:4e8b\:6545 (\:5b9f\:6e2c 2026-08-26) \:3092\:9632\:3050\:3002 *)
iSWEnsureLocalVoice[nb_, voice_] := Module[{v},
  If[iSWVoiceRealtimeQ[voice] || !StringQ[voice], Return[True]];
  v = Quiet[SourceVault`SourceVaultVoice[voice]];
  If[AssociationQ[v], Return[True]];
  iSWStatus[nb, iSL["\:97f3\:58f0\:30a8\:30f3\:30b8\:30f3\:3092\:8d77\:52d5\:3057\:3066\:3044\:307e\:3059 (\:521d\:56de\:306f 1\:301c2 \:5206\:304b\:304b\:308a\:307e\:3059)...",
    "Starting the speech engine (the first start can take 1-2 min)..."]];
  Quiet @ Check[
    If[Length[DownValues[SourceVault`SourceVaultVoiceAivisEnsure]] > 0,
      SourceVault`SourceVaultVoiceAivisEnsure[]], False];
  v = Quiet[SourceVault`SourceVaultVoice[voice]];
  iSWStatusClearLater[nb];
  AssociationQ[v]];

iSWEnsureVoiceFailDialog[voice_] := MessageDialog[iSL[
  "\:58f0\:300c" <> ToString[voice] <> "\:300d\:3092\:4f7f\:3048\:308b\:72b6\:614b\:306b\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f (\:97f3\:58f0\:30a8\:30f3\:30b8\:30f3\:304c\:8d77\:52d5\:3057\:3066\:3044\:306a\:3044?)\:3002SourceVaultVoiceAivisStatus[] \:3092\:78ba\:8a8d\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
  "Could not make the voice \"" <> ToString[voice] <>
    "\" available (speech engine down?). Check SourceVaultVoiceAivisStatus[]."]];

iSWEngineHint[voice_] := If[iSWVoiceRealtimeQ[voice],
  With[{r = Quiet[SourceVault`SourceVaultRealtimeRuntime[]]},
    If[AssociationQ[r] && StringQ[r["Hint"]], r["Hint"],
      iSL["SourceVault_realtime.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093 (SourceVault \:3092\:30ed\:30fc\:30c9\:3057\:3066\:304f\:3060\:3055\:3044)\:3002",
        "SourceVault_realtime.wl is not loaded (load SourceVault first)."]]],
  iSWVoiceHint[]];

iSWVoiceName[] := Module[{vs, def},
  If[StringQ[$SlideVoice] && $SlideVoice =!= "", Return[$SlideVoice]];
  vs = SlideVoices[];
  (* voice \:5c64\:306e\:65e2\:5b9a\:58f0 (voice_config.json / $SourceVaultVoiceDefault) \:3092\:5c0a\:91cd\:3059\:308b\:3002
     \:4e00\:89a7\:306b\:7121\:304f\:3066\:3082\:305d\:306e\:540d\:524d\:3092\:8fd4\:3059: AivisSpeech \:306e\:58f0\:306f\:30a8\:30f3\:30b8\:30f3\:672a\:8d77\:52d5\:3060\:3068\:4e00\:89a7\:306b
     \:51fa\:306a\:3044\:304c\:3001SourceVaultVoiceSpeak \:304c\:5408\:6210\:6642\:306b\:81ea\:52d5\:8d77\:52d5\:3057\:3066\:89e3\:6c7a\:3059\:308b *)
  def = If[iSWVoiceLayerQ[],
    Quiet @ Check[SourceVault`SourceVaultVoiceDefaultName[], None], None];
  If[StringQ[def] && def =!= "",
    Return[SelectFirst[vs, # === def || StringStartsQ[#, def] &, def]]];
  If[vs === {}, None, First[vs]]];

(* \:8868\:793a\:5c02\:7528\:306e\:77ed\:7e2e\:540d\:3002AivisSpeech \:306e\:8a71\:8005\:540d\:306f\:300c\:307b\:306e\:304b(~\:73fe\:5b9f20\:4ee3\:5973\:5b50AI...)\:300d\:306e
   \:3088\:3046\:306b\:62ec\:5f27\:66f8\:304d\:306e\:6b63\:5f0f\:540d\:304c\:9577\:3044\:306e\:3067\:3001\:6700\:521d\:306e\:62ec\:5f27\:4ee5\:964d\:3092\:843d\:3068\:3057\:3066\:540d\:524d\:3060\:3051\:306b\:3059\:308b
   (\:5408\:6210\:3084 $SlideVoice \:306b\:306f\:5e38\:306b\:5b8c\:5168\:540d\:3092\:4f7f\:3046\:3002\:3053\:3053\:306f\:898b\:305f\:76ee\:3060\:3051)\:3002 *)
iSWVoiceShortName[n_String] := Module[{base},
  base = StringTrim[First[StringSplit[n, "(" | "\:ff08", 2]]];
  If[base === "", base = n];
  If[StringLength[base] > 16, StringTake[base, 15] <> "\[Ellipsis]", base]];

iSWRefreshVoiceLabel[] := ($iSWVoiceLabel = "V: " <>
  With[{n = iSWVoiceName[]},
    If[StringQ[n], iSWVoiceShortName[n], iSL["\:672a\:5c0e\:5165", "not installed"]]]);

SlideCycleVoice[] := Module[{vs, cur, idx},
  vs = SlideVoices[];
  If[vs === {},
    iSWRefreshVoiceLabel[];
    MessageDialog[iSL["\:4f7f\:3048\:308b\:58f0\:304c\:3042\:308a\:307e\:305b\:3093\:3002\n", "No voice model is installed.\n"] <>
      iSWVoiceHint[]];
    Return[$SlideVoice]];
  cur = iSWVoiceName[];
  idx = With[{p = Position[vs, cur]}, If[Length[p] >= 1, p[[1, 1]], 0]];
  $SlideVoice = vs[[Mod[idx, Length[vs]] + 1]];
  iSWRefreshVoiceLabel[];
  If[$iSWPlayState["Status"] =!= "Playing", $iSWPlayState["Voice"] = $SlideVoice];
  $SlideVoice];

(* ---- \:539f\:7a3f (talk md) -> \:30b9\:30e9\:30a4\:30c9\:756a\:53f7\:3054\:3068\:306e\:8aad\:307f\:4e0a\:3052\:30c6\:30ad\:30b9\:30c8 ---- *)

(* \:8aad\:307f\:4e0a\:3052\:306b\:8a18\:53f7\:3092\:6df7\:305c\:306a\:3044: markdown \:306e\:98fe\:308a\:3060\:3051\:843d\:3068\:3059 (\:672c\:6587\:306f\:89e6\:3089\:306a\:3044) *)
iSWVoicePlainText[s_String] := Module[{t},
  t = StringReplace[s, "\r\n" -> "\n"];
  t = StringReplace[t, {
    RegularExpression["!?\\[([^\\]]*)\\]\\([^)]*\\)"] -> "$1",
    RegularExpression["(?m)^[ \t]*[-*+][ \t]+"] -> "",
    RegularExpression["(?m)^[ \t]*#+[ \t]*"] -> "",
    "**" -> "", "`" -> "", "~~" -> ""}];
  StringTrim[t]];

iSWVoicePlainText[x_] := iSWVoicePlainText[ToString[x]];

(* ---- \:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb\:304c\:539f\:7a3f\:306e\:6b63 (v1.12) ------------------------------
   \:518d\:751f\:30fb\:898b\:7a4d\:30fb\:767b\:9332\:306f\:3001\:307e\:305a\:30b9\:30e9\:30a4\:30c9\:5185\:306e SlideTalk \:30bb\:30eb\:304b\:3089\:539f\:7a3f\:3092\:7d44\:307f\:7acb\:3066\:308b\:3002
   <deck>_talk.md \:306f\:30c8\:30fc\:30af\:30bb\:30eb\:306e\:7121\:3044\:65e7\:30c7\:30c3\:30ad\:7528\:306e\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:306b\:843d\:3068\:3059
   (\:5225\:30d5\:30a1\:30a4\:30eb\:3092\:4f5c\:3089\:306a\:304f\:3066\:3082\:30c7\:30c3\:30ad\:3060\:3051\:3067\:767a\:8868\:304c\:5b8c\:7d50\:3059\:308b)\:3002
   \:524d\:7f6e\:304d (\:6700\:521d\:306e navbar \:3088\:308a\:524d) \:306e SlideTalk \:30bb\:30eb\:306f Opening \:3068\:3057\:3066\:8aad\:3080\:3002
   \:30c7\:30c3\:30ad\:5358\:4f4d\:306e\:30e1\:30bf (SlideURL / Aliases / PrivacyLevel \:306a\:3069) \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e
   TaggingRules "SWTalkMeta" \:306b\:6301\:3061 (SlideTalkMeta \:3067\:8aad\:307f\:66f8\:304d)\:3001\:65e2\:5b58\:306e
   _talk.md \:304c\:3042\:308c\:3070 front matter \:304c\:4e0d\:8db3\:5206\:3092\:88dc\:3046 (TaggingRules \:304c\:512a\:5148)\:3002 *)

$iSWTalkMetaKeys = {"Title", "Aliases", "Event", "Author", "Date", "SlideURL",
  "Language", "NarrationInstructions", "SecondsPerSlide", "PrivacyLevel"};

iSWTalkMetaNormalize[v_] := KeyTake[
  Replace[v, {a_Association :> a, l : {___Rule} :> Association[l], _ -> <||>}],
  $iSWTalkMetaKeys];

iSWTalkStoredMeta[nb_NotebookObject] :=
  iSWTalkMetaNormalize[Quiet[CurrentValue[nb, {TaggingRules, "SWTalkMeta"}]]];

(* \:4fdd\:5b58\:6e08\:307f\:30d5\:30a1\:30a4\:30eb (Notebook \:5f0f) \:306e TaggingRules \:304b\:3089\:3002headless \:306e\:767b\:9332\:7d4c\:8def\:7528 *)
iSWTalkMetaFromNotebookExpr[nbExpr_Notebook] := Module[{tr},
  tr = Replace[Quiet[TaggingRules /. Rest[List @@ nbExpr]],
    Except[{___Rule} | _Association] -> {}];
  iSWTalkMetaNormalize[Quiet["SWTalkMeta" /. Normal[tr]]]];

(* _talk.md \:306e front matter \:304b\:3089\:306e\:88dc\:5b8c (\:7a7a\:5024\:306f\:843d\:3068\:3057\:3066\:65e2\:5b9a\:306b\:8b72\:308b) *)
iSWTalkFileMeta[talkPath_] := Module[{talk},
  If[!StringQ[talkPath] || !FileExistsQ[talkPath], Return[<||>]];
  talk = Quiet[SlideTalkFromMarkdown[File[talkPath]]];
  If[!AssociationQ[talk], Return[<||>]];
  DeleteCases[KeyTake[talk, $iSWTalkMetaKeys], "" | {}]];

SlideTalkMeta[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideTalkMeta[nb],
    Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>]]];

SlideTalkMeta[nb_NotebookObject] :=
  Join[iSWTalkFileMeta[SlideTalkFile[nb]], iSWTalkStoredMeta[nb]];

SlideTalkMeta[nb_NotebookObject, rules__Rule] := Module[{stored},
  stored = Join[iSWTalkStoredMeta[nb],
    KeyTake[Association[rules], $iSWTalkMetaKeys]];
  CurrentValue[nb, {TaggingRules, "SWTalkMeta"}] = Normal[stored];
  stored];

(* \:30c7\:30c3\:30ad (path | Notebook \:5f0f) \:3068\:30e1\:30bf\:304b\:3089\:30c8\:30fc\:30af\:9023\:60f3\:3092\:7d44\:307f\:7acb\:3066\:308b\:7d14\:95a2\:6570\:3002
   \:30c8\:30fc\:30af\:30bb\:30eb\:304c 1 \:3064\:3082\:7121\:3051\:308c\:3070 $Failed (\:547c\:3073\:51fa\:3057\:5074\:304c _talk.md \:3078\:843d\:3068\:3059)\:3002 *)
iSWTalkFromCellsCore[src_, meta_Association, deckFile_String, fallbackTitle_String] :=
  Module[{outline, talks, opening, slides, rate},
    outline = iTalkDeckOutline[src];
    If[outline === $Failed, Return[$Failed]];
    talks = Lookup[outline, "Talks", {}];
    If[!AnyTrue[talks, StringQ[#] && StringTrim[#] =!= "" &], Return[$Failed]];
    opening = StringTrim[StringRiffle[
      Cases[Lookup[outline, "Prelude", {}],
        c : Cell[_, "SlideTalk", ___] :> iCellText[c], {1}], "\n"]];
    rate = iSWTalkCharRate[];
    slides = MapThread[
      Function[{i, title, talk},
        If[StringQ[talk] && StringTrim[talk] =!= "",
          <|"Slide" -> i, "Title" -> title,
            "Seconds" -> Max[10., N[Round[StringLength[StringTrim[talk]]/rate]]],
            "Text" -> StringTrim[talk]|>,
          Nothing]],
      {Range[outline["Count"]], outline["Titles"], talks}];
    <|"Title" -> Lookup[meta, "Title", fallbackTitle],
      "Aliases" -> Flatten[{Lookup[meta, "Aliases", {}]}],
      "Event" -> Lookup[meta, "Event", ""],
      "Author" -> Lookup[meta, "Author", ""],
      "Date" -> Lookup[meta, "Date", ""],
      "SlideURL" -> Lookup[meta, "SlideURL", ""],
      "Deck" -> deckFile,
      "Language" -> Lookup[meta, "Language", "Japanese"],
      "NarrationInstructions" -> Lookup[meta, "NarrationInstructions", ""],
      "SecondsPerSlide" -> Lookup[meta, "SecondsPerSlide", $SlideTalkSecondsPerSlide],
      "PrivacyLevel" -> Lookup[meta, "PrivacyLevel", 0.],
      "Opening" -> opening, "Closing" -> "",
      "Slides" -> slides,
      "TalkSource" -> "Cells"|>];

(* \:4fdd\:5b58\:6e08\:307f path \:306f\:30d5\:30a1\:30a4\:30eb\:65e5\:4ed8+\:30e1\:30bf\:3067\:30ad\:30e3\:30c3\:30b7\:30e5 (\:518d\:751f\:30fb\:898b\:7a4d\:30fb\:60c5\:5831\:304c\:7e70\:308a\:8fd4\:3057
   \:547c\:3076\:305f\:3073\:306b\:6570\:5341 MB \:306e\:30c7\:30c3\:30ad\:3092 Get \:3057\:76f4\:3055\:306a\:3044\:305f\:3081)\:3002$Failed \:3082\:8a18\:61b6\:3059\:308b *)
$iSWTalkCellCache = <||>;

iSWTalkFromCellsCached[path_String, meta_Association, deckFile_String, fallbackTitle_String] :=
  Module[{date, hash, entry, talk},
    date = Quiet[FileDate[path]];
    hash = Hash[{meta, deckFile}];
    entry = Lookup[$iSWTalkCellCache, path, None];
    If[AssociationQ[entry] && entry["Date"] === date && entry["Hash"] === hash,
      Return[entry["Talk"]]];
    talk = iSWTalkFromCellsCore[path, meta, deckFile, fallbackTitle];
    $iSWTalkCellCache[path] = <|"Date" -> date, "Hash" -> hash, "Talk" -> talk|>;
    talk];

iSWTalkFromCells[nb_NotebookObject] := Module[{src, meta, fn, deckFile, base},
  src = iSWDeckSource[nb];
  meta = SlideTalkMeta[nb];
  fn = Quiet[NotebookFileName[nb]];
  deckFile = If[StringQ[fn], fn, ""];
  base = Last[iSWDeckBaseName[nb]];
  If[StringQ[src],
    iSWTalkFromCellsCached[src, meta, deckFile, base],
    iSWTalkFromCellsCore[src, meta, deckFile, base]]];

(* \:4fdd\:5b58\:6e08\:307f .nb path \:304b\:3089 (headless / SlideDeckRegister[path] \:7528)\:3002
   TaggingRules \:306f\:30d5\:30a1\:30a4\:30eb\:306e Notebook \:5f0f\:304b\:3089\:8aad\:3080 *)
iSWTalkFromCellsPath[path_String] := Module[{nbExpr, meta},
  If[!FileExistsQ[path], Return[$Failed]];
  nbExpr = iGetNotebook[path];
  If[nbExpr === $Failed || Head[nbExpr] =!= Notebook, Return[$Failed]];
  meta = Join[iSWTalkFileMeta[SlideTalkFile[path]],
    iSWTalkMetaFromNotebookExpr[nbExpr]];
  iSWTalkFromCellsCore[nbExpr, meta, path, FileBaseName[path]]];

(* \:539f\:7a3f\:306e\:89e3\:6c7a: \:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb > <deck>_talk.md > $Failed *)
iSWTalkResolve[nb_NotebookObject] := Module[{talk, path},
  talk = iSWTalkFromCells[nb];
  If[AssociationQ[talk], Return[talk]];
  path = SlideTalkFile[nb];
  If[!StringQ[path] || !FileExistsQ[path], Return[$Failed]];
  talk = Quiet[SlideTalkFromMarkdown[File[path]]];
  If[AssociationQ[talk], Append[talk, "TalkSource" -> "File"], $Failed]];

iSWVoiceTexts[nb_NotebookObject] := iSWVoiceTextsFromTalk[iSWTalkResolve[nb]];

iSWVoiceTextsFromFile[path_] := Module[{talk},
  If[!StringQ[path] || !FileExistsQ[path], Return[$Failed]];
  talk = Quiet[SlideTalkFromMarkdown[File[path]]];
  iSWVoiceTextsFromTalk[talk]];

iSWVoiceTextsFromTalk[talk_Association] := Module[
  {slides, texts = <||>, keys, op, cl},
  slides = Select[Lookup[talk, "Slides", {}], AssociationQ];
  Do[
    With[{k = Lookup[s, "Slide", None], t = iSWVoicePlainText[Lookup[s, "Text", ""]]},
      If[IntegerQ[k] && k >= 1 && t =!= "",
        texts[k] = If[KeyExistsQ[texts, k], texts[k] <> "\n" <> t, t]]],
    {s, slides}];
  If[Length[texts] === 0, Return[$Failed]];
  keys = Sort[Keys[texts]];
  op = iSWVoicePlainText[Lookup[talk, "Opening", ""]];
  cl = iSWVoicePlainText[Lookup[talk, "Closing", ""]];
  If[op =!= "", texts[First[keys]] = op <> "\n" <> texts[First[keys]]];
  If[cl =!= "", texts[Last[keys]] = texts[Last[keys]] <> "\n" <> cl];
  texts];

iSWVoiceTextsFromTalk[_] := $Failed;

(* ---- \:5408\:6210 (\:30ad\:30e3\:30c3\:30b7\:30e5\:4ed8\:304d) ---- *)

iSWVoiceCacheDir[nb_] := Module[{dir, base},
  {dir, base} = iSWDeckBaseName[nb];
  FileNameJoin[{dir, base <> "_voice"}]];

iSWVoiceCacheFile[dir_String, n_Integer, voice_String, text_String] :=
  FileNameJoin[{dir,
    "slide-" <> IntegerString[n, 10, 3] <> "-" <>
      StringReplace[voice, Except[WordCharacter | "-" | "_"] -> "_"] <> "-" <>
      StringTake[Hash[{voice, text}, "SHA256", "HexString"], 8] <> ".wav"}];

(* \:540c\:3058\:58f0 + \:540c\:3058\:539f\:7a3f\:306a\:3089\:518d\:5408\:6210\:3057\:306a\:3044\:3002\:539f\:7a3f\:3092\:76f4\:305b\:3070\:30cf\:30c3\:30b7\:30e5\:304c\:5909\:308f\:308b\:306e\:3067\:4f5c\:308a\:76f4\:3059 *)
iSWVoiceFileFor[nb_, n_Integer, text_String] :=
  iSWVoiceFileInDir[iSWVoiceCacheDir[nb], n, text];

iSWVoiceFileInDir[dir_String, n_Integer, text_String] := Module[{voice, file, res},
  voice = iSWVoiceName[];
  If[!StringQ[voice], Return[$Failed]];
  If[!DirectoryQ[dir],
    Quiet[CreateDirectory[dir, CreateIntermediateDirectories -> True]]];
  file = iSWVoiceCacheFile[dir, n, voice, text];
  If[FileExistsQ[file] && TrueQ[Quiet[FileByteCount[file]] > 1000], Return[file]];
  res = Quiet[SourceVault`SourceVaultVoiceSpeak[text,
    "Voice" -> voice, "OutputFile" -> file]];
  If[!FileExistsQ[file],
    $iSWPlayState["LastFailure"] = res;
    Return[$Failed]];
  file];

(* ---- \:30b9\:30e9\:30a4\:30c9\:4f4d\:7f6e (FE \:306e SlideShow \:30ab\:30a6\:30f3\:30bf) ---- *)

iSWFEInt[v_] := Which[
  IntegerQ[v], v,
  StringQ[v] && StringMatchQ[StringTrim[v], DigitCharacter ..],
    ToExpression[StringTrim[v]],
  True, None];

iSWSlideNumberFE[nb_] :=
  iSWFEInt[Quiet[CurrentValue[nb, {"CounterValue", "SlideShowNavigationBar"}]]];

iSWSlideCountFE[nb_] :=
  iSWFEInt[Quiet[CurrentValue[nb, {"MaxCounterValue", "SlideShowNavigationBar"}]]];

iSWSlideShowQ[nb_] := Quiet[CurrentValue[nb, ScreenStyleEnvironment]] === "SlideShow";

(* \:3044\:307e\:753b\:9762\:306b\:51fa\:3066\:3044\:308b\:30da\:30fc\:30b8\:756a\:53f7\:3002\:767a\:8868\:8005\:304c\:624b\:3067\:9001\:308b\:3053\:3068\:3082\:3042\:308b\:306e\:3067\:3001
   \:899a\:3048\:3066\:3044\:308b\:5024\:3067\:306f\:306a\:304f\:30d5\:30ed\:30f3\:30c8\:30a8\:30f3\:30c9\:306b\:8a0a\:304f *)
SlideCurrentNumber[] := With[{nb = iSWSlideControlNotebook[]},
  If[Head[nb] === NotebookObject, SlideCurrentNumber[nb], Missing["NoNotebook"]]];

SlideCurrentNumber[nb_NotebookObject] := Module[{n, total},
  n = iSWSlideNumberFE[nb];
  If[! IntegerQ[n], Return[Missing["NoCounter"]]];
  total = iSWSlideCountOf[nb];
  If[IntegerQ[total] && total > 0 && n > total, n = total];
  If[n < 1, Missing["NoCounter"], n]];
SlideCurrentNumber[_] := Missing["NoNotebook"];

(* SlideShow \:30c4\:30fc\:30eb\:30d0\:30fc\:306e\:6b21\:30b9\:30e9\:30a4\:30c9\:30dc\:30bf\:30f3\:3068\:540c\:3058 FE \:30c8\:30fc\:30af\:30f3 *)
iSWSlideGoNext[nb_] := Quiet[FrontEndTokenExecute[nb, "ScrollPageNext"]];

(* ---- \:7d22\:5f15 (\:982d\:51fa\:3057 + \:97f3\:58f0\:8a66\:8074) ---- *)

$iSWPreviewStream = None;

iSWPreviewRelease[] := (
  If[Head[$iSWPreviewStream] === AudioStream,
    Quiet[AudioStop[$iSWPreviewStream]];
    Quiet[RemoveAudioStream[$iSWPreviewStream]]];
  $iSWPreviewStream = None);

(* 1 \:679a\:3060\:3051\:58f0\:306b\:51fa\:3059\:3002\:7d22\:5f15\:306e Play \:3068\:3001\:624b\:3067\:547c\:3076\:3068\:304d\:306e\:5165\:53e3 *)
SlideSpeakSlide[n_Integer] := With[{nb = iSWSlideControlNotebook[]},
  If[Head[nb] === NotebookObject, SlideSpeakSlide[nb, n], $Failed]];

SlideSpeakSlide[nb_NotebookObject, n_Integer] := Module[
  {texts, text, voice, file, audio},
  texts = iSWVoiceTexts[nb];
  If[texts === $Failed,
    MessageDialog[iSL["\:767a\:8868\:306e\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093 (\:30c8\:30fc\:30af\:30bb\:30eb\:3082 _talk.md \:3082\:7121\:3057)\:3002",
      "No narration (neither talk cells nor _talk.md)."]];
    Return[$Failed]];
  text = ToString[Lookup[texts, n, ""]];
  If[StringTrim[text] === "",
    iSWStatus[nb, iSL["\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:306f\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093", "No narration for this slide"]];
    iSWStatusClearLater[nb];
    Return[None]];
  voice = iSWVoiceName[];
  If[iSWVoiceRealtimeQ[voice],
    (* \:30af\:30e9\:30a6\:30c9\:306e\:58f0: \:52d5\:3044\:3066\:3044\:308b\:97f3\:58f0\:4f1a\:8a71\:306b\:8aad\:307e\:305b\:308b *)
    If[! iSWRealtimeRunningQ[],
      MessageDialog[iSL["\:5148\:306b\:300c\:5fdc\:7b54on\:300d\:3067\:97f3\:58f0\:4f1a\:8a71\:3092\:59cb\:3081\:3066\:304f\:3060\:3055\:3044 (realtime: \:306e\:58f0\:306f\:305d\:3053\:3067\:9cf4\:308a\:307e\:3059)\:3002",
        "Turn voice answering on first: a realtime voice speaks through that session."]];
      Return[$Failed]];
    Quiet[SourceVault`SourceVaultRealtimeNarrate["preview-" <> ToString[n], text,
      "Heading" -> (iSL["\:30b9\:30e9\:30a4\:30c9 ", "Slide "] <> ToString[n]),
      "Instructions" -> iSWTalkNarrationInstructions[nb]]];
    Return[<|"Status" -> "Speaking", "Slide" -> n, "Voice" -> voice|>]];
  (* \:30ed\:30fc\:30ab\:30eb\:306e\:58f0: \:5408\:6210 (\:30ad\:30e3\:30c3\:30b7\:30e5\:6e08\:307f\:306a\:3089\:5373) \:3057\:3066\:9cf4\:3089\:3059 *)
  If[!iSWEnsureLocalVoice[nb, voice],
    iSWEnsureVoiceFailDialog[voice];
    Return[$Failed]];
  iSWStatus[nb, iSL["\:97f3\:58f0\:3092\:7528\:610f\:4e2d: \:30b9\:30e9\:30a4\:30c9 ", "Preparing audio: slide "] <> ToString[n]];
  file = iSWVoiceFileFor[nb, n, text];
  If[file === $Failed,
    iSWStatus[nb, iSL["\:97f3\:58f0\:5408\:6210\:306b\:5931\:6557\:3057\:307e\:3057\:305f", "Speech synthesis failed"]];
    iSWStatusClearLater[nb];
    Return[$Failed]];
  audio = Quiet[Audio[file]];
  If[! TrueQ[Quiet[AudioQ[audio]]], Return[$Failed]];
  iSWPreviewRelease[];
  $iSWPreviewStream = Quiet[AudioPlay[audio]];
  iSWStatus[nb, iSL["\:518d\:751f\:4e2d: \:30b9\:30e9\:30a4\:30c9 ", "Playing: slide "] <> ToString[n]];
  iSWStatusClearLater[nb];
  <|"Status" -> "Playing", "Slide" -> n, "File" -> file|>];

(* Dataset \:306e\:30bb\:30eb\:306b\:306f\:5c0f\:3055\:306a\:30bf\:30b0\:3060\:3051\:3092\:7f6e\:304f\:3002LeafCount \:304c 32 \:3092\:8d85\:3048\:308b\:3068
   Dataset \:306f\:4e2d\:8eab\:3092\:63cf\:304b\:305a\:306b "..." \:306b\:3057\:3066\:3057\:307e\:3044\:3001\:30dc\:30bf\:30f3\:304c\:62bc\:305b\:306a\:304f\:306a\:308b *)
iSWIndexDisplay[iSWUIGo[nb_, n_], ___] := Button[
  Style[iSL["Slide", "Slide"], 9, GrayLevel[0.25]],
  SlideShowSlide[nb, n]; SetSelectedNotebook[nb],
  Appearance -> "Palette", ImageSize -> {52, 20}, Method -> "Queued"];

iSWIndexDisplay[iSWUIPlay[nb_, n_], ___] := Button[
  Style[iSL["Audio", "Audio"], 9, GrayLevel[0.25]],
  SlideSpeakSlide[nb, n],
  Appearance -> "Palette", ImageSize -> {52, 20}, Method -> "Queued"];

iSWIndexDisplay[x_, ___] := x;

Options[SlideIndex] = {"Voice" -> Automatic, "Questions" -> False};

SlideIndex[opts : OptionsPattern[]] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideIndex[nb, opts],
    Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>]]];

SlideIndex[nb_NotebookObject, opts : OptionsPattern[]] := Module[
  {est, rows, titles, talk, planned, gap, question, running, table},
  est = SlideTalkDuration[nb, opts];
  If[! AssociationQ[est], Return[est]];
  rows = Lookup[est, "Rows", {}];
  titles = iSWSlideTitles[nb];
  talk = iSWTalkResolve[nb];
  planned = If[AssociationQ[talk],
    Association[Table[
      Lookup[sl, "Slide", 0] -> With[{v = Lookup[sl, "Seconds", Null]},
        If[NumericQ[v], Round[N[v]], 0]],
      {sl, Select[Lookup[talk, "Slides", {}], AssociationQ]}]], <||>];
  gap = With[{g = $SlideVoiceGap}, If[NumericQ[g], N[g], 0.8]];
  question = If[TrueQ[OptionValue["Questions"]] &&
      iSWVoiceRealtimeQ[Replace[OptionValue["Voice"], Automatic :> iSWVoiceName[]]],
    iSWQuestionWindow[], 0.];
  running = 0.;
  table = Table[
    Module[{r = rows[[i]], n},
      n = r["Slide"];
      running = running + r["Seconds"] + gap + question;
      <|"Nu" -> n,
        "Show" -> iSWUIGo[nb, n],
        "Title" -> If[1 <= n <= Length[titles], titles[[n]], ""],
        "Play" -> iSWUIPlay[nb, n],
        "Chars" -> r["Characters"],
        "Time" -> Round[r["Seconds"]],
        "Plan" -> Lookup[planned, n, 0],
        "Total" -> iSWFormatDuration[running],
        "Src" -> Switch[r["Source"],
          "Measured", iSL["\:5b9f\:6e2c", "measured"],
          "Silent", iSL["\:539f\:7a3f\:306a\:3057", "no script"],
          _, iSL["\:898b\:7a4d", "estimate"]]|>],
    {i, Length[rows]}];
  (* ItemSize \:306f\:6307\:5b9a\:3057\:306a\:3044: \:5217\:5e45\:3092\:6e21\:3059\:3068\:8868\:304c\:6a2a\:306b 4 \:500d\:4f38\:3073\:308b (\:5b9f\:6e2c) *)
  Dataset[table, ItemDisplayFunction -> (iSWIndexDisplay[#] &),
    HeaderStyle -> {Bold, 10}]];

(* ---- \:60c5\:5831\:30a6\:30a4\:30f3\:30c9\:30a6 (\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:60c5\:5831\:300d) ---- *)

iSWInfoRows[nb_] := Module[{est, count, talkPath, talk, voice, engine, rt, src},
  count = iSWSlideCountOf[nb];
  talkPath = SlideTalkFile[nb];
  talk = iSWTalkResolve[nb];
  voice = iSWVoiceName[];
  engine = If[iSWVoiceRealtimeQ[voice], iSL["\:30af\:30e9\:30a6\:30c9 (realtime)", "cloud (realtime)"],
    With[{v = If[StringQ[voice], Quiet @ Check[SourceVault`SourceVaultVoice[voice], $Failed], $Failed]},
      If[AssociationQ[v] && v["Engine"] === "AivisSpeech",
        iSL["\:30ed\:30fc\:30ab\:30eb (AivisSpeech)", "local (AivisSpeech)"],
        iSL["\:30ed\:30fc\:30ab\:30eb (Piper)", "local (Piper)"]]]];
  est = Quiet[SlideTalkDuration[nb]];
  rt = iSWRealtimeStatus[];
  src = Quiet[NotebookFileName[nb]];
  Join[
    {{iSL["\:30c7\:30c3\:30ad", "Deck"], If[StringQ[src], FileNameTake[src], iSL["(\:672a\:4fdd\:5b58)", "(unsaved)"]]},
     {iSL["\:30b9\:30e9\:30a4\:30c9\:679a\:6570", "Slides"], ToString[count] <>
        iSL[" \:679a (\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:3088\:308a\:524d)", " (before the end marker)"]},
     {iSL["\:73fe\:5728\:306e\:30b9\:30e9\:30a4\:30c9", "Current slide"], With[{c = iSWSlideNumberFE[nb]},
        If[IntegerQ[c] && c > 0, ToString[c], iSL["(\:4e0d\:660e)", "(unknown)"]]]},
     {iSL["\:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883", "Screen environment"],
        If[iSWSlideShowQ[nb], "SlideShow", ToString[Quiet[CurrentValue[nb, ScreenStyleEnvironment]]]]},
     {iSL["\:767a\:8868\:539f\:7a3f", "Talk"],
        Which[
          AssociationQ[talk] && Lookup[talk, "TalkSource", ""] === "Cells",
            iSL["\:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af (", "in-slide talk cells ("] <>
              ToString[Length[Select[Lookup[talk, "Slides", {}], AssociationQ]]] <>
              iSL[" \:679a\:5206)", " slides)"],
          AssociationQ[talk],
            FileNameTake[talkPath] <> " (" <>
              ToString[Length[Select[Lookup[talk, "Slides", {}], AssociationQ]]] <>
              iSL[" \:679a\:5206)", " slides)"],
          True, iSL["\:306a\:3057", "none"]]}},
    If[AssociationQ[est],
      {{iSL["\:898b\:7a4d\:6642\:9593 (\:8cea\:554f\:306a\:3057)", "Estimated (no questions)"], est["Formatted"]},
       {iSL["  \:5185\:8a33", "  breakdown"],
          iSL["\:8aad\:307f\:4e0a\:3052 ", "speech "] <> ToString[Round[est["Speech"]]] <> "s / " <>
          iSL["\:9593\:30fb\:9001\:308a ", "waits "] <> ToString[Round[est["Waits"]]] <> "s"},
       If[iSWVoiceRealtimeQ[voice],
         {iSL["\:898b\:7a4d\:6642\:9593 (\:8cea\:554f\:53d7\:4ed8\:8fbc\:307f)", "Estimated (with question windows)"],
           Quiet[SlideTalkDuration[nb, "Questions" -> True]["Formatted"]]},
         Nothing],
       {iSL["\:30b7\:30ca\:30ea\:30aa\:306e\:5ba3\:8a00\:5408\:8a08", "Declared in the scenario"], est["PlannedFormatted"]},
       {iSL["\:7dcf\:6587\:5b57\:6570", "Characters"], ToString[est["Characters"]] <>
          iSL[" \:5b57 (", " chars ("] <> ToString[est["CharactersPerSecond"]] <>
          iSL[" \:5b57/\:79d2)", " chars/s)"]},
       {iSL["\:97f3\:58f0\:306e\:7528\:610f", "Audio prepared"],
          ToString[est["Measured"]] <> " / " <>
          ToString[est["Measured"] + est["Estimated"]] <>
          iSL[" \:679a (\:5408\:6210\:6e08\:307f)", " slides synthesized"]}},
      {{iSL["\:898b\:7a4d\:6642\:9593", "Estimated"], iSL["\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093", "no talk scenario"]}}],
    {{iSL["\:58f0", "Voice"], If[StringQ[voice], voice, iSL["\:672a\:5c0e\:5165", "none"]] <> "  (" <> engine <> ")"},
     {iSL["\:97f3\:58f0\:4f1a\:8a71", "Voice answering"],
        If[TrueQ[Lookup[rt, "Running", False]],
          iSL["\:5b9f\:884c\:4e2d", "running"] <> " - " <> ToString[Lookup[rt, "Mode", ""]] <>
            iSL[" / \:30de\:30a4\:30af ", " / mic "] <>
            If[TrueQ[Lookup[rt, "Muted", False]], iSL["\:5207", "off"], iSL["\:5165", "on"]],
          iSL["\:505c\:6b62\:4e2d", "stopped"]]},
     {iSL["\:624b\:5143\:30ea\:30e2\:30b3\:30f3", "Hand remote"],
        With[{rs = SlideRemoteStatus[]},
          Which[
            TrueQ[rs["Watching"]],
              iSL["\:898b\:5f35\:308a\:4e2d: ", "watching: "] <> StringRiffle[
                KeyValueMap[#1 <> " \[Rule] " <> iSWRemoteActionLabel[#2] &,
                  rs["Bindings"]], ", "],
            TrueQ[rs["Checked"]] && ! TrueQ[rs["Available"]],
              iSL["\:4f7f\:3048\:307e\:305b\:3093: ", "unavailable: "] <> ToString[rs["Hint"]],
            True,
              iSL["\:6b62\:307e\:3063\:3066\:3044\:307e\:3059 (SlideRemoteStart[] \:3067\:958b\:59cb)",
                "stopped (SlideRemoteStart[] to begin)"]]]},
     {iSL["\:8aad\:307f\:4e0a\:3052", "Narration"],
        With[{st = SlidePlayStatus[]},
          ToString[st["Status"]] <> If[st["Status"] === "Playing",
            " (" <> ToString[st["Slide"]] <> "/" <> ToString[st["SlideCount"]] <> ")", ""]]}}]];

SlideInfo[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideInfo[nb], $Failed]];

SlideInfo[nb_NotebookObject] := Module[{info, index},
  $iSWSlideControlNotebook = nb;
  info = Grid[iSWInfoRows[nb], Alignment -> Left, Frame -> All,
    FrameStyle -> GrayLevel[0.85], Spacings -> {1.2, 0.9},
    Background -> {None, {{GrayLevel[1], GrayLevel[0.97]}}}];
  index = Quiet[SlideIndex[nb]];
  CreateDocument[
    Flatten[{
      Cell[iSL["\:767a\:8868\:306e\:60c5\:5831", "Talk information"], "Subsection"],
      Cell[BoxData[ToBoxes[info]], "Output"],
      If[Head[index] === Dataset,
        {Cell[iSL["\:30b9\:30e9\:30a4\:30c9\:7d22\:5f15 (Slide \:3067\:982d\:51fa\:3057 / Audio \:3067\:8a66\:8074)",
           "Slide index (Slide jumps, Audio previews)"], "Subsection"],
         Cell[BoxData[ToBoxes[index]], "Output"]},
        {}]}],
    WindowTitle -> iSL["\:767a\:8868\:306e\:60c5\:5831", "Talk information"],
    WindowSize -> {900, 620}]];

iSWInfoAction[nb_] := SlideInfo[nb];

(* ---- \:767a\:8868\:6642\:9593\:306e\:898b\:7a4d\:3082\:308a ---- *)

iSWLookupRate[assoc_, engine_String, fallback_] := With[
  {v = If[AssociationQ[assoc], Lookup[assoc, engine, fallback], fallback]},
  If[NumericQ[v] && N[v] > 0., N[v], fallback]];

iSWFormatDuration[secs_?NumericQ] := Module[{t = Max[0, Round[N[secs]]], m, sec},
  m = Quotient[t, 60]; sec = Mod[t, 60];
  If[m >= 60,
    ToString[Quotient[m, 60]] <> iSL["\:6642\:9593", "h "] <> ToString[Mod[m, 60]] <>
      iSL["\:5206", "m "] <> ToString[sec] <> iSL["\:79d2", "s"],
    ToString[m] <> iSL["\:5206", "m "] <> ToString[sec] <> iSL["\:79d2", "s"]]];

iSWFormatDuration[_] := "";

(* \:539f\:7a3f\:3068\:58f0\:304b\:3089 1 \:679a\:5206\:306e\:79d2\:6570\:3002\:5408\:6210\:6e08\:307f\:306a\:3089\:5b9f\:6e2c\:3001\:7121\:3051\:308c\:3070\:6587\:5b57\:6570\:304b\:3089 *)
iSWSlideSeconds[dir_, n_Integer, text_String, voice_, engine_String, rate_, latency_] :=
  Module[{file, audio, dur},
    If[StringTrim[text] === "",
      Return[<|"Seconds" -> $iSWVoiceSilentSeconds, "Source" -> "Silent"|>]];
    If[engine === "Local" && StringQ[voice] && StringQ[dir],
      file = iSWVoiceCacheFile[dir, n, voice, text];
      If[FileExistsQ[file] && TrueQ[Quiet[FileByteCount[file]] > 1000],
        audio = Quiet[Audio[file]];
        dur = Quiet[QuantityMagnitude[Duration[audio]]];
        If[NumericQ[dur] && dur > 0.,
          Return[<|"Seconds" -> N[dur], "Source" -> "Measured"|>]]]];
    <|"Seconds" -> N[StringLength[text]]/rate + latency, "Source" -> "Estimated"|>];

Options[SlideTalkDuration] = {"Voice" -> Automatic, "Questions" -> False,
  "View" -> False};

SlideTalkDuration[opts : OptionsPattern[]] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideTalkDuration[nb, opts],
    Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>]]];

SlideTalkDuration[nb_NotebookObject, opts : OptionsPattern[]] :=
  With[{t = iSWTalkResolve[nb]},
    iSWTalkDuration[If[AssociationQ[t], t, SlideTalkFile[nb]],
      iSWVoiceCacheDir[nb], iSWSlideCountOf[nb], iSWSlideTitles[nb], opts]];

SlideTalkDuration[path_String, opts : OptionsPattern[]] := Module[{talk, dir, base},
  talk = If[ToLowerCase[FileExtension[path]] === "md", path, SlideTalkFile[path]];
  {dir, base} = {DirectoryName[talk],
    StringReplace[FileBaseName[talk], "_talk" ~~ EndOfString -> ""]};
  iSWTalkDuration[talk, FileNameJoin[{dir, base <> "_voice"}], 0, {}, opts]];

(* talkSpec \:306f\:30c8\:30fc\:30af\:9023\:60f3 (\:30bb\:30eb\:7531\:6765) \:304b _talk.md \:306e path *)
iSWTalkDuration[talkSpec_, cacheDir_, deckCount_, titles_, OptionsPattern[SlideTalkDuration]] :=
  Module[{texts, keys, voice, engine, rate, latency, questionSeconds, gap,
    rows, speech, waits, total, planned, talk},
  talk = Which[
    AssociationQ[talkSpec], talkSpec,
    StringQ[talkSpec] && FileExistsQ[talkSpec],
      Quiet[SlideTalkFromMarkdown[File[talkSpec]]],
    True, $Failed];
  texts = iSWVoiceTextsFromTalk[talk];
  If[texts === $Failed,
    Return[Failure["SlideTalkMissing",
      <|"MessageTemplate" -> "\:767a\:8868\:306e\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093 (\:30c8\:30fc\:30af\:30bb\:30eb\:3082 _talk.md \:3082\:7121\:3057): " <>
        If[StringQ[talkSpec], talkSpec, "(cells)"]|>]]];
  voice = Replace[OptionValue["Voice"], Automatic :> iSWVoiceName[]];
  engine = If[iSWVoiceRealtimeQ[voice], "Realtime", "Local"];
  rate = iSWLookupRate[$SlideSpeechRate, engine, If[engine === "Realtime", 5.6, 6.95]];
  latency = iSWLookupRate[$SlideSpeechLatency, engine,
    If[engine === "Realtime", 1.5, 0.3]];
  keys = Sort[Keys[texts]];
  If[IntegerQ[deckCount] && deckCount > 0, keys = Select[keys, # <= deckCount &]];
  gap = With[{g = $SlideVoiceGap}, If[NumericQ[g], N[g], 0.8]];
  questionSeconds = If[TrueQ[OptionValue["Questions"]] && engine === "Realtime",
    iSWQuestionWindow[], 0.];
  rows = Table[
    Module[{text = ToString[Lookup[texts, k, ""]], one},
      one = iSWSlideSeconds[cacheDir, k, text, voice, engine, rate, latency];
      <|"Slide" -> k,
        "Title" -> If[1 <= k <= Length[titles], titles[[k]], ""],
        "Characters" -> StringLength[text],
        "Seconds" -> Round[one["Seconds"], 0.1],
        "Source" -> one["Source"]|>],
    {k, keys}];
  speech = Total[#["Seconds"] & /@ rows];
  (* 1 \:679a\:3054\:3068\:306e\:9593 + \:30da\:30fc\:30b8\:9001\:308a\:3002\:6700\:5f8c\:306e 1 \:679a\:306e\:3042\:3068\:306f\:9001\:3089\:306a\:3044 *)
  waits = Length[rows] (gap + questionSeconds) + Max[0, Length[rows] - 1] 0.4;
  total = speech + waits;
  planned = If[AssociationQ[talk],
    Total[Table[With[{sec = Lookup[sl, "Seconds", Null]},
      If[NumericQ[sec], N[sec], Lookup[talk, "SecondsPerSlide", 25.]]],
      {sl, Select[Lookup[talk, "Slides", {}], AssociationQ]}]], 0.];
  If[TrueQ[OptionValue["View"]], Return[Dataset[rows]]];
  <|"Total" -> Quantity[Round[total, 0.1], "Seconds"],
    "Formatted" -> iSWFormatDuration[total],
    "Speech" -> Round[speech, 0.1],
    "Waits" -> Round[waits, 0.1],
    "Slides" -> Length[rows],
    "Characters" -> Total[#["Characters"] & /@ rows],
    "Engine" -> engine, "Voice" -> voice,
    "CharactersPerSecond" -> rate,
    "Measured" -> Count[rows, r_ /; r["Source"] === "Measured"],
    "Estimated" -> Count[rows, r_ /; r["Source"] === "Estimated"],
    "QuestionWindows" -> Round[Length[rows] questionSeconds, 0.1],
    "PlannedInScenario" -> Quantity[Round[planned, 0.1], "Seconds"],
    "PlannedFormatted" -> iSWFormatDuration[planned],
    "Rows" -> rows|>];

(* ---- \:898b\:51fa\:3057\:7d22\:5f15\:3068\:30b9\:30e9\:30a4\:30c9\:79fb\:52d5 ---- *)

$iSWTitleCache = <||>;

(* \:6700\:5f8c\:306b\:64cd\:4f5c\:3057\:305f\:30c7\:30c3\:30ad\:3002\:58f0\:304b\:3089\:306e\:8981\:6c42\:306f\:30b9\:30b1\:30b8\:30e5\:30fc\:30eb\:30bf\:30b9\:30af\:7d4c\:7531\:3067\:6765\:308b\:306e\:3067\:3001
   InputNotebook[] \:306f\:5f53\:3066\:306b\:306a\:3089\:306a\:3044 (\:30d1\:30ec\:30c3\:30c8\:3084\:5225\:7a93\:304c\:524d\:306b\:3044\:308b) *)
$iSWSlideControlNotebook = None;

iSWLiveNotebookQ[nb_] := Head[nb] === NotebookObject &&
  With[{nbs = Quiet[Notebooks[]]}, ! ListQ[nbs] || MemberQ[nbs, nb]];

iSWSlideControlNotebook[] := SelectFirst[
  {$iSWPlayState["Notebook"],
   If[iSWRealtimeLayerQ[], Quiet[SourceVault`SourceVaultRealtimeStatusNotebook[]], None],
   $iSWSlideControlNotebook,
   Quiet[iSWResolveTargetNb[]]},
  iSWLiveNotebookQ, $Failed];

(* \:898b\:51fa\:3057\:3060\:3051\:3092\:8aad\:3080\:3002\:30b9\:30e9\:30a4\:30c9\:5168\:4f53\:3092 NotebookRead \:3059\:308b\:3068\:753b\:50cf\:307e\:3067 FE \:304b\:3089
   \:5f15\:304d\:53d6\:308b\:3053\:3068\:306b\:306a\:308b\:306e\:3067\:3001Subsection \:7b49\:306e\:30bb\:30eb\:3092 1 \:3064\:3060\:3051\:8aad\:3080 *)
iSWSlideTitles[nb_NotebookObject] := Module[{styles, cells, ranges, key, hit},
  cells = Cells[nb];
  key = {nb, Length[cells]};
  hit = Lookup[$iSWTitleCache, Key[key], None];
  If[ListQ[hit], Return[hit]];
  styles = iSWCellStyles[nb];
  ranges = iSWSlideRanges[nb];
  hit = Table[
    Module[{idx},
      idx = SelectFirst[Range[r[[1]], Min[r[[2]], Length[styles]]],
        MemberQ[{"Subsection", "Section", "Subsubsection", "Title", "Item"},
          styles[[#]]] &, None];
      If[idx === None, "",
        With[{c = Quiet[NotebookRead[cells[[idx]]]]},
          If[Head[c] === Cell, iCellText[c], ""]]]],
    {r, ranges}];
  $iSWTitleCache = <|Key[key] -> hit|>;
  hit];

SlideTitles[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideTitles[nb], {}]];
SlideTitles[nb_NotebookObject] := iSWSlideTitles[nb];

(* \:679a\:6570\:306f\:30c7\:30c3\:30ad\:306e\:69cb\:9020\:304b\:3089\:6570\:3048\:308b\:3002FE \:306e MaxCounterValue \:306f navbar \:30bb\:30eb\:3092
   \:5168\:90e8\:6570\:3048\:308b\:306e\:3067\:3001\:7d42\:7aef\:30de\:30fc\:30ab\:30fc (\:300c\:30b9\:30e9\:30a4\:30c9\:7d42\:7aef\:300d) \:3068\:4ed8\:9332\:307e\:3067 1 \:30da\:30fc\:30b8\:306b
   \:306a\:3063\:3066\:3057\:307e\:3044\:3001\:300c\:6700\:5f8c\:306e\:30b9\:30e9\:30a4\:30c9\:300d\:304c\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:306b\:306a\:308b *)
iSWSlideCountOf[nb_] := Module[{ranges, fe},
  ranges = Quiet[iSWSlideRanges[nb]];
  If[ListQ[ranges] && Length[ranges] > 0, Return[Length[ranges]]];
  fe = iSWSlideCountFE[nb];
  If[IntegerQ[fe] && fe > 0, fe, 0]];

(* \:8a9e\:304b\:3089\:30b9\:30e9\:30a4\:30c9\:3092\:63a2\:3059: \:898b\:51fa\:3057 -> \:539f\:7a3f (talk md) \:306e\:9806\:3002
   \:58f0\:306e\:66f8\:304d\:8d77\:3053\:3057\:306f\:8868\:8a18\:304c\:63fa\:308c\:308b\:306e\:3067\:3001\:7a7a\:767d\:30fb\:4e2d\:9ed2\:3092\:843d\:3068\:3057\:3066\:6bd4\:3079\:308b *)
iSWNormalizeQuery[s_String] :=
  ToLowerCase[StringDelete[s, {" ", "\t", "\:3000", "\:30fb", "\:ff65", "\:3001", "\:3002",
    "\:306e\:30b9\:30e9\:30a4\:30c9", "\:30b9\:30e9\:30a4\:30c9"}]];

iSWFindSlideByText[nb_, queryIn_String] := Module[{query, titles, hit, texts},
  query = iSWNormalizeQuery[queryIn];
  If[query === "", Return[$Failed]];
  titles = iSWSlideTitles[nb];
  hit = SelectFirst[Range[Length[titles]],
    StringContainsQ[iSWNormalizeQuery[titles[[#]]], query] &, None];
  If[IntegerQ[hit], Return[hit]];
  texts = If[AssociationQ[$iSWPlayState["Texts"]] && Length[$iSWPlayState["Texts"]] > 0,
    $iSWPlayState["Texts"], Quiet[iSWVoiceTexts[nb]]];
  If[AssociationQ[texts],
    hit = SelectFirst[Sort[Keys[texts]],
      StringContainsQ[iSWNormalizeQuery[ToString[texts[#]]], query] &, None];
    If[IntegerQ[hit], Return[hit]]];
  $Failed];

(* n \:679a\:76ee\:3078\:98db\:3076\:3002FE \:30c8\:30fc\:30af\:30f3\:306b\:306f\:4efb\:610f\:30b8\:30e3\:30f3\:30d7\:304c\:7121\:3044\:306e\:3067\:3001\:5148\:982d\:304b\:3089\:9001\:308b\:304b\:3001
   navbar \:30bb\:30eb\:3078\:9078\:629e\:3092\:52d5\:304b\:3059 (\:30b9\:30e9\:30a4\:30c9\:30b7\:30e7\:30fc\:3067\:306f\:9078\:629e\:306e\:3042\:308b\:30da\:30fc\:30b8\:304c\:51fa\:308b) *)
iSWSlideGoTo[nb_, nIn_Integer] := Module[{n, count, cur, navs, k},
  count = iSWSlideCountOf[nb];
  n = Clip[nIn, {1, Max[1, count]}];
  navs = Quiet[Cells[nb, CellStyle -> "SlideShowNavigationBar"]];
  If[MatchQ[navs, {__CellObject}] && Length[navs] >= n,
    Quiet[SelectionMove[navs[[n]], After, Cell, AutoScroll -> True]];
    Pause[0.2];
    If[iSWSlideNumberFE[nb] === n, Return[n]]];
  (* \:9078\:629e\:3067\:52d5\:304b\:306a\:3051\:308c\:3070\:30c8\:30fc\:30af\:30f3\:3067\:6570\:3048\:308b *)
  Quiet[FrontEndTokenExecute[nb, "ScrollPageFirst"]];
  Pause[0.15];
  Do[iSWSlideGoNext[nb]; Pause[0.06], {n - 1}];
  Pause[0.1];
  cur = iSWSlideNumberFE[nb];
  If[IntegerQ[cur], cur, n]];

(* \:97f3\:58f0\:304b\:3089\:306e\:8868\:793a\:8981\:6c42\:3002SourceVault_realtime \:304c pump \:304b\:3089\:547c\:3076 *)
iSWSlideRequestHandler[req_Association] := Module[
  {nb, target, cur, count, dest, titles},
  nb = With[{given = Lookup[req, "Notebook", None]},
    If[iSWLiveNotebookQ[given], given, iSWSlideControlNotebook[]]];
  If[Head[nb] =!= NotebookObject,
    Return[<|"status" -> "error", "message" -> "\:30b9\:30e9\:30a4\:30c9\:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002"|>]];
  count = iSWSlideCountOf[nb];
  cur = With[{c = iSWSlideNumberFE[nb]},
    If[IntegerQ[c] && c >= 1, c, $iSWPlayState["Slide"]]];
  If[! IntegerQ[cur] || cur < 1, cur = 1];
  target = ToLowerCase[ToString[Lookup[req, "target", ""]]];
  dest = Switch[target,
    "next", cur + 1,
    "previous", cur - 1,
    "first", 1,
    "last", Max[1, count],
    "number", With[{v = Lookup[req, "number", None]},
      Which[IntegerQ[v], v, NumericQ[v], Round[v], True, $Failed]],
    "title", iSWFindSlideByText[nb, ToString[Lookup[req, "title", ""]]],
    _, $Failed];
  If[dest === $Failed || ! IntegerQ[dest],
    Return[<|"status" -> "error",
      "message" -> "\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3067\:3057\:305f\:3002"|>]];
  If[dest < 1 || dest > Max[1, count],
    Return[<|"status" -> "error", "slide" -> cur,
      "message" -> If[dest < 1, "\:6700\:521d\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:3059\:3002", "\:6700\:5f8c\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:3059\:3002"]|>]];
  dest = iSWSlideGoTo[nb, dest];
  iSWNoteSlide[dest];
  (* \:8aad\:307f\:4e0a\:3052\:4e2d\:306a\:3089\:3001\:305d\:306e\:679a\:3092\:8aad\:307f\:76f4\:3059 (\:8868\:793a\:3068\:8a71\:304c\:98df\:3044\:9055\:308f\:306a\:3044\:3088\:3046\:306b) *)
  If[$iSWPlayState["Status"] === "Playing" && iSWPlayRealtimeQ[],
    $iSWPlayState["Slide"] = dest;
    $iSWPlayState["NarrationId"] = None;
    $iSWPlayState["Deadline"] = AbsoluteTime[] + 3.;
    $iSWPlayState["AudioEnd"] = AbsoluteTime[] + 3.];
  titles = iSWSlideTitles[nb];
  <|"status" -> "ok", "slide" -> dest, "slideCount" -> count,
    "title" -> If[1 <= dest <= Length[titles], titles[[dest]], ""]|>];

SlideShowSlide[spec_] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideShowSlide[nb, spec], $Failed]];

SlideShowSlide[nb_NotebookObject, spec_] := Module[{req},
  $iSWSlideControlNotebook = nb;
  req = Which[
    IntegerQ[spec], <|"target" -> "number", "number" -> spec|>,
    StringQ[spec] && MemberQ[{"next", "previous", "first", "last"}, ToLowerCase[spec]],
      <|"target" -> ToLowerCase[spec]|>,
    StringQ[spec], <|"target" -> "title", "title" -> spec|>,
    True, <|"target" -> ""|>];
  iSWSlideRequestHandler[Append[req, "Notebook" -> nb]]];

(* ---- \:518d\:751f\:30a8\:30f3\:30b8\:30f3 ---- *)

iSWPlayReleaseStream[] := Module[{s = $iSWPlayState["Stream"]},
  If[Head[s] === AudioStream,
    Quiet[AudioStop[s]]; Quiet[RemoveAudioStream[s]]];
  $iSWPlayState["Stream"] = None];

iSWPlayStopTask[] := Module[{t = $iSWPlayState["Task"]},
  If[Head[t] === TaskObject, Quiet[TaskRemove[t]]];
  $iSWPlayState["Task"] = None];

iSWPlayStartTask[] := (iSWPlayStopTask[];
  $iSWPlayState["Task"] =
    Quiet[SessionSubmit[ScheduledTask[iSWPlayTick[], $SlideVoiceTick]]]);

iSWPlaySetLabel[s_String] := ($iSWPlayLabel = s);

$iSWTalkLabel = "\[EmptyCircle] \:5fdc\:7b54off";

iSWRealtimeRunningQ[] := TrueQ[Lookup[iSWRealtimeStatus[], "Running", False]];

iSWTalkLabelText[running_] :=
  If[TrueQ[running], "\[FilledCircle] \:5fdc\:7b54on", "\[EmptyCircle] \:5fdc\:7b54off"];

iSWRefreshTalkLabel[] := ($iSWTalkLabel = iSWTalkLabelText[iSWRealtimeRunningQ[]]);

(* \:30d1\:30ec\:30c3\:30c8\:306e\:300c\:5fdc\:7b54on/off\:300d: \:97f3\:58f0\:4f1a\:8a71\:305d\:306e\:3082\:306e\:306e\:958b\:59cb\:3068\:505c\:6b62\:3002
   \:767a\:8868\:306e\:8aad\:307f\:4e0a\:3052 (\:518d\:751f) \:3068\:306f\:5225 -- \:8aad\:307f\:4e0a\:3052\:4e2d\:3067\:3082\:8cea\:7591\:3060\:3051\:6b62\:3081\:305f\:3044/\:59cb\:3081\:305f\:3044\:3053\:3068\:304c\:3042\:308b *)
SlideToggleRealtime[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideToggleRealtime[nb], $Failed]];

SlideToggleRealtime[nb_NotebookObject] := Module[{res, voice},
  $iSWSlideControlNotebook = nb;
  If[! iSWRealtimeLayerQ[],
    MessageDialog[iSL["SourceVault_realtime.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093\:3002",
      "SourceVault_realtime.wl is not loaded."]];
    Return[$Failed]];
  If[iSWRealtimeRunningQ[],
    res = Quiet[SourceVault`SourceVaultRealtimeStop[]];
    $iSWPlayState["StartedBridge"] = False;
    iSWRemoteAutoStop[];
    iSWRefreshTalkLabel[];
    iSWRefreshMicLabel[];
    Return[res]];
  voice = With[{v = iSWVoiceName[]},
    If[iSWVoiceRealtimeQ[v], iSWRealtimeVoiceOf[v], Automatic]];
  res = Quiet[SourceVault`SourceVaultRealtimeStart[
    "Notebook" -> nb, "Voice" -> voice, "StartMuted" -> False,
    "SlideControl" -> True, "InputLevelGate" -> iSWInputGate[],
    "Instructions" -> iSWRealtimeSessionInstructions[]]];
  iSWRefreshTalkLabel[];
  (* \:624b\:5143\:30ea\:30e2\:30b3\:30f3 (Relacon \:306e\:518d\:751f/\:4e00\:6642\:505c\:6b62) \:3092\:97f3\:58f0\:5fdc\:7b54\:3068\:9023\:52d5\:3055\:305b\:308b *)
  iSWRemoteAutoStart[];
  iSWRefreshMicLabel[];
  If[FailureQ[res] || res === $Failed,
    MessageDialog[iSL["\:97f3\:58f0\:5fdc\:7b54\:3092\:958b\:59cb\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f:\n",
      "Could not start voice answering:\n"] <> iSWFailureText[res]]];
  res];

iSWPlayLabelPlay[] := iSWPlaySetLabel["\[FilledRightTriangle] " <> iSL["\:518d\:751f", "Play"]];
iSWPlayLabelResume[] := iSWPlaySetLabel["\[FilledRightTriangle] " <> iSL["\:518d\:958b", "Resume"]];
iSWPlayLabelPause[] := iSWPlaySetLabel["|| " <> iSL["\:4e00\:6642\:505c\:6b62", "Pause"]];

iSWPlayRefreshProgress[] := ($iSWPlayProgress =
  If[$iSWPlayState["Status"] === "Idle", "",
    ToString[$iSWPlayState["Slide"]] <> "/" <> ToString[$iSWPlayState["Count"]] <>
      " " <> If[StringQ[$iSWPlayState["Voice"]],
        iSWVoiceShortName[$iSWPlayState["Voice"]], ""]]);

(* Realtime \:306e\:3068\:304d\:306f\:8868\:793a\:306e\:51fa\:53e3\:3092 1 \:3064\:306b\:3059\:308b: \:30b9\:30c6\:30fc\:30bf\:30b9\:30d0\:30fc\:306f\:30ef\:30fc\:30ab\:30fc\:304c\:6301\:3063\:3066
   \:3044\:308b\:306e\:3067\:3001\:3053\:3061\:3089\:306e\:884c\:3082\:540c\:3058\:7d4c\:8def\:3078\:6d41\:3059\:3002\:76f4\:63a5\:66f8\:304f\:3068\:4f1a\:8a71\:306e\:884c\:3068\:596a\:3044\:5408\:3063\:3066\:3001
   \:3069\:3061\:3089\:3082\:8aad\:3081\:306a\:304f\:306a\:308b\:3002 *)
iSWPlayNote[msg_String] := (
  If[iSWPlayRealtimeQ[] && iSWRealtimeLayerQ[],
    Quiet[SourceVault`SourceVaultRealtimeLine[msg]],
    With[{nb = $iSWPlayState["Notebook"]},
      If[Head[nb] === NotebookObject, iSWStatus[nb, msg]]]];
  iSWPlayRefreshProgress[]);

(* \:81ea\:5206\:3067\:8d77\:3053\:3057\:305f\:97f3\:58f0\:4f1a\:8a71\:306f\:81ea\:5206\:3067\:7247\:3065\:3051\:308b\:3002\:5229\:7528\:8005\:304c\:5148\:306b\:8d77\:3053\:3057\:3066\:3044\:305f
   \:30bb\:30c3\:30b7\:30e7\:30f3 (\:8cea\:7591\:7528\:306a\:3069) \:306f\:6b62\:3081\:306a\:3044\:3002 *)
iSWPlayReleaseRealtime[] := If[iSWPlayRealtimeQ[] && iSWRealtimeLayerQ[],
  (* \:5358\:306b\:5207\:308b\:3060\:3051\:3060\:3068\:3001\:98db\:3093\:3067\:3044\:305f\:5fdc\:7b54\:3084\:90e8\:5c4b\:306e\:7269\:97f3\:3067\:6570\:79d2\:5f8c\:306b\:307e\:305f\:8a71\:3057\:51fa\:3059\:3002
     \:767a\:8868\:306e\:6587\:8108\:3054\:3068\:9589\:3058\:3066\:3001\:3057\:3070\:3089\:304f\:306f\:81ea\:767a\:7684\:306a\:5fdc\:7b54\:3092\:4f5c\:3089\:305b\:306a\:3044 *)
  Quiet[SourceVault`SourceVaultRealtimeEndTalk[]];
  If[TrueQ[$iSWPlayState["StartedBridge"]],
    Quiet[SourceVault`SourceVaultRealtimeStop[]];
    $iSWPlayState["StartedBridge"] = False;
    iSWRemoteAutoStop[]];
  iSWRefreshTalkLabel[];
  iSWRefreshMicLabel[]];

iSWPlayHalt[] := (
  iSWPlayReleaseStream[];
  iSWPlayReleaseRealtime[];
  iSWPlayStopTask[];
  $iSWPlayState["Status"] = "Idle";
  $iSWPlayState["NarrationId"] = None;
  iSWPlayLabelPlay[];
  iSWPlayRefreshProgress[];
  Null);

iSWPlayFinish[] := (
  iSWPlayNote[iSL["\:8aad\:307f\:4e0a\:3052\:7d42\:4e86", "Narration finished"]];
  iSWPlayHalt[];
  With[{nb = $iSWPlayState["Notebook"]},
    If[Head[nb] === NotebookObject, iSWStatusClearLater[nb]]];
  Null);

(* \:5408\:6210\:306b\:5931\:6557\:3057\:305f\:3089\:9ed9\:3063\:3066\:6b62\:3081\:308b\:3002\:80cc\:666f\:30bf\:30b9\:30af\:304b\:3089\:30c0\:30a4\:30a2\:30ed\:30b0\:306f\:51fa\:3055\:306a\:3044
   (\:539f\:56e0\:306f SlidePlayStatus[]["LastFailure"] \:306b\:6b8b\:3059) *)
iSWPlayFailReason[msg_String] := (
  iSWPlayNote[msg];
  iSWPlayHalt[];
  Null);

iSWPlayFail[] := iSWPlayFailReason[
  iSL["\:97f3\:58f0\:5408\:6210\:306b\:5931\:6557\:3057\:307e\:3057\:305f (SlidePlayStatus[] \:3092\:78ba\:8a8d)",
    "Speech synthesis failed (see SlidePlayStatus[])"]];

iSWPlaySlide[nIn_Integer] := Module[{nb, n, text, now},
  nb = $iSWPlayState["Notebook"];
  n = nIn;
  $iSWPlayState["Slide"] = n;
  iSWNoteDeck[nb];
  iSWNoteSlide[n];
  $iSWPlayState["NarrationId"] = None;
  iSWPlayReleaseStream[];
  text = Lookup[$iSWPlayState["Texts"], n, ""];
  now = AbsoluteTime[];
  If[!StringQ[text] || StringTrim[text] === "",
    (* \:539f\:7a3f\:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9: \:5c11\:3057\:898b\:305b\:3066\:304b\:3089\:6b21\:3078 *)
    $iSWPlayState["StartedAt"] = now;
    $iSWPlayState["Duration"] = $iSWVoiceSilentSeconds;
    $iSWPlayState["AudioEnd"] = now + $iSWVoiceSilentSeconds;
    $iSWPlayState["Deadline"] = now + $iSWVoiceSilentSeconds;
    iSWPlayNote[iSL["\:30b9\:30e9\:30a4\:30c9 ", "Slide "] <> ToString[n] <> "/" <>
      ToString[$iSWPlayState["Count"]] <> iSL[" (\:539f\:7a3f\:306a\:3057)", " (no narration)"]];
    Return[Null]];
  If[iSWPlayRealtimeQ[],
    iSWPlaySlideRealtime[n, text],
    iSWPlaySlideLocal[nb, n, text]];
  Null];

(* \:30ed\:30fc\:30ab\:30eb (Piper): \:5408\:6210 -> Audio -> AudioPlay\:3002\:9577\:3055\:306f\:5206\:304b\:308b\:306e\:3067\:7de0\:5207\:3067\:9001\:308b *)
iSWPlaySlideLocal[nb_, n_Integer, text_String] :=
  Module[{file, audio, dur, stream, now},
  iSWPlayNote[iSL["\:97f3\:58f0\:3092\:5408\:6210\:4e2d: \:30b9\:30e9\:30a4\:30c9 ", "Synthesizing: slide "] <> ToString[n]];
  file = iSWVoiceFileFor[nb, n, text];
  If[file === $Failed, iSWPlayFail[]; Return[Null]];
  audio = Quiet[Audio[file]];
  If[!TrueQ[Quiet[AudioQ[audio]]], iSWPlayFail[]; Return[Null]];
  dur = Quiet[QuantityMagnitude[Duration[audio]]];
  If[!NumericQ[dur] || dur <= 0., dur = $iSWVoiceSilentSeconds];
  stream = Quiet[AudioPlay[audio]];
  now = AbsoluteTime[];
  $iSWPlayState["Stream"] = If[Head[stream] === AudioStream, stream, None];
  $iSWPlayState["StartedAt"] = now;
  $iSWPlayState["Duration"] = dur;
  $iSWPlayState["AudioEnd"] = now + dur;
  $iSWPlayState["Deadline"] = now + dur + $SlideVoiceGap;
  $iSWPlayState["LastPos"] = 0.;
  $iSWPlayState["LastPosAt"] = now;
  (* \:30b9\:30c6\:30fc\:30bf\:30b9\:30d0\:30fc\:306f\:30da\:30fc\:30b8\:60c5\:5831\:3060\:3051 (\:58f0\:306e\:540d\:524d\:306f\:51fa\:3055\:306a\:3044 \:2014 \:9577\:3044\:6b63\:5f0f\:540d\:304c\:90aa\:9b54) *)
  iSWPlayNote["\[FilledRightTriangle] " <> ToString[n] <> "/" <>
    ToString[$iSWPlayState["Count"]]];
  (* \:6b21\:30b9\:30e9\:30a4\:30c9\:306e\:5148\:8aad\:307f\:5408\:6210 (\:3053\:306e\:9593\:3082 FE \:5074\:306e\:518d\:751f\:306f\:7d9a\:304f) *)
  iSWVoicePrefetch[nb, n + 1];
  Null];

(* Realtime (gpt-realtime): \:539f\:7a3f\:3092\:6e21\:3057\:3066\:8aad\:307e\:305b\:3001\:300c\:9cf4\:308a\:7d42\:308f\:3063\:305f\:300d\:3068\:8a00\:3063\:3066\:304d\:305f\:3089\:6b21\:3078\:3002
   \:9577\:3055\:306f\:4e8b\:524d\:306b\:5206\:304b\:3089\:306a\:3044\:306e\:3067\:3001\:7de0\:5207\:306f\:66b4\:8d70\:3088\:3051\:306e\:4e0a\:9650\:3068\:3057\:3066\:3060\:3051\:4f7f\:3046\:3002 *)
iSWPlaySlideRealtime[n_Integer, text_String] := Module[{id, res, now, budget},
  id = "s" <> ToString[n] <> "r" <> ToString[$iSWPlayState["Run"]];
  iSWRealtimeMic[False];
  res = Quiet[SourceVault`SourceVaultRealtimeNarrate[id, text,
    "Heading" -> (iSL["\:30b9\:30e9\:30a4\:30c9 ", "Slide "] <> ToString[n] <> "/" <>
      ToString[$iSWPlayState["Count"]]),
    "Instructions" -> ToString[$iSWPlayState["Instructions"]]]];
  If[FailureQ[res],
    $iSWPlayState["LastFailure"] = res;
    iSWPlayFailReason[iSL["\:8aad\:307f\:4e0a\:3052\:3092\:4f9d\:983c\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f",
      "Could not request narration"]];
    Return[Null]];
  now = AbsoluteTime[];
  (* \:65e5\:672c\:8a9e\:3067\:6bce\:79d2 6-7 \:6587\:5b57\:307b\:3069\:3002\:4e0a\:9650\:306f\:305d\:306e\:500d\:306b 45 \:79d2\:8db3\:3059 *)
  budget = Max[60., N[StringLength[text]]/3. + 45.];
  $iSWPlayState["NarrationId"] = id;
  $iSWPlayState["StartedAt"] = now;
  $iSWPlayState["Duration"] = budget;
  $iSWPlayState["AudioEnd"] = now + budget;
  $iSWPlayState["Deadline"] = now + budget;
  Null];

iSWVoicePrefetch[nb_, n_Integer] :=
  If[n <= $iSWPlayState["Count"],
    With[{t = Lookup[$iSWPlayState["Texts"], n, ""]},
      If[StringQ[t] && StringTrim[t] =!= "", Quiet[iSWVoiceFileFor[nb, n, t]]]]];

iSWPlayAdvance[] := Module[{nb, cur, feBefore, feN, next},
  nb = $iSWPlayState["Notebook"];
  cur = $iSWPlayState["Slide"];
  iSWPlayReleaseStream[];
  If[cur >= $iSWPlayState["Count"], iSWPlayFinish[]; Return[Null]];
  feBefore = If[TrueQ[$iSWPlayState["UseFECounter"]], iSWSlideNumberFE[nb], None];
  iSWSlideGoNext[nb];
  Pause[0.25];
  (* \:30da\:30fc\:30b8\:304c\:52d5\:304b\:306a\:304b\:3063\:305f\:3089\:3001\:5bfe\:8c61\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:524d\:306b\:51fa\:3057\:3066\:3082\:3046\:4e00\:5ea6\:3060\:3051\:8a66\:3059\:3002
     FE \:30c8\:30fc\:30af\:30f3\:306f\:5bfe\:8c61\:30a6\:30a4\:30f3\:30c9\:30a6\:304c\:80cc\:9762\:306e\:307e\:307e\:3060\:3068\:901a\:3089\:306a\:3044\:3053\:3068\:304c\:3042\:308b *)
  If[IntegerQ[feBefore] && feBefore >= 1 &&
      iSWSlideNumberFE[nb] === feBefore,
    (* \:66f4\:65b0\:304c\:9045\:3044\:3060\:3051\:306e\:3053\:3068\:304c\:3042\:308b\:306e\:3067\:3001\:3082\:3046\:5c11\:3057\:5f85\:3063\:3066\:898b\:76f4\:3057\:3066\:304b\:3089\:9001\:308a\:76f4\:3059\:3002
       \:5f85\:305f\:305a\:306b 2 \:56de\:9001\:308b\:3068\:3001\:9045\:308c\:3066\:8ffd\:3044\:3064\:3044\:305f\:30ab\:30a6\:30f3\:30bf\:3068\:5408\:308f\:305b\:3066 2 \:679a\:9032\:3093\:3067\:3057\:307e\:3046 *)
    Pause[0.4];
    If[iSWSlideNumberFE[nb] === feBefore,
      Quiet[SetSelectedNotebook[nb]];
      Pause[0.1];
      iSWSlideGoNext[nb];
      Pause[0.15]];
    If[iSWSlideNumberFE[nb] === feBefore,
      $iSWPlayState["LastFailure"] = Failure["SlideAdvanceIgnored",
        <|"MessageTemplate" -> "ScrollPageNext did not move the slide (counter stayed at `1`)",
          "MessageParameters" -> {feBefore}|>]]];
  (* FE \:306e\:30ab\:30a6\:30f3\:30bf\:304c\:4f7f\:3048\:308b\:306a\:3089\:3001\:305d\:308c\:3092\:6b63\:3068\:3059\:308b (\:767a\:8868\:8005\:304c\:624b\:3067\:9001\:3063\:3066\:3082\:8ffd\:968f\:3059\:308b) *)
  feN = If[TrueQ[$iSWPlayState["UseFECounter"]], iSWSlideNumberFE[nb], None];
  (* \:30ab\:30a6\:30f3\:30bf\:304c\:52d5\:3044\:3066\:3044\:306a\:3044\:3068\:304d\:306b\:305d\:308c\:3092\:4fe1\:3058\:308b\:3068\:540c\:3058\:679a\:3092\:8aad\:307f\:76f4\:3057\:7d9a\:3051\:308b\:3002
     \:73fe\:5728\:5024\:3068\:540c\:3058\:306a\:3089\:300c\:307e\:3060\:66f4\:65b0\:3055\:308c\:3066\:3044\:306a\:3044\:300d\:3068\:307f\:306a\:3057\:3066\:5185\:90e8\:306e\:6570\:3048\:4e0a\:3052\:306b\:843d\:3068\:3059 *)
  next = If[IntegerQ[feN] && feN >= 1 && feN =!= cur, feN, cur + 1];
  If[next > $iSWPlayState["Count"], iSWPlayFinish[]; Return[Null]];
  iSWPlaySlide[next];
  Null];

iSWPlayTickBody[] := Module[{nb, nbs, now, stream, pos, rt, elapsed},
  If[$iSWPlayState["Status"] =!= "Playing", Return[Null]];
  nb = $iSWPlayState["Notebook"];
  (* \:5bfe\:8c61\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:9589\:3058\:3089\:308c\:305f\:3089\:6b62\:3081\:308b\:3002Notebooks[] \:304c\:53d6\:308c\:306a\:3044\:3068\:304d\:306f
     \:5224\:5b9a\:6750\:6599\:304c\:7121\:3044\:3060\:3051\:306a\:306e\:3067\:6b62\:3081\:306a\:3044 (\:53d6\:308c\:306a\:3044 = \:9589\:3058\:305f\:3001\:3067\:306f\:306a\:3044) *)
  nbs = Quiet[Notebooks[]];
  If[Head[nb] =!= NotebookObject || (ListQ[nbs] && !MemberQ[nbs, nb]),
    iSWPlayHalt[]; Return[Null]];
  now = AbsoluteTime[];
  If[iSWPlayRealtimeQ[],
    (* Realtime: \:8aad\:307f\:7d42\:308f\:308a\:306f\:30ef\:30fc\:30ab\:30fc\:306e narrationDone (\:5b9f\:969b\:306b\:9cf4\:308a\:7d42\:308f\:3063\:305f\:5370) \:3067\:898b\:308b\:3002
       \:7de0\:5207\:306f\:8fd4\:4e8b\:304c\:6765\:306a\:3044\:3068\:304d\:306e\:4fdd\:967a *)
    rt = iSWRealtimeStatus[];
    If[!TrueQ[Lookup[rt, "Running", False]],
      iSWPlayFailReason[iSL["\:97f3\:58f0\:4f1a\:8a71\:304c\:6b62\:307e\:308a\:307e\:3057\:305f (SourceVaultRealtimeStatus[] \:3092\:78ba\:8a8d)",
        "The realtime bridge stopped (see SourceVaultRealtimeStatus[])"]];
      Return[Null]];
    If[StringQ[$iSWPlayState["NarrationId"]],
      If[Lookup[rt, "NarrationDone", None] === $iSWPlayState["NarrationId"],
        $iSWPlayState["NarrationId"] = None;
        $iSWPlayState["AudioEnd"] = now;
        (* \:8aad\:307f\:7d42\:308f\:308a\:3002\:3053\:3053\:3067\:30de\:30a4\:30af\:3092\:958b\:3051\:3066\:8cea\:554f\:3092\:5f85\:3064 *)
        $iSWPlayState["WindowStart"] = now;
        iSWRealtimeMic[True];
        $iSWPlayState["Deadline"] = now + $SlideVoiceGap + iSWQuestionWindow[],
        (* \:307e\:3060\:8aad\:3093\:3067\:3044\:308b\:6700\:4e2d\:306b\:7de0\:5207\:304c\:6765\:3066\:3082\:6253\:3061\:5207\:3089\:306a\:3044\:3002\:7de0\:5207\:306f\:300c\:8fd4\:4e8b\:304c
           \:6765\:306a\:304f\:306a\:3063\:305f\:300d\:3068\:304d\:306e\:4fdd\:967a\:3067\:3042\:3063\:3066\:3001\:8a71\:306e\:9577\:3055\:306e\:4e0a\:9650\:3067\:306f\:306a\:3044 *)
        If[now >= $iSWPlayState["Deadline"] &&
            (TrueQ[Lookup[rt, "Speaking", False]] ||
              Lookup[rt, "NarrationActive", None] === $iSWPlayState["NarrationId"]),
          $iSWPlayState["Deadline"] = now + 30.;
          $iSWPlayState["AudioEnd"] = now + 30.]],
      (* \:8aad\:307f\:4e0a\:3052\:306f\:7d42\:308f\:3063\:3066\:3044\:308b = \:8cea\:554f\:306e\:53d7\:4ed8\:4e2d\:3002\:8ab0\:304b\:304c\:8a71\:3057\:3066\:3044\:305f\:3089\:3001
         \:3084\:308a\:53d6\:308a\:304c\:7d42\:308f\:3063\:3066\:304b\:3089\:307e\:305f\:540c\:3058\:3060\:3051\:5f85\:3064 *)
      If[iSWRealtimeBusyQ[rt],
        If[now - $iSWPlayState["WindowStart"] < iSWQuestionMax[] ||
            iSWRealtimeAnsweringQ[rt],
          $iSWPlayState["Deadline"] = now + iSWQuestionWindow[];
          $iSWPlayState["AudioEnd"] = $iSWPlayState["Deadline"],
          (* \:7269\:97f3\:3067\:30de\:30a4\:30af\:304c\:958b\:304d\:7d9a\:3051\:3066\:3044\:308b: \:3044\:3064\:307e\:3067\:3082\:6b62\:307e\:3063\:3066\:3044\:3089\:308c\:306a\:3044 *)
          $iSWPlayState["Deadline"] = now]]],
    (* \:30ed\:30fc\:30ab\:30eb: \:7d42\:4e86\:306f AudioStream \:306e Position \:3067\:898b\:308b\:3002\:5b9f\:6e2c\:3067\:306f\:518d\:751f\:304c\:7d42\:308f\:3063\:3066\:3082
       Status \:306f "Playing" \:306e\:307e\:307e\:306a\:306e\:3067 Status \:3067\:306f\:5224\:5b9a\:3067\:304d\:306a\:3044\:3002\:58c1\:6642\:8a08\:306e
       Deadline \:306f Position \:304c\:53d6\:308c\:306a\:3044\:3068\:304d\:306e\:4fdd\:967a\:3002
       Position \:306f\:5b9f\:6642\:9593\:3068\:3057\:3066\:59a5\:5f53\:306a\:7bc4\:56f2 (\:58c1\:6642\:8a08\:7d4c\:904e+1s \:4ee5\:5185) \:306e\:3068\:304d\:3060\:3051\:4fe1\:3058\:308b:
       \:30b5\:30f3\:30d7\:30eb\:6570\:306a\:3069\:3067\:8fd4\:308b\:7248\:304c\:3042\:3063\:3066\:3082\:65e9\:9001\:308a\:306b\:8aa4\:7206\:3057\:306a\:3044\:3002
       \:9006\:306b\:30b9\:30e9\:30a4\:30c9\:5207\:66ff\:76f4\:5f8c\:306f FE \:304c\:6b21\:30b9\:30e9\:30a4\:30c9\:306e\:63cf\:753b\:3067\:5fd9\:3057\:304f\:518d\:751f\:958b\:59cb\:304c\:6570\:79d2
       \:9045\:308c\:308b (\:5b9f\:6e2c 2026-08-26: \:672b\:5c3e\:304c\:5207\:308c\:3066\:6b21\:3078\:9001\:3089\:308c\:305f)\:3002\:518d\:751f\:304c\:307e\:3060\:9014\:4e2d\:306a\:3089
       \:5b9f\:969b\:306e\:6b8b\:308a\:6642\:9593\:307e\:3067 Deadline \:3092\:5ef6\:9577\:3059\:308b (\:66b4\:8d70\:4e0a\:9650\:3064\:304d) *)
    stream = $iSWPlayState["Stream"];
    If[Head[stream] === AudioStream && now < $iSWPlayState["AudioEnd"],
      pos = Quiet[QuantityMagnitude[stream["Position"]]];
      elapsed = now - $iSWPlayState["StartedAt"];
      If[NumericQ[pos] && pos <= elapsed + 1.0,
        (* \:4f4d\:7f6e\:304c\:9032\:3093\:3067\:3044\:308b\:304b\:3092\:8a18\:9332\:3059\:308b\:3002Position \:306f\:672b\:5c3e\:306e\:308f\:305a\:304b\:624b\:524d
           (\:30d0\:30c3\:30d5\:30a1\:7c92\:5ea6) \:3067\:98fd\:548c\:3057\:3066 Duration \:306b\:5c4a\:304b\:306a\:3044\:3053\:3068\:304c\:3042\:308a\:3001
           \:300c\:5c4a\:304f\:307e\:3067\:5ef6\:9577\:300d\:3060\:3068\:8aad\:307f\:7d42\:308f\:308a\:5f8c\:306b\:9577\:3044\:7121\:97f3\:304c\:51fa\:308b (\:5b9f\:6e2c 2026-08-26) *)
        If[pos > $iSWPlayState["LastPos"] + 0.01,
          $iSWPlayState["LastPos"] = pos;
          $iSWPlayState["LastPosAt"] = now];
        Which[
          pos >= $iSWPlayState["Duration"] - 0.25,
          (* \:5b9f\:8cea\:6700\:5f8c\:307e\:3067\:9cf4\:3063\:305f *)
          $iSWPlayState["AudioEnd"] = now;
          $iSWPlayState["Deadline"] = now + $SlideVoiceGap,
          now - $iSWPlayState["LastPosAt"] < 2.0,
          (* \:307e\:3060\:9032\:3093\:3067\:3044\:308b: \:5b9f\:6b8b\:308a\:6642\:9593\:3076\:3093\:306f\:7de0\:3081\:5207\:3089\:306a\:3044 (\:51fa\:3060\:3057\:306e\:9045\:308c\:5bfe\:7b56) *)
          $iSWPlayState["Deadline"] = Min[
            Max[$iSWPlayState["Deadline"],
              now + ($iSWPlayState["Duration"] - pos) + $SlideVoiceGap],
            $iSWPlayState["StartedAt"] + 2. $iSWPlayState["Duration"] + 10.];
          $iSWPlayState["AudioEnd"] = Min[
            Max[$iSWPlayState["AudioEnd"], now + ($iSWPlayState["Duration"] - pos)],
            $iSWPlayState["StartedAt"] + 2. $iSWPlayState["Duration"] + 10.],
          True,
          (* \:4f4d\:7f6e\:304c 2 \:79d2\:9032\:3093\:3067\:3044\:306a\:3044: \:9cf4\:308a\:7d42\:308f\:308a (\:307e\:305f\:306f\:6b7b\:3093\:3060\:30b9\:30c8\:30ea\:30fc\:30e0) \:6271\:3044 *)
          $iSWPlayState["AudioEnd"] = now;
          $iSWPlayState["Deadline"] = now + $SlideVoiceGap]]]];
  If[now >= $iSWPlayState["Deadline"], iSWPlayAdvance[]];
  Null];

(* \:5408\:6210\:3067\:30c6\:30a3\:30c3\:30af\:304c\:9577\:5f15\:304f\:3053\:3068\:304c\:3042\:308b\:306e\:3067\:591a\:91cd\:5b9f\:884c\:3092\:6b62\:3081\:308b\:3002
   \:4e07\:4e00\:30d5\:30e9\:30b0\:304c\:7acb\:3063\:305f\:307e\:307e\:843d\:3061\:3066\:3082 60 \:79d2\:3067\:56de\:5fa9\:3059\:308b *)
iSWPlayTick[] := Module[{now = AbsoluteTime[]},
  If[TrueQ[$iSWPlayBusy] && now - $iSWPlayBusySince < 60., Return[Null]];
  $iSWPlayBusy = True; $iSWPlayBusySince = now;
  iSWPlayTickBody[];
  $iSWPlayBusy = False;
  Null];

(* ---- \:516c\:958b API ---- *)

(* \:8d70\:3063\:3066\:3044\:306a\:3051\:308c\:3070\:8d77\:3053\:3059\:3002\:8d70\:3063\:3066\:3044\:3066\:3082\:58f0\:304c\:9055\:3048\:3070\:5165\:308c\:76f4\:3059 (Realtime \:306e\:58f0\:306f
   \:30bb\:30c3\:30b7\:30e7\:30f3\:958b\:59cb\:5f8c\:306b\:306f\:5909\:3048\:3089\:308c\:306a\:3044)\:3002\:81ea\:5206\:3067\:8d77\:3053\:3057\:305f\:304b\:3069\:3046\:304b\:3092\:899a\:3048\:3066\:304a\:304d\:3001
   \:7d42\:4e86\:6642\:306b\:5229\:7528\:8005\:306e\:30bb\:30c3\:30b7\:30e7\:30f3\:307e\:3067\:5dfb\:304d\:8fbc\:307e\:306a\:3044\:3088\:3046\:306b\:3059\:308b\:3002 *)
iSWEnsureRealtimeBridge[nb_, voiceName_String] := Module[{st, res},
  st = iSWRealtimeStatus[];
  If[TrueQ[Lookup[st, "Running", False]],
    (* \:58f0\:304c\:540c\:3058\:3067\:3001\:304b\:3064\:30ef\:30fc\:30ab\:30fc\:304c\:4eca\:306e\:5951\:7d04\:306a\:3089\:4f7f\:3044\:56de\:3059\:3002\:53e4\:3044\:30ef\:30fc\:30ab\:30fc\:306f
       \:77e5\:3089\:306a\:3044\:30b3\:30de\:30f3\:30c9 (narrate) \:3092\:9ed9\:3063\:3066\:6368\:3066\:308b\:306e\:3067\:5165\:308c\:76f4\:3059 *)
    If[Lookup[st, "Voice", ""] === voiceName &&
        Lookup[st, "WorkerVersion", None] ===
          SourceVault`$SourceVaultRealtimeWorkerVersion,
      Return[<|"Status" -> "Reused", "Voice" -> voiceName|>]];
    Quiet[SourceVault`SourceVaultRealtimeStop[]];
    $iSWPlayState["StartedBridge"] = False];
  (* \:30df\:30e5\:30fc\:30c8\:3057\:306a\:3044: \:8aad\:307f\:4e0a\:3052\:4e2d\:306f\:534a\:4e8c\:91cd\:30b2\:30fc\:30c8\:304c\:30de\:30a4\:30af\:3092\:6b62\:3081\:308b\:306e\:3067\:5272\:308a\:8fbc\:307e\:308c\:305a\:3001
     \:8aad\:307f\:7d42\:3048\:305f\:5408\:9593\:3060\:3051\:8cea\:554f\:304c\:5c4a\:304f\:3002\:30df\:30e5\:30fc\:30c8\:3057\:3066\:3044\:308b\:3068\:8cea\:554f\:3067\:304d\:306a\:3044 *)
  res = Quiet[SourceVault`SourceVaultRealtimeStart[
    "Notebook" -> nb, "Voice" -> voiceName, "StartMuted" -> False,
    "SlideControl" -> True, "InputLevelGate" -> iSWInputGate[],
    "Instructions" -> iSWRealtimeSessionInstructions[]]];
  If[FailureQ[res] || res === $Failed, Return[res]];
  $iSWPlayState["StartedBridge"] = True;
  iSWRefreshTalkLabel[];
  res];

(* \:539f\:7a3f\:30e1\:30bf (SlideTalkMeta / talk md front matter) \:306e NarrationInstructions \:306f\:3001
   1 \:679a\:3054\:3068\:306e\:8aad\:307f\:4e0a\:3052\:6307\:793a\:306b\:305d\:306e\:307e\:307e\:8db3\:3059 *)
iSWTalkNarrationInstructions[nb_] := Module[{talk},
  talk = iSWTalkResolve[nb];
  If[!AssociationQ[talk], Return[""]];
  With[{s = Lookup[talk, "NarrationInstructions", ""]},
    If[StringQ[s], s, ""]]];

SlidePlayStatus[] := <|
  "Status" -> $iSWPlayState["Status"],
  "Slide" -> $iSWPlayState["Slide"],
  "SlideCount" -> $iSWPlayState["Count"],
  "Voice" -> $iSWPlayState["Voice"],
  "Engine" -> $iSWPlayState["Engine"],
  "NarrationId" -> $iSWPlayState["NarrationId"],
  "SecondsToDeadline" -> If[$iSWPlayState["Status"] === "Playing",
    Round[$iSWPlayState["Deadline"] - AbsoluteTime[], 0.1], None],
  "TickTaskRunning" -> (Head[$iSWPlayState["Task"]] === TaskObject),
  "SlideNumberFE" -> With[{nb = $iSWPlayState["Notebook"]},
    If[Head[nb] === NotebookObject, iSWSlideNumberFE[nb], None]],
  "Notebook" -> $iSWPlayState["Notebook"],
  "CacheDirectory" -> With[{nb = $iSWPlayState["Notebook"]},
    If[Head[nb] === NotebookObject, iSWVoiceCacheDir[nb], None]],
  "LastFailure" -> $iSWPlayState["LastFailure"]|>;

SlidePlay[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlidePlay[nb],
    MessageDialog[iSL["\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002", "No notebook found."]]; $Failed]];

SlidePlay[nb_NotebookObject] := Module[
  {voice, engine, texts, count, feCount, feN, start, bridge},
  If[$iSWPlayState["Status"] === "Playing", Return[SlidePlayStatus[]]];
  If[$iSWPlayState["Status"] === "Paused" && $iSWPlayState["Notebook"] === nb,
    Return[iSWPlayResume[]]];
  iSWPlayHalt[];
  voice = iSWVoiceName[];
  If[!StringQ[voice],
    MessageDialog[iSL["\:4f7f\:3048\:308b\:58f0\:304c\:3042\:308a\:307e\:305b\:3093\:3002\n", "No voice is available.\n"] <>
      iSWVoiceHint[]];
    Return[$Failed]];
  If[!iSWEngineReadyQ[voice],
    MessageDialog[iSL["\:3053\:306e\:58f0\:3092\:4f7f\:3048\:308b\:72b6\:614b\:3067\:306f\:3042\:308a\:307e\:305b\:3093\:3002\n",
      "This voice is not ready.\n"] <> iSWEngineHint[voice]];
    Return[$Failed]];
  If[!iSWEnsureLocalVoice[nb, voice],
    iSWEnsureVoiceFailDialog[voice];
    Return[$Failed]];
  If[!iSWSlideShowQ[nb],
    MessageDialog[iSL[
      "\:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883\:304c SlideShow \:3067\:306f\:3042\:308a\:307e\:305b\:3093\:3002\:66f8\:5f0f > \:30b9\:30af\:30ea\:30fc\:30f3\:74b0\:5883 > SlideShow \:306b\:3057\:3066\:304b\:3089\:518d\:751f\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
      "The screen environment is not SlideShow. Switch to Format > Screen Environment > SlideShow first."]];
    Return[$Failed]];
  texts = iSWVoiceTexts[nb];
  If[texts === $Failed,
    MessageDialog[iSL[
      "\:767a\:8868\:306e\:539f\:7a3f\:304c\:3042\:308a\:307e\:305b\:3093\:3002\:30b9\:30e9\:30a4\:30c9\:306b\:30c8\:30fc\:30af\:30bb\:30eb\:3092\:4f5c\:308b\:304b (\:633f\:5165 > \:30c8\:30fc\:30af\:3001\:307e\:305f\:306f\:5c55\:958b)\:3001\:300c\:30b7\:30ca\:30ea\:30aa\:300d\:3067 " <>
        FileNameTake[SlideTalkFile[nb]] <> " \:3092\:4f5c\:6210\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
      "No narration found. Add in-slide talk cells (Insert > Talk, or expand), or press \"Talk\" to write " <>
        FileNameTake[SlideTalkFile[nb]] <> "."]];
    Return[$Failed]];
  count = Max[Keys[texts]];
  feCount = iSWSlideCountOf[nb];
  If[IntegerQ[feCount] && feCount > 0, count = Min[count, feCount]];
  feN = iSWSlideNumberFE[nb];
  start = If[IntegerQ[feN] && 1 <= feN <= count, feN, 1];
  engine = If[iSWVoiceRealtimeQ[voice], "Realtime", "Local"];
  $iSWSlideControlNotebook = nb;
  $iSWPlayState["Notebook"] = nb;
  $iSWPlayState["Texts"] = texts;
  $iSWPlayState["Count"] = count;
  $iSWPlayState["Voice"] = voice;
  $iSWPlayState["Engine"] = engine;
  $iSWPlayState["Run"] = $iSWPlayState["Run"] + 1;
  $iSWPlayState["Instructions"] = iSWTalkNarrationInstructions[nb];
  $iSWPlayState["UseFECounter"] = IntegerQ[feN];
  $iSWPlayState["LastFailure"] = None;
  If[engine === "Realtime",
    bridge = iSWEnsureRealtimeBridge[nb, iSWRealtimeVoiceOf[voice]];
    If[FailureQ[bridge] || bridge === $Failed,
      $iSWPlayState["LastFailure"] = bridge;
      MessageDialog[iSL["\:97f3\:58f0\:4f1a\:8a71\:3092\:958b\:59cb\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f:\n",
        "Could not start the realtime bridge:\n"] <> iSWFailureText[bridge]];
      Return[$Failed]]];
  $iSWPlayState["Status"] = "Playing";
  iSWPlayLabelPause[];
  iSWRemoteAutoStart[];
  Quiet[SetSelectedNotebook[nb]];
  iSWPlaySlide[start];
  If[$iSWPlayState["Status"] === "Playing", iSWPlayStartTask[]];
  SlidePlayStatus[]];

SlidePause[] := Module[{s, now = AbsoluteTime[]},
  If[$iSWPlayState["Status"] =!= "Playing", Return[SlidePlayStatus[]]];
  If[iSWPlayRealtimeQ[],
    (* Realtime \:306f\:9014\:4e2d\:3067\:6b62\:3081\:305f\:7d9a\:304d\:304b\:3089\:8a71\:305b\:306a\:3044\:306e\:3067\:3001\:3044\:307e\:8a00\:3063\:3066\:3044\:308b\:5206\:3092\:5207\:308b *)
    Quiet[SourceVault`SourceVaultRealtimeCancel[]];
    $iSWPlayState["NarrationId"] = None,
    s = $iSWPlayState["Stream"];
    If[Head[s] === AudioStream, Quiet[AudioPause[s]]]];
  iSWPlayStopTask[];
  $iSWPlayState["Remaining"] = Max[0., $iSWPlayState["Deadline"] - now];
  $iSWPlayState["Status"] = "Paused";
  iSWPlayLabelResume[];
  iSWPlayNote[iSL["\:4e00\:6642\:505c\:6b62", "Paused"]];
  SlidePlayStatus[]];

iSWPlayResume[] := Module[{s, now = AbsoluteTime[], pos, rest},
  If[iSWPlayRealtimeQ[],
    (* \:9014\:4e2d\:304b\:3089\:306f\:518d\:958b\:3067\:304d\:306a\:3044\:306e\:3067\:3001\:305d\:306e 1 \:679a\:3092\:982d\:304b\:3089\:8aad\:307f\:76f4\:3059 *)
    $iSWPlayState["Status"] = "Playing";
    iSWPlayLabelPause[];
    iSWPlaySlide[$iSWPlayState["Slide"]];
    If[$iSWPlayState["Status"] === "Playing", iSWPlayStartTask[]];
    With[{nb = $iSWPlayState["Notebook"]},
      If[Head[nb] === NotebookObject, Quiet[SetSelectedNotebook[nb]]]];
    Return[SlidePlayStatus[]]];
  s = $iSWPlayState["Stream"];
  rest = Max[0., $iSWPlayState["Remaining"] - $SlideVoiceGap];
  If[Head[s] === AudioStream,
    pos = Quiet[QuantityMagnitude[s["Position"]]];
    If[NumericQ[pos], rest = Max[0., $iSWPlayState["Duration"] - pos]];
    Quiet[AudioPlay[s]]];
  $iSWPlayState["StartedAt"] = now;
  $iSWPlayState["AudioEnd"] = now + rest;
  $iSWPlayState["Deadline"] = now + rest + $SlideVoiceGap;
  $iSWPlayState["LastPos"] = If[NumericQ[pos], pos, 0.];
  $iSWPlayState["LastPosAt"] = now;
  $iSWPlayState["Status"] = "Playing";
  iSWPlayLabelPause[];
  iSWPlayStartTask[];
  With[{nb = $iSWPlayState["Notebook"]},
    If[Head[nb] === NotebookObject, Quiet[SetSelectedNotebook[nb]]]];
  iSWPlayNote["\[FilledRightTriangle] " <> ToString[$iSWPlayState["Slide"]] <> "/" <>
    ToString[$iSWPlayState["Count"]]];
  SlidePlayStatus[]];

SlideStop[] := (
  iSWPlayNote[iSL["\:8aad\:307f\:4e0a\:3052\:3092\:6b62\:3081\:307e\:3057\:305f", "Narration stopped"]];
  iSWPlayHalt[];
  iSWRemoteAutoStop[];
  With[{nb = $iSWPlayState["Notebook"]},
    If[Head[nb] === NotebookObject, iSWStatusClearLater[nb]]];
  SlidePlayStatus[]);

SlideVoicePrepare[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideVoicePrepare[nb],
    Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>]]];

SlideVoicePrepare[nb_NotebookObject] := Module[{texts, keys, ok = 0, ng = 0, i = 0},
  If[iSWVoiceRealtimeQ[iSWVoiceName[]],
    Return[Failure["SlideVoiceRealtimeNoPrepare",
      <|"MessageTemplate" -> "\:30af\:30e9\:30a6\:30c9\:97f3\:58f0 (realtime:...) \:306f\:4e8b\:524d\:5408\:6210\:3067\:304d\:307e\:305b\:3093\:3002\:30ed\:30fc\:30ab\:30eb\:306e\:58f0\:3092\:9078\:3093\:3067\:304b\:3089\:5b9f\:884c\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  If[!iSWVoiceReadyQ[],
    Return[Failure["SlideVoiceUnavailable",
      <|"MessageTemplate" -> iSWVoiceHint[]|>]]];
  If[!iSWEnsureLocalVoice[nb, iSWVoiceName[]],
    Return[Failure["SlideVoiceUnavailable",
      <|"MessageTemplate" ->
        "\:58f0\:3092\:4f7f\:3048\:308b\:72b6\:614b\:306b\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f (\:97f3\:58f0\:30a8\:30f3\:30b8\:30f3\:304c\:8d77\:52d5\:3057\:3066\:3044\:306a\:3044?)\:3002SourceVaultVoiceAivisStatus[] \:3092\:78ba\:8a8d\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  texts = iSWVoiceTexts[nb];
  If[texts === $Failed,
    Return[Failure["SlideTalkMissing",
      <|"MessageTemplate" ->
        "no talk (neither in-slide talk cells nor " <> SlideTalkFile[nb] <> ")"|>]]];
  keys = Sort[Keys[texts]];
  Do[
    i++;
    iSWStatus[nb, iSL["\:97f3\:58f0\:3092\:7528\:610f\:4e2d ", "Preparing audio "] <> ToString[i] <> "/" <>
      ToString[Length[keys]]];
    If[iSWVoiceFileFor[nb, k, texts[k]] === $Failed, ng++, ok++],
    {k, keys}];
  iSWStatus[nb, iSL["\:97f3\:58f0\:306e\:7528\:610f\:304c\:7d42\:308f\:308a\:307e\:3057\:305f: ", "Audio ready: "] <> ToString[ok] <>
    If[ng > 0, iSL[" (\:5931\:6557 ", " (failed "] <> ToString[ng] <> ")", ""]];
  iSWStatusClearLater[nb];
  <|"Status" -> If[ng === 0, "OK", "Partial"], "Prepared" -> ok, "Failed" -> ng,
    "Voice" -> iSWVoiceName[], "Directory" -> iSWVoiceCacheDir[nb]|>];

(* \:30d1\:30ec\:30c3\:30c8\:306e 1 \:30dc\:30bf\:30f3\:3067 \:518d\:751f <-> \:4e00\:6642\:505c\:6b62 \:3092\:5f80\:5fa9\:3059\:308b *)
iSWPlayToggleAction[nb_] := If[$iSWPlayState["Status"] === "Playing",
  SlidePause[], SlidePlay[nb]];

(* ---- \:30d1\:30ec\:30c3\:30c8\:52d5\:4f5c ---- *)

iSWTalkBuildAction[nb_] := Module[{src, out, res, title},
  src = iSWDeckSource[nb];
  If[iSWUnsavedQ[nb] && !StringQ[src],
    (* \:672a\:4fdd\:5b58\:3067\:3082\:30bb\:30eb\:5f0f\:304b\:3089\:4f5c\:308c\:308b\:3002\:305f\:3060\:3057\:51fa\:529b\:5148\:306f\:30c7\:30c3\:30ad\:540d\:304b\:3089\:6c7a\:3081\:305f\:3044\:306e\:3067\:8b66\:544a *)
    iSWStatus[nb, iSL["\:672a\:4fdd\:5b58\:3067\:3059\:3002\:4fdd\:5b58\:3057\:3066\:304b\:3089\:5b9f\:884c\:3059\:308b\:3068\:539f\:7a3f\:306e\:7f6e\:304d\:5834\:6240\:304c\:6c7a\:307e\:308a\:307e\:3059",
      "Unsaved: save the deck first so the talk file lands next to it"]]];
  out = SlideTalkFile[nb];
  title = StringReplace[FileBaseName[out], "_talk" ~~ EndOfString -> ""];
  iSWStatus[nb, iSL["\:767a\:8868\:30b7\:30ca\:30ea\:30aa\:3092\:751f\:6210\:4e2d...", "Generating the talk scenario..."]];
  res = SlideTalkBuild[src, "Output" -> out, "Notebook" -> nb, "OpenResult" -> True,
    "Title" -> title];
  If[AssociationQ[res] && res["Status"] === "Skeleton",
    iSWStatus[nb, iSL["\:9aa8\:683c\:3092\:66f8\:304d\:51fa\:3057\:307e\:3057\:305f (LLM \:672a\:4f7f\:7528): " <> FileNameTake[out],
      "Wrote the skeleton (no LLM): " <> FileNameTake[out]]];
    iSWStatusClearLater[nb]];
  If[AssociationQ[res] && res["Status"] === "FromCells",
    iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:304b\:3089\:539f\:7a3f\:3092\:675f\:306d\:307e\:3057\:305f: " <> FileNameTake[out],
      "Wrote the talk from in-slide talk cells: " <> FileNameTake[out]]];
    iSWStatusClearLater[nb]];
  res];

(* \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304b\:3089\:76f4\:63a5\:767b\:9332\:3059\:308b (\:30c8\:30fc\:30af\:30bb\:30eb + SlideTalkMeta)\:3002md \:30d5\:30a1\:30a4\:30eb\:306f
   \:30c8\:30fc\:30af\:30bb\:30eb\:306e\:7121\:3044\:65e7\:30c7\:30c3\:30ad\:306e\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af\:3068\:3057\:3066 SlideDeckRegister \:5074\:304c\:8aad\:3080 *)
iSWTalkRegisterAction[nb_] := Module[{res},
  res = SlideDeckRegister[nb];
  If[FailureQ[res],
    MessageDialog[Lookup[Last[res], "MessageTemplate", ToString[res]]];
    Return[res]];
  iSWStatus[nb, iSL[
    "\:767b\:9332\:3057\:307e\:3057\:305f: " <> ToString[Lookup[res, "Title", "?"]] <> " -> " <>
      ToString[Lookup[res, "SlideURL", "?"]],
    "Registered: " <> ToString[Lookup[res, "Title", "?"]]]];
  iSWStatusClearLater[nb];
  res];

(* ===================== \:624b\:5143\:30ea\:30e2\:30b3\:30f3 (\:30e1\:30c7\:30a3\:30a2\:30ad\:30fc) ===================== *)

(* Elecom Relacon \:306e\:3088\:3046\:306a\:624b\:5143\:30c7\:30d0\:30a4\:30b9\:306e\:30dc\:30bf\:30f3\:3092\:3001\:767a\:8868\:306e\:64cd\:4f5c\:306b\:5272\:308a\:5f53\:3066\:308b\:3002
   \:65e2\:5b9a\:306f\:300c\:524d\:306e\:66f2\:300d= \:30de\:30a4\:30af\:306e mute/unmute\:3001\:300c\:518d\:751f/\:4e00\:6642\:505c\:6b62\:300d= \:8aad\:307f\:4e0a\:3052\:306e
   \:518d\:751f/\:4e00\:6642\:505c\:6b62 ($SlideRemoteBindings)\:3002

   \:306a\:305c\:3053\:306e\:5f62\:304b:
     Windows \:306f HID \:306e Consumer Control (\:518d\:751f/\:4e00\:6642\:505c\:6b62\:30fb\:97f3\:91cf\:30fb\:66f2\:9001\:308a\:306a\:3069) \:3092
     \:4eee\:60f3\:30ad\:30fc\:306e\:30ad\:30fc\:5165\:529b\:3068\:3057\:3066\:4f9b\:7d66\:3059\:308b\:3002\:518d\:751f/\:4e00\:6642\:505c\:6b62\:306f VK_MEDIA_PLAY_PAUSE
     (16^^B3)\:3001\:524d\:306e\:66f2\:306f VK_MEDIA_PREV_TRACK (16^^B1)\:3002user32.dll \:306e
     GetAsyncKeyState \:306f\:300c\:524d\:56de\:554f\:3044\:5408\:308f\:305b\:3066\:304b\:3089\:62bc\:3055\:308c\:305f\:304b\:300d\:3092 bit0 \:3067\:8fd4\:3057\:3001
     \:3069\:306e\:7a93\:306b\:30d5\:30a9\:30fc\:30ab\:30b9\:304c\:3042\:3063\:3066\:3082\:7b54\:3048\:308b\:3002\:3060\:304b\:3089\:30b9\:30e9\:30a4\:30c9\:3092\:5168\:753b\:9762\:8868\:793a\:3057\:305f
     \:307e\:307e\:3067\:3082\:3001\:30d5\:30ed\:30f3\:30c8\:30a8\:30f3\:30c9\:306e\:30ad\:30fc\:30a4\:30d9\:30f3\:30c8\:3092\:4e00\:5207\:7d4c\:7531\:305b\:305a\:306b\:30dc\:30bf\:30f3\:3092\:62fe\:3048\:308b\:3002

   \:306a\:305c NETLink \:3067\:306f\:306a\:304f ForeignFunctionLoad \:304b (\:5b9f\:6e2c\:3057\:3066\:6c7a\:3081\:305f):
     \:898b\:5f35\:308a\:306f ScheduledTask = preemptive computation \:3067\:56de\:3059\:3002.NET/Link \:306f
     preemptive computation \:304b\:3089\:547c\:3079\:306a\:3044 (NET::preemptive \:304c\:51fa\:3066\:6bce\:56de\:5931\:6557\:3059\:308b\:3002
     2026-08-23 \:5b9f\:6e2c: 13 tick \:3059\:3079\:3066\:5931\:6557)\:3002\:30d7\:30ed\:30bb\:30b9\:5185 FFI \:306e
     ForeignFunctionLoad \:306f preemptive \:3067\:3082\:901a\:308a\:3001\:3057\:304b\:3082 1 \:56de 3.7us \:3068
     .NET/Link \:306e 110us \:3088\:308a 30 \:500d\:901f\:3044\:3002\:3060\:304b\:3089 user32.dll \:3092\:76f4\:63a5\:958b\:304f\:3002

   \:4ed5\:7d44\:307f\:4e0a\:306e\:9650\:754c (\:627f\:77e5\:306e\:4e0a\:3067\:4f7f\:3046\:3053\:3068):
     - \:62bc\:4e0b\:306f Windows \:306e\:30e1\:30c7\:30a3\:30a2\:5236\:5fa1\:306b\:3082\:540c\:6642\:306b\:5c4a\:304f\:3002\:30b9\:30e9\:30a4\:30c9\:3067\:52d5\:753b\:3092\:518d\:751f\:3057\:3066
       \:3044\:308b\:3068\:3001\:305d\:308c\:3082\:4e00\:7dd2\:306b\:6b62\:307e\:308b/\:66f2\:9001\:308a\:3055\:308c\:308b\:3002\:62bc\:4e0b\:3092\:596a\:3046 (suppress) \:306b\:306f
       \:4f4e\:30ec\:30d9\:30eb\:30ad\:30fc\:30d5\:30c3\:30af (WH_KEYBOARD_LL) \:304c\:8981\:308a\:3001\:3053\:306e\:5c64\:306f\:305d\:308c\:3092\:6301\:305f\:306a\:3044\:3002
     - \:3069\:306e\:4eee\:60f3\:30ad\:30fc\:304c\:51fa\:308b\:304b\:306f\:30c7\:30d0\:30a4\:30b9\:6b21\:7b2c\:3002SlideRemoteProbe[] \:3067\:5b9f\:6e2c\:3057\:3066\:304b\:3089
       $SlideRemoteBindings \:306b\:5165\:308c\:308b\:3002
     - \:8aad\:307f\:4e0a\:3052\:4e2d\:306e\:30de\:30a4\:30af\:306e\:958b\:9589\:306f\:534a\:4e8c\:91cd\:30b2\:30fc\:30c8 (iSWRealtimeMic) \:304c\:63e1\:3063\:3066\:3044\:308b\:3002
       \:624b\:3067\:5207\:308a\:66ff\:3048\:3066\:3082\:3001\:6b21\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:8aad\:307f\:4e0a\:3052\:304c\:59cb\:307e\:308b\:6642\:70b9\:3067\:30b2\:30fc\:30c8\:5074\:306b\:623b\:308b\:3002
     - Windows \:5c02\:7528\:3002\:305d\:308c\:4ee5\:5916\:3067\:306f\:898b\:5f35\:308a\:3092\:59cb\:3081\:3088\:3046\:3068\:3059\:308b\:3068 Failure \:3092\:8fd4\:3059\:3002
*)

$iSWVKNames = Join[
  <|16^^08 -> "Backspace", 16^^09 -> "Tab", 16^^0D -> "Enter",
    16^^10 -> "Shift", 16^^11 -> "Ctrl", 16^^12 -> "Alt", 16^^13 -> "PauseBreak",
    16^^14 -> "CapsLock", 16^^1B -> "Esc", 16^^20 -> "Space",
    16^^21 -> "PageUp", 16^^22 -> "PageDown", 16^^23 -> "End", 16^^24 -> "Home",
    16^^25 -> "Left", 16^^26 -> "Up", 16^^27 -> "Right", 16^^28 -> "Down",
    16^^2C -> "PrintScreen", 16^^2D -> "Insert", 16^^2E -> "Delete",
    16^^5B -> "LWin", 16^^5C -> "RWin", 16^^5D -> "Apps",
    16^^A0 -> "LShift", 16^^A1 -> "RShift", 16^^A2 -> "LCtrl", 16^^A3 -> "RCtrl",
    16^^A4 -> "LAlt", 16^^A5 -> "RAlt",
    16^^A6 -> "BrowserBack", 16^^A7 -> "BrowserForward", 16^^A8 -> "BrowserRefresh",
    16^^A9 -> "BrowserStop", 16^^AA -> "BrowserSearch", 16^^AB -> "BrowserFavorites",
    16^^AC -> "BrowserHome", 16^^AD -> "VolumeMute", 16^^AE -> "VolumeDown",
    16^^AF -> "VolumeUp", 16^^B0 -> "MediaNextTrack", 16^^B1 -> "MediaPrevTrack",
    16^^B2 -> "MediaStop", 16^^B3 -> "MediaPlayPause", 16^^B4 -> "LaunchMail",
    16^^B5 -> "LaunchMediaSelect", 16^^B6 -> "LaunchApp1", 16^^B7 -> "LaunchApp2",
    16^^FA -> "MediaPlay", 16^^FB -> "Zoom"|>,
  Association[Table[16^^70 + i - 1 -> "F" <> ToString[i], {i, 24}]],
  Association[Table[16^^30 + i -> "Digit" <> ToString[i], {i, 0, 9}]],
  Association[Table[16^^41 + i -> FromCharacterCode[16^^41 + i], {i, 0, 25}]]];

$iSWVKByName = Association[
  ToLowerCase[Last[#]] -> First[#] & /@ Normal[$iSWVKNames]];

iSWVKName[vk_Integer] :=
  Lookup[$iSWVKNames, vk, "VK_" <> ToUpperCase[IntegerString[vk, 16, 2]]];

(* \:4eee\:60f3\:30ad\:30fc\:306e\:6307\:5b9a\:3092\:756a\:53f7\:3078\:3002\:756a\:53f7 / \:540d\:524d ("MediaPrevTrack") / "0xB1" \:3092\:53d7\:3051\:308b *)
iSWVKCode[spec_] := Which[
  IntegerQ[spec] && 1 <= spec <= 16^^FE, spec,
  StringQ[spec] && KeyExistsQ[$iSWVKByName, ToLowerCase[spec]],
    $iSWVKByName[ToLowerCase[spec]],
  StringQ[spec] && StringMatchQ[spec, ("0x" | "0X") ~~ HexadecimalCharacter ..],
    With[{v = FromDigits[StringDrop[spec, 2], 16]},
      If[1 <= v <= 16^^FE, v, None]],
  True, None];

(* ---- \:30dc\:30bf\:30f3\:306b\:5272\:308a\:5f53\:3066\:3089\:308c\:308b\:52d5\:4f5c ---- *)

$iSWRemoteActionNames = {"Mic", "Play", "Stop", "NextSlide", "PreviousSlide",
  "None"};

iSWRemoteActionName[a_] := SelectFirst[$iSWRemoteActionNames,
  ToLowerCase[#] === ToLowerCase[ToString[a]] &, None];

iSWRemoteActionLabel[a_String] := Switch[a,
  "Mic", iSL["\:30de\:30a4\:30af\:5207\:66ff", "mic toggle"],
  "Play", iSL["\:518d\:751f/\:4e00\:6642\:505c\:6b62", "play/pause"],
  "Stop", iSL["\:505c\:6b62", "stop"],
  "NextSlide", iSL["\:6b21\:306e\:30b9\:30e9\:30a4\:30c9", "next slide"],
  "PreviousSlide", iSL["\:524d\:306e\:30b9\:30e9\:30a4\:30c9", "previous slide"],
  _, a];

iSWLiveNotebookQ[nb_] := Head[nb] === NotebookObject &&
  TrueQ[Quiet[MemberQ[Notebooks[], nb]]];

(* \:8aad\:307f\:4e0a\:3052\:306e\:518d\:751f/\:4e00\:6642\:505c\:6b62\:3092\:3069\:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3078\:5411\:3051\:308b\:304b\:3002\:518d\:751f\:4e2d/\:4e00\:6642\:505c\:6b62\:4e2d\:306f
   \:305d\:306e\:76f8\:624b\:3067\:306a\:3051\:308c\:3070 SlidePlay \:304c\:300c\:7d9a\:304d\:304b\:3089\:300d\:306b\:306a\:3089\:306a\:3044\:306e\:3067\:3001\:307e\:305a\:518d\:751f\:72b6\:614b\:304c
   \:899a\:3048\:3066\:3044\:308b\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:898b\:308b\:3002 *)
iSWRemoteTargetNb[] := Module[{nb},
  nb = $iSWPlayState["Notebook"];
  If[iSWLiveNotebookQ[nb], Return[nb]];
  nb = $iSWSlideControlNotebook;
  If[iSWLiveNotebookQ[nb], Return[nb]];
  nb = Quiet[iSWResolveTargetNb[]];
  If[iSWLiveNotebookQ[nb], nb, $Failed]];

iSWRemotePlayToggle[] := With[{nb = iSWRemoteTargetNb[]},
  If[Head[nb] === NotebookObject, iSWPlayToggleAction[nb], $Failed]];

(* \:30dc\:30bf\:30f3\:304c\:62bc\:3055\:308c\:305f\:3068\:304d\:306b\:8d70\:308b\:306e\:306f\:3053\:3053\:3060\:3051\:3002\:30c0\:30a4\:30a2\:30ed\:30b0\:3092\:51fa\:3057\:3046\:308b\:306e\:306f
   SlidePlay \:306e\:5931\:6557\:7d4c\:8def\:3060\:304c\:3001MessageDialog \:306f\:30ab\:30fc\:30cd\:30eb\:3092\:5f85\:305f\:305b\:306a\:3044\:306e\:3067
   preemptive tick \:304b\:3089\:547c\:3093\:3067\:3082\:8a70\:307e\:3089\:306a\:3044\:3002 *)
iSWRemoteRun["Mic"] := iSWToggleMic[True];
iSWRemoteRun["Play"] := iSWRemotePlayToggle[];
iSWRemoteRun["Stop"] := Quiet[SlideStop[]];
iSWRemoteRun["NextSlide"] := Quiet[SlideShowSlide["Next"]];
iSWRemoteRun["PreviousSlide"] := Quiet[SlideShowSlide["Previous"]];
iSWRemoteRun[_] := Null;

(* ---- \:898b\:5f35\:308a ---- *)

$iSWRemoteKeyFn = None;      (* GetAsyncKeyState \:3078\:306e\:53e3 (ForeignFunction) *)
$iSWRemoteInit = False;      (* \:4e00\:5ea6\:3067\:3082\:7528\:610f\:3092\:8a66\:3057\:305f\:304b *)
$iSWRemoteHint = "";         (* \:4f7f\:3048\:306a\:3044\:3068\:304d\:306e\:7406\:7531 *)
$iSWRemoteTask = None;
$iSWRemoteMap = <||>;        (* \:4eee\:60f3\:30ad\:30fc\:756a\:53f7 -> \:52d5\:4f5c\:540d *)
$iSWRemoteLastFire = <||>;   (* \:4eee\:60f3\:30ad\:30fc\:756a\:53f7 -> \:6700\:5f8c\:306b\:767a\:706b\:3057\:305f\:6642\:523b *)
$iSWRemoteLastSync = 0.;

iSWUser32Path[] := Module[{root, p},
  root = Quiet[Check[Environment["SystemRoot"], $Failed]];
  If[! StringQ[root] || root === "", root = "C:\\Windows"];
  p = FileNameJoin[{root, "System32", "user32.dll"}];
  If[FileExistsQ[p], p, "C:\\Windows\\System32\\user32.dll"]];

(* user32.dll \:3092\:30d7\:30ed\:30bb\:30b9\:5185\:3067\:958b\:304f\:3002\:6700\:521d\:306b\:5fc5\:8981\:306b\:306a\:3063\:305f\:3068\:304d\:3060\:3051\:884c\:3046\:3002
   \:958b\:3051\:305f\:304b\:3069\:3046\:304b\:306f\:300cInteger \:304c\:8fd4\:3063\:3066\:304f\:308b\:304b\:300d\:3067\:5224\:5b9a\:3059\:308b (\:578b\:306e\:98df\:3044\:9055\:3044\:3092
   \:3053\:3053\:3067\:843d\:3068\:3059)\:3002\:3053\:306e 1 \:56de\:306e\:554f\:3044\:5408\:308f\:305b\:306f\:62bc\:4e0b bit \:3092 1 \:3064\:6d88\:8cbb\:3059\:308b\:304c\:3001
   \:898b\:5f35\:308a\:3092\:59cb\:3081\:308b\:524d\:306a\:306e\:3067\:5bb3\:306f\:306a\:3044\:3002 *)
iSWRemoteReady[] := (
  If[! TrueQ[$iSWRemoteInit],
    $iSWRemoteInit = True;
    Which[
      $OperatingSystem =!= "Windows",
        $iSWRemoteHint = iSL[
          "\:624b\:5143\:30ea\:30e2\:30b3\:30f3\:306e\:8a8d\:8b58\:306f Windows \:3067\:3060\:3051\:52d5\:304d\:307e\:3059 (user32.dll \:3092\:4f7f\:3046\:305f\:3081)\:3002",
          "Remote-button watching works only on Windows (it uses user32.dll)."],
      Names["System`ForeignFunctionLoad"] === {},
        $iSWRemoteHint = iSL[
          "\:3053\:306e\:7248\:306e Wolfram Language \:306b\:306f ForeignFunctionLoad \:304c\:3042\:308a\:307e\:305b\:3093\:3002",
          "This Wolfram Language version has no ForeignFunctionLoad."],
      True,
        Module[{path, fn},
          path = iSWUser32Path[];
          If[! FileExistsQ[path],
            $iSWRemoteHint = iSL["user32.dll \:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002",
              "user32.dll was not found."],
            fn = Quiet[Check[
              ForeignFunctionLoad[path, "GetAsyncKeyState", {"CInt"} -> "CShort"],
              $Failed]];
            If[fn === $Failed || FailureQ[fn] || ! IntegerQ[Quiet[fn[16^^B3]]],
              $iSWRemoteHint = iSL[
                "user32.dll \:306e GetAsyncKeyState \:3092\:958b\:3051\:307e\:305b\:3093\:3067\:3057\:305f\:3002",
                "Could not open GetAsyncKeyState in user32.dll."],
              $iSWRemoteKeyFn = fn;
              $iSWRemoteHint = ""]]]]];
  $iSWRemoteKeyFn =!= None);

(* GetAsyncKeyState \:306e bit0 = \:524d\:56de\:554f\:3044\:5408\:308f\:305b\:3066\:304b\:3089\:62bc\:3055\:308c\:305f\:304b\:3002\:8aad\:3080\:3068\:6d88\:3048\:308b\:3002
   \:3060\:304b\:3089\:5468\:671f\:304c\:9045\:304f\:3066\:3082\:62bc\:4e0b\:81ea\:4f53\:306f\:843d\:3061\:306a\:3044 (\:53cd\:5fdc\:304c\:9045\:308c\:308b\:3060\:3051)\:3002\:8fd4\:308a\:5024\:306f\:7b26\:53f7\:3064\:304d
   16bit \:306a\:306e\:3067\:62bc\:3057\:3063\:3071\:306a\:3057\:306e 16^^8000 \:306f\:8ca0\:6570\:3067\:6765\:308b\:3002\:3053\:3053\:306f bit0 \:3060\:3051\:3092\:898b\:308b\:3002 *)
iSWRemotePressedQ[vk_Integer] := If[$iSWRemoteKeyFn === None, False,
  With[{v = Quiet[$iSWRemoteKeyFn[vk]]},
    IntegerQ[v] && BitAnd[v, 1] =!= 0]];

iSWRemoteWatchingQ[] := Head[$iSWRemoteTask] === TaskObject;

(* <|key -> action|> / {key -> action, ..} \:3092 <|\:4eee\:60f3\:30ad\:30fc\:756a\:53f7 -> \:52d5\:4f5c\:540d|> \:3078\:3002
   \:8aad\:3081\:306a\:3044\:6307\:5b9a\:306f\:9ed9\:3063\:3066\:843d\:3068\:3059 (\:8aa4\:5b57\:3067\:898b\:5f35\:308a\:5168\:4f53\:304c\:6b7b\:306c\:307b\:3046\:304c\:56f0\:308b) *)
iSWRemoteResolveBindings[spec_] := Module[{pairs},
  pairs = Which[
    AssociationQ[spec], Normal[spec],
    MatchQ[spec, {___Rule}], spec,
    True, {}];
  Association[Cases[pairs,
    (k_ -> a_) :> With[{vk = iSWVKCode[k], act = iSWRemoteActionName[a]},
      If[IntegerQ[vk] && StringQ[act] && act =!= "None", vk -> act, Nothing]]]]];

iSWRemoteBindingsView[map_Association] :=
  Association[KeyValueMap[iSWVKName[#1] -> #2 &, map]];

Options[SlideRemoteStart] = {"Bindings" -> Automatic, "Tick" -> Automatic};

SlideRemoteStart[OptionsPattern[]] := Module[{map, tick, now},
  SlideRemoteStop[];
  If[! iSWRemoteReady[],
    Return[Failure["SlideRemoteUnavailable",
      <|"MessageTemplate" -> If[StringQ[$iSWRemoteHint] && $iSWRemoteHint =!= "",
          $iSWRemoteHint, "Remote buttons cannot be watched."]|>]]];
  map = iSWRemoteResolveBindings[
    Replace[OptionValue["Bindings"], Automatic :> $SlideRemoteBindings]];
  If[map === <||>,
    Return[Failure["SlideRemoteNoBindings",
      <|"MessageTemplate" -> "No usable button bindings ($SlideRemoteBindings)."|>]]];
  tick = Replace[OptionValue["Tick"], Automatic :> $SlideRemoteTick];
  tick = If[NumericQ[tick] && N[tick] >= 0.05, N[tick], 0.15];
  now = AbsoluteTime[];
  $iSWRemoteMap = map;
  Scan[iSWRemotePressedQ, Keys[map]];   (* \:6e9c\:307e\:3063\:3066\:3044\:305f\:62bc\:4e0b\:3092\:6368\:3066\:3066\:304b\:3089\:898b\:5f35\:308b *)
  $iSWRemoteLastFire = Association[# -> now & /@ Keys[map]];
  $iSWRemoteLastSync = now;
  $iSWRemoteTask = Quiet[SessionSubmit[ScheduledTask[iSWRemoteTick[], tick]]];
  If[Head[$iSWRemoteTask] =!= TaskObject,
    $iSWRemoteTask = None;
    Return[Failure["SlideRemoteTaskFailed",
      <|"MessageTemplate" -> "Could not submit the watching task."|>]]];
  <|"Status" -> "Watching", "Bindings" -> iSWRemoteBindingsView[map],
    "Tick" -> tick|>];

SlideRemoteStop[] := (
  If[iSWRemoteWatchingQ[], Quiet[TaskRemove[$iSWRemoteTask]]];
  $iSWRemoteTask = None;
  <|"Status" -> "Stopped"|>);

(* \:72b6\:614b\:3092\:898b\:308b\:3060\:3051\:3002\:3053\:3053\:3067 user32.dll \:3092\:958b\:304d\:306b\:3044\:304b\:306a\:3044 (\:60c5\:5831\:30a6\:30a4\:30f3\:30c9\:30a6\:304b\:3089\:547c\:3070\:308c\:308b) *)
SlideRemoteStatus[] := <|
  "Watching" -> iSWRemoteWatchingQ[],
  "Available" -> ($iSWRemoteKeyFn =!= None),
  "Checked" -> TrueQ[$iSWRemoteInit],
  "Bindings" -> iSWRemoteBindingsView[$iSWRemoteMap],
  "Tick" -> $SlideRemoteTick,
  "Hint" -> $iSWRemoteHint|>;

(* \:898b\:5f35\:308a\:306e\:672c\:4f53\:30021 tick = \:5272\:308a\:5f53\:3066\:305f\:30dc\:30bf\:30f3\:306e\:6570\:3060\:3051\:554f\:3044\:5408\:308f\:305b\:308b (1 \:56de 3.7us)\:3002
   \:30e9\:30d9\:30eb\:306e\:8ffd\:968f\:306f\:72b6\:614b\:30d5\:30a1\:30a4\:30eb\:306e\:8aad\:307f\:8fbc\:307f\:3092\:4f34\:3046\:306e\:3067 1.5 \:79d2\:306b 1 \:5ea6\:3060\:3051\:306b\:3059\:308b\:3002
   \:53d6\:308a\:3053\:307c\:3057\:3092\:9632\:3050\:305f\:3081\:3001\:62bc\:4e0b bit \:306f\:6bce tick \:3059\:3079\:3066\:306e\:30ad\:30fc\:306b\:3064\:3044\:3066\:8aad\:3080
   (\:62bc\:4e0b\:304c\:6291\:6b62\:3055\:308c\:308b\:306e\:306f\:540c\:3058\:30ad\:30fc\:306e\:9023\:6253\:3060\:3051)\:3002 *)
iSWRemoteTick[] := Module[{now = AbsoluteTime[]},
  KeyValueMap[
    Function[{vk, act},
      If[iSWRemotePressedQ[vk] &&
          now - Lookup[$iSWRemoteLastFire, vk, 0.] > 0.35,
        $iSWRemoteLastFire[vk] = now;
        iSWRemoteRun[act]]],
    $iSWRemoteMap];
  If[now - $iSWRemoteLastSync > 1.5,
    $iSWRemoteLastSync = now;
    iSWRemoteSyncLabels[]];
  Null];

iSWRemoteSyncLabels[] := Module[{st = iSWRealtimeStatus[]},
  $iSWTalkLabel = iSWTalkLabelText[Lookup[st, "Running", False]];
  iSWApplyMicLabel[st]];

(* \:898b\:5f35\:308a\:3092\:6301\:3064\:7406\:7531\:306f 2 \:3064 -- \:97f3\:58f0\:5fdc\:7b54\:304c\:52d5\:3044\:3066\:3044\:308b (\:30de\:30a4\:30af\:5207\:66ff) \:3068\:3001
   \:8aad\:307f\:4e0a\:3052\:304c\:9032\:3093\:3067\:3044\:308b (\:518d\:751f/\:4e00\:6642\:505c\:6b62)\:3002\:7247\:65b9\:3060\:3051\:6b62\:3081\:3066\:3082
   \:3082\:3046\:7247\:65b9\:304c\:7d9a\:3044\:3066\:3044\:308b\:9593\:306f\:898b\:5f35\:308a\:3092\:7d9a\:3051\:308b *)
iSWRemoteWantedQ[] := iSWRealtimeRunningQ[] ||
  MemberQ[{"Playing", "Paused"}, $iSWPlayState["Status"]];

iSWRemoteAutoStart[] := If[TrueQ[$SlideRemoteAuto] && iSWRemoteWantedQ[],
  Quiet[SlideRemoteStart[]]];

iSWRemoteAutoStop[] := If[TrueQ[$SlideRemoteAuto] && ! iSWRemoteWantedQ[],
  SlideRemoteStop[]];

(* ---- \:3069\:306e\:30dc\:30bf\:30f3\:304c\:3069\:306e\:4eee\:60f3\:30ad\:30fc\:3092\:51fa\:3059\:304b\:306e\:5b9f\:6e2c ---- *)

Options[SlideRemoteProbe] = {"Seconds" -> 10., "IncludeMouse" -> False,
  "View" -> False};

SlideRemoteProbe[OptionsPattern[]] := Module[
  {secs, vks, counts, deadline, resume = None, run, hits, best, suggestion},
  If[! iSWRemoteReady[],
    Return[<|"Status" -> "Unavailable", "Hits" -> {},
      "Suggestion" -> $iSWRemoteHint|>]];
  secs = With[{v = OptionValue["Seconds"]},
    If[NumericQ[v] && N[v] > 0., N[v], 10.]];
  vks = If[TrueQ[OptionValue["IncludeMouse"]],
    Range[16^^01, 16^^FE], Range[16^^07, 16^^FE]];
  (* \:898b\:5f35\:308a\:304c\:52d5\:3044\:3066\:3044\:308b\:3068\:62bc\:4e0b bit \:3092\:5148\:306b\:53d6\:3089\:308c\:308b\:3002\:6b62\:3081\:3066\:3001\:3042\:3068\:3067\:623b\:3059 *)
  If[iSWRemoteWatchingQ[], resume = $iSWRemoteMap; SlideRemoteStop[]];
  counts = <||>;
  Scan[iSWRemotePressedQ, vks];          (* \:6e9c\:307e\:3063\:3066\:3044\:305f\:62bc\:4e0b\:3092\:6368\:3066\:308b *)
  deadline = AbsoluteTime[] + secs;
  run[] := While[AbsoluteTime[] < deadline,
    Scan[Function[vk,
      If[iSWRemotePressedQ[vk], counts[vk] = Lookup[counts, vk, 0] + 1]], vks];
    Pause[0.03]];
  (* \:6b8b\:308a\:79d2\:6570\:306e\:8868\:793a\:306f FE \:304c\:3042\:308b\:3068\:304d\:3060\:3051\:3002\:7121\:3044\:3068\:3053\:308d\:3067 Monitor \:3059\:308b\:3068
     FrontEndObject::notavail \:304c\:51fa\:308b\:3060\:3051\:3067\:4f55\:306e\:5f79\:306b\:3082\:7acb\:305f\:306a\:3044 *)
  If[TrueQ[$Notebooks],
    Monitor[run[],
      Row[{iSL["\:30dc\:30bf\:30f3\:3092\:62bc\:3057\:3066\:304f\:3060\:3055\:3044 \[Ellipsis] \:6b8b\:308a ", "Press the button \[Ellipsis] "],
        Round[Max[0., deadline - AbsoluteTime[]]], iSL[" \:79d2", " s left"]}]],
    run[]];
  (* \:898b\:5f35\:308a\:3092\:6b62\:3081\:305f\:306e\:306f\:3053\:3061\:3089\:306e\:90fd\:5408\:306a\:306e\:3067\:3001\:5143\:306e\:5272\:308a\:5f53\:3066\:306e\:307e\:307e\:623b\:3059 *)
  If[AssociationQ[resume] && resume =!= <||>,
    Quiet[SlideRemoteStart["Bindings" -> resume]]];
  hits = SortBy[
    KeyValueMap[
      <|"VK" -> #1, "Hex" -> "0x" <> ToUpperCase[IntegerString[#1, 16, 2]],
        "Name" -> iSWVKName[#1], "Presses" -> #2|> &, counts],
    -#["Presses"] &];
  best = If[hits === {}, None, First[hits]];
  suggestion = If[best === None,
    iSL["\:4f55\:3082\:62fe\:3048\:307e\:305b\:3093\:3067\:3057\:305f\:3002\:305d\:306e\:30dc\:30bf\:30f3\:306f\:30e1\:30c7\:30a3\:30a2\:30ad\:30fc\:3092\:51fa\:3057\:3066\:3044\:306a\:3044\:304b\:3082\:3057\:308c\:307e\:305b\:3093\:3002",
      "Nothing was picked up. That button may not emit a media key at all."],
    "$SlideRemoteBindings[\"" <> best["Name"] <> "\"] = \"Mic\"; SlideRemoteStart[]"];
  If[TrueQ[OptionValue["View"]], Return[Dataset[hits]]];
  <|"Status" -> "OK", "Seconds" -> secs, "Hits" -> hits,
    "Suggestion" -> suggestion|>];

(* ---- \:30de\:30a4\:30af\:306e mute / unmute ---- *)

$iSWMicLabel = "\[EmptyCircle] Mic \[Dash]";
$iSWMicColor = GrayLevel[0.5];
$iSWMicIntentUntil = 0.;

iSWSetMicLabel[state_String] := Switch[state,
  "Live",
    ($iSWMicLabel = "\[FilledCircle] " <> iSL["\:30de\:30a4\:30afon", "Mic on"];
     $iSWMicColor = RGBColor[0.25, 0.55, 0.45]),
  "Muted",
    ($iSWMicLabel = "\[EmptyCircle] " <> iSL["\:30de\:30a4\:30afoff", "Mic off"];
     $iSWMicColor = RGBColor[0.6, 0.35, 0.35]),
  _,
    ($iSWMicLabel = "\[EmptyCircle] " <> iSL["\:30de\:30a4\:30af\[Dash]", "Mic \[Dash]"];
     $iSWMicColor = GrayLevel[0.5])];

(* \:30ef\:30fc\:30ab\:30fc\:304c\:72b6\:614b\:30d5\:30a1\:30a4\:30eb\:3092\:66f8\:304d\:623b\:3059\:307e\:3067\:6570\:767e\:30df\:30ea\:79d2\:304b\:304b\:308b\:3002\:5207\:308a\:66ff\:3048\:305f\:76f4\:5f8c\:306e
   \:77ed\:3044\:9593\:306f\:3001\:3053\:3061\:3089\:306e\:610f\:56f3\:3057\:305f\:8868\:793a\:3092\:4fdd\:3064 (\:62bc\:3057\:305f\:77ac\:9593\:306b\:5143\:3078\:623b\:3063\:3066\:898b\:3048\:306a\:3044\:3088\:3046\:306b) *)
iSWApplyMicLabel[st_Association] := If[AbsoluteTime[] >= $iSWMicIntentUntil,
  iSWSetMicLabel[
    If[! TrueQ[Lookup[st, "Running", False]], "Off",
      If[TrueQ[Lookup[st, "Muted", False]], "Muted", "Live"]]]];

iSWRefreshMicLabel[] := iSWApplyMicLabel[iSWRealtimeStatus[]];

iSWToggleMic[quiet_] := Module[{st, muted, res},
  If[! iSWRealtimeLayerQ[],
    If[! TrueQ[quiet],
      MessageDialog[iSL["SourceVault_realtime.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093\:3002",
        "SourceVault_realtime.wl is not loaded."]]];
    Return[$Failed]];
  st = iSWRealtimeStatus[];
  If[! TrueQ[Lookup[st, "Running", False]],
    $iSWMicIntentUntil = 0.;
    iSWSetMicLabel["Off"];
    If[! TrueQ[quiet],
      MessageDialog[iSL[
        "\:97f3\:58f0\:5fdc\:7b54\:304c\:52d5\:3044\:3066\:3044\:307e\:305b\:3093 (\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:5fdc\:7b54on/off\:300d\:3067\:59cb\:3081\:3066\:304f\:3060\:3055\:3044)\:3002",
        "Voice answering is not running (start it with the palette button)."]]];
    Return[$Failed]];
  muted = TrueQ[Lookup[st, "Muted", False]];
  res = Quiet[SourceVault`SourceVaultRealtimeMute[! muted]];
  iSWSetMicLabel[If[muted, "Live", "Muted"]];
  $iSWMicIntentUntil = AbsoluteTime[] + 1.5;
  (* \:97f3\:58f0\:5fdc\:7b54\:4e2d\:306f\:30b9\:30c6\:30fc\:30bf\:30b9\:30d0\:30fc\:306e\:6301\:3061\:4e3b\:304c\:30ef\:30fc\:30ab\:30fc\:306a\:306e\:3067\:3001\:77e5\:3089\:305b\:3082\:540c\:3058\:7d4c\:8def\:3078\:6d41\:3059 *)
  Quiet[SourceVault`SourceVaultRealtimeLine[
    If[muted, iSL["\:30de\:30a4\:30afon", "Mic on"], iSL["\:30de\:30a4\:30afoff (\:30df\:30e5\:30fc\:30c8)", "Mic off (muted)"]]]];
  <|"Status" -> If[FailureQ[res], "Failed", "Sent"], "Muted" -> ! muted|>];

Options[SlideToggleMic] = {"Quiet" -> False};

SlideToggleMic[OptionsPattern[]] := iSWToggleMic[TrueQ[OptionValue["Quiet"]]];

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

(* \:30bb\:30af\:30b7\:30e7\:30f3\:898b\:51fa\:3057\:3002ImageMargins -> {{left, right}, {bottom, top}}\:3002
   \:898b\:51fa\:3057\:306e\:4e0a\:30de\:30fc\:30b8\:30f3\:306f 0 (v1.16: \:5f93\:6765 5px \:3002
   \:898b\:51fa\:3057 6 \:500b\:5206 \:2248 30px \:5206\:30d1\:30ec\:30c3\:30c8\:304c\:7e2e\:307f\:3001
   \:6700\:4e0b\:90e8\:306e\:8a2d\:5b9a\:6b04\:304c\:30a6\:30a3\:30f3\:30c9\:30a6\:304b\:3089\:306f\:307f\:51fa\:3055\:306a\:3044) *)
iSWSectionLabel[ja_String, en_String] :=
  Pane[Style[iSL[ja, en], Bold, 8, GrayLevel[0.3]],
    ImageMargins -> {{0, 0}, {0, 0}}];

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

(* \:5c55\:958b\:6642\:306b\:30c8\:30fc\:30af(talk:)\:3082\:751f\:6210\:3059\:308b\:304b\:306e\:30c8\:30b0\:30eb ($SlideTalkPerSlide) *)
$iSWTalkGenLabel = "";
iSWRefreshTalkGenLabel[] := ($iSWTalkGenLabel =
  If[TrueQ[$SlideTalkPerSlide],
    iSL["\:5c55\:958b: \:30c8\:30fc\:30af\:751f\:6210 on", "Expand: talk gen on"],
    iSL["\:5c55\:958b: \:30c8\:30fc\:30af\:751f\:6210 off", "Expand: talk gen off"]]);

(* v1.2: "Safe"->True \:3067 ClaudeCode \:3068\:5b8c\:5168\:975e\:5e72\:6e09
   (LoadPaletteSettings \:3082 P:/M: \:8a2d\:5b9a\:6b04\:3082\:7701\:7565)\:3002\:30d5\:30ea\:30fc\:30ba\:5207\:308a\:5206\:3051\:7528 *)
$SlideWorkflowInteractiveVersion = "1.16";
Options[ShowSlidePalette] = {"Safe" -> False};

ShowSlidePalette[OptionsPattern[]] := Module[{safe = TrueQ[OptionValue["Safe"]]},
  If[$iSWPalette =!= None, Quiet[NotebookClose[$iSWPalette]]];
  If[!safe && Length[DownValues[ClaudeCode`LoadPaletteSettings]] > 0,
    Module[{initNb = Quiet[InputNotebook[]]},
      If[Head[initNb] === NotebookObject,
        Quiet[TimeConstrained[ClaudeCode`LoadPaletteSettings[initNb], 5]]]]];
  If[!safe, iSWRefreshSettingsLabels[]];
  iSWRefreshVoiceLabel[];
  iSWRefreshTalkLabel[];
  iSWRefreshMicLabel[];
  iSWRefreshEnvLabel[];
  iSWRefreshTalkGenLabel[];
  iSWPlayRefreshProgress[];
  $iSWPalette = Quiet[CreatePalette[
    Column[{
      Style["SlideWorkflow", Bold, 11, RGBColor[0.878, 0.486, 0.078]],

      iSWSectionLabel[" \:30b9\:30e9\:30a4\:30c9", " Slides"],
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

      iSWSectionLabel[" \:633f\:5165", " Insert"],
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
        iSWButton2[iSL["\:6587\:732e", "Refs"],
          RGBColor[0.3, 0.55, 0.5], SlideInsertReferences[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:30c8\:30fc\:30af", "Talk"],
          RGBColor[0.45, 0.42, 0.7], SlideInsertTalk[]],
        iSWButton2[iSL["\:7d42\:7aef", "End"],
          RGBColor[0.5, 0.45, 0.35], SlideInsertEndMarker[]]],

      iSWSectionLabel[" \:8868\:793a", " View"],
      Button[
        Dynamic[Style[$iSWEnvLabel, Bold, 8, White],
          TrackedSymbols :> {$iSWEnvLabel}, SynchronousUpdating -> False],
        With[{nb = iSWNotebook[]},
          If[nb =!= $Failed, SlideToggleScreenEnvironment[nb]; SetSelectedNotebook[nb]]],
        Appearance -> "Frameless",
        Background -> Dynamic[$iSWEnvColor,
          TrackedSymbols :> {$iSWEnvColor}, SynchronousUpdating -> False],
        ImageSize -> {100, 18}, FrameMargins -> {{4, 4}, {1, 1}},
        Method -> "Queued"],
      iSWButton[iSL["\[LeftRightArrow] \:30d7\:30ed\:30f3\:30d7\:30c8\:8868\:793a", "\[LeftRightArrow] Prompts"],
        RGBColor[0.35, 0.45, 0.65], SlideTogglePrompts[]],

      iSWSectionLabel[" \:66f8\:304d\:51fa\:3057", " Export"],
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

      iSWSectionLabel[" \:767a\:8868", " Talk"],
      iSWButtonRow[
        iSWButton2[iSL["\:30b7\:30ca\:30ea\:30aa", "Talk"],
          RGBColor[0.72, 0.4, 0.2],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWTalkBuildAction[nb]]]],
        iSWButton2[iSL["\:767b\:9332", "Register"],
          RGBColor[0.35, 0.55, 0.4],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWTalkRegisterAction[nb]]]]],
      (* \:300c\:60c5\:5831\:300d\:306f\:534a\:5206\:306e\:5e45\:306b\:3057\:3001\:6a2a\:306b\:30de\:30a4\:30af\:306e mute/unmute \:3092\:7f6e\:304f\:3002
         \:3053\:306e\:30dc\:30bf\:30f3\:306f\:624b\:5143\:30ea\:30e2\:30b3\:30f3 (Relacon \:306e\:518d\:751f/\:4e00\:6642\:505c\:6b62) \:3068\:540c\:3058\:52d5\:4f5c *)
      iSWButtonRow[
        iSWButton2[iSL["\:60c5\:5831", "Info"],
          RGBColor[0.45, 0.5, 0.6],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWInfoAction[nb]]]],
        Button[
          Dynamic[Style[$iSWMicLabel, Bold, 7, White],
            TrackedSymbols :> {$iSWMicLabel}, SynchronousUpdating -> False],
          (SlideToggleMic[];
           With[{inb = InputNotebook[]},
             If[Head[inb] === NotebookObject, SetSelectedNotebook[inb]]]),
          Appearance -> "Frameless",
          Background -> Dynamic[$iSWMicColor,
            TrackedSymbols :> {$iSWMicColor}, SynchronousUpdating -> False],
          ImageSize -> {49, 18}, FrameMargins -> {{1, 1}, {1, 1}},
          Method -> "Queued"]],
      iSWButtonRow[
        Button[
          Dynamic[Style[$iSWPlayLabel, Bold, 7, White],
            TrackedSymbols :> {$iSWPlayLabel}, SynchronousUpdating -> False],
          With[{nb = iSWNotebook[]},
            If[nb =!= $Failed, iSWPlayToggleAction[nb]; SetSelectedNotebook[nb]]],
          Appearance -> "Frameless", Background -> RGBColor[0.25, 0.55, 0.45],
          ImageSize -> {49, 18}, FrameMargins -> {{1, 1}, {1, 1}},
          Method -> "Queued"],
        iSWButton2["\[FilledSquare] " <> iSL["\:505c\:6b62", "Stop"],
          RGBColor[0.6, 0.35, 0.35], SlideStop[]]],
      Button[
        Dynamic[Style[$iSWTalkLabel, Bold, 8, White],
          TrackedSymbols :> {$iSWTalkLabel}, SynchronousUpdating -> False],
        With[{nb = iSWNotebook[]},
          If[nb =!= $Failed, SlideToggleRealtime[nb]; SetSelectedNotebook[nb]]],
        Appearance -> "Frameless", Background -> RGBColor[0.35, 0.45, 0.6],
        ImageSize -> {100, 18}, FrameMargins -> {{4, 4}, {1, 1}},
        Method -> "Queued"],
      Button[
        Dynamic[Style[$iSWVoiceLabel, 9, Bold, GrayLevel[0.2]],
          TrackedSymbols :> {$iSWVoiceLabel}, SynchronousUpdating -> False],
        SlideCycleVoice[],
        Appearance -> "Frameless", Method -> "Queued"],
      Dynamic[Style[$iSWPlayProgress, 8, GrayLevel[0.45]],
        TrackedSymbols :> {$iSWPlayProgress}, SynchronousUpdating -> False],


      iSWSectionLabel[" \:8a2d\:5b9a", " Settings"],
      (* \:5c55\:958b\:6642\:306e\:30c8\:30fc\:30af\:751f\:6210 on/off (P:/M: \:3068\:540c\:3058\:8a2d\:5b9a\:9805\:76ee\:30b9\:30bf\:30a4\:30eb) *)
      Button[
        Dynamic[Style[$iSWTalkGenLabel, 9, Bold, GrayLevel[0.2]],
          TrackedSymbols :> {$iSWTalkGenLabel}, SynchronousUpdating -> False],
        ($SlideTalkPerSlide = !TrueQ[$SlideTalkPerSlide];
         iSWRefreshTalkGenLabel[]),
        Appearance -> "Frameless", Method -> "Queued"],
      Sequence @@ If[!safe && Length[DownValues[ClaudeCode`GetPaletteProvider]] > 0,
        {Button[
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

(* \:58f0\:304b\:3089\:306e\:30b9\:30e9\:30a4\:30c9\:8868\:793a\:8981\:6c42\:306e\:53d7\:3051\:53e3\:3092 SourceVault_realtime \:3078\:767b\:9332\:3059\:308b\:3002
   \:3053\:308c\:304c\:3042\:308b\:3068 show_slide \:30c4\:30fc\:30eb\:304c\:30e2\:30c7\:30eb\:306b\:63d0\:793a\:3055\:308c\:308b *)
If[Length[DownValues[SourceVault`SourceVaultRealtimeStart]] > 0,
  SourceVault`$SourceVaultRealtimeSlideHandler =
    SlideWorkflow`Private`iSWSlideRequestHandler];

(* ---- ClaudeCode \:30ad\:30fc\:30ef\:30fc\:30c9\:81ea\:52d5\:6ce8\:5165\:767b\:9332 (PDFIndex \:3068\:540c\:30d1\:30bf\:30fc\:30f3) ---- *)
Print["
  ShowSlidePalette[]        \:2192 \:30b9\:30e9\:30a4\:30c9\:4f5c\:6210\:30d1\:30ec\:30c3\:30c8 (v" <> SlideWorkflow`$SlideWorkflowInteractiveVersion <> ", \"Safe\"->True \:3067\:975e\:5e72\:6e09\:30e2\:30fc\:30c9)
  SlideAddSlide[] / SlideExpand[]          \:2192 \:65b0\:898f\:9aa8\:683c / \:30d7\:30ed\:30f3\:30d7\:30c8\:2192\:30b9\:30e9\:30a4\:30c9\:5c55\:958b (LLM)
  SlideTranslate[] / SlideTranslateRevert[] / SlideTranslateDeck[]
  SlideInsertPrompt/Citation/Note/Directive/Dictionary/Bibliography/EndMarker[]
  SlideTogglePrompts[]      \:2192 \:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:8868\:793a\:5207\:66ff
  SlideToggleScreenEnvironment[]           \:2192 Working \:21d4 Slideshow \:5207\:66ff (\:30e1\:30e2/\:6307\:793a/\:6587\:732e/\:30d7\:30ed\:30f3\:30d7\:30c8\:306f Slideshow \:3067\:975e\:8868\:793a)
  SlideInsertReferences[]                  \:2192 \:6587\:732e\:30ea\:30b9\:30c8\:30bb\:30eb ([key] locator | \:30e1\:30e2\:3001\:5c55\:958b\:6642\:306b\:53c2\:7167)
  SlideTable[rows]                         \:2192 \:30c6\:30fc\:30de\:914d\:8272\:306e\:8868 (md \:3067\:306f | \:69cb\:6587)
  SlidePDFFigure["key|path", page]         \:2192 \:6587\:732e PDF \:306e\:30da\:30fc\:30b8/\:9818\:57df\:3092\:56f3\:3068\:3057\:3066\:5207\:308a\:51fa\:3057
  SlideInsertTalk[]                        \:2192 \:30c8\:30fc\:30af\:30bb\:30eb (\:767a\:8868\:539f\:7a3f\:3002Slideshow \:3067\:975e\:8868\:793a\:3001md \:3067\:306f talk: \:884c)
      \:5c55\:958b\:306f\:5404\:30b9\:30e9\:30a4\:30c9\:672b\:5c3e\:306b talk: \:539f\:7a3f\:3092\:751f\:6210\:3002\:5168\:30b9\:30e9\:30a4\:30c9\:306b\:30c8\:30fc\:30af\:304c\:3042\:308c\:3070\:300c\:30b7\:30ca\:30ea\:30aa\:300d\:306f LLM \:306a\:3057\:3067 deck_talk.md \:3092\:675f\:306d\:308b
  SlidePDFImages["key|path"]               \:2192 PDF \:57cb\:3081\:8fbc\:307f\:753b\:50cf(\:5199\:771f\:30fb\:30e9\:30b9\:30bf\:56f3)\:306e\:62bd\:51fa
  SlideDeckFigure["deck.nb", n]            \:2192 \:904e\:53bb\:30c7\:30c3\:30ad\:306e\:30b9\:30e9\:30a4\:30c9 1 \:679a\:3092\:753b\:50cf\:5f15\:7528
      locator \:306f URL / arxiv:ID / Google Slides \:3082\:53ef (\:81ea\:52d5\:30c0\:30a6\:30f3\:30ed\:30fc\:30c9+PDF \:5316+\:30ad\:30e3\:30c3\:30b7\:30e5)\:3002\:539f\:56f3\:5f15\:7528\:304c\:65e2\:5b9a
  SlideTalkBuild[\"deck.nb\"]                \:2192 \:767a\:8868\:30b7\:30ca\:30ea\:30aa(\:539f\:7a3f) \:3092 deck_talk.md \:3078\:66f8\:304d\:51fa\:3057 (\:518d\:751f\:30fb\:767b\:9332\:306b\:306f\:4e0d\:8981)
  SlideDeckRegister[\"deck.nb\"]             \:2192 \:30bf\:30a4\:30c8\:30eb/URL/\:30b7\:30ca\:30ea\:30aa\:3092 SourceVault \:767b\:9332\:7c3f\:3078 (\:30c8\:30fc\:30af\:30bb\:30eb\:304b\:3089\:76f4\:63a5)
  SlideTalkMeta[nb, \"SlideURL\"->url]       \:2192 \:767b\:9332\:7528\:30e1\:30bf (URL/\:5225\:540d/PL) \:3092\:30c7\:30c3\:30ad\:306b\:6c38\:7d9a\:5316
  SlideDeckRegistry[]                      \:2192 \:767b\:9332\:6e08\:307f\:767a\:8868\:306e\:4e00\:89a7
  SlidePlay[] / SlidePause[] / SlideStop[]  \:2192 \:539f\:7a3f\:3092\:8aad\:307f\:4e0a\:3052\:306a\:304c\:3089\:30b9\:30e9\:30a4\:30c9\:3092\:81ea\:52d5\:9001\:308a
  SlideVoices[] / SlideCycleVoice[]        \:2192 \:30dc\:30a4\:30b9\:30e2\:30c7\:30eb\:306e\:4e00\:89a7\:3068\:5207\:308a\:66ff\:3048 ($SlideVoice)
  SlideVoicePrepare[]                      \:2192 \:5168\:30b9\:30e9\:30a4\:30c9\:306e\:97f3\:58f0\:3092\:5148\:306b\:5408\:6210\:3057\:3066\:30ad\:30e3\:30c3\:30b7\:30e5
  SlideTalkDuration[]                      \:2192 \:539f\:7a3f\:304b\:3089\:767a\:8868\:6642\:9593\:3092\:898b\:7a4d\:3082\:308b (\:8cea\:554f\:306a\:3057)
  SlideIndex[] / SlideInfo[]               \:2192 \:982d\:51fa\:3057\:30fb\:8a66\:8074\:4ed8\:304d\:306e\:7d22\:5f15 / \:767a\:8868\:306e\:60c5\:5831
  SlideToggleMic[]                         \:2192 \:30de\:30a4\:30af\:306e mute / unmute (\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:30de\:30a4\:30afon/off\:300d)
  SlideRemoteStart[] / SlideRemoteProbe[]  \:2192 \:624b\:5143\:30ea\:30e2\:30b3\:30f3(Relacon \:7b49)\:306e\:898b\:5f35\:308a\:958b\:59cb / \:3069\:306e\:4eee\:60f3\:30ad\:30fc\:304b\:5b9f\:6e2c
      \:65e2\:5b9a\:306e\:5272\:308a\:5f53\:3066 ($SlideRemoteBindings): \:524d\:306e\:66f2 \:2192 \:30de\:30a4\:30af\:5207\:66ff\:3001\:518d\:751f/\:4e00\:6642\:505c\:6b62 \:2192 \:8aad\:307f\:4e0a\:3052\:306e\:518d\:751f/\:4e00\:6642\:505c\:6b62
"];

(* ---- NBAccess \:627f\:8a8d\:30b2\:30fc\:30c8\:306e\:8a31\:53ef head \:767b\:9332 ----
   SlideThemeColor(\:7d14\:95a2\:6570)\:3068 SlideApplyScenario(\:30b9\:30e9\:30a4\:30c9\:66f8\:8fbc\:307f\:306e\:552f\:4e00\:306e
   \:6c7a\:5b9a\:7684\:5165\:53e3\:3001\:5165\:529b\:691c\:8a3c\:4ed8\:304d)\:3092 UnknownHead \:627f\:8a8d\:304b\:3089\:5916\:3059\:3002 *)
(* 2026-08-06: NBAccess \:7ba1\:7406\:5909\:6570\:3078\:306e\:76f4\:63a5\:66f8\:304d\:63db\:3048\:3092\:3084\:3081\:3001\:767b\:9332 API \:3092\:901a\:3059 *)
Quiet @ Check[
  NBAccess`NBRegisterAllowedHeads[{"SlideThemeColor", "SlideApplyScenario",
    "SlideTable", "SlidePDFFigure", "SlidePDFImages", "SlideDeckFigure",
    "SlideSourceFile"}],
  Null];

If[AssociationQ[ClaudeCode`$ClaudePackageKeywordMap],
  ClaudeCode`$ClaudePackageKeywordMap["SlideWorkflow"] =
    {"SlideWorkflow", "SlideDeck", "Sliden", "slide", "slideshow", "deck",
     "presentation",
     "\:30b9\:30e9\:30a4\:30c9", "\:30c7\:30c3\:30ad", "\:30d7\:30ec\:30bc\:30f3",
     "\:767a\:8868\:8cc7\:6599", "\:30b9\:30e9\:30a4\:30c9\:30b7\:30e7\:30fc", "\:8aad\:307f\:4e0a\:3052", "\:97f3\:58f0", "\:30ca\:30ec\:30fc\:30b7\:30e7\:30f3"}
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