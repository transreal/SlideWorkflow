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
SlideTalkBuild::usage = "SlideTalkBuild[deck] \:767a\:8868\:539f\:7a3f\:3092 <deck>_talk.md \:3078\:66f8\:304d\:51fa\:3059 (v1.30: \:30d1\:30ec\:30c3\:30c8\:304b\:3089\:306f\:5916\:3057\:305f\:3002\:539f\:7a3f\:306e\:6b63\:672c\:306f\:30c8\:30fc\:30af\:30bb\:30eb\:3067\:3001\:539f\:7a3f\:306e\:7121\:3044\:679a\:3092\:57cb\:3081\:308b\:306e\:306f SlideTalkFill)\:3002LLM \:304c\:4f7f\:3048\:308b\:3068\:304d\:306f\:975e\:540c\:671f (SlideExpand \:3068\:540c\:3058\:7d4c\:8def) \:3067\:3001\:4f7f\:3048\:306a\:3044\:3068\:304d\:306f\:9aa8\:683c\:3092\:540c\:671f\:3067\:66f8\:304f\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Output\", \"UseLLM\", \"Notebook\", \"OpenResult\" \:3068 SlideTalkPrompt \:306e\:30aa\:30d7\:30b7\:30e7\:30f3\:3002";
SlideTalkFile::usage = "SlideTalkFile[deck] \:767a\:8868\:30b7\:30ca\:30ea\:30aa\:306e\:898f\:7d04\:30d1\:30b9 <deck>_talk.md \:3092\:8fd4\:3059 (\:30c8\:30fc\:30af\:30bb\:30eb\:306e\:7121\:3044\:65e7\:30c7\:30c3\:30ad\:7528\:306e\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af)\:3002";

SlideTalkMeta::usage = "SlideTalkMeta[nb] \:306f\:30c7\:30c3\:30ad\:5358\:4f4d\:306e\:767a\:8868\:30e1\:30bf (Title / SlideURL / UploadURL / Aliases / PrivacyLevel \:306a\:3069) \:3092\:8fd4\:3059\:3002\:30bd\:30fc\:30b9\:306f \:30c7\:30c3\:30ad\:5148\:982d\:306e\:6307\:793a (Directive) \:30bb\:30eb\:306e Key: value \:884c (Title: / SlideURL: / Host: sftp://user@host/dir) > TaggingRules \"SWTalkMeta\" > _talk.md front matter \:306e\:9806\:3002\n" <>
  "SlideTalkMeta[nb, \"SlideURL\" -> url, ...] \:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e TaggingRules \:306b\:6c38\:7d9a\:5316\:3059\:308b (\:6307\:793a\:30bb\:30eb\:306e\:884c\:304c\:3042\:308c\:3070\:305d\:3061\:3089\:304c\:512a\:5148)\:3002";
SlideDeckRegister::usage = "SlideDeckRegister[nb|deck.nb|talkfile|md] \:767a\:8868 (\:30c8\:30fc\:30af\:30bb\:30eb + \:6307\:793a\:30bb\:30eb\:306e\:30e1\:30bf) \:3092 SourceVault \:306e\:767b\:9332\:7c3f\:3078\:767b\:9332\:3057\:3001\:30e1\:30bf\:306b UploadURL (\:6307\:793a\:30bb\:30eb\:306e Host: \:884c) \:304c\:3042\:308c\:3070 Sliden \:7528 mp4 \:3092 web \:30b5\:30fc\:30d0\:3078\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:3059\:308b (\:7d50\:679c\:306f \"Upload\" \:30ad\:30fc)\:3002\:4ee5\:5f8c VRCRealtime \:304c\:767a\:8868\:30bf\:30a4\:30c8\:30eb\:304b\:3089\:30b9\:30e9\:30a4\:30c9 URL \:3068\:539f\:7a3f\:3092\:5f15\:3051\:308b\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"SlideURL\", \"Title\", \"Id\", \"DeckFile\", \"PrivacyLevel\", \"SlideCount\", \"Upload\" (Automatic|True|False)\:3002\:540c\:3058\:30c7\:30c3\:30ad\:3067\:518d\:5ea6\:5b9f\:884c\:3059\:308b\:3068\:3001\:524d\:56de\:306e\:30a8\:30f3\:30c8\:30ea\:3092\:571f\:53f0\:306b\:4eca\:56de\:4e0e\:3048\:305f\:5024\:3060\:3051\:3092\:4e0a\:66f8\:304d\:3059\:308b (\:524d\:56de\:306e\:7279\:5b9a\:306f Id > DeckFile > SlideURL\:3002\:6307\:793a\:30bb\:30eb\:306e Id: \:884c\:3067\:56fa\:5b9a\:3067\:304d\:308b)\:3002\:4f55\:304c\:5909\:308f\:3063\:305f\:304b\:306f\:623b\:308a\:5024\:306e RegistryStatus (Created|Updated) \:3068 ChangedKeys\:3002";
SlideDeckRegistry::usage = "SlideDeckRegistry[] \:767b\:9332\:6e08\:307f\:767a\:8868\:30a8\:30f3\:30c8\:30ea\:306e\:4e00\:89a7\:3092\:8fd4\:3059\:3002";
SlideDeckUpload::usage = "SlideDeckUpload[nb|deck.nb|deck.mp4] \:306f Sliden \:7528 mp4 (<deck>.mp4) \:3092\:767a\:8868\:30e1\:30bf\:306e UploadURL (\:6307\:793a\:30bb\:30eb\:306e Host: sftp://user@host/dir \:884c) \:3078 sftp \:3067\:9001\:308a\:3001SlideURL \:306e HEAD \:3067\:914d\:4fe1\:3092\:78ba\:8a8d\:3059\:308b\:3002\:540c\:3058\:30b5\:30a4\:30ba\:3067\:914d\:4fe1\:4e2d\:306a\:3089\:9001\:3089\:306a\:3044 (\"Force\"->True \:3067\:5f37\:5236)\:3002\:30d1\:30b9\:30ef\:30fc\:30c9\:306f NBAccess \:7ba1\:8f44\:306e SystemCredential (SlideUploadCredential \:3067\:4fdd\:5b58)\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"UploadURL\", \"SlideURL\", \"File\", \"Method\" (Automatic|\"Native\"|\"curl\"), \"Password\", \"User\", \"Force\", \"Verify\", \"ExportVideo\", \"Interactive\"\:3002\:30c7\:30c3\:30ad\:304c mp4 \:3088\:308a\:65b0\:3057\:3051\:308c\:3070\:66f8\:304d\:51fa\:3057\:76f4\:3057\:3066\:304b\:3089\:9001\:308b (ExportVideo->False \:3067\:6291\:6b62\:3001True \:3067\:5e38\:306b\:4f5c\:308a\:76f4\:3059)\:3002";
SlideUploadCredential::usage = "SlideUploadCredential[url|nb] \:306f sftp \:306e\:30d1\:30b9\:30ef\:30fc\:30c9\:3092\:30c0\:30a4\:30a2\:30ed\:30b0\:3067\:5c0b\:306d\:3001NBAccess \:7d4c\:7531\:3067 SystemCredential \:306b\:4fdd\:5b58\:3059\:308b (\:540d\:524d = sftp://user@host)\:3002SlideUploadCredential[url, password] \:3067\:76f4\:63a5\:4fdd\:5b58\:3001SlideUploadCredential[url, None] \:3067\:524a\:9664\:3002";
SlideUploadCredentialQ::usage = "SlideUploadCredentialQ[url|nb] \:306f sftp \:306e\:30d1\:30b9\:30ef\:30fc\:30c9\:304c\:4fdd\:5b58\:6e08\:307f\:304b\:3069\:3046\:304b\:3092\:8fd4\:3059 (\:5024\:306f\:8fd4\:3055\:306a\:3044)\:3002";
$SlideUploadMethod::usage = "$SlideUploadMethod \:306f mp4 \:306e\:8ee2\:9001\:624b\:6bb5\:3002Automatic (\:65e2\:5b9a) = \"Native\" (CopyFile -> RemoteFile\:3001WL \:7d44\:8fbc\:307f) \:3092\:8a66\:3057\:3001\:4f7f\:3048\:306a\:3051\:308c\:3070 \"curl\" (Git for Windows \:540c\:68b1\:306e sftp \:5bfe\:5fdc curl)\:3002";
$SlideVoice::usage = "$SlideVoice \:306f\:8aad\:307f\:4e0a\:3052\:306b\:4f7f\:3046\:30dc\:30a4\:30b9\:30e2\:30c7\:30eb\:540d (SourceVault \:306e\:30ed\:30fc\:30ab\:30eb\:97f3\:58f0\:8cc7\:7523\:306e\:58f0\:540d)\:3002\:65e2\:5b9a Automatic \:306f SourceVaultVoice[] \:306e\:65e2\:5b9a\:306e\:58f0\:3002SlideVoices[] \:3067\:5019\:88dc\:4e00\:89a7\:3002";
$SlideVoiceGap::usage = "$SlideVoiceGap \:306f\:30b9\:30e9\:30a4\:30c9\:3092\:8aad\:307f\:7d42\:3048\:3066\:304b\:3089\:6b21\:3078\:9001\:308b\:307e\:3067\:306e\:9593 (\:79d2\:3001\:65e2\:5b9a 0.8)\:3002";
$SlideRenderSettle::usage = "$SlideRenderSettle \:306f\:6b21\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:8868\:793a\:3057\:3066\:304b\:3089\:8aad\:307f\:4e0a\:3052\:3092\:59cb\:3081\:308b\:307e\:3067\:306e\:9593 (\:79d2\:3001\:65e2\:5b9a 0.6)\:3002FE \:304c\:91cd\:3044\:30b9\:30e9\:30a4\:30c9\:306e\:63cf\:753b\:3067\:585e\:304c\:3063\:3066\:3044\:308b\:9593\:306b\:9cf4\:3089\:3057\:59cb\:3081\:308b\:3068\:97f3\:304c\:6b62\:307e\:308b\:305f\:3081\:3001\:63cf\:753b\:304c\:843d\:3061\:7740\:304f\:306e\:3092\:5f85\:3064\:30020 \:3067\:5f85\:305f\:306a\:3044\:3002";
$SlidePrepareBeforePlay::usage = "$SlidePrepareBeforePlay \:304c True (\:65e2\:5b9a) \:306e\:3068\:304d\:3001SlidePlay \:306f\:30ed\:30fc\:30ab\:30eb\:306e\:58f0\:306e\:97f3\:58f0\:3092\:518d\:751f\:958b\:59cb\:524d\:306b\:5168\:30b9\:30e9\:30a4\:30c9\:5206\:7528\:610f\:3059\:308b (\:672a\:5408\:6210\:306e\:3082\:306e\:3060\:3051\:5408\:6210)\:3002\:518d\:751f\:4e2d\:306b\:5408\:6210\:3092\:8d70\:3089\:305b\:308b\:3068\:97f3\:304c\:9014\:5207\:308c\:308b\:305f\:3081\:3002False \:3067\:5f93\:6765\:306e 1 \:679a\:5148\:8aad\:307f\:3002";
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
SlideEnsureDeckStyles::usage = "SlideEnsureDeckStyles[nb] \:306f\:30c7\:30c3\:30ad\:306b\:30e1\:30bf\:30bb\:30eb\:7528\:30b9\:30bf\:30a4\:30eb\:5b9a\:7fa9(Note/Directive/Dictionary/Bibliography/References/SlidePrompt/SlideTalk/SlideQA\:3002SlideShow \:74b0\:5883\:3067\:975e\:8868\:793a)\:3092\:57cb\:3081\:8fbc\:3080\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:633f\:5165\:30fb\:5c55\:958b\:30fb\:8868\:793a\:5207\:66ff\:304b\:3089\:81ea\:52d5\:3067\:547c\:3070\:308c\:3001documentation.wl \:306e DocInsert* \:3082\:3053\:306e\:5b9a\:7fa9\:3092\:4f7f\:3046\:3002";
SlideTogglePrompts::usage = "SlideTogglePrompts[] \:306f\:5168 SlidePrompt \:30bb\:30eb\:306e\:8868\:793a/\:975e\:8868\:793a\:3092\:5207\:308a\:66ff\:3048\:308b\:3002";
$SlideTranslationLanguage::usage = "$SlideTranslationLanguage \:306f\:7ffb\:8a33\:5148\:8a00\:8a9e\:3002\:65e2\:5b9a\:306f\:65e5\:672c\:8a9e\:74b0\:5883\:306a\:3089 \"English\"\:3002";
$SlideExportExternal::usage = "$SlideExportExternal \:30d1\:30ec\:30c3\:30c8\:306e\:753b\:50cf/mp4 \:66f8\:304d\:51fa\:3057\:3092\:5225\:30d7\:30ed\:30bb\:30b9(wolframscript)\:3067\:884c\:3046\:304b\:3002Automatic(\:65e2\:5b9a)=1 \:5ea6\:8a66\:3057\:3001\:30e9\:30a4\:30bb\:30f3\:30b9\:5e2d\:4e0d\:8db3\:7b49\:3067\:8d77\:52d5\:3067\:304d\:306a\:3051\:308c\:3070\:4ee5\:5f8c\:306f FE \:5185\:51e6\:7406\:306b\:30d5\:30a9\:30fc\:30eb\:30d0\:30c3\:30af | True | False\:3002";

SlideTable::usage = "SlideTable[rows] \:306f\:30c7\:30c3\:30ad\:914d\:8272($SlideTheme)\:306e\:8868\:3092\:8fd4\:3059\:3002rows \:306f\:6587\:5b57\:5217\:306e\:884c\:30ea\:30b9\:30c8\:3002\"HeaderRows\"->n (\:65e2\:5b9a 1) \:3067\:30d8\:30c3\:30c0\:884c\:3092\:5f37\:8abf\:3002\:30b7\:30ca\:30ea\:30aa md \:3067\:306f | \:69cb\:6587 (\"| a | b |\"\:30012 \:884c\:76ee\:306b \"| --- | --- |\" \:3067 1 \:884c\:76ee\:304c\:30d8\:30c3\:30c0) \:304c\:540c\:3058\:8868\:306b\:306a\:308b\:3002";
SlidePDFFigure::usage = "SlidePDFFigure[src, page] \:306f PDF \:306e\:30da\:30fc\:30b8\:3092\:56f3(Image)\:3068\:3057\:3066\:5207\:308a\:51fa\:3059\:3002src \:306f\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9 / eagle:ID / sv://URI / src-ID / URL / arxiv:ID / \:6587\:732e\:30ea\:30b9\:30c8(References)\:306e key\:3002URL\:30fbarxiv\:30fbGoogle Slides(\:30d7\:30ec\:30bc\:30f3 URL)\:306f\:81ea\:52d5\:30c0\:30a6\:30f3\:30ed\:30fc\:30c9\:3057\:3066 PDF \:5316\:3057\:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b\:3002png \:7b49\:306e\:753b\:50cf\:30d5\:30a1\:30a4\:30eb\:3082 src \:306b\:6307\:5b9a\:3067\:304d\:308b\:3002\"Crop\"->{{x1,x2},{y1,y2}} (\:5de6\:4e0a\:539f\:70b9\:306e\:30da\:30fc\:30b8\:6bd4\:7387 0..1) \:3067\:9818\:57df\:6307\:5b9a\:3001\"Trim\"->Automatic (\:65e2\:5b9a) \:3067\:767d\:4f59\:767d\:3092\:81ea\:52d5\:30c8\:30ea\:30e0\:3001ImageResolution (\:65e2\:5b9a 144)\:3002\:6587\:732e PDF \:306e\:56f3\:3092\:30b9\:30e9\:30a4\:30c9\:3078\:5f15\:7528\:3059\:308b\:3068\:304d\:306f\:76f4\:5f8c\:306b cite: \:3092\:4ed8\:3059\:3002";
$SlideVisualsPerSlide::usage = "$SlideVisualsPerSlide \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:5c55\:958b\:30d7\:30ed\:30f3\:30d7\:30c8\:304c\:300c\:539f\:5247\:3059\:3079\:3066\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:56f3\:304b\:8868\:3092 1 \:3064\:4ee5\:4e0a\:300d\:3092\:8981\:6c42\:3059\:308b\:3002False \:3067\:5f93\:6765\:306e\:6587\:7ae0\:4e2d\:5fc3\:751f\:6210\:3002";

SlideInsertQA::usage = "SlideInsertQA[] \:306f\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb(SlideQA \:30b9\:30bf\:30a4\:30eb\:3001\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:60f3\:5b9a\:554f\:7b54)\:3092\:633f\:5165\:3059\:308b\:3002\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:3001\:30c8\:30fc\:30af\:30bb\:30eb\:306e\:96a3\:306b\:7f6e\:304f\:3002Working \:3067\:53ef\:8996\:3001SlideShow \:74b0\:5883\:3067\:306f\:975e\:8868\:793a\:3001\:753b\:50cf\:30fbmp4 \:306e\:66f8\:304d\:51fa\:3057\:304b\:3089\:3082\:9664\:5916\:3002md \:3067\:306f \"qa: \" \:884c\:3002\:66f8\:5f0f\:306f 1 \:554f\:3054\:3068\:306b \"Q: \:60f3\:5b9a\:8cea\:554f\" / \"A: \:8aad\:307f\:4e0a\:3052\:308b\:56de\:7b54\" \:306e 2 \:884c (\:4efb\:610f\:3067 \"cite: \:51fa\:5178\"\:3001\"PL: 0.6\")\:3002\:300c\:767b\:9332\:300d\:3067\:3053\:306e\:30bb\:30eb\:7fa4\:304c gpt-realtime \:304b\:3089\:5f15\:3051\:308b QA \:30c7\:30fc\:30bf\:30d9\:30fc\:30b9\:306b\:306a\:308b\:3002";
SlideQAEntries::usage = "SlideQAEntries[nb|deck.nb] \:306f\:30c7\:30c3\:30ad\:5185\:306e\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092 <|\"SlideCount\", \"Questions\", \"Answered\", \"Missing\"(\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9), \"Slides\"|> \:306b\:3057\:3066\:8fd4\:3059(\:30b3\:30a2\:95a2\:6570)\:3002";
SlideQAStateView::usage = "SlideQAStateView[nb|deck.nb] \:306f\:30b9\:30e9\:30a4\:30c9\:3054\:3068\:306e\:8cea\:7591\:5fdc\:7b54\:306e\:72b6\:614b (\:672a\:4f5c\:6210 / \:8981\:66f4\:65b0 / \:6700\:65b0 / \:5224\:5b9a\:4e0d\:80fd\:3001\:56f3\:8868\:306e\:6709\:7121) \:3092 Dataset \:3067\:8fd4\:3059(View \:95a2\:6570)\:3002\:300cQA \:751f\:6210\:300d\:304c\:3069\:306e\:679a\:3092\:62fe\:3046\:304b\:304c\:3053\:308c\:3067\:5206\:304b\:308b\:3002";
SlideQAView::usage = "SlideQAView[nb|deck.nb] \:306f\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:4e2d\:8eab\:3092 1 \:884c 1 \:554f\:306e Dataset \:3067\:8868\:793a\:3059\:308b(View \:95a2\:6570)\:3002";
SlideQAGenerate::usage = "SlideQAGenerate[nb] \:306f LLM \:3067\:60f3\:5b9a\:554f\:7b54\:306e\:4e0b\:66f8\:304d\:3092\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3078\:66f8\:304d\:8fbc\:3080 (\:975e\:540c\:671f\:30011 \:679a\:305a\:3064\:9806\:306b)\:3002\:66f8\:3044\:305f\:3042\:3068\:306f\:4eba\:304c\:76f4\:3059\:3053\:3068\:304c\:524d\:63d0\:3002\n" <>
  "\"Mode\" \:306e 3 \:3064:\n" <>
  "  \"Regenerate\" (1) \:5168\:30b9\:30e9\:30a4\:30c9\:3092\:4f5c\:308a\:76f4\:3059\:3002\:65e2\:5b58\:306e\:8cea\:7591\:5fdc\:7b54\:306f\:6368\:3066\:308b (SlideQAGenerateAll)\n" <>
  "  \"Update\" (2) \:5168\:30b9\:30e9\:30a4\:30c9\:3092\:898b\:76f4\:3059\:3002\:65e2\:5b58\:3092 LLM \:306b\:898b\:305b\:3001\:6d3b\:304b\:3057\:305f\:307e\:307e\:76f4\:3055\:305b\:308b (SlideQAUpdateAll)\n" <>
  "  \"Changed\" (3, \:65e2\:5b9a) \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9\:3068\:3001\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:305f\:30b9\:30e9\:30a4\:30c9\:3060\:3051\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:300cQA \:751f\:6210\:300d\:306f\:3053\:308c\n" <>
  "\:5909\:66f4\:306e\:5224\:5b9a\:306f\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:5148\:982d\:306e \"# slide: <\:30cf\:30c3\:30b7\:30e5>\" \:884c (\:66f8\:3044\:305f\:6642\:70b9\:306e\:30b9\:30e9\:30a4\:30c9)\:3002\:30bb\:30eb\:306b\:4ed8\:3044\:3066\:56de\:308b\:306e\:3067\:4e26\:3079\:66ff\:3048\:3066\:3082\:5d29\:308c\:306a\:3044\:3002\:30de\:30fc\:30ab\:30fc\:306e\:7121\:3044\:30bb\:30eb (\:624b\:66f8\:304d) \:306f 3 \:3067\:306f\:89e6\:3089\:306a\:3044\:3002\n" <>
  "\:56f3\:30fb\:5199\:771f\:30fb\:8868\:306e\:3042\:308b\:30b9\:30e9\:30a4\:30c9\:306f\:63cf\:753b\:753b\:50cf\:3092 LLM \:306b\:6dfb\:4ed8\:3057\:3001\:305d\:306e\:5185\:5bb9\:306b\:3064\:3044\:3066\:306e\:554f\:7b54\:3082\:4f5c\:3089\:305b\:308b (\"Vision\", \:65e2\:5b9a $SlideQAVision = True)\:3002\n" <>
  "\:30aa\:30d7\:30b7\:30e7\:30f3: \"Mode\", \"QuestionsPerSlide\" (\:65e2\:5b9a $SlideQAPerSlide = 3), \"Vision\", \"Slides\" -> All | {n..}\:3002";
SlideQAMarkCurrent::usage = "SlideQAMarkCurrent[nb] \:306f\:65e2\:306b\:3042\:308b\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306b\:3001\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:5370 (# slide: \:884c) \:3060\:3051\:3092\:6253\:3064\:3002LLM \:3092\:4f7f\:308f\:305a\:3001\:554f\:7b54\:306e\:6587\:9762\:306f\:5909\:3048\:306a\:3044\:3002\:30de\:30fc\:30ab\:30fc\:306e\:7121\:3044\:65e7\:3044\:30c7\:30c3\:30ad\:3092\:300cQA \:751f\:6210\:300d(\:5909\:66f4\:5206\:306e\:307f) \:306b\:4e57\:305b\:308b\:305f\:3081\:306e\:571f\:53f0\:3002**\:4eca\:306e\:4e2d\:8eab\:3092\:300c\:78ba\:8a8d\:6e08\:307f\:300d\:3068\:5ba3\:8a00\:3059\:308b\:64cd\:4f5c**\:306a\:306e\:3067\:3001\:4e2d\:8eab\:3092\:898b\:3066\:304b\:3089\:4f7f\:3046\:3053\:3068\:3002";
SlideQAGenerateAll::usage = "SlideQAGenerateAll[nb] \:306f\:5168\:30b9\:30e9\:30a4\:30c9\:306e\:60f3\:5b9a\:554f\:7b54\:3092\:4f5c\:308a\:76f4\:3059 (\:65e2\:5b58\:306f\:7f6e\:304d\:63db\:3048)\:3002SlideQAGenerate[nb, \"Mode\" -> \"Regenerate\"] \:3068\:540c\:3058\:3002";
SlideQAUpdateAll::usage = "SlideQAUpdateAll[nb] \:306f\:5168\:30b9\:30e9\:30a4\:30c9\:306e\:60f3\:5b9a\:554f\:7b54\:3092\:3001\:65e2\:5b58\:3092\:6d3b\:304b\:3057\:305f\:307e\:307e\:898b\:76f4\:3059\:3002SlideQAGenerate[nb, \"Mode\" -> \"Update\"] \:3068\:540c\:3058\:3002";
$SlideQAVision::usage = "$SlideQAVision \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:56f3\:30fb\:5199\:771f\:30fb\:8868\:3092\:542b\:3080\:30b9\:30e9\:30a4\:30c9\:306e QA \:751f\:6210\:3067\:63cf\:753b\:753b\:50cf\:3092 LLM \:306b\:6dfb\:4ed8\:3059\:308b\:3002\:753b\:50cf\:306f <deck>_qa_images/ \:306b\:30b9\:30e9\:30a4\:30c9\:306e\:30cf\:30c3\:30b7\:30e5\:3067\:30ad\:30e3\:30c3\:30b7\:30e5\:3055\:308c\:308b\:3002";
SlideQAFromPack::usage = "SlideQAFromPack[nb] \:306f\:3059\:3067\:306b\:767b\:9332\:6e08\:307f\:306e QA \:30d1\:30c3\:30af (\:4ee5\:524d\:306b SourceVaultTalkQABuild \:3067 LLM \:304b\:3089\:4f5c\:3063\:305f\:3082\:306e\:3092\:542b\:3080) \:3092\:3001\:30b9\:30e9\:30a4\:30c9\:306e\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3078\:66f8\:304d\:623b\:3059\:3002\:30bb\:30eb\:304c\:6b63\:672c\:306b\:306a\:3063\:305f\:3042\:3068\:3082\:3001\:53e4\:3044\:4f5c\:308a\:7f6e\:304d\:3092\:6368\:3066\:305a\:306b\:4eba\:304c\:76f4\:305b\:308b\:5f62\:3078\:79fb\:305b\:308b\:3002LLM \:306f\:4f7f\:308f\:306a\:3044\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"Rebuild\" (\:65e2\:5b9a False = \:65e2\:306b\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:3042\:308b\:30b9\:30e9\:30a4\:30c9\:306f\:89e6\:3089\:306a\:3044)\:3002";
SlideQABuild::usage = "SlideQABuild[nb|deck.nb] \:306f\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092 SourceVault \:306e QA \:30d1\:30c3\:30af\:3078\:713c\:304d\:3001\:767a\:8868\:4e2d\:306e gpt-realtime \:304c\:6570\:5341 ms \:3067\:5f15\:3051\:308b\:3088\:3046\:306b\:3059\:308b(SourceVaultTalkQAImport \:3078\:59d4\:8b72)\:3002\:300c\:767b\:9332\:300d\:304b\:3089\:81ea\:52d5\:3067\:547c\:3070\:308c\:308b\:3002\:30aa\:30d7\:30b7\:30e7\:30f3: \"PrivacyLevel\", \"Ingest\" (\:65e2\:5b9a True = KB \:3078\:3082\:53d6\:308a\:8fbc\:3080), \"Enrich\" (\:65e2\:5b9a True = \:56de\:7b54\:304c\:7a7a\:306e\:554f\:3060\:3051 KB \:304b\:3089\:88dc\:3046)\:3002";
$SlideQAPerSlide::usage = "$SlideQAPerSlide \:306f SlideQAGenerate \:304c 1 \:679a\:3042\:305f\:308a\:306b\:4f5c\:308b\:60f3\:5b9a\:8cea\:554f\:306e\:6570 (\:65e2\:5b9a 3)\:3002";
SlideDeckMarkVideoCurrent::usage = "SlideDeckMarkVideoCurrent[nb|deck.nb] \:306f\:3001\:4eca\:3042\:308b <deck>.mp4 \:3092\:300c\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:4f5c\:3089\:308c\:305f\:3082\:306e\:300d\:3068\:3057\:3066\:8a18\:9332\:3059\:308b\:3002\:65e2\:5b58\:306e\:30c7\:30c3\:30ad\:3092\:3053\:306e\:4ed5\:7d44\:307f\:3078\:79fb\:3059\:3068\:304d\:3001\:3059\:3067\:306b\:914d\:4fe1\:6e08\:307f\:306e mp4 \:3092 1 \:56de\:3060\:3051\:4f5c\:308a\:76f4\:3059\:306e\:3092\:907f\:3051\:308b\:305f\:3081\:306e\:3082\:306e\:3002**\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:305f\:306e\:306b\:547c\:3076\:3068\:3001\:53e4\:3044 mp4 \:304c\:6700\:65b0\:6271\:3044\:3067\:56fa\:5b9a\:3055\:308c\:308b**\:306e\:3067\:3001\:898b\:305f\:76ee\:304c\:4e00\:81f4\:3057\:3066\:3044\:308b\:3068\:304d\:3060\:3051\:4f7f\:3046\:3002";
SlideDeckChangeStatus::usage = "SlideDeckChangeStatus[nb|deck.nb] \:306f\:300c\:767b\:9332\:300d\:304c\:4f55\:3092\:3084\:308a\:76f4\:3059\:304b\:3092\:8fd4\:3059(\:30b9\:30e9\:30a4\:30c9\:306e\:4e26\:3073\:306e\:30cf\:30c3\:30b7\:30e5\:3001mp4 \:304c\:53e4\:3044\:304b\:3001QA \:304c\:713c\:304d\:76f4\:3055\:308c\:308b\:304b)\:3002\:300c\:767b\:9332\:3057\:3066\:3082\:4f55\:3082\:8d77\:304d\:306a\:3044\:300d\:3068\:304d\:306e\:5207\:308a\:5206\:3051\:306b\:4f7f\:3046\:3002";

SlideInsertTalk::usage = "SlideInsertTalk[] \:306f\:30c8\:30fc\:30af\:30bb\:30eb(SlideTalk \:30b9\:30bf\:30a4\:30eb\:3001\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f)\:3092\:633f\:5165\:3059\:308b\:3002\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:306b\:7f6e\:304f\:3002Working \:3067\:53ef\:8996\:3001SlideShow \:74b0\:5883\:3067\:306f\:975e\:8868\:793a\:3001\:66f8\:304d\:51fa\:3057\:304b\:3089\:3082\:9664\:5916\:3002md \:3067\:306f \"talk: \:539f\:7a3f\" \:884c\:3002\:5168\:30b9\:30e9\:30a4\:30c9\:306b\:30c8\:30fc\:30af\:304c\:3042\:308b\:3068 SlideTalkBuild(\:30d1\:30ec\:30c3\:30c8\:300c\:30b7\:30ca\:30ea\:30aa\:300d)\:304c LLM \:306a\:3057\:3067 deck_talk.md \:3092\:675f\:306d\:308b\:3002";
$SlideTalkPerSlide::usage = "$SlideTalkPerSlide \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:5c55\:958b\:30d7\:30ed\:30f3\:30d7\:30c8\:304c\:5404\:30b9\:30e9\:30a4\:30c9\:672b\:5c3e\:306b talk: \:539f\:7a3f(\:3067\:3059\:30fb\:307e\:3059\:8abf 2\:301c6 \:6587)\:3092\:8981\:6c42\:3057\:3001\:30b9\:30e9\:30a4\:30c9\:672c\:6587\:306f\:56f3\:8868+\:4f53\:8a00\:6b62\:3081\:306b\:7d5e\:308b(\:30b9\:30e9\:30a4\:30c9\:3068\:30c8\:30fc\:30af\:3067\:89e3\:8aac\:304c\:5b8c\:6210\:3059\:308b\:5206\:696d)\:3002False \:3067\:5f93\:6765\:3069\:304a\:308a\:3002";

SlidePDFImages::usage = "SlidePDFImages[src] \:306f PDF \:306b\:57cb\:3081\:8fbc\:307e\:308c\:305f\:30e9\:30b9\:30bf\:753b\:50cf(\:5199\:771f\:30fb\:30d3\:30c3\:30c8\:30de\:30c3\:30d7\:56f3)\:3092 Image \:306e\:30ea\:30b9\:30c8\:3067\:62bd\:51fa\:3059\:308b\:3002src \:306f SlidePDFFigure \:3068\:540c\:3058 locator (\:30d1\:30b9 / eagle:ID / sv://URI / URL / arxiv:ID / References \:306e key)\:3002\"MinSize\"->px (\:65e2\:5b9a 80) \:672a\:6e80\:306e\:5c0f\:753b\:50cf(\:30a2\:30a4\:30b3\:30f3\:7b49)\:306f\:9664\:5916\:3002\:30d9\:30af\:30bf\:306e\:307f\:306e PDF \:3067\:306f {} \:3092\:8fd4\:3059(\:305d\:306e\:5834\:5408\:306f SlidePDFFigure \:3067\:30da\:30fc\:30b8\:5207\:308a\:51fa\:3057)\:3002";
SlideDeckFigure::usage = "SlideDeckFigure[deck, n] \:306f\:65e2\:5b58\:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad(.nb)\:306e n \:679a\:76ee\:3092 1920x1080 \:306e Image \:3068\:3057\:3066\:5f15\:7528\:3059\:308b\:3002deck \:306f\:30d1\:30b9\:307e\:305f\:306f References \:306e key\:3002\:8ad6\:6587\:7d39\:4ecb\:30fb\:904e\:53bb\:30b9\:30e9\:30a4\:30c9\:7d39\:4ecb\:3067\:539f\:30b9\:30e9\:30a4\:30c9\:3092\:305d\:306e\:307e\:307e\:898b\:305b\:308b\:306e\:306b\:4f7f\:3046(cite: \:3092\:4ed8\:3059)\:3002";
SlideNotebookOutline::usage = "SlideNotebookOutline[src] \:306f\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af(\:8ad6\:6587\:306e\:548c\:8a33 .nb \:306a\:3069\:3001\:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad\:3067\:306a\:3044\:4e00\:822c\:306e .nb)\:306e\:898b\:51fa\:3057\:69cb\:6210\:3092\:8fd4\:3059\:3002\:5404\:8981\:7d20\:306f <|\"N\", \"Style\", \"Title\", \"Chars\"(\:305d\:306e\:7bc0\:306e\:672c\:6587\:6587\:5b57\:6570), \"Figures\"(\:305d\:306e\:7bc0\:306b\:3042\:308b\:56f3\:756a\:53f7)|>\:3002\:307e\:305a\:69cb\:6210\:3092\:898b\:3066\:3001\:5fc5\:8981\:306a\:7bc0\:3060\:3051\:3092 SlideNotebookText[src, \:898b\:51fa\:3057] \:3067\:8aad\:3080\:3068\:6587\:8108\:3092\:7bc0\:7d04\:3067\:304d\:308b\:3002src \:306f SlidePDFFigure \:3068\:540c\:3058 locator (\:30d1\:30b9 / eagle:ID / sv://URI / References \:306e key)\:3002";
SlideNotebookText::usage = "SlideNotebookText[src] \:306f\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:672c\:6587\:3092 \"[Style] \:672c\:6587\" \:884c\:306e\:4e26\:3073\:3067\:8fd4\:3059(\:56f3\:306e\:4f4d\:7f6e\:306f \"[FIGn]\" \:884c)\:3002SlideNotebookText[src, \:898b\:51fa\:3057|\:898b\:51fa\:3057\:756a\:53f7] \:306f\:305d\:306e\:7bc0\:3060\:3051\:3092\:8fd4\:3059\:3002\:6570\:5f0f(DisplayFormula)\:3082\:542b\:3080\:3002\:30bb\:30eb\:304b\:3089\:753b\:50cf\:30dc\:30c3\:30af\:30b9\:3092\:5916\:3057\:3066\:304b\:3089\:6587\:5b57\:5217\:5316\:3059\:308b\:306e\:3067\:3001\:751f\:306e Import \:3068\:9055\:3063\:3066 Raster \:306e\:5727\:7e2e\:30c7\:30fc\:30bf\:304c\:672c\:6587\:306b\:6df7\:3056\:3089\:306a\:3044\:3002\:6570\:5f0f\:30bb\:30eb\:306e\:884c\:982d\:306b\:306f \"[EQn]\" \:304c\:4ed8\:304d\:3001\:672c\:6587\:306b\:306f\:5143\:306e LaTeX (\:5909\:63db\:30ce\:30fc\:30c8\:304c TaggingRules \:306b\:4fdd\:6301\:3057\:3066\:3044\:308c\:3070) \:3092\:51fa\:3059\:306e\:3067\:3001\:6570\:5f0f\:3092\:8aa4\:8aad\:3057\:306a\:3044\:3002\:305d\:306e\:307e\:307e\:30b9\:30e9\:30a4\:30c9\:3078\:5f15\:7528\:3059\:308b\:306b\:306f SlideNotebookFormula[src, n]\:3002opts: \"MaxCharacters\"(\:65e2\:5b9a 40000\:3001\:8d85\:904e\:5206\:306f\:5207\:308a\:8a70\:3081\:3066\:6ce8\:8a18) / \"Styles\"(\:65e2\:5b9a Automatic = \:672c\:6587\:7cfb\:30b9\:30bf\:30a4\:30eb)\:3002LLM \:751f\:6210\:30b3\:30fc\:30c9\:3067\:306f Import / Get \:304c\:6052\:4e45\:7981\:6b62 head \:306a\:306e\:3067\:3001\:7d20\:6750 .nb \:3092\:8aad\:3080\:3068\:304d\:306f\:3053\:308c\:3092\:4f7f\:3046\:3002";
SlideNotebookFormula::usage = "SlideNotebookFormula[src, n] \:306f\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e n \:756a\:76ee\:306e\:6570\:5f0f(SlideNotebookText \:306e \"[EQn]\" \:306b\:5bfe\:5fdc)\:3092\:3001**\:539f\:30bb\:30eb\:306e\:7d44\:7248\:3092\:4fdd\:3063\:305f\:307e\:307e** Cell \:3067\:8fd4\:3059\:3002SlideApplyScenario \:306e \"Figures\"->{...} \:306b\:305d\:306e\:307e\:307e\:6e21\:305b\:3070\:3001\:30b9\:30e9\:30a4\:30c9\:306b\:7d44\:7248\:3055\:308c\:305f\:6570\:5f0f\:3068\:3057\:3066\:8f09\:308b(\:30d7\:30ec\:30fc\:30f3\:6587\:5b57\:5217\:3078\:6f70\:3057\:3066\:66f8\:304d\:76f4\:3055\:306a\:3044\:3053\:3068)\:3002opts: \"Style\"(\:65e2\:5b9a \"DisplayFormula\") / FontSize / FontColor\:3002";
SlideNotebookFigure::usage = "SlideNotebookFigure[src, n] \:306f\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e n \:756a\:76ee\:306e\:56f3(SlideNotebookText \:306e \"[FIGn]\" \:306b\:5bfe\:5fdc)\:3092 Image \:3067\:8fd4\:3059\:3002\:539f\:56f3\:3092\:305d\:306e\:307e\:307e\:5f15\:7528\:3059\:308b\:305f\:3081\:306e\:5165\:53e3\:3067\:3001SlideApplyScenario \:306e \"Figures\"->{...} \:306b\:305d\:306e\:307e\:307e\:6e21\:305b\:308b(cite: \:3092\:5fc5\:305a\:4ed8\:3059)\:3002\:56f3\:306e\:7dcf\:6570\:3068\:6240\:5728\:306f SlideNotebookOutline / SlideNotebookText \:306e [FIGn] \:3067\:5206\:304b\:308b\:3002\:8fd4\:3059\:753b\:50cf\:306f\:9577\:8fba $SlideNotebookFigureMaxSize (\:65e2\:5b9a 1200px\:3001\"MaxSize\" \:3067\:5909\:66f4\:53ef) \:306b\:53ce\:3081\:308b \:2014 \:30c7\:30c3\:30ad\:306e\:30e9\:30b9\:30bf\:5316\:3067\:5b9f\:969b\:306b\:51fa\:308b\:306e\:306f\:9ad8\:3005 1120px \:306a\:306e\:3067\:3001\:305d\:308c\:4ee5\:4e0a\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:91cd\:304f\:3059\:308b\:3060\:3051\:306b\:306a\:308b\:3002";

$SlideNotebookFigureMaxSize::usage = "$SlideNotebookFigureMaxSize \:306f SlideNotebookFigure \:304c\:8fd4\:3059\:56f3\:306e\:9577\:8fba\:4e0a\:9650 px (\:65e2\:5b9a 1200)\:3002\:30c7\:30c3\:30ad\:306f WindowWidth 960 \:3092 1920 \:3078 2 \:500d\:3067\:30e9\:30b9\:30bf\:5316\:3057\:3001\:56f3\:30bb\:30eb\:306f ImageSize -> 560 \:306a\:306e\:3067\:3001\:6700\:7d42\:753b\:50cf\:306b\:51fa\:308b\:306e\:306f\:9ad8\:3005 1120 px\:3002\:305d\:308c\:3092\:8d85\:3048\:308b\:753b\:7d20\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3092\:91cd\:304f\:3059\:308b\:3060\:3051\:306b\:306a\:308b\:3002";
$SlideNotebookRasterizeSeconds::usage = "$SlideNotebookRasterizeSeconds \:306f SlideNotebookFigure \:304c\:30d9\:30af\:30bf\:56f3\:3092 Rasterize \:3059\:308b\:969b\:306e\:4e0a\:9650\:79d2 (\:65e2\:5b9a 30)\:3002Rasterize \:306f\:30d5\:30ed\:30f3\:30c8\:30a8\:30f3\:30c9\:3092\:8981\:6c42\:3059\:308b\:306e\:3067\:3001\:5fc5\:305a\:6642\:9593\:3067\:5207\:308b\:3002";

SlideSourceFile::usage = "SlideSourceFile[locator] \:306f\:6587\:732e locator (\:30d1\:30b9 / eagle:ID / sv://URI / URL / arxiv:ID / Google Slides URL / References \:306e key) \:3092\:89e3\:6c7a\:3057\:3066\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9\:3092\:8fd4\:3059(URL \:7cfb\:306f\:81ea\:52d5\:30c0\:30a6\:30f3\:30ed\:30fc\:30c9+PDF \:5316+\:30ad\:30e3\:30c3\:30b7\:30e5)\:3002\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c ClaudeAttach[SlideSourceFile[...]] \:3067\:8cc7\:6599\:3092\:95b2\:89a7\:3057\:3001\:5f15\:7528\:3059\:308b\:30da\:30fc\:30b8\:30fb\:9818\:57df\:3092\:6c7a\:3081\:308b\:306e\:306b\:4f7f\:3046\:3002";

$SlideHideToolbarInSlideshow::usage = "$SlideHideToolbarInSlideshow \:304c True (\:65e2\:5b9a) \:306a\:3089\:3001\:8868\:793a\:5207\:66ff(SlideToggleScreenEnvironment)\:3067 SlideShow \:3078\:5165\:308b\:3068\:304d\:306b\:6a19\:6e96\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:30c4\:30fc\:30eb\:30d0\:30fc(MultipurposeBar)\:3068\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5074 DockedCells(CloudPublishable \:306e Public/Private \:30d0\:30c3\:30b8\:7b49)\:3092\:4e00\:6642\:9000\:907f\:3057\:3001Working \:3078\:623b\:3059\:3068\:304d\:306b\:5fa9\:5143\:3059\:308b\:3002\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5074 DockedCells \:306f\:30b9\:30bf\:30a4\:30eb\:30b7\:30fc\:30c8\:306e\:30b9\:30e9\:30a4\:30c9\:30ca\:30d3\:30d0\:30fc\:5b9a\:7fa9\:3092\:4e0a\:66f8\:304d\:3059\:308b\:305f\:3081\:3001\:9000\:907f\:3057\:306a\:3044\:3068\:30ca\:30d3\:30d0\:30fc\:304c\:51fa\:306a\:3044\:3002";

SlideDeckInsertScenario::usage = "SlideDeckInsertScenario[nb, afterN, md] \:306f\:30b7\:30ca\:30ea\:30aa Markdown \:306e\:30b9\:30e9\:30a4\:30c9\:7fa4\:3092\:3001\:958b\:3044\:3066\:3044\:308b\:30c7\:30c3\:30ad\:306e afterN \:679a\:76ee\:306e\:76f4\:5f8c\:3078\:633f\:5165\:3059\:308b (afterN=0 \:3067\:5148\:982d)\:3002\:65e2\:5b58\:30b9\:30e9\:30a4\:30c9\:306b\:306f\:89e6\:308c\:306a\:3044 (\:5dee\:3057\:66ff\:3048\:306f SlideApplyScenario)\:3002\"Figures\"->{...} \:306f md \:4e2d\:306e <<FIG1>>.. \:306b\:5bfe\:5fdc\:3002\:6210\:529f\:3067 Success\:3001\:5931\:6557\:3067 Failure\:3002";

SlideInsertStory::usage = "SlideInsertStory[] \:306f\:30b9\:30c8\:30fc\:30ea\:30fc/\:8074\:304d\:624b\:4ed5\:69d8\:30bb\:30eb (SlideStory \:30b9\:30bf\:30a4\:30eb) \:3092\:633f\:5165\:3059\:308b\:3002Key: value \:884c\:3067 Graph: / Audience: / Slides: / Minutes: / Language: / Strategy: / Story: \:3092\:66f8\:304f (Audience \:306f \"\:9ad8\:6821\:751f, \:96fb\:6c17\:5316\:5b66=0.3, \:9ad8\:6821\:6570\:5b66III\" \:306e\:3088\:3046\:306b\:30d7\:30ea\:30bb\:30c3\:30c8\:3068\:9818\:57df=\:7406\:89e3\:5ea6\:306e\:4f75\:8a18)\:3002Working \:3067\:53ef\:8996\:3001SlideShow \:3067\:306f\:975e\:8868\:793a\:3001\:66f8\:304d\:51fa\:3057\:30fb\:82f1\:8a33\:306e\:5bfe\:8c61\:5916\:3002";
SlideGraphSpec::usage = "SlideGraphSpec[nb] \:306f SlideStory \:30bb\:30eb\:3068 Directive \:30bb\:30eb (Title: / Language:) \:304b\:3089\:77e5\:8b58\:30b0\:30e9\:30d5\:751f\:6210\:306e\:4ed5\:69d8\:9023\:60f3 <|\"Graph\", \"Audience\", \"Slides\", \"Minutes\", \"Seconds\", \"Language\", \"Strategy\", \"Story\", \"Title\", \"SecondsPerSlide\"|> \:3092\:8fd4\:3059\:3002nb \:306f NotebookObject / Notebook \:5f0f / \:4fdd\:5b58\:6e08\:307f\:30d1\:30b9\:3002";
SlideGraphBuild::usage = "SlideGraphBuild[] / SlideGraphBuild[nb, \"Mode\" -> Automatic | \"Agent\" | \"Extract\"] \:306f References \:306e\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304b\:3089 SlideGraphSeed \:3067\:7b2c\:4e00\:6b21 KG \:3092\:6c7a\:5b9a\:7684\:306b\:4f5c\:3063\:3066\:4fdd\:5b58\:3057\:3001\:7d9a\:3051\:3066\:7bc0\:3054\:3068\:306e\:63a8\:6572\:3092\:884c\:3046\:3002\:65e2\:5b9a\:306f SlideGraphRefine \:306e Direct \:9023\:9396 (LLM \:3092\:7bc0\:3054\:3068\:306b\:76f4\:63a5\:547c\:3076)\:3001\"Agent\" \:306f\:63a8\:6572\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8 (ClaudeEval) \:306b\:59d4\:8b72\:3001\"Extract\" \:306f\:548c\:8a33\:30ce\:30fc\:30c8\:7121\:3057\:3067 PDF \:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:8aad\:307e\:305b\:308b\:65e7\:7d4c\:8def\:3002\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:7121\:3051\:308c\:3070 Failure (NoSourceNotebook) \:3067 DocImportPaper \:3092\:6848\:5185\:3059\:308b\:3002v1.30: \:6587\:732e\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:7121\:304f (\:307e\:305f\:306f Story \:306b Source: \:30b7\:30ca\:30ea\:30aa)\:3001\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306b\:7b4b\:66f8\:304d\:304c\:3042\:308c\:3070\:3001\:7b4b\:66f8\:304d\:304b\:3089 KG \:3092\:4f5c\:308b (SlideGraphSeedScenario \:2192 \:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc SlideGraphRelated (Story \:306e Survey: local | web | off) \:2192 \:7b4b\:66f8\:304d\:306e\:5c55\:958b)\:3002";
SlideGraphIngest::usage = "SlideGraphIngest[graphId, json, opts] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306e JSON (\:6587\:5b57\:5217 / \:9023\:60f3) \:3092\:691c\:8a3c\:3057\:3066\:4fdd\:5b58\:3059\:308b\:552f\:4e00\:306e\:66f8\:304d\:8fbc\:307f\:53e3\:3002\"Merge\"->True \:3067\:4fdd\:5b58\:6e08\:307f KG \:3078\:306e\:5dee\:5206\:53d6\:308a\:8fbc\:307f\:3001\"Language\"->\"en\" \:3067\:7ffb\:8a33\:306e\:4f75\:8a18\:3001\"Link\"->True (\:65e2\:5b9a) \:3067\:5468\:8fba\:77e5\:8b58\:30ce\:30fc\:30c9\:3092\:5171\:6709 background \:5c64\:3078\:9023\:7d50\:3002Success[\"GraphIngested\", <|NodeCount, EdgeCount, Warnings, ..|>] \:307e\:305f\:306f Failure\:3002";
SlideGraphBackground::usage = "SlideGraphBackground[] / SlideGraphBackground[nb] \:306f Story \:30bb\:30eb\:306e\:8074\:304d\:624b\:306b\:8db3\:308a\:306a\:3044\:5468\:8fba\:77e5\:8b58\:30ce\:30fc\:30c9 (\:524d\:63d0\:77e5\:8b58) \:306e\:8ffd\:52a0\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72\:3059\:308b\:3002\:53d6\:308a\:8fbc\:307f\:306f SlideGraphIngest[.., \"Merge\"->True] \:3067\:3001\:5171\:6709 background \:5c64\:3078\:306e\:9023\:7d50\:306f\:81ea\:52d5\:3002";
SlideGraphTranslate::usage = "SlideGraphTranslate[nb, lang] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:30ce\:30fc\:30c9\:5358\:4f4d\:7ffb\:8a33\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72\:3059\:308b (SlideGraphIngest[.., \"Merge\"->True, \"Language\"->lang] \:3067\:4f75\:8a18)\:3002\:4ee5\:5f8c SlideGraphGenerate[.., \"Language\"->lang] \:3067\:305d\:306e\:8a00\:8a9e\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:751f\:6210\:3067\:304d\:308b (\:30c7\:30c3\:30ad\:306e\:30bb\:30eb\:5358\:4f4d\:82f1\:8a33 SlideTranslate \:3068\:306f\:72ec\:7acb)\:3002";
SlideGraphPlan::usage = "SlideGraphPlan[nb | graphId | kg, opts] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:9806\:5e8f\:6728\:3068\:30b9\:30e9\:30a4\:30c9\:8a08\:753b\:3092\:6c7a\:5b9a\:7684\:306b\:4f5c\:308b\:3002opts: \"Slides\" / \"Seconds\" / \"Audience\" / \"Strategy\" (Source|Coherent|Importance|Difficulty) / \"SecondsPerSlide\" / \"Language\" (\:672a\:6307\:5b9a\:306f Story \:30bb\:30eb)\:3002<|\"Graph\", \"Tree\", \"Plan\", \"Verify\", \"Spec\"|>\:3002";
SlideGraphPlanView::usage = "SlideGraphPlanView[nb | graphId, opts] \:306f\:8a08\:753b\:306e Dataset (\:756a\:53f7 / \:30bf\:30a4\:30c8\:30eb / \:8a70\:3081\:8fbc\:3093\:3060\:5b50 / \:79d2 / \:30d5\:30e9\:30b0)\:3002opts \:306f SlideGraphPlan \:3068\:540c\:3058\:3002";
SlideGraphGenerate::usage = "SlideGraphGenerate[nb | graphId | kg, opts] \:306f\:8a08\:753b\:3092\:30b7\:30ca\:30ea\:30aa Markdown \:306b\:6295\:5f71\:3057\:3001\:56f3\:8cc7\:7523 (NotebookFigure / Formula / PDFFigure / DeckSlide) \:3092 SlideNotebookFigure / SlideNotebookFormula / SlidePDFFigure / SlideDeckFigure \:3067\:5b9f\:4f53\:5316\:3059\:308b\:3002<|\"Markdown\", \"Figures\", \"Plan\", \"Tree\", \"Outline\", \"Warnings\", \"SlideCount\"|>\:3002opts: SlideGraphPlan \:3068\:540c\:3058 + \"Language\" / \"Talks\" (\:679a\:3054\:3068\:306e\:539f\:7a3f\:306e\:5dee\:3057\:66ff\:3048) / \"Title\"\:3002";
SlideGraphApply::usage = "SlideGraphApply[] / SlideGraphApply[nb, opts] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210\:3057\:305f\:30b9\:30e9\:30a4\:30c9\:7fa4\:3092\:30c7\:30c3\:30ad\:3078\:9069\:7528\:3059\:308b (10 \:679a\:305a\:3064 SlideDeckInsertScenario \:3092\:547c\:3076)\:3002\"Mode\" -> Automatic (v1.30) \:306f\:524d\:56de KG \:304b\:3089\:4f5c\:3063\:305f\:679a (\:984c\:76ee\:30bb\:30eb\:306e CellTags \"KGNode:<id>\") \:304c\:3042\:308c\:3070 \"Replace\" = \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092 KG \:306e\:30ce\:30fc\:30c9\:3078\:4fdd\:5b58\:3057\:3066\:304b\:3089\:524d\:56de\:306e\:679a\:3092\:6d88\:3057\:3001\:540c\:3058\:4f4d\:7f6e\:306b\:4f5c\:308a\:76f4\:3059 (\:554f\:7b54\:306f\:65b0\:3057\:3044\:679a\:3078\:623b\:308b)\:3002\:7121\:3051\:308c\:3070 \"Append\" = \:6700\:5f8c\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:5f8c (\"After\"->n \:3067\:4f4d\:7f6e\:6307\:5b9a)\:3002\"Polish\"->True \:306a\:3089 talk \:306e\:63a8\:6572\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:3078\:59d4\:8b72\:3057\:3001\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c SlideGraphApply[\"Talks\"->{..}] \:3067\:9069\:7528\:3059\:308b\:3002";
SlideGraphAdjust::usage = "SlideGraphAdjust[] / SlideGraphAdjust[nb] \:306f\:3001\:751f\:6210\:306e\:3042\:3068\:3067\:76f4\:3057\:305f\:3044\:3053\:3068\:3092\:8abf\:6574\:30bb\:30eb (SlideAdjust) \:306b\:66f8\:3044\:3066\:77e5\:8b58\:30b0\:30e9\:30d5\:3078\:53cd\:6620\:3059\:308b (\:30d1\:30ec\:30c3\:30c8\:300c\:8abf\:6574\:300d)\:3002\:8abf\:6574\:30bb\:30eb\:304c\:7121\:3051\:308c\:3070\:5165\:308c\:308b\:3002SlideGraphAdjust[nb | graphId, \"\:6307\:793a\"] \:306f\:6307\:793a\:3092\:76f4\:63a5\:6e21\:3059\:3002LLM \:304c KG \:306e\:5dee\:5206 (\:30b9\:30e9\:30a4\:30c9\:306e\:8ffd\:52a0\:30fb\:6587\:306e\:4fee\:6b63\:30fb\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:5916\:3059\:30fb\:56f3\:306e\:6307\:5b9a) \:3092\:8fd4\:3057\:3001\:53cd\:6620\:5f8c\:306b\:300c\:751f\:6210\:300d\:3067\:4f5c\:308a\:76f4\:3059\:3002opts: \"PDF\" -> \:8ad6\:6587 PDF \:306e locator (\:65e2\:5b9a\:306f\:6587\:732e\:6b04\:304b\:3089)\:3001\"Then\" -> \:53cd\:6620\:5f8c\:306b\:547c\:3076\:95a2\:6570\:3001\"Refine\" -> False \:3067\:672a\:63a8\:6572\:306e\:7bc0\:3092\:5148\:306b\:63a8\:6572\:3057\:306a\:3044 (v1.29: \:63a8\:6572\:3055\:308c\:3066\:3044\:306a\:3044\:7bc0\:304c\:3042\:308c\:3070\:5148\:306b\:63a8\:6572\:3057\:3066\:304b\:3089\:53cd\:6620\:3059\:308b)\:3002\:6307\:793a\:306b\:30b9\:30e9\:30a4\:30c9\:756a\:53f7 (\:300c43 \:4ee5\:964d\:300d\:300c17 \:679a\:76ee\:300d) \:304c\:3042\:308c\:3070\:3001\:305d\:306e\:679a\:306e\:30ce\:30fc\:30c9\:306e\:5143\:306e\:672c\:6587\:3092 LLM \:306b\:6e21\:3059\:3002";
SlideInsertAdjust::usage = "SlideInsertAdjust[] \:306f\:8abf\:6574\:30bb\:30eb (SlideAdjust) \:3092\:5165\:308c\:308b\:3002Working \:3067\:898b\:3048\:3001SlideShow \:3068\:66f8\:304d\:51fa\:3057\:3067\:306f\:96a0\:308c\:308b\:3002";
SlideGraphVisualize::usage = "SlideGraphVisualize[nb | graphId | kg, opts] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:56f3\:3092\:8fd4\:3059 (v1.30\:3002SourceVaultKGVisualize \:3078\:306e\:3064\:306a\:304e)\:3002\:30c7\:30c3\:30ad\:3092\:6e21\:3059\:3068 Story \:30bb\:30eb\:306e\:8074\:304d\:624b\:30fb\:679a\:6570\:3067\:8a08\:753b\:3092\:7acb\:3066\:3066\:679a\:756a\:53f7 (#n) \:3092\:91cd\:306d\:308b (\"Plan\" -> Automatic | True | False | \:8a08\:753b)\:3002opts \:306f SourceVaultKGVisualize \:3068\:540c\:3058: \"View\" -> \"Story\" | \"Sections\" | \"Focus\" | \"Graph\"\:3001\"Focus\"\:3001\"Radius\"\:3001\"EdgeKinds\"\:3001\"Layers\"\:3001\"Labels\"\:3001\"Selected\"\:3001\"OnClick\"\:3001\"Legend\"\:3001\"Hidden\"\:3001\"Language\"\:3002";
SlideGraphViewer::usage = "SlideGraphViewer[] / SlideGraphViewer[nb | graphId] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:3092\:898b\:308b\:7a93\:3092\:958b\:304f (v1.30\:3001\:30d1\:30ec\:30c3\:30c8\:300cKG\:56f3\:300d)\:3002\:8868\:793a (\:8a71\:306e\:6d41\:308c / \:7bc0 / \:5468\:8fba / \:8a08\:753b / \:4e00\:89a7)\:3001\:8fba\:3068\:5c64\:306e\:7d5e\:308a\:8fbc\:307f\:3001\:8a08\:753b\:306e\:91cd\:306d\:66f8\:304d\:3001\:540d\:524d\:306e\:91cf\:3001\:5468\:8fba\:306e\:534a\:5f84\:3092\:5207\:308a\:66ff\:3048\:3089\:308c\:3001\:56f3\:306e\:30ce\:30fc\:30c9\:3092\:30af\:30ea\:30c3\:30af\:3059\:308b\:3068\:53f3\:306b\:4e2d\:8eab (\:5c0e\:5165\:6587\:30fb\:8981\:70b9\:30fb\:88dc\:8db3\:30fb\:539f\:7a3f\:30fb\:56f3\:30fb\:8cea\:7591\:5fdc\:7b54\:30fb\:51fa\:5178\:30fb\:672c\:6587\:30fb\:3064\:306a\:304c\:308a) \:304c\:51fa\:308b\:3002\:30dc\:30bf\:30f3: \:5468\:8fba\:3092\:898b\:308b / \:30b9\:30e9\:30a4\:30c9\:3078 (\:305d\:306e\:679a\:3001\:8a70\:3081\:8fbc\:307e\:308c\:3066\:3044\:308c\:3070\:8a70\:3081\:8fbc\:307f\:5148\:306e\:679a\:306e\:984c\:76ee\:3078\:79fb\:52d5) / \:8abf\:6574\:306b\:66f8\:304f (\:8abf\:6574\:30bb\:30eb\:306b\:300c\:984c\:76ee\:300d(Id): \:3092\:8db3\:3059)\:3002\:691c\:7d22\:6b04\:3067\:4e00\:89a7\:3092\:7d5e\:308c\:308b\:3002\:300c\:66f4\:65b0\:300d\:3067 KG \:3092\:8aad\:307f\:76f4\:3059\:3002";
SlideGraphSeedScenario::usage = "SlideGraphSeedScenario[nb | {<|\"Title\"->..,\"Text\"->..|>..}, opts] \:306f\:6587\:66f8 (\:8ad6\:6587) \:306e\:7121\:3044\:767a\:8868\:306e\:305f\:3081\:306b\:3001\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb (SlidePrompt) \:306b\:66f8\:3044\:305f\:7b4b\:66f8\:304d (\:30b7\:30ca\:30ea\:30aa) \:304b\:3089\:7b2c\:4e00\:6b21 KG \:3092\:6c7a\:5b9a\:7684\:306b\:4f5c\:3063\:3066\:4fdd\:5b58\:3059\:308b (v1.30)\:3002\:30bb\:30eb\:306f\:898b\:51fa\:3057 (#) / \:884c\:982d\:306e\:756a\:53f7 / \:7a7a\:884c\:3067\:90e8\:306b\:5206\:3051\:3001\:90e8\:3054\:3068\:306b\:7bc0\:30ce\:30fc\:30c9 sc<i> \:3068\:7b4b\:66f8\:304d\:30ce\:30fc\:30c9 sc<i>_d (\:672c\:6587 = \:7b4b\:66f8\:304d\:3001\:8981\:70b9\:306a\:3057) \:3092\:7f6e\:304f\:3002KG \:306e Kind \:306f \"Scenario\"\:3002\:7d9a\:304f\:63a8\:6572 (SlideGraphRefine) \:304c\:7b4b\:66f8\:304d\:3092\:767a\:8868\:7528\:306e\:30ce\:30fc\:30c9 (sc<i>_1..\:3001\:95a2\:9023\:7814\:7a76 rw_<\:5019\:88dc\:756a\:53f7>\:3001\:524d\:63d0 bg_*) \:306b\:5c55\:958b\:3059\:308b\:3002opts: \"Graph\", \"Title\", \"Language\", \"Save\", \"Keep\" (\"Background\" = \:4f5c\:308a\:76f4\:3057\:3066\:3082\:5468\:8fba\:77e5\:8b58\:3092\:6b8b\:3059)\:3002";
SlideGraphRelated::usage = "SlideGraphRelated[nb | graphId, opts] \:306f\:30b7\:30ca\:30ea\:30aa KG \:306e\:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc\:3092\:96c6\:3081\:3066 KG \:306e \"Related\" \:306b\:4fdd\:5b58\:3059\:308b (v1.30\:3001\:975e\:540c\:671f)\:3002LLM \:304c\:7b4b\:66f8\:304d\:304b\:3089\:691c\:7d22\:8a9e (\:77ed\:3044\:8a9e\:53e5 4\:301c8 \:500b) \:3092\:4f5c\:308a\:3001SourceVaultSummaries (\:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e\:8ad6\:6587\:30fbEagle) \:3067\:63a2\:3059\:3002\"Web\" -> True (Story \:306e Survey: web) \:306e\:3068\:304d\:3060\:3051 SourceVaultWebSearch \:3082\:4f7f\:3046 (\:691c\:7d22\:8a9e\:304c\:5916\:306b\:51fa\:308b\:305f\:3081)\:3002PrivacyLevel >= 0.5 \:306e\:5019\:88dc\:306f\:30c7\:30c3\:30ad\:306e PrivacyLevel \:304c\:305d\:308c\:4ee5\:4e0a\:306e\:3068\:304d\:3060\:3051\:6b8b\:3059\:3002opts: \"Web\", \"MaxCandidates\" (20), \"Then\" (\:7d42\:308f\:3063\:305f\:3089\:547c\:3076\:95a2\:6570), \"Audience\", \"Story\"\:3002\:7d50\:679c\:306f SlideWorkflow`Private`$iSWRelatedLast\:3002";
SlideTalkFill::usage = "SlideTalkFill[] / SlideTalkFill[nb] \:306f\:539f\:7a3f (\:30c8\:30fc\:30af\:30bb\:30eb) \:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9\:306b\:3060\:3051\:539f\:7a3f\:3092\:66f8\:304f (v1.30\:3001\:30d1\:30ec\:30c3\:30c8\:300c\:767a\:8868\:306e\:6e96\:5099\:300d\:306e\:300c\:539f\:7a3f\:300d)\:3002LLM \:304c\:30c7\:30c3\:30ad\:5168\:4f53\:306e\:6d41\:308c\:3092\:898b\:3066 8 \:679a\:305a\:3064\:66f8\:304d\:3001\:5404\:30b9\:30e9\:30a4\:30c9\:306e\:30c8\:30fc\:30af\:30bb\:30eb\:306b\:5165\:308c\:308b (\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c\:3042\:308c\:3070\:305d\:306e\:524d)\:3002\:5168\:679a\:306b\:539f\:7a3f\:304c\:3042\:308c\:3070\:4f55\:3082\:3057\:306a\:3044 (\:539f\:7a3f\:3092 md \:306b\:66f8\:304d\:51fa\:3059\:306e\:306f SlideTalkBuild)\:3002";
SlideGraphBuildDeck::usage = "SlideGraphBuildDeck[graphId | kg, \"deck.nb\", opts] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:65b0\:3057\:3044\:30c7\:30c3\:30ad\:30d5\:30a1\:30a4\:30eb\:3092\:751f\:6210\:3059\:308b (headless \:53ef)\:3002opts: SlideGraphGenerate \:3068\:540c\:3058 + \"TitleSlide\" / \"Event\" / \"Author\" / \"Date\"\:3002<|\"File\", \"Slides\", \"Warnings\", \"Verify\", \"Plan\"|>\:3002";
SlideGraphSurvey::usage = "SlideGraphSurvey[{graphId1, graphId2, ..}, \"deck.nb\", opts] \:306f\:8907\:6570\:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:3092\:5408\:6210 (\:5171\:6709 background \:30ce\:30fc\:30c9\:3092\:7d71\:5408\:3001\:8ad6\:6587\:9593 RelatedTo \:3092\:4ed8\:4e0e) \:3057\:3066\:30b5\:30fc\:30d9\:30a4\:30c7\:30c3\:30ad\:3092\:751f\:6210\:3059\:308b\:3002opts: \"Title\" / \"Slides\" / \"Seconds\" / \"Audience\" / \"Language\" / \"Chronological\" / \"GraphId\" / \"Save\" (\:5408\:6210 KG \:3092\:4fdd\:5b58\:3001\:65e2\:5b9a True)\:3002";
SlideGraphView::usage = "SlideGraphView[nb | graphId] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:30ce\:30fc\:30c9\:4e00\:89a7 Dataset\:3002SlideGraphView[src, \"Map\"] \:306f SlideGraphVisualize \:306e\:56f3 (v1.30)\:3001SlideGraphView[src, \"Graph\"] \:306f WL Graph\:3001\"Tree\" \:306f\:9806\:5e8f\:6728\:306e Dataset\:3001\"Plan\" \:306f\:8a08\:753b\:306e Dataset\:3002";
SlideGraphShow::usage = "SlideGraphShow[\"Plan\" | \"Nodes\" | \"Graph\" | \"Tree\"] \:306f\:958b\:3044\:3066\:3044\:308b\:30c7\:30c3\:30ad\:306e Appendix (\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d) \:306b\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:8868\:793a\:3092\:66f8\:304d\:51fa\:3059 (\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:8a08\:753b\:300d\:300cKG\:8868\:793a\:300d)\:3002";
SlideGraphLoad::usage = "SlideGraphLoad[nb | graphId] \:306f\:4fdd\:5b58\:6e08\:307f\:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:9023\:60f3\:3092\:8fd4\:3059 (nb \:306a\:3089 Story \:30bb\:30eb\:306e Graph: \:304b\:3089)\:3002";

SlideGraphSeed::usage = "SlideGraphSeed[nb | key | path, opts] \:306f\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af (DocImportPaper \:306e\:51fa\:529b\:306a\:3069) \:306e\:6bb5\:843d\:69cb\:9020\:304b\:3089**\:7b2c\:4e00\:6b21\:306e\:77e5\:8b58\:30b0\:30e9\:30d5**\:3092\:6c7a\:5b9a\:7684\:306b\:4f5c\:3063\:3066\:4fdd\:5b58\:3059\:308b\:3002\:898b\:51fa\:3057 \:2192 Section\:3001\:6bb5\:843d \:2192 Concept (\:672c\:6587\:306f \"Text\" \:306b\:4fdd\:6301)\:3001\:56f3 \:2192 Figure (NotebookFigure \:8cc7\:7523\:3001\:30ad\:30e3\:30d7\:30b7\:30e7\:30f3\:300c\:56f31 |\:300d\:300cFigure 1:\:300d\:3092\:5408\:6d41)\:3001\:6570\:5f0f \:2192 Equation (Formula \:8cc7\:7523)\:3001Contains / Precedes / Supports \:8fba\:3002Title \:30bb\:30eb\:304c\:7121\:3051\:308c\:3070\:6700\:521d\:306e\:898b\:51fa\:3057 (\:8ad6\:6587\:984c\:540d) \:306f root \:306b\:7573\:307f\:3001\:8457\:8005\:884c\:306f\:843d\:3068\:3057\:3001root \:76f4\:4e0b\:306e\:6700\:521d\:306e\:9577\:3044\:6bb5\:843d\:3092\:300c\:6982\:8981\:300d\:30ce\:30fc\:30c9\:306b\:3059\:308b\:3002\:4ed8\:9332 (A. / Appendix / \:4ed8\:9332) \:306f Importance 0.3\:3001\:53c2\:8003\:6587\:732e\:30fb\:8b1d\:8f9e\:30fbAI Disclosure \:306a\:3069\:306f\:8aad\:307f\:98db\:3070\:3059\:3002LLM \:306f\:4f7f\:308f\:306a\:3044\:3002opts: \"Graph\" (GraphId\:3001\:65e2\:5b9a\:306f Story \:30bb\:30eb) / \"Title\" / \"Language\" / \"MinCharacters\" (40) / \"Save\" / \"Reconstruction\" (\:65e2\:5b9a False: DocImportPaper \:306e\:7b2c\:4e8c\:90e8\:300c\:8a08\:7b97\:306e\:518d\:69cb\:6210\:300d\:3092\:9664\:5916) / \"Keep\" (\:65e2\:5b9a \"Background\": \:518d seed \:3067\:3082\:4fdd\:5b58\:6e08\:307f KG \:306e Background / Shared \:5c64\:306e\:30ce\:30fc\:30c9\:3068\:8fba\:3092\:6b8b\:3059\:3002None \:3067\:6368\:3066\:308b)\:3002\:7d50\:679c <|\"Graph\", \"Title\", \"PaperTitle\", \"NodeCount\", \"EdgeCount\", \"Sections\", \"Paragraphs\", \"Figures\", \"Formulas\", \"Kept\", \"Skipped\", \"Warnings\", \"KG\"|>\:3002";
SlideGraphSectionText::usage = "SlideGraphSectionText[graphId, sectionId, opts] \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:7bc0 (Section \:30ce\:30fc\:30c9) \:306e**\:81ea\:8eab\:306e\:672c\:6587\:30ce\:30fc\:30c9** (\:76f4\:4e0b\:306e\:6bb5\:843d\:30fb\:56f3\:30fb\:5f0f\:3002\:5165\:308c\:5b50\:306e\:4e0b\:4f4d\:7bc0\:306f\:5225\:6271\:3044) \:3092 Id / Kind / Label / Text \:306e\:8aad\:307f\:3084\:3059\:3044\:30c6\:30ad\:30b9\:30c8\:3067\:8fd4\:3059 (\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c\:7bc0\:3054\:3068\:306b\:78e8\:304f\:305f\:3081\:306e\:8aad\:307f\:53e3\:3002\:623b\:308a\:5024\:306f\:8aad\:3080\:305f\:3081\:306e\:3082\:306e\:3067\:89e3\:6790\:306f\:4e0d\:8981)\:3002\:9577\:3044\:7bc0\:306f \"MaxCharacters\" (\:65e2\:5b9a 4000) \:3054\:3068\:306b\:30ce\:30fc\:30c9\:5883\:754c\:3067\:30da\:30fc\:30b8\:306b\:5206\:304b\:308c\:3001\"Page\" -> n \:3067\:7d9a\:304d\:3092\:8aad\:3080 (\:672b\:5c3e\:306b\:6b21\:30da\:30fc\:30b8\:306e\:5f0f\:3092\:793a\:3059)\:3002SlideGraphSectionText[graphId] \:306f\:7bc0\:306e\:4e00\:89a7 (Id / Label / \:672c\:6587\:30ce\:30fc\:30c9\:6570 / \:4e0b\:4f4d\:7bc0)\:3002\"Format\" -> \"JSON\" \:3067 JSON \:6587\:5b57\:5217 (<|\"Section\", \"Nodes\", \"Nested\", \"Edges\"|>\:3001\:30da\:30fc\:30b8\:7121\:3057)\:3002";
SlideGraphRefine::usage = "SlideGraphRefine[] / SlideGraphRefine[nb, opts] / SlideGraphRefine[graphId, opts] \:306f\:7b2c\:4e00\:6b21 KG (SlideGraphSeed) \:3092\:7bc0\:3054\:3068\:306b\:78e8\:304f\:3002\:65e2\:5b9a (\"Mode\" -> \"Direct\") \:306f LLM \:3092\:7bc0\:3054\:3068\:306b\:76f4\:63a5\:547c\:3076\:9023\:9396: \:672a\:63a8\:6572 (\:7bc0\:4e00\:89a7\:3067\:300c\:6e08\:300d\:3067\:306a\:3044) \:306e\:7bc0\:3092\:4e00\:89a7\:306e\:9806\:306b\:3001\:672c\:6587\:30ce\:30fc\:30c9\:5408\:8a08 \"BatchNodes\" (8) \:4ee5\:4e0b\:306e\:96a3\:63a5\:7bc0\:3092\:307e\:3068\:3081\:3066 1 \:30ea\:30af\:30a8\:30b9\:30c8\:306b\:3057\:3001\:7bc0\:672c\:6587\:3092\:6307\:793a\:306b\:540c\:68b1\:3057\:3066\:5dee\:5206 JSON (Nodes (Label / Summary / Points / Talk) / Edges / Remove) \:3092\:53d7\:3051\:53d6\:308a SlideGraphIngest[.., \"Merge\"->True] \:3067\:53d6\:308a\:8fbc\:3080 (\:5f62\:5f0f\:9055\:53cd\:306f 1 \:56de\:518d\:554f\:5408\:305b\:3001Id \:306f\:672c\:6587\:306b\:51fa\:305f\:65e2\:5b58 Id \:3068 bg_* \:3060\:3051\:3092\:53d7\:7406\:3001\:7bc0\:3068 root \:306f Remove \:3057\:306a\:3044)\:3002Talk \:306f Points \:3068\:540c\:3058\:9806\:306e\:539f\:7a3f (\:30b9\:30e9\:30a4\:30c9\:306e\:7b87\:6761\:66f8\:304d\:3068\:539f\:7a3f\:3092\:5bfe\:5fdc\:3055\:305b\:308b)\:3002\:9014\:4e2d\:3067\:6b62\:3081\:3066\:3082\:300c\:6e08\:300d\:306e\:7bc0\:3092\:98db\:3070\:3057\:3066\:518d\:958b\:3067\:304d\:308b\:3002\"Mode\" -> \"Talk\" \:306f\:8981\:70b9\:306f\:3042\:308b\:304c Talk \:306e\:7121\:3044\:30ce\:30fc\:30c9\:306b\:539f\:7a3f\:3060\:3051\:3092\:8db3\:3059\:8efd\:3044\:56de (\:63a8\:6572\:6e08\:307f\:306e\:53e4\:3044 KG \:7528)\:3002\"Mode\" -> \"Agent\" \:306f\:5f93\:6765\:306e\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:59d4\:8b72\:3002\"Sections\" -> {\"s3\", ..} \:3067\:5bfe\:8c61\:3092\:7d5e\:308b\:3002graphId \:5f62\:5f0f\:3067\:306f \"Audience\" / \"Story\" \:3092\:6e21\:305b\:308b\:3002";

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
iMetaStyleCellQ[Cell[_, "Note" | "Dictionary" | "Directive" | "Bibliography" | "References" | "SlidePrompt" | "SlideTalk" | "SlideQA" | "SlideStory" | "SlideAdjust", ___]] := True;
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

(* \:898b\:51fa\:3057\:306e\:5c5e\:6027 {expected=20 node=p27} (v1.30: node= \:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:4f5c\:3063\:305f\:679a\:306e\:51fa\:3069\:3053\:308d\:3002\:984c\:76ee\:30bb\:30eb\:306e CellTags "KGNode:<id>") *)
iParseSlideAttrs[t_String] := With[{m = StringCases[t,
    "{" ~~ a : Except["{" | "}"] .. ~~ "}" ~~ (WhitespaceCharacter ...) ~~ EndOfString :> a]},
  If[m =!= {} && StringStartsQ[StringTrim[First[m]], "expected=" | "node="], First[m], None]];
iParseSlideNodeAttr[t_String] := With[{a = iParseSlideAttrs[t]},
  If[StringQ[a], FirstCase[StringCases[a, "node=" ~~ v : Except[WhitespaceCharacter | "}"] .. :> v], s_String, None], None]];
iParseSlideTitle[t_String] := Module[{title = t, exp = None, a = iParseSlideAttrs[t], e},
  If[StringQ[a],
    e = StringCases[a, "expected=" ~~ d : DigitCharacter .. :> d];
    If[e =!= {}, exp = ToExpression[First[e]]];
    title = StringTrim[StringReplace[t, "{" <> a <> "}" -> ""]]];
  {title, exp}];
iSWHeadingAttrs[exp_, node_] := With[{parts = Join[
    If[StringQ[exp] && exp =!= "", {"expected=" <> exp}, {}],
    If[StringQ[node] && node =!= "", {"node=" <> node}, {}]]},
  If[parts === {}, "", " {" <> StringRiffle[parts, " "] <> "}"]];

iParseImageSpecs[line_String] := StringCases[line,
  "![" ~~ alt : Except["]"] ... ~~ "](" ~~ path : Except[")"] .. ~~ ")" :>
    With[{w = StringCases[alt, "w=" ~~ d : DigitCharacter .. :> ToExpression[d]]},
      <|"Path" -> StringTrim[path], "Width" -> If[w === {}, Automatic, First[w]]|>]];

SlideScenarioFromMarkdown[File[f_String]] := SlideScenarioFromMarkdown[
  Import[iResolvePath[f], "Text"]];

SlideScenarioFromMarkdown[md_String] := Module[
  {lines, meta, body, slides = {}, cur = None, curContent = {}, curTalk = {},
   curQA = {},
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
    (* qa: \:884c\:3082\:540c\:3058\:304f\:672b\:5c3e\:306e 1 \:30a8\:30f3\:30c8\:30ea\:3078 (\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306f\:5e38\:306b\:30c8\:30fc\:30af\:306e\:6b21) *)
    If[curQA =!= {},
      AppendTo[curContent, {"QA", StringRiffle[curQA, "\n"]}]];
    curQA = {};
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
          With[{nd = iParseSlideNodeAttr[t]}, If[StringQ[nd], cur["Node"] = nd]];
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
      StringStartsQ[StringTrim[line], "qa:"],
      AppendTo[curQA, StringTrim[StringDrop[StringTrim[line], 3]]],
      StringStartsQ[StringTrim[line], "cite:"],
      AppendTo[curContent, {"Cite", StringTrim[StringDrop[StringTrim[line], 5]]}],
      StringStartsQ[StringTrim[line], "crumb:"],
      AppendTo[curContent, {"Crumb", StringTrim[StringDrop[StringTrim[line], 6]]}],
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
         {item, Cases[Lookup[slide, "Content", {}], {"Talk", _}]}];
       Do[AppendTo[out, StringRiffle[("qa: " <> #) & /@
           StringSplit[item[[2]], "\n"], "\n"]],
         {item, Cases[Lookup[slide, "Content", {}], {"QA", _}]}]),
      AppendTo[out, "## " <> slide["Title"] <>
        iSWHeadingAttrs[If[KeyExistsQ[slide, "ExpectedSeconds"], ToString[slide["ExpectedSeconds"]], None],
          Lookup[slide, "Node", None]]];
      Do[
        AppendTo[out, Switch[item[[1]],
          "Item", "- " <> item[[2]],
          "Subitem", "  - " <> item[[2]],
          "Subsubitem", "    - " <> item[[2]],
          "ItemParagraph" | "SubitemParagraph" | "SubsubitemParagraph", "> " <> item[[2]],
          "Crumb", "crumb: " <> item[[2]],
          "Text", item[[2]],
          "Image", "![" <> If[item[[2, "Width"]] === Automatic, "",
            "w=" <> ToString[item[[2, "Width"]]]] <> "](" <> item[[2, "Path"]] <> ")",
          "Images", StringJoin[("![" <> If[#["Width"] === Automatic, "", "w=" <> ToString[#["Width"]]] <>
            "](" <> #["Path"] <> ")") & /@ item[[2]]],
          "Cite", "cite: " <> item[[2]],
          "Keep", "<<FIG" <> ToString[item[[2]]] <> ">>",
          "Table", iSWTableToMd[item[[2]]],
          "Talk", StringRiffle[("talk: " <> #) & /@ StringSplit[item[[2]], "\n"], "\n"],
          "QA", StringRiffle[("qa: " <> #) & /@ StringSplit[item[[2]], "\n"], "\n"],
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

iContentCell[{"Input", code_String}] := Cell[code, "Input"];

iContentCell[{"Image", spec_Association}] :=
  Cell[BoxData[ToBoxes[iSizedSlideImage[spec]]], "Input", TextAlignment -> Center];

iContentCell[{"Images", specs_List}] :=
  Cell[BoxData[ToBoxes[Grid[{iSizedSlideImage[#, 0.9*820/Length[specs], 340] & /@ specs},
    Alignment -> Top, Spacings -> {2, 0}]]], "Input", TextAlignment -> Center];

(* \:8868\:30bb\:30eb: \:5185\:5bb9\:306f TaggingRules \:306b\:4fdd\:6301\:3057\:3066 md \:3078\:5f80\:5fa9\:53ef\:80fd\:306b\:3059\:308b\:3002
   "ShowInput" \:30bf\:30b0\:3067 IncludeInput \:8a2d\:5b9a\:306b\:3088\:3089\:305a\:66f8\:304d\:51fa\:3057\:306b\:6b8b\:308b *)
iContentCell[{"Talk", text_String}] := Cell[iSWTalkSpeakText[text], "SlideTalk"];

(* \:30d1\:30f3\:304f\:305a (v1.25): \:300c\:7b2ck\:90e8 \:2026 \:203a \:89aa\:300d\:3092\:984c\:76ee\:306e\:76f4\:4e0b\:306b\:5c0f\:3055\:304f\:51fa\:3057\:3001\:4eca\:306e\:8a71\:304c\:5168\:4f53\:306e\:3069\:3053\:304b\:3092\:793a\:3059\:3002KG \:751f\:6210\:304c crumb: \:884c\:3067\:51fa\:3059 *)
iContentCell[{"Crumb", text_String}] := Cell[text, "SlideCrumb"];
(* \:7b87\:6761\:66f8\:304d\:30fb\:5730\:306e\:6587\:306e $tex$ \:306f\:884c\:5185\:6570\:5f0f\:306b\:7d44\:3080 (\:5143 boxes \:8f9e\:66f8 \:2192 TeX \:8aad\:307f\:8fbc\:307f \:2192 \:6587\:5b57\:5217) *)
iContentCell[{style : "Item" | "Subitem" | "Subsubitem" | "ItemParagraph" | "SubitemParagraph" | "SubsubitemParagraph" | "Text", text_String}] :=
  Cell[iSWInlineTextData[text], style];

iContentCell[{"QA", text_String}] := Cell[text, "SlideQA"];

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
  (* Eagle \:306e PDF (sv://object/eagle-<id>): \:53d6\:308a\:8fbc\:307f\:6e08\:307f\:30bd\:30fc\:30b9\:3067\:306f\:306a\:3044\:306e\:3067 Eagle \:5074\:306e\:8aad\:307f\:53e3\:3067\:5f15\:304f *)
  StringStartsQ[src, "sv://object/eagle-"],
  Module[{r},
    r = If[Length[DownValues[SourceVault`SourceVaultEagleObjectInfo]] > 0,
      Quiet[Check[SourceVault`SourceVaultEagleObjectInfo[src], $Failed]], $Failed];
    If[AssociationQ[r] && StringQ[Lookup[r, "File", None]] && FileExistsQ[r["File"]],
      r["File"], iSWResolveRefPath["eagle:" <> StringDrop[src, StringLength["sv://object/eagle-"]]]]],
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
    hit = If[Head[nb] =!= NotebookObject, None,
      (refs = Quiet[Check[iSWReferencesList[nb], {}]];
       SelectFirst[refs, #["Key"] === src &, None])];
    Which[
      hit =!= None && hit["Locator"] =!= src, iSWResolveRefPath[hit["Locator"]],
      (* \:30c7\:30c3\:30ad\:304c\:7121\:304f\:3066\:3082 KG \:306e Sources \:306b\:5143\:306e\:6587\:732e locator \:304c\:3042\:308c\:3070\:305d\:308c\:3067\:89e3\:304f *)
      With[{ks = iSWKGSourceOf[src]}, AssociationQ[ks] && StringQ[Lookup[ks, "Reference", None]] &&
        ks["Reference"] =!= "" && ks["Reference"] =!= src],
        iSWResolveRefPath[iSWKGSourceOf[src]["Reference"]],
      (* References \:306e key \:3067\:3082\:306a\:3051\:308c\:3070\:3001\:30c7\:30c3\:30ad\:3068\:540c\:3058\:30d5\:30a9\:30eb\:30c0\:306e\:76f8\:5bfe\:30d1\:30b9\:3068\:3057\:3066\:89e3\:304f\:3002
         \:7d20\:6750 (\:8ad6\:6587\:306e PDF \:3084\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af) \:3092\:30c7\:30c3\:30ad\:306e\:96a3\:306b\:7f6e\:304f\:904b\:7528\:3067\:3001
         "[SHH2024] PIIS2666386424004363.nb | \:548c\:8a33" \:306e\:3088\:3046\:306b\:30d5\:30a1\:30a4\:30eb\:540d\:3060\:3051\:3092
         locator \:306b\:66f8\:3051\:308b\:3088\:3046\:306b\:3059\:308b\:3002 *)
      True, iSWDeckRelativePath[nb, src]]]];

(* \:30c7\:30c3\:30ad (\:7121\:3051\:308c\:3070\:8a55\:4fa1\:4e2d\:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af) \:306e\:30d5\:30a9\:30eb\:30c0\:3002\:30c6\:30b9\:30c8\:3067\:5dee\:3057\:66ff\:3048\:3089\:308c\:308b\:3088\:3046
   \:306b 1 \:95a2\:6570\:306b\:9589\:3058\:308b *)
iSWDeckDirectory[nb_] := With[{
    d = If[Head[nb] === NotebookObject,
      Quiet@Check[NotebookDirectory[nb], $Failed], $Failed]},
  If[StringQ[d], d, Quiet@Check[NotebookDirectory[], $Failed]]];

iSWDeckRelativePath[nb_, f_String] := Module[{d, p},
  d = iSWDeckDirectory[nb];
  If[! StringQ[d], Return[$Failed]];
  p = FileNameJoin[{d, f}];
  If[FileExistsQ[p], p, $Failed]];
iSWDeckRelativePath[___] := $Failed;

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
Options[SlidePDFImages] = {"MinSize" -> 80, "Page" -> All};

(* \:30da\:30fc\:30b8\:3054\:3068\:306e\:57cb\:3081\:8fbc\:307f\:753b\:50cf: \:5404\:30da\:30fc\:30b8\:306e\:30e9\:30b9\:30bf\:6570\:3092 PageGraphics \:3067\:6570\:3048\:3001Import[pdf, "Images"] \:306e\:4e26\:3073
   (\:51fa\:73fe\:9806) \:306b\:5bfe\:5fdc\:3055\:305b\:308b\:3002\:7e26\:6a2a\:6bd4\:304c\:5408\:308f\:306a\:3051\:308c\:3070\:5bfe\:5fdc\:304c\:53d6\:308c\:306a\:3044\:3068\:307f\:306a\:3059 (Failure)\:3002
   \:8ad6\:6587 1 \:30da\:30fc\:30b8\:76ee\:306e\:56f3 (\:30b0\:30e9\:30d5\:30a3\:30ab\:30eb\:30a2\:30d6\:30b9\:30c8\:30e9\:30af\:30c8) \:306f\:30ad\:30e3\:30d7\:30b7\:30e7\:30f3\:304c\:7121\:304f\:548c\:8a33\:30ce\:30fc\:30c8\:306b\:5165\:3089\:306a\:3044\:306e\:3067\:3001\:3053\:3053\:304b\:3089\:5f15\:304f *)
$iSWPDFImageCache = <||>;
iSWPDFImagesOf[path_String] := Module[{key = {path, Quiet[FileByteCount[path]]}, imgs},
  If[KeyExistsQ[$iSWPDFImageCache, key], Return[$iSWPDFImageCache[key]]];
  (* Check \:306f\:4f7f\:308f\:306a\:3044: \:521d\:56de\:306e Import \:304c\:6587\:5b57\:30b3\:30fc\:30c9\:306e\:8b66\:544a ($CharacterEncoding::sjis) \:3092\:51fa\:3059\:3068\:753b\:50cf\:304c\:53d6\:308c\:3066\:3044\:3066\:3082
     \:5931\:6557\:6271\:3044\:306b\:306a\:308a\:3001\:7a7a\:306e\:307e\:307e\:899a\:3048\:3066\:3057\:307e\:3063\:305f\:3002\:7d50\:679c\:306e\:578b\:3067\:5224\:5b9a\:3057\:3001\:5931\:6557\:306f\:899a\:3048\:306a\:3044 *)
  imgs = Quiet[Import[path, "Images"]];
  If[!ListQ[imgs], Return[{}]];
  imgs = Select[imgs, ImageQ];
  If[Length[$iSWPDFImageCache] > 8, $iSWPDFImageCache = <||>];
  $iSWPDFImageCache[key] = imgs];
$iSWPDFRasterCache = <||>;
(* \:30da\:30fc\:30b8 p \:306e\:30e9\:30b9\:30bf\:306e {\:5e45, \:9ad8\:3055} \:306e\:4e26\:3073 *)
iSWPDFPageRasters[path_String, p_Integer] := Module[{key = {path, Quiet[FileByteCount[path]], p}, g, r},
  If[KeyExistsQ[$iSWPDFRasterCache, key], Return[$iSWPDFRasterCache[key]]];
  g = Quiet[Import[path, {"PageGraphics", p}]];
  If[ListQ[g], g = If[g === {}, $Failed, First[g]]];
  If[Head[g] =!= Graphics, Return[$Failed]];
  r = Cases[g, x : (_Raster | Inset[_Image, ___]) :>
    If[Head[x] === Raster, Reverse[Take[Dimensions[First[x]], 2]], ImageDimensions[First[x]]], Infinity];
  $iSWPDFRasterCache[key] = r];
$iSWPDFPageCountCache = <||>;
iSWPDFPageCount[path_String] := Module[{key = {path, Quiet[FileByteCount[path]]}, n},
  If[KeyExistsQ[$iSWPDFPageCountCache, key], Return[$iSWPDFPageCountCache[key]]];
  n = Quiet[Import[path, {"PDF", "PageCount"}]];
  If[! IntegerQ[n], Return[$Failed]];
  $iSWPDFPageCountCache[key] = n];
iSWAspect[{w_, h_}] := N[w/Max[h, 1]];
iSWPDFAspectOKQ[im_, wh_] := With[{a = iSWAspect[ImageDimensions[im]], b = iSWAspect[wh]}, Abs[a - b] < 0.05 b + 0.02];
(* \:30da\:30fc\:30b8\:306e\:4e26\:3073\:306b\:6cbf\:3063\:3066\:3001\:30e9\:30b9\:30bf\:3054\:3068\:306b\:7e26\:6a2a\:6bd4\:306e\:5408\:3046\:6b21\:306e\:753b\:50cf\:3092\:5272\:308a\:5f53\:3066\:308b (\:5408\:308f\:306a\:3044\:753b\:50cf = \:30da\:30fc\:30b8\:306b\:73fe\:308c\:306a\:3044
   \:30a2\:30a4\:30b3\:30f3\:306a\:3069\:306f\:98db\:3070\:3059)\:3002\:9014\:4e2d\:3067\:5408\:3046\:753b\:50cf\:304c\:7121\:3051\:308c\:3070\:5bfe\:5fdc\:304c\:53d6\:308c\:306a\:3044 ($Failed) *)
iSWPDFPageImages[path_String, page_Integer] := Catch[Module[{imgs = iSWPDFImagesOf[path], j = 0, out = {}, rs, k, np},
  (* 1 \:30da\:30fc\:30b8\:3060\:3051\:306e PDF \:306a\:3089\:753b\:50cf\:306f\:3059\:3079\:3066\:305d\:306e\:30da\:30fc\:30b8\:306e\:3082\:306e (\:30da\:30fc\:30b8\:306e\:30b0\:30e9\:30d5\:30a3\:30c3\:30af\:30b9\:306b\:753b\:50cf\:304c\:73fe\:308c\:306a\:3044 PDF \:3082\:3042\:308b) *)
  np = iSWPDFPageCount[path];
  If[IntegerQ[np] && page > np, Throw[$Failed, "pdfimg"]];
  If[np === 1, Throw[imgs, "pdfimg"]];
  Do[
    rs = iSWPDFPageRasters[path, q];
    If[!ListQ[rs], Throw[$Failed, "pdfimg"]];
    Do[
      k = j + 1;
      While[k <= Length[imgs] && ! iSWPDFAspectOKQ[imgs[[k]], r], k++];
      If[k > Length[imgs], Throw[$Failed, "pdfimg"]];
      j = k;
      If[q === page, AppendTo[out, imgs[[k]]]],
      {r, rs}],
    {q, page}];
  out], "pdfimg"];

SlidePDFImages[src_String, OptionsPattern[]] := Module[{path, imgs, im, page = OptionValue["Page"]},
  path = iSWResolveRefPath[src];
  If[!StringQ[path] || !FileExistsQ[path],
    Return[Failure["NoFile",
      <|"MessageTemplate" -> "cannot resolve `1` to a local file",
        "MessageParameters" -> {src}|>]]];
  If[MemberQ[{"png", "jpg", "jpeg", "gif", "webp", "bmp", "tif", "tiff"},
      ToLowerCase[FileExtension[path]]],
    im = Quiet[Check[Import[path], $Failed]];
    Return[If[ImageQ[im], {im}, {}]]];
  imgs = If[IntegerQ[page] && page >= 1,
    With[{r = iSWPDFPageImages[path, page]},
      If[r === $Failed,
        Return[Failure["PageImages", <|"MessageTemplate" -> "cannot map the embedded images of page `1` in `2`",
          "MessageParameters" -> {page, path}|>]], r]],
    iSWPDFImagesOf[path]];
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

(* ---- \:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af (\:8ad6\:6587\:306e\:548c\:8a33 .nb \:306a\:3069) \:306e\:53d6\:308a\:8fbc\:307f ----
   \:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306e\:30b3\:30fc\:30c9\:306f NBAccess \:306e\:95a2\:6240\:3092\:901a\:308b LLM \:751f\:6210\:30b3\:30fc\:30c9\:3067\:3042\:308a\:3001Import /
   Get \:306f $NBDenyHeads \:306e\:6052\:4e45\:7981\:6b62 head (ForbiddenHead \:306f ClaudeRuntime \:306e fatal
   class \:306a\:306e\:3067\:30bf\:30fc\:30f3\:3054\:3068\:5373\:6b7b\:3059\:308b)\:3002\:7981\:6b62\:3059\:308b\:3060\:3051\:3067\:306f\:30e2\:30c7\:30eb\:306f\:5fc5\:305a Import \:3092\:9078\:3076\:306e\:3067\:3001
   \:300c\:4ee3\:308f\:308a\:306b\:547c\:3079\:308b\:53d7\:3051\:76bf\:300d\:3092\:7528\:610f\:3059\:308b \:2014 PDF \:306b\:5bfe\:3059\:308b SlidePDFImages / SlidePDFFigure
   \:3068\:540c\:3058\:7acb\:5834\:306e .nb \:7248\:3002SlideDeckSlides \:7cfb\:306f\:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad\:5c02\:7528 (SlideShowNavigationBar
   \:304c\:8981\:308b) \:3067\:3001\:8ad6\:6587\:3092\:5909\:63db\:3057\:305f\:3060\:3051\:306e\:7d20\:6750 .nb \:306b\:306f\:4f7f\:3048\:305a\:3001\:3053\:3053\:304c\:7a7a\:767d\:3060\:3063\:305f\:3002

   \:5b9f\:6e2c (PIIS2666386424004363.nb, 3.1MB, \:5168 343 \:30bb\:30eb): \:672c\:6587\:7cfb 219 \:30bb\:30eb\:30fb\:56f3 18\:3002
   \:30bb\:30eb\:304b\:3089 GraphicsBox/RasterBox \:3092\:5916\:3057\:3066\:304b\:3089\:6587\:5b57\:5217\:5316\:3059\:308b\:3068 68k \:5b57\:3002\:5916\:3055\:306a\:3044\:3068
   Raster \:306e\:5727\:7e2e\:30c7\:30fc\:30bf\:6587\:5b57\:5217\:307e\:3067\:62fe\:3063\:3066 2.0M \:5b57\:306b\:306a\:308b\:3002 *)

$iSWSourceTextStyles = {"Title", "Subtitle", "Chapter", "Section", "Subsection",
  "Subsubsection", "Subsubsubsection", "Text", "Item", "ItemNumbered",
  "Subitem", "SubitemNumbered", "Caption", "Abstract", "DisplayFormula",
  "DisplayFormulaNumbered", "EquationNumbered", "Bibliography",
  "Author", "Affiliation"};

(* \:898b\:51fa\:3057\:30b9\:30bf\:30a4\:30eb\:3002\:4e26\:3073\:9806\:304c\:305d\:306e\:307e\:307e\:968e\:5c64\:306e\:6df1\:3055 (\:7bc0\:306e\:5207\:308a\:51fa\:3057\:306b\:4f7f\:3046) *)
$iSWSourceHeadingStyles = {"Title", "Subtitle", "Chapter", "Section",
  "Subsection", "Subsubsection", "Subsubsubsection"};

iSWHeadingLevel[st_] := With[{p = FirstPosition[$iSWSourceHeadingStyles, st, {0}, {1}]},
  If[ListQ[p] && First[p] > 0, First[p], 99]];

(* SourceVault \:306b\:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e\:8ad6\:6587 (sv:// / src- / arxiv:) \:306b\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c
   \:767b\:9332\:3055\:308c\:3066\:3044\:308c\:3070\:305d\:306e\:30d1\:30b9 (SourceVault_papernb.wl \:306e\:767b\:9332\:7c3f)\:3002\:7121\:3051\:308c\:3070 $Failed *)
iSWRegisteredSourceNotebook[src_String] := Module[{p},
  If[Length[DownValues[SourceVault`SourceVaultPaperNotebook]] === 0, Return[$Failed]];
  p = Quiet[Check[SourceVault`SourceVaultPaperNotebook[src], $Failed]];
  If[StringQ[p] && FileExistsQ[p], p, $Failed]];

(* \:7d20\:6750 .nb \:306e\:89e3\:6c7a: \:76f4\:63a5 .nb \:306a\:3089\:305d\:308c\:3001\:53d6\:308a\:8fbc\:307f\:6e08\:307f\:8ad6\:6587\:306a\:3089\:767b\:9332\:3055\:308c\:305f\:548c\:8a33\:30ce\:30fc\:30c8\:3092\:81ea\:52d5\:3067\:4f7f\:3046 *)
(* KG \:306e Sources (Key \:2192 \:548c\:8a33\:30ce\:30fc\:30c8 / \:5143\:306e\:6587\:732e locator): \:751f\:6210\:6642\:306b Block \:3067\:675f\:7e1b\:3057\:3001\:30c7\:30c3\:30ad\:304c\:958b\:3044\:3066\:3044\:306a\:3044 (headless\:3001SlideGraphBuildDeck) \:3068\:304d\:3082\:8cc7\:7523\:306e key \:3092\:89e3\:3051\:308b *)
$iSWKGSources = {};
iSWKGSourceOf[key_String] := SelectFirst[Replace[$iSWKGSources, Except[_List] -> {}],
  AssociationQ[#] && Lookup[#, "Key", None] === key &, None];
iSWSourceNBPath[src_String] := Module[{p = iSWResolveRefPath[src], reg, ks},
  If[StringQ[p] && FileExistsQ[p] && ToLowerCase[FileExtension[p]] === "nb", Return[p]];
  reg = iSWRegisteredSourceNotebook[src];
  If[reg =!= $Failed, Return[reg]];
  ks = iSWKGSourceOf[src];
  If[AssociationQ[ks] && StringQ[Lookup[ks, "Locator", None]] && FileExistsQ[ks["Locator"]] &&
      ToLowerCase[FileExtension[ks["Locator"]]] === "nb", Return[ks["Locator"]]];
  (* References \:306e key \:306a\:3089 locator \:3067\:3082\:5f15\:304f *)
  With[{nb = iSWResolveTargetNb[]},
    If[Head[nb] === NotebookObject,
      With[{hit = SelectFirst[Quiet[Check[iSWReferencesList[nb], {}]], #["Key"] === src &, None]},
        If[hit =!= None && StringQ[Lookup[hit, "Notebook", None]] && FileExistsQ[hit["Notebook"]],
          Return[hit["Notebook"]]]]]];
  $Failed];

(* \:6587\:732e 1 \:4ef6\:304c\:300c\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3068\:3057\:3066\:8aad\:3081\:308b\:300d\:304b: .nb \:306e locator \:304b\:3001\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:767b\:9332\:6e08\:307f *)
iSWRefNotebookQ[r_Association] := r["Kind"] === "Notebook" || StringQ[Lookup[r, "Notebook", None]];

iSWSourceNoNB[src_] := Failure["NoSourceNotebook",
  <|"MessageTemplate" -> "cannot resolve `1` to a source notebook (.nb)",
    "MessageParameters" -> {src}|>];

iSWSourceCellStyle[Cell[_, s_String, ___]] := s;
iSWSourceCellStyle[_] := "";

(* ---- \:6570\:5f0f\:30dc\:30c3\:30af\:30b9\:3092\:8aad\:3081\:308b\:7dda\:5f62\:30c6\:30ad\:30b9\:30c8\:306b\:3059\:308b ----
   iCellText \:306f\:300c\:6587\:5b57\:5217\:306e\:8449\:3092\:5168\:90e8\:3064\:306a\:3050\:300d\:3060\:3051\:306a\:306e\:3067\:3001FractionBox["D", RowBox[{"R","T"}]]
   \:304c "DRT" \:306b\:3001du/dx \:304c "dudx" \:306b\:306a\:308b\:3002\:5b9f\:5bb3: \:548c\:8a33\:30ce\:30fc\:30c8\:306e Equation 1 \:304c
   "J=DRTdudx" \:3068\:8aad\:3081\:3001\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c\:305d\:308c\:3092\:5f0f\:3068\:89e3\:305b\:305a\:306b\:5225\:306e\:5f0f
   (Nernst-Planck) \:3092\:5275\:4f5c\:3057\:3066\:30b9\:30e9\:30a4\:30c9\:306b\:8f09\:305b\:305f\:3002\:69cb\:9020\:3092\:4fdd\:3063\:3066\:7dda\:5f62\:5316\:3059\:308b\:3002 *)
iSWBoxText[b_String] := b;
iSWBoxText[l_List] := StringJoin[iSWBoxText /@ l];
iSWBoxText[RowBox[l_List]] := StringJoin[iSWBoxText /@ l];
iSWBoxText[FractionBox[a_, b_]] :=
  "(" <> iSWBoxText[a] <> ")/(" <> iSWBoxText[b] <> ")";
iSWBoxText[SqrtBox[a_]] := "sqrt(" <> iSWBoxText[a] <> ")";
iSWBoxText[RadicalBox[a_, n_, ___]] :=
  "(" <> iSWBoxText[a] <> ")^(1/" <> iSWBoxText[n] <> ")";
iSWBoxText[SubscriptBox[a_, b_, ___]] := iSWBoxText[a] <> "_" <> iSWBoxText[b];
iSWBoxText[SuperscriptBox[a_, b_, ___]] := iSWBoxText[a] <> "^" <> iSWBoxText[b];
iSWBoxText[SubsuperscriptBox[a_, b_, c_, ___]] :=
  iSWBoxText[a] <> "_" <> iSWBoxText[b] <> "^" <> iSWBoxText[c];
iSWBoxText[OverscriptBox[a_, b_, ___]] :=
  iSWBoxText[a] <> "^(" <> iSWBoxText[b] <> ")";
iSWBoxText[UnderscriptBox[a_, b_, ___]] :=
  iSWBoxText[a] <> "_(" <> iSWBoxText[b] <> ")";
iSWBoxText[UnderoverscriptBox[a_, b_, c_, ___]] :=
  iSWBoxText[a] <> "_(" <> iSWBoxText[b] <> ")^(" <> iSWBoxText[c] <> ")";
iSWBoxText[GridBox[rows_List, ___]] :=
  StringRiffle[Map[StringRiffle[iSWBoxText /@ #, " | "] &, rows], " ; "];
iSWBoxText[(FormBox | StyleBox | TagBox | InterpretationBox | AdjustmentBox |
    PaneBox | ItemBox | TemplateBox | ButtonBox | TooltipBox)[a_, ___]] :=
  iSWBoxText[a];
iSWBoxText[BoxData[b_]] := iSWBoxText[b];
iSWBoxText[TextData[t_]] := iSWBoxText[t];
iSWBoxText[Cell[c_, ___]] := iSWBoxText[c];
iSWBoxText[_] := "";

(* ---- \:5f15\:7528\:756a\:53f7 (v1.29) ----
   \:548c\:8a33\:30ce\:30fc\:30c8\:306e\:5f15\:7528\:756a\:53f7\:306f\:571f\:53f0\:306e\:7a7a\:306a\:4e0a\:4ed8\:304d (SuperscriptBox["", "38"] / RowBox[{"23", "-", "25"}]) \:3067\:3001\:5f0f\:3068\:3057\:3066\:8aad\:3080\:3068
   Null^38 \:2192 $\text{Null}^{38}$ \:306b\:306a\:3063\:3066\:3044\:305f (\:8a08\:7b97\:3068\:81ea\:713633: \:672c\:6587 16 \:6bb5\:843d\:3001\:300c,\:300d\:533a\:5207\:308a\:306f\:5f0f\:306b\:306a\:3089\:305a ^23,26)\:3002
   \:5f0f\:306b\:305b\:305a [38] \:306e\:5f62\:306e\:6587\:5b57\:306b\:3059\:308b\:3002\:571f\:53f0\:304c\:7a7a\:767d\:3067\:4e0a\:4ed8\:304d\:304c \:2218 \:306e\:3082\:306e\:306f\:5ea6 (\:00b0) *)
iSWCitationText[s_String] := Module[{t = StringDelete[s, WhitespaceCharacter]},
  t = StringReplace[t, "\[Dash]" | "\[LongDash]" | "\:2012" | "\[Minus]" -> "-"];
  Which[
    StringMatchQ[t, RegularExpression["\\d{1,4}([,\\-]\\d{1,4})*"]], "[" <> t <> "]",
    MemberQ[{"\[SmallCircle]", "\[Degree]", "\[EmptySmallCircle]", "\:02da"}, t], "\[Degree]",
    True, None]];
iSWCitationText[_] := None;
iSWBlankBaseSupText[b_] := Replace[b //. (FormBox | StyleBox | TagBox)[x_, ___] :> x,
  {SuperscriptBox[a_String, s_, ___] /; StringTrim[a] === "" :> iSWBoxText[s], _ -> None}];
iSWBoxText[SuperscriptBox[a_String, b_, ___]] /; StringTrim[a] === "" && StringQ[iSWCitationText[iSWBoxText[b]]] :=
  iSWCitationText[iSWBoxText[b]];

(* ---- \:884c\:5185\:6570\:5f0f (v1.25) ----
   \:548c\:8a33\:30ce\:30fc\:30c8\:306e\:672c\:6587\:30bb\:30eb\:306b\:306f\:6570\:5f0f\:304c boxes \:3067\:7d44\:307e\:308c\:3066\:3044\:308b\:304c\:3001KG \:306e\:672c\:6587 (Text) \:306f\:7dda\:5f62\:6587\:5b57\:5217 (q_i) \:3060\:3063\:305f\:3002
   seed \:3067\:884c\:5185\:6570\:5f0f\:3092 $tex$ (boxes \:2192 TeX) \:306b\:3057\:3001tex \:2192 boxes \:306e\:8f9e\:66f8\:3092\:30ce\:30fc\:30c9\:306b\:6b8b\:3059\:3002\:30b9\:30e9\:30a4\:30c9\:306e\:7b87\:6761\:66f8\:304d\:306f
   $tex$ \:3092\:8f9e\:66f8\:3067\:5143\:306e boxes \:306b\:623b\:3057 (\:5b8c\:5168\:4e00\:81f4)\:3001\:7121\:3051\:308c\:3070 TeX \:8aad\:307f\:8fbc\:307f\:3001\:305d\:308c\:3082\:99c4\:76ee\:306a\:3089\:6587\:5b57\:5217\:306e\:307e\:307e\:3002 *)
$iSWInlineFormulaDict = <||>;
iSWBoxTeX[b_] := Module[{e, tex},
  e = Quiet @ Check[ToExpression[b, TraditionalForm, HoldForm], $Failed];
  If[e === $Failed, Return[None]];
  tex = Quiet @ Check[ToString[e, TeXForm], $Failed];
  If[! StringQ[tex] || StringTrim[tex] === "" || StringContainsQ[tex, "\n"] || StringContainsQ[tex, "\\text{Null}"],
    None, StringTrim[tex]]];
(* \:672c\:6587\:30bb\:30eb\:5185\:306e\:884c\:5185\:6570\:5f0f\:30bb\:30eb: TeX \:306b\:3067\:304d\:308c\:3070 $tex$ \:3068\:8f9e\:66f8\:767b\:9332\:3001\:3067\:304d\:306a\:3051\:308c\:3070\:7dda\:5f62\:5316 *)
iSWBoxText[Cell[BoxData[b_], ___]] := With[{cite = iSWCitationText[iSWBlankBaseSupText[b]]},
  If[StringQ[cite], cite,
    With[{tex = iSWBoxTeX[b]},
      If[StringQ[tex] && ! StringContainsQ[tex, "$"],
        $iSWInlineFormulaDict[tex] = ToString[b, InputForm]; "$" <> tex <> "$",
        iSWBoxText[b]]]]];

(* v1.29 \:3088\:308a\:524d\:306e KG\:69cb\:7bc9\:3067\:5165\:3063\:305f\:5f15\:7528\:756a\:53f7 ($\text{Null}^{38}$\:3001\:5f0f\:306b\:306a\:3089\:306a\:304b\:3063\:305f ^23,26) \:3092 [38] \:306e\:5f62\:306b\:76f4\:3059\:3002
   \:63a8\:6572\:30fb\:8abf\:6574\:306e\:958b\:59cb\:6642\:306b\:4e00\:5ea6\:3060\:3051\:66f8\:304d\:76f4\:3057\:3066\:4fdd\:5b58\:3059\:308b (\:524d\:306e\:7248\:306f KG \:306e\:5c65\:6b74\:306b\:6b8b\:308b) *)
$iSWCiteRepairKeys = {"Text", "Summary", "Label", "Lead", "Points", "Details", "Talk"};
iSWCiteRepairSup[sup_String] := With[{core = StringTrim[StringTrim[sup], "{" | "}"]},
  Which[core === "\\circ", "\[Degree]", StringQ[iSWCitationText[core]], iSWCitationText[core], True, "^" <> core]];
iSWCiteRepairString[s_String] := If[! StringContainsQ[s, "^"], s,
  StringReplace[
    StringReplace[s, RegularExpression["\\$\\s*\\\\text\\{Null\\}\\^(\\{[^{}$]*\\}|\\w)\\s*\\$"] :> iSWCiteRepairSup["$1"]],
    RegularExpression["(?<![!-~])\\^(\\d{1,4}(?:\\s*,\\s*\\d{1,4})+)"] :> "[" <> StringDelete["$1", WhitespaceCharacter] <> "]"]];
iSWCiteRepairString[x_] := x;
iSWCiteRepairNode[n_Association] := Module[{m = n},
  Do[If[KeyExistsQ[m, k], m[k] = Replace[m[k], s_String :> iSWCiteRepairString[s], {0, Infinity}]], {k, $iSWCiteRepairKeys}];
  If[ListQ[Lookup[m, "Formulas", None]],
    m["Formulas"] = Select[m["Formulas"],
      ! (AssociationQ[#] && StringContainsQ[ToString[Lookup[#, "Tex", ""]], "\\text{Null}"]) &]];
  m];
iSWKGCiteRepair[gid_String, kg_Association] := Module[{nodes = Map[iSWCiteRepairNode, kg["Nodes"]], fixed},
  If[nodes === kg["Nodes"], Return[kg]];
  fixed = Append[kg, "Nodes" -> nodes];
  If[StringQ[Quiet @ SourceVault`SourceVaultKGSave[fixed]], fixed, kg]];
iSWKGCiteRepair[_, kg_] := kg;

(* $...$ \:3092\:542b\:3080\:6587\:5b57\:5217 \:2192 TextData (\:884c\:5185\:6570\:5f0f\:306f\:5143 boxes / TeX \:8aad\:307f\:8fbc\:307f / \:7d20\:306e\:6587\:5b57\:5217) *)
$iSWFormulaBoxes = <||>;
(* TeX \:8aad\:307f\:8fbc\:307f\:304c\:6271\:3048\:308b\:30de\:30af\:30ed\:3060\:3051\:901a\:3059 (\:672a\:77e5\:306e\:30de\:30af\:30ed\:306f\:9ed9\:3063\:3066\:58ca\:308c\:305f\:6587\:5b57\:5217\:306b\:306a\:308b: 
osuchmacro{x} \:2192 osuchmacrox) *)
$iSWTeXMacros = {"alpha", "beta", "gamma", "delta", "epsilon", "varepsilon", "zeta", "eta", "theta", "vartheta", "iota", "kappa",
  "lambda", "mu", "nu", "xi", "pi", "rho", "sigma", "tau", "upsilon", "phi", "varphi", "chi", "psi", "omega",
  "Gamma", "Delta", "Theta", "Lambda", "Xi", "Pi", "Sigma", "Upsilon", "Phi", "Psi", "Omega",
  "mathcal", "mathrm", "mathbf", "mathbb", "mathit", "mathsf", "text", "textrm", "textbf", "operatorname", "mathop",
  "hat", "bar", "tilde", "vec", "dot", "ddot", "overline", "underline", "widehat", "widetilde",
  "frac", "sqrt", "sum", "prod", "int", "lim", "log", "ln", "exp", "min", "max", "arg", "argmin", "argmax", "sin", "cos", "tan",
  "in", "notin", "subset", "subseteq", "supset", "supseteq", "cup", "cap", "le", "leq", "ge", "geq", "ne", "neq", "approx", "sim",
  "simeq", "equiv", "propto", "to", "rightarrow", "leftarrow", "Rightarrow", "Leftarrow", "leftrightarrow", "mapsto",
  "cdot", "cdots", "ldots", "dots", "vdots", "times", "div", "pm", "mp", "infty", "partial", "nabla", "left", "right",
  "langle", "rangle", "mid", "emptyset", "varnothing", "top", "bot", "forall", "exists", "neg", "land", "lor", "oplus", "otimes",
  "prime", "circ", "star", "ast", "quad", "qquad", "displaystyle", "textstyle", "lbrace", "rbrace", "lvert", "rvert", "lVert", "rVert"};
iSWTeXMacrosOKQ[tex_String] := AllTrue[StringCases[tex, "\\" ~~ m : LetterCharacter .. :> m], MemberQ[$iSWTeXMacros, #] &];
iSWInlineFormulaBoxes[tex_String] := Module[{src = Lookup[$iSWFormulaBoxes, tex, None], b, e},
  b = If[StringQ[src], Quiet @ Check[ToExpression[src], $Failed], $Failed];
  If[b =!= $Failed && b =!= Null, Return[b]];
  If[! iSWTeXMacrosOKQ[tex], Return[None]];
  e = Quiet @ Check[ToExpression[tex, TeXForm, HoldForm], $Failed];
  If[e === $Failed, None,
    Quiet @ Check[ToBoxes[e, TraditionalForm] /. TagBox[bx_, HoldForm, ___] :> bx, None]]];
(* **\:5f37\:8abf** \:306f\:592a\:5b57 (StyleBox) \:306b\:3002\:6570\:5f0f\:3068\:7d44\:307f\:5408\:308f\:305b\:3066\:3082\:53ef *)
iSWInlineBold[t_String] := If[! StringContainsQ[t, "**"], {t},
  Select[StringSplit[t, "**" ~~ Shortest[b : Except["*"] ..] ~~ "**" :> StyleBox[b, FontWeight -> Bold], All], # =!= "" &]];
iSWInlineTextData[text_String] := Module[{parts, out},
  If[! StringContainsQ[text, "$"] && ! StringContainsQ[text, "**"], Return[text]];
  parts = StringSplit[text, "$" ~~ Shortest[tex : Except["$"] ..] ~~ "$" :> {"tex", tex}, All];
  out = Flatten[Map[Function[p, If[ListQ[p],
      With[{bx = iSWInlineFormulaBoxes[StringTrim[p[[2]]]]},
        If[bx === None, StringTrim[p[[2]]], Cell[BoxData[If[MatchQ[bx, _FormBox], bx, FormBox[bx, TraditionalForm]]]]]],
      iSWInlineBold[p]]], Select[parts, # =!= "" &]]];
  If[AllTrue[out, StringQ], StringJoin[out], TextData[out]]];

(* ---- \:8aad\:307f\:4e0a\:3052\:539f\:7a3f\:306e\:6570\:5f0f: \:30b9\:30e9\:30a4\:30c9\:306b\:5f0f\:304c\:51fa\:3066\:3044\:308b\:306e\:3060\:304b\:3089\:3001\:8907\:96d1\:306a\:5f0f\:306f\:8aad\:307f\:4e0a\:3052\:305a
   \:300c\:3053\:306e\:5f0f\:300d\:3068\:6307\:3059\:3002\:8a18\:53f7 1 \:3064\:3084\:77ed\:3044\:548c\:5dee\:3060\:3051\:58f0\:306b\:51fa\:3059 ($u_e$ \:2192 u e)\:3002
   TeX \:306e\:307e\:307e\:8aad\:3080\:3068 "frac" \:3068\:767a\:58f0\:3055\:308c\:3066\:4f55\:3092\:8a00\:3063\:3066\:3044\:308b\:304b\:5206\:304b\:3089\:306a\:3044 ---- *)
$iSWSpeakGreek = <|"alpha" -> "\:30a2\:30eb\:30d5\:30a1", "beta" -> "\:30d9\:30fc\:30bf", "gamma" -> "\:30ac\:30f3\:30de", "delta" -> "\:30c7\:30eb\:30bf",
  "epsilon" -> "\:30a4\:30d7\:30b7\:30ed\:30f3", "varepsilon" -> "\:30a4\:30d7\:30b7\:30ed\:30f3", "zeta" -> "\:30bc\:30fc\:30bf", "eta" -> "\:30a4\:30fc\:30bf",
  "theta" -> "\:30b7\:30fc\:30bf", "iota" -> "\:30a4\:30aa\:30bf", "kappa" -> "\:30ab\:30c3\:30d1", "lambda" -> "\:30e9\:30e0\:30c0", "mu" -> "\:30df\:30e5\:30fc",
  "nu" -> "\:30cb\:30e5\:30fc", "xi" -> "\:30b0\:30b6\:30a4", "pi" -> "\:30d1\:30a4", "rho" -> "\:30ed\:30fc", "sigma" -> "\:30b7\:30b0\:30de", "tau" -> "\:30bf\:30a6",
  "upsilon" -> "\:30a6\:30d7\:30b7\:30ed\:30f3", "phi" -> "\:30d5\:30a1\:30a4", "varphi" -> "\:30d5\:30a1\:30a4", "chi" -> "\:30ab\:30a4", "psi" -> "\:30d7\:30b5\:30a4",
  "omega" -> "\:30aa\:30e1\:30ac", "Gamma" -> "\:30ac\:30f3\:30de", "Delta" -> "\:30c7\:30eb\:30bf", "Theta" -> "\:30b7\:30fc\:30bf", "Lambda" -> "\:30e9\:30e0\:30c0",
  "Xi" -> "\:30b0\:30b6\:30a4", "Pi" -> "\:30d1\:30a4", "Sigma" -> "\:30b7\:30b0\:30de", "Phi" -> "\:30d5\:30a1\:30a4", "Psi" -> "\:30d7\:30b5\:30a4", "Omega" -> "\:30aa\:30e1\:30ac"|>;
(* \:3053\:308c\:3089\:304c\:5165\:3063\:3066\:3044\:305f\:3089\:300c\:3053\:306e\:5f0f\:300d\:3068\:6307\:3059 (\:58f0\:3067\:8ffd\:3048\:306a\:3044) *)
$iSWTeXComplexMarks = {"\\frac", "\\dfrac", "\\tfrac", "\\sqrt", "\\sum", "\\int", "\\prod", "\\lim", "\\partial",
  "\\nabla", "\\begin", "\\hat", "\\vec", "\\bar", "\\over", "^", "=", "<", ">", "\\le", "\\ge", "\\neq",
  "\\approx", "\\simeq", "\\to", "\\rightarrow", "\\propto", "\\pm", "\\mp"};
iSWTeXClean[s_String] := StringTrim[StringReplace[s,
  {"\\left" -> "", "\\right" -> "", "\\!" -> "", "\\," -> " ", "\\;" -> " ", "\\quad" -> " ", "\\qquad" -> " ",
   "\\displaystyle" -> "", "\\limits" -> "", "\\mathrm" -> "", "\\mathbf" -> "", "\\mathit" -> "", "\\mathcal" -> "",
   "\\mathbb" -> "", "\\boldsymbol" -> "", "\\operatorname" -> "", "\\text" -> "", "\\rm" -> ""}]];
iSWTeXComplexQ[s_String] := StringLength[s] > 24 || AnyTrue[$iSWTeXComplexMarks, StringContainsQ[s, #] &];
iSWTeXSpeak[texIn_String, ja_] := Module[{s = iSWTeXClean[texIn]},
  If[s === "", Return[""]];
  If[iSWTeXComplexQ[s], Return[If[TrueQ[ja], "\:3053\:306e\:5f0f", "this equation"]]];
  s = StringReplace[s, "\\" ~~ c : LetterCharacter .. :>
    " " <> If[TrueQ[ja], Lookup[$iSWSpeakGreek, c, c], c] <> " "];
  s = StringReplace[s, {"_" -> " ", "{" -> " ", "}" -> " ", "\\" -> " "}];
  s = StringReplace[s, {"+" -> If[TrueQ[ja], " \:30d7\:30e9\:30b9 ", " plus "], "-" -> If[TrueQ[ja], " \:30de\:30a4\:30ca\:30b9 ", " minus "],
    "\:00d7" -> If[TrueQ[ja], " \:304b\:3051\:308b ", " times "], "*" -> If[TrueQ[ja], " \:304b\:3051\:308b ", " times "]}];
  StringTrim[StringReplace[s, Whitespace -> " "]]];
iSWJaTextQ[t_String] := AnyTrue[ToCharacterCode[t], # >= 12288 &];
(* \:539f\:7a3f\:3092\:58f0\:306b\:51fa\:305b\:308b\:5f62\:3078: $\:2026$ \:306e\:6570\:5f0f\:3092\:8a00\:8449\:306b\:3057\:3001**\:5f37\:8abf** \:306e\:5370\:3092\:5916\:3059\:3002
   \:3059\:3067\:306b\:5e73\:6587\:306a\:3089\:4f55\:3082\:3057\:306a\:3044 (\:5e8f\:3067\:306a\:3044\:3053\:3068\:306f\:4f55\:5ea6\:9069\:7528\:3057\:3066\:3082\:540c\:3058) *)
iSWTalkSpeakText[textIn_String] := Module[{s = textIn, ja},
  (* \:5f15\:7528\:756a\:53f7 [38] / [23-25] \:306f\:8aad\:307e\:306a\:3044 (\:82f1\:6570\:5b57\:306e\:76f4\:5f8c\:306e a[1] \:306e\:3088\:3046\:306a\:6dfb\:5b57\:306f\:6b8b\:3059) *)
  s = StringReplace[s, RegularExpression["(?<![A-Za-z0-9_])\\s*\\[\\d{1,4}(?:\\s*[,\\-\\x{2013}]\\s*\\d{1,4})*\\]"] -> ""];
  If[s =!= textIn, s = StringReplace[s, RegularExpression["(?<=[^\\x00-\\x7F]) (?=[^\\x00-\\x7F])"] -> ""]];
  If[! StringContainsQ[s, "$"] && ! StringContainsQ[s, "**"], Return[s]];
  ja = iSWJaTextQ[s];
  s = StringReplace[s, "**" -> ""];
  (* $\:2026$ \:306e\:4e2d\:306b\:65e5\:672c\:8a9e\:304c\:3042\:308c\:3070\:6570\:5f0f\:3067\:306f\:7121\:3044 (\:300c$100 \:3068 $200\:300d\:306e\:3088\:3046\:306a\:8ab2\:91d1\:8868\:8a18) \:306e\:3067\:89e6\:3089\:306a\:3044 *)
  s = StringReplace[s, whole : ("$" ~~ b : Shortest[Except["$"] ..] ~~ "$") :>
    If[iSWJaTextQ[b], whole, iSWTeXSpeak[b, ja]]];
  s = StringReplace[s, RegularExpression[" {2,}"] -> " "];
  (* \:65e5\:672c\:8a9e\:540c\:58eb\:306e\:9593\:306b\:6b8b\:3063\:305f\:7a7a\:767d\:306f\:843d\:3068\:3059 *)
  s = StringReplace[s, RegularExpression["(?<=[^\\x00-\\x7F]) (?=[^\\x00-\\x7F])"] -> ""];
  StringTrim[s]];
iSWTalkSpeakText[x_] := x;

(* \:753b\:50cf\:30dc\:30c3\:30af\:30b9\:3092\:5916\:3057\:3066\:304b\:3089\:6587\:5b57\:5217\:5316\:3059\:308b (Raster \:306e\:5727\:7e2e\:30c7\:30fc\:30bf\:3092\:672c\:6587\:306b\:6df7\:305c\:306a\:3044) *)
iSWSourceCellText[c_] :=
  StringTrim[iSWBoxText[
    DeleteCases[c, _GraphicsBox | _Graphics3DBox | _RasterBox, Infinity]]];

(* \:8ad6\:6587 PDF \:304b\:3089\:306e\:5909\:63db\:30ce\:30fc\:30c8\:306f\:3001\:5143\:306e LaTeX \:3092
   TaggingRules -> {"documentation" -> {"paperLatex" -> .., "paperLabel" -> ..}}
   \:306b\:6b8b\:3057\:3066\:3044\:308b\:3002\:3042\:308c\:3070\:305d\:308c\:304c\:6700\:3082\:66d6\:6627\:3055\:306e\:306a\:3044\:8868\:73fe\:306a\:306e\:3067\:672c\:6587\:306b\:306f\:3053\:3061\:3089\:3092\:51fa\:3059\:3002 *)
iSWCellPaperLatex[c_Cell] :=
  Module[{tr, doc, tex, lab},
    tr = FirstCase[List @@ c, HoldPattern[TaggingRules -> x_] :> x, None];
    doc = If[ListQ[tr] || AssociationQ[tr], Lookup[tr, "documentation", None], None];
    If[! (ListQ[doc] || AssociationQ[doc]), Return[Missing["NoLatex"]]];
    tex = Lookup[doc, "paperLatex", Missing[]];
    lab = Lookup[doc, "paperLabel", ""];
    If[! StringQ[tex], Return[Missing["NoLatex"]]];
    StringTrim[tex <> If[StringQ[lab] && lab =!= "", "   " <> lab, ""]]];
iSWCellPaperLatex[_] := Missing["NoLatex"];

(* \:72ec\:7acb\:3057\:305f\:6570\:5f0f\:30bb\:30eb (\:5f15\:7528\:3067\:304d\:308b\:5358\:4f4d) *)
$iSWSourceFormulaStyles = {"DisplayFormula", "DisplayFormulaNumbered",
  "EquationNumbered", "Equation"};

(* {\:30d1\:30b9, \:66f4\:65b0\:65e5\:6642} \:3067 1 \:4ef6\:3060\:3051\:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b\:3002\:5c55\:958b\:306f\:30b9\:30e9\:30a4\:30c9 1 \:679a\:3054\:3068\:306b\:8d70\:308b\:306e\:3067\:3001
   \:540c\:3058\:7d20\:6750\:3092\:6bce\:56de\:8aad\:307f\:76f4\:3055\:306a\:3044 *)
$iSWSourceNBCache = None;

iSWSourceNBParts[path_String] :=
  Module[{stamp, nb, flat, items = {}, figs = {}, eqs = {}, k = 0, q = 0},
    stamp = {path, Quiet@Check[FileDate[path, "Modification"], None]};
    If[ListQ[$iSWSourceNBCache] && $iSWSourceNBCache[[1]] === stamp,
      Return[$iSWSourceNBCache[[2]]]];
    nb = iGetNotebook[path];
    If[Head[nb] =!= Notebook, Return[$Failed]];
    flat = iFlattenCells[First[nb]];
    Do[
      Module[{c = flat[[i]], st, gb, t, mine = {}, eq = {}, tex, fdict},
        st = iSWSourceCellStyle[c];
        gb = Cases[c, _GraphicsBox | _Graphics3DBox, Infinity];
        Do[k++; AppendTo[figs, <|"N" -> k, "Cell" -> i, "Style" -> st, "Box" -> g|>];
           AppendTo[mine, k], {g, gb}];
        $iSWInlineFormulaDict = <||>;
        t = If[MemberQ[$iSWSourceTextStyles, st], iSWSourceCellText[c], ""];
        fdict = $iSWInlineFormulaDict;
        (* \:6570\:5f0f\:30bb\:30eb\:306f\:539f\:30bb\:30eb (boxes) \:3054\:3068\:4fdd\:6301\:3059\:308b: \:30b9\:30e9\:30a4\:30c9\:3078\:306f\:4f5c\:308a\:76f4\:3055\:305a
           \:305d\:306e\:307e\:307e\:5f15\:7528\:3057\:305f\:3044 (SlideNotebookFormula) *)
        If[MemberQ[$iSWSourceFormulaStyles, st] && gb === {},
          q++; AppendTo[eq, q];
          tex = iSWCellPaperLatex[c];
          AppendTo[eqs, <|"N" -> q, "Cell" -> i, "Style" -> st,
            "Latex" -> tex, "Text" -> t, "Source" -> c|>];
          If[StringQ[tex], t = tex]];
        If[t =!= "" || mine =!= {} || eq =!= {},
          AppendTo[items, <|"Cell" -> i, "Style" -> st, "Text" -> t,
            "Figures" -> mine, "Formulas" -> eq,
            "InlineFormulas" -> KeyValueMap[<|"Tex" -> #1, "Boxes" -> #2|> &, fdict]|>]]],
      {i, Length[flat]}];
    $iSWSourceNBCache = {stamp,
      <|"Path" -> path, "Items" -> items, "Figures" -> figs, "Formulas" -> eqs|>};
    $iSWSourceNBCache[[2]]];

iSWHeadingPositions[items_List] := Flatten[Position[items,
  x_ /; MemberQ[$iSWSourceHeadingStyles, Lookup[x, "Style", ""]],
  {1}, Heads -> False]];

(* \:898b\:51fa\:3057\:4f4d\:7f6e p \:304b\:3089\:3001\:540c\:3058\:304b\:4e0a\:4f4d\:306e\:898b\:51fa\:3057\:304c\:73fe\:308c\:308b\:76f4\:524d\:307e\:3067\:3092 1 \:7bc0\:3068\:3059\:308b *)
iSWSectionSlice[items_List, p_Integer] := Module[{lv, nxt},
  lv = iSWHeadingLevel[items[[p, "Style"]]];
  nxt = SelectFirst[Select[iSWHeadingPositions[items], # > p &],
    iSWHeadingLevel[items[[#, "Style"]]] <= lv &, Length[items] + 1];
  items[[p ;; nxt - 1]]];

iSWSourceSection[items_List, All] := items;
iSWSourceSection[items_List, n_Integer] := With[{idx = iSWHeadingPositions[items]},
  If[n < 1 || n > Length[idx], $Failed, iSWSectionSlice[items, idx[[n]]]]];
iSWSourceSection[items_List, s_String] := Module[{hit},
  hit = SelectFirst[iSWHeadingPositions[items],
    StringContainsQ[Lookup[items[[#]], "Text", ""], s, IgnoreCase -> True] &, None];
  If[hit === None, $Failed, iSWSectionSlice[items, hit]]];
iSWSourceSection[_, _] := $Failed;

SlideNotebookOutline[src_String] := Module[{path, parts, items, idx},
  path = iSWSourceNBPath[src];
  If[path === $Failed, Return[iSWSourceNoNB[src]]];
  parts = iSWSourceNBParts[path];
  If[! AssociationQ[parts], Return[iSWSourceNoNB[src]]];
  items = parts["Items"];
  idx = iSWHeadingPositions[items];
  MapIndexed[Function[{p, j},
    With[{seg = iSWSectionSlice[items, p]},
      <|"N" -> First[j], "Style" -> items[[p, "Style"]],
        "Title" -> items[[p, "Text"]],
        "Chars" -> Total[StringLength[Lookup[#, "Text", ""]] & /@ seg],
        "Figures" -> Flatten[Lookup[#, "Figures", {}] & /@ seg],
        "Formulas" -> Flatten[Lookup[#, "Formulas", {}] & /@ seg]|>]], idx]];

Options[SlideNotebookText] = {"MaxCharacters" -> 40000, "Styles" -> Automatic};

iSWSourceText[src_String, section_, opts_List] :=
  Module[{path, parts, items, styles, maxc, sel, lines, txt, total},
    path = iSWSourceNBPath[src];
    If[path === $Failed, Return[iSWSourceNoNB[src]]];
    parts = iSWSourceNBParts[path];
    If[! AssociationQ[parts], Return[iSWSourceNoNB[src]]];
    items = parts["Items"];
    maxc = OptionValue[SlideNotebookText, opts, "MaxCharacters"];
    styles = OptionValue[SlideNotebookText, opts, "Styles"];
    If[styles === Automatic, styles = $iSWSourceTextStyles];
    sel = iSWSourceSection[items, section];
    If[sel === $Failed,
      Return[Failure["NoSection",
        <|"MessageTemplate" -> "no heading matching `1` in `2`",
          "MessageParameters" -> {section, path}|>]]];
    lines = Flatten[Map[Function[it,
      Join[
        Map[Function[n, "[FIG" <> ToString[n] <> "]"], Lookup[it, "Figures", {}]],
        If[Lookup[it, "Text", ""] =!= "" && MemberQ[styles, Lookup[it, "Style", ""]],
          {With[{eq = Lookup[it, "Formulas", {}]},
              If[eq === {}, "",
                "[EQ" <> StringRiffle[ToString /@ eq, ","] <> "] "]] <>
            "[" <> Lookup[it, "Style", ""] <> "] " <> it["Text"]}, {}]]], sel]];
    txt = StringRiffle[lines, "\n"];
    total = StringLength[txt];
    If[IntegerQ[maxc] && maxc > 0 && total > maxc,
      txt = StringTake[txt, maxc] <> "\n[... " <> ToString[total - maxc] <>
        " characters omitted. SlideNotebookOutline[src] \:3067\:7bc0\:3092\:9078\:3073 " <>
        "SlideNotebookText[src, \:898b\:51fa\:3057] \:3067\:8aad\:3080]"];
    txt];

SlideNotebookText[src_String, opts : OptionsPattern[]] :=
  iSWSourceText[src, All, Flatten[{opts}]];
SlideNotebookText[src_String, section : (_String | _Integer), opts : OptionsPattern[]] :=
  iSWSourceText[src, section, Flatten[{opts}]];

(* \:56f3\:30dc\:30c3\:30af\:30b9 -> Image\:3002Raster \:7531\:6765\:306f\:305d\:306e\:307e\:307e Image \:304c\:53d6\:308c\:308b(\:539f\:56f3\:306e\:753b\:7d20\:3092\:4fdd\:3064)\:306e\:3067
   \:5148\:306b\:8a66\:3057\:3001\:30d9\:30af\:30bf\:56f3\:3060\:3051 Rasterize \:3059\:308b\:3002
   Rasterize \:306f **\:30d5\:30ed\:30f3\:30c8\:30a8\:30f3\:30c9\:3092\:8981\:6c42\:3059\:308b**\:306e\:3067\:3001SlideDeckImages \:3068\:540c\:3058\:304f
   UsingFrontEnd \:3067\:5305\:307f\:3001\:3055\:3089\:306b TimeConstrained \:3067\:4e0a\:9650\:3092\:5207\:308b\:3002\:88f8\:3067\:547c\:3076\:3068\:3001
   FE \:304c\:3053\:306e\:8a55\:4fa1\:306e\:5b8c\:4e86\:3092\:5f85\:3063\:3066\:3044\:308b\:72b6\:6cc1 (\:5c55\:958b\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306e\:30bb\:30eb\:8a55\:4fa1\:4e2d\:306a\:3069) \:3067
   \:76f8\:4e92\:5f85\:3061\:306b\:306a\:308a\:3001\:30ab\:30fc\:30cd\:30eb\:3082 FE \:3082 CPU 0% \:306e\:307e\:307e\:56fa\:307e\:308b\:3002 *)
iSWBoxToImage[g_, res_] := Module[{e, r},
  e = Quiet@Check[ToExpression[g, StandardForm], $Failed];
  If[ImageQ[e], Return[e]];
  r = Quiet@Check[
    TimeConstrained[
      UsingFrontEnd[Rasterize[RawBoxes[g], "Image", ImageResolution -> res]],
      If[NumericQ[$SlideNotebookRasterizeSeconds], $SlideNotebookRasterizeSeconds, 30],
      $Failed],
    $Failed];
  If[ImageQ[r], r, $Failed]];

If[! ValueQ[$SlideNotebookRasterizeSeconds], $SlideNotebookRasterizeSeconds = 30];

(* \:56f3 1 \:679a\:306e\:753b\:7d20\:4e0a\:9650 (\:9577\:8fba)\:3002\:30c7\:30c3\:30ad\:306f WindowWidth 960 -> 1920 \:306e 2 \:500d\:3067\:30e9\:30b9\:30bf\:5316\:3057\:3001
   \:56f3\:30bb\:30eb\:306f ImageSize -> 560 \:3067\:7f6e\:304b\:308c\:308b\:306e\:3067\:3001\:6700\:7d42\:753b\:50cf\:306b\:51fa\:308b\:306e\:306f\:9ad8\:3005 1120 px\:3002
   \:305d\:308c\:3092\:8d85\:3048\:308b\:753b\:7d20\:306f\:30b9\:30e9\:30a4\:30c9\:306b\:306f\:4e00\:5207\:73fe\:308c\:306a\:3044\:306e\:306b\:3001\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306b\:713c\:304b\:308c\:3066
   FE <-> \:30ab\:30fc\:30cd\:30eb\:306e\:8ee2\:9001\:91cf\:3060\:3051\:3092\:5897\:3084\:3059 (\:5b9f\:6e2c: \:539f\:5bf8\:306e\:307e\:307e\:3060\:3068 10 \:679a\:3067 26.5MB)\:3002 *)
If[! ValueQ[$SlideNotebookFigureMaxSize], $SlideNotebookFigureMaxSize = 1200];

iSWCapImage[img_, maxSz_] := Module[{d, m},
  If[! ImageQ[img] || ! (IntegerQ[maxSz] && maxSz > 0), Return[img]];
  d = ImageDimensions[img];
  m = Max[d];
  If[m <= maxSz, img,
    Quiet@Check[ImageResize[img, {maxSz * d[[1]]/m, maxSz * d[[2]]/m}], img]]];

(* ---- \:539f\:5f0f\:3092\:305d\:306e\:307e\:307e\:5f15\:7528\:3059\:308b ----
   iSWFigureCell \:306f _Cell \:3092\:305d\:306e\:307e\:307e\:901a\:3059\:306e\:3067\:3001\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:6570\:5f0f\:30bb\:30eb
   (BoxData[FormBox[..]]) \:3092 "Figures" -> {..} \:3067\:6e21\:305b\:3070\:3001\:30b9\:30e9\:30a4\:30c9\:306b\:7d44\:7248\:3055\:308c\:305f
   \:6570\:5f0f\:3068\:3057\:3066\:8f09\:308b\:3002\:30d7\:30ec\:30fc\:30f3\:6587\:5b57\:5217\:306b\:6f70\:3057\:3066\:66f8\:304d\:76f4\:3059\:5fc5\:8981\:306f\:306a\:3044\:3002 *)
Options[SlideNotebookFormula] = {"Style" -> "DisplayFormula",
  FontSize -> Automatic, FontColor -> Automatic};

SlideNotebookFormula[src_String, n_Integer : 1, OptionsPattern[]] :=
  Module[{path, parts, eqs, cell, boxes, style, fs, fc},
    path = iSWSourceNBPath[src];
    If[path === $Failed, Return[iSWSourceNoNB[src]]];
    parts = iSWSourceNBParts[path];
    If[! AssociationQ[parts], Return[iSWSourceNoNB[src]]];
    eqs = Lookup[parts, "Formulas", {}];
    If[n < 1 || n > Length[eqs],
      Return[Failure["NoFormula",
        <|"MessageTemplate" -> "`1` has `2` formula(s); [EQ`3`] does not exist",
          "MessageParameters" -> {path, Length[eqs], n}|>]]];
    cell = eqs[[n, "Source"]];
    boxes = FirstCase[List @@ cell, b_BoxData :> b, None, {1}];
    If[boxes === None,
      Return[Failure["BadFormula",
        <|"MessageTemplate" -> "[EQ`1`] of `2` carries no BoxData",
          "MessageParameters" -> {n, path}|>]]];
    style = OptionValue["Style"];
    fs = Replace[OptionValue[FontSize], Automatic -> 22];
    fc = Replace[OptionValue[FontColor], Automatic :> SlideThemeColor["Bullet"]];
    Cell[boxes, style, TextAlignment -> Center,
      FontFamily -> $SlideFontFamily, FontSize -> fs, FontColor -> fc,
      CellMargins -> {{40, 40}, {8, 8}}]];

Options[SlideNotebookFigure] = {ImageResolution -> 144, "MaxSize" -> Automatic};

SlideNotebookFigure[src_String, n_Integer : 1, OptionsPattern[]] :=
  Module[{path, parts, figs, img},
    path = iSWSourceNBPath[src];
    If[path === $Failed, Return[iSWSourceNoNB[src]]];
    parts = iSWSourceNBParts[path];
    If[! AssociationQ[parts], Return[iSWSourceNoNB[src]]];
    figs = parts["Figures"];
    If[n < 1 || n > Length[figs],
      Return[Failure["NoFigure",
        <|"MessageTemplate" -> "`1` has `2` figure(s); [FIG`3`] does not exist",
          "MessageParameters" -> {path, Length[figs], n}|>]]];
    img = iSWBoxToImage[figs[[n, "Box"]], OptionValue[ImageResolution]];
    img = iSWCapImage[img,
      Replace[OptionValue["MaxSize"], Automatic :> $SlideNotebookFigureMaxSize]];
    If[ImageQ[img], img,
      Failure["BadFigure",
        <|"MessageTemplate" -> "cannot render [FIG`1`] of `2`",
          "MessageParameters" -> {n, path}|>]]];

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

iSubsectionTags[slide_Association] := Join[
  If[KeyExistsQ[slide, "ExpectedSeconds"], {"Expected:" <> ToString[slide["ExpectedSeconds"]], "Top"}, {"Top"}],
  If[StringQ[Lookup[slide, "Node", None]], {"KGNode:" <> slide["Node"]}, {}]];

iBuildSlideCells[slide_Association] := Module[{cells},
  If[KeyExistsQ[slide, "ImagePage"],
    (* \:5168\:9762\:753b\:50cf\:30da\:30fc\:30b8: Subsection \:306f\:9589\:3058\:305f\:30bb\:30eb\:3067\:4fdd\:6301(\:679a\:6570\:8a08\:6e2c\:7cfb\:3068\:306e\:4e92\:63db) *)
    Join[{iNavBarCell[],
      Cell[iLookupString[slide, "Title"], "Subsection", CellOpen -> False, CellTags -> iSubsectionTags[slide]],
      Cell[BoxData[ToBoxes[iSizedSlideImage[<|"Path" -> slide["ImagePage"], "Width" -> Automatic|>, 900, 500]]],
        "Input", TextAlignment -> Center, CellMargins -> {{0, 0}, {0, 0}}, CellTags -> "ImagePage"]},
     iContentCell /@ Cases[Lookup[slide, "Content", {}], {"Talk" | "QA", _}]],
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

iSWDirectivesBlock[nb_] := Module[{ds},
  (* \:6307\:793a\:30bb\:30eb\:306e Title: / SlideURL: / Host: \:306a\:3069\:306e\:30e1\:30bf\:884c\:306f LLM \:3078\:306e\:6307\:793a\:3067\:306f\:306a\:3044 *)
  ds = Select[iSWStripMetaLines /@ iSWCollectByStyle[nb, "Directive"], # =!= "" &];
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
        iSWHeadingAttrs[exp, iSWKGNodeOfTags[FirstCase[c, (CellTags -> tg_) :> tg, {}]]]],
      MatchQ[c, Cell[_, "Item", ___]],
      AppendTo[lines, "- " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "Subitem", ___]],
      AppendTo[lines, "  - " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "Subsubitem", ___]],
      AppendTo[lines, "    - " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "ItemParagraph" | "SubitemParagraph" | "SubsubitemParagraph", ___]],
      AppendTo[lines, "> " <> SlideWorkflow`Private`iCellText[c]],
      MatchQ[c, Cell[_, "SlideCrumb", ___]],
      AppendTo[lines, "crumb: " <> SlideWorkflow`Private`iCellText[c]],
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
      MatchQ[c, Cell[_, "SlideQA", ___]],
      AppendTo[lines, StringRiffle[("qa: " <> #) & /@
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
  "qa: \:60f3\:5b9a\:554f\:7b54 (Q: \:8cea\:554f / A: \:56de\:7b54 \:306e\:884c\:3002\:65e2\:306b\:3042\:308c\:3070\:305d\:306e\:307e\:307e\:6b8b\:3059)\n" <>
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
  "- \:65e2\:5b58\:306e qa: \:884c (\:60f3\:5b9a\:554f\:7b54) \:306f\:3001\:524a\:9664\:30fb\:66f4\:65b0\:306e\:6307\:793a\:304c\:306a\:3044\:9650\:308a\:305d\:306e\:307e\:307e\:6b8b\:3059\:3002\n" <>
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
(* \:56f3\:306e\:5927\:304d\:3055: \:5e45 560\:3001\:305f\:3060\:3057\:7e26\:9577\:30fb\:6b63\:65b9\:5f62\:306e\:56f3\:306f\:9ad8\:3055 360 \:307e\:3067 (1 \:30da\:30fc\:30b8\:76ee\:306e\:5168\:4f53\:50cf\:306e\:56f3\:306a\:3069\:304c\:753b\:9762\:304b\:3089\:306f\:307f\:51fa\:3059) *)
iSWFigureImageSize[img_?ImageQ] := With[{d = ImageDimensions[img]}, If[d[[2]]/Max[d[[1]], 1] > 360./560., {Automatic, 360}, 560]];
iSWFigureCell[g_] := Which[
  MatchQ[g, _Cell], g,
  ImageQ[g], Cell[BoxData[ToBoxes[Image[g, ImageSize -> iSWFigureImageSize[g]]]], "Input", TextAlignment -> Center],
  MatchQ[g, _Graphics | _Graphics3D], Cell[BoxData[ToBoxes[Show[g, ImageSize -> {560, 360}]]], "Input", TextAlignment -> Center],
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

(* ---- SlideDeckInsertScenario: \:65e2\:5b58\:30b9\:30e9\:30a4\:30c9\:7121\:50b7\:306e\:7d14\:7c8b\:633f\:5165 (2026-08-26) ---- *)
Options[SlideDeckInsertScenario] = {"Figures" -> {}};

SlideDeckInsertScenario[afterN_Integer, md_String, opts : OptionsPattern[]] :=
  With[{nb = iSWResolveTargetNb[]},
    If[Head[nb] =!= NotebookObject,
      Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>],
      SlideDeckInsertScenario[nb, afterN, md, opts]]];

SlideDeckInsertScenario[nb_NotebookObject, afterN_Integer, md_String, OptionsPattern[]] :=
  Module[{ranges, cells, figs, mdText, sc, slides, newCells},
  Quiet[SlideEnsureDeckStyles[nb]];
  ranges = iSWSlideRanges[nb];
  If[!(0 <= afterN <= Length[ranges]) || ranges === {},
    Return[Failure["SlideOutOfRange",
      <|"MessageTemplate" -> "cannot insert after slide `1` (deck has `2`)",
        "MessageParameters" -> {afterN, Length[ranges]}|>]]];
  figs = iSWFigureCell /@ Flatten[{OptionValue["Figures"]}];
  mdText = iSWNormalizeScenarioResponse[md, ""];
  sc = Quiet[SlideScenarioFromMarkdown[mdText]];
  slides = If[AssociationQ[sc], Lookup[sc, "Slides", {}], {}];
  If[slides === {},
    Return[Failure["BadScenario",
      <|"MessageTemplate" -> "scenario md has no slides (missing \"## title\"?)"|>]]];
  newCells = Block[{$iSlideKeepCells = figs}, iBuildSlideCells /@ slides];
  cells = Cells[nb];
  If[afterN === 0,
    SelectionMove[cells[[ranges[[1, 1]]]], Before, Cell],
    SelectionMove[cells[[ranges[[afterN, 2]]]], After, Cell]];
  NotebookWrite[nb, Flatten[newCells, 1]];
  SelectionMove[nb, After, Notebook];
  iSWStatus[nb, iSL[ToString[afterN] <> " \:679a\:76ee\:306e\:5f8c\:3078 " <> ToString[Length[slides]] <> " \:679a\:633f\:5165",
    "Inserted " <> ToString[Length[slides]] <> " slides after " <> ToString[afterN]]];
  iSWStatusClearLater[nb];
  Success["SlidesInserted", <|"After" -> afterN, "Slides" -> Length[slides],
    "Figures" -> Length[figs]|>]];

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
    "3b. \:539f\:5247\:3068\:3057\:3066\:3059\:3079\:3066\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:56f3\:304b\:8868\:3092 1 \:3064\:4ee5\:4e0a\:5165\:308c\:308b\:3002\:6bd4\:8f03\:30fb\:4ed5\:69d8\:30fb\:6570\:5024\:306e\:7f85\:5217\:306f | \:69cb\:6587\:306e\:8868\:306b\:3059\:308b\:3002\:56f3\:306e\:5165\:624b\:512a\:5148\:9806\:4f4d: (1) \:65e2\:5b58 <<FIGn>> \:306e\:518d\:914d\:7f6e (2) \:539f\:8cc7\:6599\:304b\:3089\:306e\:5f15\:7528 \:2014 \:8ad6\:6587\:30fb\:65e2\:5b58\:30b9\:30e9\:30a4\:30c9\:30fbweb \:306e\:56f3\:8868\:30fb\:5199\:771f\:30fb\:5b9f\:9a13\:30b0\:30e9\:30d5\:306f\:4f5c\:308a\:76f4\:3055\:305a\:539f\:56f3\:3092\:305d\:306e\:307e\:307e\:5207\:308a\:51fa\:3057\:3066\:4f7f\:3046(\:5f15\:7528\:304c\:6b63\:78ba\:6027\:3092\:4fdd\:3064): SlidePDFFigure[\"<key|\:30d1\:30b9|URL>\", \:30da\:30fc\:30b8, \"Crop\"->{{x1,x2},{y1,y2}} \:5de6\:4e0a\:539f\:70b9\:6bd4\:7387] (URL\:30fbarxiv:ID\:30fbGoogle Slides \:30d7\:30ec\:30bc\:30f3 URL \:306f\:81ea\:52d5\:3067 PDF \:5316\:3055\:308c\:308b) / SlidePDFImages[\"<key>\"] = PDF \:57cb\:3081\:8fbc\:307f\:306e\:5199\:771f\:30fb\:30e9\:30b9\:30bf\:56f3\:306e\:4e00\:89a7 / SlideDeckFigure[\"<\:904e\:53bb\:30c7\:30c3\:30ad.nb>\", n] = \:904e\:53bb\:30b9\:30e9\:30a4\:30c9 1 \:679a\:306e\:753b\:50cf\:5f15\:7528 / SlideNotebookFigure[\"<\:7d20\:6750.nb>\", n] = \:30c7\:30c3\:30ad\:3067\:306a\:3044\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af(\:8ad6\:6587\:306e\:548c\:8a33\:306a\:3069)\:306e n \:756a\:76ee\:306e\:56f3\:3002\:30da\:30fc\:30b8\:756a\:53f7\:3068\:9818\:57df\:306f ClaudeAttach[SlideSourceFile[\"<key|URL>\"]] (URL \:7cfb\:306f PDF \:5316\:6e08\:307f\:306e\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:304c\:8fd4\:308b) \:3067\:8cc7\:6599\:3092\:6dfb\:4ed8\:30fb\:95b2\:89a7\:3057\:3066\:78ba\:304b\:3081\:3001\:5207\:308a\:51fa\:3057\:7d50\:679c\:306f ImageDimensions \:7b49\:3067\:691c\:8a3c\:3059\:308b\:3002\:5207\:308a\:51fa\:3057\:305f\:56f3\:306f \"Figures\" \:3067\:6e21\:3057 md \:3067\:306f <<FIGn>>\:3001\:76f4\:5f8c\:306b\:5fc5\:305a cite: (3) \:539f\:8cc7\:6599\:306b\:5b58\:5728\:3057\:306a\:3044\:6982\:5ff5\:56f3\:30fb\:307e\:3068\:3081\:56f3\:306e\:307f\:65b0\:898f\:4f5c\:56f3\:3002\n", ""] <>
  If[TrueQ[$SlideTalkPerSlide],
    "3c. \:5404\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c\:306b talk: \:884c\:3067\:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f\:3092\:66f8\:304f(\:3067\:3059\:30fb\:307e\:3059\:8abf\:30012\:301c6 \:6587\:30011 \:679a 25 \:79d2\:524d\:5f8c\:3002\:5192\:982d\:306b\:524d\:306e\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:306e\:63a5\:7d9a\:3092\:4e00\:8a00\:3001\:6bce\:56de\:9055\:3046\:8a00\:3044\:56de\:3057\:3067)\:3002\:30b9\:30e9\:30a4\:30c9\:672c\:6587\:306f\:56f3\:8868+\:4f53\:8a00\:6b62\:3081\:306e\:77ed\:3044\:7b87\:6761\:66f8\:304d\:306b\:3068\:3069\:3081\:3001\:8aac\:660e\:306e\:6587\:7ae0\:306f talk \:5074\:304c\:62c5\:3046 \:2014 \:30b9\:30e9\:30a4\:30c9\:3068 talk \:3092\:5408\:308f\:305b\:3066\:89e3\:8aac\:304c\:5b8c\:6210\:3059\:308b\:3088\:3046\:306b\:66f8\:304d\:3001\:540c\:3058\:6587\:3092\:4e21\:65b9\:306b\:5165\:308c\:306a\:3044\:3002\:7b87\:6761\:66f8\:304d\:8a18\:53f7\:30fbURL\:30fb\:8a18\:53f7\:5217\:306e\:8aad\:307f\:4e0a\:3052\:3092 talk \:306b\:5165\:308c\:306a\:3044\:3002\:30b9\:30e9\:30a4\:30c9\:306b\:7121\:3044\:4e8b\:5b9f\:30fb\:6570\:5024\:3092 talk \:3067\:4f5c\:3089\:306a\:3044\:3002\n", ""] <>
  "3d. \:65e2\:5b58\:306e qa: \:884c (\:60f3\:5b9a\:554f\:7b54) \:306f\:3001\:524a\:9664\:30fb\:66f4\:65b0\:306e\:6307\:793a\:304c\:306a\:3044\:9650\:308a md \:306b\:305d\:306e\:307e\:307e\:6b8b\:3059\:3002\n" <>
  "3e. **\:6570\:5f0f\:306f\:66f8\:304d\:76f4\:3055\:306a\:3044**\:3002\:7d20\:6750\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:6570\:5f0f\:306f SlideNotebookText \:306e \"[EQn]\" \:884c\:3067\:4f4d\:7f6e\:304c\:5206\:304b\:308b\:306e\:3067\:3001SlideNotebookFormula[key, n] \:3067\:539f\:30bb\:30eb\:306e\:7d44\:7248\:3054\:3068 \"Figures\"->{...} \:3078\:6e21\:3057\:3066\:5f15\:7528\:3059\:308b (md \:3067\:306f <<FIGn>> \:3068\:540c\:3058\:30c8\:30fc\:30af\:30f3\:67a0\:3092\:4f7f\:3046)\:3002\:30d7\:30ec\:30fc\:30f3\:6587\:5b57\:5217\:306b\:6f70\:3059\:3068\:5206\:6570\:30fb\:6dfb\:5b57\:30fb\:7dcf\:548c\:304c\:58ca\:308c\:308b\:3002\:539f\:8cc7\:6599\:306b\:7121\:3044\:5f0f\:3092\:81ea\:5206\:3067\:66f8\:304f\:5834\:5408\:306f \:305d\:306e\:65e8\:3092 cite: \:884c\:306b\:660e\:8a18\:3059\:308b\:3002
4. \:539f\:8cc7\:6599\:306b\:7121\:3044\:6982\:5ff5\:56f3\:30fb\:30d5\:30ed\:30fc\:56f3\:306e\:307f Wolfram \:8a00\:8a9e\:306e Graphics \:3067\:65b0\:898f\:4f5c\:56f3\:3059\:308b\:3002\:539f\:8cc7\:6599\:306b\:5b58\:5728\:3059\:308b\:56f3\:8868\:30fb\:5199\:771f\:30fb\:5b9f\:9a13\:30b0\:30e9\:30d5\:3092 Graphics \:3067\:4f5c\:308a\:76f4\:3057\:3066\:306f\:306a\:3089\:306a\:3044(3b \:306e\:5f15\:7528\:3092\:4f7f\:3046)\:3002\:4f5c\:56f3\:6642\:306e\:898f\:7d04(\:914d\:8272\:306f SlideThemeColor[\"Title\"|\"Bullet\"|\"SubBullet\"|\"Dim\"|\"Arrow\"|\"PanelBackground\"|\"PanelBorder\"]\:3001\:30d5\:30a9\:30f3\:30c8\:306f FontFamily->$SlideFontFamily\:3001\:88dc\:52a9\:5b9a\:7fa9\:306f\:5fc5\:305a Module \:5185)\:3002\:56f3\:306e\:751f\:6210\:306b\:8ab2\:91d1 API(LLMSynthesize / ImageSynthesize \:7b49)\:3092\:4f7f\:308f\:306a\:3044\:3053\:3068\:3002\:65b0\:898f\:56f3\:306f md \:4e2d\:3067 <<FIG" <> ToString[k + 1] <> ">> \:4ee5\:964d\:306e\:30c8\:30fc\:30af\:30f3\:3068\:3057\:3066\:53c2\:7167\:3059\:308b\:3002\n" <>
  "4b. \:30b3\:30fc\:30c9\:3092\:8a55\:4fa1\:3059\:308b\:3068\:304d\:306f **\:4ee3\:5165\:3092\:5fc5\:305a Module[{a, b}, ...] \:306e\:4e2d\:306b\:7f6e\:304f**\:3002\:30b0\:30ed\:30fc\:30d0\:30eb\:5909\:6570\:3078\:306e\:4ee3\:5165 (x = ...) \:306f GlobalSetRequiresApproval \:3067\:627f\:8a8d\:5f85\:3061\:306b\:306a\:308a\:3001\:30c4\:30fc\:30eb\:7d4c\:8def\:3067\:306f\:627f\:8a8d UI \:3092\:51fa\:305b\:306a\:3044\:306e\:3067\:305d\:3053\:3067\:6b62\:307e\:308b\:3002
5. \:6700\:5f8c\:306b SlideApplyScenario[" <> ToString[slideNo] <> ", md] \:3092\:4e00\:5ea6\:3060\:3051\:8a55\:4fa1\:3057\:3066\:9069\:7528\:3059\:308b(\:65b0\:898f\:56f3\:304c\:3042\:308c\:3070 SlideApplyScenario[" <> ToString[slideNo] <> ", md, \"Figures\"->{g1, ...}] \:306e\:5f62\:3067\:3001md \:306e <<FIG" <> ToString[k + 1] <> ">> \:4ee5\:964d\:3068\:540c\:9806\:306b\:6e21\:3059)\:3002\:3053\:308c\:304c\:30b9\:30e9\:30a4\:30c9\:3078\:306e\:552f\:4e00\:306e\:66f8\:8fbc\:307f\:624b\:6bb5\:3067\:3042\:308a\:3001NotebookWrite \:7b49\:3067\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:63a5\:7de8\:96c6\:3057\:3066\:306f\:306a\:3089\:306a\:3044\:3002\n" <>
  "5b. **35 \:679a\:306e\:3088\:3046\:306a\:5927\:304d\:306a\:5c55\:958b\:306f 1 \:56de\:306e\:8a55\:4fa1\:306b\:8a70\:3081\:8fbc\:307e\:306a\:3044**\:3002SlideDeckInsertScenario / SlideApplyScenario \:3092 10 \:679a\:7a0b\:5ea6\:305a\:3064\:306b\:5206\:3051\:3066\:547c\:3076\:3002\:307e\:305f\:3001\:30bb\:30eb\:306e\:623b\:308a\:5024\:306b\:753b\:50cf\:3084\:56f3\:306e\:30ea\:30b9\:30c8\:3092\:7f6e\:304b\:306a\:3044 (Length \:3084 Status \:306a\:3069\:77ed\:3044\:5024\:3092\:8fd4\:3059) \:2014 \:5927\:91cf\:306e\:753b\:50cf\:3092 1 \:56de\:3067\:66f8\:304d\:8fbc\:3080\:30fb\:8868\:793a\:3059\:308b\:3068 FE <-> \:30ab\:30fc\:30cd\:30eb\:306e\:8ee2\:9001\:3067\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:5fdc\:7b54\:3057\:306a\:304f\:306a\:308b\:3002
6. \:623b\:308a\:5024\:304c Failure \:306a\:3089 md \:3092\:4fee\:6b63\:3057\:3066 SlideApplyScenario \:3092\:518d\:8a55\:4fa1\:3059\:308b\:3002Success[\"SlideApplied\", ...] \:304c\:8fd4\:308c\:3070\:5b8c\:4e86\:3002" <>
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
    iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb] <> iSWReferencesBlock[nb] <> iSWStoryBlock[nb]];
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, iSWAgentEvalCell[task], All];
  SelectionEvaluate[nb];
  iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9 " <> ToString[slideNo] <> " \:306e\:5c55\:958b\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72 (\:8ffd\:8de1\:306f\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d)",
    "Delegated slide " <> ToString[slideNo] <> " expansion to agent (see cells after end marker)"]];
];

(* Direct \:7d4c\:8def: \:8efd\:91cf\:306a\:76f4\:63a5 LLM (\:65e7\:65b9\:5f0f)\:3002\:30c4\:30fc\:30eb\:7121\:3057\:30fb\:30c6\:30ad\:30b9\:30c8\:751f\:6210\:306e\:307f *)
iSWExpandDirect[nb_, slideNo_, ctx_] := Module[{meta, prompt},
  If[!iSWRequireLLM[], Return[$Failed]];
  meta = iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb] <> iSWReferencesBlock[nb] <> iSWStoryBlock[nb];
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

(* \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb: \:305d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:60f3\:5b9a\:554f\:7b54\:3002\:6a59\:8907\:7cfb (\:30c8\:30fc\:30af\:306e\:9752\:7d2b\:3068\:5bfe) *)
$iSWQACellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.8, 0.45, 0.15],
  Background -> RGBColor[0.995, 0.96, 0.915], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.8, 0.45, 0.15]]};

(* ---- \:30c7\:30c3\:30ad\:57cb\:3081\:8fbc\:307f\:30b9\:30bf\:30a4\:30eb\:5b9a\:7fa9 (2026-08-25) ----
   \:30e1\:30bf\:30bb\:30eb(SlidePrompt/Note/Directive/Dictionary/Bibliography/References)\:3092
   Working \:3067\:306f\:5f93\:6765\:306e\:898b\:305f\:76ee\:306e\:307e\:307e\:3001SlideShow \:74b0\:5883\:3067\:306f\:975e\:8868\:793a\:306b\:3059\:308b\:3002
   \:30bb\:30eb\:5074\:306f\:7d20\:306e Cell[text, style] \:306b\:3057\:3001\:898b\:305f\:76ee\:30fb\:53ef\:8996\:6027\:306f stylesheet \:5074\:304c\:6301\:3064\:3002 *)
$iSWDeckStyleVersion = 6;  (* v3: +SlideQA, v4: +SlideStory, v5: +SlideCrumb, v6: +SlideAdjust *)
$iSWOwnedStyleNames = {"SWDeckStyles", "SlidePrompt", "Note", "Directive",
  "Dictionary", "Bibliography", "References", "SlideTalk", "SlideQA", "SlideStory", "SlideCrumb", "SlideAdjust"};
(* \:30d1\:30f3\:304f\:305a: \:984c\:76ee\:306e\:76f4\:4e0b\:306b\:5c0f\:3055\:304f\:7070\:8272\:3067\:53f3\:5bc4\:305b\:3002SlideShow \:3067\:3082\:898b\:305b\:308b (\:96a0\:3057\:30e1\:30bf\:30bb\:30eb\:3067\:306f\:306a\:3044) *)
$iSWCrumbCellOpts = {FontSize -> 12, FontColor -> GrayLevel[0.5], TextAlignment -> Right,
  CellMargins -> {{60, 30}, {2, 0}}, ShowCellBracket -> False, Selectable -> True};

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
     {"SlideTalk", $iSWTalkCellOpts},
     {"SlideQA", $iSWQACellOpts},
     {"SlideStory", $iSWStoryCellOpts},
     {"SlideAdjust", $iSWAdjustCellOpts}}], 1],
  {Cell[StyleData["SlideCrumb"], Sequence @@ $iSWCrumbCellOpts]}];

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

(* \:534a\:5e45\:30dc\:30bf\:30f3\:306b\:53ce\:307e\:308b\:77ed\:3044\:30e9\:30d9\:30eb (v1.21) *)
iSWSetEnvLabel[env_] := If[env === "SlideShow",
  $iSWEnvLabel = "Slideshow";
  $iSWEnvColor = RGBColor[0.878, 0.486, 0.078],
  $iSWEnvLabel = "Working";
  $iSWEnvColor = RGBColor[0.3, 0.5, 0.4]];

iSWRefreshEnvLabel[] := Module[{nb = Quiet[InputNotebook[]]},
  iSWSetEnvLabel[If[Head[nb] === NotebookObject,
    Quiet[CurrentValue[nb, ScreenStyleEnvironment]], "Working"]]];

(* SlideShow \:4e2d\:306f\:6a19\:6e96\:30c4\:30fc\:30eb\:30d0\:30fc\:3092\:9000\:907f\:3059\:308b\:3002\:5b9f\:6e2c (2026-08-26): \:30ea\:30dc\:30f3\:306e\:6b63\:4f53\:306f
   WindowToolbars -> {"MultipurposeBar"} \:3067\:3001SlideShow \:306e\:30b9\:30e9\:30a4\:30c9\:30ca\:30d3\:30d0\:30fc\:3068
   \:4e0a\:7aef\:3092\:53d6\:308a\:5408\:3046\:3002\:9000\:907f\:6642\:306f\:5143\:5024\:3092 TaggingRules \:306b\:4fdd\:5b58\:3057\:3001Working \:5fa9\:5e30\:3067\:5fa9\:5143 *)
If[!ValueQ[$SlideHideToolbarInSlideshow], $SlideHideToolbarInSlideshow = True];

iSWSlideshowToolbarQ[v_] := StringContainsQ[ToString[v, InputForm], "SlideshowToolbar" | "SlideShowToolbar"];

iSWApplyToolbarPolicy[nb_, env_] := If[TrueQ[$SlideHideToolbarInSlideshow],
  If[env === "SlideShow",
    Module[{saved, tb, dc},
      (* \:65e2\:306b\:9000\:907f\:304c\:3042\:308b\:3068\:304d\:306f\:4e0a\:66f8\:304d\:3057\:306a\:3044: \:66f8\:5f0f\:30e1\:30cb\:30e5\:30fc\:7d4c\:7531\:3067 Working \:306b\:623b\:3063\:305f\:5f8c\:306a\:3069\:306b
         \:518d\:5ea6 Slideshow \:3078\:5165\:308b\:3068\:300c\:96a0\:308c\:305f\:72b6\:614b {}\:300d\:3092\:9000\:907f\:3057\:3066\:3057\:307e\:3044\:3001\:5fa9\:5143\:3067\:30ea\:30dc\:30f3\:304c\:6d88\:3048\:308b *)
      saved = Quiet[CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}]];
      If[!StringQ[saved],
        tb = Quiet[Check[AbsoluteCurrentValue[nb, WindowToolbars], Inherited]];
        CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}] = ToString[tb, InputForm]];
      SetOptions[nb, WindowToolbars -> {}];
      (* \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:5074 DockedCells (CloudPublishable \:306e Public/Private \:30d0\:30c3\:30b8\:7b49) \:306f
         stylesheet \:306e SlideShow \:74b0\:5883\:5b9a\:7fa9 = \:30b9\:30e9\:30a4\:30c9\:30ca\:30d3\:30d0\:30fc\:3092\:5168\:74b0\:5883\:3067\:4e0a\:66f8\:304d\:3059\:308b\:305f\:3081
         \:9000\:907f\:3057\:3066 Inherited \:3078\:3002\:3053\:3061\:3089\:3082\:4e8c\:91cd\:9000\:907f\:3092\:9632\:3050 *)
      saved = Quiet[CurrentValue[nb, {TaggingRules, "SWSavedDockedCells"}]];
      If[!StringQ[saved],
        dc = FirstCase[Options[nb, DockedCells],
          HoldPattern[DockedCells -> v_] :> v, Inherited];
        (* FE \:306e\:30d7\:30ec\:30bc\:30f3\:30bf\:30fc\:30d3\:30e5\:30fc (Slide n of m) \:304c\:30ce\:30fc\:30c8\:5074\:306b SlideshowToolbar \:3092\:713c\:304f\:3068\:3001Working \:3067\:3082
           \:30ca\:30d3\:30d0\:30fc\:304c\:51fa\:7d9a\:3051\:308b (\:5b9f\:6e2c 2026-09-15)\:3002\:3053\:308c\:306f\:9000\:907f\:305b\:305a\:3001Working \:3067\:306f Inherited \:306b\:843d\:3068\:3059 *)
        If[dc =!= Inherited && dc =!= {} && ! iSWSlideshowToolbarQ[dc],
          CurrentValue[nb, {TaggingRules, "SWSavedDockedCells"}] =
            ToString[dc, InputForm]]];
      SetOptions[nb, DockedCells -> Inherited]],
    Module[{s = Quiet[CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}]], d, val},
      val = If[StringQ[s], Quiet[Check[ToExpression[s], Inherited]], Inherited];
      (* \:300c\:96a0\:3057\:305f\:72b6\:614b\:300d\:3092\:5fa9\:5143\:3057\:306a\:3044\:4fdd\:967a: {} / None \:306f Inherited \:306b\:843d\:3068\:3057\:3001
         \:5927\:57df\:65e2\:5b9a (\:901a\:5e38 MultipurposeBar \:306e\:30ea\:30dc\:30f3) \:3092\:5fc5\:305a\:53d6\:308a\:623b\:3059 *)
      If[val === {} || val === None, val = Inherited];
      SetOptions[nb, WindowToolbars -> val];
      Quiet[CurrentValue[nb, {TaggingRules, "SWSavedToolbars"}] = Inherited];
      With[{cur = FirstCase[Options[nb, DockedCells], HoldPattern[DockedCells -> v_] :> v, Inherited]},
        If[iSWSlideshowToolbarQ[cur], SetOptions[nb, DockedCells -> Inherited]]];
      d = Quiet[CurrentValue[nb, {TaggingRules, "SWSavedDockedCells"}]];
      If[StringQ[d] && StringContainsQ[d, "SlideshowToolbar"], d = None];
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
    Module[{kind = iSWRefKind[r["Locator"]], reg},
      (* \:53d6\:308a\:8fbc\:307f\:6e08\:307f\:8ad6\:6587\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:3042\:308c\:3070 "Notebook" \:30ad\:30fc\:3067\:6301\:3064 (Seed / \:672c\:6587\:8aad\:307f\:306f\:305d\:3061\:3089\:3092\:4f7f\:3046) *)
      reg = If[MemberQ[{"SourceVault", "arXiv", "Eagle"}, kind], iSWRegisteredSourceNotebook[r["Locator"]], $Failed];
      Join[r, <|"Key" -> If[StringQ[r["Key"]] && r["Key"] =!= "", r["Key"],
          "ref" <> ToString[n]],
        "Kind" -> kind|>,
        If[reg =!= $Failed, <|"Notebook" -> reg|>, <||>]]]], items]];

iSWReferencesList[nb_] :=
  iSWParseReferences[StringRiffle[iSWStyleTexts[nb, "References"], "\n"]];

iSWReferenceGuide[] :=
  "\:53c2\:7167\:65b9\:6cd5: eagle:<id> \:306f SourceVaultEagleItemPath[SourceVaultEagleItem[\"<id>\"]] \:3067\:539f\:672c\:30d1\:30b9\:3092\:53d6\:5f97\:3057\:3001PDF \:306f ClaudeAttach[\:30d1\:30b9] \:3067\:6dfb\:4ed8\:3057\:3066\:8aad\:3080\:3002sv://.. / src-.. \:306f SourceVaultResolveReference (\:307e\:305f\:306f ClaudeAttach[\"sv://..\"])\:3002arxiv:<id> \:306f https://arxiv.org/abs/<id>\:3002URL \:306f ClaudeAttach[url] \:304b web \:691c\:7d22/\:53d6\:5f97\:3002.nb \:306f 2 \:7a2e\:985e\:3092\:898b\:5206\:3051\:308b: (i) \:904e\:53bb\:30b9\:30e9\:30a4\:30c9\:30c7\:30c3\:30ad\:306f SlideDeckOverview / SlideDeckSlides \:3067\:69cb\:6210\:30fb\:4f53\:88c1\:3092\:53c2\:7167\:3057\:3001\:56f3\:306e\:5f15\:7528\:306f SlideDeckFigure\:3002(ii) \:8ad6\:6587\:306e\:548c\:8a33\:306a\:3069\:30c7\:30c3\:30ad\:3067\:306a\:3044\:7d20\:6750 .nb \:306f SlideNotebookOutline[key] (\:898b\:51fa\:3057\:69cb\:6210\:3068\:5404\:7bc0\:306e\:56f3\:756a\:53f7) \:2192 SlideNotebookText[key, \:898b\:51fa\:3057] (\:305d\:306e\:7bc0\:306e\:672c\:6587\:30fb\:6570\:5f0f\:3002\:56f3\:306e\:4f4d\:7f6e\:306f [FIGn] \:884c) \:2192 SlideNotebookFigure[key, n] ([FIGn] \:306e\:539f\:56f3\:3092 Image \:3067) \:3067\:8aad\:3080\:3002\:30d5\:30a1\:30a4\:30eb\:3092\:8aad\:3080\:306e\:306b Import / Get \:3092\:4f7f\:3063\:3066\:306f\:306a\:3089\:306a\:3044 (NBAccess \:306e\:6052\:4e45\:7981\:6b62 head \:3067\:3001\:4f7f\:3046\:3068 ForbiddenHead \:3067\:30bf\:30fc\:30f3\:3054\:3068\:5373\:6b7b\:3059\:308b)\:3002\:4e0a\:8a18\:306e\:5c02\:7528\:95a2\:6570\:3067\:53d6\:308c\:306a\:3044\:5f62\:5f0f\:306e\:30d5\:30a1\:30a4\:30eb\:3092\:3069\:3046\:3057\:3066\:3082\:8aad\:3080\:3068\:304d\:3060\:3051 NBImport[path] / NBImport[path, \"Text\"] (NBAccess \:4ef2\:4ecb Import\:3002\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c NBSetAccessibleDirs \:3067\:5ba3\:8a00\:3057\:305f\:30c7\:30a3\:30ec\:30af\:30c8\:30ea\:5185\:306e\:307f\:3002\:7bc4\:56f2\:5916\:306f $Failed)\:3002\:56f3\:8868\:30fb\:5199\:771f\:306e\:5f15\:7528\:5207\:308a\:51fa\:3057\:306f SlidePDFFigure(\:30da\:30fc\:30b8/\:9818\:57df) / SlidePDFImages(\:57cb\:3081\:8fbc\:307f\:753b\:50cf) / SlideDeckFigure(\:904e\:53bb\:30b9\:30e9\:30a4\:30c9 1 \:679a) \:2014 locator \:3092\:305d\:306e\:307e\:307e\:6e21\:305b\:308b\:3002SlideSourceFile[locator] \:306f\:89e3\:6c7a\:6e08\:307f\:30ed\:30fc\:30ab\:30eb\:30d5\:30a1\:30a4\:30eb\:30d1\:30b9(ClaudeAttach \:3067\:306e\:95b2\:89a7\:7528)\:3002";

iSWReferencesBlockFromList[refs_List] := If[refs === {}, "",
  "=== References (\:6587\:732e\:30ea\:30b9\:30c8: \:6307\:793a\:4e2d\:306e [key] \:306f\:3053\:308c\:3092\:6307\:3059) ===\n" <>
  StringRiffle[Map[Function[r,
    "[" <> r["Key"] <> "] (" <> r["Kind"] <> ") " <> r["Locator"] <>
      If[StringQ[Lookup[r, "Notebook", None]], " [\:548c\:8a33\:30ce\:30fc\:30c8\:767b\:9332\:6e08\:307f: SlideNotebookOutline/Text/Figure/Formula \:3067\:8aad\:3081\:308b]", ""] <>
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
(* \:6307\:793a\:30bb\:30eb\:306f\:300c\:30c7\:30c3\:30ad\:5358\:4f4d\:30e1\:30bf (Title:/SlideURL:/Host:) \:306e\:6b63\:300d\:3067\:3082\:3042\:308b\:306e\:3067\:3001
   \:7a7a\:306e\:30e1\:30bf\:884c\:3092\:96db\:5f62\:3068\:3057\:3066\:5148\:306b\:7f6e\:304f (v1.19) *)
SlideInsertDirective[nb_NotebookObject] := iSWInsertMeta[nb, "DocInsertDirective", "Directive",
  iSWDirectiveTemplateText[], $iSWDirectiveCellOpts];

SlideInsertTalk[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertTalk[nb]]];
SlideInsertTalk[nb_NotebookObject] := iSWInsertMeta[nb, "", "SlideTalk",
  iSL["\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:767a\:8868\:539f\:7a3f(\:30c8\:30fc\:30af)\:3092\:66f8\:304f\:3002\:30b9\:30e9\:30a4\:30c9\:306f\:56f3\:8868+\:30ad\:30fc\:30ef\:30fc\:30c9\:3001\:8aac\:660e\:306f\:30c8\:30fc\:30af\:3067\:3002",
    "Write the talk for this slide here; keep the slide itself visual and terse."],
  $iSWTalkCellOpts];

SlideInsertQA[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertQA[nb]]];
(* \:60f3\:5b9a\:554f\:7b54\:30bb\:30eb\:3002\:30c8\:30fc\:30af\:30bb\:30eb\:306e\:96a3 (\:30b9\:30e9\:30a4\:30c9\:306e\:6700\:5f8c) \:306b\:7f6e\:304f\:30021 \:554f = Q:/A: \:306e 2 \:884c *)
SlideInsertQA[nb_NotebookObject] := iSWInsertMeta[nb, "", "SlideQA",
  iSL["Q: \:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:8a0a\:304b\:308c\:305d\:3046\:306a\:8cea\:554f\nA: \:305d\:306e\:307e\:307e\:8aad\:307f\:4e0a\:3052\:3089\:308c\:308b\:56de\:7b54 (2\:301c4 \:6587)\n# cite: sv://... \:3084\:51fa\:5178\:30c6\:30ad\:30b9\:30c8\:3001PL: 0.6 \:3067 1 \:554f\:3060\:3051\:975e\:516c\:958b\:6271\:3044\:306b\:3067\:304d\:308b",
    "Q: an anticipated question about this slide\nA: the answer, ready to be read aloud\n# optional: cite: sv://... , PL: 0.6"],
  $iSWQACellOpts];

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
    Quiet[iSWRecordVideoDigest[Quiet[NotebookFileName[nb]]]];
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
  If[StringQ[out], Quiet[iSWRecordVideoDigest[Quiet[NotebookFileName[nb]]]]];
  iSWStatus[nb, If[StringQ[out], iSL["mp4 \:5b8c\:4e86: " <> FileNameTake[out], "mp4 done: " <> FileNameTake[out]],
    iSL["mp4 \:5931\:6557", "mp4 failed"]]];
  iSWStatusClearLater[nb];
  out];

iSWOverviewAction[nb_] := Module[{ov = SlideDeckOverview[iSWDeckSource[nb]]},
  If[Head[ov] === Dataset,
    CreateDocument[{Cell[BoxData[ToBoxes[ov]], "Output"]},
      WindowTitle -> "Slide Overview", WindowSize -> {760, 520}],
    MessageDialog[iSL["\:4e00\:89a7\:3092\:53d6\:5f97\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f\:3002", "Could not build overview."]]]];

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
  <|"Id" -> iTalkMetaString[meta, {"Id"}, ""],
    "Title" -> iTalkMetaString[meta, {"Title"}, ""],
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
    {k, {"Id", "Title"}}];
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

iTalkDeckOutline[source_] := Module[{data, slides, titles, mds, talks, qas, visuals},
  data = SlideDeckSlides[source];
  If[!AssociationQ[data], Return[$Failed]];
  slides = Lookup[data, "Slides", {}];
  If[slides === {}, Return[$Failed]];
  titles = SlideWorkflow`Private`iSlideTitle /@ slides;
  (* \:30b9\:30e9\:30a4\:30c9\:5185\:30c8\:30fc\:30af\:30bb\:30eb (SlideTalk) \:3092\:53ce\:7a6b\:3059\:308b *)
  talks = StringTrim[StringRiffle[
    Cases[#, c : Cell[_, "SlideTalk", ___] :>
      SlideWorkflow`Private`iCellText[c], {1}], "\n"]] & /@ slides;
  (* \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb (SlideQA) \:3082\:53ce\:7a6b\:3059\:308b\:3002\:539f\:7a3f\:3068\:306f\:5225\:306e\:5c64 *)
  qas = StringTrim[StringRiffle[
    Cases[#, c : Cell[_, "SlideQA", ___] :>
      SlideWorkflow`Private`iCellText[c], {1}], "\n"]] & /@ slides;
  mds = StringRiffle[
    Select[StringSplit[#, "\n"],
      !StringStartsQ[StringTrim[#], "talk:"] &&
        !StringStartsQ[StringTrim[#], "qa:"] &],
    "\n"] & /@
    (StringReplace[First[iSWSlideToMarkdown[#]],
      "<<FIG" ~~ DigitCharacter .. ~~ ">>" -> "(\:56f3)"] & /@ slides);
  (* \:56f3\:30fb\:5199\:771f\:30fb\:30b0\:30e9\:30d5\:3092\:542b\:3080\:679a\:3002QA \:751f\:6210\:3067\:63cf\:753b\:753b\:50cf\:3092\:898b\:305b\:308b\:304b\:306e\:5224\:65ad\:306b\:4f7f\:3046 *)
  visuals = AnyTrue[#, SlideWorkflow`Private`iVisualCellQ] & /@ slides;
  <|"Count" -> Length[slides], "Titles" -> titles, "Markdown" -> mds,
    "Talks" -> talks, "QAs" -> qas, "Visuals" -> visuals,
    "Prelude" -> Lookup[data, "Prelude", {}]|>];

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
  "DeckFile" -> Automatic, "PrivacyLevel" -> Automatic, "SlideCount" -> Automatic,
  "Upload" -> Automatic, "QA" -> Automatic};

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
  iSWRegisterUploadStep[
    iSWRegisterQAStep[
      iSWDeckRegisterCore[talk, md, If[StringQ[fn], fn, ""],
        {"Title" -> OptionValue["Title"], "SlideURL" -> OptionValue["SlideURL"],
         "Id" -> OptionValue["Id"], "DeckFile" -> OptionValue["DeckFile"],
         "PrivacyLevel" -> OptionValue["PrivacyLevel"],
         "SlideCount" -> OptionValue["SlideCount"]}],
      If[StringQ[fn], fn, ""], iSWDeckSource[nb], OptionValue["QA"]],
    nb, talk, OptionValue["Upload"]]];

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
  iSWRegisterUploadStep[
    iSWRegisterQAStep[
      iSWDeckRegisterCore[talk, md, deckFileDefault,
        {"Title" -> OptionValue["Title"], "SlideURL" -> OptionValue["SlideURL"],
         "Id" -> OptionValue["Id"], "DeckFile" -> OptionValue["DeckFile"],
         "PrivacyLevel" -> OptionValue["PrivacyLevel"],
         "SlideCount" -> OptionValue["SlideCount"]}],
      deckFileDefault, OptionValue["QA"]],
    If[deckFileDefault =!= "", deckFileDefault, None], talk, OptionValue["Upload"]]];

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
  (* Id \:306f\:518d\:767b\:9332\:6642\:306e\:540c\:4e00\:6027\:306e\:9375\:3002\:6307\:793a\:30bb\:30eb\:306e Id: \:884c\:3067\:56fa\:5b9a\:3067\:304d\:308b *)
  With[{oid = Lookup[opt, "Id", Automatic], tid = Lookup[talk, "Id", ""]},
    Which[
      oid =!= Automatic, entry["Id"] = ToString[oid],
      StringQ[tid] && StringTrim[tid] =!= "", entry["Id"] = StringTrim[tid]]];
  SourceVault`SourceVaultSlideDeckRegister[entry,
    KeyTake[talk, {"Title", "Language", "Opening", "Closing", "Slides"}]]];

SlideDeckRegistry[] := If[iTalkRegistryAvailableQ[],
  SourceVault`SourceVaultSlideDeckRegistry[],
  Failure["SlideDeckRegistryUnavailable",
    <|"MessageTemplate" -> "SourceVault_slidedeck.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093\:3002"|>]];

(* ===================== \:8cea\:7591\:5fdc\:7b54 (QA) =====================
   \:300c\:767a\:8868\:4e2d\:306b\:58f0\:3067\:805e\:304b\:308c\:305f\:3089\:3001\:305d\:306e\:5834\:3067\:7b54\:3048\:308b\:300d\:305f\:3081\:306e\:4f5c\:308a\:7f6e\:304d\:3092\:3001\:30b9\:30e9\:30a4\:30c9\:306e\:4e2d\:306b\:7f6e\:304f\:5c64\:3002

   \:6b63\:672c\:306f\:30b9\:30e9\:30a4\:30c9\:5185\:306e\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb (SlideQA \:30b9\:30bf\:30a4\:30eb)\:3002\:30c8\:30fc\:30af\:30bb\:30eb (SlideTalk) \:3068\:540c\:3058\:304f
   \:5404\:30b9\:30e9\:30a4\:30c9\:306e\:672b\:5c3e\:306b 1 \:500b\:7f6e\:304d\:3001Working \:3067\:306f\:898b\:3048\:3001SlideShow \:74b0\:5883\:3067\:306f\:6d88\:3048\:3001\:753b\:50cf\:30fbmp4 \:306e
   \:66f8\:304d\:51fa\:3057\:306b\:3082\:5165\:3089\:306a\:3044\:3002md \:3067\:306f "qa: " \:884c\:3002

   \:30bb\:30eb\:306e\:66f8\:5f0f (1 \:30bb\:30eb\:306b\:4f55\:554f\:3067\:3082):
     Q: \:60f3\:5b9a\:8cea\:554f
     A: \:305d\:306e\:307e\:307e\:8aad\:307f\:4e0a\:3052\:3089\:308c\:308b\:56de\:7b54
     cite: sv://... \:307e\:305f\:306f\:51fa\:5178\:30c6\:30ad\:30b9\:30c8   (\:7701\:7565\:53ef\:3001\:8907\:6570\:53ef)
     PL: 0.6                              (\:7701\:7565\:53ef\:3002\:3053\:306e 1 \:554f\:3060\:3051\:975e\:516c\:958b\:6271\:3044\:306b\:3059\:308b)
   Q: \:304c\:6765\:308b\:305f\:3073\:306b\:65b0\:3057\:3044 1 \:554f\:3002\:63a5\:982d\:8f9e\:306e\:7121\:3044\:884c\:306f\:76f4\:524d\:306e\:9805\:76ee\:306e\:7d9a\:304d\:3002# \:884c\:306f\:30b3\:30e1\:30f3\:30c8\:3002

   \:300c\:767b\:9332\:300d\:3092\:62bc\:3059\:3068\:3001\:3053\:306e\:30bb\:30eb\:7fa4\:304c gpt-realtime \:304b\:3089\:5f15\:3051\:308b\:5f62 (SourceVault \:306e QA \:30d1\:30c3\:30af)
   \:306b\:713c\:304b\:308c\:308b\:3002\:713c\:304f\:306e\:306f SourceVaultTalkQAImport \:3067\:3001\:4eba\:306e\:66f8\:3044\:305f\:7b54\:3048\:3092 LLM \:304c\:8a00\:3044\:63db\:3048\:306a\:3044\:3002
   ============================================================================ *)

$iSWQAKeyQuestion = {"Q:", "q:", "\:8cea\:554f:", "\:554f:"};
$iSWQAKeyAnswer = {"A:", "a:", "\:56de\:7b54:", "\:7b54:"};
$iSWQAKeyCite = {"cite:", "Cite:", "\:51fa\:5178:"};
$iSWQAKeyPL = {"PL:", "pl:", "PrivacyLevel:"};

iSWQAPrefix[line_String, keys_List] :=
  SelectFirst[keys, StringStartsQ[line, #] &, None];

(* 1 \:30bb\:30eb\:5206\:306e\:30c6\:30ad\:30b9\:30c8\:3092 {<|"Question","Answer","Citations","PrivacyLevel"|>..} \:306b\:3059\:308b\:3002
   PrivacyLevel \:306f\:66f8\:304b\:308c\:305f\:3068\:304d\:3060\:3051\:5165\:308c\:308b (\:66f8\:304b\:308c\:3066\:3044\:306a\:3051\:308c\:3070\:30c7\:30c3\:30ad\:306e\:65e2\:5b9a\:3092\:4f7f\:3046) *)
iSWQAParse[text_] := Module[{lines, out = {}, cur = None, field = "Question", k, v},
  If[!StringQ[text] || StringTrim[text] === "", Return[{}]];
  lines = StringSplit[StringReplace[text, "\r\n" -> "\n"], "\n"];
  Do[
    Module[{l = StringTrim[line]},
      Which[
        l === "" || StringStartsQ[l, "#"], Null,
        (k = iSWQAPrefix[l, $iSWQAKeyQuestion]) =!= None,
        If[AssociationQ[cur], AppendTo[out, cur]];
        cur = <|"Question" -> StringTrim[StringDrop[l, StringLength[k]]],
          "Answer" -> "", "Citations" -> {}|>;
        field = "Question",
        !AssociationQ[cur], Null,   (* \:6700\:521d\:306e Q: \:3088\:308a\:524d\:306e\:884c\:306f\:898b\:51fa\:3057\:6271\:3044\:3067\:6368\:3066\:308b *)
        (k = iSWQAPrefix[l, $iSWQAKeyAnswer]) =!= None,
        cur["Answer"] = StringTrim[StringDrop[l, StringLength[k]]];
        field = "Answer",
        (k = iSWQAPrefix[l, $iSWQAKeyCite]) =!= None,
        v = StringTrim[StringDrop[l, StringLength[k]]];
        If[v =!= "", cur["Citations"] = Append[cur["Citations"], v]];
        field = "Answer",
        (k = iSWQAPrefix[l, $iSWQAKeyPL]) =!= None,
        v = Quiet[ToExpression[StringTrim[StringDrop[l, StringLength[k]]]]];
        If[NumericQ[v], cur["PrivacyLevel"] = N[v]];
        field = "Answer",
        True,
        cur[field] = StringTrim[cur[field] <> If[cur[field] === "", "", "\n"] <> l]]],
    {line, lines}];
  If[AssociationQ[cur], AppendTo[out, cur]];
  Select[out, StringTrim[#["Question"]] =!= "" &]];

(* \:9006\:5411\:304d: \:9805\:76ee\:30ea\:30b9\:30c8\:3092\:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:306b\:623b\:3059 (LLM \:751f\:6210\:306e\:66f8\:304d\:8fbc\:307f\:306b\:4f7f\:3046) *)
iSWQAToText[entries_List] := StringRiffle[Map[Function[e,
  StringRiffle[Flatten[{
    "Q: " <> StringTrim[ToString[Lookup[e, "Question", ""]]],
    "A: " <> StringTrim[ToString[Lookup[e, "Answer", ""]]],
    ("cite: " <> #) & /@ Select[Flatten[{Lookup[e, "Citations", {}]}], StringQ],
    With[{pl = Lookup[e, "PrivacyLevel", None]},
      If[NumericQ[pl], "PL: " <> ToString[N[pl]], Nothing]]}], "\n"]],
  Select[entries, AssociationQ]], "\n"];

(* ---- \:30c7\:30c3\:30ad\:304b\:3089\:96c6\:3081\:308b ---- *)

(* \:30c7\:30c3\:30ad\:5168\:4f53\:3092 {<|"Slide","Title","Text","Talk","Entries"|>..} \:306b\:3059\:308b\:3002
   SourceVaultTalkQAImport \:3078\:305d\:306e\:307e\:307e\:6e21\:305b\:308b\:5f62 *)
(* State: \:305d\:306e\:679a\:306e\:8cea\:7591\:5fdc\:7b54\:304c\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:8ffd\:3044\:3064\:3044\:3066\:3044\:308b\:304b
     "Missing"  \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c\:7121\:3044
     "Stale"    \:30bb\:30eb\:306e\:30de\:30fc\:30ab\:30fc\:3068\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:304c\:9055\:3046 = \:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:305f
     "Current"  \:4e00\:81f4
     "Unmarked" \:30de\:30fc\:30ab\:30fc\:304c\:7121\:3044 (\:624b\:66f8\:304d\:30fb\:30d1\:30c3\:30af\:304b\:3089\:306e\:5fa9\:5143) = \:5224\:5b9a\:3067\:304d\:306a\:3044
     "Unknown"  \:30b9\:30e9\:30a4\:30c9\:306e\:30cf\:30c3\:30b7\:30e5\:304c\:53d6\:308c\:306a\:304b\:3063\:305f *)
iSWQASlides[source_] := Module[{outline, digests, n, visuals},
  outline = iTalkDeckOutline[source];
  If[outline === $Failed, Return[$Failed]];
  n = outline["Count"];
  digests = iSWQASlideDigestList[source];
  If[Length[digests] =!= n, digests = ConstantArray["", n]];
  visuals = Lookup[outline, "Visuals", ConstantArray[False, n]];
  If[Length[visuals] =!= n, visuals = ConstantArray[False, n]];
  Table[
    Module[{qa = outline["QAs"][[i]], marker, entries, state},
      marker = iSWQAMarkerOf[qa];
      entries = iSWQAParse[qa];
      state = Which[
        entries === {}, "Missing",
        marker === "", "Unmarked",
        digests[[i]] === "", "Unknown",
        marker === digests[[i]], "Current",
        True, "Stale"];
      <|"Slide" -> i, "Title" -> outline["Titles"][[i]],
        "Text" -> outline["Markdown"][[i]],
        "Talk" -> outline["Talks"][[i]],
        "QAText" -> qa, "Marker" -> marker, "Digest" -> digests[[i]],
        "State" -> state, "Visual" -> TrueQ[visuals[[i]]],
        "Entries" -> entries|>],
    {i, n}]];

SlideQAEntries[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQAEntries[nb]]];

SlideQAEntries[nb_NotebookObject] := SlideQAEntries[iSWDeckSource[nb]];

SlideQAEntries[source_] := Module[{slides},
  slides = iSWQASlides[source];
  If[slides === $Failed, Return[$Failed]];
  <|"Deck" -> If[StringQ[source], source, ""],
    "SlideCount" -> Length[slides],
    "Questions" -> Total[Length[#["Entries"]] & /@ slides],
    "Answered" -> Total[Count[#["Entries"],
      e_ /; StringTrim[ToString[Lookup[e, "Answer", ""]]] =!= ""] & /@ slides],
    "Missing" -> Lookup[Select[slides, #["State"] === "Missing" &], "Slide", {}],
    "Stale" -> Lookup[Select[slides, #["State"] === "Stale" &], "Slide", {}],
    "Unmarked" -> Lookup[Select[slides, #["State"] === "Unmarked" &], "Slide", {}],
    "Current" -> Lookup[Select[slides, #["State"] === "Current" &], "Slide", {}],
    "Visual" -> Lookup[Select[slides, TrueQ[#["Visual"]] &], "Slide", {}],
    "Slides" -> slides|>];

(* View: \:4e2d\:8eab\:3092 1 \:884c 1 \:554f\:3067\:898b\:308b\:3002core (SlideQAEntries) \:3068\:5bfe *)
SlideQAView[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQAView[nb]]];

SlideQAView[source_] := Module[{data, rows},
  data = SlideQAEntries[source];
  If[!AssociationQ[data], Return[$Failed]];
  rows = Flatten[Map[Function[s,
    Map[Function[e,
      <|"Slide" -> s["Slide"],
        "Title" -> Style[s["Title"], FontFamily -> $SlideFontFamily],
        "Q" -> Style[Lookup[e, "Question", ""], FontFamily -> $SlideFontFamily],
        "A" -> Style[StringTake[StringTrim[ToString[Lookup[e, "Answer", ""]]], UpTo[120]],
          FontFamily -> $SlideFontFamily],
        "PL" -> Lookup[e, "PrivacyLevel", ""],
        "Cites" -> Length[Lookup[e, "Citations", {}]]|>],
      s["Entries"]]],
    data["Slides"]], 1];
  If[rows === {},
    Dataset[{<|"Slide" -> 0, "Title" -> "", "Q" -> iSL["\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c\:3042\:308a\:307e\:305b\:3093",
      "no QA cells"], "A" -> "", "PL" -> "", "Cites" -> 0|>}],
    Dataset[rows]]];

(* \:3069\:306e\:679a\:306b\:624b\:3092\:5165\:308c\:308b\:5fc5\:8981\:304c\:3042\:308b\:304b\:3092 1 \:884c 1 \:679a\:3067\:898b\:308b\:3002
   \:300cQA \:751f\:6210\:300d(\:5909\:66f4\:5206\:306e\:307f) \:304c\:4f55\:3092\:62fe\:3046\:304b\:3068\:540c\:3058\:5224\:5b9a *)
$iSWQAStateLabel = <|
  "Missing" -> {"\:672a\:4f5c\:6210", "missing"},
  "Stale" -> {"\:8981\:66f4\:65b0 (\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:305f)", "stale"},
  "Current" -> {"\:6700\:65b0", "current"},
  "Unmarked" -> {"\:5224\:5b9a\:4e0d\:80fd (\:624b\:66f8\:304d)", "unmarked"},
  "Unknown" -> {"\:5224\:5b9a\:4e0d\:80fd", "unknown"}|>;

iSWQAStateText[st_] := With[{p = Lookup[$iSWQAStateLabel, st, {st, st}]},
  iSL[p[[1]], p[[2]]]];

SlideQAStateView[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQAStateView[nb]]];

SlideQAStateView[source_] := Module[{data},
  data = SlideQAEntries[source];
  If[!AssociationQ[data], Return[$Failed]];
  Dataset[Map[Function[s,
    <|"Slide" -> s["Slide"],
      "Title" -> Style[s["Title"], FontFamily -> $SlideFontFamily],
      iSL["\:72b6\:614b", "State"] -> Style[iSWQAStateText[s["State"]],
        FontFamily -> $SlideFontFamily],
      "Q" -> Length[s["Entries"]],
      iSL["\:56f3\:8868", "Visual"] -> If[TrueQ[s["Visual"]], "\:25cf", ""]|>],
    data["Slides"]]]];

(* ---- \:30d1\:30c3\:30af\:5316 (gpt-realtime \:304b\:3089\:5f15\:3051\:308b\:5f62\:3078) ---- *)

iSWQALayerQ[] := Length[DownValues[SourceVault`SourceVaultTalkQAImport]] > 0;

Options[SlideQABuild] = {"PrivacyLevel" -> Automatic, "Ingest" -> True,
  "Enrich" -> True, "Verbose" -> False};

SlideQABuild[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQABuild[nb]]];

SlideQABuild[nb_NotebookObject, opts : OptionsPattern[]] := Module[{fn},
  fn = Quiet[NotebookFileName[nb]];
  If[!StringQ[fn],
    Return[Failure["SlideQAUnsaved",
      <|"MessageTemplate" ->
        "\:30c7\:30c3\:30ad\:304c\:672a\:4fdd\:5b58\:3067\:3059\:3002\:4fdd\:5b58\:3057\:3066\:304b\:3089 QA \:3092\:767b\:9332\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  SlideQABuild[fn, opts]];

(* \:96c6\:3081\:6e08\:307f\:306e slides \:3092\:53d7\:3051\:308b\:3002\:300c\:767b\:9332\:300d\:306f\:5148\:306b\:5dee\:5206\:3092\:898b\:308b\:305f\:3081\:306b\:96c6\:3081\:3066\:3044\:308b\:306e\:3067\:3001
   \:3053\:3053\:3067\:30c7\:30c3\:30ad\:3092\:3082\:3046\:4e00\:5ea6 Get \:3057\:76f4\:3055\:306a\:3044 (\:5927\:304d\:3044\:30c7\:30c3\:30ad\:3067\:306f\:3053\:308c\:304c\:52b9\:304f) *)
iSWQABuildFrom[deck_String, slides_List, plIn_, ingest_, enrich_, verbose_] :=
  Module[{pl = plIn, res},
  If[pl === Automatic,
    pl = With[{m = iSWTalkFileMeta[SlideTalkFile[deck]]},
      With[{v = Lookup[m, "PrivacyLevel", 0.3]}, If[NumericQ[v], N[v], 0.3]]]];
  res = SourceVault`SourceVaultTalkQAImport[deck,
    KeyTake[#, {"Slide", "Title", "Text", "Talk", "Entries", "PrivacyLevel"}] & /@ slides,
    "PrivacyLevel" -> pl, "Ingest" -> TrueQ[ingest], "Enrich" -> TrueQ[enrich],
    "Verbose" -> TrueQ[verbose]];
  If[AssociationQ[res],
    iSWDeckStateWrite[deck, <|"QADigest" -> iSWQADigestOf[slides]|>]];
  res];

SlideQABuild[deck_String, OptionsPattern[]] := Module[{slides},
  If[!iSWQALayerQ[],
    Return[Failure["SlideQALayerMissing",
      <|"MessageTemplate" ->
        "SourceVault_talkqa.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093 (SourceVault \:3092\:30ed\:30fc\:30c9\:3057\:3066\:304f\:3060\:3055\:3044)\:3002"|>]]];
  slides = iSWQASlides[deck];
  If[slides === $Failed,
    Return[Failure["SlideQANoDeck",
      <|"MessageTemplate" -> "\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093 (navbar \:533a\:5207\:308a\:304c\:7121\:3044?)\:3002"|>]]];
  slides = Select[slides, #["Entries"] =!= {} &];
  If[slides === {},
    Return[Failure["SlideQAEmpty",
      <|"MessageTemplate" ->
        "\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c\:3042\:308a\:307e\:305b\:3093\:3002\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:8cea\:7591\:300d\:3067\:30bb\:30eb\:3092\:4f5c\:308b\:304b\:3001\:300cQA \:751f\:6210\:300d\:3092\:4f7f\:3063\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  iSWQABuildFrom[deck, slides, OptionValue["PrivacyLevel"],
    OptionValue["Ingest"], OptionValue["Enrich"], OptionValue["Verbose"]]];

(* ---- \:65e2\:5b58\:30d1\:30c3\:30af -> \:30bb\:30eb (\:79fb\:884c\:7d4c\:8def) ----
   \:30bb\:30eb\:304c\:6b63\:672c\:306b\:306a\:3063\:305f\:306e\:3067\:3001\:4ee5\:524d LLM \:3067\:4f5c\:3063\:305f\:30d1\:30c3\:30af\:306f\:3053\:3053\:3092\:901a\:3057\:3066
   \:30b9\:30e9\:30a4\:30c9\:3078\:623b\:3059\:3002\:623b\:3055\:305a\:306b\:30bb\:30eb\:3092 1 \:3064\:3060\:3051\:4f5c\:3063\:3066\:300c\:767b\:9332\:300d\:3059\:308b\:3068\:3001
   \:30d1\:30c3\:30af\:304c\:305d\:306e 1 \:554f\:3060\:3051\:306b\:306a\:308b (\:9ed9\:3063\:3066\:6d88\:3048\:308b) *)

iSWQAPackEntriesFor[deck_String] := Module[{sel, entries},
  If[!iSWQALayerQ[], Return[$Failed]];
  If[Length[DownValues[SourceVault`SourceVaultTalkQAExport]] === 0, Return[$Failed]];
  sel = Quiet[SourceVault`SourceVaultTalkQASelectForDeck[deck]];
  If[FailureQ[sel], Return[$Failed]];
  entries = Quiet[SourceVault`SourceVaultTalkQAExport[]];
  If[!ListQ[entries] || entries === {}, Return[$Failed]];
  GroupBy[Select[entries, AssociationQ], Lookup[#, "Slide", 0] &]];

Options[SlideQAFromPack] = {"Rebuild" -> False};

SlideQAFromPack[opts : OptionsPattern[]] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQAFromPack[nb, opts]]];

SlideQAFromPack[nb_NotebookObject, OptionsPattern[]] := Module[
  {deck, grouped, ranges, existing, n = 0, rebuild, digests},
  deck = Quiet[NotebookFileName[nb]];
  If[!StringQ[deck],
    Return[Failure["SlideQAUnsaved",
      <|"MessageTemplate" -> "\:30c7\:30c3\:30ad\:304c\:672a\:4fdd\:5b58\:3067\:3059\:3002"|>]]];
  grouped = iSWQAPackEntriesFor[deck];
  If[grouped === $Failed,
    Return[Failure["SlideQANoPack",
      <|"MessageTemplate" -> "\:3053\:306e\:30c7\:30c3\:30ad\:306e QA \:30d1\:30c3\:30af\:304c\:3042\:308a\:307e\:305b\:3093\:3002"|>]]];
  rebuild = TrueQ[OptionValue["Rebuild"]];
  Quiet[SlideEnsureDeckStyles[nb]];
  (* \:623b\:3057\:305f\:30bb\:30eb\:306b\:3082\:30de\:30fc\:30ab\:30fc\:3092\:6253\:3064\:3002\:3053\:308c\:304c\:7121\:3044\:3068 "Unmarked" \:306e\:307e\:307e\:306b\:306a\:308a\:3001
     \:4ee5\:5f8c\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:3066\:3082\:300cQA \:751f\:6210\:300d(\:5909\:66f4\:5206\:306e\:307f) \:304c\:62fe\:308f\:306a\:3044 *)
  digests = iSWQASlideDigestList[iSWDeckSource[nb]];
  ranges = iSWSlideRanges[nb];
  existing = iSWQASlideHasCellQ[nb];
  Do[
    If[KeyExistsQ[grouped, i] && (rebuild || !TrueQ[Lookup[existing, i, False]]),
      With[{txt = iSWQAWithMarker[iSWQAToText[grouped[i]],
          If[Length[digests] === Length[ranges], digests[[i]], ""]]},
        If[StringTrim[txt] =!= "" && iSWQAWriteCell[nb, i, txt] =!= $Failed, n++]]],
    {i, Length[ranges], 1, -1}];
  <|"Status" -> "OK", "Slides" -> n,
    "Questions" -> Total[Length /@ Values[KeyTake[grouped, Range[Length[ranges]]]]]|>];

(* ---- LLM \:3067\:4e0b\:66f8\:304d\:3092\:4f5c\:308a\:3001\:30bb\:30eb\:3078\:66f8\:304d\:8fbc\:3080 ----
   3 \:3064\:306e\:6d41\:5100:
     "Regenerate" (1) \:5168\:30b9\:30e9\:30a4\:30c9\:3092\:4f5c\:308a\:76f4\:3059\:3002\:65e2\:5b58\:306e\:8cea\:7591\:5fdc\:7b54\:306f\:6368\:3066\:308b\:3002
     "Update"     (2) \:5168\:30b9\:30e9\:30a4\:30c9\:3092\:898b\:76f4\:3059\:3002\:65e2\:5b58\:3092 LLM \:306b\:898b\:305b\:3001\:6d3b\:304b\:3057\:305f\:307e\:307e\:76f4\:3055\:305b\:308b\:3002
     "Changed"    (3) \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9\:3068\:3001\:30b9\:30e9\:30a4\:30c9\:304c\:5909\:308f\:3063\:305f\:30b9\:30e9\:30a4\:30c9\:3060\:3051\:3002\:65e2\:5b9a\:3002
   \:30d1\:30ec\:30c3\:30c8\:306e\:300cQA \:751f\:6210\:300d\:306f 3\:3002\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c 1 \:3064\:3082\:7121\:3044\:30c7\:30c3\:30ad\:306a\:3089\:7d50\:5c40\:3059\:3079\:3066\:751f\:6210\:306b\:306a\:308b\:3002

   \:300c\:30b9\:30e9\:30a4\:30c9\:304c\:5909\:308f\:3063\:305f\:300d\:306e\:5224\:5b9a: \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:5148\:982d\:306b\:3001\:66f8\:3044\:305f\:6642\:70b9\:306e\:30b9\:30e9\:30a4\:30c9\:306e
   \:30cf\:30c3\:30b7\:30e5\:3092 "# slide: <16\:6841>" \:3068\:3057\:3066\:6b8b\:3059\:3002\:30bb\:30eb\:306b\:4ed8\:3044\:3066\:56de\:308b\:306e\:3067\:3001\:30b9\:30e9\:30a4\:30c9\:3092
   \:4e26\:3079\:66ff\:3048\:3066\:3082\:633f\:5165\:3057\:3066\:3082\:5bfe\:5fdc\:304c\:5d29\:308c\:306a\:3044 (\:756a\:53f7\:3067\:899a\:3048\:308b\:3068\:5d29\:308c\:308b)\:3002
   \:30de\:30fc\:30ab\:30fc\:306e\:7121\:3044\:30bb\:30eb (\:624b\:66f8\:304d\:30fb\:30d1\:30c3\:30af\:304b\:3089\:306e\:5fa9\:5143) \:306f\:300c\:5224\:5b9a\:3067\:304d\:306a\:3044\:300d\:306e\:3067 3 \:3067\:306f\:89e6\:3089\:306a\:3044\:3002

   \:56f3\:30fb\:5199\:771f\:30fb\:8868: \:30b9\:30e9\:30a4\:30c9\:3092\:63cf\:753b\:3057\:305f\:753b\:50cf\:3092 LLM \:306b\:6dfb\:4ed8\:3059\:308b\:3002\:672c\:6587\:306b\:306f\:73fe\:308c\:306a\:3044
   \:300c\:56f3\:306b\:4f55\:304c\:63cf\:304b\:308c\:3066\:3044\:308b\:304b\:300d\:304b\:3089\:3082\:8cea\:554f\:304c\:51fa\:308b\:305f\:3081\:3002\:753b\:50cf\:306f\:30b9\:30e9\:30a4\:30c9\:306e\:30cf\:30c3\:30b7\:30e5\:3067
   \:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b\:306e\:3067\:3001\:540c\:3058\:30b9\:30e9\:30a4\:30c9\:3092\:4e8c\:5ea6\:63cf\:753b\:3057\:306a\:3044\:3002 *)

If[!ValueQ[$SlideQAPerSlide], $SlideQAPerSlide = 3];
If[!ValueQ[$SlideQAVision], $SlideQAVision = True];

(* ---- \:51fa\:6240\:30de\:30fc\:30ab\:30fc ---- *)

$iSWQAMarkerPrefix = "# slide: ";

iSWQAMarkerOf[text_] := If[!StringQ[text], "",
  With[{m = StringCases[text,
      RegularExpression["(?m)^#\\s*slide:\\s*([0-9a-fA-F]{6,})"] :> "$1", 1]},
    If[m === {}, "", ToLowerCase[First[m]]]]];

iSWQAStripMarker[text_] := If[!StringQ[text], "",
  StringTrim[StringReplace[text,
    RegularExpression["(?m)^#\\s*slide:\\s*[0-9a-fA-F]{6,}[ \\t]*(\\r?\\n|$)"] -> ""]]];

iSWQAWithMarker[text_String, digest_] :=
  If[!StringQ[digest] || digest === "", iSWQAStripMarker[text],
    $iSWQAMarkerPrefix <> digest <> "\n" <> iSWQAStripMarker[text]];

iSWQAShort[d_] := If[StringQ[d] && StringLength[d] >= 16,
  StringTake[ToLowerCase[d], 16], If[StringQ[d], ToLowerCase[d], ""]];

(* \:30b9\:30e9\:30a4\:30c9\:3054\:3068\:306e\:300c\:63cf\:304b\:308c\:308b\:4e2d\:8eab\:300d\:306e\:30cf\:30c3\:30b7\:30e5 (mp4 \:306e\:5dee\:5206\:5224\:5b9a\:3068\:540c\:3058\:7269\:5dee\:3057) *)
iSWQASlideDigestList[source_] := With[{ds = Quiet[iSWDeckSlideDigests[source]]},
  If[ListQ[ds], iSWQAShort /@ ds, {}]];

(* ---- \:753b\:50cf (\:56f3\:30fb\:5199\:771f\:30fb\:8868\:3092\:898b\:305b\:308b) ---- *)

iSWQAImageDir[deck_String] :=
  FileNameJoin[{DirectoryName[deck], FileBaseName[deck] <> "_qa_images"}];

iSWQAImageFile[deck_String, n_Integer, digest_String] :=
  FileNameJoin[{iSWQAImageDir[deck],
    "slide-" <> IntegerString[n, 10, 3] <> "-" <>
      If[digest === "", "nodigest", digest] <> ".png"}];

(* \:6dfb\:4ed8\:306f\:6a2a 1280 \:306b\:843d\:3068\:3059\:30021920 \:306e\:307e\:307e\:3060\:3068 1 \:679a 1\:301c2MB \:3067\:3001\:8aad\:307f\:53d6\:308a\:7cbe\:5ea6\:306f\:5909\:308f\:3089\:306a\:3044 *)
$iSWQAImageWidth = 1280;

iSWQANormalizeImageFile[path_String] := Quiet @ Check[
  Module[{img = Import[path]},
    If[ImageQ[img] && First[ImageDimensions[img]] > $iSWQAImageWidth,
      Export[path, ImageResize[img, {$iSWQAImageWidth, Automatic}], "PNG"]];
    path],
  path];

(* \:5225\:30d7\:30ed\:30bb\:30b9\:3067\:6307\:5b9a\:30b9\:30e9\:30a4\:30c9\:3060\:3051\:63cf\:753b\:3059\:308b ("Slides" \:3092\:6e21\:305b\:308b\:306e\:3067 1 \:679a\:3067\:3082\:5b89\:3044) *)
iSWQARenderExternal[deck_String, nums_List, outdir_String] := Module[{r},
  If[$SlideExportExternal === False || TrueQ[$iSWExternalBroken], Return[$Failed]];
  r = iSWExternalExport[deck, "SlideDeckExportImages", outdir,
    "\"Slides\" -> " <> ToString[nums, InputForm]];
  If[r === $Failed && $SlideExportExternal === Automatic, $iSWExternalBroken = True];
  If[MatchQ[r, {__String}], r, $Failed]];

(* \:5fc5\:8981\:306a\:30b9\:30e9\:30a4\:30c9\:306e\:753b\:50cf\:3092\:7528\:610f\:3057\:3066 <\:756a\:53f7 -> \:30d1\:30b9> \:3092\:8fd4\:3059\:3002\:65e2\:306b\:3042\:308b\:3082\:306e\:306f\:4f5c\:3089\:306a\:3044 *)
iSWQAEnsureImages[nb_, deck_, nums_List, digestOf_Association] := Module[
  {dir, want, missing, tmp, files, out = <||>, imgs},
  If[nums === {}, Return[<||>]];
  dir = iSWQAImageDir[deck];
  If[!DirectoryQ[dir], Quiet[CreateDirectory[dir, CreateIntermediateDirectories -> True]]];
  want = Association[Table[
    n -> iSWQAImageFile[deck, n, Lookup[digestOf, n, ""]], {n, nums}]];
  Do[If[FileExistsQ[want[n]], out[n] = want[n]], {n, nums}];
  missing = Select[nums, !KeyExistsQ[out, #] &];
  If[missing === {}, Return[out]];
  iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9\:753b\:50cf\:3092\:7528\:610f\:4e2d (" <> ToString[Length[missing]] <> " \:679a)...",
    "Rendering slide images (" <> ToString[Length[missing]] <> ")..."]];
  tmp = FileNameJoin[{$TemporaryDirectory,
    "slideqa_img_" <> IntegerString[RandomInteger[{10^8, 10^9}]]}];
  files = iSWQARenderExternal[deck, missing, tmp];
  If[MatchQ[files, {__String}] && Length[files] === Length[missing],
    MapThread[Function[{n, f},
      Quiet[CopyFile[f, want[n], OverwriteTarget -> True]];
      If[FileExistsQ[want[n]], out[n] = iSWQANormalizeImageFile[want[n]]]],
      {missing, files}],
    (* \:5225\:30d7\:30ed\:30bb\:30b9\:304c\:4f7f\:3048\:306a\:3044: FE \:5185\:3067\:63cf\:304f (\:679a\:6570\:304c\:5c11\:306a\:3044\:306e\:3067\:8a31\:5bb9) *)
    imgs = Quiet[SlideDeckImages[deck, "Slides" -> missing]];
    If[MatchQ[imgs, {__Image}] && Length[imgs] === Length[missing],
      MapThread[Function[{n, im},
        Quiet[Export[want[n], im, "PNG"]];
        If[FileExistsQ[want[n]], out[n] = iSWQANormalizeImageFile[want[n]]]],
        {missing, imgs}]]];
  Quiet[If[DirectoryQ[tmp], DeleteDirectory[tmp, DeleteContents -> True]]];
  out];

iSWQAAttachAvailableQ[] :=
  Length[DownValues[ClaudeCode`ClaudeAttach]] > 0 &&
  Length[DownValues[ClaudeCode`ClaudeDetach]] > 0;

(* ---- \:6d41\:5100 ---- *)

iSWQAMode[m_] := Which[
  m === 1 || m === "Regenerate" || m === "All" || m === "New", "Regenerate",
  m === 2 || m === "Update" || m === "Refresh", "Update",
  True, "Changed"];

(* \:305d\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:89e6\:308b\:304b\:3002Changed \:306f\:300c\:30bb\:30eb\:304c\:7121\:3044\:300d\:304b\:300c\:30b9\:30e9\:30a4\:30c9\:304c\:5909\:308f\:3063\:305f\:300d\:3060\:3051 *)
iSWQATargetQ[s_Association, mode_String] := Which[
  mode === "Regenerate", True,
  mode === "Update", True,
  True, MemberQ[{"Missing", "Stale"}, Lookup[s, "State", "Missing"]]];

(* \:65e2\:5b58\:306e\:554f\:7b54\:3092 LLM \:306b\:898b\:305b\:308b\:304b\:3002Regenerate \:306f\:6368\:3066\:308b\:3001\:305d\:308c\:4ee5\:5916\:306f\:6d3b\:304b\:3059 *)
iSWQAKeepQ[s_Association, mode_String] :=
  mode =!= "Regenerate" && Lookup[s, "Entries", {}] =!= {};

(* ---- \:30d7\:30ed\:30f3\:30d7\:30c8 ---- *)

iSWQAOutlineText[slides_List] := StringRiffle[
  Table["  " <> ToString[s["Slide"]] <> " " <> iSWQAOneLine[s["Title"]],
    {s, slides}], "\n"];

iSWQAOneLine[s_] := StringTake[
  StringTrim[StringReplace[ToString[s], {"\r\n" -> " ", "\n" -> " "}]], UpTo[60]];

iSWQASlidePrompt[slides_List, s_Association, k_Integer, meta_String,
    mode_String, deckTitle_String, hasImage_, src_String : ""] := Module[{keep, existing},
  keep = iSWQAKeepQ[s, mode];
  existing = If[keep, iSWQAToText[s["Entries"]], ""];
  meta <>
  "\:3042\:306a\:305f\:306f\:7814\:7a76\:767a\:8868\:306e\:8cea\:7591\:5fdc\:7b54\:3092\:6e96\:5099\:3059\:308b\:52a9\:624b\:3067\:3059\:3002\n" <>
  "\:767a\:8868\:300c" <> deckTitle <> "\:300d\:306e " <> ToString[s["Slide"]] <> " \:679a\:76ee\:306b\:3064\:3044\:3066\:3001\:8074\:8846\:304b\:3089\:51fa\:305d\:3046\:306a\:8cea\:554f\:3068\:3001\n" <>
  "\:305d\:306e\:5834\:3067\:8aad\:307f\:4e0a\:3052\:3089\:308c\:308b\:56de\:7b54\:3092\:66f8\:3044\:3066\:304f\:3060\:3055\:3044\:3002\n\n" <>
  "\:767a\:8868\:5168\:4f53\:306e\:6d41\:308c (\:4f4d\:7f6e\:3092\:628a\:63e1\:3059\:308b\:305f\:3081\:306e\:53c2\:8003\:3002\:4ed6\:306e\:679a\:306e\:8cea\:554f\:306f\:4f5c\:3089\:306a\:3044):\n" <>
  iSWQAOutlineText[slides] <> "\n\n" <>
  "=== \:3053\:306e\:30b9\:30e9\:30a4\:30c9 (" <> ToString[s["Slide"]] <> " / " <>
    ToString[Length[slides]] <> ") ===\n" <>
  "\:30bf\:30a4\:30c8\:30eb: " <> iSWQAOneLine[s["Title"]] <> "\n" <>
  StringTake[ToString[s["Text"]], UpTo[2500]] <> "\n" <>
  With[{t = StringTrim[ToString[s["Talk"]]]},
    If[t === "", "", "\n(\:767a\:8868\:539f\:7a3f) " <> StringTake[t, UpTo[1500]] <> "\n"]] <>
  If[StringTrim[src] === "", "",
    "\n(\:5143\:306e\:8cc7\:6599: \:3053\:306e\:679a\:306e\:51fa\:3069\:3053\:308d\:3002\:8ad6\:6587\:306e\:672c\:6587\:3084\:767a\:8868\:306e\:7b4b\:66f8\:304d) " <> StringTake[src, UpTo[2200]] <> "\n"] <>
  If[TrueQ[hasImage],
    "\n\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:63cf\:753b\:3057\:305f\:753b\:50cf\:3092\:6dfb\:4ed8\:3057\:3066\:3044\:307e\:3059\:3002**\:6587\:5b57\:3060\:3051\:3067\:306a\:304f\:3001\:56f3\:30fb\:5199\:771f\:30fb\:8868\:306b\n" <>
    "\:4f55\:304c\:63cf\:304b\:308c\:3066\:3044\:308b\:304b** (\:8ef8\:3068\:5358\:4f4d\:30fb\:7cfb\:5217\:30fb\:50be\:5411\:30fb\:5199\:3063\:3066\:3044\:308b\:3082\:306e\:30fb\:8868\:306e\:9805\:76ee\:3068\:6570\:5024\:30fb\n" <>
    "\:56f3\:4e2d\:306e\:8a18\:53f7\:3084\:6ce8\:8a18) \:3092\:8aad\:307f\:53d6\:308a\:3001\:305d\:3053\:304b\:3089\:51fa\:305d\:3046\:306a\:8cea\:554f\:3068\:56de\:7b54\:3092\:5fc5\:305a 1 \:554f\:4ee5\:4e0a\:542b\:3081\:3066\:304f\:3060\:3055\:3044\:3002\n" <>
    "\:753b\:50cf\:304b\:3089\:8aad\:307f\:53d6\:308c\:306a\:3044\:3053\:3068 (\:6570\:5024\:3092\:63a8\:6e2c\:3059\:308b\:306a\:3069) \:306f\:66f8\:304b\:306a\:3044\:3002\n", ""] <>
  If[existing =!= "",
    "\n=== \:65e2\:5b58\:306e\:60f3\:5b9a\:554f\:7b54 (\:767a\:8868\:8005\:304c\:76ee\:3092\:901a\:3057\:3066\:3044\:307e\:3059) ===\n" <> existing <>
    "\n\:826f\:3044\:3082\:306e\:306f**\:6587\:9762\:3092\:5909\:3048\:305a\:305d\:306e\:307e\:307e\:6b8b\:3057**\:3001\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:5185\:5bb9\:3068\:98df\:3044\:9055\:3046\:3082\:306e\:3060\:3051\:76f4\:3057\:3001\n" <>
    "\:8db3\:308a\:306a\:3044\:89b3\:70b9\:3092\:8db3\:3057\:3066\:304f\:3060\:3055\:3044\:3002\:5168\:554f\:3092\:5225\:306e\:8a00\:3044\:56de\:3057\:306b\:4f5c\:308a\:76f4\:3055\:306a\:3044\:3002\n", ""] <>
  "\n\:8981\:4ef6:\n" <>
  "- \:5168\:90e8\:3067 " <> ToString[k] <> " \:554f\:524d\:5f8c\:3002\:30b9\:30e9\:30a4\:30c9\:306e\:5185\:5bb9\:306b\:5373\:3057\:305f\:3001\:5177\:4f53\:7684\:3067\:77ed\:3044\:8cea\:554f\:306b\:3059\:308b\:3002\n" <>
  "- \:300c\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:3064\:3044\:3066\:6559\:3048\:3066\:300d\:306e\:3088\:3046\:306a\:6f20\:7136\:3068\:3057\:305f\:8cea\:554f\:306f\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:56de\:7b54\:306f\:30b9\:30e9\:30a4\:30c9\:30fb\:539f\:7a3f" <> If[TrueQ[hasImage], "\:30fb\:6dfb\:4ed8\:753b\:50cf", ""] <> If[StringTrim[src] === "", "", "\:30fb\:5143\:306e\:8cc7\:6599"] <>
    "\:306b\:3042\:308b\:3053\:3068\:3060\:3051\:3067\:66f8\:304f\:3002\:7121\:3044\:4e8b\:5b9f\:30fb\:6570\:5024\:30fb\:5f15\:7528\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:56de\:7b54\:306f\:8a71\:3057\:8a00\:8449\:3067 2\:301c4 \:6587\:3002\:305d\:306e\:307e\:307e\:8aad\:307f\:4e0a\:3052\:3089\:308c\:308b\:9577\:3055\:306b\:3059\:308b\:3002\:8a18\:53f7\:5217\:30fbURL \:306e\:8aad\:307f\:4e0a\:3052\:3092\:5165\:308c\:306a\:3044\:3002\n" <>
  "- \:8cc7\:6599\:304b\:3089\:7b54\:3048\:3089\:308c\:306a\:3044\:8cea\:554f\:306f\:3001A: \:306b\:300c\:8cc7\:6599\:306b\:306f\:3042\:308a\:307e\:305b\:3093\:300d\:3068\:66f8\:304f\:306e\:3067\:306f\:306a\:304f\:3001\:305d\:306e\:8cea\:554f\:81ea\:4f53\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:65e5\:672c\:8a9e\:3067\:66f8\:304f\:3002\n\n" <>
  "\:51fa\:529b\:306f\:6b21\:306e\:66f8\:5f0f\:3060\:3051\:3002\:524d\:7f6e\:304d\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:30fb\:898b\:51fa\:3057\:30fb\:756a\:53f7\:3092\:4e00\:5207\:51fa\:529b\:3057\:306a\:3044\:3002\n" <>
  "Q: \:8cea\:554f\n" <>
  "A: \:56de\:7b54\n" <>
  "Q: \:8cea\:554f\n" <>
  "A: \:56de\:7b54\n"];

(* ---- \:5fdc\:7b54 -> \:30bb\:30eb ---- *)

iSWQAStripFences[resp_String] := StringRiffle[
  Select[StringSplit[StringReplace[resp, "\r\n" -> "\n"], "\n"],
    !StringStartsQ[StringTrim[#], "```"] &], "\n"];

iSWQAErrorRespQ[resp_] := !StringQ[resp] ||
  StringStartsQ[resp, "Error"] || StringStartsQ[resp, "[ERROR]"] ||
  StringLength[StringTrim[resp]] < 8;

(* \:30b9\:30e9\:30a4\:30c9 n \:306e\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092\:5dee\:3057\:66ff\:3048\:308b (\:7121\:3051\:308c\:3070\:672b\:5c3e\:306b\:8db3\:3059)\:3002
   \:672b\:5c3e\:304b\:3089\:9806\:306b\:89e6\:308b\:306e\:3067\:3001\:524d\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:30bb\:30eb\:4f4d\:7f6e\:306f\:305a\:308c\:306a\:3044 *)
iSWQAWriteCell[nb_NotebookObject, n_Integer, text_String] := Module[
  {ranges, cells, styles, idx},
  ranges = iSWSlideRanges[nb];
  If[!(1 <= n <= Length[ranges]), Return[$Failed]];
  cells = Cells[nb]; styles = iSWCellStyles[nb];
  idx = SelectFirst[Range[ranges[[n, 1]], ranges[[n, 2]]],
    MemberQ[Flatten[{styles[[#]]}], "SlideQA"] &, None];
  If[idx === None,
    SelectionMove[cells[[ranges[[n, 2]]]], After, Cell];
    NotebookWrite[nb, Cell[text, "SlideQA"]],
    SelectionMove[cells[[idx]], All, Cell];
    NotebookWrite[nb, Cell[text, "SlideQA"], All]];
  n];

iSWQASlideHasCellQ[nb_NotebookObject] := Module[{ranges, styles},
  ranges = iSWSlideRanges[nb]; styles = iSWCellStyles[nb];
  Association[Table[
    i -> AnyTrue[Range[ranges[[i, 1]], ranges[[i, 2]]],
      MemberQ[Flatten[{styles[[#]]}], "SlideQA"] &],
    {i, Length[ranges]}]]];

iSWQAApplyOne[nb_, n_Integer, resp_, digest_] := Module[{entries, txt},
  If[iSWQAErrorRespQ[resp], Return[$Failed]];
  entries = iSWQAParse[iSWQAStripFences[resp]];
  If[entries === {}, Return[$Failed]];
  txt = iSWQAWithMarker[iSWQAToText[entries], digest];
  If[StringTrim[txt] === "", Return[$Failed]];
  iSWQAWriteCell[nb, n, txt]];

(* ---- 1 \:679a\:305a\:3064\:9806\:306b (\:753b\:50cf\:3092\:6dfb\:4ed8\:3059\:308b\:306e\:3067 1 \:679a 1 \:30ea\:30af\:30a8\:30b9\:30c8) ---- *)

$iSWQARun = <|"OK" -> 0, "NG" -> 0, "New" -> 0, "Updated" -> 0|>;
$iSWQABusy = False;
$iSWQABusySince = 0.;
(* \:9014\:4e2d\:3067 callback \:304c\:623b\:3089\:306a\:304b\:3063\:305f\:3068\:304d\:306b\:30dc\:30bf\:30f3\:304c\:6c38\:4e45\:306b\:6b7b\:306a\:306a\:3044\:3088\:3046\:3001
   \:53e4\:3044 busy \:306f\:7121\:8996\:3059\:308b (1 \:679a\:6570\:5341\:79d2\:3001\:5168\:679a\:3067\:3082 30 \:5206\:306f\:8d85\:3048\:306a\:3044) *)
$iSWQABusyMaxSeconds = 1800.;

iSWQABusyQ[] := TrueQ[$iSWQABusy] &&
  (AbsoluteTime[] - $iSWQABusySince) < $iSWQABusyMaxSeconds;

iSWQAKGNote[lang_String] := With[{h = Lookup[$iSWQARun, "KG", None]},
  If[AssociationQ[h] && Lookup[h, "Status", ""] === "Saved",
    If[lang === "ja", " (\:77e5\:8b58\:30b0\:30e9\:30d5\:306b " <> ToString[h["Nodes"]] <> " \:30ce\:30fc\:30c9\:5206\:3092\:4fdd\:5b58\:3002\:751f\:6210\:3057\:76f4\:3057\:3066\:3082\:6b8b\:308a\:307e\:3059)",
      " (saved " <> ToString[h["Nodes"]] <> " nodes to the knowledge graph; kept when regenerating)"], ""]];
iSWQAChain[nb_, plan_List, idx_Integer, ctx_Association] :=
  If[idx > Length[plan],
    (* KG \:304b\:3089\:4f5c\:3063\:305f\:679a\:306e\:554f\:7b54\:306f KG \:306e\:30ce\:30fc\:30c9\:306b\:3082\:4fdd\:5b58\:3059\:308b (\:751f\:6210\:3057\:76f4\:3057\:3066\:3082\:6d88\:3048\:306a\:3044) *)
    If[StringQ[Lookup[ctx, "Graph", None]] && Head[nb] === NotebookObject,
      $iSWQARun["KG"] = Quiet @ Check[iSWKGHarvestQA[nb, ctx["Graph"]], None]];
    iSWStatus[nb, iSL[
      "\:8cea\:7591\:5fdc\:7b54: \:65b0\:898f " <> ToString[$iSWQARun["New"]] <> " \:679a / \:66f4\:65b0 " <>
        ToString[$iSWQARun["Updated"]] <> " \:679a" <>
        If[$iSWQARun["NG"] > 0, " (\:5931\:6557 " <> ToString[$iSWQARun["NG"]] <> ")", ""] <>
        "\:3002\:5185\:5bb9\:3092\:78ba\:304b\:3081\:3066\:304b\:3089\:300c\:767b\:9332\:300d\:3057\:3066\:304f\:3060\:3055\:3044" <> iSWQAKGNote["ja"],
      "QA: " <> ToString[$iSWQARun["New"]] <> " new / " <>
        ToString[$iSWQARun["Updated"]] <> " updated" <>
        If[$iSWQARun["NG"] > 0, " (" <> ToString[$iSWQARun["NG"]] <> " failed)", ""] <>
        ". Review, then Register." <> iSWQAKGNote["en"]]];
    $iSWQABusy = False;
    iSWStatusClearLater[nb],
    iSWQARunOne[nb, plan, idx, ctx]];

iSWQARunOne[nb_, plan_List, idx_Integer, ctx_Association] := Module[
  {item, rec, prompt, img, attached = False},
  item = plan[[idx]];
  iSWStatus[nb, iSL["\:60f3\:5b9a\:554f\:7b54\:3092\:751f\:6210\:4e2d " <> ToString[idx] <> "/" <> ToString[Length[plan]] <>
    " (\:30b9\:30e9\:30a4\:30c9 " <> ToString[item["Slide"]] <> ")...",
    "Generating Q&A " <> ToString[idx] <> "/" <> ToString[Length[plan]] <>
    " (slide " <> ToString[item["Slide"]] <> ")..."]];
  img = Lookup[item, "Image", None];
  If[StringQ[img] && FileExistsQ[img] && iSWQAAttachAvailableQ[],
    attached = TrueQ[Quiet[Check[ClaudeCode`ClaudeAttach[img]; True, False]]]];
  rec = SelectFirst[ctx["Slides"], #["Slide"] === item["Slide"] &, None];
  If[! AssociationQ[rec],
    $iSWQARun["NG"] = $iSWQARun["NG"] + 1;
    Return[iSWQAChain[nb, plan, idx + 1, ctx]]];
  prompt = iSWQASlidePrompt[ctx["Slides"], rec, ctx["K"], ctx["Meta"],
    ctx["Mode"], ctx["Title"], attached, Lookup[Lookup[ctx, "Sources", <||>], item["Slide"], ""]];
  With[{n2 = nb, p = plan, i2 = idx, c = ctx, n = item["Slide"],
        d = Lookup[item, "Digest", ""], was = Lookup[item, "Existed", False],
        im = img, att = attached},
    NBAccess`$NBLLMQueryFunc[prompt,
      Function[resp,
        If[att, Quiet[ClaudeCode`ClaudeDetach[im]]];
        If[iSWQAApplyOne[n2, n, resp, d] === $Failed,
          $iSWQARun["NG"] = $iSWQARun["NG"] + 1,
          $iSWQARun["OK"] = $iSWQARun["OK"] + 1;
          If[TrueQ[was], $iSWQARun["Updated"] = $iSWQARun["Updated"] + 1,
            $iSWQARun["New"] = $iSWQARun["New"] + 1]];
        iSWQAChain[n2, p, i2 + 1, c]],
      n2, Fallback -> iSWFallback[],
      Sequence @@ If[NumericQ[Lookup[c, "PL", None]], {PrivacyLevel -> c["PL"]}, {}]]];
  Null];

(* ---- \:5165\:53e3 ---- *)

Options[SlideQAGenerate] = {"Mode" -> Automatic, "QuestionsPerSlide" -> Automatic,
  "Vision" -> Automatic, "Slides" -> All};

SlideQAGenerate[opts : OptionsPattern[]] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQAGenerate[nb, opts]]];

SlideQAGenerate[nb_NotebookObject, OptionsPattern[]] := Module[
  {k, src, meta, mode, slides, targets, sel, deck, visionQ, images, plan,
   digestOf, title, kgq},
  If[!iSWRequireLLM[], Return[$Failed]];
  (* \:9032\:884c\:4e2d\:306e\:751f\:6210\:304c\:3042\:308b\:3068\:30ab\:30a6\:30f3\:30bf\:3082\:66f8\:304d\:8fbc\:307f\:5148\:3082\:6df7\:3056\:308b *)
  If[iSWQABusyQ[],
    iSWStatus[nb, iSL["\:60f3\:5b9a\:554f\:7b54\:3092\:751f\:6210\:4e2d\:3067\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044",
      "A Q&A generation run is already in progress"]];
    iSWStatusClearLater[nb];
    Return[<|"Status" -> "Busy"|>]];
  mode = iSWQAMode[OptionValue["Mode"]];
  k = OptionValue["QuestionsPerSlide"];
  If[k === Automatic, k = $SlideQAPerSlide];
  If[!IntegerQ[k] || k < 1, k = 3];
  src = iSWDeckSource[nb];
  slides = iSWQASlides[src];
  If[slides === $Failed,
    iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093", "No slides found"]];
    iSWStatusClearLater[nb];
    Return[$Failed]];
  targets = Select[slides, iSWQATargetQ[#, mode] &];
  sel = OptionValue["Slides"];
  If[ListQ[sel], targets = Select[targets, MemberQ[sel, #["Slide"]] &]];
  If[targets === {},
    iSWStatus[nb, iSL["\:66f4\:65b0\:304c\:5fc5\:8981\:306a\:30b9\:30e9\:30a4\:30c9\:306f\:3042\:308a\:307e\:305b\:3093 (\:5168\:90e8\:4f5c\:308a\:76f4\:3059\:306a\:3089 SlideQAGenerateAll[])",
      "Nothing to update (use SlideQAGenerateAll[] to redo everything)"]];
    iSWStatusClearLater[nb];
    Return[<|"Status" -> "UpToDate", "Mode" -> mode, "Slides" -> 0|>]];

  (* \:753b\:50cf: \:4fdd\:5b58\:6e08\:307f\:30c7\:30c3\:30ad\:3067\:3057\:304b\:63cf\:3051\:306a\:3044 (\:5225\:30d7\:30ed\:30bb\:30b9\:3082\:30d5\:30a1\:30a4\:30eb\:3092\:8aad\:3080) *)
  deck = Quiet[NotebookFileName[nb]];
  visionQ = Replace[OptionValue["Vision"], Automatic :> TrueQ[$SlideQAVision]];
  images = <||>;
  digestOf = Association[Table[s["Slide"] -> s["Digest"], {s, slides}]];
  If[TrueQ[visionQ] && StringQ[deck] && FileExistsQ[deck] && !iSWUnsavedQ[nb] &&
      iSWQAAttachAvailableQ[],
    images = iSWQAEnsureImages[nb, deck,
      Lookup[Select[targets, TrueQ[#["Visual"]] &], "Slide", {}], digestOf]];

  title = With[{m = SlideTalkMeta[nb]},
    With[{t = Lookup[m, "Title", ""]},
      If[StringQ[t] && StringTrim[t] =!= "", t, Last[iSWDeckBaseName[nb]]]]];
  meta = iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb];
  plan = Table[
    <|"Slide" -> s["Slide"], "Digest" -> s["Digest"],
      "Existed" -> (s["Entries"] =!= {}),
      "Image" -> Lookup[images, s["Slide"], None]|>,
    {s, targets}];
  $iSWQARun = <|"OK" -> 0, "NG" -> 0, "New" -> 0, "Updated" -> 0|>;
  $iSWQABusy = True; $iSWQABusySince = AbsoluteTime[];
  (* KG \:304b\:3089\:4f5c\:3063\:305f\:679a: \:5143\:306e\:8cc7\:6599 (\:8ad6\:6587\:306e\:672c\:6587\:30fb\:7b4b\:66f8\:304d) \:3092\:6dfb\:3048\:3001\:554f\:7b54\:306f KG \:306b\:3082\:4fdd\:5b58\:3059\:308b *)
  kgq = Quiet @ Check[iSWQAKGSources[nb], <|"Graph" -> None, "Sources" -> <||>, "PL" -> None|>];
  If[! AssociationQ[kgq], kgq = <|"Graph" -> None, "Sources" -> <||>, "PL" -> None|>];
  iSWQAChain[nb, plan, 1,
    <|"Slides" -> slides, "K" -> k, "Meta" -> meta, "Mode" -> mode,
      "Title" -> title, "Graph" -> kgq["Graph"], "Sources" -> kgq["Sources"], "PL" -> kgq["PL"]|>];
  <|"Status" -> "Submitted", "Mode" -> mode, "Slides" -> Length[plan],
    "WithImages" -> Length[images], "QuestionsPerSlide" -> k|>];

(* \:65e2\:306b\:3042\:308b\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306b\:3001\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:5370\:3060\:3051\:3092\:6253\:3064 (LLM \:3092\:4f7f\:308f\:306a\:3044\:3001
   \:554f\:7b54\:306e\:6587\:9762\:306f 1 \:5b57\:3082\:5909\:3048\:306a\:3044)\:3002\:30de\:30fc\:30ab\:30fc\:306e\:7121\:3044\:65e7\:3044\:30c7\:30c3\:30ad\:3092\:300cQA \:751f\:6210\:300d(\:5909\:66f4\:5206\:306e\:307f)
   \:306b\:4e57\:305b\:308b\:305f\:3081\:306e\:571f\:53f0\:3002\:4eca\:306e\:4e2d\:8eab\:3092\:300c\:78ba\:8a8d\:6e08\:307f\:300d\:3068\:5ba3\:8a00\:3059\:308b\:64cd\:4f5c\:306a\:306e\:3067\:3001
   \:4e2d\:8eab\:3092\:898b\:3066\:304b\:3089\:4f7f\:3046\:3053\:3068 *)
SlideQAMarkCurrent[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideQAMarkCurrent[nb]]];

SlideQAMarkCurrent[nb_NotebookObject] := Module[{slides, digests, ranges, n = 0},
  slides = iSWQASlides[iSWDeckSource[nb]];
  If[slides === $Failed,
    Return[Failure["SlideQANoDeck",
      <|"MessageTemplate" -> "\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093\:3002"|>]]];
  digests = Lookup[slides, "Digest", {}];
  ranges = iSWSlideRanges[nb];
  If[Length[digests] =!= Length[ranges],
    Return[Failure["SlideQADigestMismatch",
      <|"MessageTemplate" -> "\:30b9\:30e9\:30a4\:30c9\:306e\:30cf\:30c3\:30b7\:30e5\:3092\:53d6\:308c\:307e\:305b\:3093\:3067\:3057\:305f\:3002"|>]]];
  Quiet[SlideEnsureDeckStyles[nb]];
  Do[
    Module[{s = slides[[i]], txt},
      If[s["Entries"] =!= {} && StringQ[digests[[i]]] && digests[[i]] =!= "" &&
          s["Marker"] =!= digests[[i]],
        txt = iSWQAWithMarker[iSWQAStripMarker[s["QAText"]], digests[[i]]];
        If[iSWQAWriteCell[nb, i, txt] =!= $Failed, n++]]],
    {i, Length[ranges], 1, -1}];
  iSWStatus[nb, iSL[ToString[n] <> " \:679a\:306b\:5370\:3092\:6253\:3061\:307e\:3057\:305f (\:554f\:7b54\:306f\:5909\:3048\:3066\:3044\:307e\:305b\:3093)",
    "Marked " <> ToString[n] <> " slide(s) (the Q&A text is unchanged)"]];
  iSWStatusClearLater[nb];
  <|"Status" -> "OK", "Marked" -> n|>];

(* 1: \:3059\:3079\:3066\:65b0\:898f\:751f\:6210 (\:65e2\:5b58\:3092\:6368\:3066\:308b) *)
SlideQAGenerateAll[opts : OptionsPattern[SlideQAGenerate]] :=
  With[{nb = iSWNotebook[]},
    If[nb === $Failed, $Failed, SlideQAGenerateAll[nb, opts]]];
SlideQAGenerateAll[nb_NotebookObject, opts : OptionsPattern[SlideQAGenerate]] :=
  SlideQAGenerate[nb, "Mode" -> "Regenerate",
    Sequence @@ FilterRules[{opts}, Except["Mode"]]];

(* 2: \:3059\:3079\:3066\:898b\:76f4\:3059 (\:65e2\:5b58\:3092\:6d3b\:304b\:3059) *)
SlideQAUpdateAll[opts : OptionsPattern[SlideQAGenerate]] :=
  With[{nb = iSWNotebook[]},
    If[nb === $Failed, $Failed, SlideQAUpdateAll[nb, opts]]];
SlideQAUpdateAll[nb_NotebookObject, opts : OptionsPattern[SlideQAGenerate]] :=
  SlideQAGenerate[nb, "Mode" -> "Update",
    Sequence @@ FilterRules[{opts}, Except["Mode"]]];

(* ===================== \:30c7\:30c3\:30ad\:306e\:5909\:66f4\:691c\:51fa (\:767b\:9332\:306e\:7a7a\:632f\:308a\:3092\:907f\:3051\:308b) =====================
   \:300c\:767b\:9332\:300d\:306f\:767b\:9332\:7c3f\:30fbQA \:30d1\:30c3\:30af\:30fbmp4 \:306e 3 \:3064\:3092\:89e6\:308b\:3002\:3069\:308c\:3082\:4e2d\:8eab\:304c\:5909\:308f\:3063\:3066\:3044\:306a\:3051\:308c\:3070
   \:3084\:308a\:76f4\:3059\:610f\:5473\:304c\:7121\:304f\:3001mp4 \:306f\:7279\:306b\:9ad8\:3044 (\:5168\:30b9\:30e9\:30a4\:30c9\:3092\:30e9\:30b9\:30bf\:30e9\:30a4\:30ba\:3059\:308b)\:3002

   \:4f55\:3092\:898b\:3066\:300c\:5909\:308f\:3063\:305f\:300d\:3068\:8a00\:3046\:304b:
     - \:30d5\:30a1\:30a4\:30eb\:65e5\:4ed8\:3067\:306f\:306a\:3044\:3002\:30c8\:30fc\:30af\:30bb\:30eb\:3084\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092\:76f4\:3057\:305f\:3060\:3051\:3067 .nb \:306f\:65b0\:3057\:304f\:306a\:308b\:304c\:3001
       \:30b9\:30e9\:30a4\:30c9\:306e\:898b\:305f\:76ee\:306f 1 \:30d4\:30af\:30bb\:30eb\:3082\:5909\:308f\:3089\:306a\:3044\:3002
     - \:30b9\:30e9\:30a4\:30c9\:3068\:3057\:3066\:63cf\:304b\:308c\:308b\:30bb\:30eb\:3060\:3051\:3092\:3001\:9806\:756a\:3069\:304a\:308a\:306b\:4e26\:3079\:305f\:3082\:306e\:306e\:30cf\:30c3\:30b7\:30e5\:3002
       \:4e26\:3079\:66ff\:3048\:30fb\:633f\:5165\:30fb\:524a\:9664\:306f\:5217\:304c\:5909\:308f\:308b\:306e\:3067\:5fc5\:305a\:691c\:51fa\:3055\:308c\:308b\:3002
     - CellChangeTimes / CellID / ExpressionUUID / CellLabel \:306f\:4e2d\:8eab\:3067\:306f\:306a\:3044\:306e\:3067\:843d\:3068\:3059
       (\:89e6\:3063\:305f\:3060\:3051\:3067\:4f5c\:308a\:76f4\:3057\:306b\:306a\:308b\:306e\:3092\:9632\:3050)\:3002
   \:8a18\:9332\:306f <deck>_state.json\:3002\:7121\:3051\:308c\:3070 (\:65e7\:30c7\:30c3\:30ad) \:5f93\:6765\:3069\:304a\:308a\:30d5\:30a1\:30a4\:30eb\:65e5\:4ed8\:3067\:5224\:65ad\:3059\:308b\:3002
   ============================================================================= *)

$iSWDigestDropOptions = {CellChangeTimes, CellID, ExpressionUUID, CellLabel};

iSWDigestCell[c_Cell] := DeleteCases[c,
  Rule[Alternatives @@ $iSWDigestDropOptions, _], {1}];
iSWDigestCell[c_] := c;

(* \:30b9\:30e9\:30a4\:30c9\:3068\:3057\:3066\:63cf\:304b\:308c\:308b\:30bb\:30eb\:304b\:3002\:30e1\:30bf\:30bb\:30eb (\:30e1\:30e2\:30fb\:6307\:793a\:30fb\:30c8\:30fc\:30af\:30fb\:8cea\:7591\:5fdc\:7b54\:2026) \:3068
   \:97f3\:58f0\:30bb\:30eb\:306f SlideShow \:3067\:6d88\:3048\:308b\:306e\:3067\:3001\:5909\:308f\:3063\:3066\:3082 mp4 \:306f\:5909\:308f\:3089\:306a\:3044 *)
iSWRenderedCellQ[c_Cell] := !iMetaStyleCellQ[c] && !iAudioCellQ[c];
iSWRenderedCellQ[_] := True;

iSWSlideDigest[cells_List] :=
  Hash[iSWDigestCell /@ Select[cells, iSWRenderedCellQ], "SHA256", "HexString"];

$iSWDeckDigestCache = <||>;

iSWDeckSlideDigests[source_] := Module[{nb, data},
  nb = iAsNotebook[source];
  If[Head[nb] =!= Notebook, Return[$Failed]];
  data = iSlideSplit[nb, iFlattenVisibleCells];
  If[!AssociationQ[data], Return[$Failed]];
  iSWSlideDigest /@ Lookup[data, "Slides", {}]];

(* \:4fdd\:5b58\:6e08\:307f path \:306f\:30d5\:30a1\:30a4\:30eb\:65e5\:4ed8\:3067\:30ad\:30e3\:30c3\:30b7\:30e5\:3059\:308b (\:767b\:9332\:306e\:305f\:3073\:306b\:6570\:5341 MB \:3092 Get \:3057\:76f4\:3055\:306a\:3044) *)
iSWDeckSlideDigestsCached[path_String] := Module[{date, entry, ds},
  date = Quiet[FileDate[path]];
  entry = Lookup[$iSWDeckDigestCache, path, None];
  If[AssociationQ[entry] && entry["Date"] === date, Return[entry["Digests"]]];
  ds = iSWDeckSlideDigests[path];
  $iSWDeckDigestCache[path] = <|"Date" -> date, "Digests" -> ds|>;
  ds];

iSWDeckDigest[source_] := Module[{ds},
  ds = If[StringQ[source] && FileExistsQ[source],
    iSWDeckSlideDigestsCached[source], iSWDeckSlideDigests[source]];
  If[ListQ[ds] && ds =!= {}, Hash[ds, "SHA256", "HexString"], $Failed]];

(* \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:4e2d\:8eab\:306e\:30cf\:30c3\:30b7\:30e5\:3002\:3053\:3061\:3089\:306f\:4e26\:3073\:9806\:3064\:304d\:306e\:751f\:30c6\:30ad\:30b9\:30c8\:3067\:5341\:5206 *)
(* \:30de\:30fc\:30ab\:30fc\:884c\:306f\:4e2d\:8eab\:3067\:306f\:306a\:3044\:306e\:3067\:843d\:3068\:3059\:3002\:843d\:3068\:3055\:306a\:3044\:3068\:3001
   \:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:3066 QA \:3092\:4f5c\:308a\:76f4\:3057\:305f\:3068\:304d\:3001\:554f\:7b54\:304c\:540c\:3058\:3067\:3082\:713c\:304d\:76f4\:3057\:306b\:306a\:308b *)
iSWQADigestOf[slides_List] :=
  Hash[Table[{Lookup[s, "Slide", 0], iSWQAStripMarker[ToString[Lookup[s, "QAText", ""]]]},
    {s, Select[slides, AssociationQ]}], "SHA256", "HexString"];

iSWQADigest[source_] := With[{sl = iSWQASlides[source]},
  If[ListQ[sl], iSWQADigestOf[sl], $Failed]];

(* ---- \:8a18\:9332 (<deck>_state.json) ---- *)

iSWDeckStateFile[deck_String] :=
  FileNameJoin[{DirectoryName[deck], FileBaseName[deck] <> "_state.json"}];

iSWDeckStateRead[deck_] := Module[{f},
  If[!StringQ[deck] || deck === "", Return[<||>]];
  f = iSWDeckStateFile[deck];
  If[!FileExistsQ[f], Return[<||>]];
  With[{r = Quiet[Import[f, "RawJSON"]]}, If[AssociationQ[r], r, <||>]]];

iSWDeckStateWrite[deck_, upd_Association] := Module[{f, cur},
  If[!StringQ[deck] || deck === "", Return[$Failed]];
  f = iSWDeckStateFile[deck];
  cur = iSWDeckStateRead[deck];
  Quiet[Check[Export[f,
    Join[cur, upd, <|"UpdatedAtUTC" -> DateString[Now, "ISODateTime"]|>], "RawJSON"],
    $Failed]]];

iSWFileNewerQ[a_, b_] := StringQ[a] && StringQ[b] &&
  With[{da = Quiet[AbsoluteTime[FileDate[a]]], db = Quiet[AbsoluteTime[FileDate[b]]]},
    NumericQ[da] && NumericQ[db] && da > db];

(* mp4 \:3092\:4f5c\:308a\:76f4\:3059\:3079\:304d\:304b\:3002\:5224\:65ad\:3067\:304d\:306a\:3044\:3068\:304d\:3060\:3051\:5f93\:6765\:306e\:30d5\:30a1\:30a4\:30eb\:65e5\:4ed8\:3078\:843d\:3061\:308b *)
iSWVideoStaleQ[deckPath_String, mp4_String] := Module[{rec, cur},
  rec = Lookup[iSWDeckStateRead[deckPath], "VideoSlidesDigest", None];
  cur = Quiet[iSWDeckDigest[deckPath]];
  Which[
    !StringQ[cur], iSWFileNewerQ[deckPath, mp4],
    !StringQ[rec], iSWFileNewerQ[deckPath, mp4],
    True, cur =!= rec]];

iSWRecordVideoDigest[deck_] := Module[{d},
  If[!StringQ[deck] || !FileExistsQ[deck], Return[$Failed]];
  $iSWDeckDigestCache = KeyDrop[$iSWDeckDigestCache, deck];
  d = Quiet[iSWDeckDigest[deck]];
  If[StringQ[d], iSWDeckStateWrite[deck, <|"VideoSlidesDigest" -> d|>], $Failed]];

(* \:65e2\:5b58\:30c7\:30c3\:30ad\:306e\:79fb\:884c\:7528\:3002\:8a18\:9332\:304c\:7121\:3044\:3068\:65e5\:4ed8\:6bd4\:8f03\:3078\:843d\:3061\:3001\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092\:8db3\:3057\:305f\:3060\:3051\:3067
   1 \:56de\:3060\:3051 mp4 \:3092\:4f5c\:308a\:76f4\:3059\:3053\:3068\:306b\:306a\:308b\:3002\:898b\:305f\:76ee\:304c\:5408\:3063\:3066\:3044\:308b\:306e\:306a\:3089\:3053\:308c\:3067\:9000\:3051\:308b *)
SlideDeckMarkVideoCurrent[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideDeckMarkVideoCurrent[nb]]];

SlideDeckMarkVideoCurrent[nb_NotebookObject] := With[{fn = Quiet[NotebookFileName[nb]]},
  If[StringQ[fn], SlideDeckMarkVideoCurrent[fn],
    Failure["SlideDeckUnsaved",
      <|"MessageTemplate" -> "\:30c7\:30c3\:30ad\:304c\:672a\:4fdd\:5b58\:3067\:3059\:3002"|>]]];

SlideDeckMarkVideoCurrent[deck_String] := Module[{mp4, d},
  mp4 = FileNameJoin[{DirectoryName[deck], FileBaseName[deck] <> ".mp4"}];
  If[! FileExistsQ[mp4],
    Return[Failure["SlideVideoMissing",
      <|"MessageTemplate" -> "mp4 \:304c\:3042\:308a\:307e\:305b\:3093: " <> mp4, "File" -> mp4|>]]];
  d = iSWRecordVideoDigest[deck];
  If[! StringQ[Lookup[iSWDeckStateRead[deck], "VideoSlidesDigest", None]],
    Return[Failure["SlideDigestFailed",
      <|"MessageTemplate" -> "\:30b9\:30e9\:30a4\:30c9\:306e\:30cf\:30c3\:30b7\:30e5\:3092\:53d6\:308c\:307e\:305b\:3093\:3067\:3057\:305f\:3002"|>]]];
  <|"Status" -> "OK", "Deck" -> deck, "VideoFile" -> mp4,
    "VideoSlidesDigest" -> Lookup[iSWDeckStateRead[deck], "VideoSlidesDigest", None]|>];

(* \:4f55\:304c\:5909\:308f\:3063\:3066\:3044\:308b\:304b\:3092\:898b\:308b (\:300c\:767b\:9332\:3057\:3066\:3082\:4f55\:3082\:8d77\:304d\:306a\:3044\:300d\:3068\:304d\:306e\:5207\:308a\:5206\:3051) *)
SlideDeckChangeStatus[] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideDeckChangeStatus[nb]]];

SlideDeckChangeStatus[nb_NotebookObject] := With[{fn = Quiet[NotebookFileName[nb]]},
  If[StringQ[fn], SlideDeckChangeStatus[fn],
    Failure["SlideDeckUnsaved",
      <|"MessageTemplate" -> "\:30c7\:30c3\:30ad\:304c\:672a\:4fdd\:5b58\:3067\:3059\:3002"|>]]];

SlideDeckChangeStatus[deck_String] := Module[{st, cur, qa, mp4},
  st = iSWDeckStateRead[deck];
  cur = Quiet[iSWDeckDigest[deck]];
  qa = Quiet[iSWQADigest[deck]];
  mp4 = FileNameJoin[{DirectoryName[deck], FileBaseName[deck] <> ".mp4"}];
  <|"Deck" -> deck, "StateFile" -> iSWDeckStateFile[deck],
    "SlidesDigest" -> cur,
    "VideoSlidesDigest" -> Lookup[st, "VideoSlidesDigest", None],
    "VideoStale" -> If[FileExistsQ[mp4], iSWVideoStaleQ[deck, mp4], True],
    "VideoFile" -> If[FileExistsQ[mp4], mp4, None],
    "QADigest" -> qa, "QARegistered" -> Lookup[st, "QADigest", None],
    "QAStale" -> (StringQ[qa] && qa =!= Lookup[st, "QADigest", None]),
    "UpdatedAtUTC" -> Lookup[st, "UpdatedAtUTC", None]|>];

(* ---- \:300c\:767b\:9332\:300d\:306e QA \:6bb5 ---- *)

(* \:5909\:308f\:3063\:3066\:3044\:306a\:3051\:308c\:3070\:713c\:304d\:76f4\:3055\:306a\:3044\:3002QA \:30d1\:30c3\:30af\:306e\:4f5c\:6210\:306f KB \:53d6\:308a\:8fbc\:307f\:3092\:4f34\:3046\:306e\:3067\:5b89\:304f\:306f\:306a\:3044 *)
(* deck = \:30d1\:30c3\:30af\:3068\:8a18\:9332\:306e\:7f6e\:304d\:5834\:6240\:3001src = \:4eca\:8aad\:3080\:3079\:304d\:4e2d\:8eab\:3002
   \:672a\:4fdd\:5b58\:306e\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:3067\:306f src \:306e\:307b\:3046\:304c\:65b0\:3057\:3044 (\:767b\:9332\:7c3f\:3082\:305d\:3061\:3089\:3092\:898b\:3066\:3044\:308b) *)
iSWRegisterQAStep[res_, deck_, qaOpt_] := iSWRegisterQAStep[res, deck, deck, qaOpt];

iSWRegisterQAStep[res_, deck_, srcIn_, qaOpt_] := Module[{slides, digest, st, out, src},
  If[!AssociationQ[res] || qaOpt === False, Return[res]];
  If[!StringQ[deck] || deck === "" || !FileExistsQ[deck], Return[res]];
  src = If[srcIn === None || srcIn === "", deck, srcIn];
  If[!iSWQALayerQ[],
    Return[If[qaOpt === True,
      Append[res, "QA" -> Failure["SlideQALayerMissing",
        <|"MessageTemplate" -> "SourceVault_talkqa.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093\:3002"|>]],
      res]]];
  slides = iSWQASlides[src];
  If[slides === $Failed, Return[res]];
  slides = Select[slides, #["Entries"] =!= {} &];
  If[slides === {},
    Return[If[qaOpt === True,
      Append[res, "QA" -> <|"Status" -> "NoCells", "Questions" -> 0|>], res]]];
  digest = iSWQADigestOf[slides];
  st = iSWDeckStateRead[deck];
  If[qaOpt =!= True && StringQ[digest] && digest === Lookup[st, "QADigest", None],
    Return[Append[res, "QA" -> <|"Status" -> "Unchanged",
      "Questions" -> Total[Length[#["Entries"]] & /@ slides]|>]]];
  out = iSWQABuildFrom[deck, slides, Automatic, True, True, False];
  Append[res, "QA" -> out]];

(* ===================== Sliden mp4 \:306e\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9 (sftp, v1.18) =====================
   \:300c\:767b\:9332\:300d= \:767b\:9332\:7c3f\:3078\:306e\:767b\:9332 + \:52d5\:753b (<deck>.mp4) \:306e web \:30b5\:30fc\:30d0\:3078\:306e\:914d\:7f6e\:3002\:5b9b\:5148\:306f
   \:6307\:793a\:30bb\:30eb\:306e  Host: sftp://user@host/home/user/www/cn  (Upload: / UploadURL: \:540c\:7fa9)
   \:3067\:3001\:914d\:4fe1 URL (SlideURL) \:306e\:672b\:5c3e\:30d5\:30a1\:30a4\:30eb\:540d\:3092\:305d\:306e dir \:306b\:7f6e\:304f\:3002\:30d1\:30b9\:30ef\:30fc\:30c9\:306f
   NBAccess \:7ba1\:8f44\:306e SystemCredential \:306b\:7f6e\:304f (\:540d\:524d = sftp://user@host\:3001
   SlideUploadCredential \:3067\:4fdd\:5b58\:3002\:5024\:306f\:3053\:306e\:5c64\:306e\:5916\:3078\:51fa\:3055\:306a\:3044)\:3002
   \:8ee2\:9001\:624b\:6bb5:
     "Native" = CopyFile -> RemoteFile (WL \:7d44\:8fbc\:307f\:30022026-09-03 \:5b9f\:6e2c: \:30b5\:30fc\:30d0\:3078\:5230\:9054\:3057
               \:8aa4\:30d1\:30b9\:30ef\:30fc\:30c9\:3067 URL::invAuth \:304c\:8fd4\:308b)
     "curl"   = Git for Windows \:540c\:68b1\:306e sftp \:5bfe\:5fdc curl (System32 \:306e curl \:306f sftp \:975e\:5bfe\:5fdc\:3002
               libssh2 \:304c ed25519 \:306e known_hosts \:3092\:6271\:3048\:305a\:5931\:6557\:3059\:308b\:305f\:3081 -k \:3067\:65e2\:77e5\:30db\:30b9\:30c8
               \:7167\:5408\:3092\:7701\:304f)
   Windows OpenSSH \:306e sftp.exe \:306f\:30b3\:30f3\:30bd\:30fc\:30eb\:7121\:3057\:3060\:3068 password \:8a8d\:8a3c\:3092\:8a66\:307f\:306a\:3044
   (SSH_ASKPASS_REQUIRE=force \:3067\:3082 "we did not send a packet, disable method"\:3001\:5b9f\:6e2c)
   \:306e\:3067\:4f7f\:308f\:306a\:3044\:3002\:8ee2\:9001\:5f8c\:306f SlideURL \:306e HEAD (200 + Content-Length \:4e00\:81f4) \:3067\:914d\:4fe1\:3092\:78ba\:8a8d\:3057\:3001
   \:8ee2\:9001\:524d\:306b\:540c\:3058 HEAD \:3067\:300c\:65e2\:306b\:540c\:30b5\:30a4\:30ba\:300d\:306a\:3089\:9001\:3089\:306a\:3044 ("Force"->True \:3067\:5f37\:5236)\:3002 *)

If[!ValueQ[$SlideUploadMethod], $SlideUploadMethod = Automatic];

iSWUploadParseURL[url_String] := Module[{p, segs, trailing, path},
  p = Quiet[Check[URLParse[StringTrim[url]], $Failed]];
  If[!AssociationQ[p], Return[$Failed]];
  If[ToLowerCase[ToString[Lookup[p, "Scheme", ""]]] =!= "sftp", Return[$Failed]];
  If[!StringQ[Lookup[p, "Domain", None]] || p["Domain"] === "", Return[$Failed]];
  segs = Replace[Lookup[p, "Path", {}],
    {s_String :> StringSplit[s, "/", All], Except[_List] -> {}}];
  trailing = segs =!= {} && Last[segs] === "";
  segs = Select[segs, StringQ[#] && # =!= "" &];
  path = "/" <> StringRiffle[segs, "/"];
  <|"User" -> Replace[Lookup[p, "User", None], Except[_String] -> None],
    "Host" -> p["Domain"],
    "Port" -> Replace[Lookup[p, "Port", None], Except[_Integer] -> None],
    "Path" -> path,
    "IsFile" -> (!trailing && segs =!= {} &&
      StringEndsQ[ToLowerCase[Last[segs]], ".mp4"])|>];
iSWUploadParseURL[_] := $Failed;

iSWUploadHostPort[p_Association] :=
  p["Host"] <> If[IntegerQ[p["Port"]], ":" <> ToString[p["Port"]], ""];

iSWUploadCredentialName[p_Association] :=
  "sftp://" <> ToString[p["User"]] <> "@" <> iSWUploadHostPort[p];

iSWUploadRemotePath[p_Association, fileName_String] := Which[
  TrueQ[p["IsFile"]], p["Path"],
  p["Path"] === "/", "/" <> fileName,
  True, p["Path"] <> "/" <> fileName];

iSWUploadRemoteURL[p_Association, fileName_String] :=
  "sftp://" <> iSWUploadHostPort[p] <> iSWUploadRemotePath[p, fileName];

(* \:914d\:4fe1 URL \:306e\:672b\:5c3e\:30d5\:30a1\:30a4\:30eb\:540d (URLParse \:306e Path \:306f\:30bb\:30b0\:30e1\:30f3\:30c8\:306e\:30ea\:30b9\:30c8\:3067\:8fd4\:308b) *)
iSWURLFileName[url_String] := Module[{p, segs},
  p = Quiet[Check[URLParse[url], $Failed]];
  If[!AssociationQ[p], Return[""]];
  segs = Replace[Lookup[p, "Path", {}],
    {s_String :> StringSplit[s, "/", All], Except[_List] -> {}}];
  segs = Select[segs, StringQ[#] && # =!= "" &];
  If[segs === {}, "", Last[segs]]];
iSWURLFileName[_] := "";

(* HEAD -> <|StatusCode, ContentLength, LastModified|> / $Failed *)
iSWURLHead[url_String] := Module[{r, headers, lookup},
  r = Quiet[Check[URLRead[url, Method -> "HEAD", TimeConstraint -> 20], $Failed]];
  If[Head[r] =!= HTTPResponse, Return[$Failed]];
  headers = Replace[Quiet[r["Headers"]], Except[_List] -> {}];
  lookup[name_] := FirstCase[headers,
    (k_ -> v_) /; ToLowerCase[ToString[k]] === name :> v, None];
  <|"StatusCode" -> Quiet[r["StatusCode"]],
    "ContentLength" -> With[{v = lookup["content-length"]},
      Which[
        IntegerQ[v], v,
        StringQ[v] && StringMatchQ[StringTrim[v], DigitCharacter ..], FromDigits[StringTrim[v]],
        True, None]],
    "LastModified" -> lookup["last-modified"]|>];
iSWURLHead[_] := $Failed;

iSWFormatBytes[n_Integer] := Which[
  n >= 10^6, ToString[Round[n/10.^6, 0.1]] <> " MB",
  n >= 10^3, ToString[Round[n/10.^3, 0.1]] <> " KB",
  True, ToString[n] <> " B"];
iSWFormatBytes[_] := "";

(* ---- \:8cc7\:683c\:60c5\:5831 (NBAccess \:7d4c\:7531\:306e SystemCredential) ---- *)

iSWCredAvailableQ[] := Length[DownValues[NBAccess`NBGetCredential]] > 0;

iSWCredGet[name_String] := If[!iSWCredAvailableQ[], None,
  With[{v = Quiet[NBAccess`NBGetCredential[name]]},
    If[StringQ[v] && v =!= "", v, None]]];

iSWCredNBAccessFailure[] := Failure["NBAccessUnavailable",
  <|"MessageTemplate" ->
    "NBAccess.wl \:304c\:8aad\:307f\:8fbc\:307e\:308c\:3066\:3044\:307e\:305b\:3093\:3002sftp \:306e\:30d1\:30b9\:30ef\:30fc\:30c9\:306f NBAccess \:7ba1\:8f44\:306e SystemCredential \:306b\:7f6e\:304f\:898f\:7d04\:306e\:305f\:3081\:3001NBAccess \:3092\:30ed\:30fc\:30c9\:3057\:3066\:304b\:3089\:767b\:9332\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>];

(* \:5f15\:6570 -> \:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:5148: sftp:// \:6587\:5b57\:5217\:306f\:305d\:306e\:307e\:307e\:3001nb / .nb path \:306f\:767a\:8868\:30e1\:30bf\:304b\:3089 *)
iSWUploadMetaOf[nb_NotebookObject] := SlideTalkMeta[nb];
iSWUploadMetaOf[path_String] := Module[{e},
  If[!FileExistsQ[path] || ToLowerCase[FileExtension[path]] =!= "nb", Return[<||>]];
  e = Quiet[iGetNotebook[path]];
  If[Head[e] =!= Notebook, Return[<||>]];
  Join[iSWTalkFileMeta[SlideTalkFile[path]], iSWTalkMetaFromNotebookExpr[e],
    iSWDirectiveMeta[e]]];
iSWUploadMetaOf[_] := <||>;

iSWUploadURLOf[src_] := Which[
  StringQ[src] && StringStartsQ[ToLowerCase[StringTrim[src]], "sftp://"], StringTrim[src],
  True, With[{m = iSWUploadMetaOf[src]}, Lookup[m, "UploadURL", ""]]];

iSWUploadURLMissingFailure[] := Failure["SlideUploadURLMissing",
  <|"MessageTemplate" ->
    "\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:5148\:304c\:3042\:308a\:307e\:305b\:3093\:3002\:30c7\:30c3\:30ad\:5148\:982d\:306e\:6307\:793a\:30bb\:30eb (Directive) \:306b  Host: sftp://user@host/path  \:306e\:884c\:3092\:66f8\:3044\:3066\:304f\:3060\:3055\:3044 (Upload: / UploadURL: \:3082\:53ef)\:3002"|>];

iSWUploadURLInvalidFailure[url_] := Failure["SlideUploadURLInvalid",
  <|"MessageTemplate" ->
    "\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:5148\:306f  sftp://user@host/dir  \:306e\:5f62\:306e URL \:306b\:3057\:3066\:304f\:3060\:3055\:3044: " <> ToString[url],
    "UploadURL" -> url|>];

iSWUploadUserMissingFailure[url_] := Failure["SlideUploadUserMissing",
  <|"MessageTemplate" ->
    "\:30e6\:30fc\:30b6\:30fc\:540d\:304c\:3042\:308a\:307e\:305b\:3093\:3002Host: sftp://user@host/path \:306e\:3088\:3046\:306b user@ \:3092\:4ed8\:3051\:3066\:304f\:3060\:3055\:3044: " <> ToString[url],
    "UploadURL" -> url|>];

(* \:89e3\:6c7a\:6e08\:307f (user \:5fc5\:9808) \:306e parse\:3002Failure \:304b\:9023\:60f3 (URL \:30ad\:30fc\:4ed8\:304d) *)
iSWUploadTarget[src_, userOpt_ : Automatic] := Module[{url, p, user},
  url = iSWUploadURLOf[src];
  If[!StringQ[url] || StringTrim[url] === "", Return[iSWUploadURLMissingFailure[]]];
  p = iSWUploadParseURL[url];
  If[p === $Failed, Return[iSWUploadURLInvalidFailure[url]]];
  user = Replace[userOpt, Automatic :> p["User"]];
  If[!StringQ[user] || user === "", Return[iSWUploadUserMissingFailure[url]]];
  p["User"] = user;
  p["URL"] = url;
  p];

SlideUploadCredentialQ[] := SlideUploadCredentialQ[iSWResolveTargetNb[]];
SlideUploadCredentialQ[src_] := Module[{p},
  p = iSWUploadTarget[src];
  If[FailureQ[p] || !iSWCredAvailableQ[], Return[False]];
  TrueQ[Quiet[NBAccess`NBCredentialConfiguredQ[iSWUploadCredentialName[p]]]]];

(* \:30d1\:30b9\:30ef\:30fc\:30c9\:3092\:30c0\:30a4\:30a2\:30ed\:30b0\:3067\:5c0b\:306d\:3066\:4fdd\:5b58 (\:5024\:306f\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306b\:6b8b\:3089\:306a\:3044) *)
SlideUploadCredential[] := SlideUploadCredential[iSWResolveTargetNb[]];
SlideUploadCredential[src_] := Module[{p, dlg},
  p = iSWUploadTarget[src];
  If[FailureQ[p], Return[p]];
  If[!iSWCredAvailableQ[], Return[iSWCredNBAccessFailure[]]];
  If[!TrueQ[$Notebooks],
    Return[Failure["NoFrontEnd",
      <|"MessageTemplate" ->
        "\:30c0\:30a4\:30a2\:30ed\:30b0\:3092\:51fa\:305b\:307e\:305b\:3093\:3002SlideUploadCredential[url, password] \:3067\:4fdd\:5b58\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  dlg = Quiet[AuthenticationDialog[{"Password"}]];
  If[!AssociationQ[dlg] || !StringQ[Lookup[dlg, "Password", None]] ||
      dlg["Password"] === "", Return[$Canceled]];
  SlideUploadCredential[p["URL"], dlg["Password"]]];

SlideUploadCredential[src_, password_String] := Module[{p, name},
  p = iSWUploadTarget[src];
  If[FailureQ[p], Return[p]];
  If[!iSWCredAvailableQ[], Return[iSWCredNBAccessFailure[]]];
  name = iSWUploadCredentialName[p];
  If[!TrueQ[NBAccess`NBSetCredential[name, password]],
    Return[Failure["SlideUploadCredentialStoreFailed",
      <|"MessageTemplate" -> "SystemCredential \:3078\:306e\:4fdd\:5b58\:306b\:5931\:6557\:3057\:307e\:3057\:305f: " <> name,
        "Credential" -> name|>]]];
  <|"Credential" -> name, "Configured" -> True|>];

SlideUploadCredential[src_, None] := Module[{p, name},
  p = iSWUploadTarget[src];
  If[FailureQ[p], Return[p]];
  If[!iSWCredAvailableQ[], Return[iSWCredNBAccessFailure[]]];
  name = iSWUploadCredentialName[p];
  Quiet[NBAccess`NBRemoveCredential[name]];
  <|"Credential" -> name, "Configured" -> False|>];

(* ---- \:8ee2\:9001\:624b\:6bb5 ---- *)

iSWUploadUnavailable[method_String, why_String] := Failure["SlideUploadMethodUnavailable",
  <|"MessageTemplate" -> why, "Class" -> "Unavailable", "Method" -> method|>];

iSWUploadAuthFailure[method_String, p_Association] := Failure["SlideUploadAuthFailed",
  <|"MessageTemplate" ->
    "sftp \:306e\:8a8d\:8a3c\:306b\:5931\:6557\:3057\:307e\:3057\:305f (\:30e6\:30fc\:30b6\:30fc\:540d\:304b\:30d1\:30b9\:30ef\:30fc\:30c9\:304c\:9055\:3044\:307e\:3059): " <>
      iSWUploadCredentialName[p] <> "\:3002SlideUploadCredential[\"" <>
      iSWUploadCredentialName[p] <> "\"] \:3067\:4fdd\:5b58\:3057\:76f4\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
    "Class" -> "Auth", "Method" -> method, "Credential" -> iSWUploadCredentialName[p]|>];

iSWUploadTransferFailure[method_String, remoteURL_String, detail_String] :=
  Failure["SlideUploadFailed",
    <|"MessageTemplate" -> "sftp \:306e\:8ee2\:9001\:306b\:5931\:6557\:3057\:307e\:3057\:305f (" <> method <> "): " <> remoteURL <>
        If[detail === "", "", "\n" <> detail],
      "Class" -> "Transfer", "Method" -> method, "Remote" -> remoteURL|>];

iSWUploadWith["Native", local_String, remoteURL_String, p_Association, pw_String] := Module[
  {res, auth = False},
  res = Quiet[Check[
    Check[CopyFile[local, RemoteFile[remoteURL],
        Authentication -> <|"Username" -> p["User"], "Password" -> pw|>,
        OverwriteTarget -> True],
      (auth = True; $Failed), {URL::invAuth}],
    $Failed]];
  Which[
    auth, iSWUploadAuthFailure["Native", p],
    res === $Failed, iSWUploadTransferFailure["Native", remoteURL,
      "(\"Method\" -> \"curl\" \:3067\:518d\:8a66\:884c\:3059\:308b\:3068 curl \:306e\:8a73\:7d30\:30e1\:30c3\:30bb\:30fc\:30b8\:304c\:5f97\:3089\:308c\:307e\:3059)"],
    True, <|"Status" -> "Uploaded", "Method" -> "Native"|>]];

$iSWCurlPathCache = None;

iSWCurlSftpQ[exe_String] := With[
  {out = Quiet[Check[RunProcess[{exe, "--version"}, "StandardOutput"], ""]]},
  StringQ[out] && StringContainsQ[out, "sftp"]];

iSWCurlPath[] := Module[{cands},
  If[StringQ[$iSWCurlPathCache], Return[$iSWCurlPathCache]];
  If[$iSWCurlPathCache === False, Return[None]];
  cands = Flatten[{
    With[{pf = Environment["ProgramFiles"]},
      If[StringQ[pf], {FileNameJoin[{pf, "Git", "mingw64", "bin", "curl.exe"}],
        FileNameJoin[{pf, "Git", "usr", "bin", "curl.exe"}]}, {}]],
    With[{pf = Environment["ProgramW6432"]},
      If[StringQ[pf], {FileNameJoin[{pf, "Git", "mingw64", "bin", "curl.exe"}]}, {}]],
    "curl"}];
  cands = Select[cands, StringQ[#] && (# === "curl" || FileExistsQ[#]) &];
  $iSWCurlPathCache = SelectFirst[cands, iSWCurlSftpQ, False];
  If[StringQ[$iSWCurlPathCache], $iSWCurlPathCache, None]];

(* \:8a8d\:8a3c\:306f\:30b3\:30de\:30f3\:30c9\:30e9\:30a4\:30f3 (\:30d7\:30ed\:30bb\:30b9\:4e00\:89a7\:306b\:898b\:3048\:308b) \:3067\:306a\:304f stdin \:306e\:8a2d\:5b9a\:3067\:6e21\:3059 *)
iSWCurlConfig[user_String, pw_String] :=
  "user = \"" <> StringReplace[user <> ":" <> pw, {"\\" -> "\\\\", "\"" -> "\\\""}] <> "\"\n";

iSWUploadWith["curl", local_String, remoteURL_String, p_Association, pw_String] := Module[
  {exe = iSWCurlPath[], r, code},
  If[!StringQ[exe],
    Return[iSWUploadUnavailable["curl",
      "sftp \:5bfe\:5fdc\:306e curl \:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093 (Git for Windows \:540c\:68b1\:306e curl \:304c\:5fc5\:8981)\:3002"]]];
  r = Quiet[Check[RunProcess[{exe, "-sS", "-k", "--connect-timeout", "30",
      "-T", local, remoteURL, "-K", "-"}, All, iSWCurlConfig[p["User"], pw]], $Failed]];
  If[!AssociationQ[r],
    Return[iSWUploadTransferFailure["curl", remoteURL, "curl \:3092\:8d77\:52d5\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f"]]];
  code = Lookup[r, "ExitCode", -1];
  Which[
    code === 0, <|"Status" -> "Uploaded", "Method" -> "curl"|>,
    code === 67, iSWUploadAuthFailure["curl", p],
    True, iSWUploadTransferFailure["curl", remoteURL,
      "curl exit " <> ToString[code] <> ": " <>
        StringTrim[ToString[Lookup[r, "StandardError", ""]]]]]];

iSWUploadWith[m_, ___] := iSWUploadUnavailable[ToString[m], "\:672a\:77e5\:306e\:8ee2\:9001\:624b\:6bb5: " <> ToString[m]];

(* ---- \:672c\:4f53 ---- *)

Options[SlideDeckUpload] = {
  "UploadURL" -> Automatic, "SlideURL" -> Automatic, "File" -> Automatic,
  "Method" -> Automatic, "Password" -> Automatic, "User" -> Automatic,
  "Force" -> False, "Verify" -> True, "ExportVideo" -> Automatic,
  "Interactive" -> Automatic};

SlideDeckUpload[opts : OptionsPattern[]] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideDeckUpload[nb, opts],
    Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>]]];

SlideDeckUpload[src : Except[_Rule | _RuleDelayed], opts : OptionsPattern[]] := Module[
  {meta, uploadURL, slideURL, p, local, bytes, fileName, remoteURL, head, credName, pw,
   interactive, methods, res, t0, verify, isMp4Src, deckPath, staleQ, refreshed, was},
  isMp4Src = StringQ[src] && ToLowerCase[FileExtension[src]] === "mp4";
  meta = If[OptionValue["UploadURL"] === Automatic || OptionValue["SlideURL"] === Automatic,
    iSWUploadMetaOf[src], <||>];
  uploadURL = Replace[OptionValue["UploadURL"], Automatic :> Lookup[meta, "UploadURL", ""]];
  If[!StringQ[uploadURL] || StringTrim[uploadURL] === "",
    Return[iSWUploadURLMissingFailure[]]];
  p = iSWUploadTarget[uploadURL, OptionValue["User"]];
  If[FailureQ[p], Return[p]];
  slideURL = Replace[OptionValue["SlideURL"], Automatic :> Lookup[meta, "SlideURL", ""]];
  slideURL = If[StringQ[slideURL], StringTrim[slideURL], ""];
  (* \:30ed\:30fc\:30ab\:30eb\:306e mp4 (\:30d1\:30ec\:30c3\:30c8\:306e mp4 \:66f8\:304d\:51fa\:3057\:3068\:540c\:3058 <deck>.mp4) *)
  local = OptionValue["File"];
  If[local === Automatic,
    local = Which[
      Head[src] === NotebookObject,
        With[{db = iSWDeckBaseName[src]}, FileNameJoin[{db[[1]], db[[2]] <> ".mp4"}]],
      isMp4Src, src,
      StringQ[src], FileNameJoin[{DirectoryName[src], FileBaseName[src] <> ".mp4"}],
      True, None]];
  If[!StringQ[local],
    Return[Failure["SlideUploadFileMissing",
      <|"MessageTemplate" ->
        "\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:3059\:308b mp4 \:3092\:7279\:5b9a\:3067\:304d\:307e\:305b\:3093\:3002\"File\" -> path \:3067\:6307\:5b9a\:3057\:3066\:304f\:3060\:3055\:3044\:3002"|>]]];
  (* mp4 \:304c\:7121\:3044\:304b\:3001\:30c7\:30c3\:30ad\:3088\:308a\:53e4\:3044 (\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:3066\:304b\:3089\:518d\:767b\:9332\:3057\:305f) \:306a\:3089\:66f8\:304d\:76f4\:3059\:3002
     "ExportVideo": Automatic = \:7121\:3044/\:53e4\:3044\:3068\:304d\:3060\:3051 / True = \:5fc5\:305a / False = \:66f8\:304d\:76f4\:3055\:306a\:3044\:3002
     \:65e2\:5b58\:306e mp4 \:3092\:4f5c\:308a\:76f4\:3057\:305f\:3068\:304d\:306f\:4e2d\:8eab\:304c\:5909\:308f\:3063\:3066\:3044\:308b\:306e\:3067\:3001\:540c\:30b5\:30a4\:30ba\:3067\:3082\:9001\:308b *)
  deckPath = Which[
    Head[src] === NotebookObject,
      Replace[Quiet[NotebookFileName[src]], Except[_String] -> None],
    StringQ[src] && !isMp4Src && FileExistsQ[src], src,
    True, None];
  (* \:30d5\:30a1\:30a4\:30eb\:65e5\:4ed8\:3067\:306f\:306a\:304f\:300c\:30b9\:30e9\:30a4\:30c9\:3068\:3057\:3066\:63cf\:304b\:308c\:308b\:30bb\:30eb\:306e\:4e26\:3073\:300d\:3067\:898b\:308b\:3002
     \:30c8\:30fc\:30af\:30fb\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092\:76f4\:3057\:305f\:3060\:3051\:3067 mp4 \:3092\:4f5c\:308a\:76f4\:3055\:306a\:3044 (\:4e26\:3073\:9806\:306e\:5909\:66f4\:306f\:691c\:51fa\:3055\:308c\:308b) *)
  staleQ = FileExistsQ[local] && StringQ[deckPath] && iSWVideoStaleQ[deckPath, local];
  refreshed = False;
  If[!isMp4Src && OptionValue["ExportVideo"] =!= False &&
      (!FileExistsQ[local] || staleQ || OptionValue["ExportVideo"] === True),
    refreshed = FileExistsQ[local];
    was = If[FileExistsQ[local], Quiet[AbsoluteTime[FileDate[local]]], None];
    Quiet[Check[
      Which[
        (* \:30d1\:30ec\:30c3\:30c8\:306e mp4 \:30dc\:30bf\:30f3\:3068\:540c\:3058\:7d4c\:8def (\:5225\:30d7\:30ed\:30bb\:30b9\:2192FE \:5185\:3001\:72b6\:614b\:884c\:8868\:793a) *)
        Head[src] === NotebookObject, iSWExportVideoAction[src],
        StringQ[deckPath], SlideDeckExportVideo[deckPath, local]],
      Null]];
    (* \:66f8\:304d\:51fa\:3057\:304c\:5b9f\:969b\:306b\:8d70\:3063\:305f\:3068\:304d\:3060\:3051\:8a18\:9332\:3059\:308b\:3002\:5931\:6557\:3057\:305f\:306e\:306b\:8a18\:9332\:3059\:308b\:3068\:3001
       \:53e4\:3044 mp4 \:3092\:300c\:6700\:65b0\:300d\:3068\:898b\:306a\:3057\:3066\:4ee5\:5f8c\:4f5c\:308a\:76f4\:3055\:306a\:304f\:306a\:308b *)
    If[StringQ[deckPath] && FileExistsQ[local] &&
        (was === None || Quiet[AbsoluteTime[FileDate[local]]] =!= was),
      Quiet[iSWRecordVideoDigest[deckPath]]]];
  If[!FileExistsQ[local],
    Return[Failure["SlideUploadFileMissing",
      <|"MessageTemplate" -> "Sliden \:7528 mp4 \:304c\:3042\:308a\:307e\:305b\:3093: " <> local <>
          " (\:30d1\:30ec\:30c3\:30c8\:306e mp4 \:66f8\:304d\:51fa\:3057\:3067\:4f5c\:6210\:3057\:3066\:304f\:3060\:3055\:3044)", "File" -> local|>]]];
  bytes = FileByteCount[local];
  fileName = If[slideURL =!= "", iSWURLFileName[slideURL], ""];
  If[fileName === "", fileName = FileNameTake[local]];
  remoteURL = iSWUploadRemoteURL[p, fileName];
  (* \:65e2\:306b\:540c\:3058\:30b5\:30a4\:30ba\:3067\:914d\:4fe1\:4e2d\:306a\:3089\:9001\:3089\:306a\:3044 *)
  If[!TrueQ[OptionValue["Force"]] && !TrueQ[refreshed] && slideURL =!= "",
    head = iSWURLHead[slideURL];
    If[AssociationQ[head] && head["StatusCode"] === 200 && head["ContentLength"] === bytes,
      Return[<|"Status" -> "Unchanged", "Method" -> None, "File" -> local,
        "Bytes" -> bytes, "Remote" -> remoteURL, "SlideURL" -> slideURL,
        "Verified" -> True, "RemoteBytes" -> bytes, "Seconds" -> 0.,
        "Refreshed" -> False|>]]];
  (* \:30d1\:30b9\:30ef\:30fc\:30c9: \:30aa\:30d7\:30b7\:30e7\:30f3 > SystemCredential > (FE \:306a\:3089) \:30c0\:30a4\:30a2\:30ed\:30b0\:3067\:4fdd\:5b58 *)
  credName = iSWUploadCredentialName[p];
  pw = OptionValue["Password"];
  interactive = Replace[OptionValue["Interactive"], Automatic :> TrueQ[$Notebooks]];
  If[!StringQ[pw],
    If[pw =!= None,
      If[!iSWCredAvailableQ[], Return[iSWCredNBAccessFailure[]]];
      pw = iSWCredGet[credName];
      If[pw === None && TrueQ[interactive],
        With[{r = SlideUploadCredential[p["URL"]]},
          If[AssociationQ[r] && TrueQ[r["Configured"]], pw = iSWCredGet[credName]]]]];
    If[!StringQ[pw],
      Return[Failure["SlideUploadCredentialMissing",
        <|"MessageTemplate" -> "sftp \:306e\:30d1\:30b9\:30ef\:30fc\:30c9\:304c\:672a\:8a2d\:5b9a\:3067\:3059: " <> credName <>
            "\:3002SlideUploadCredential[\"" <> credName <>
            "\"] (\:30c0\:30a4\:30a2\:30ed\:30b0) \:304b SlideUploadCredential[url, password] \:3067\:4fdd\:5b58\:3057\:3066\:304f\:3060\:3055\:3044\:3002",
          "Credential" -> credName|>]]]];
  (* \:8ee2\:9001: \:4f7f\:3048\:306a\:3044\:624b\:6bb5\:306f\:98db\:3070\:3057\:3001\:8a8d\:8a3c/\:8ee2\:9001\:306e\:5931\:6557\:306f\:305d\:3053\:3067\:6b62\:3081\:308b *)
  methods = Flatten[{Replace[OptionValue["Method"], Automatic :>
    Replace[$SlideUploadMethod, Automatic -> {"Native", "curl"}]]}];
  t0 = AbsoluteTime[];
  res = iSWUploadUnavailable["None", "\:8ee2\:9001\:624b\:6bb5\:304c\:3042\:308a\:307e\:305b\:3093"];
  Do[
    res = iSWUploadWith[m, local, remoteURL, p, pw];
    If[!(FailureQ[res] && Lookup[Last[res], "Class", ""] === "Unavailable"), Break[]],
    {m, methods}];
  If[FailureQ[res], Return[res]];
  verify = If[TrueQ[OptionValue["Verify"]] && slideURL =!= "", iSWURLHead[slideURL], None];
  <|"Status" -> "Uploaded", "Method" -> res["Method"], "File" -> local, "Bytes" -> bytes,
    "Remote" -> remoteURL, "SlideURL" -> slideURL,
    "Verified" -> Which[
      verify === None, None,
      AssociationQ[verify] && verify["StatusCode"] === 200 &&
        verify["ContentLength"] === bytes, True,
      True, False],
    "RemoteBytes" -> If[AssociationQ[verify], verify["ContentLength"], None],
    "Refreshed" -> TrueQ[refreshed],
    "Seconds" -> Round[AbsoluteTime[] - t0, 0.1]|>];

(* \:767b\:9332\:7c3f\:3078\:306e\:767b\:9332\:306e\:3042\:3068\:306b\:52d5\:753b\:3092\:914d\:7f6e\:3059\:308b (SlideDeckRegister \:306e "Upload" \:30aa\:30d7\:30b7\:30e7\:30f3)\:3002
   Automatic = \:767a\:8868\:30e1\:30bf\:306b UploadURL \:304c\:3042\:308c\:3070\:9001\:308b / True = \:5fc5\:9808 / False = \:9001\:3089\:306a\:3044 *)
iSWRegisterUploadStep[res_, src_, talk_Association, upload_] := Module[{uurl, up},
  If[!AssociationQ[res] || upload === False, Return[res]];
  uurl = If[src === None, "", Lookup[talk, "UploadURL", ""]];
  If[!StringQ[uurl] || StringTrim[uurl] === "",
    Return[If[upload === True, Append[res, "Upload" -> iSWUploadURLMissingFailure[]], res]]];
  up = SlideDeckUpload[src, "UploadURL" -> uurl,
    "SlideURL" -> ToString[Lookup[res, "SlideURL", Lookup[talk, "SlideURL", ""]]]];
  Append[res, "Upload" -> up]];

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
If[!ValueQ[$SlideRenderSettle], $SlideRenderSettle = 0.6];
If[!ValueQ[$SlidePrepareBeforePlay], $SlidePrepareBeforePlay = True];
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

iSWRefreshVoiceLabel[] := ($iSWVoiceLabel = iSL["\:767a\:8868\:30dc\:30a4\:30b9: ", "Voice: "] <>
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

$iSWTalkMetaKeys = {"Id", "Title", "Aliases", "Event", "Author", "Date", "SlideURL",
  "Language", "NarrationInstructions", "SecondsPerSlide", "PrivacyLevel", "UploadURL"};

(* ---- \:6307\:793a (Directive) \:30bb\:30eb\:306e Key: value \:884c (v1.18) ------------------------------
   \:30c7\:30c3\:30ad\:5148\:982d (\:524d\:7f6e\:304d) \:306e\:6307\:793a\:30bb\:30eb\:306b
     Title: \:8a08\:7b97\:3068\:81ea\:7136 32
     SlideURL: https://transreal.sakura.ne.jp/cn/32.mp4
     Host: sftp://transreal@transreal.sakura.ne.jp/home/transreal/www/cn
   \:306e\:3088\:3046\:306b\:66f8\:304f (Upload: / UploadURL: \:306f Host: \:3068\:540c\:7fa9\:3002Aliases: / PrivacyLevel: \:7b49\:3082\:53ef)\:3002
   \:767a\:8868\:30e1\:30bf\:306e\:6700\:512a\:5148\:30bd\:30fc\:30b9 (TaggingRules "SWTalkMeta" > _talk.md front matter \:306e\:4e0a)\:3002
   _talk.md \:3092\:5ec3\:6b62\:3057\:305f\:306e\:3067\:3001\:767b\:9332\:306b\:8981\:308b\:60c5\:5831\:306f\:30c7\:30c3\:30ad\:306e\:4e2d\:3067\:5b8c\:7d50\:3059\:308b\:3002
   LLM \:3078\:6e21\:3059\:6307\:793a\:30d6\:30ed\:30c3\:30af (iSWDirectivesBlock) \:304b\:3089\:306f\:3053\:308c\:3089\:306e\:884c\:3092\:53d6\:308a\:9664\:304f\:3002 *)
$iSWDirectiveMetaKeyMap = <|
  "title" -> "Title", "slideurl" -> "SlideURL", "url" -> "SlideURL", "sliden" -> "SlideURL",
  "host" -> "UploadURL", "upload" -> "UploadURL", "uploadurl" -> "UploadURL",
  "uploadto" -> "UploadURL",
  "aliases" -> "Aliases", "alias" -> "Aliases", "event" -> "Event", "author" -> "Author",
  "date" -> "Date", "language" -> "Language",
  "narrationinstructions" -> "NarrationInstructions", "instructions" -> "NarrationInstructions",
  "secondsperslide" -> "SecondsPerSlide", "privacylevel" -> "PrivacyLevel",
  "id" -> "Id"|>;

(* \:300c\:6307\:793a\:300d\:30dc\:30bf\:30f3\:304c\:6700\:521d\:306b\:66f8\:304f\:96db\:5f62\:3002\:30e1\:30bf\:884c\:3092\:5148\:982d\:306b\:7f6e\:304d\:3001\:305d\:306e\:4e0b\:3078
   LLM \:3078\:306e\:6307\:793a\:3092\:66f8\:3044\:3066\:3082\:3089\:3046\:3002Host: \:306e\:5024\:306f\:66f8\:5f0f\:898b\:672c\:306a\:306e\:3067\:3001\:96db\:5f62\:306e\:307e\:307e\:306a\:3089
   \:672a\:8a18\:5165\:3068\:3057\:3066\:6271\:3046 (\:5b58\:5728\:3057\:306a\:3044\:30db\:30b9\:30c8\:3078\:9001\:308d\:3046\:3068\:3057\:3066\:5931\:6557\:3055\:305b\:306a\:3044) *)
$iSWDirectiveHostPlaceholder = "sftp://...@.../dir/";

iSWDirectiveTemplateText[] := StringJoin[
  "Title: \n", "SlideURL: \n", "Host: ", $iSWDirectiveHostPlaceholder, "\n\n",
  iSL["\:3053\:3053\:306b LLM \:3078\:306e\:6307\:793a\:3092\:8a18\:8f09...", "Write LLM directives here..."]];

(* \:96db\:5f62\:306e\:307e\:307e (\:7a7a / "..." \:3092\:542b\:3080 URL) \:306f\:300c\:66f8\:3044\:3066\:3044\:306a\:3044\:300d\:3068\:540c\:3058\:6271\:3044\:3002
   \:884c\:81ea\:4f53\:306f\:30e1\:30bf\:884c\:306a\:306e\:3067 LLM \:3078\:306e\:6307\:793a\:304b\:3089\:306f\:5f15\:304d\:7d9a\:304d\:53d6\:308a\:9664\:304f *)
iSWDirectivePlaceholderQ[key_String, v_String] := StringTrim[v] === "" ||
  (MemberQ[{"SlideURL", "UploadURL"}, key] && StringContainsQ[v, "..."]);

(* 1 \:884c -> {\:6b63\:898f\:30ad\:30fc, \:5024}\:3002\:30e1\:30bf\:884c\:3067\:306a\:3051\:308c\:3070 None *)
iSWDirectiveMetaLine[line_String] := Module[{m},
  m = StringCases[line,
    StartOfString ~~ WhitespaceCharacter ... ~~ k : (LetterCharacter ..) ~~
      WhitespaceCharacter ... ~~ ":" ~~ v___ ~~ EndOfString :>
      {ToLowerCase[k], StringTrim[v]}, 1];
  If[m === {} || !KeyExistsQ[$iSWDirectiveMetaKeyMap, m[[1, 1]]], None,
    {$iSWDirectiveMetaKeyMap[m[[1, 1]]], m[[1, 2]]}]];
iSWDirectiveMetaLine[_] := None;

iSWDirectiveMetaValue["Aliases", v_String] := iTalkSplitAliases[v];
iSWDirectiveMetaValue["SecondsPerSlide" | "PrivacyLevel", v_String] :=
  With[{n = Quiet[Check[ToExpression[v], $Failed]]}, If[NumericQ[n], N[n], None]];
iSWDirectiveMetaValue[_, v_String] := v;

(* \:30bb\:30eb 1 \:3064\:5206\:306e\:30c6\:30ad\:30b9\:30c8 -> \:30e1\:30bf\:9023\:60f3\:3002\:540c\:3058\:30ad\:30fc\:306f\:5148\:306b\:66f8\:3044\:305f\:884c\:304c\:52dd\:3064 *)
iSWMetaFromDirectiveText[text_String] := Module[{meta = <||>, kv, val},
  Do[
    kv = iSWDirectiveMetaLine[line];
    If[ListQ[kv] && !iSWDirectivePlaceholderQ[kv[[1]], kv[[2]]] && !KeyExistsQ[meta, kv[[1]]],
      val = iSWDirectiveMetaValue[kv[[1]], kv[[2]]];
      If[val =!= None, meta[kv[[1]]] = val]],
    {line, StringSplit[StringReplace[text, "\r\n" -> "\n"], "\n"]}];
  meta];

(* \:30e1\:30bf\:884c\:3092\:9664\:3044\:305f\:6307\:793a\:672c\:6587 (LLM \:3078\:6e21\:3059\:5206) *)
iSWStripMetaLines[text_String] := StringTrim[StringRiffle[
  Select[StringSplit[StringReplace[text, "\r\n" -> "\n"], "\n"],
    iSWDirectiveMetaLine[#] === None &], "\n"]];
iSWStripMetaLines[_] := "";

(* \:6307\:793a\:30bb\:30eb\:306e\:30c6\:30ad\:30b9\:30c8\:5217\:3002NotebookObject \:306f FE \:304b\:3089 Directive \:30bb\:30eb\:3060\:3051\:3092\:5f15\:304f
   (\:5168\:30bb\:30eb\:306e\:30b9\:30bf\:30a4\:30eb\:7167\:4f1a\:3092\:907f\:3051\:308b)\:3001Notebook \:5f0f / \:4fdd\:5b58\:6e08\:307f path \:306f\:30ab\:30fc\:30cd\:30eb\:5074\:3067 *)
iSWDirectiveTexts[nb_NotebookObject] := Select[
  With[{c = Quiet[NotebookRead[#]]},
      If[Head[c] === Cell, StringTrim[iCellText[c]], ""]] & /@
    Replace[Quiet[Cells[nb, CellStyle -> "Directive"]], Except[_List] -> {}],
  StringQ[#] && # =!= "" &];
iSWDirectiveTexts[nbExpr_Notebook] := Select[
  StringTrim[iCellText[#]] & /@ Cases[nbExpr, Cell[_, "Directive", ___], Infinity],
  StringQ[#] && # =!= "" &];
iSWDirectiveTexts[path_String] := With[
  {e = If[FileExistsQ[path], Quiet[iGetNotebook[path]], $Failed]},
  If[Head[e] === Notebook, iSWDirectiveTexts[e], {}]];
iSWDirectiveTexts[_] := {};

(* \:5148\:306b\:73fe\:308c\:305f\:30bb\:30eb\:304c\:52dd\:3064 *)
iSWDirectiveMeta[src_] := Fold[Join[#2, #1] &, <||>,
  iSWMetaFromDirectiveText /@ iSWDirectiveTexts[src]];

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
  Join[iSWTalkFileMeta[SlideTalkFile[nb]], iSWTalkStoredMeta[nb], iSWDirectiveMeta[nb]];

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
    <|"Id" -> Lookup[meta, "Id", ""],
      "Title" -> Lookup[meta, "Title", fallbackTitle],
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
      "UploadURL" -> Lookup[meta, "UploadURL", ""],
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
    iSWTalkMetaFromNotebookExpr[nbExpr], iSWDirectiveMeta[nbExpr]];
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

iSWVoiceFileInDir[dir_String, n_Integer, rawText_String] := Module[{text = iSWTalkSpeakText[rawText], voice, file, res},
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
  (* \:30e1\:30e2\:30ea\:306b\:8f09\:305b\:3066\:304b\:3089\:9cf4\:3089\:3059\:3002\:30d5\:30a1\:30a4\:30eb\:53c2\:7167\:578b\:306e\:307e\:307e\:3060\:3068\:518d\:751f\:4e2d\:3082\:30c7\:30a3\:30b9\:30af\:3092\:8aad\:307f\:3001
     \:540c\:3058 Dropbox \:30d5\:30a9\:30eb\:30c0\:306b\:5148\:8aad\:307f\:306e wav \:3092\:66f8\:304f/\:540c\:671f\:3059\:308b\:52d5\:304d\:3068\:7af6\:5408\:3057\:3046\:308b *)
  audio = With[{m = Quiet[Audio[AudioData[audio], SampleRate -> AudioSampleRate[audio]]]},
    If[TrueQ[Quiet[AudioQ[m]]], m, audio]];
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
  (* \:6b21\:30b9\:30e9\:30a4\:30c9\:306e\:63cf\:753b\:304c\:843d\:3061\:7740\:3044\:3066\:304b\:3089\:8aad\:307f\:59cb\:3081\:308b\:3002\:518d\:751f\:306f FE \:5074\:306e AudioStream
     \:306a\:306e\:3067\:3001\:91cd\:3044\:30b9\:30e9\:30a4\:30c9 (\:5927\:304d\:306a\:753b\:50cf) \:306e\:63cf\:753b\:4e2d\:306b\:9cf4\:3089\:3057\:59cb\:3081\:308b\:3068 FE \:304c\:585e\:304c\:3063\:3066
     \:3044\:308b\:6570\:79d2\:9593\:3060\:3051\:97f3\:304c\:6b62\:307e\:308b (\:5b9f\:6e2c 2026-08-26: \:8a08\:7b97\:3068\:81ea\:7136 32\:3001\:8868\:793a\:76f4\:5f8c\:306b\:505c\:6b62)\:3002
     \:540c\:671f\:547c\:3073\:51fa\:3057\:3067 FE \:306e\:51e6\:7406\:5f85\:3061\:3092\:6d41\:3057\:3066\:304b\:3089\:3001\:63cf\:753b\:306e\:5206\:3060\:3051\:9593\:3092\:7f6e\:304f *)
  iSWFESettle[nb];
  iSWPlaySlide[next];
  Null];

iSWFESettle[nb_] := (
  Quiet[CurrentValue[nb, WindowTitle]];
  With[{s = $SlideRenderSettle}, If[NumericQ[s] && s > 0., Pause[N[s]]]]);

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
  (* \:518d\:751f\:4e2d\:306b\:5408\:6210\:3057\:306a\:3044: \:672a\:5408\:6210\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:5148\:306b\:307e\:3068\:3081\:3066\:7528\:610f\:3059\:308b\:3002\:5408\:6210\:4e2d\:306f
     \:518d\:751f\:304c\:9014\:5207\:308c\:308b (\:5b9f\:6e2c 2026-08-26: \:518d\:751f\:76f4\:5f8c\:306e\:5148\:8aad\:307f\:5408\:6210\:3067\:6570\:79d2\:7121\:97f3)\:3002
     \:30ad\:30e3\:30c3\:30b7\:30e5\:6e08\:307f\:306e\:679a\:306f\:5373\:5ea7\:306b\:8fd4\:308b\:306e\:3067\:30012 \:56de\:76ee\:4ee5\:964d\:306e\:518d\:751f\:306f\:5f85\:305f\:306a\:3044 *)
  If[TrueQ[$SlidePrepareBeforePlay] && engine === "Local",
    Module[{keys = Select[Sort[Keys[texts]], # <= count &], i = 0},
      Do[i++;
        iSWPlayNote[iSL["\:97f3\:58f0\:3092\:7528\:610f\:4e2d ", "Preparing audio "] <> ToString[i] <> "/" <>
          ToString[Length[keys]]];
        Quiet[iSWVoiceFileFor[nb, k, texts[k]]],
        {k, keys}]]];
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
(* \:518d\:767b\:9332\:306f\:300c\:76f4\:3057\:305f\:3068\:3053\:308d\:3060\:3051\:300d\:3092\:4e0a\:66f8\:304d\:3059\:308b\:306e\:3067\:3001\:4f55\:304c\:5909\:308f\:3063\:305f\:304b\:3092\:72b6\:614b\:884c\:306b\:51fa\:3059 *)
iSWRegisterHeadline[res_Association] := Module[{chg},
  chg = Select[Flatten[{Lookup[res, "ChangedKeys", {}]}], StringQ];
  Which[
    Lookup[res, "RegistryStatus", "Created"] =!= "Updated",
      iSL["\:767b\:9332\:3057\:307e\:3057\:305f: ", "Registered: "],
    chg === {},
      iSL["\:767b\:9332\:6e08\:307f (\:5909\:66f4\:306a\:3057): ", "Already registered (no change): "],
    True,
      iSL["\:66f4\:65b0\:3057\:307e\:3057\:305f [", "Updated ["] <>
        StringRiffle[Take[chg, UpTo[6]], ", "] <>
        If[Length[chg] > 6, ", ...", ""] <> "]: "]];
iSWRegisterHeadline[_] := iSL["\:767b\:9332\:3057\:307e\:3057\:305f: ", "Registered: "];

(* QA \:6bb5\:306e\:4e00\:884c\:3002\:300c\:5909\:308f\:3063\:3066\:3044\:306a\:3044\:306e\:3067\:4f55\:3082\:3057\:3066\:3044\:306a\:3044\:300d\:3053\:3068\:304c\:898b\:3048\:306a\:3044\:3068\:3001
   \:58ca\:308c\:3066\:3044\:308b\:306e\:304b\:7701\:3044\:305f\:306e\:304b\:5206\:304b\:3089\:306a\:3044 *)
iSWRegisterQANote[None] := "";
iSWRegisterQANote[qa_] := Which[
  FailureQ[qa],
    iSL["QA \:5931\:6557 (", "QA FAILED ("] <> ToString[Lookup[Last[qa], "MessageTemplate", "?"]] <> ")  ",
  !AssociationQ[qa], "",
  Lookup[qa, "Status", ""] === "Unchanged",
    iSL["QA \:306f\:767b\:9332\:6e08\:307f (\:5909\:66f4\:306a\:3057)  ", "QA unchanged  "],
  Lookup[qa, "Status", ""] === "NoCells",
    iSL["QA \:30bb\:30eb\:7121\:3057  ", "no QA cells  "],
  True,
    iSL["QA ", "QA "] <> ToString[Lookup[qa, "Questions", 0]] <>
      iSL[" \:554f\:3092\:767b\:9332 (\:516c\:958b ", " questions registered (public "] <>
      ToString[Lookup[qa, "Public", 0]] <> ")" <>
      With[{d = Lookup[qa, "Dropped", 0]},
        If[IntegerQ[d] && d > 0,
          iSL[" \:203b\:56de\:7b54\:7121\:3057 " <> ToString[d] <> " \:554f\:306f\:9664\:5916",
            " (" <> ToString[d] <> " unanswered dropped)"], ""]] <> "  "];

(* \:30d1\:30ec\:30c3\:30c8\:306e\:300cQA \:751f\:6210\:300d: LLM \:3067\:60f3\:5b9a\:554f\:7b54\:306e\:4e0b\:66f8\:304d\:3092\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3078\:66f8\:304f (\:975e\:540c\:671f) *)
iSWQAGenerateAction[nb_] := Module[{seeded},
  (* \:65e2\:5b58\:306e\:4f5c\:308a\:7f6e\:304d\:304c\:3042\:3063\:3066\:30bb\:30eb\:304c 1 \:3064\:3082\:7121\:3044\:306a\:3089\:3001\:307e\:305a\:305d\:308c\:3092\:30bb\:30eb\:3078\:623b\:3059\:3002
     LLM \:3092\:56de\:3059\:524d\:306b\:3001\:4eca\:3042\:308b\:3082\:306e\:3092\:6368\:3066\:306a\:3044 *)
  If[!iSWUnsavedQ[nb] && ! AnyTrue[Values[iSWQASlideHasCellQ[nb]], TrueQ],
    seeded = Quiet[SlideQAFromPack[nb]];
    If[AssociationQ[seeded] && Lookup[seeded, "Slides", 0] > 0,
      iSWStatus[nb, iSL["\:65e2\:5b58\:306e QA \:30d1\:30c3\:30af\:304b\:3089 " <> ToString[seeded["Questions"]] <>
        " \:554f\:3092\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3078\:623b\:3057\:307e\:3057\:305f (LLM \:672a\:4f7f\:7528)\:3002\:76f4\:3057\:3066\:304b\:3089\:300c\:767b\:9332\:300d\:3057\:3066\:304f\:3060\:3055\:3044",
        "Restored " <> ToString[seeded["Questions"]] <>
          " questions from the existing pack into QA cells (no LLM). Edit, then Register."]];
      iSWStatusClearLater[nb];
      Return[seeded]]];
  If[iSWUnsavedQ[nb],
    iSWStatus[nb, iSL["\:672a\:4fdd\:5b58\:3067\:3059\:3002\:4fdd\:5b58\:3057\:3066\:304b\:3089\:5b9f\:884c\:3059\:308b\:3068\:30c7\:30c3\:30ad\:5168\:4f53\:3092\:8aad\:3093\:3067\:4f5c\:308c\:307e\:3059",
      "Unsaved: save the deck first so the whole deck can be read"]]];
  SlideQAGenerate[nb]];

(* \:30d1\:30ec\:30c3\:30c8\:306e\:300cQA \:4e00\:89a7\:300d: \:30bb\:30eb\:306e\:4e2d\:8eab\:3068\:3001\:767b\:9332\:6e08\:307f\:30d1\:30c3\:30af\:306e\:72b6\:614b\:3092\:4e26\:3079\:3066\:898b\:305b\:308b *)
iSWQANumberLine[label_String, nums_List] := If[nums === {}, Nothing,
  label <> StringRiffle[ToString /@ Take[nums, UpTo[20]], ", "] <>
    If[Length[nums] > 20, " ...", ""]];

iSWQAOverviewAction[nb_] := Module[{data, view, st, chg, summary},
  data = SlideQAEntries[nb];
  view = SlideQAView[nb];
  If[!AssociationQ[data] || Head[view] =!= Dataset,
    MessageDialog[iSL["\:8cea\:7591\:5fdc\:7b54\:3092\:96c6\:3081\:3089\:308c\:307e\:305b\:3093\:3067\:3057\:305f\:3002",
      "Could not collect the Q&A."]];
    Return[$Failed]];
  st = If[iSWQALayerQ[], Quiet[SourceVault`SourceVaultTalkQAStatus[]], None];
  chg = Quiet[SlideDeckChangeStatus[nb]];
  summary = StringRiffle[Flatten[{
    iSL["\:30b9\:30e9\:30a4\:30c9 ", "Slides: "] <> ToString[Lookup[data, "SlideCount", 0]] <>
      iSL[" \:679a / \:60f3\:5b9a\:8cea\:554f ", " / questions: "] <> ToString[Lookup[data, "Questions", 0]] <>
      iSL[" \:554f (\:56de\:7b54\:6e08\:307f ", " (answered "] <> ToString[Lookup[data, "Answered", 0]] <> ")",
    iSWQANumberLine[iSL["\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9: ", "Slides without a QA cell: "],
      Lookup[data, "Missing", {}]],
    iSWQANumberLine[iSL["\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3057\:305f\:306e\:3067\:8981\:66f4\:65b0: ", "Changed since their QA was written: "],
      Lookup[data, "Stale", {}]],
    iSWQANumberLine[iSL["\:5224\:5b9a\:4e0d\:80fd (\:624b\:66f8\:304d\:30fb\:30de\:30fc\:30ab\:30fc\:7121\:3057\:3001\:300cQA \:751f\:6210\:300d\:3067\:306f\:89e6\:3089\:306a\:3044): ",
      "Unmarked (hand-written; QA gen leaves them alone): "],
      Lookup[data, "Unmarked", {}]],
    With[{n = Length[Lookup[data, "Missing", {}]] + Length[Lookup[data, "Stale", {}]]},
      If[n === 0,
        iSL["\:300cQA \:751f\:6210\:300d\:3067\:3084\:308b\:3053\:3068\:306f\:3042\:308a\:307e\:305b\:3093\:3002",
          "Nothing for the QA gen button to do."],
        iSL["\:300cQA \:751f\:6210\:300d\:3092\:62bc\:3059\:3068 " <> ToString[n] <> " \:679a\:3092\:66f4\:65b0\:3057\:307e\:3059\:3002",
          "The QA gen button would update " <> ToString[n] <> " slide(s)."]]],
    If[AssociationQ[chg],
      iSL["\:767b\:9332\:6e08\:307f\:306e QA \:3068\:306e\:5dee: ", "QA vs registered: "] <>
        If[TrueQ[Lookup[chg, "QAStale", True]],
          iSL["\:672a\:767b\:9332\:306e\:5909\:66f4\:3042\:308a (\:300c\:767b\:9332\:300d\:3067\:713c\:304d\:76f4\:3057\:307e\:3059)",
            "changed (press Register to rebuild)"],
          iSL["\:5909\:66f4\:306a\:3057", "unchanged"]],
      Nothing],
    If[AssociationQ[st],
      iSL["\:30d1\:30c3\:30af: ", "Pack: "] <> ToString[Lookup[st, "PackId", "?"]] <>
        " / " <> ToString[Lookup[st, "Questions", 0]] <> iSL[" \:554f (\:516c\:958b ", " questions (public "] <>
        ToString[Lookup[st, "Public", 0]] <> iSL[" / \:975e\:516c\:958b ", " / non-public "] <>
        ToString[Lookup[st, "NonPublic", 0]] <> ") " <> ToString[Lookup[st, "BuiltAtUTC", ""]],
      iSL["\:30d1\:30c3\:30af\:306f\:307e\:3060\:3042\:308a\:307e\:305b\:3093 (\:300c\:767b\:9332\:300d\:3067\:4f5c\:3089\:308c\:307e\:3059)",
        "No pack yet (press Register to build one)"]]}], "\n"];
  CreateDocument[{
    Cell[iSL["\:8cea\:7591\:5fdc\:7b54 (\:30b9\:30e9\:30a4\:30c9\:5185\:306e\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c\:6b63\:672c)",
      "Anticipated Q&A (the in-slide QA cells are the source of truth)"], "Section"],
    Cell[summary, "Text"],
    Cell[iSL["\:30b9\:30e9\:30a4\:30c9\:3054\:3068\:306e\:72b6\:614b", "Per-slide state"], "Subsection"],
    Cell[BoxData[ToBoxes[Quiet[SlideQAStateView[nb]]]], "Output"],
    Cell[iSL["\:60f3\:5b9a\:554f\:7b54", "Anticipated Q&A"], "Subsection"],
    Cell[BoxData[ToBoxes[view]], "Output"],
    Cell[iSL["\:7de8\:96c6\:306f\:3053\:3053\:3067\:306f\:306a\:304f\:30c7\:30c3\:30ad\:306e\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3067\:884c\:3044\:307e\:3059\:3002\:76f4\:3057\:305f\:3089\:4fdd\:5b58\:3057\:3066\:300c\:767b\:9332\:300d\:3092\:62bc\:3059\:3068\:3001gpt-realtime \:304c\:5f15\:3051\:308b\:5f62\:306b\:713c\:304d\:76f4\:3055\:308c\:307e\:3059\:3002",
      "Edit the QA cells in the deck (not here). Save, then press Register to rebuild the database gpt-realtime reads."],
      "Text"]},
    WindowTitle -> "Slide QA", WindowSize -> {900, 620}]];

iSWTalkRegisterAction[nb_] := Module[{res, up, note, head, qa},
  iSWStatus[nb, iSL["\:767b\:9332\:30fbQA\:30fbmp4 \:3092\:66f4\:65b0\:4e2d (\:5909\:308f\:3063\:305f\:5206\:3060\:3051)...",
    "Updating registry, QA and mp4 (only what changed)..."]];
  res = SlideDeckRegister[nb];
  If[FailureQ[res],
    iSWStatusClearLater[nb];
    MessageDialog[Lookup[Last[res], "MessageTemplate", ToString[res]]];
    Return[res]];
  up = Lookup[res, "Upload", None];
  note = Which[
    up === None, iSL["(\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:5148\:306a\:3057: \:6307\:793a\:30bb\:30eb\:306b Host: \:3092\:66f8\:304f\:3068 mp4 \:3082\:914d\:7f6e)",
      "(no upload target: add a Host: line to the directive cell)"],
    FailureQ[up], iSL["mp4 \:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:5931\:6557", "mp4 upload FAILED"],
    Lookup[up, "Status", ""] === "Unchanged",
      iSL["mp4 \:306f\:914d\:4fe1\:6e08\:307f (\:5909\:66f4\:306a\:3057)", "mp4 already published (unchanged)"],
    True, If[TrueQ[Lookup[up, "Refreshed", False]],
        iSL["mp4 \:3092\:4f5c\:308a\:76f4\:3057\:3066\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9 ", "mp4 rebuilt and uploaded "],
        iSL["mp4 \:30a2\:30c3\:30d7\:30ed\:30fc\:30c9 ", "mp4 uploaded "]] <> iSWFormatBytes[Lookup[up, "Bytes", 0]] <>
      " / " <> ToString[Lookup[up, "Seconds", 0]] <> "s" <>
      Switch[Lookup[up, "Verified", None],
        True, iSL[" \:914d\:4fe1\:78ba\:8a8dOK", " verified"],
        False, iSL[" \:914d\:4fe1\:672a\:78ba\:8a8d (URL \:3068\:7f6e\:304d\:5834\:6240\:3092\:78ba\:8a8d)", " NOT verified"],
        _, ""]];
  qa = iSWRegisterQANote[Lookup[res, "QA", None]];
  (* \:672a\:4fdd\:5b58\:3060\:3068 mp4 \:306e\:5dee\:5206\:5224\:5b9a\:306f\:4fdd\:5b58\:6e08\:307f\:306e\:4e2d\:8eab\:3092\:898b\:308b\:3002
     \:76f4\:3057\:305f\:30b9\:30e9\:30a4\:30c9\:304c mp4 \:306b\:5165\:3089\:306a\:3044\:306e\:3067\:3001\:9ed9\:3063\:3066\:9032\:3081\:306a\:3044 *)
  qa = If[iSWUnsavedQ[nb],
    iSL["\:203b\:672a\:4fdd\:5b58 (mp4 \:306f\:4fdd\:5b58\:6e08\:307f\:306e\:5185\:5bb9\:3067\:5224\:5b9a)  ",
      "(unsaved: mp4 staleness judged from the saved file)  "] <> qa, qa];
  head = iSWRegisterHeadline[res];
  iSWStatus[nb, head <> ToString[Lookup[res, "Title", "?"]] <> " -> " <>
    ToString[Lookup[res, "SlideURL", "?"]] <> "  " <> qa <> note];
  iSWStatusClearLater[nb];
  If[FailureQ[up],
    MessageDialog[iSL["\:767b\:9332\:7c3f\:3078\:306e\:767b\:9332\:306f\:5b8c\:4e86\:3057\:307e\:3057\:305f\:304c\:3001mp4 \:306e\:30a2\:30c3\:30d7\:30ed\:30fc\:30c9\:306b\:5931\:6557\:3057\:307e\:3057\:305f:\n",
        "Registered, but the mp4 upload failed:\n"] <>
      Lookup[Last[up], "MessageTemplate", ToString[up]]]];
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

(* v1.21: Claude Code \:30d1\:30ec\:30c3\:30c8\:3068\:540c\:3058\:8a70\:3081\:65b9 (110/54 \:5e45\:30fb18 \:9ad8\:30fb\:30d5\:30a9\:30f3\:30c8 10/8\:30fbColumn Spacings 0) *)
SetAttributes[iSWButton, HoldRest];
iSWButton[label_String, color_, action_] :=
  Button[Style[label, Bold, 10, White],
    CompoundExpression[action,
      With[{inb = InputNotebook[]},
        If[Head[inb] === NotebookObject, SetSelectedNotebook[inb]]]],
    Appearance -> "Frameless", Background -> color,
    ImageSize -> {110, 18}, FrameMargins -> {{4, 4}, {1, 1}},
    Method -> "Queued"];

SetAttributes[iSWButton2, HoldRest];
iSWButton2[label_String, color_, action_] :=
  Button[Style[label, Bold, 8, White],
    CompoundExpression[action,
      With[{inb = InputNotebook[]},
        If[Head[inb] === NotebookObject, SetSelectedNotebook[inb]]]],
    Appearance -> "Frameless", Background -> color,
    ImageSize -> {54, 18}, FrameMargins -> {{1, 1}, {1, 1}},
    Method -> "Queued"];

(* \:30dc\:30bf\:30f3\:306e\:8aac\:660e (\:9759\:7684\:3002\:63cf\:753b\:6642\:306b kernel \:3092\:547c\:3070\:306a\:3044) *)
iSWTip[b_, tip_String] := Tooltip[b, tip, TooltipDelay -> 0.4];

iSWButtonRow[b1_, b2_] :=
  Grid[{{b1, b2}}, Spacings -> 0.1, ItemSize -> {Automatic, Automatic}];

(* \:534a\:5e45\:306e\:52d5\:7684\:30e9\:30d9\:30eb\:30dc\:30bf\:30f3 (\:8868\:793a\:5207\:66ff / \:30de\:30a4\:30af / \:518d\:751f / \:5fdc\:7b54): \:8272\:3082\:30e9\:30d9\:30eb\:3082 kernel \:5074\:5909\:6570\:3092\:8ffd\:8de1\:3059\:308b\:3060\:3051 *)
(* \:6a2a\:5e45\:3044\:3063\:3071\:3044\:306e\:52d5\:7684\:30e9\:30d9\:30eb\:30dc\:30bf\:30f3 (\:5fdc\:7b54 on/off \:3092 1 \:884c\:3067) *)
SetAttributes[iSWDynButton, HoldAll];
iSWDynButton[labelSym_, colorSym_, action_] :=
  Button[
    Dynamic[Style[labelSym, Bold, 10, White],
      TrackedSymbols :> {labelSym}, SynchronousUpdating -> False],
    action,
    Appearance -> "Frameless",
    Background -> Dynamic[colorSym, TrackedSymbols :> {colorSym}, SynchronousUpdating -> False],
    ImageSize -> {110, 18}, FrameMargins -> {{4, 4}, {1, 1}},
    Method -> "Queued"];

SetAttributes[iSWDynButton2, HoldAll];
iSWDynButton2[labelSym_, colorSym_, action_] :=
  Button[
    Dynamic[Style[labelSym, Bold, 8, White],
      TrackedSymbols :> {labelSym}, SynchronousUpdating -> False],
    action,
    Appearance -> "Frameless",
    Background -> Dynamic[colorSym, TrackedSymbols :> {colorSym}, SynchronousUpdating -> False],
    ImageSize -> {54, 18}, FrameMargins -> {{1, 1}, {1, 1}},
    Method -> "Queued"];

(* \:30bb\:30af\:30b7\:30e7\:30f3\:898b\:51fa\:3057: Claude Code \:30d1\:30ec\:30c3\:30c8\:3068\:540c\:3058\:7d20\:306e Style (Pane \:7121\:3057) *)
iSWSectionLabel[ja_String, en_String] := Style[iSL[ja, en], Bold, 8, GrayLevel[0.3]];

$iSWPlayColor = RGBColor[0.25, 0.55, 0.45];
$iSWTalkColor = RGBColor[0.35, 0.45, 0.6];

$iSWPalette = None;

(* v1.21: P:/M: \:306f Claude Code \:30d1\:30ec\:30c3\:30c8\:3067\:8a2d\:5b9a\:3059\:308b (\:3053\:3053\:306b\:306f\:7f6e\:304b\:306a\:3044) *)

(* \:5c55\:958b\:6642\:306b\:30c8\:30fc\:30af(talk:)\:3082\:751f\:6210\:3059\:308b\:304b\:306e\:30c8\:30b0\:30eb ($SlideTalkPerSlide) *)
$iSWTalkGenLabel = "";
iSWRefreshTalkGenLabel[] := ($iSWTalkGenLabel =
  If[TrueQ[$SlideTalkPerSlide],
    iSL["\:5c55\:958b: \:30c8\:30fc\:30af\:751f\:6210 on", "Expand: talk gen on"],
    iSL["\:5c55\:958b: \:30c8\:30fc\:30af\:751f\:6210 off", "Expand: talk gen off"]]);

(* v1.2: "Safe"->True \:3067 ClaudeCode \:3068\:5b8c\:5168\:975e\:5e72\:6e09
   (LoadPaletteSettings \:3082 P:/M: \:8a2d\:5b9a\:6b04\:3082\:7701\:7565)\:3002\:30d5\:30ea\:30fc\:30ba\:5207\:308a\:5206\:3051\:7528 *)
$SlideWorkflowInteractiveVersion = "1.31";
Options[ShowSlidePalette] = {"Safe" -> False};

ShowSlidePalette[OptionsPattern[]] := Module[{safe = TrueQ[OptionValue["Safe"]]},
  If[$iSWPalette =!= None, Quiet[NotebookClose[$iSWPalette]]];
  iSWRefreshVoiceLabel[];
  iSWRefreshTalkLabel[];
  iSWRefreshMicLabel[];
  iSWRefreshEnvLabel[];
  iSWRefreshTalkGenLabel[];
  iSWPlayRefreshProgress[];
  $iSWPalette = Quiet[CreatePalette[
    Column[{
      Row[{Style["SlideWorkflow", Bold, 11, RGBColor[0.878, 0.486, 0.078]], " ",
        Style[SlideWorkflow`$SlideWorkflowInteractiveVersion, 8, GrayLevel[0.5]]}],

      (* v1.30: \:4e0a\:304b\:3089\:300c\:4f5c\:308b (\:77e5\:8b58\:30b0\:30e9\:30d5)\:300d\:300c1 \:679a\:305a\:3064 (\:5f93\:6765\:306e\:5c55\:958b)\:300d\:300c\:633f\:5165\:300d\:300c\:8868\:793a\:30fb\:66f8\:304d\:51fa\:3057\:300d\:300c\:767a\:8868\:306e\:6e96\:5099\:300d\:300c\:767a\:8868\:300d\:300c\:8a2d\:5b9a\:300d\:3002
         \:4f5c\:308b\:7bc0\:306f\:5de5\:7a0b\:306e\:9806 (\:5de6\:304b\:3089\:53f3\:3001\:4e0a\:304b\:3089\:4e0b)\:3002KG\:69cb\:7bc9\:306f\:6587\:732e\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:3042\:308c\:3070\:8ad6\:6587\:304b\:3089\:3001\:7121\:3051\:308c\:3070\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306e\:30b7\:30ca\:30ea\:30aa\:304b\:3089 *)
      iSWSectionLabel[" \:4f5c\:308b (\:77e5\:8b58\:30b0\:30e9\:30d5)", " Build (knowledge graph)"],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["\:30b9\:30c8\:30fc\:30ea\:30fc", "Story"], RGBColor[0.7, 0.55, 0.3], SlideInsertStory[]],
          iSL["\:8074\:304d\:624b\:30fb\:679a\:6570\:30fb\:8a71\:306e\:9806\:306a\:3069\:3092\:66f8\:304f (\:6700\:521d\:306b\:66f8\:304f)", "Audience, length and order of the talk (write first)"]],
        iSWTip[iSWButton2[iSL["\:6587\:732e", "Refs"], RGBColor[0.3, 0.55, 0.5], SlideInsertReferences[]],
          iSL["\:8ad6\:6587\:306e\:548c\:8a33\:30ce\:30fc\:30c8\:3084\:5f15\:7528\:3059\:308b\:8cc7\:6599 ([key] locator | \:30e1\:30e2)", "Translated paper notebook and sources ([key] locator | note)"]]],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["KG\:69cb\:7bc9", "Build KG"], RGBColor[0.5, 0.6, 0.25], SlideGraphBuild[]],
          iSL["\:6587\:732e\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:3042\:308c\:3070\:8ad6\:6587\:304b\:3089\:3001\:7121\:3051\:308c\:3070\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306e\:7b4b\:66f8\:304d (\:30b7\:30ca\:30ea\:30aa) \:304b\:3089\:77e5\:8b58\:30b0\:30e9\:30d5\:3092\:4f5c\:308b (\:95a2\:9023\:7814\:7a76\:3082\:63a2\:3059)",
            "Build the knowledge graph from the translated paper, or from the scenario in the prompt cells (with related work)"]],
        iSWTip[iSWButton2[iSL["\:63a8\:6572", "Refine"], RGBColor[0.4, 0.55, 0.35], SlideGraphRefine[]],
          iSL["\:6e08\:3093\:3067\:3044\:306a\:3044\:7bc0\:304b\:3089\:7d9a\:304d\:3092\:63a8\:6572 (\:30b7\:30ca\:30ea\:30aa\:306f\:7b4b\:66f8\:304d\:306e\:5c55\:958b)", "Continue refining (expanding the scenario) from unfinished sections"]]],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["\:5468\:8fba\:77e5\:8b58", "Background"], RGBColor[0.35, 0.6, 0.6], SlideGraphBackground[]],
          iSL["\:8074\:304d\:624b\:306b\:8db3\:308a\:306a\:3044\:524d\:63d0\:77e5\:8b58\:3092\:8db3\:3059", "Add prerequisites the audience lacks"]],
        iSWTip[iSWButton2[iSL["\:56f3\:89e3", "Visuals"], RGBColor[0.3, 0.5, 0.7], SlideGraphRefine["Mode" -> "Visual"]],
          iSL["\:56f3\:306e\:7121\:3044\:679a\:306b\:8868\:304b\:6982\:5ff5\:56f3\:3092\:4ed8\:3051\:308b", "Add a table or concept figure to slides without one"]]],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["\:8abf\:6574", "Adjust"], RGBColor[0.3, 0.45, 0.75], SlideGraphAdjust[]],
          iSL["\:8abf\:6574\:30bb\:30eb\:306b\:76f4\:3057\:305f\:3044\:3053\:3068\:3092\:66f8\:3044\:3066\:62bc\:3059", "Write what to change in the adjustment cell, then press"]],
        iSWTip[iSWButton2[iSL["KG\:56f3", "KG map"], RGBColor[0.45, 0.45, 0.55],
            With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWGraphViewerAction[nb]]]],
          iSL["\:77e5\:8b58\:30b0\:30e9\:30d5\:3092\:56f3\:3067\:898b\:308b\:7a93 (\:8a71\:306e\:6d41\:308c\:30fb\:7bc0\:30fb\:5468\:8fba\:30fb\:8a08\:753b\:30fb\:4e00\:89a7\:3002\:30ce\:30fc\:30c9\:3092\:30af\:30ea\:30c3\:30af\:3067\:4e2d\:8eab\:3001\:30b9\:30e9\:30a4\:30c9\:3078\:79fb\:52d5\:3001\:8abf\:6574\:306b\:66f8\:304f)",
            "Open the knowledge-graph map (story, sections, neighborhood, plan, nodes; click a node to see it, jump to its slide, or add it to Adjust)"]]],
      iSWTip[iSWButton[iSL["\:751f\:6210", "Generate"], RGBColor[0.878, 0.486, 0.078],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWGraphApplyAction[nb]]]],
        iSL["\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:30b9\:30e9\:30a4\:30c9\:3092\:4f5c\:308b (\:524d\:56de\:306e\:751f\:6210\:30b9\:30e9\:30a4\:30c9\:306f\:7f6e\:304d\:63db\:3048\:3089\:308c\:308b\:3002\:8cea\:7591\:5fdc\:7b54\:306f\:5f15\:304d\:7d99\:3050)",
          "Generate the slides (replaces the previous generation; the Q&A is carried over)"]],

      iSWSectionLabel[" 1 \:679a\:305a\:3064", " One slide"],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["\:30d7\:30ed\:30f3\:30d7\:30c8", "Prompt"], RGBColor[0.878, 0.486, 0.078], SlideInsertPrompt[]],
          iSL["\:3053\:306e\:679a\:3067\:4f1d\:3048\:305f\:3044\:3053\:3068\:3092\:66f8\:304f\:30bb\:30eb (KG\:69cb\:7bc9\:306e\:30b7\:30ca\:30ea\:30aa\:306b\:3082\:306a\:308b)", "Prompt cell for this slide (also the scenario for Build KG)"]],
        iSWTip[iSWButton2[iSL["\:5c55\:958b", "Expand"], RGBColor[0.878, 0.486, 0.078], SlideExpand[]],
          iSL["\:30d7\:30ed\:30f3\:30d7\:30c8\:304b\:3089\:3053\:306e\:679a\:3092\:4f5c\:308b (\:77e5\:8b58\:30b0\:30e9\:30d5\:3092\:4f7f\:308f\:306a\:3044)", "Make this slide from its prompt (without the knowledge graph)"]]],
      iSWButtonRow[
        iSWButton2[iSL["\:ff0b\:30b9\:30e9\:30a4\:30c9", "+Slide"], RGBColor[0.2, 0.55, 0.35], SlideAddSlide[]],
        iSWButton2[iSL["\:51fa\:5178", "Cite"], RGBColor[0.45, 0.45, 0.55], SlideInsertCitation[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:82f1\:8a33", "Translate"], RGBColor[0.3, 0.4, 0.65], SlideTranslate[]],
        iSWButton2[iSL["\:00d7\:82f1\:8a33", "\[Times]Tr"], RGBColor[0.6, 0.35, 0.35], SlideTranslateRevert[]]],
      iSWButton[iSL["\:5168\:30b9\:30e9\:30a4\:30c9\:82f1\:8a33", "Translate All"], RGBColor[0.3, 0.4, 0.65], SlideTranslateDeck[]],

      iSWSectionLabel[" \:633f\:5165", " Insert"],
      iSWButtonRow[
        iSWButton2[iSL["\:30e1\:30e2", "Note"], RGBColor[0.7, 0.63, 0.35], SlideInsertNote[]],
        iSWButton2[iSL["\:6307\:793a", "Directive"], RGBColor[0.65, 0.35, 0.5], SlideInsertDirective[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:8f9e\:66f8", "Dict"], RGBColor[0.35, 0.65, 0.65], SlideInsertDictionary[]],
        iSWButton2[iSL["\:30c8\:30fc\:30af", "Talk"], RGBColor[0.45, 0.42, 0.7], SlideInsertTalk[]]],
      iSWButtonRow[
        iSWButton2[iSL["\:8cea\:7591", "QA"], RGBColor[0.8, 0.45, 0.15], SlideInsertQA[]],
        iSWButton2[iSL["\:7d42\:7aef", "End"], RGBColor[0.5, 0.45, 0.35], SlideInsertEndMarker[]]],

      (* \:8868\:793a: \:74b0\:5883\:5207\:66ff (Working/Slideshow) \:3068\:30d7\:30ed\:30f3\:30d7\:30c8\:8868\:793a\:3001\:66f8\:304d\:51fa\:3057 *)
      iSWSectionLabel[" \:8868\:793a\:30fb\:66f8\:304d\:51fa\:3057", " View / Export"],
      (* v1.31: \:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:7a93 (SlideGraphViewer) \:3092\:5206\:304b\:308b\:540d\:524d\:3067\:3002\:300c\:4f5c\:308b\:300d\:6b04\:306e\:300cKG\:56f3\:300d\:3068\:540c\:3058 *)
      iSWTip[iSWButton[iSL["\:77e5\:8b58\:30b0\:30e9\:30d5\:3092\:898b\:308b", "Knowledge graph"], RGBColor[0.4, 0.45, 0.62],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWGraphViewerAction[nb]]]],
        iSL["\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:7a93\:3092\:958b\:304f (\:8a71\:306e\:6d41\:308c\:30fb\:7bc0\:30fb\:5468\:8fba\:30fb\:8a08\:753b\:30fb\:4e00\:89a7\:3002\:30ce\:30fc\:30c9\:3092\:30af\:30ea\:30c3\:30af\:3067\:4e2d\:8eab\:3001\:30b9\:30e9\:30a4\:30c9\:3078\:79fb\:52d5\:3001\:8abf\:6574\:306b\:66f8\:304f)",
          "Open the knowledge-graph window (story, sections, neighborhood, plan, nodes)"]],
      iSWButtonRow[
        iSWDynButton2[$iSWEnvLabel, $iSWEnvColor,
          With[{nb = iSWNotebook[]},
            If[nb =!= $Failed, SlideToggleScreenEnvironment[nb]; SetSelectedNotebook[nb]]]],
        iSWButton2[iSL["\[LeftRightArrow]\:30d7\:30ed\:30f3\:30d7\:30c8", "\[LeftRightArrow]Prompts"],
          RGBColor[0.35, 0.45, 0.65], SlideTogglePrompts[]]],
      iSWButton[iSL["\:4e00\:89a7", "Overview"], RGBColor[0.4, 0.5, 0.55],
        With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWOverviewAction[nb]]]],
      iSWButtonRow[
        iSWButton2[iSL["\:753b\:50cf", "Images"], RGBColor[0.3, 0.5, 0.55],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWExportImagesAction[nb]]]],
        iSWButton2[iSL["mp4", "mp4"], RGBColor[0.4, 0.4, 0.55],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWExportVideoAction[nb]]]]],

      (* \:767a\:8868\:306e\:6e96\:5099: \:539f\:7a3f (\:30c8\:30fc\:30af\:30bb\:30eb) \:3068\:60f3\:5b9a\:554f\:7b54\:3092\:6574\:3048\:3066\:767b\:9332\:3059\:308b\:3002\:3069\:308c\:3082\:30b9\:30e9\:30a4\:30c9\:306e\:4f5c\:308a\:65b9 (KG / \:5c55\:958b) \:306b\:3088\:3089\:306a\:3044 *)
      iSWSectionLabel[" \:767a\:8868\:306e\:6e96\:5099", " Prepare the talk"],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["\:539f\:7a3f", "Talk"], RGBColor[0.72, 0.4, 0.2],
            With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWTalkFillAction[nb]]]],
          iSL["\:539f\:7a3f (\:30c8\:30fc\:30af\:30bb\:30eb) \:306e\:7121\:3044\:679a\:306b\:3060\:3051\:539f\:7a3f\:3092\:66f8\:304f", "Write talks only for slides without one"]],
        iSWTip[iSWButton2[iSL["QA\:751f\:6210", "QA gen"], RGBColor[0.8, 0.45, 0.15],
            With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWQAGenerateAction[nb]]]],
          iSL["\:60f3\:5b9a\:554f\:7b54\:3092\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306b\:66f8\:304f (\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:679a\:306f\:5143\:306e\:8cc7\:6599\:3082\:898b\:308b\:3002\:554f\:7b54\:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306b\:3082\:4fdd\:5b58)",
            "Draft the anticipated Q&A (slides from the knowledge graph also use the source; the Q&A is saved to the graph)"]]],
      iSWButtonRow[
        iSWTip[iSWButton2[iSL["QA\:4e00\:89a7", "QA list"], RGBColor[0.6, 0.45, 0.3],
            With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWQAOverviewAction[nb]]]],
          iSL["\:8cea\:7591\:5fdc\:7b54\:306e\:70b9\:691c", "Review the Q&A"]],
        iSWTip[iSWButton2[iSL["\:767b\:9332", "Register"], RGBColor[0.35, 0.55, 0.4],
            With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWTalkRegisterAction[nb]]]],
          iSL["\:767b\:9332\:7c3f\:30fbQA\:30fbmp4 \:3092\:66f4\:65b0 (\:5909\:308f\:3063\:305f\:5206\:3060\:3051)", "Update the registry, Q&A and mp4 (only what changed)"]]],

      (* \:767a\:8868: \:300c\:60c5\:5831\:300d\:306e\:6a2a\:306b\:30de\:30a4\:30af\:306e mute/unmute (\:624b\:5143\:30ea\:30e2\:30b3\:30f3\:306e\:518d\:751f/\:4e00\:6642\:505c\:6b62\:3068\:540c\:3058\:52d5\:4f5c) *)
      iSWSectionLabel[" \:767a\:8868", " Present"],
      iSWButtonRow[
        iSWButton2[iSL["\:60c5\:5831", "Info"], RGBColor[0.45, 0.5, 0.6],
          With[{nb = iSWNotebook[]}, If[nb =!= $Failed, iSWInfoAction[nb]]]],
        iSWDynButton2[$iSWMicLabel, $iSWMicColor,
          (SlideToggleMic[];
           With[{inb = InputNotebook[]},
             If[Head[inb] === NotebookObject, SetSelectedNotebook[inb]]])]],
      iSWButtonRow[
        iSWDynButton2[$iSWPlayLabel, $iSWPlayColor,
          With[{nb = iSWNotebook[]},
            If[nb =!= $Failed, iSWPlayToggleAction[nb]; SetSelectedNotebook[nb]]]],
        iSWButton2["\[FilledSquare] " <> iSL["\:505c\:6b62", "Stop"], RGBColor[0.6, 0.35, 0.35], SlideStop[]]],
      (* \:5fdc\:7b54 on/off \:306f 1 \:884c\:3067\:3002\:30dc\:30a4\:30b9\:5207\:66ff\:306f\:5e45\:304c\:8db3\:308a\:306a\:3044 (\:300cV: \:307b\:306e\:304b\:300d\:304c\:8a70\:307e\:308b) \:306e\:3067\:8a2d\:5b9a\:6b04\:3078 *)
      iSWDynButton[$iSWTalkLabel, $iSWTalkColor,
        With[{nb = iSWNotebook[]},
          If[nb =!= $Failed, SlideToggleRealtime[nb]; SetSelectedNotebook[nb]]]],
      Dynamic[Style[$iSWPlayProgress, 8, GrayLevel[0.45]],
        TrackedSymbols :> {$iSWPlayProgress}, SynchronousUpdating -> False],

      (* \:8a2d\:5b9a: \:5c55\:958b\:6642\:306e\:30c8\:30fc\:30af\:751f\:6210 on/off \:3068\:767a\:8868\:30dc\:30a4\:30b9\:3002P:/M: \:306f Claude Code \:30d1\:30ec\:30c3\:30c8\:3067\:8a2d\:5b9a\:3059\:308b (v1.21 \:3067\:64a4\:53bb) *)
      iSWSectionLabel[" \:8a2d\:5b9a", " Settings"],
      Button[
        Dynamic[Style[$iSWTalkGenLabel, 9, Bold, GrayLevel[0.2]],
          TrackedSymbols :> {$iSWTalkGenLabel}, SynchronousUpdating -> False],
        ($SlideTalkPerSlide = !TrueQ[$SlideTalkPerSlide];
         iSWRefreshTalkGenLabel[]),
        Appearance -> "Frameless", Method -> "Queued"],
      (* \:767a\:8868\:306e\:8aad\:307f\:4e0a\:3052\:30dc\:30a4\:30b9: \:62bc\:3059\:305f\:3073\:306b\:6b21\:306e\:30dc\:30a4\:30b9\:3078 *)
      Button[
        Dynamic[Style[$iSWVoiceLabel, 9, Bold, GrayLevel[0.2]],
          TrackedSymbols :> {$iSWVoiceLabel}, SynchronousUpdating -> False],
        SlideCycleVoice[],
        Appearance -> "Frameless", Method -> "Queued"]
    }, Alignment -> Center, Spacings -> 0],
    WindowTitle -> "Slides", WindowMargins -> {{Automatic, 60}, {Automatic, 60}}]];
  $iSWPalette];

(* ===================== \:77e5\:8b58\:30b0\:30e9\:30d5\:99c6\:52d5\:751f\:6210 (v1.20) =====================
   \:4ed5\:69d8: SlideWorkflow_info/design/slide_knowledge_graph_spec_v0_1.md
   \:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:8a08\:7b97 (\:691c\:8a3c / \:9806\:5e8f\:6728 / \:8074\:304d\:624b / \:8a70\:3081\:8fbc\:307f / md \:5316) \:306f SourceVault_knowledgegraph.wl\:3002
   \:3053\:3053\:306f (1) Story \:30bb\:30eb\:306e\:8aad\:307f\:53d6\:308a\:3001(2) \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:3078\:306e\:59d4\:8b72\:30bf\:30b9\:30af\:6587\:3001(3) md \:4e2d\:306e\:8cc7\:7523\:6307\:5b9a\:306e
   \:5b9f\:4f53\:5316 (SlidePDFFigure / SlideNotebookFormula / SlideNotebookFigure / SlideDeckFigure)\:3001
   (4) \:30c7\:30c3\:30ad\:3078\:306e\:9069\:7528 (SlideDeckInsertScenario / SlideDeckBuild) \:3060\:3051\:3092\:6301\:3064\:3002
   documentation.wl \:306f\:547c\:3070\:306a\:3044\:3002\:7ffb\:8a33\:306f KG \:306e\:30ce\:30fc\:30c9\:5358\:4f4d (SourceVault \:5074) \:3067\:3001\:30bb\:30eb\:5358\:4f4d\:306e\:82f1\:8a33\:3068\:72ec\:7acb\:3002 *)

$iSWStoryCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.5, 0.6, 0.25],
  Background -> RGBColor[0.96, 0.975, 0.92], FontSize -> 11,
  FontColor -> GrayLevel[0.3], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.5, 0.6, 0.25]]};

$iSWPackageDirectory = With[{f = Quiet @ Check[$InputFileName, ""]},
  If[StringQ[f] && f =!= "", DirectoryName[f], ""]];

iSWKGLoadedQ[] := Length[DownValues[SourceVault`SourceVaultKGFromJSON]] > 0;

(* SourceVault.wl \:304c\:8aad\:307f\:8fbc\:3080\:304c\:3001SlideWorkflow \:5358\:4f53\:3067\:3082\:96a3\:306e SourceVault_knowledgegraph.wl \:3092\:62fe\:3046 *)
iSWKGEnsure[] := Module[{dir, f},
  If[iSWKGLoadedQ[], Return[True]];
  dir = Which[
    StringQ[Global`$packageDirectory] && DirectoryQ[Global`$packageDirectory], Global`$packageDirectory,
    $iSWPackageDirectory =!= "", $iSWPackageDirectory,
    True, ""];
  f = FileNameJoin[{dir, "SourceVault_knowledgegraph.wl"}];
  If[dir =!= "" && FileExistsQ[f],
    Quiet @ Check[Block[{$CharacterEncoding = "UTF-8"}, Get[f]], Null]];
  iSWKGLoadedQ[]];

iSWKGFail[] := Failure["NoKnowledgeGraphLayer", <|"MessageTemplate" ->
  "SourceVault_knowledgegraph.wl is not loaded (SourceVault.wl loads it, or Get it next to SlideWorkflow.wl)"|>];

(* ---- Story \:30bb\:30eb (\:8074\:304d\:624b / \:679a\:6570 / \:6642\:9593 / \:8a00\:8a9e / \:6226\:7565 / \:30b9\:30c8\:30fc\:30ea\:30fc) ---- *)
$iSWStoryKeyMap = <|"graph" -> "Graph", "kg" -> "Graph", "\:30b0\:30e9\:30d5" -> "Graph",
  "audience" -> "Audience", "\:8074\:304d\:624b" -> "Audience", "\:8074\:8846" -> "Audience", "\:5bfe\:8c61" -> "Audience",
  "slides" -> "Slides", "\:679a\:6570" -> "Slides", "minutes" -> "Minutes", "\:5206" -> "Minutes", "\:6642\:9593" -> "Minutes",
  "seconds" -> "Seconds", "\:79d2" -> "Seconds", "secondsperslide" -> "SecondsPerSlide",
  "language" -> "Language", "\:8a00\:8a9e" -> "Language", "strategy" -> "Strategy", "\:6226\:7565" -> "Strategy",
  "story" -> "Story", "\:30b9\:30c8\:30fc\:30ea\:30fc" -> "Story", "\:69cb\:6210" -> "Story", "title" -> "Title",
  "source" -> "Source", "\:7d20\:6750" -> "Source", "\:30bd\:30fc\:30b9" -> "Source", "survey" -> "Survey", "\:30b5\:30fc\:30d9\:30a4" -> "Survey"|>;

iSWStoryLine[line_String] := Module[{m},
  m = StringCases[line, StartOfString ~~ k : Except[":" | "\:ff1a"] .. ~~ (":" | "\:ff1a") ~~ v___ ~~ EndOfString :>
    {ToLowerCase[StringTrim[k]], StringTrim[v]}, 1];
  If[m === {} || ! KeyExistsQ[$iSWStoryKeyMap, m[[1, 1]]], None, {$iSWStoryKeyMap[m[[1, 1]]], m[[1, 2]]}]];

(* Key: value \:884c\:306f\:4ed5\:69d8\:3001\:305d\:308c\:4ee5\:5916\:306e\:884c\:306f Story \:306e\:7d9a\:304d\:3002\:540c\:3058\:30ad\:30fc\:306f\:5148\:306b\:66f8\:3044\:305f\:884c\:304c\:52dd\:3064 *)
iSWParseStoryText[text_String] := Module[{spec = <||>, kv, story = {}},
  Do[
    kv = iSWStoryLine[line];
    Which[
      ListQ[kv] && kv[[1]] === "Story", If[kv[[2]] =!= "", AppendTo[story, kv[[2]]]],
      ListQ[kv], If[kv[[2]] =!= "" && ! KeyExistsQ[spec, kv[[1]]], spec[kv[[1]]] = kv[[2]]],
      StringTrim[line] === "" || StringStartsQ[StringTrim[line], "#"], Null,
      True, AppendTo[story, StringTrim[line]]],
    {line, StringSplit[StringReplace[text, "\r\n" -> "\n"], "\n"]}];
  If[story =!= {}, spec["Story"] = StringRiffle[story, "\n"]];
  spec];

iSWStyleTexts[nb_NotebookObject, style_String] := iSWCollectByStyle[nb, style];
iSWStyleTexts[nbExpr_Notebook, style_String] := Select[
  StringTrim[iCellText[#]] & /@ Cases[nbExpr, Cell[_, style, ___], Infinity], StringQ[#] && # =!= "" &];
iSWStyleTexts[path_String, style_String] := With[
  {e = If[FileExistsQ[path], Quiet[iGetNotebook[path]], $Failed]},
  If[Head[e] === Notebook, iSWStyleTexts[e, style], {}]];
iSWStyleTexts[___] := {};

iSWNumberOrNone[v_] := With[{n = Quiet @ Check[ToExpression[StringTrim[ToString[v]]], $Failed]},
  If[NumericQ[n], N[n], None]];

iSWKGLangCode[v_] := With[{s = ToLowerCase[StringTrim[ToString[v]]]},
  Which[s === "", "ja", MemberQ[{"ja", "japanese", "\:65e5\:672c\:8a9e"}, s], "ja",
    MemberQ[{"en", "english", "\:82f1\:8a9e"}, s], "en", True, s]];

iSWKGDefaultGraphId[title_] := Module[{t = StringTrim[ToString[title]], k},
  If[t === "" || t === "None", Return["deck"]];
  k = ToLowerCase[Quiet @ Check[CharacterNormalize[t, "NFKC"], t]];
  k = StringJoin @ Select[Characters[k], StringMatchQ[#, LetterCharacter | DigitCharacter] &];
  If[k === "", "deck", StringTake[k, UpTo[40]]]];

$iSWStoryDefaults = <|"Audience" -> "\:4e00\:822c", "Slides" -> None, "Minutes" -> None, "Seconds" -> None,
  "Language" -> "ja", "Strategy" -> "Source", "Story" -> "", "Graph" -> None, "Title" -> "",
  "SecondsPerSlide" -> None, "Source" -> "", "Survey" -> ""|>;

SlideGraphSpec[] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] === NotebookObject, SlideGraphSpec[nb], $iSWStoryDefaults]];
SlideGraphSpec[src_] := Module[{spec, story, meta},
  story = Fold[Join[#2, #1] &, <||>, iSWParseStoryText /@ iSWStyleTexts[src, "SlideStory"]];
  meta = Quiet @ Check[iSWDirectiveMeta[src], <||>];
  If[! AssociationQ[meta], meta = <||>];
  spec = Join[$iSWStoryDefaults, KeyTake[meta, {"Title", "Language", "SecondsPerSlide"}], story];
  Do[spec[k] = iSWNumberOrNone[spec[k]], {k, {"Slides", "Minutes", "Seconds", "SecondsPerSlide"}}];
  If[NumericQ[spec["Slides"]], spec["Slides"] = Round[spec["Slides"]]];
  If[! NumericQ[spec["Seconds"]] && NumericQ[spec["Minutes"]], spec["Seconds"] = 60. * spec["Minutes"]];
  If[! NumericQ[spec["SecondsPerSlide"]], spec["SecondsPerSlide"] = N[$SlideTalkSecondsPerSlide]];
  spec["Language"] = iSWKGLangCode[spec["Language"]];
  If[! StringQ[spec["Strategy"]] || spec["Strategy"] === "", spec["Strategy"] = "Source"];
  If[! StringQ[spec["Graph"]] || spec["Graph"] === "", spec["Graph"] = iSWKGDefaultGraphId[spec["Title"]]];
  spec];

(* \:5c55\:958b\:30d7\:30ed\:30f3\:30d7\:30c8\:306b\:3082\:8074\:304d\:624b\:30fb\:6642\:9593\:30fb\:30b9\:30c8\:30fc\:30ea\:30fc\:3092\:898b\:305b\:308b (Directives / Dictionary / References \:3068\:4e26\:3076 4 \:3064\:76ee\:306e\:30d6\:30ed\:30c3\:30af) *)
iSWStoryBlock[nb_] := Module[{spec, lines = {}},
  If[iSWStyleTexts[nb, "SlideStory"] === {}, Return[""]];
  spec = Quiet @ Check[SlideGraphSpec[nb], <||>];
  If[! AssociationQ[spec], Return[""]];
  If[StringQ[spec["Audience"]] && spec["Audience"] =!= "", AppendTo[lines, "\:8074\:304d\:624b: " <> spec["Audience"]]];
  If[IntegerQ[spec["Slides"]], AppendTo[lines, "\:679a\:6570: " <> ToString[spec["Slides"]]]];
  If[NumericQ[spec["Seconds"]], AppendTo[lines, "\:6642\:9593: " <> ToString[Round[spec["Seconds"] / 60.]] <> " \:5206"]];
  If[StringQ[spec["Story"]] && spec["Story"] =!= "", AppendTo[lines, "\:30b9\:30c8\:30fc\:30ea\:30fc: " <> spec["Story"]]];
  If[lines === {}, "",
    "=== Story (\:8074\:304d\:624b\:30fb\:6642\:9593\:30fb\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a\:3002\:53b3\:5b88) ===\n" <> StringRiffle[lines, "\n"] <> "\n=== End Story ===\n\n"]];

SlideInsertStory[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertStory[nb]]];
(* ---- Story \:30bb\:30eb\:306e\:96db\:5f62: \:6587\:732e\:6b04\:306e\:548c\:8a33\:30ce\:30fc\:30c8\:304b\:3089\:7bc0\:306e\:4e26\:3073\:3068\:8981\:65e8\:306e\:7d50\:3073\:3092\:62fe\:3044\:3001\:5968\:52b1\:30b9\:30c8\:30fc\:30ea\:30fc\:3092\:521d\:671f\:5024\:306b\:3059\:308b\:3002
   \:7a74\:57cb\:3081\:306e\:898b\:672c\:6587 ("\:3053\:3053\:306b\:66f8\:304f") \:3092\:6b8b\:3059\:3068\:3001\:66f8\:304d\:63db\:3048\:3089\:308c\:306a\:3044\:307e\:307e LLM \:3078\:6e21\:3063\:3066\:3057\:307e\:3046 ---- *)
$iSWStorySkipSections = {"\:53c2\:8003\:6587\:732e", "\:5f15\:7528\:6587\:732e", "References", "\:8b1d\:8f9e", "Acknowledg", "\:4ed8\:9332", "Appendix",
  "\:88dc\:8db3", "Supplementary", "\:5229\:76ca\:76f8\:53cd", "Conflict", "\:8457\:8005", "Author", "Disclosure", "\:8cc7\:91d1", "Funding",
  "\:30c7\:30fc\:30bf", "Data availability", "Ethic", "\:502b\:7406", "Highlights", "Declaration", "Supplemental",
  "Graphical abstract", "Keywords", "\:30ad\:30fc\:30ef\:30fc\:30c9"};
(* \:65b9\:6cd5\:306e\:7bc0\:306f\:984c\:304c\:5b8c\:5168\:306b\:4e00\:81f4\:3059\:308b\:3068\:304d\:3060\:3051\:5916\:3059 ("Experimental approach" \:306f\:7d50\:679c\:306e\:5c0f\:7bc0) *)
$iSWStoryMethodTitles = {"experimental procedures", "methods", "materials and methods", "star methods", "star\[FivePointedStar]methods",
  "method details", "\:65b9\:6cd5", "\:5b9f\:9a13\:65b9\:6cd5", "\:6750\:6599\:3068\:65b9\:6cd5"};
iSWStoryAbstractQ[s_String] := StringContainsQ[s, "\:6982\:8981" | "\:8981\:65e8" | "\:6284\:9332" | "Abstract" | "Summary", IgnoreCase -> True];
iSWStoryHeadings[src_String] := Module[{ol, styles, best, cut, occ = <||>},
  ol = Quiet @ Check[SlideNotebookOutline[src], $Failed];
  If[! ListQ[ol] || ol === {} || ! AllTrue[ol, AssociationQ], Return[{}]];
  ol = Select[ol, StringQ[Lookup[#, "Title", None]] &];
  (* DocImportPaper \:306e\:7b2c\:4e8c\:90e8 (\:8a08\:7b97\:306e\:518d\:69cb\:6210) \:304b\:3089\:5148\:306f\:8ad6\:6587\:306e\:69cb\:6210\:3067\:306f\:306a\:3044 *)
  cut = FirstPosition[ol, o_ /; StringStartsQ[StringTrim[o["Title"]], "\:7b2c\:4e8c\:90e8" | "Part II"], None, {1}, Heads -> False];
  If[cut =!= None, ol = Take[ol, First[cut] - 1]];
  (* \:540c\:3058\:984c\:306e\:898b\:51fa\:3057\:304c\:8907\:6570\:3042\:308b (Findings \:306a\:3069) \:306e\:3067\:51fa\:73fe\:756a\:53f7\:3092\:4ed8\:3051\:308b (KG \:306e\:7bc0\:3068\:5bfe\:5fdc\:3055\:305b\:308b) *)
  ol = Map[Function[o, Append[o, "Occurrence" -> (occ[o["Title"]] = Lookup[occ, o["Title"], 0] + 1)]], ol];
  (* \:898b\:51fa\:3057\:306f 2 \:968e\:5c64\:3042\:308b\:3053\:3068\:304c\:591a\:3044 (\:984c\:540d = Section\:3001\:7bc0 = Subsection)\:3002\:6570\:306e\:591a\:3044\:968e\:5c64\:3092\:7bc0\:3068\:307f\:306a\:3059 *)
  styles = Tally[Lookup[ol, "Style", ""]];
  best = If[styles === {}, "", First[Last[SortBy[styles, Last]]]];
  Select[ol, Lookup[#, "Style", ""] === best &]];
(* KG \:304c\:3042\:308c\:3070\:7bc0\:306e\:984c\:3092 KG \:306e (\:63a8\:6572\:6e08\:307f\:30fb\:65e5\:672c\:8a9e\:306e) \:984c\:306b\:7f6e\:304d\:63db\:3048\:308b: \:7bc0\:30ce\:30fc\:30c9\:306f\:5143\:306e\:898b\:51fa\:3057\:3092 Source.Section \:306b\:6301\:3064 *)
iSWStoryKGLabels[kg_Association] := GroupBy[
  SortBy[Select[Lookup[kg, "Nodes", {}], StringQ[Lookup[Replace[Lookup[#, "Source", <||>], Except[_Association] -> <||>], "Section", None]] &],
    Replace[Lookup[#, "Order", None], Except[_?NumericQ] -> Infinity] &],
  StringTrim[#["Source"]["Section"]] &, Map[SourceVault`SourceVaultKGText[#, "Label"] &]];
iSWStoryKGLabels[_] := <||>;
iSWStorySectionTitles[src_String, labels_Association : <||>] := Module[{tops},
  tops = Select[iSWStoryHeadings[src], Lookup[#, "Chars", 0] >= 40 &];
  tops = Select[tops, Function[it, ! iSWStoryAbstractQ[it["Title"]] &&
    ! MemberQ[$iSWStoryMethodTitles, ToLowerCase[StringTrim[it["Title"]]]] &&
    ! AnyTrue[$iSWStorySkipSections, StringContainsQ[it["Title"], #, IgnoreCase -> True] &]]];
  Take[Select[Map[Function[it, With[{ls = Lookup[labels, StringTrim[it["Title"]], {}]},
      StringTrim[If[Length[ls] >= it["Occurrence"] && StringQ[ls[[it["Occurrence"]]]] && ls[[it["Occurrence"]]] =!= "",
        ls[[it["Occurrence"]]], it["Title"]]]]], tops], # =!= "" &], UpTo[6]]];
(* \:8981\:65e8\:306e\:7d50\:3073\:306e 1 \:6587 = \:305d\:306e\:8ad6\:6587\:306e\:7d50\:8ad6\:3002\:7121\:3051\:308c\:3070\:7a7a *)
iSWStoryConclusion[src_String] := Module[{ab, txt, ss},
  ab = SelectFirst[iSWStoryHeadings[src],
    StringQ[Lookup[#, "Title", None]] && iSWStoryAbstractQ[#["Title"]] &, None];
  If[! AssociationQ[ab], Return[""]];
  txt = Quiet @ Check[SlideNotebookText[src, ab["Title"], "MaxCharacters" -> 6000], ""];
  If[! StringQ[txt], Return[""]];
  txt = StringReplace[txt, RegularExpression["(?m)^\\[[^]]*\\] ?"] -> ""];
  ss = Select[StringTrim /@ StringSplit[txt, "\:3002" | ". "], StringLength[#] >= 15 &];
  If[ss === {}, "", StringTrim[Last[ss], "\:3002" | "."]]];
iSWStorySourceOf[nb_] := Module[{refs},
  refs = Quiet @ Check[iSWReferencesList[nb], {}];
  If[! ListQ[refs], refs = {}];
  refs = Select[refs, AssociationQ];
  FirstCase[refs, r_ /; StringQ[Lookup[r, "Notebook", None]] :> r["Notebook"],
    FirstCase[refs, r_ /; StringQ[Lookup[r, "Locator", None]] &&
      StringEndsQ[r["Locator"], ".nb", IgnoreCase -> True] :> r["Locator"], None]]];
iSWStoryTemplateText[nb_] := Module[{src, secs = {}, concl = "", order, head, labels = <||>},
  src = iSWStorySourceOf[nb];
  (* v1.30: \:6587\:732e\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:7121\:304f\:3001\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306b\:7b4b\:66f8\:304d\:304c\:3042\:308c\:3070\:30b7\:30ca\:30ea\:30aa\:306e\:96db\:5f62 *)
  If[! StringQ[src],
    With[{parts = Quiet @ Check[iSWScenarioParts[nb], {}]},
      If[ListQ[parts] && parts =!= {},
        Return[iSWStoryScenarioTemplate[parts, $Language === "Japanese" || iSWJaTextQ[StringJoin[Lookup[parts, "Text", ""]]]]]]]];
  If[iSWKGLoadedQ[],
    labels = Quiet @ Check[iSWStoryKGLabels[iSWKGResolve[SlideGraphSpec[nb]["Graph"]]], <||>];
    If[! AssociationQ[labels], labels = <||>]];
  If[StringQ[src],
    TimeConstrained[secs = iSWStorySectionTitles[src, labels]; concl = iSWStoryConclusion[src], 30]];
  If[! ListQ[secs], secs = {}];
  If[! StringQ[concl], concl = ""];
  (* \:96db\:5f62\:306e\:8a00\:8a9e\:306f\:539f\:7a3f\:306b\:5408\:308f\:305b\:308b: \:548c\:8a33\:30ce\:30fc\:30c8\:304b\:3089\:62fe\:3048\:305f\:6587\:5b57\:5217\:304c\:65e5\:672c\:8a9e\:306a\:3089 UI \:304c\:82f1\:8a9e\:3067\:3082\:65e5\:672c\:8a9e *)
  If[$Language === "Japanese" || iSWJaTextQ[concl <> StringJoin[secs]],
    head = "Graph: \nAudience: \:5927\:5b66\:7406\:7cfb\:5b66\:90e8\:5352\nSlides: 20\nMinutes: \nLanguage: ja\nStrategy: Source\n";
    order = If[secs === {}, "\:7d50\:8ad6 \:2192 \:306a\:305c\:305d\:3046\:8a00\:3048\:308b\:304b \:2192 \:65b9\:6cd5 \:2192 \:7d50\:679c \:2192 \:9650\:754c\:3068\:5c55\:671b",
      "\:7d50\:8ad6 \:2192 " <> StringRiffle[secs, " \:2192 "] <> " \:2192 \:9650\:754c\:3068\:5c55\:671b"];
    head <> "Story: \:7d50\:8ad6\:30d5\:30a1\:30fc\:30b9\:30c8\:3002\:6700\:521d\:306e 1 \:679a\:3067" <>
      If[concl === "", "\:7d50\:8ad6\:3068\:65b0\:898f\:6027", "\:300c" <> concl <> "\:300d\:3068\:3044\:3046\:7d50\:8ad6"] <> "\:3092\:793a\:3059\:3002\n" <>
      "\:9806\:5e8f: " <> order <> "\:3002\n" <>
      "\:5f37\:8abf: \:7d50\:8ad6\:3068\:3001\:305d\:308c\:304c\:65b0\:3057\:3044\:7406\:7531\:3002\n" <>
      "\:56f3\:3084\:8868\:3067\:793a\:305b\:308b\:5185\:5bb9\:306f\:56f3\:3092\:4e3b\:5f79\:306b\:3057\:3001\:7b87\:6761\:66f8\:304d\:306f\:305d\:306e\:8aac\:660e\:306b\:3059\:308b (\:8ad6\:6587\:306e\:56f3\:306f\:95a2\:4fc2\:3059\:308b\:679a\:3067\:898b\:305b\:76f4\:3057\:3001\:7121\:3044\:6240\:306f\:6982\:5ff5\:56f3\:304b\:8868\:3092\:63cf\:304f)\:3002\n" <>
      "\:7701\:304f: \:88c5\:7f6e\:306e\:7d30\:90e8\:3001\:4ed8\:9332\:306e\:88dc\:8db3\:6e2c\:5b9a\:3002\n" <>
      "\:8074\:304d\:624b\:306f\:3053\:306e\:5206\:91ce\:306e\:5c02\:9580\:5bb6\:3067\:306f\:306a\:3044\:306e\:3067\:3001\:521d\:51fa\:306e\:7528\:8a9e\:306f\:4e00\:8a00\:3067\:8a00\:3044\:63db\:3048\:308b\:3002\n" <>
      "\:65b9\:7a0b\:5f0f\:306f\:5f0f\:306e\:5c0e\:51fa\:3067\:306f\:306a\:304f\:300c\:4f55\:3068\:4f55\:304c\:91e3\:308a\:5408\:3063\:3066\:3044\:308b\:304b\:300d\:3092 1 \:884c\:6dfb\:3048\:308b\:3002",
    head = "Graph: \nAudience: undergraduate\nSlides: 20\nMinutes: \nLanguage: en\nStrategy: Source\n";
    order = If[secs === {}, "conclusion -> why it holds -> method -> results -> limits and outlook",
      "conclusion -> " <> StringRiffle[secs, " -> "] <> " -> limits and outlook"];
    head <> "Story: conclusion first. The opening slide states " <>
      If[concl === "", "the conclusion and what is new", "the conclusion: " <> concl] <> ".\n" <>
      "Order: " <> order <> ".\n" <>
      "Emphasis: the conclusion and why it is new.\n" <>
      "Let a figure or table carry each slide where possible, with the bullets explaining it.\n" <>
      "Skip: apparatus details and the supplementary measurements.\n" <>
      "The audience is not from this field, so gloss every term on first use.\n" <>
      "For equations, say what balances what in one line instead of deriving them."]];

SlideInsertStory[nb_NotebookObject] := iSWInsertMeta[nb, "", "SlideStory",
  iSWStoryTemplateText[nb], $iSWStoryCellOpts];

(* ---- \:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:89e3\:6c7a\:3068\:53d6\:308a\:8fbc\:307f ---- *)
iSWKGResolve[kg_Association] := kg;
(* \:6587\:5b57\:5217: \:4fdd\:5b58\:6e08\:307f\:30c7\:30c3\:30ad (.nb) \:306a\:3089 Story \:30bb\:30eb\:306e Graph: \:3092\:3001\:305d\:308c\:4ee5\:5916\:306f graphId \:3068\:3057\:3066\:89e3\:304f *)
iSWKGResolve[path_String /; StringEndsQ[path, ".nb", IgnoreCase -> True] && FileExistsQ[path]] :=
  iSWKGResolve[SlideGraphSpec[path]["Graph"]];
iSWKGResolve[graphId_String] := If[! iSWKGEnsure[], iSWKGFail[],
  With[{g = SourceVault`SourceVaultKGLoad[graphId]},
    If[AssociationQ[g], g,
      Failure["NoGraph", <|"MessageTemplate" -> "knowledge graph `1` is not saved (run SlideGraphBuild first)",
        "MessageParameters" -> {graphId}|>]]]];
iSWKGResolve[nb_NotebookObject] := iSWKGResolve[SlideGraphSpec[nb]["Graph"]];
iSWKGResolve[nbExpr_Notebook] := iSWKGResolve[SlideGraphSpec[nbExpr]["Graph"]];
iSWKGResolve[File[path_String]] := iSWKGResolve[SlideGraphSpec[path]["Graph"]];
iSWKGResolve[_] := Failure["BadGraphSource", <|"MessageTemplate" ->
  "expected a graph id, a knowledge graph association, or a notebook"|>];

SlideGraphLoad[] := iSWKGResolve[iSWResolveTargetNb[]];
SlideGraphLoad[src_] := iSWKGResolve[src];

Options[SlideGraphIngest] = {"Merge" -> False, "Language" -> Automatic, "Title" -> Automatic,
  "Sources" -> Automatic, "Link" -> True};
(* File[path] \:306f JSON \:30d5\:30a1\:30a4\:30eb (UTF-8) \:3092\:8aad\:3080\:3002\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306f Import \:3092\:4f7f\:3048\:306a\:3044\:306e\:3067\:3053\:3053\:3067\:8aad\:3080 *)
SlideGraphIngest[graphId_String, File[path_String], opts : OptionsPattern[]] := Module[{ba},
  ba = If[FileExistsQ[path], Quiet @ Check[ReadByteArray[path], $Failed], $Failed];
  If[! ByteArrayQ[ba],
    Failure["NoFile", <|"MessageTemplate" -> "cannot read `1`", "MessageParameters" -> {path}|>],
    SlideGraphIngest[graphId, ByteArrayToString[ba, "UTF-8"], opts]]];
SlideGraphIngest[graphId_String, json_, OptionsPattern[]] := Module[{kg, existing, res, link = None},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  existing = If[TrueQ[OptionValue["Merge"]], SourceVault`SourceVaultKGLoad[graphId], Missing["NoMerge"]];
  kg = If[AssociationQ[existing],
    SourceVault`SourceVaultKGMerge[existing, json, "Language" -> OptionValue["Language"]],
    SourceVault`SourceVaultKGFromJSON[json]];
  If[! AssociationQ[kg], Return[kg]];
  kg["GraphId"] = graphId;
  If[StringQ[OptionValue["Title"]] && OptionValue["Title"] =!= "", kg["Title"] = OptionValue["Title"]];
  If[ListQ[OptionValue["Sources"]], kg["Sources"] = OptionValue["Sources"]];
  If[TrueQ[OptionValue["Link"]],
    link = Quiet @ Check[SourceVault`SourceVaultKGBackgroundLink[kg], $Failed];
    If[AssociationQ[link], kg = link["Graph"]]];
  res = SourceVault`SourceVaultKGSave[kg];
  If[! StringQ[res],
    Return[Failure["SaveFailed", <|"MessageTemplate" -> "could not save knowledge graph `1`",
      "MessageParameters" -> {graphId}|>]]];
  Success["GraphIngested", <|"GraphId" -> graphId, "NodeCount" -> Length[kg["Nodes"]],
    "EdgeCount" -> Length[kg["Edges"]], "Root" -> kg["Root"],
    "Warnings" -> Take[Lookup[kg, "Warnings", {}], UpTo[10]],
    "Linked" -> If[AssociationQ[link], Length[link["Linked"]], 0],
    "Created" -> If[AssociationQ[link], Length[link["Created"]], 0], "File" -> res|>]];

(* ---- \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:3078\:306e\:59d4\:8b72 (SlideExpand \:3068\:540c\:3058 ClaudeEval \:30bb\:30eb\:65b9\:5f0f) ---- *)
iSWGraphDelegate[nb_, task_String, statusJa_String, statusEn_String] := (
  $SlideTargetNotebook = nb;
  iSWEnsureEndMarkerAtEnd[nb];
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, iSWAgentEvalCell[task], All];
  SelectionEvaluate[nb];
  iSWStatus[nb, iSL[statusJa, statusEn]]);

iSWNoAgentFailure[] := Failure["NoAgent", <|"MessageTemplate" ->
  "ClaudeCode`ClaudeEval is not available (load claudecode.wl)"|>];

iSWGraphBuildTask[spec_Association, refs_List, metaBlocks_String] := Module[
  {nbKeys, pdfKeys, gid = spec["Graph"], prompt},
  nbKeys = Lookup[Select[refs, iSWRefNotebookQ], "Key", {}];
  pdfKeys = Lookup[Select[refs, MemberQ[{"PDF", "arXiv", "Web", "Eagle", "SourceVault"}, #["Kind"]] &], "Key", {}];
  prompt = SourceVault`SourceVaultKGExtractionPrompt["(\:672c\:6587\:306f\:4e0b\:306e\:624b\:9806 1 \:3067 SlideNotebookText \:3092\:4f7f\:3063\:3066\:8aad\:3080)",
    "GraphId" -> gid, "Title" -> spec["Title"], "Language" -> spec["Language"],
    "SourceKey" -> If[nbKeys === {}, "", First[nbKeys]], "PDFKey" -> If[pdfKeys === {}, "", First[pdfKeys]]];
  metaBlocks <>
  "SlideWorkflow \:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:69cb\:7bc9\:30bf\:30b9\:30af\:3002\:3053\:306e\:30c7\:30c3\:30ad\:306e\:6587\:732e (References) \:304b\:3089\:767a\:8868\:7528\:306e\:77e5\:8b58\:30b0\:30e9\:30d5 (KG) \:3092\:62bd\:51fa\:3057\:3001SlideGraphIngest \:3067\:4fdd\:5b58\:3059\:308b\:3002GraphId \:306f \"" <> gid <> "\"\:3002\n\n" <>
  If[StringQ[spec["Story"]] && spec["Story"] =!= "",
    "\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a (\:30ce\:30fc\:30c9\:306e Importance \:3068 Section \:306e\:5207\:308a\:65b9\:306b\:53cd\:6620\:3059\:308b):\n" <> spec["Story"] <> "\n\n", ""] <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <> " (Background \:30ce\:30fc\:30c9\:306e Difficulty \:3068 Domains \:306f\:3053\:306e\:8074\:304d\:624b\:3068\:306e\:5dee\:304c\:5206\:304b\:308b\:3088\:3046\:306b\:4ed8\:3051\:308b)\n\n" <>
  "\:624b\:9806(\:53b3\:5b88):\n" <>
  "1. \:7d20\:6750\:3092\:8aad\:3080\:3002" <>
  If[nbKeys =!= {}, "\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af [" <> StringRiffle[nbKeys, ", "] <>
    "] \:306f SlideNotebookOutline[key] \:3067\:7bc0\:3092\:78ba\:8a8d\:3057\:3001SlideNotebookText[key, \:7bc0] \:3092\:5168\:7bc0\:306b\:3064\:3044\:3066\:8aad\:3080 (\:56f3\:306f [FIGn]\:3001\:5f0f\:306f [EQn] \:3067\:4f4d\:7f6e\:304c\:5206\:304b\:308b)\:3002", ""] <>
  If[pdfKeys =!= {},
    If[nbKeys === {},
      " \:672c\:6587\:306f\:539f\:8ad6\:6587 [" <> StringRiffle[pdfKeys, ", "] <> "] \:3092 ClaudeAttach[SlideSourceFile[key]] \:3067\:6dfb\:4ed8\:3057\:3066\:8aad\:3080 (sv:// / src- \:306e locator \:306f SourceVault \:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e PDF \:306b\:89e3\:6c7a\:3055\:308c\:308b\:3002\:9577\:3044\:8ad6\:6587\:306f sourcevault_get_document \:3067\:672c\:6587\:30c6\:30ad\:30b9\:30c8\:3092\:7bc0\:3054\:3068\:306b\:53d6\:3063\:3066\:3082\:3088\:3044)\:3002\:56f3\:30fb\:8868\:30fb\:5199\:771f\:306f Assets \:306e PDFFigure (Ref=key, Page, Crop) \:3067\:53c2\:7167\:3057\:3001\:30da\:30fc\:30b8\:3068\:9818\:57df\:306f\:6dfb\:4ed8\:3057\:305f PDF \:3067\:78ba\:304b\:3081\:308b\:3002",
      " \:539f\:8ad6\:6587 [" <> StringRiffle[pdfKeys, ", "] <> "] \:306f\:5fc5\:8981\:306a\:3089 ClaudeAttach[SlideSourceFile[key]] \:3067\:56f3\:306e\:30da\:30fc\:30b8\:3092\:78ba\:8a8d\:3059\:308b\:3002"], ""] <>
  " Import / Get \:306f\:4f7f\:308f\:306a\:3044 (ForbiddenHead \:3067\:5373\:6b7b\:3059\:308b)\:3002\n" <>
  "2. \:6b21\:306e\:898f\:5247\:3067 KG \:306e JSON \:3092\:69cb\:6210\:3059\:308b:\n" <> prompt <> "\n" <>
  "3. \:7bc0\:3054\:3068\:306b\:5206\:3051\:3066\:53d6\:308a\:8fbc\:3093\:3067\:3088\:3044\:3002\:6700\:521d\:306f SlideGraphIngest[\"" <> gid <> "\", json] (json \:306f JSON \:6587\:5b57\:5217)\:3001\:4ee5\:964d\:306f SlideGraphIngest[\"" <> gid <>
    "\", json, \"Merge\"->True] \:3067\:5dee\:5206\:3092\:8db3\:3059\:30021 \:56de\:306e\:8a55\:4fa1\:306b 40 \:30ce\:30fc\:30c9\:4ee5\:4e0a\:3092\:8a70\:3081\:8fbc\:307e\:306a\:3044\:3002\:623b\:308a\:5024\:304c Failure \:306a\:3089 JSON \:3092\:76f4\:3057\:3066\:518d\:8a55\:4fa1\:3059\:308b\:3002Success \:306e Warnings \:3092\:78ba\:8a8d\:3057\:3001DanglingEdge \:304c\:3042\:308c\:3070\:8fba\:306e Id \:3092\:76f4\:3059\:3002\n" <>
  "4. \:6700\:5f8c\:306b SlideGraphPlanView[\"" <> gid <> "\"] \:3092\:8a55\:4fa1\:3057\:3066\:9806\:5e8f\:6728\:3068\:8a08\:753b\:3092\:78ba\:8a8d\:3059\:308b (\:30c7\:30c3\:30ad\:3078\:306e\:66f8\:304d\:8fbc\:307f\:306f\:3057\:306a\:3044\:3002\:30b9\:30e9\:30a4\:30c9\:306e\:751f\:6210\:306f\:5229\:7528\:8005\:304c\:30d1\:30ec\:30c3\:30c8\:306e\:300c\:751f\:6210\:300d\:3067\:884c\:3046)\:3002\n" <>
  "5. \:4ee3\:5165\:306f\:5fc5\:305a Module[{...}, ...] \:306e\:4e2d\:306b\:7f6e\:304f (GlobalSetRequiresApproval \:3067\:6b62\:307e\:308b)\:3002"];

(* v1.22: References \:306b\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af (.nb) \:304c\:3042\:308c\:3070 SlideGraphSeed \:3067\:7b2c\:4e00\:6b21 KG \:3092\:6c7a\:5b9a\:7684\:306b\:4f5c\:308a\:3001
   \:7bc0\:3054\:3068\:306e\:63a8\:6572\:3060\:3051\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72\:3059\:308b\:3002\:7121\:3051\:308c\:3070 DocImportPaper \:3092\:6848\:5185\:3057\:3066\:6b62\:307e\:308b
   ("Mode"->"Extract" \:3067\:5f93\:6765\:306e PDF \:76f4\:8aad\:307f\:62bd\:51fa)\:3002 *)
Options[SlideGraphBuild] = {"Mode" -> Automatic};
SlideGraphBuild[opts : OptionsPattern[]] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideGraphBuild[nb, opts]]];
SlideGraphBuild[nb_NotebookObject, OptionsPattern[]] := Module[{spec, refs, nbRefs, seed, mode = OptionValue["Mode"], refine,
    source, parts},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  If[MemberQ[{"Agent", "Extract"}, mode] && ! iSWAgentAvailableQ[], Return[iSWNoAgentFailure[]]];
  spec = SlideGraphSpec[nb];
  refs = iSWReferencesList[nb];
  nbRefs = Select[refs, iSWRefNotebookQ];
  (* v1.30: \:7d20\:6750 = Story \:306e Source: > \:6587\:732e\:306e\:548c\:8a33\:30ce\:30fc\:30c8 > \:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306e\:30b7\:30ca\:30ea\:30aa (\:6587\:66f8\:304c\:7121\:304f\:3066\:3082\:4f5c\:308c\:308b) *)
  source = iSWBuildSourceMode[Lookup[spec, "Source", ""]];
  If[source =!= "Paper" && mode =!= "Extract" && (source === "Scenario" || nbRefs === {}),
    parts = iSWScenarioParts[nb];
    If[parts =!= {} || source === "Scenario", Return[iSWScenarioBuild[nb, spec, parts]]]];
  If[refs === {},
    iSWStatus[nb, iSL["\:7d20\:6750\:304c\:7121\:3044: \:6587\:732e\:306b\:8ad6\:6587\:306e\:548c\:8a33\:30ce\:30fc\:30c8\:3092\:767b\:9332\:3059\:308b\:304b\:3001\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306b\:767a\:8868\:306e\:7b4b\:66f8\:304d (\:30b7\:30ca\:30ea\:30aa) \:3092\:66f8\:304f",
      "No material: add a translated paper to References, or write the outline of the talk in prompt cells"]];
    Return[Failure["NoReferences", <|"MessageTemplate" ->
      "add a References cell ([key] locator | note) with a translated paper notebook, or write the scenario of the talk in prompt cells (Insert > Prompt)"|>]]];
  Which[
    mode === "Extract",
      iSWGraphDelegate[nb,
        iSWGraphBuildTask[spec, refs, iSWReferencesBlock[nb] <> iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb]],
        "\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:62bd\:51fa\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72 (\:8ffd\:8de1\:306f\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:4ee5\:964d)",
        "Delegated KG extraction to agent (see cells after end marker)"];
      Success["Delegated", <|"GraphId" -> spec["Graph"]|>],
    nbRefs === {},
      iSWStatus[nb, iSL["\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:7121\:3044: DocImportPaper \:3067\:4f5c\:3063\:3066\:6587\:732e\:306b\:767b\:9332 (\:8ad6\:6587\:304c\:7121\:3044\:767a\:8868\:306f\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306b\:7b4b\:66f8\:304d\:3092\:66f8\:304f)",
        "No source notebook: run DocImportPaper and add it to References (for a talk without a paper, write the scenario in prompt cells)"]];
      Failure["NoSourceNotebook", <|"MessageTemplate" ->
        "no translated notebook for the References. For an ingested paper run SourceVaultMakePaperNotebook[\"src-...\"] (or DocImportPaper[\"src-...\"]; the sources view has a [+ notebook] button) -- the notebook inherits the source PrivacyLevel and is picked up automatically. For a local PDF run DocImportPaper[path, \"OutputPath\" -> ...] and add \"[key] <name>.nb | ...\" to References (or SlideGraphBuild[nb, \"Mode\" -> \"Extract\"] to read the PDF directly)"|>],
    True,
      seed = SlideGraphSeed[nb];
      If[! AssociationQ[seed], Return[seed]];
      If[mode =!= "Agent",
        refine = iSWRefineStart[nb, spec, seed["KG"], 8, All];
        Return[Success["Seeded", <|"GraphId" -> seed["Graph"], "NodeCount" -> seed["NodeCount"], "Sections" -> seed["Sections"],
          "Kept" -> Lookup[seed, "Kept", 0], "Skipped" -> Lookup[seed, "Skipped", <||>], "Refine" -> refine|>]]];
      iSWGraphDelegate[nb, iSWGraphRefineTask[spec, seed["KG"], iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb]],
        "\:7b2c\:4e00\:6b21 KG (" <> ToString[seed["NodeCount"]] <> " \:30ce\:30fc\:30c9) \:3092\:4f5c\:6210\:3001\:7bc0\:3054\:3068\:306e\:63a8\:6572\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72",
        "Seeded the KG (" <> ToString[seed["NodeCount"]] <> " nodes); delegated refinement to agent"];
      Success["Seeded", <|"GraphId" -> seed["Graph"], "NodeCount" -> seed["NodeCount"], "Sections" -> seed["Sections"], "Kept" -> Lookup[seed, "Kept", 0], "Skipped" -> Lookup[seed, "Skipped", <||>]|>]]];

iSWGraphBackgroundTask[spec_Association, kg_Association] := With[{gid = spec["Graph"]},
  "SlideWorkflow \:306e\:5468\:8fba\:77e5\:8b58\:8ffd\:52a0\:30bf\:30b9\:30af\:3002GraphId \"" <> gid <> "\" \:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:306b\:3001\:8074\:304d\:624b (" <>
    ToString[spec["Audience"]] <> ") \:306b\:8db3\:308a\:306a\:3044\:524d\:63d0\:77e5\:8b58\:30ce\:30fc\:30c9\:3092\:5dee\:5206\:3067\:8db3\:3059\:3002\n\n" <>
  If[StringQ[spec["Story"]] && spec["Story"] =!= "",
    "\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a (\:3069\:306e\:524d\:63d0\:77e5\:8b58\:3092\:8db3\:3059\:304b\:306f\:3053\:308c\:3067\:6c7a\:307e\:308b\:3002\:300cintroduction \:306f\:95a2\:9023\:8ad6\:6587\:3092\:5f15\:7528\:3057\:3066\:89e3\:8aac\:300d\:306e\:3088\:3046\:306a\:8981\:6c42\:306f\:3053\:3053\:306b\:66f8\:304b\:308c\:308b):\n" <>
      spec["Story"] <> "\n\n", ""] <>
  SourceVault`SourceVaultKGBackgroundPrompt[kg, spec["Audience"]] <> "\n\n" <>
  "\:624b\:9806(\:53b3\:5b88): 1. \:4e0a\:306e\:6307\:793a\:306b\:5f93\:3044\:5dee\:5206 JSON \:3092\:4f5c\:308b (\:65e2\:5b58\:30ce\:30fc\:30c9\:306e Id \:306f\:305d\:306e\:307e\:307e\:4f7f\:3046)\:30022. SlideGraphIngest[\"" <> gid <>
    "\", json, \"Merge\"->True] \:3092\:4e00\:5ea6\:3060\:3051\:8a55\:4fa1\:3059\:308b (\:5171\:6709 background \:5c64\:3068\:306e\:9023\:7d50\:306f\:81ea\:52d5)\:3002Failure \:306a\:3089\:76f4\:3057\:3066\:518d\:8a55\:4fa1\:30023. SlideGraphPlanView[\"" <>
    gid <> "\"] \:3067\:78ba\:8a8d\:3059\:308b\:30024. \:4ee3\:5165\:306f Module \:5185\:3002Import / Get \:306f\:4f7f\:308f\:306a\:3044\:3002"];

SlideGraphBackground[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideGraphBackground[nb]]];
SlideGraphBackground[nb_NotebookObject] := Module[{spec, kg},
  If[! iSWAgentAvailableQ[], Return[iSWNoAgentFailure[]]];
  spec = SlideGraphSpec[nb];
  kg = iSWKGResolve[spec["Graph"]];
  If[! AssociationQ[kg], iSWStatus[nb, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; Return[kg]];
  iSWGraphDelegate[nb, iSWDirectivesBlock[nb] <> iSWGraphBackgroundTask[spec, kg],
    "\:5468\:8fba\:77e5\:8b58\:306e\:8ffd\:52a0\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72", "Delegated background-knowledge pass to agent"];
  Success["Delegated", <|"GraphId" -> spec["Graph"]|>]];

SlideGraphTranslate[nb_NotebookObject, lang_String : "en"] := Module[{spec, kg, code},
  If[! iSWAgentAvailableQ[], Return[iSWNoAgentFailure[]]];
  spec = SlideGraphSpec[nb];
  kg = iSWKGResolve[spec["Graph"]];
  If[! AssociationQ[kg], Return[kg]];
  code = iSWKGLangCode[lang];
  iSWGraphDelegate[nb,
    iSWDictionaryBlock[nb] <> "SlideWorkflow \:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:7ffb\:8a33\:30bf\:30b9\:30af\:3002GraphId \"" <> spec["Graph"] <> "\"\:3002\n\n" <>
      SourceVault`SourceVaultKGTranslatePrompt[kg, code] <>
      "\n\n\:624b\:9806(\:53b3\:5b88): \:7ffb\:8a33 JSON \:3092 SlideGraphIngest[\"" <> spec["Graph"] <> "\", json, \"Merge\"->True, \"Language\"->\"" <> code <>
      "\"] \:3067\:53d6\:308a\:8fbc\:3080 (\:30ce\:30fc\:30c9\:6570\:304c\:591a\:3051\:308c\:3070 30 \:30ce\:30fc\:30c9\:305a\:3064\:5206\:3051\:3066\:4f55\:5ea6\:304b\:547c\:3076)\:3002Dictionary \:306e\:7528\:8a9e\:5bfe\:5fdc\:3092\:53b3\:5b88\:3002\:4ee3\:5165\:306f Module \:5185\:3002",
    "\:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:7ffb\:8a33\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72", "Delegated KG translation to agent"];
  Success["Delegated", <|"GraphId" -> spec["Graph"], "Language" -> code|>]];

(* ---- \:8a08\:753b (\:6c7a\:5b9a\:7684) ---- *)
Options[SlideGraphPlan] = {"Slides" -> Automatic, "Seconds" -> Automatic, "Audience" -> Automatic,
  "Strategy" -> Automatic, "SecondsPerSlide" -> Automatic, "Language" -> Automatic, "Spec" -> Automatic};

iSWNotOptionQ[x_] := ! MatchQ[x, _Rule | _RuleDelayed];

SlideGraphPlan[opts : OptionsPattern[]] := SlideGraphPlan[iSWResolveTargetNb[], opts];
SlideGraphPlan[src_?iSWNotOptionQ, OptionsPattern[]] := Module[
  {spec, kg, tree, plan, strategy, slides, seconds, aud, sps, lang},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  kg = iSWKGResolve[src];
  If[! AssociationQ[kg], Return[kg]];
  spec = Which[
    AssociationQ[OptionValue["Spec"]], Join[$iSWStoryDefaults, OptionValue["Spec"]],
    Head[src] === NotebookObject || Head[src] === Notebook || Head[src] === File ||
      (StringQ[src] && StringEndsQ[src, ".nb", IgnoreCase -> True] && FileExistsQ[src]), SlideGraphSpec[Replace[src, File[p_] :> p]],
    True, Join[$iSWStoryDefaults, <|"Graph" -> kg["GraphId"], "Title" -> kg["Title"], "Language" -> kg["Language"]|>]];
  strategy = Replace[OptionValue["Strategy"], Automatic -> spec["Strategy"]];
  If[! StringQ[strategy], strategy = "Source"];
  slides = Replace[OptionValue["Slides"], Automatic -> spec["Slides"]];
  seconds = Replace[OptionValue["Seconds"], Automatic -> spec["Seconds"]];
  aud = Replace[OptionValue["Audience"], Automatic -> spec["Audience"]];
  sps = Replace[OptionValue["SecondsPerSlide"], Automatic -> spec["SecondsPerSlide"]];
  If[! NumericQ[sps], sps = N[$SlideTalkSecondsPerSlide]];
  lang = iSWKGLangCode[Replace[OptionValue["Language"], Automatic -> Lookup[spec, "Language", kg["Language"]]]];
  tree = SourceVault`SourceVaultKGOrderedTree[kg, "Strategy" -> strategy];
  If[! AssociationQ[tree], Return[tree]];
  plan = SourceVault`SourceVaultKGPlan[kg, tree,
    "Slides" -> If[IntegerQ[slides] && slides > 0, slides, Automatic],
    "Seconds" -> If[NumericQ[seconds] && seconds > 0, seconds, Automatic],
    "SecondsPerSlide" -> sps, "Audience" -> aud];
  <|"Graph" -> kg, "Tree" -> tree, "Plan" -> plan,
    "Verify" -> <|"Tree" -> SourceVault`SourceVaultKGVerify[kg, tree],
      "Plan" -> SourceVault`SourceVaultKGVerifyPlan[kg, plan]|>,
    "Spec" -> Join[spec, <|"Strategy" -> strategy, "Slides" -> slides, "Seconds" -> seconds,
      "Audience" -> aud, "SecondsPerSlide" -> sps, "Language" -> lang|>]|>];

SlideGraphPlanView[opts : OptionsPattern[SlideGraphPlan]] := SlideGraphPlanView[iSWResolveTargetNb[], opts];
SlideGraphPlanView[src_?iSWNotOptionQ, opts : OptionsPattern[SlideGraphPlan]] :=
  With[{p = SlideGraphPlan[src, opts]},
    If[! AssociationQ[p], p, SourceVault`SourceVaultKGPlanView[p["Graph"], p["Plan"]]]];

(* ---- \:56f3\:89e3\:306e\:30b3\:30fc\:30c9: \:4f5c\:56f3\:3068\:6570\:5b66\:306e\:7d44\:8fbc\:307f\:95a2\:6570\:3060\:3051\:3092\:901a\:3059 (\:30d5\:30a1\:30a4\:30eb\:30fb\:30cd\:30c3\:30c8\:30ef\:30fc\:30af\:30fb\:5916\:90e8\:5b9f\:884c\:306f\:901a\:3055\:306a\:3044)\:3002
   \:8aad\:307f\:53d6\:308a\:306f\:9694\:96e2\:3057\:305f\:6587\:8108 (\:672a\:77e5\:306e\:540d\:524d\:306f\:305d\:3053\:306b\:4f5c\:3089\:308c\:308b) \:3067\:884c\:3044\:3001\:8a55\:4fa1\:306f\:6642\:9593\:3068\:30e1\:30e2\:30ea\:3092\:533a\:5207\:308b ---- *)
$iSWFigureHeadNames = {"Graphics", "Show", "Plot", "ListPlot", "ListLinePlot", "ParametricPlot", "PolarPlot", "LogPlot",
  "LogLinearPlot", "DensityPlot", "ContourPlot", "RegionPlot", "BarChart", "Histogram", "BoxWhiskerChart", "PieChart",
  "NumberLinePlot", "ArrayPlot", "MatrixPlot", "StreamPlot", "VectorPlot", "GraphicsRow", "GraphicsColumn", "GraphicsGrid",
  "Graph", "DirectedEdge", "UndirectedEdge", "Labeled", "Legended", "LineLegend", "PointLegend", "SwatchLegend", "Placed",
  "Callout", "Inset", "Text", "Style", "Line", "Arrow", "Arrowheads", "Circle", "Disk", "Rectangle", "Polygon", "Point",
  "BezierCurve", "BSplineCurve", "Annulus", "Triangle", "RegularPolygon", "FilledCurve", "JoinedCurve", "Thickness",
  "AbsoluteThickness", "Dashing", "AbsoluteDashing", "Opacity", "EdgeForm", "FaceForm", "RGBColor", "GrayLevel", "Hue",
  "Lighter", "Darker", "Blend", "Directive", "PointSize", "AbsolutePointSize", "Offset", "Scaled", "ImageScaled", "Framed",
  "Row", "Column", "Grid", "Pane", "Table", "Range", "Subdivide", "Map", "MapIndexed", "MapThread", "Apply", "Function",
  "Slot", "SlotSequence", "List", "Rule", "RuleDelayed", "Part", "Span", "First", "Last", "Rest", "Most", "Take", "Drop",
  "Join", "Append", "Prepend", "Length", "Partition", "Flatten", "Transpose", "Accumulate", "Differences", "Reverse",
  "Sort", "SortBy", "Total", "Mean", "Module", "With", "If", "Which", "Switch", "And", "Or", "Not", "Equal", "Unequal",
  "Less", "Greater", "LessEqual", "GreaterEqual", "SameQ", "UnsameQ", "CompoundExpression", "Set", "SetDelayed", "Blank",
  "Pattern", "Plus", "Times", "Power", "Subtract", "Divide", "Minus", "N", "Clip", "Rescale", "Piecewise", "Boole",
  "Evaluate", "Tooltip", "Sequence", "Nothing", "ToString", "StringJoin", "TextString", "NumberForm", "Subscript",
  "Superscript", "Overscript", "Underscript", "TraditionalForm", "HoldForm", "Nest", "NestList", "Fold", "FoldList",
  "Interpolation", "ListInterpolation", "NDSolveValue", "DSolveValue", "D", "Integrate", "NIntegrate", "Sum", "Product",
  "Normal", "Norm", "Dot", "Cross", "RotationTransform", "TranslationTransform", "ScalingTransform",
  "GeometricTransformation", "Translate", "Rotate", "Scale", "CirclePoints", "AngleVector", "Thread", "ConstantArray",
  "RandomReal", "RandomInteger", "SeedRandom", "BlockRandom", "Riffle", "Tuples", "Outer", "Array", "Count", "Select",
  "Cases", "Position", "Tally", "Union", "Complement", "Intersection", "DeleteDuplicates", "Chop", "Increment",
  "AddTo", "Do", "Association", "Lookup", "Key", "Keys", "Values", "Pi", "E", "I", "Infinity", "Degree", "True", "False",
  "None", "Automatic", "All", "Full", "Null", "Top", "Bottom", "Left", "Right", "Center", "Above", "Below", "Before",
  "After", "Black", "White", "Gray", "Red", "Green", "Blue", "Orange", "Purple", "Brown", "Pink", "Yellow", "Cyan",
  "Magenta", "LightGray", "LightBlue", "LightRed", "LightGreen", "LightOrange", "LightYellow", "Thick", "Thin", "Dashed",
  "Dotted", "DotDashed", "Bold", "Italic", "Plain", "Large", "Medium", "Small", "Tiny", "Larger", "Smaller", "Axis",
  "Scaled", "Filling", "Frame", "FrameLabel", "PlotLabel", "AxesLabel", "Ticks", "FrameTicks", "PlotRange",
  "PlotStyle", "PlotLegends", "AspectRatio", "Axes", "AxesOrigin", "GridLines", "Background", "Epilog", "Prolog",
  "PlotRangePadding", "ImagePadding", "Joined", "Mesh", "Exclusions", "ColorFunction", "ChartLabels", "ChartStyle",
  "BarSpacing", "VertexLabels", "EdgeLabels", "VertexStyle", "EdgeStyle", "VertexSize", "GraphLayout",
  "VertexCoordinates", "VertexShapeFunction", "FontSize", "FontWeight", "FontColor", "FontSlant", "LabelStyle",
  "BaseStyle", "Alignment", "Spacings", "Dividers", "FrameStyle", "RoundingRadius", "FrameMargins", "ImageMargins",
  "LineLegend", "LegendMarkers", "Method", "MaxRecursion", "PlotPoints", "WorkingPrecision", "Epilog", "Opacity",
  "Arrowheads", "CapForm", "JoinForm", "Round", "Floor", "Ceiling", "Max", "Min", "Abs", "Mod", "Quotient", "Sign",
  "UnitStep", "HeavisideTheta", "Exp", "Log", "Sqrt", "Sin", "Cos", "Tan", "ArcTan", "Sinh", "Cosh", "Tanh", "Erf",
  "Gamma", "Re", "Im", "Arg", "Conjugate", "Log10", "Log2", "ArcSin", "ArcCos", "Sech", "LogisticSigmoid", "Ramp",
  "HoldComplete", "FontFamily", "ImageSize"};
iSWFigureSymbolOKQ[{ctx_String, name_String}] := Which[
  ctx === "SWFigSandbox`", ! StringStartsQ[name, "$"],
  ctx === "System`", MemberQ[$iSWFigureHeadNames, name] ||
    MemberQ[Quiet[Attributes[name]], NumericFunction],
  True, False];
iSWFigureHeld[code_String] := Block[{$Context = "SWFigSandbox`", $ContextPath = {"System`"}},
  Quiet @ Check[ToExpression[code, InputForm, HoldComplete], $Failed]];
iSWSafeFigureCodeQ[code_String] := Module[{held, syms},
  If[StringLength[code] > 6000, Return[False]];
  held = iSWFigureHeld[code];
  If[Head[held] =!= HoldComplete || Length[held] =!= 1, Return[False]];
  syms = DeleteDuplicates[Cases[held, s_Symbol :> {Context[s], SymbolName[Unevaluated[s]]}, {0, Infinity}, Heads -> True]];
  AllTrue[syms, iSWFigureSymbolOKQ]];
iSWSafeFigureCodeQ[_] := False;
iSWFigureFromCode[code_String] := Module[{held, r},
  If[! iSWSafeFigureCodeQ[code], Return[$Failed]];
  held = iSWFigureHeld[code];
  r = Block[{$Context = "SWFigSandbox`", $ContextPath = {"System`"}},
    Quiet @ Check[TimeConstrained[MemoryConstrained[ReleaseHold[held], 3*^8, $Failed], 20, $Failed], $Failed]];
  Quiet[ClearAll["SWFigSandbox`*"]];
  If[MatchQ[r, _Graphics | _Legended | _Graph | _Labeled], r, $Failed]];
iSWFigureFromCode[_] := $Failed;
(* \:63cf\:753b: \:30c7\:30c3\:30ad\:306e\:5b57\:4f53\:3067\:3001\:4e0b\:306b\:77ed\:3044\:8aac\:660e\:3092\:4ed8\:3051\:3066\:753b\:50cf\:306b\:3059\:308b *)
iSWFigureRender[code_, caption_] := Module[{g = iSWFigureFromCode[code], fam = $SlideFontFamily},
  If[g === $Failed, Return[$Failed]];
  g = If[Head[g] === Graphics, Show[g, ImageSize -> 560, BaseStyle -> {FontFamily -> fam, FontSize -> 14}],
    Style[g, FontFamily -> fam, FontSize -> 14]];
  If[StringQ[caption] && caption =!= "",
    g = Labeled[g, Style[caption, FontFamily -> fam, FontSize -> 12, GrayLevel[0.4]], Bottom]];
  Quiet @ Check[Rasterize[g, ImageResolution -> 144], $Failed]];

(* ---- \:8cc7\:7523\:306e\:5b9f\:4f53\:5316 ---- *)
iSWKGCrop[c_] := If[MatchQ[c, {{_?NumericQ, _?NumericQ}, {_?NumericQ, _?NumericQ}}], c, None];

iSWKGRealizeAsset[a_Association] := Module[
  {type = ToString[Lookup[a, "Type", ""]], ref = ToString[Lookup[a, "Ref", Lookup[a, "Deck", Lookup[a, "Path", ""]]]], n, r},
  n = Lookup[a, "N", Lookup[a, "Page", Lookup[a, "Slide", 1]]];
  If[! IntegerQ[n], n = 1];
  r = Quiet @ Check[Switch[type,
    "NotebookFigure", SlideNotebookFigure[ref, n],
    "Formula", SlideNotebookFormula[ref, n],
    "PDFFigure", SlidePDFFigure[ref, n, "Crop" -> iSWKGCrop[Lookup[a, "Crop", None]]],
    "DeckSlide", SlideDeckFigure[ref, n],
    "WLFigure", iSWFigureRender[Lookup[a, "Code", ""], Lookup[a, "Caption", ""]],
    "PDFImage", With[{l = SlidePDFImages[ref, "Page" -> Replace[Lookup[a, "Page", 1], Except[_Integer] -> 1], "MinSize" -> 0],
        k = Replace[Lookup[a, "N", 1], Except[_Integer] -> 1]},
      If[ListQ[l] && 1 <= k <= Length[l], l[[k]], $Failed]],
    _, $Failed], $Failed];
  If[ImageQ[r] || MatchQ[r, _Cell | _Graphics | _Graphics3D], r, $Failed]];
iSWKGRealizeAsset[___] := $Failed;

(* \:5b9f\:4f53\:5316\:306b\:5931\:6557\:3057\:305f <<FIGn>> \:3092\:843d\:3068\:3057\:3066\:4ed8\:756a\:3057\:76f4\:3059 (StringReplace \:306e\:898f\:5247\:30ea\:30b9\:30c8\:306f\:540c\:6642\:9069\:7528) *)
iSWKGRenumberFigures[md_String, results_List] := Module[{k = 0, dropRules, rules},
  dropRules = Flatten[MapIndexed[If[#1 === $Failed,
    {"<<FIG" <> ToString[First[#2]] <> ">>\n" -> "", "<<FIG" <> ToString[First[#2]] <> ">>" -> ""}, {}] &, results]];
  rules = MapIndexed[If[#1 === $Failed, Nothing,
    (k++; "<<FIG" <> ToString[First[#2]] <> ">>" -> "<<FIG" <> ToString[k] <> ">>")] &, results];
  StringReplace[If[dropRules === {}, md, StringReplace[md, dropRules]], rules]];

(* KG \:306e\:30ce\:30fc\:30c9\:306b\:6b8b\:3057\:305f\:884c\:5185\:6570\:5f0f\:8f9e\:66f8 (tex \:2192 boxes) \:3092\:96c6\:3081\:308b *)
iSWKGFormulaDict[kg_Association] := Association[Flatten[Map[Function[n,
  Map[Function[fm, If[AssociationQ[fm] && StringQ[Lookup[fm, "Tex", None]] && StringQ[Lookup[fm, "Boxes", None]],
      fm["Tex"] -> fm["Boxes"], Nothing]], Replace[Lookup[n, "Formulas", {}], Except[_List] -> {}]]],
  Lookup[kg, "Nodes", {}]]]];
iSWKGFormulaDict[_] := <||>;

(* \:751f\:6210\:306e\:7d4c\:904e\:3092\:72b6\:614b\:6b04\:306b\:51fa\:3059 (\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304c\:3042\:308b\:3068\:304d\:3060\:3051)\:3002\:300c\:751f\:6210\:300d\:3092\:62bc\:3057\:3066\:304b\:3089\:4f55\:3082\:51fa\:306a\:3044\:6642\:9593\:3092\:4f5c\:3089\:306a\:3044 *)
iSWGenProgress[nb_NotebookObject, ja_String, en_String] := iSWStatus[nb, iSL[ja, en]];
iSWGenProgress[___] := Null;
(* \:56f3\:306e\:6e96\:5099\:306e\:7d4c\:904e: {\:30ce\:30fc\:30c8\:30d6\:30c3\:30af, \:65e5\:672c\:8a9e\:306e\:524d\:7f6e\:304d, \:82f1\:8a9e\:306e\:524d\:7f6e\:304d} \:3092 Block \:3067\:6e21\:3059 *)
$iSWRealizeProgress = None;
iSWKGRealizeMarkdown[outline_Association, slides_List, nb_, kg_ : None] := Module[{mdA, results, figs, warnings = {}, md, nA},
  mdA = SourceVault`SourceVaultKGOutlineToMarkdown[Join[outline, <|"Slides" -> slides|>]];
  nA = Length[mdA["Assets"]];
  results = Block[{$SlideTargetNotebook = If[Head[nb] === NotebookObject, nb, $SlideTargetNotebook],
      $iSWKGSources = If[AssociationQ[kg], Lookup[kg, "Sources", {}], $iSWKGSources]},
    MapIndexed[Function[{a, i},
      If[ListQ[$iSWRealizeProgress] && Length[$iSWRealizeProgress] === 3,
        iSWGenProgress[$iSWRealizeProgress[[1]],
          $iSWRealizeProgress[[2]] <> "\:56f3\:3092\:6e96\:5099\:4e2d (" <> ToString[First[i]] <> "/" <> ToString[nA] <> ")\:2026",
          $iSWRealizeProgress[[3]] <> "preparing figure " <> ToString[First[i]] <> "/" <> ToString[nA] <> "..."]];
      iSWKGRealizeAsset[a]], mdA["Assets"]]];
  figs = DeleteCases[results, $Failed];
  Do[If[results[[i]] === $Failed,
      AppendTo[warnings, "AssetFailed: " <> StringTake[ToString[mdA["Assets"][[i]], InputForm], UpTo[160]]]],
    {i, Length[results]}];
  md = iSWKGRenumberFigures[mdA["Markdown"], results];
  <|"Markdown" -> md, "Figures" -> figs, "Warnings" -> warnings, "SlideCount" -> Length[slides]|>];

(* ---- \:751f\:6210 (md + \:56f3) ---- *)
Options[SlideGraphGenerate] = Join[Options[SlideGraphPlan],
  {"Notebook" -> Automatic, "Talks" -> None, "Title" -> Automatic, "Outline" -> {}, "Realize" -> True}];
SlideGraphGenerate[opts : OptionsPattern[]] := SlideGraphGenerate[iSWResolveTargetNb[], opts];
SlideGraphGenerate[src_?iSWNotOptionQ, opts : OptionsPattern[]] := Module[
  {p, outline, lang, talks, nb, r, warnings = {},
   olOpts = FilterRules[Replace[OptionValue["Outline"], Except[_List] -> {}], Options[SourceVault`SourceVaultKGOutline]],
   pnb = If[Head[src] === NotebookObject, src, OptionValue["Notebook"]]},
  iSWGenProgress[pnb, "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210: \:8a08\:753b\:3092\:4f5c\:6210\:4e2d\:2026", "Generating from the KG: planning..."];
  p = SlideGraphPlan[src, Sequence @@ FilterRules[{opts}, Options[SlideGraphPlan]]];
  If[! AssociationQ[p], Return[p]];
  lang = p["Spec"]["Language"];
  iSWGenProgress[pnb, "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210: \:30b9\:30e9\:30a4\:30c9\:69cb\:6210\:3092\:4f5c\:6210\:4e2d\:2026", "Generating from the KG: building the outline..."];
  outline = SourceVault`SourceVaultKGOutline[p["Graph"], p["Plan"], "Language" -> lang, Sequence @@ olOpts];
  (* \:76ee\:6b21 (\:5168\:4f53\:306e\:6d41\:308c) \:304c\:5165\:308b\:3068\:304d\:306f\:6307\:5b9a\:679a\:6570\:306b\:53ce\:307e\:308b\:3088\:3046 1 \:679a\:5c11\:306a\:304f\:8a08\:753b\:3057\:76f4\:3059 *)
  (* \:76ee\:6b21\:3084 (\:7d9a\:304d) \:306e\:679a\:3067\:6307\:5b9a\:679a\:6570\:3092\:8d85\:3048\:308b\:3068\:304d\:306f\:3001\:305d\:306e\:5206\:3060\:3051\:5c11\:306a\:304f\:8a08\:753b\:3057\:76f4\:3059 (\:6700\:5927 2 \:56de) *)
  Module[{want = Lookup[p["Spec"], "Slides", None], extra, p2, tries = 0},
    If[IntegerQ[want] && want > 3,
      (* \:8d85\:904e (\:76ee\:6b21\:30fb\:7d9a\:304d) \:306f\:6e1b\:3089\:3057\:3001\:4e0d\:8db3 (1 \:5b50\:7bc0\:306e\:7573\:307f\:8fbc\:307f) \:306f\:5897\:3084\:3057\:3066\:53d6\:308a\:76f4\:3059\:3002\:5019\:88dc\:304c\:5c3d\:304d\:305f\:3089\:8ae6\:3081\:308b *)
      While[(extra = Length[outline["Slides"]] - want) =!= 0 && want - extra >= 3 && tries < 3 &&
          (extra > 0 || Length[Lookup[p["Plan"], "Pruned", {}]] > 0),
        tries++;
        iSWGenProgress[pnb, "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210: " <> ToString[want] <> " \:679a\:306b\:5408\:308f\:305b\:3066\:8a08\:753b\:3057\:76f4\:3057\:4e2d (" <> ToString[tries] <> " \:56de\:76ee)\:2026",
          "Generating from the KG: re-planning for " <> ToString[want] <> " slides (" <> ToString[tries] <> ")..."];
        p2 = SlideGraphPlan[src, "Slides" -> want - extra, Sequence @@ FilterRules[FilterRules[{opts}, Options[SlideGraphPlan]], Except["Slides"]]];
        If[! AssociationQ[p2], Break[]];
        p = p2; outline = SourceVault`SourceVaultKGOutline[p["Graph"], p["Plan"], "Language" -> lang, Sequence @@ olOpts]]]];
  (* \:9806\:5e8f\:6728\:304b\:3089\:843d\:3061\:305f\:30ce\:30fc\:30c9\:304c\:3042\:308b\:3068\:3001\:305d\:306e\:5148\:306e\:5185\:5bb9\:304c\:9ed9\:3063\:3066\:751f\:6210\:3055\:308c\:306a\:3044 (\:8a08\:7b97\:3068\:81ea\:713633: 45 \:679a\:306e\:6307\:5b9a\:3067 23 \:679a)\:3002
     \:843d\:3061\:305f\:3053\:3068\:81ea\:4f53\:3092\:8b66\:544a\:306b\:3057\:3066\:5229\:7528\:8005\:306b\:898b\:305b\:308b *)
  With[{tv = Lookup[Lookup[p, "Verify", <||>], "Tree", <||>], want = Lookup[p["Spec"], "Slides", None]},
    If[Lookup[tv, "Orphans", {}] =!= {},
      AppendTo[warnings, "BrokenTree: " <> ToString[Length[tv["Orphans"]]] <>
        " \:30ce\:30fc\:30c9\:304c\:9806\:5e8f\:6728\:306b\:5165\:3089\:305a\:751f\:6210\:304b\:3089\:5916\:308c\:307e\:3057\:305f (" <> StringRiffle[Take[tv["Orphans"], UpTo[6]], ", "] <> " \:2026)"]];
    If[IntegerQ[want] && Length[outline["Slides"]] < want - 3,
      AppendTo[warnings, "Shortfall: \:6307\:5b9a " <> ToString[want] <> " \:679a\:306b\:5bfe\:3057\:3066 " <> ToString[Length[outline["Slides"]]] <>
        " \:679a (\:524d\:63d0\:3068\:3057\:3066\:7701\:3044\:305f " <> ToString[Length[Lookup[p["Plan"], "Assumed", {}]]] <> " \:30ce\:30fc\:30c9\:3001\:843d\:3068\:3057\:305f " <>
        ToString[Length[Lookup[p["Plan"], "Pruned", {}]]] <> " \:30ce\:30fc\:30c9)"]]];
  With[{un = iSWUnrefinedSections[p["Graph"]]},
    If[un =!= {},
      PrependTo[warnings, "Unrefined: " <> iSL[
        "\:63a8\:6572\:304c\:6e08\:3093\:3067\:3044\:306a\:3044\:7bc0\:304c " <> ToString[Length[un]] <> " \:3042\:308a\:307e\:3059 (" <> iSWUnrefinedNote[p["Graph"], un] <>
          ")\:3002\:305d\:306e\:679a\:306e\:7b87\:6761\:66f8\:304d\:306f\:6bb5\:843d\:306e\:66f8\:304d\:51fa\:3057\:306e\:307e\:307e (\:300c\:2026\:300d\:3067\:5207\:308c\:308b) \:3067\:3059\:3002\:300c\:63a8\:6572\:300d\:304b\:300c\:56f3\:89e3\:300d\:3092\:62bc\:3059\:3068\:3001\:305d\:306e\:7bc0\:304b\:3089\:63a8\:6572\:3057\:307e\:3059",
        ToString[Length[un]] <> " sections are not refined (" <> iSWUnrefinedNote[p["Graph"], un] <>
          "); their bullets are raw paragraph openings. Press Refine (or Visuals) to refine them"]]]];
  If[Lookup[outline, "MissingLanguage", {}] =!= {},
    AppendTo[warnings, "MissingLanguage(" <> lang <> "): " <>
      StringRiffle[Take[outline["MissingLanguage"], UpTo[8]], ", "] <>
      " (SlideGraphTranslate \:3067\:30ce\:30fc\:30c9\:5358\:4f4d\:306e\:8a33\:3092\:8db3\:3059)"]];
  (* \:8cea\:7591\:5fdc\:7b54: KG \:306e\:30ce\:30fc\:30c9\:306b\:4fdd\:5b58\:3057\:305f\:554f\:7b54\:3092\:3001\:305d\:306e\:30ce\:30fc\:30c9\:306e\:679a\:3078\:623b\:3059 (\:751f\:6210\:3057\:76f4\:3057\:3066\:3082\:6d88\:3048\:306a\:3044) *)
  outline = iSWKGAttachQA[outline, p["Graph"]];
  talks = OptionValue["Talks"];
  If[ListQ[talks] && talks =!= {},
    outline["Slides"] = MapIndexed[Function[{s, i},
      If[First[i] <= Length[talks] && StringQ[talks[[First[i]]]] && StringTrim[talks[[First[i]]]] =!= "",
        Append[s, "Talk" -> talks[[First[i]]]], s]], outline["Slides"]]];
  If[StringQ[OptionValue["Title"]], outline["Title"] = OptionValue["Title"]];
  nb = Replace[OptionValue["Notebook"], Automatic -> If[Head[src] === NotebookObject, src, None]];
  (* "Realize" -> False: \:56f3\:306f\:5b9f\:4f53\:5316\:3057\:306a\:3044 (\:300c\:751f\:6210\:300d\:306f 10 \:679a\:305a\:3064\:5b9f\:4f53\:5316\:3059\:308b\:306e\:3067\:3001\:3053\:3053\:3067\:5168\:90e8\:4f5c\:308b\:3068\:4e8c\:5ea6\:624b\:9593) *)
  r = If[TrueQ[OptionValue["Realize"]],
    Block[{$iSWRealizeProgress = {pnb, "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210: ", "Generating from the KG: "}},
      iSWKGRealizeMarkdown[outline, outline["Slides"], nb, p["Graph"]]],
    <|"Markdown" -> SourceVault`SourceVaultKGOutlineToMarkdown[outline]["Markdown"], "Figures" -> {}, "Warnings" -> {}|>];
  <|"Markdown" -> r["Markdown"], "Figures" -> r["Figures"], "Plan" -> p["Plan"], "Tree" -> p["Tree"],
    "Outline" -> outline, "Graph" -> p["Graph"], "Spec" -> p["Spec"], "Verify" -> p["Verify"],
    "Warnings" -> Join[warnings, r["Warnings"]], "SlideCount" -> Length[outline["Slides"]]|>];

(* ---- \:30c7\:30c3\:30ad\:3078\:306e\:9069\:7528 ---- *)
iSWGraphPolishTask[gen_Association, gid_String, metaBlocks_String] :=
  metaBlocks <>
  "SlideWorkflow \:306e\:767a\:8868\:539f\:7a3f (talk) \:63a8\:6572\:30bf\:30b9\:30af\:3002GraphId \"" <> gid <> "\" \:304b\:3089\:751f\:6210\:3057\:305f\:30b9\:30e9\:30a4\:30c9\:69cb\:6210\:306e talk \:3092\:78e8\:304f\:3002\n\n" <>
  SourceVault`SourceVaultKGTalkPrompt[gen["Outline"]] <> "\n\n" <>
  "\:624b\:9806(\:53b3\:5b88): 1. \:4e0a\:306e Talks \:3092\:4f5c\:308b (\:69cb\:6210\:30fb\:9806\:5e8f\:30fb\:30bf\:30a4\:30c8\:30eb\:30fb\:7b87\:6761\:66f8\:304d\:306f\:5909\:3048\:306a\:3044\:3002\:30b9\:30e9\:30a4\:30c9\:306b\:7121\:3044\:4e8b\:5b9f\:3092\:4f5c\:3089\:306a\:3044)\:3002" <>
  "2. SlideGraphApply[\"Talks\"->{talk1, talk2, ...}] \:3092\:4e00\:5ea6\:3060\:3051\:8a55\:4fa1\:3059\:308b (Slide \:756a\:53f7\:9806\:306e\:6587\:5b57\:5217\:30ea\:30b9\:30c8\:3002\:3053\:308c\:304c\:30c7\:30c3\:30ad\:3078\:306e\:552f\:4e00\:306e\:66f8\:304d\:8fbc\:307f\:3067\:3001\:56f3\:306e\:5b9f\:4f53\:5316\:3068\:633f\:5165\:306f\:95a2\:6570\:5074\:304c\:884c\:3046)\:3002Failure \:306a\:3089\:76f4\:3057\:3066\:518d\:8a55\:4fa1\:30023. \:4ee3\:5165\:306f Module \:5185\:3002";

Options[SlideGraphApply] = Join[Options[SlideGraphGenerate],
  {"Mode" -> Automatic, "After" -> Automatic, "Polish" -> False, "ChunkSize" -> 10}];
SlideGraphApply[opts : OptionsPattern[]] := With[{nb = iSWResolveTargetNb[]},
  If[Head[nb] =!= NotebookObject,
    Failure["NoNotebook", <|"MessageTemplate" -> "target notebook not found"|>],
    SlideGraphApply[nb, opts]]];
(* v1.30: "Mode" -> Automatic = \:524d\:56de KG \:304b\:3089\:4f5c\:3063\:305f\:679a (\:984c\:76ee\:30bb\:30eb\:306b KGNode \:30bf\:30b0) \:304c\:3042\:308c\:3070\:7f6e\:304d\:63db\:3048\:3001\:7121\:3051\:308c\:3070\:672b\:5c3e\:306b\:8ffd\:52a0\:3002
   \:7f6e\:304d\:63db\:3048\:3067\:306f\:3001\:6d88\:3059\:524d\:306b\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092 KG \:306e\:30ce\:30fc\:30c9\:3078\:56de\:53ce\:3057\:3001\:65b0\:3057\:3044\:679a\:306f\:524d\:56de\:306e\:6700\:521d\:306e\:679a\:306e\:4f4d\:7f6e\:306b\:5165\:308c\:308b *)
SlideGraphApply[nb_NotebookObject, opts : OptionsPattern[]] := Module[
  {gen, ranges, after, outline, chunks, inserted = 0, warnings, r, res, rows, oldIdx, mode, gid0, harvest = None,
   removed = 0, legacyQ},
  iSWGenProgress[nb, "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210\:3092\:958b\:59cb\:2026", "Starting generation from the KG..."];
  rows = Quiet @ Check[iSWKGDeckSlideNodes[nb], {}];
  If[! ListQ[rows], rows = {}];
  oldIdx = Lookup[Select[rows, StringQ[#["Node"]] &], "Slide", {}];
  mode = Replace[OptionValue["Mode"], Automatic -> If[oldIdx =!= {}, "Replace", "Append"]];
  If[! MemberQ[{"Replace", "Append"}, mode], mode = "Append"];
  If[mode === "Replace" && oldIdx =!= {},
    gid0 = Quiet @ Check[SlideGraphSpec[nb]["Graph"], None];
    If[StringQ[gid0],
      iSWGenProgress[nb, "\:524d\:56de\:306e\:679a\:306e\:8cea\:7591\:5fdc\:7b54\:3092\:77e5\:8b58\:30b0\:30e9\:30d5\:3078\:4fdd\:5b58\:4e2d\:2026", "Saving the Q&A of the previous slides to the KG..."];
      harvest = iSWKGHarvestQA[nb, gid0]]];
  gen = SlideGraphGenerate[nb, "Realize" -> False,
    Sequence @@ FilterRules[FilterRules[{opts}, Options[SlideGraphGenerate]], Except["Realize"]]];
  If[! AssociationQ[gen], iSWStatus[nb, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; Return[gen]];
  If[TrueQ[OptionValue["Polish"]] && ! ListQ[OptionValue["Talks"]],
    If[! iSWAgentAvailableQ[], Return[iSWNoAgentFailure[]]];
    iSWGraphDelegate[nb, iSWGraphPolishTask[gen, gen["Graph"]["GraphId"], iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb]],
      "\:539f\:7a3f\:306e\:63a8\:6572\:3068\:9069\:7528\:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72", "Delegated talk polishing + apply to agent"];
    Return[Success["Delegated", <|"Slides" -> gen["SlideCount"]|>]]];
  ranges = iSWSlideRanges[nb];
  If[ranges === {},
    Return[Failure["NoSlides", <|"MessageTemplate" ->
      "the deck has no slides to insert after (create the deck with SlideDeckBuild or add one slide first)"|>]]];
  after = Replace[OptionValue["After"],
    Automatic -> If[mode === "Replace" && oldIdx =!= {}, Min[oldIdx] - 1, Length[ranges]]];
  If[! IntegerQ[after] || after < 0 || after > Length[ranges], after = Length[ranges]];
  (* v1.29 \:4ee5\:524d\:306e\:751f\:6210\:30b9\:30e9\:30a4\:30c9\:306b\:306f\:76ee\:5370\:304c\:7121\:3044: \:898b\:5206\:3051\:3089\:308c\:306a\:3044\:306e\:3067\:8ffd\:8a18\:3057\:3001\:624b\:3067\:6d88\:3059\:3088\:3046\:77e5\:3089\:305b\:308b *)
  legacyQ = oldIdx === {} && MemberQ[Flatten[{iSWCellStyles[nb]}], "SlideCrumb"];
  outline = Append[gen["Outline"], "Title" -> ""];
  chunks = Partition[outline["Slides"], UpTo[Max[1, OptionValue["ChunkSize"]]]];
  warnings = gen["Warnings"];
  Do[
    Module[{a0 = inserted + 1, b0 = inserted + Length[chunk], nAll = Length[outline["Slides"]]},
      r = Block[{$iSWRealizeProgress = {nb,
          "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210 (" <> ToString[a0] <> "\:2013" <> ToString[b0] <> " / " <> ToString[nAll] <> " \:679a): ",
          "Generating from the KG (" <> ToString[a0] <> "-" <> ToString[b0] <> " / " <> ToString[nAll] <> "): "}},
        iSWKGRealizeMarkdown[outline, chunk, nb, gen["Graph"]]];
      iSWGenProgress[nb, "\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210: \:30b9\:30e9\:30a4\:30c9\:3092\:633f\:5165\:4e2d (" <> ToString[a0] <> "\:2013" <> ToString[b0] <> " / " <> ToString[nAll] <> " \:679a)\:2026",
        "Generating from the KG: inserting slides " <> ToString[a0] <> "-" <> ToString[b0] <> " / " <> ToString[nAll] <> "..."]];
    res = Block[{$iSWFormulaBoxes = iSWKGFormulaDict[gen["Graph"]]},
      SlideDeckInsertScenario[nb, after + inserted, r["Markdown"], "Figures" -> r["Figures"]]];
    If[! MatchQ[res, _Success],
      iSWGraphApplyNote[nb, iSL["\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:306e\:751f\:6210\:304c " <> ToString[inserted + 1] <> " \:679a\:76ee\:3067\:6b62\:307e\:308a\:307e\:3057\:305f" <>
          If[mode === "Replace" && oldIdx =!= {}, " (\:524d\:56de\:306e\:679a\:306f\:6b8b\:3057\:3066\:3044\:307e\:3059)", ""] <> ": ",
        "Generation from the KG stopped at slide " <> ToString[inserted + 1] <>
          If[mode === "Replace" && oldIdx =!= {}, " (the previous slides are kept)", ""] <> ": "] <>
        StringTake[ToString[Quiet[Lookup[Replace[res, Failure[_, a_] :> a], "MessageTemplate", res]]], UpTo[300]]];
      Return[res, Module]];
    inserted += Length[chunk];
    warnings = Join[warnings, r["Warnings"]],
    {chunk, chunks}];
  (* \:524d\:56de\:306e\:679a\:3092\:6d88\:3059: \:65b0\:3057\:3044\:679a\:3092\:305d\:306e\:524d\:306b\:5165\:308c\:305f\:306e\:3067\:3001\:5f8c\:308d\:306b\:3042\:308b\:756a\:53f7\:306f inserted \:3060\:3051\:305a\:308c\:308b *)
  If[mode === "Replace" && oldIdx =!= {},
    iSWGenProgress[nb, "\:524d\:56de\:306e " <> ToString[Length[oldIdx]] <> " \:679a\:3092\:524a\:9664\:4e2d\:2026", "Removing the " <> ToString[Length[oldIdx]] <> " previous slides..."];
    removed = iSWDeleteSlides[nb, If[# > after, # + inserted, #] & /@ oldIdx]];
  iSWGraphApplyNote[nb, iSL["\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089 " <> ToString[inserted] <> " \:679a\:3092\:751f\:6210", "Generated " <> ToString[inserted] <> " slides from the KG"] <>
    If[IntegerQ[Lookup[gen["Spec"], "Slides", None]], iSL[" (\:6307\:5b9a ", " (requested "] <> ToString[gen["Spec"]["Slides"]] <> ")", ""] <>
    If[removed > 0, iSL["\:3002\:524d\:56de\:306e " <> ToString[removed] <> " \:679a\:3092\:7f6e\:304d\:63db\:3048", ". Replaced the " <> ToString[removed] <> " previous slides"], ""] <>
    If[AssociationQ[harvest] && harvest["Status"] === "Saved",
      iSL["\:3001\:8cea\:7591\:5fdc\:7b54 " <> ToString[harvest["Nodes"]] <> " \:30ce\:30fc\:30c9\:5206\:3092\:77e5\:8b58\:30b0\:30e9\:30d5\:306b\:4fdd\:5b58\:3057\:3066\:5f15\:304d\:7d99\:304e", ", carried over the Q&A of " <> ToString[harvest["Nodes"]] <> " nodes"], ""] <>
    If[TrueQ[legacyQ], iSL["\:3002\:524d\:306e\:7248\:3067\:751f\:6210\:3057\:305f\:30b9\:30e9\:30a4\:30c9\:306f\:76ee\:5370\:304c\:7121\:3044\:306e\:3067\:6b8b\:3063\:3066\:3044\:307e\:3059 (\:624b\:3067\:6d88\:3057\:3066\:304f\:3060\:3055\:3044)",
      ". Slides generated by an older version have no marker and were kept (delete them by hand)"], ""] <>
    If[warnings === {}, "", iSL["\:3002\:8b66\:544a: ", ". Warnings: "] <> StringRiffle[DeleteDuplicates[warnings], " / "]]];
  Success["GraphApplied", <|"After" -> after, "Slides" -> inserted, "Mode" -> mode, "Replaced" -> removed,
    "QA" -> harvest, "Warnings" -> DeleteDuplicates[warnings], "Verify" -> gen["Verify"]|>]];

(* \:751f\:6210\:306e\:7d50\:679c\:3092\:72b6\:614b\:6b04\:3068\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:672b\:5c3e (\:7d42\:7aef\:30de\:30fc\:30ab\:30fc\:306e\:5f8c) \:306e Text \:30bb\:30eb\:306b\:6b8b\:3059\:3002
   \:8b66\:544a\:306f\:72b6\:614b\:6b04\:306e\:81ea\:52d5\:6d88\:53bb\:3067\:6d88\:3048\:308b\:306e\:3067\:3001\:30bb\:30eb\:306b\:3082\:66f8\:304f *)
iSWGraphApplyNote[nb_, msg_String] := (
  iSWStatus[nb, msg];
  If[Head[nb] === NotebookObject,
    Quiet @ Check[iSWEnsureEndMarkerAtEnd[nb]; SelectionMove[nb, After, Notebook];
      NotebookWrite[nb, Cell[msg, "Text"]], Null];
    iSWStatusClearLater[nb]]);

iSWKGStripFrontMatter[md_String] := If[StringStartsQ[md, "---\n"],
  With[{p = StringPosition[md, "\n---\n", 1]}, If[p === {}, md, StringTrim[StringDrop[md, p[[1, 2]]], "\n"]]], md];

Options[SlideGraphBuildDeck] = Join[Options[SlideGraphGenerate],
  {"TitleSlide" -> True, "Event" -> "", "Author" -> "", "Date" -> ""}];
SlideGraphBuildDeck[src_, nbfile_String, opts : OptionsPattern[]] := Module[{gen, md, front, file},
  gen = SlideGraphGenerate[src, "Notebook" -> None, Sequence @@ FilterRules[{opts}, Options[SlideGraphGenerate]]];
  If[! AssociationQ[gen], Return[gen]];
  front = Select[{"Title: " <> ToString[gen["Outline"]["Title"]],
    If[OptionValue["Event"] =!= "", "Event: " <> ToString[OptionValue["Event"]], Nothing],
    If[OptionValue["Author"] =!= "", "Author: " <> ToString[OptionValue["Author"]], Nothing],
    If[OptionValue["Date"] =!= "", "Date: " <> ToString[OptionValue["Date"]], Nothing]}, StringQ];
  md = "---\n" <> StringRiffle[front, "\n"] <> "\n---\n\n" <> iSWKGStripFrontMatter[gen["Markdown"]];
  file = Block[{$iSlideKeepCells = iSWFigureCell /@ gen["Figures"]},
    SlideDeckBuild[md, nbfile, "TitleSlide" -> OptionValue["TitleSlide"]]];
  <|"File" -> file, "Slides" -> gen["SlideCount"], "Warnings" -> gen["Warnings"],
    "Verify" -> gen["Verify"], "Plan" -> gen["Plan"], "GraphId" -> gen["Graph"]["GraphId"]|>];

(* ---- \:30b5\:30fc\:30d9\:30a4 (\:8907\:6570 KG \:306e\:5408\:6210) ---- *)
Options[SlideGraphSurvey] = Join[Options[SlideGraphBuildDeck],
  {"Chronological" -> False, "GraphId" -> Automatic, "Save" -> True}];
SlideGraphSurvey[ids_List, nbfile_String, opts : OptionsPattern[]] := Module[{kgs, comp, title, bad},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  kgs = iSWKGResolve /@ ids;
  bad = SelectFirst[kgs, ! AssociationQ[#] &, None];
  If[bad =!= None, Return[bad]];
  title = Replace[OptionValue["Title"], Automatic -> "Survey: " <> StringRiffle[Lookup[kgs, "Title"], " / "]];
  comp = SourceVault`SourceVaultKGCompose[kgs, "Title" -> title, "GraphId" -> OptionValue["GraphId"],
    "Chronological" -> OptionValue["Chronological"],
    "Language" -> Replace[OptionValue["Language"], Automatic -> First[kgs]["Language"]]];
  If[! AssociationQ[comp], Return[comp]];
  If[TrueQ[OptionValue["Save"]], Quiet @ SourceVault`SourceVaultKGSave[comp]];
  SlideGraphBuildDeck[comp, nbfile, "Title" -> title,
    Sequence @@ FilterRules[{opts}, Options[SlideGraphBuildDeck]]]];

(* ---- \:8868\:793a ---- *)
SlideGraphView[] := SlideGraphView[iSWResolveTargetNb[], "Nodes"];
SlideGraphView[src_, what_String : "Nodes"] := Module[{kg = iSWKGResolve[src]},
  If[! AssociationQ[kg], Return[kg]];
  Switch[what,
    "Map", SlideGraphVisualize[src],
    "Graph", SourceVault`SourceVaultKGGraph[kg],
    "Tree", With[{t = SourceVault`SourceVaultKGOrderedTree[kg]},
      If[AssociationQ[t], SourceVault`SourceVaultKGTreeView[kg, t], t]],
    "Plan", SlideGraphPlanView[src],
    _, SourceVault`SourceVaultKGView[kg]]];

SlideGraphShow[what_String : "Plan"] := With[{nb = iSWNotebook[]},
  If[nb === $Failed, $Failed, SlideGraphShow[nb, what]]];
SlideGraphShow[nb_NotebookObject, what_String : "Plan"] := Module[{v},
  v = If[what === "Plan", SlideGraphPlanView[nb], SlideGraphView[nb, what]];
  If[FailureQ[v] || v === $Failed,
    iSWStatus[nb, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; Return[v]];
  $SlideTargetNotebook = nb;
  iSWEnsureEndMarkerAtEnd[nb];
  SelectionMove[nb, After, Notebook];
  NotebookWrite[nb, Cell[BoxData[ToBoxes[v, StandardForm]], "Output"]];
  v];

(* ---- \:7b2c\:4e00\:6b21 KG (seed): \:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:6bb5\:843d\:69cb\:9020\:304b\:3089\:6c7a\:5b9a\:7684\:306b\:4f5c\:308b (v1.22) ----
   v1.23 \:3067\:8db3\:3057\:305f\:898f\:5247 (WikiSkill \:306e\:548c\:8a33\:30ce\:30fc\:30c8\:3067\:5b9f\:6e2c\:3057\:305f\:554f\:984c):
   - Title \:30bb\:30eb\:304c\:7121\:304f\:8ad6\:6587\:984c\:540d\:304c\:6700\:521d\:306e\:898b\:51fa\:3057 (DocImportPaper \:51fa\:529b) \:2192 \:7bc0\:306b\:305b\:305a root \:306b\:7573\:3080
   - \:984c\:540d\:76f4\:5f8c\:306e\:8457\:8005\:30fb\:6240\:5c5e\:884c (^{1} / \:2020 / \:5927\:5b66\:540d) \:2192 \:30ce\:30fc\:30c9\:306b\:3057\:306a\:3044
   - root \:76f4\:4e0b\:306e\:6700\:521d\:306e\:9577\:3044\:6bb5\:843d (Abstract \:76f8\:5f53) \:2192 \:300c\:6982\:8981\:300d\:30ce\:30fc\:30c9 (Importance 0.8) + root \:306e\:8981\:7d04
   - \:30ad\:30e3\:30d7\:30b7\:30e7\:30f3\:300c\:56f31 |\:300d\:300cFigure 1:\:300d\:300cFig. 1.\:300d\:3082\:56f3\:30ce\:30fc\:30c9\:306b\:5408\:6d41 (\:56f3\:306e\:524d\:5f8c\:3069\:3061\:3089\:3067\:3082)
   - \:4ed8\:9332 (A. / A.1. / Appendix / \:4ed8\:9332) \:306e\:7bc0\:30fb\:6bb5\:843d\:30fb\:56f3\:30fb\:5f0f\:306f Importance \:3092\:4e0b\:3052\:308b (\:7bc0 0.3\:3001PackRatio 0.35 \:672a\:6e80\:306a\:306e\:3067\:672b\:5c3e\:306e\:679a\:306b\:8a70\:307e\:308c\:306a\:3044)
   - AI Disclosure / Ethics / Reproducibility statement \:306a\:3069\:3092\:8aad\:307f\:98db\:3070\:3059
   - \:7b2c\:4e8c\:90e8 (\:8a08\:7b97\:306e\:518d\:69cb\:6210 = DocImportPaper \:306e\:6d3e\:751f\:90e8) \:306f\:65e2\:5b9a\:3067\:9664\:5916 ("Reconstruction"->True \:3067\:542b\:3081\:308b)
   - \:518d seed \:3067\:3082\:4fdd\:5b58\:6e08\:307f KG \:306e Background / Shared \:5c64\:306e\:30ce\:30fc\:30c9\:3068\:8fba\:306f\:6b8b\:3059 ("Keep"->"Background") *)
$iSWSeedSkipHeadings = {"references", "reference", "bibliography", "acknowledgments", "acknowledgements",
  "acknowledgment", "acknowledgement", "author contributions", "declaration of interests",
  "declaration of competing interest", "supplemental information", "supplementary information",
  "data and code availability", "resource availability", "lead contact", "materials availability", "funding",
  "conflict of interest", "ai disclosure", "disclosure", "ethics statement", "ethical statement",
  "reproducibility statement", "impact statement", "broader impact", "\:53c2\:8003\:6587\:732e", "\:8b1d\:8f9e", "\:5229\:76ca\:76f8\:53cd"};
$iSWSeedReconstructionHeadings = {"\:7b2c\:4e8c\:90e8", "part ii", "computational reconstruction", "\:8a08\:7b97\:306e\:518d\:69cb\:6210"};

iSWSeedSkipHeadingQ[t_String] := With[{k = ToLowerCase[StringTrim[t]]},
  AnyTrue[$iSWSeedSkipHeadings, StringStartsQ[k, #] &]];
iSWSeedReconstructionHeadingQ[t_String] := With[{k = ToLowerCase[StringTrim[t]]},
  AnyTrue[$iSWSeedReconstructionHeadings, StringStartsQ[k, #] &]];
(* \:4ed8\:9332\:898b\:51fa\:3057: "A. Method Details" / "D.1. Baseline Methods" / "Appendix B ..." / "\:4ed8\:9332 A" (\:51a0\:8a5e\:306e "A Unified ..." \:306f\:9055\:3046) *)
iSWSeedAppendixHeadingQ[t_String] := With[{k = StringTrim[t]},
  StringMatchQ[k, RegularExpression["(?i)^(appendix|appendices|supplementary|supplemental)\\b.*"]] ||
  StringStartsQ[k, "\:4ed8\:9332" | "\:88dc\:907a"] ||
  StringMatchQ[k, RegularExpression["^[A-Z](\\.\\d+)+\\.?\\s+\\S.*"]] ||
  StringMatchQ[k, RegularExpression["^[A-Z]\\.\\s+\\S.*"]]];
(* \:8457\:8005\:30fb\:6240\:5c5e\:884c (\:984c\:540d\:76f4\:5f8c\:306e\:6700\:521d\:306e\:6bb5\:843d\:3060\:3051\:306b\:9069\:7528\:3059\:308b) *)
iSWSeedAuthorLineQ[t_String] := StringLength[t] < 800 && ! StringContainsQ[t, "\:3002"] &&
  (StringContainsQ[t, RegularExpression["\\^\\{?[0-9a-z*]|[\:2020\:2021\:2217]"]] ||
   (StringCount[t, ","] >= 2 &&
    StringContainsQ[t, RegularExpression["(?i)\\b(university|universit|institute|laborator|inc\\.|research|google|microsoft|deepmind|openai|anthropic)\\b|\:5927\:5b66|\:7814\:7a76\:6240|@"]]));
(* \:30ad\:30e3\:30d7\:30b7\:30e7\:30f3\:756a\:53f7: "\:56f3 1." / "\:56f31 |" / "Figure 1:" / "Fig. 1." ("\:56f3 1 \:306e\:7d50\:679c\:306f" \:306f\:9055\:3046) *)
iSWSeedCaptionNumber[t_String] := With[{m = StringCases[StringTrim[t],
    StartOfString ~~ ("\:56f3" | "Figure" | "Fig.") ~~ WhitespaceCharacter ... ~~ d : DigitCharacter .. ~~
      WhitespaceCharacter ... ~~ ("|" | ":" | "." | "\:ff0e" | "\:ff1a" | "\:3001" | EndOfString) :> ToExpression[d], 1]},
  If[m === {}, None, First[m]]];
iSWSeedCaptionBody[t_String] := StringTrim[StringReplace[StringTrim[t],
  StartOfString ~~ ("\:56f3" | "Figure" | "Fig.") ~~ WhitespaceCharacter ... ~~ DigitCharacter .. ~~
    WhitespaceCharacter ... ~~ ("|" | ":" | "." | "\:ff0e" | "\:ff1a" | "\:3001") ... -> "", 1]];

iSWSeedFirstSentence[t_String, max_Integer] := Module[{s},
  s = First[StringSplit[StringTrim[t], {"\:3002", ". ", "\n"}], ""];
  s = StringTrim[s];
  If[StringLength[s] > max, StringTake[s, max] <> "\:2026", s]];

iSWSeedLabel[t_String] := Module[{s = iSWSeedFirstSentence[t, 40]},
  (* \:30e9\:30d9\:30eb\:306f\:984c\:76ee\:306a\:306e\:3067 $...$ \:306e\:9014\:4e2d\:3067\:5207\:308c\:306a\:3044\:3088\:3046\:3001\:6570\:5f0f\:306f\:7d20\:306e TeX \:306b\:843d\:3068\:3059 *)
  s = StringReplace[s, "$" -> ""];
  If[s === "", "\:6bb5\:843d", s]];

iSWSeedSummary[t_String] := Module[{parts},
  parts = Select[StringTrim /@ StringSplit[StringTrim[t], "\:3002"], # =!= "" &];
  If[parts === {}, "", StringTake[StringRiffle[Take[parts, UpTo[2]], "\:3002"] <> "\:3002", UpTo[200]]]];

iSWSeedHeadingImportance[t_String] := With[{k = ToLowerCase[t]},
  Which[
    StringContainsQ[k, "abstract" | "summary" | "highlights" | "\:8981\:65e8" | "\:6982\:8981" | "\:307e\:3068\:3081"], 0.9,
    StringContainsQ[k, "conclusion" | "discussion" | "\:7d50\:8ad6" | "\:8003\:5bdf" | "\:8b70\:8ad6"], 0.85,
    StringContainsQ[k, "introduction" | "background" | "\:306f\:3058\:3081\:306b" | "\:5e8f\:8ad6" | "\:80cc\:666f"], 0.7,
    StringContainsQ[k, "result" | "\:7d50\:679c" | "\:5b9f\:9a13" | "experiment" | "evaluation"], 0.85,
    StringContainsQ[k, "method" | "approach" | "\:624b\:6cd5" | "\:65b9\:6cd5" | "model" | "framework"], 0.8,
    StringContainsQ[k, "related work" | "\:95a2\:9023\:7814\:7a76"], 0.5,
    StringContainsQ[k, "limitation" | "future" | "\:9650\:754c" | "\:4eca\:5f8c"], 0.5,
    True, 0.6]];

Options[SlideGraphSeed] = {"Graph" -> Automatic, "Title" -> Automatic, "Language" -> "ja",
  "MinCharacters" -> 40, "Save" -> True, "Notebook" -> Automatic, "Reconstruction" -> False, "Keep" -> "Background"};
SlideGraphSeed[src_, OptionsPattern[]] := Module[
  {nb, spec, key, path, parts, items, nodes = {}, edges = {}, stack, gid, title, root, lang,
   minc = OptionValue["MinCharacters"], prevContent = <||>, k = 0, kg, sections = 0, paras = 0,
   captionOf = <||>, lastPara = None, res, pendingFigs = {}, recon = TrueQ[OptionValue["Reconstruction"]],
   titleIdx = 0, paperTitle = None, authors = None, abstractDone = False, skipped = <||>,
   prev, keepNodes, keepEdges, kept = 0, bgIds, newIndex, prevIndex, sameQ, refLocator = None},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  nb = Replace[OptionValue["Notebook"], Automatic -> If[Head[src] === NotebookObject, src, iSWResolveTargetNb[]]];
  spec = Which[Head[src] === Notebook, SlideGraphSpec[src],
    Head[nb] === NotebookObject, SlideGraphSpec[nb], True, $iSWStoryDefaults];
  (* \:7d20\:6750\:306e\:6c7a\:5b9a: \:660e\:793a\:306e key / \:30d1\:30b9\:3001\:7121\:3051\:308c\:3070 References \:306e\:6700\:521d\:306e Notebook *)
  (* \:6587\:732e\:884c\:304b\:3089: key \:306f\:8cc7\:7523\:306e Ref \:306b\:3001\:30d1\:30b9\:306f\:767b\:9332\:6e08\:307f\:548c\:8a33\:30ce\:30fc\:30c8 ("Notebook") > locator \:306e\:9806\:3067\:89e3\:304f *)
  {key, path} = Which[
    StringQ[src], {src, $Failed},
    Head[src] === NotebookObject || Head[src] === Notebook,
      With[{refs = Select[iSWReferencesList[src], iSWRefNotebookQ]},
        If[refs === {}, {None, $Failed},
          refLocator = refs[[1, "Locator"]];
          {refs[[1, "Key"]],
           If[StringQ[Lookup[refs[[1]], "Notebook", None]] && FileExistsQ[refs[[1, "Notebook"]]],
             refs[[1, "Notebook"]], refs[[1, "Locator"]]]}]],
    True, {None, $Failed}];
  If[key === None,
    Return[Failure["NoSourceNotebook", <|"MessageTemplate" ->
      "no source notebook: add \"[key] paper.nb | ...\" to References (make it with DocImportPaper first)"|>]]];
  If[! (StringQ[path] && FileExistsQ[path] && ToLowerCase[FileExtension[path]] === "nb"),
    path = Block[{$SlideTargetNotebook = If[Head[nb] === NotebookObject, nb, $SlideTargetNotebook]},
      iSWSourceNBPath[If[StringQ[path], path, key]]]];
  If[path === $Failed, Return[iSWSourceNoNB[key]]];
  parts = iSWSourceNBParts[path];
  If[! AssociationQ[parts], Return[iSWSourceNoNB[key]]];
  items = parts["Items"];
  (* \:6bb5\:843d\:3054\:3068\:306e\:884c\:5185\:6570\:5f0f\:8f9e\:66f8 (tex \:2192 boxes) \:3092\:30ce\:30fc\:30c9\:306b\:6b8b\:3059\:3002\:30b9\:30e9\:30a4\:30c9\:751f\:6210\:6642\:306b $tex$ \:3092\:5143\:306e\:7d44\:7248\:3078\:623b\:3059 *)
  $iSWSeedItemFormulas = Association[Map[#["Cell"] -> Lookup[#, "InlineFormulas", {}] &, items]];
  lang = iSWKGLangCode[OptionValue["Language"]];
  gid = Replace[OptionValue["Graph"], Automatic -> Lookup[spec, "Graph", None]];
  If[! StringQ[gid] || gid === "", gid = iSWKGDefaultGraphId[FileBaseName[path]]];
  (* Title \:30bb\:30eb\:304c\:7121\:3044\:3068\:304d\:3001\:6700\:521d\:306e\:898b\:51fa\:3057\:3088\:308a\:6df1\:3044\:898b\:51fa\:3057\:304c\:5f8c\:306b\:3042\:308c\:3070\:3001\:305d\:306e\:6700\:521d\:306e\:898b\:51fa\:3057\:306f\:8ad6\:6587\:984c\:540d *)
  If[! AnyTrue[items, Lookup[#, "Style", ""] === "Title" &],
    With[{hs = Select[Range[Length[items]], iSWHeadingLevel[Lookup[items[[#]], "Style", ""]] < 99 &]},
      If[hs =!= {} && AnyTrue[Rest[hs],
          iSWHeadingLevel[Lookup[items[[#]], "Style", ""]] > iSWHeadingLevel[Lookup[items[[First[hs]]], "Style", ""]] &],
        titleIdx = First[hs]; paperTitle = StringTrim[Lookup[items[[titleIdx]], "Text", ""]]]]];
  title = Replace[OptionValue["Title"], Automatic ->
    With[{t = SelectFirst[items, Lookup[#, "Style", ""] === "Title" &, None]},
      Which[AssociationQ[t], StringTrim[t["Text"]],
        StringQ[Lookup[spec, "Title", None]] && StringTrim[spec["Title"]] =!= "", spec["Title"],
        StringQ[paperTitle] && paperTitle =!= "", paperTitle,
        True, FileBaseName[path]]]];
  If[! StringQ[title] || title === "", title = FileBaseName[path]];
  If[! StringQ[paperTitle] || paperTitle === "", paperTitle = title];
  root = "root";
  AppendTo[nodes, <|"Id" -> root, "Kind" -> "Claim", "Label" -> title, "Summary" -> "", "Points" -> {},
    "Importance" -> 1., "Difficulty" -> 0.3, "Order" -> 0, "Layer" -> "Paper",
    "Source" -> <|"Ref" -> key|>|>];
  (* \:898b\:51fa\:3057\:306e\:968e\:5c64\:30b9\:30bf\:30c3\:30af: {id, level, skippingQ, appendixQ} *)
  stack = {{root, 0, False, False}};
  Do[
    Module[{it = items[[i]], st, txt, lv, id, parent, skipping, appx},
      st = Lookup[it, "Style", ""]; txt = StringTrim[Lookup[it, "Text", ""]];
      lv = iSWHeadingLevel[st];
      skipping = Length[stack] > 1 && TrueQ[Last[stack][[3]]];
      appx = TrueQ[Last[stack][[4]]];
      Which[
        (* \:8ad6\:6587\:984c\:540d\:306e\:898b\:51fa\:3057: root \:306b\:7573\:3080 (\:4ee5\:5f8c\:306e\:898b\:51fa\:3057\:306f root \:306e\:76f4\:4e0b) *)
        i === titleIdx,
          stack = {{root, 0, False, False}, {root, lv, False, False}},
        (* \:898b\:51fa\:3057 *)
        lv < 99 && st =!= "Title" && st =!= "Subtitle",
          While[Length[stack] > 1 && Last[stack][[2]] >= lv, stack = Most[stack]];
          skipping = Length[stack] > 1 && TrueQ[Last[stack][[3]]];
          appx = TrueQ[Last[stack][[4]]] || iSWSeedAppendixHeadingQ[txt];
          Which[
            (* \:8aad\:307f\:98db\:3070\:3057\:4e2d\:306e\:90e8\:306e\:4e0b\:4f4d\:898b\:51fa\:3057\:3082\:8aad\:307f\:98db\:3070\:3059 *)
            skipping, AppendTo[stack, {None, lv, True, appx}],
            iSWSeedSkipHeadingQ[txt],
              skipped["Headings"] = Append[Lookup[skipped, "Headings", {}], txt];
              AppendTo[stack, {None, lv, True, appx}],
            ! recon && iSWSeedReconstructionHeadingQ[txt],
              skipped["Reconstruction"] = txt;
              AppendTo[stack, {None, lv, True, appx}],
            True,
              k++; sections++; id = "s" <> ToString[k];
              parent = SelectFirst[Reverse[stack], #[[1]] =!= None &][[1]];
              AppendTo[nodes, <|"Id" -> id, "Kind" -> "Section", "Label" -> txt, "Summary" -> "", "Points" -> {},
                "Importance" -> If[appx, 0.3, iSWSeedHeadingImportance[txt]], "Difficulty" -> 0.4, "Order" -> i,
                "Layer" -> "Paper", "Source" -> <|"Ref" -> key, "Section" -> txt|>|>];
              AppendTo[edges, <|"From" -> parent, "To" -> id, "EdgeKind" -> "Contains", "Weight" -> 1.|>];
              AppendTo[stack, {id, lv, False, appx}];
              prevContent[id] = None; lastPara = None; pendingFigs = {}],
        skipping, Null,
        (* \:56f3: \:76f4\:5f8c\:306e\:6bb5\:843d (\:56f3 n. / Figure n) \:3092\:30ad\:30e3\:30d7\:30b7\:30e7\:30f3\:306b *)
        Lookup[it, "Figures", {}] =!= {},
          parent = SelectFirst[Reverse[stack], #[[1]] =!= None &][[1]];
          Do[id = "fig" <> ToString[fn];
            AppendTo[nodes, <|"Id" -> id, "Kind" -> "Figure", "Label" -> "\:56f3 " <> ToString[fn], "Summary" -> "",
              "Points" -> {}, "Importance" -> If[appx, 0.3, 0.6], "Difficulty" -> 0.4, "Order" -> i + 0.1, "Layer" -> "Paper",
              "Assets" -> {<|"Type" -> "NotebookFigure", "Ref" -> key, "N" -> fn|>},
              "Cite" -> "(" <> key <> ") Figure " <> ToString[fn],
              "Source" -> <|"Ref" -> key, "Figure" -> fn|>|>];
            AppendTo[edges, <|"From" -> parent, "To" -> id, "EdgeKind" -> "Contains", "Weight" -> 0.8|>];
            If[StringQ[lastPara],
              AppendTo[edges, <|"From" -> id, "To" -> lastPara, "EdgeKind" -> "Supports", "Weight" -> 0.5|>],
              AppendTo[pendingFigs, id]];
            captionOf[fn] = id,
            {fn, Lookup[it, "Figures", {}]}];
          (* \:56f3\:30bb\:30eb\:306b\:672c\:6587\:304c\:4ed8\:3044\:3066\:3044\:308c\:3070\:6bb5\:843d\:3068\:3057\:3066\:7d9a\:3051\:308b *)
          If[txt =!= "" && StringLength[txt] >= minc && Lookup[it, "Formulas", {}] === {},
            paras++; id = "p" <> ToString[i];
            AppendTo[nodes, iSWSeedParagraphNode[id, txt, i, key, parent, lastPara, root, If[appx, 0.3, Automatic]]];
            AppendTo[edges, <|"From" -> parent, "To" -> id, "EdgeKind" -> "Contains", "Weight" -> 0.9|>];
            If[StringQ[prevContent[parent]], AppendTo[edges, <|"From" -> prevContent[parent], "To" -> id, "EdgeKind" -> "Precedes", "Weight" -> 0.4|>]];
            prevContent[parent] = id; lastPara = id],
        (* \:6570\:5f0f *)
        Lookup[it, "Formulas", {}] =!= {},
          parent = SelectFirst[Reverse[stack], #[[1]] =!= None &][[1]];
          Do[id = "eq" <> ToString[en];
            AppendTo[nodes, <|"Id" -> id, "Kind" -> "Equation", "Label" -> "\:5f0f " <> ToString[en],
              "Summary" -> "", "Points" -> {}, "Text" -> txt, "Importance" -> If[appx, 0.3, 0.55], "Difficulty" -> 0.6,
              "Order" -> i + 0.1, "Layer" -> "Paper",
              "Assets" -> {<|"Type" -> "Formula", "Ref" -> key, "N" -> en|>},
              "Cite" -> "(" <> key <> ") Equation " <> ToString[en],
              "Source" -> <|"Ref" -> key, "Equation" -> en|>|>];
            AppendTo[edges, <|"From" -> parent, "To" -> id, "EdgeKind" -> "Contains", "Weight" -> 0.8|>];
            If[StringQ[lastPara], AppendTo[edges, <|"From" -> lastPara, "To" -> id, "EdgeKind" -> "Precedes", "Weight" -> 0.5|>]];
            prevContent[parent] = id,
            {en, Lookup[it, "Formulas", {}]}],
        (* Abstract \:30bb\:30eb: root (Claim) \:306e\:8981\:7d04\:3068\:672c\:6587\:306b\:3059\:308b (\:5225\:30ce\:30fc\:30c9\:306b\:306f\:3057\:306a\:3044) *)
        st === "Abstract" && txt =!= "",
          nodes[[1, "Summary"]] = iSWSeedSummary[txt];
          nodes[[1, "Text"]] = txt;
          abstractDone = True,
        MemberQ[{"Text", "Item", "ItemNumbered", "Subitem", "SubitemNumbered", "Caption"}, st] &&
          StringLength[txt] >= minc,
          parent = SelectFirst[Reverse[stack], #[[1]] =!= None &][[1]];
          Which[
            (* \:984c\:540d\:76f4\:5f8c\:306e\:8457\:8005\:30fb\:6240\:5c5e\:884c *)
            parent === root && authors === None && ! abstractDone && ! StringQ[prevContent[root]] && iSWSeedAuthorLineQ[txt],
              authors = txt,
            (* \:30ad\:30e3\:30d7\:30b7\:30e7\:30f3: \:76f4\:524d\:306e\:56f3\:30ce\:30fc\:30c9\:306e\:30e9\:30d9\:30eb\:306b\:3059\:308b (\:56f3\:304c\:307e\:3060\:7121\:3051\:308c\:3070\:6bb5\:843d\:306b\:3057\:3066\:5f8c\:3067\:5408\:6d41) *)
            st === "Caption" || iSWSeedCaptionNumber[txt] =!= None,
              With[{n = iSWSeedCaptionNumber[txt]},
                If[n =!= None && KeyExistsQ[captionOf, n],
                  nodes = Replace[nodes, x_Association /; x["Id"] === captionOf[n] :>
                    Join[x, <|"Label" -> iSWSeedFirstSentence[iSWSeedCaptionBody[txt], 50],
                      "Summary" -> iSWSeedSummary[iSWSeedCaptionBody[txt]], "Text" -> txt,
                      "Source" -> Append[Lookup[x, "Source", <||>], "Caption" -> n],
                      "Cite" -> "(" <> key <> ") Figure " <> ToString[n]|>], {1}],
                  paras++; id = "p" <> ToString[i];
                  AppendTo[nodes, iSWSeedParagraphNode[id, txt, i, key, parent, lastPara, root, If[appx, 0.3, Automatic]]];
                  AppendTo[edges, <|"From" -> parent, "To" -> id, "EdgeKind" -> "Contains", "Weight" -> 0.9|>];
                  lastPara = id]],
            True,
              paras++; id = "p" <> ToString[i];
              AppendTo[nodes, iSWSeedParagraphNode[id, txt, i, key, parent, lastPara, root, If[appx, 0.3, Automatic]]];
              AppendTo[edges, <|"From" -> parent, "To" -> id, "EdgeKind" -> "Contains", "Weight" -> 0.9|>];
              If[StringQ[prevContent[parent]], AppendTo[edges, <|"From" -> prevContent[parent], "To" -> id, "EdgeKind" -> "Precedes", "Weight" -> 0.4|>]];
              prevContent[parent] = id; lastPara = id;
              Do[AppendTo[edges, <|"From" -> f, "To" -> id, "EdgeKind" -> "Supports", "Weight" -> 0.5|>], {f, pendingFigs}];
              pendingFigs = {};
              (* root \:76f4\:4e0b\:306e\:6700\:521d\:306e\:9577\:3044\:6bb5\:843d = Abstract \:76f8\:5f53: \:300c\:6982\:8981\:300d\:30ce\:30fc\:30c9\:306b\:3057 root \:306e\:8981\:7d04\:306b\:3082\:3059\:308b *)
              If[parent === root && ! abstractDone && StringLength[txt] >= 200,
                abstractDone = True;
                nodes[[-1, "Label"]] = If[lang === "ja", "\:6982\:8981", "Abstract"];
                nodes[[-1, "Importance"]] = 0.8;
                nodes[[1, "Summary"]] = iSWSeedSummary[txt]; nodes[[1, "Text"]] = txt];
              If[parent === root && nodes[[1, "Summary"]] === "", nodes[[1, "Summary"]] = iSWSeedSummary[txt]]],
        True, Null]],
    {i, Length[items]}];
  (* \:56f3\:3088\:308a\:524d\:306b\:7f6e\:304b\:308c\:305f\:30ad\:30e3\:30d7\:30b7\:30e7\:30f3\:6bb5\:843d\:3092\:56f3\:30ce\:30fc\:30c9\:3078\:5408\:6d41\:3059\:308b *)
  Do[Module[{fid = captionOf[n], fpos, cpos, cap, cid},
      fpos = FirstPosition[nodes, x_Association /; x["Id"] === fid, {0}, {1}][[1]];
      If[fpos > 0 && nodes[[fpos, "Label"]] === "\:56f3 " <> ToString[n],
        cpos = FirstPosition[nodes, x_Association /; x["Kind"] === "Concept" && iSWSeedCaptionNumber[Lookup[x, "Text", ""]] === n, {0}, {1}][[1]];
        If[cpos > 0,
          cap = nodes[[cpos, "Text"]]; cid = nodes[[cpos, "Id"]];
          nodes[[fpos, "Label"]] = iSWSeedFirstSentence[iSWSeedCaptionBody[cap], 50];
          nodes[[fpos, "Summary"]] = iSWSeedSummary[iSWSeedCaptionBody[cap]];
          nodes[[fpos, "Text"]] = cap;
          nodes[[fpos, "Source"]] = Append[Lookup[nodes[[fpos]], "Source", <||>], "Caption" -> n];
          nodes[[fpos, "Cite"]] = "(" <> key <> ") Figure " <> ToString[n];
          edges = Select[edges, #["From"] =!= cid && #["To"] =!= cid &];
          nodes = Delete[nodes, cpos]; paras--]]],
    {n, Keys[captionOf]}];
  kg = SourceVault`SourceVaultKGFromJSON[<|"GraphId" -> gid, "Title" -> title, "Language" -> lang, "Kind" -> "Paper",
    "Root" -> root, "Sources" -> {<|"Key" -> key, "Locator" -> path, "Kind" -> "Notebook",
      "Reference" -> If[StringQ[refLocator], refLocator, ""]|>},
    "Nodes" -> nodes, "Edges" -> edges|>];
  If[! AssociationQ[kg], Return[kg]];
  kg["Seed"] = True;
  (* \:518d seed: \:4fdd\:5b58\:6e08\:307f KG \:306e Background / Shared \:5c64 (\:5468\:8fba\:77e5\:8b58) \:3068\:305d\:306e\:8fba\:3092\:6b8b\:3059\:3002\:6bb5\:843d Id \:306f
     \:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:30bb\:30eb\:4f4d\:7f6e\:304b\:3089\:6c7a\:307e\:308b\:306e\:3067\:3001\:540c\:3058\:30ce\:30fc\:30c8\:306a\:3089\:524d\:63d0\:8fba\:306e\:5148\:3082\:5909\:308f\:3089\:306a\:3044 *)
  If[OptionValue["Keep"] =!= None,
    prev = Quiet @ Check[SourceVault`SourceVaultKGLoad[gid], $Failed];
    If[AssociationQ[prev],
      keepNodes = Select[Lookup[prev, "Nodes", {}], AssociationQ[#] && Lookup[#, "Layer", "Paper"] =!= "Paper" &];
      If[keepNodes =!= {},
        bgIds = Lookup[keepNodes, "Id"];
        newIndex = Association[(#["Id"] -> #) & /@ nodes];
        prevIndex = Association[(#["Id"] -> #) & /@ Select[Lookup[prev, "Nodes", {}], AssociationQ]];
        (* \:8ad6\:6587\:5074\:306e\:7aef\:70b9\:306f\:300c\:540c\:3058 Id \:3067\:540c\:3058\:5185\:5bb9\:300d\:306e\:3068\:304d\:3060\:3051 (\:7bc0\:306f\:898b\:51fa\:3057\:3001\:6bb5\:843d\:30fb\:5f0f\:306f\:672c\:6587\:3067\:7167\:5408\:3002
           \:898f\:5247\:5909\:66f4\:3067 s* \:306e\:756a\:53f7\:304c\:305a\:308c\:3066\:3082\:8aa4\:63a5\:7d9a\:3057\:306a\:3044) *)
        sameQ[id_] := MemberQ[bgIds, id] || (KeyExistsQ[newIndex, id] && KeyExistsQ[prevIndex, id] &&
          With[{a = newIndex[id], b = prevIndex[id]},
            If[a["Kind"] === "Section",
              Lookup[Lookup[a, "Source", <||>], "Section", ""] === Lookup[Lookup[b, "Source", <||>], "Section", None],
              With[{ta = Lookup[a, "Text", ""], tb = Lookup[b, "Text", ""]}, ta === "" || tb === "" || ta === tb]]]);
        keepEdges = Select[Lookup[prev, "Edges", {}], AssociationQ[#] && sameQ[#["From"]] && sameQ[#["To"]] &&
          (MemberQ[bgIds, #["From"]] || MemberQ[bgIds, #["To"]]) &];
        res = SourceVault`SourceVaultKGMerge[kg, <|"Nodes" -> keepNodes, "Edges" -> keepEdges|>];
        If[AssociationQ[res] && KeyExistsQ[res, "Nodes"], kg = res; kg["Seed"] = True; kept = Length[keepNodes]]]]];
  If[TrueQ[OptionValue["Save"]],
    res = SourceVault`SourceVaultKGSave[kg];
    If[! StringQ[res], Return[Failure["SaveFailed", <|"MessageTemplate" -> "could not save `1`", "MessageParameters" -> {gid}|>]]]];
  <|"Graph" -> gid, "Title" -> title, "PaperTitle" -> paperTitle, "NodeCount" -> Length[kg["Nodes"]], "EdgeCount" -> Length[kg["Edges"]],
    "Sections" -> sections, "Paragraphs" -> paras, "Figures" -> Length[parts["Figures"]],
    "Formulas" -> Length[parts["Formulas"]], "Kept" -> kept, "Authors" -> authors, "Skipped" -> skipped,
    "Warnings" -> kg["Warnings"], "KG" -> kg|>];

iSWSeedParagraphNode[id_, txt_, i_, key_, parent_, lastPara_, root_, imp_: Automatic] :=
  <|"Id" -> id, "Kind" -> "Concept", "Label" -> iSWSeedLabel[txt], "Summary" -> iSWSeedSummary[txt],
    "Points" -> {}, "Text" -> txt, "Importance" -> If[NumericQ[imp], imp, If[parent === root, 0.7, 0.5]], "Difficulty" -> 0.5,
    "Order" -> i, "Layer" -> "Paper", "Source" -> <|"Ref" -> key|>,
    "Formulas" -> Lookup[$iSWSeedItemFormulas, i, {}]|>;

(* ---- \:7bc0\:3054\:3068\:306e\:8aad\:307f\:53e3 (\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:7528) ---- *)
iSWKGSubtreeIds[kg_Association, sectionId_String] := Module[{kids, out = {sectionId}, q = {sectionId}},
  kids = GroupBy[Select[kg["Edges"], #["EdgeKind"] === "Contains" &], #["From"] &, Map[#["To"] &]];
  While[q =!= {}, q = Flatten[Lookup[kids, q, {}]]; out = Join[out, q]];
  DeleteDuplicates[out]];

(* \:7bc0\:300c\:81ea\:8eab\:300d\:306e\:5185\:5bb9 = Contains \:3092\:8fbf\:308b\:304c\:3001\:5165\:308c\:5b50\:306e Section \:306e\:4e0b\:3078\:306f\:964d\:308a\:306a\:3044 (\:4e0b\:4f4d\:7bc0\:306f\:5225\:306b\:78e8\:304f) *)
(* \:7bc0 = Kind \:304c Section \:306e\:30ce\:30fc\:30c9\:3001\:307e\:305f\:306f Contains \:306e\:5b50\:3092\:6301\:3064\:30ce\:30fc\:30c9 (\:6839\:3092\:9664\:304f)\:3002\:63a8\:6572\:3067\:7bc0\:306e Kind \:304c
   Conclusion \:306a\:3069\:306b\:5909\:308f\:308b\:3068\:3001Kind \:3060\:3051\:3067\:6570\:3048\:305f\:7bc0\:304c 0 \:306b\:306a\:308a\:3001\:5168\:30ce\:30fc\:30c9\:304c\:6839\:306e 1 \:884c\:306b\:5165\:3063\:3066\:3044\:305f
   (\:8a08\:7b97\:3068\:81ea\:713633: \:300c\:6e08 1/1 \:7bc0\:300d\:3001117 \:30ce\:30fc\:30c9\:3092 1 \:30ea\:30af\:30a8\:30b9\:30c8\:3067\:63a8\:6572) *)
iSWKGSectionIdSet[kg_Association] := DeleteCases[DeleteDuplicates[Join[
  Lookup[Select[kg["Nodes"], #["Kind"] === "Section" &], "Id", {}],
  Lookup[Select[kg["Edges"], #["EdgeKind"] === "Contains" &], "From", {}]]], Lookup[kg, "Root", "root"]];
iSWKGSectionOwnIds[kg_Association, sectionId_String] := Module[
  {index = Association[(#["Id"] -> #) & /@ kg["Nodes"]], kids, out = {sectionId}, q = {sectionId}, nested = {}, next, secQ, secs},
  kids = GroupBy[Select[kg["Edges"], #["EdgeKind"] === "Contains" &], #["From"] &, Map[#["To"] &]];
  secs = iSWKGSectionIdSet[kg];
  secQ[id_] := MemberQ[secs, id];
  While[q =!= {},
    next = DeleteDuplicates[Flatten[Lookup[kids, q, {}]]];
    nested = Join[nested, Select[next, secQ]];
    q = Select[next, ! secQ[#] && KeyExistsQ[index, #] && ! MemberQ[out, #] &];
    out = Join[out, q]];
  <|"Own" -> DeleteDuplicates[out], "Nested" -> DeleteDuplicates[nested]|>];

Options[SlideGraphSectionText] = {"Format" -> "Text", "MaxCharacters" -> 4000, "Page" -> 1};
(* v1.22 \:306e\:5b9a\:7fa9 (\:30aa\:30d7\:30b7\:30e7\:30f3\:7121\:3057\:306e\:30d1\:30bf\:30fc\:30f3) \:306f\:518d\:30ed\:30fc\:30c9\:3057\:3066\:3082\:6b8b\:308a\:3001\:3088\:308a\:7279\:6b8a\:306a\:306e\:3067\:52dd\:3063\:3066 JSON \:3092\:8fd4\:3057\:7d9a\:3051\:305f
   (\:5b9f\:6a5f: KG\:69cb\:7bc9\:3092\:518d\:5b9f\:884c\:3057\:3066\:3082\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c JSON \:3092\:898b\:305f)\:3002\:540c\:3058\:30d1\:30bf\:30fc\:30f3\:3092\:5b9a\:7fa9\:3057\:76f4\:3057\:3066\:4e0a\:66f8\:304d\:3059\:308b *)
SlideGraphSectionText[graphId_String] := SlideGraphSectionText[graphId, "Format" -> "Text"];
SlideGraphSectionText[graphId_String, sectionId_String] := SlideGraphSectionText[graphId, sectionId, "Format" -> "Text"];

(* \:30d6\:30ed\:30c3\:30af\:5217\:3092\:30da\:30fc\:30b8\:306b\:8a70\:3081\:308b (\:30d6\:30ed\:30c3\:30af\:5883\:754c\:3067\:5207\:308b\:30021 \:30d6\:30ed\:30c3\:30af\:304c\:4e88\:7b97\:3092\:8d85\:3048\:308b\:3068\:304d\:3060\:3051\:672c\:6587\:3092\:5207\:308a\:8a70\:3081\:308b)\:3002
   \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:623b\:308b\:8a55\:4fa1\:7d50\:679c\:306f NBAccess \:306e RedactedResult \:4e0a\:9650 ($NBRedactedResultMaxLength\:3001\:65e2\:5b9a 6000 \:5b57) \:3067
   \:5207\:3089\:308c\:308b\:306e\:3067\:30011 \:30da\:30fc\:30b8\:306f\:305d\:308c\:3088\:308a\:5c0f\:3055\:304f\:3059\:308b (\:65e2\:5b9a 4000)\:3002 *)
iSWPageBlocks[blocks_List, budget_Integer, page_Integer] := Module[{cut, pages = {}, cur = {}, len = 0, np, pg},
  cut[b_String] := If[StringLength[b] > budget, StringTake[b, Max[1, budget - 12]] <> " \:2026(\:5207\:308a\:8a70\:3081)", b];
  Do[With[{b = cut[b0]},
      If[cur =!= {} && len + StringLength[b] + 1 > budget, AppendTo[pages, cur]; cur = {}; len = 0];
      AppendTo[cur, b]; len += StringLength[b] + 1],
    {b0, blocks}];
  If[cur =!= {} || pages === {}, AppendTo[pages, cur]];
  np = Length[pages]; pg = Clip[page, {1, np}];
  <|"Lines" -> pages[[pg]], "Page" -> pg, "Pages" -> np|>];

SlideGraphSectionText[graphId_String, OptionsPattern[]] := Module[
  {kg = iSWKGResolve[graphId], rows, paged, budget = OptionValue["MaxCharacters"], head, tail},
  If[! AssociationQ[kg], Return[kg]];
  rows = KeyDrop[#, "Own"] & /@ iSWKGSectionRows[kg];
  If[OptionValue["Format"] === "JSON",
    Return[SourceVault`SourceVaultKGToJSON[<|"Sections" -> rows|>]]];
  paged = iSWPageBlocks[Map[#["Id"] <> " | " <> #["Label"] <> " | \:672c\:6587\:30ce\:30fc\:30c9 " <> ToString[#["Nodes"]] <>
      If[#["Nested"] =!= {}, " | \:4e0b\:4f4d\:7bc0: " <> StringRiffle[#["Nested"], ", "], ""] <>
      If[TrueQ[#["Done"]], " | \:6e08", ""] &, rows],
    Max[80, budget - 300], OptionValue["Page"]];
  head = "\:7bc0\:306e\:4e00\:89a7 (GraphId " <> graphId <> If[paged["Pages"] > 1, "\:3001\:30da\:30fc\:30b8 " <> ToString[paged["Page"]] <> "/" <> ToString[paged["Pages"]], ""] <>
    ")\:3002\:300c\:6e08\:300d\:306e\:7bc0\:306f\:63a8\:6572\:6e08\:307f\:306a\:306e\:3067\:98db\:3070\:3057\:3001\:6b8b\:308a\:3092\:4e0a\:304b\:3089\:9806\:306b 1 \:7bc0\:305a\:3064\:63a8\:6572\:3059\:308b\:3002\:672c\:6587\:30ce\:30fc\:30c9 = \:305d\:306e\:7bc0\:306b\:76f4\:63a5\:3076\:3089\:4e0b\:304c\:308b\:6bb5\:843d\:30fb\:56f3\:30fb\:5f0f\:306e\:6570 (\:4e0b\:4f4d\:7bc0\:306e\:5206\:306f\:542b\:307e\:306a\:3044)\:3002" <>
    If[AllTrue[rows, TrueQ[#["Done"]] &], " \:5168\:7bc0\:304c\:6e08: SlideGraphPlanView \:3067\:8a08\:753b\:3092\:78ba\:8a8d\:3057\:3066\:7d42\:4e86\:3059\:308b\:3002", ""];
  tail = If[paged["Page"] < paged["Pages"],
    {"(\:7d9a\:304d: SlideGraphSectionText[\"" <> graphId <> "\", \"Page\" -> " <> ToString[paged["Page"] + 1] <> "])"}, {}];
  StringRiffle[Join[{head}, paged["Lines"], tail], "\n"]];
SlideGraphSectionText[graphId_String, sectionId_String, OptionsPattern[]] := Module[
  {kg = iSWKGResolve[graphId], index, own, ids, edges, nodes, budget = OptionValue["MaxCharacters"], sec, lines, blocks, paged, tail},
  If[! AssociationQ[kg], Return[kg]];
  index = Association[(#["Id"] -> #) & /@ kg["Nodes"]];
  If[! KeyExistsQ[index, sectionId], Return[Failure["NoSection", <|"MessageTemplate" -> "no node `1`", "MessageParameters" -> {sectionId}|>]]];
  own = iSWKGSectionOwnIds[kg, sectionId];
  ids = own["Own"];
  nodes = Map[Function[id, With[{n = index[id]},
    <|"Id" -> id, "Kind" -> n["Kind"], "Label" -> SourceVault`SourceVaultKGText[n, "Label"],
      "Text" -> Replace[Lookup[n, "Text", SourceVault`SourceVaultKGText[n, "Summary"]], Except[_String] -> ""],
      "Assets" -> Length[Lookup[n, "Assets", {}]]|>]], ids];
  edges = Select[kg["Edges"], MemberQ[ids, #["From"]] && MemberQ[ids, #["To"]] && #["EdgeKind"] =!= "Contains" &];
  If[OptionValue["Format"] === "JSON",
    Return[SourceVault`SourceVaultKGToJSON[<|"Section" -> sectionId, "Nodes" -> nodes, "Nested" -> own["Nested"], "Edges" -> edges|>]]];
  sec = First[nodes];
  blocks = Map[Function[n, "--- " <> n["Id"] <> " [" <> n["Kind"] <> "] " <> n["Label"] <>
      If[n["Assets"] > 0, " | \:8cc7\:7523 " <> ToString[n["Assets"]], ""] <> " ---\n" <> n["Text"]], Rest[nodes]];
  If[sec["Text"] =!= "", PrependTo[blocks, "(\:7bc0\:306e\:8981\:7d04) " <> sec["Text"]]];
  paged = iSWPageBlocks[blocks, Max[80, budget - 400], OptionValue["Page"]];
  lines = {"=== \:7bc0 " <> sectionId <> " | " <> sec["Label"] <> " | \:672c\:6587\:30ce\:30fc\:30c9 " <> ToString[Length[nodes] - 1] <>
    If[own["Nested"] =!= {}, " | \:4e0b\:4f4d\:7bc0 (\:5225\:306b\:63a8\:6572): " <> StringRiffle[own["Nested"], ", "], ""] <>
    If[paged["Pages"] > 1, " | \:30da\:30fc\:30b8 " <> ToString[paged["Page"]] <> "/" <> ToString[paged["Pages"]], ""] <> " ==="};
  lines = Join[lines, paged["Lines"]];
  tail = If[paged["Page"] < paged["Pages"],
    {"(\:7d9a\:304d: SlideGraphSectionText[\"" <> graphId <> "\", \"" <> sectionId <> "\", \"Page\" -> " <> ToString[paged["Page"] + 1] <>
      "] \:3092\:8a55\:4fa1\:3059\:308b\:3002\:5168\:30da\:30fc\:30b8\:3092\:8aad\:3093\:3067\:304b\:3089\:5dee\:5206 JSON \:3092\:4f5c\:308b)"},
    Join[If[edges =!= {},
        {"\:9806\:5e8f\:8fba: " <> StringRiffle[Map[#["From"] <> " -" <> #["EdgeKind"] <> "-> " <> #["To"] &, edges], "; "]}, {}],
      {"(\:3053\:306e\:672c\:6587\:306f\:8aad\:3080\:305f\:3081\:306e\:3082\:306e\:3002\:89e3\:6790\:305b\:305a\:3001\:5dee\:5206 JSON \:3092 SlideGraphIngest[\"" <> graphId <> "\", json, \"Merge\"->True] \:3067\:53d6\:308a\:8fbc\:3080)"}]];
  StringRiffle[Join[lines, tail], "\n"]];

(* ---- \:7bc0\:3054\:3068\:306b\:78e8\:304f\:30bf\:30b9\:30af ---- *)
iSWGraphRefineTask[spec_Association, kg_Association, metaBlocks_String] := Module[{gid = spec["Graph"], secs},
  secs = Select[kg["Nodes"], #["Kind"] === "Section" &];
  metaBlocks <>
  "SlideWorkflow \:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:63a8\:6572\:30bf\:30b9\:30af\:3002GraphId \"" <> gid <> "\" \:306f\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:6bb5\:843d\:3092\:305d\:306e\:307e\:307e\:30ce\:30fc\:30c9\:306b\:3057\:305f\:7b2c\:4e00\:6b21 KG (" <>
    ToString[Length[kg["Nodes"]]] <> " \:30ce\:30fc\:30c9\:3001\:7bc0 " <> ToString[Length[secs]] <> " \:500b) \:3067\:3001\:30e9\:30d9\:30eb\:306f\:6bb5\:843d\:5192\:982d\:3001\:8981\:70b9\:306f\:7a7a\:3001\:8fba\:306f Contains / Precedes \:3060\:3051\:3002\:3053\:308c\:3092\:7bc0\:3054\:3068\:306b\:767a\:8868\:7528\:306e KG \:3078\:78e8\:304f\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <> If[StringQ[spec["Story"]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "\:624b\:9806 (\:53b3\:5b88\:3002**1 \:7bc0\:305a\:3064**\:30011 \:56de\:306e\:8a55\:4fa1\:3067 1 \:7bc0\:3060\:3051\:6271\:3046\:3002\:672c\:6587\:30ce\:30fc\:30c9\:306e\:5408\:8a08\:304c 8 \:4ee5\:4e0b\:306a\:3089\:96a3\:308a\:5408\:3046\:7bc0\:3092\:307e\:3068\:3081\:3066 1 \:56de\:3067\:6271\:3063\:3066\:3088\:3044):\n" <>
  "1. SlideGraphSectionText[\"" <> gid <> "\"] \:3067\:7bc0\:306e\:4e00\:89a7 (Id / Label / \:672c\:6587\:30ce\:30fc\:30c9\:6570 / \:4e0b\:4f4d\:7bc0 / \:6e08) \:3092\:5f97\:308b\:3002\:623b\:308a\:5024\:306f\:8aad\:3080\:305f\:3081\:306e\:6587\:5b57\:5217\:306a\:306e\:3067\:3001\:305d\:306e\:307e\:307e\:8aad\:3080 (JSON \:3068\:3057\:3066\:89e3\:6790\:3057\:305f\:308a Lookup \:3057\:305f\:308a\:3057\:306a\:3044)\:3002\:300c\:6e08\:300d\:306e\:7bc0\:306f\:524d\:56de\:307e\:3067\:306b\:63a8\:6572\:6e08\:307f\:306a\:306e\:3067\:98db\:3070\:3059\:3002
" <>
  "2. \:7bc0 Id \:3054\:3068\:306b SlideGraphSectionText[\"" <> gid <> "\", \"<sectionId>\"] \:3092\:8a55\:4fa1\:3057\:3066\:672c\:6587\:3092\:8aad\:3080 (\:540c\:3058\:304f\:6587\:5b57\:5217\:3092\:305d\:306e\:307e\:307e\:8aad\:3080\:3002\:4e0b\:4f4d\:7bc0\:306f\:5225\:306e\:7bc0\:3068\:3057\:3066\:4e00\:89a7\:306e\:9806\:306b\:6271\:3046\:3002\:672c\:6587\:30ce\:30fc\:30c9 0 \:306e\:7bc0\:306f Label / Summary \:3060\:3051\:4ed8\:3051\:308b\:3002\:672c\:6587\:304c\:9577\:3044\:7bc0\:306f\:30da\:30fc\:30b8\:306b\:5206\:304b\:308c\:308b\:306e\:3067\:3001\:672b\:5c3e\:306e\:300c\:7d9a\:304d\:300d\:306e\:6307\:793a\:3069\:304a\:308a \"Page\"->n \:3067\:6b21\:30da\:30fc\:30b8\:3082\:8aad\:307f\:3001\:5168\:30da\:30fc\:30b8\:3092\:8aad\:3093\:3067\:304b\:3089\:5dee\:5206\:3092\:4f5c\:308b)\:3002\n" <>
  "3. \:305d\:306e\:7bc0\:306e\:5dee\:5206 JSON \:3092\:4f5c\:308b:\n" <>
  "   {\"Nodes\": [{\"Id\": \"<\:65e2\:5b58 Id>\", \"Kind\": \"Concept|Definition|Method|Experiment|Result|Question|Conclusion\", \"Label\": \"\:4f53\:8a00\:6b62\:3081\:306e\:77ed\:3044\:984c\:76ee (\:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb)\", \"Summary\": \"\:3067\:3059\:30fb\:307e\:3059\:8abf 1-2 \:6587\", \"Points\": [\"\:4f53\:8a00\:6b62\:3081 2-4 \:884c\"], \"Importance\": 0-1, \"Difficulty\": 0-1, \"Domains\": [\"\:9818\:57df\"]}],\n" <>
  "    \"Edges\": [{\"From\": \"<Id>\", \"To\": \"<Id>\", \"EdgeKind\": \"Motivates|Derives|LeadsTo|Prerequisite|Supports|Explains|Contrasts\", \"Weight\": 0-1}],\n" <>
  "    \"Remove\": [\"<\:4e0d\:8981\:306a\:6bb5\:843d\:306e Id>\"]}\n" <>
  "   - \:56f3 (fig*) \:3068\:5f0f (eq*) \:306e Id \:306f\:6b8b\:3057\:3001Label / Summary / Points \:3092\:4ed8\:3051\:308b (\:56f3\:8868\:306f\:4f5c\:308a\:76f4\:3055\:306a\:3044)\:3002\n" <>
  "   - 1 \:679a\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:306a\:3089\:306a\:3044\:77ed\:3044\:6bb5\:843d\:30fb\:3064\:306a\:304e\:306e\:6bb5\:843d\:306f Remove \:3059\:308b\:304b\:3001\:96a3\:306e\:6bb5\:843d\:306e Points \:306b\:5438\:53ce\:3057\:3066 Remove \:3059\:308b\:30021 \:7bc0\:3042\:305f\:308a\:6b8b\:3059\:30ce\:30fc\:30c9\:306f 2\:301c8 \:500b\:304c\:76ee\:5b89\:3002\n" <>
  "   - \:7bc0 (s*) \:81ea\:4f53\:306b\:3082 Label (\:77ed\:304f) \:3068 Summary \:3092\:4ed8\:3051\:308b\:3002\:9806\:5e8f\:8fba\:306f\:3059\:3079\:3066 From \:3092\:5148\:306b\:63d0\:793a\:3059\:308b\:5411\:304d\:3002\n" <>
  "   - \:8074\:304d\:624b\:306b\:7121\:3044\:524d\:63d0\:77e5\:8b58\:304c\:3042\:308c\:3070 Layer=Background \:306e\:65b0\:30ce\:30fc\:30c9 (Id \:306f bg_*) \:3092\:8db3\:3057\:3001Prerequisite \:8fba\:3092\:5f35\:308b\:3002\n" <>
  "4. SlideGraphIngest[\"" <> gid <> "\", json, \"Merge\"->True] \:3092\:8a55\:4fa1\:3059\:308b (json \:306f JSON \:6587\:5b57\:5217)\:3002Failure \:306a\:3089\:76f4\:3057\:3066\:518d\:8a55\:4fa1\:3002\n" <>
  "5. \:5168\:7bc0\:304c\:7d42\:308f\:3063\:305f\:3089 SlideGraphPlanView[\"" <> gid <> "\"] \:3067\:8a08\:753b\:3092\:78ba\:8a8d\:3059\:308b\:3002\:30c7\:30c3\:30ad\:3078\:306e\:66f8\:304d\:8fbc\:307f\:306f\:3057\:306a\:3044\:3002\n" <>
  "6. \:4ee3\:5165\:306f\:5fc5\:305a Module[{...}, ...] \:306e\:4e2d\:306b\:7f6e\:304f\:3002Import / Get / ReadRawJSONString / ImportString \:306f\:4f7f\:308f\:306a\:3044 (\:627f\:8a8d\:5f85\:3061\:3067\:6b62\:307e\:308b)\:3002\n" <>
  "\:7bc0\:306e\:4e00\:89a7: " <> StringRiffle[Map[#["Id"] <> " " <> SourceVault`SourceVaultKGText[#, "Label"] &, secs], " / "]];

(* ---- \:63a8\:6572 (Direct): \:7bc0\:3054\:3068\:306b LLM \:3092\:76f4\:63a5\:547c\:3076\:9023\:9396 (v1.24) ----
   \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8 (ClaudeEval) \:7d4c\:8def\:306f 1 \:5b9f\:884c\:3042\:305f\:308a\:63d0\:6848 4\:301c5 \:30bf\:30fc\:30f3\:3067\:6253\:3061\:5207\:3089\:308c\:3001\:7bc0\:672c\:6587\:3092\:8aad\:3080\:30bf\:30fc\:30f3\:3068\:5dee\:5206\:3092\:66f8\:304f
   \:30bf\:30fc\:30f3\:3067 40 \:7bc0\:5206\:3092\:56de\:3059\:3068\:6bce\:56de\:300c\:63a8\:6572\:300d\:3092\:62bc\:3057\:76f4\:3059\:3053\:3068\:306b\:306a\:3063\:305f (\:5b9f\:6a5f 3 \:5de1)\:3002QA \:751f\:6210 (iSWQAChain) \:3068\:540c\:3058
   callback \:9023\:9396\:306b\:3057\:3001\:7bc0\:672c\:6587\:3092\:6307\:793a\:306b\:540c\:68b1\:3057\:3066\:5dee\:5206 JSON \:3060\:3051\:3092\:8fd4\:3055\:305b\:308b\:3002LLM \:306e\:7d4c\:8def (CLI / \:79c1\:7684\:30e2\:30c7\:30eb) \:306f
   PrivacyLevel (\:30c7\:30c3\:30ad\:6307\:793a\:3068 KG \:30ce\:30fc\:30c9\:306e\:6700\:5927) \:3067 ClaudeQueryAsync \:304c\:6c7a\:3081\:308b\:3002 *)
$iSWRefineRun = <|"OK" -> 0, "NG" -> 0, "Failed" -> {}, "Warnings" -> {}, "Calls" -> 0|>;
$iSWRefineBusy = False;
$iSWRefineBusySince = 0.;
(* \:5b9f\:884c\:4e2d\:306e\:76ee\:5370\:306f\:6700\:5f8c\:306e\:554f\:3044\:5408\:308f\:305b\:304b\:3089 20 \:5206\:3067\:5207\:308c\:308b (\:5fdc\:7b54\:304c\:623b\:3089\:305a\:9023\:9396\:304c\:6b62\:307e\:3063\:3066\:3082\:3001\:307b\:304b\:306e\:30dc\:30bf\:30f3\:304c\:9577\:304f\:4f7f\:3048\:306a\:304f\:306a\:3089\:306a\:3044\:3088\:3046\:306b) *)
$iSWRefineBusyMaxSeconds = 1200.;
iSWRefineBusyQ[] := TrueQ[$iSWRefineBusy] && (AbsoluteTime[] - $iSWRefineBusySince) < $iSWRefineBusyMaxSeconds;
iSWStatusIf[nb_, s_String] := If[Head[nb] === NotebookObject, iSWStatus[nb, s]];

(* \:7bc0\:306e\:884c (Id / Label / \:672c\:6587\:30ce\:30fc\:30c9 / \:4e0b\:4f4d\:7bc0 / \:6e08) \:2014 \:4e00\:89a7 (SlideGraphSectionText) \:3068\:9023\:9396\:3067\:5171\:7528\:3002
   \:6e08 = \:7bc0\:306b Summary \:304c\:4ed8\:3044\:305f\:3001\:307e\:305f\:306f\:672c\:6587\:30ce\:30fc\:30c9\:5168\:90e8\:306b\:8981\:70b9\:304c\:4ed8\:3044\:305f (\:9014\:4e2d\:3067\:6b62\:3081\:3066\:518d\:958b\:3059\:308b\:3068\:304d\:306e\:76ee\:5370) *)
iSWKGSectionRows[kg_Association] := Module[{index, secs, root, rootOwn, doneQ, rows},
  index = Association[(#["Id"] -> #) & /@ kg["Nodes"]];
  secs = Lookup[index, Select[iSWKGSectionIdSet[kg], KeyExistsQ[index, #] &]];
  doneQ[s_, ownIds_] := SourceVault`SourceVaultKGText[s, "Summary"] =!= "" ||
    (ownIds =!= {} && AllTrue[ownIds, Lookup[Lookup[index, #, <||>], "Points", {}] =!= {} &]);
  rows = Map[Function[s, With[{own = iSWKGSectionOwnIds[kg, s["Id"]]},
    <|"Id" -> s["Id"], "Label" -> SourceVault`SourceVaultKGText[s, "Label"],
      "Nodes" -> Length[own["Own"]] - 1, "Own" -> Rest[own["Own"]], "Nested" -> own["Nested"],
      "Done" -> doneQ[s, Rest[own["Own"]]]|>]], secs];
  (* root \:76f4\:4e0b\:306e\:672c\:6587 (\:6982\:8981\:30fb\:56f3 1 \:306a\:3069\:3001\:3069\:306e\:7bc0\:306b\:3082\:5c5e\:3055\:306a\:3044) \:3082 1 \:3064\:306e\:300c\:7bc0\:300d\:3068\:3057\:3066\:78e8\:304f\:3002root \:306e\:8981\:7d04\:306f seed \:304c
     Abstract \:304b\:3089\:4ed8\:3051\:308b\:306e\:3067\:3001\:6e08 \:306f\:672c\:6587\:30ce\:30fc\:30c9\:5168\:90e8\:306b\:8981\:70b9\:304c\:4ed8\:3044\:305f\:304b\:3060\:3051\:3067\:5224\:5b9a\:3059\:308b *)
  root = Lookup[kg, "Root", "root"];
  rootOwn = If[KeyExistsQ[index, root], Rest[iSWKGSectionOwnIds[kg, root]["Own"]], {}];
  If[rootOwn =!= {},
    PrependTo[rows, <|"Id" -> root, "Label" -> SourceVault`SourceVaultKGText[index[root], "Label"],
      "Nodes" -> Length[rootOwn], "Own" -> rootOwn, "Nested" -> {},
      "Done" -> AllTrue[rootOwn, Lookup[Lookup[index, #, <||>], "Points", {}] =!= {} &]|>]];
  (* \:4ed5\:4e0a\:3052 (\:5c0e\:5165\:6587\:30fb\:539f\:7a3f\:30fb\:56f3\:89e3) \:306e\:56de\:3067\:306f\:3001\:3069\:306e\:7bc0\:306b\:3082\:5c5e\:3055\:306a\:3044\:5468\:8fba\:77e5\:8b58\:30ce\:30fc\:30c9\:3082 1 \:884c\:306b\:3057\:3066\:5bfe\:8c61\:306b\:3059\:308b *)
  If[TrueQ[$iSWRefineTalkOnly],
    With[{bg = Complement[Select[Lookup[kg["Nodes"], "Id", {}], Lookup[index[#], "Layer", ""] === "Background" &],
        Flatten[Lookup[rows, "Own", {}]]]},
      If[bg =!= {}, AppendTo[rows, <|"Id" -> "bg", "Label" -> "\:5468\:8fba\:77e5\:8b58", "Nodes" -> Length[bg], "Own" -> bg,
        "Nested" -> {}, "Done" -> True|>]]]];
  rows];

(* \:672a\:63a8\:6572\:306e\:7bc0\:3092\:4e00\:89a7\:306e\:9806\:306b\:3001\:672c\:6587\:30ce\:30fc\:30c9\:5408\:8a08 maxNodes \:4ee5\:4e0b\:306e\:96a3\:63a5\:7bc0\:3067\:307e\:3068\:3081\:308b *)
(* \:539f\:7a3f (Talk) \:3060\:3051\:3092\:8db3\:3059\:8efd\:3044\:56de: \:8981\:70b9\:306f\:3042\:308b\:304c Talk \:306e\:7121\:3044\:30ce\:30fc\:30c9\:3092\:7bc0\:3054\:3068\:306b\:307e\:3068\:3081\:308b (\:63a8\:6572\:6e08\:307f KG \:306e\:5f8c\:4ed8\:3051\:7528) *)
$iSWRefineTalkOnly = False;
iSWNodeNeedsTalkQ[n_Association] := SourceVault`SourceVaultKGText[n, "Points"] =!= {} && SourceVault`SourceVaultKGText[n, "Talk"] === "";
(* \:5f8c\:4ed8\:3051 (Enrich) \:306e\:5bfe\:8c61: \:8981\:70b9\:306f\:3042\:308b\:304c Lead / Details / Talk \:306e\:3069\:308c\:304b\:304c\:7121\:3044\:30ce\:30fc\:30c9 *)
$iSWRefineEnrichAll = True;
iSWNodeNeedsEnrichQ[n_Association] := If[TrueQ[$iSWRefineEnrichAll],
  SourceVault`SourceVaultKGText[n, "Points"] =!= {} &&
    (SourceVault`SourceVaultKGText[n, "Talk"] === "" || SourceVault`SourceVaultKGText[n, "Lead"] === "" ||
     Replace[SourceVault`SourceVaultKGText[n, "Details"], Except[_List] -> {}] === {}),
  iSWNodeNeedsTalkQ[n]];
iSWNodeNeedsPassQ[n_Association] := If[TrueQ[$iSWRefineVisual], iSWNodeNeedsVisualQ[n], iSWNodeNeedsEnrichQ[n]];
iSWRefineBatches[kg_Association, maxNodes_Integer, selection_] := Module[{pending, batches = {}, cur = {}, n = 0, index},
  index = Association[(#["Id"] -> #) & /@ kg["Nodes"]];
  (* \:4ed5\:4e0a\:3052\:306e\:56de: \:7bc0\:306e\:4e26\:3073\:306e\:9806\:306b\:30ce\:30fc\:30c9\:3092\:96c6\:3081\:3001maxNodes \:500b\:305a\:3064\:306b\:5207\:308b (\:7bc0\:306e\:5927\:304d\:3055\:306b\:4f9d\:3089\:306a\:3044) *)
  If[TrueQ[$iSWRefineTalkOnly],
    Return[Partition[DeleteDuplicates[Select[Flatten[Map[Prepend[#["Own"], #["Id"]] &,
        Select[iSWKGSectionRows[kg], selection === All || MemberQ[selection, #["Id"]] &]]],
      KeyExistsQ[index, #] && iSWNodeNeedsPassQ[index[#]] &]], UpTo[Max[1, maxNodes]]]]];
  pending = Select[iSWKGSectionRows[kg], ! TrueQ[#["Done"]] && (selection === All || MemberQ[selection, #["Id"]]) &];
  Do[If[cur =!= {} && n + r["Nodes"] > maxNodes, AppendTo[batches, cur]; cur = {}; n = 0];
     AppendTo[cur, r["Id"]]; n += r["Nodes"], {r, pending}];
  If[cur =!= {}, AppendTo[batches, cur]];
  batches];

iSWRefineSchemaText[] :=
  "{\"Nodes\": [{\"Id\": \"<\:65e2\:5b58 Id>\", \"Kind\": \"Concept|Definition|Method|Experiment|Result|Question|Conclusion\", \"Label\": \"\:4f53\:8a00\:6b62\:3081\:306e\:77ed\:3044\:984c\:76ee (\:30b9\:30e9\:30a4\:30c9\:30bf\:30a4\:30c8\:30eb)\", \"Summary\": \"\:3067\:3059\:30fb\:307e\:3059\:8abf 1-2 \:6587\", \"Points\": [\"\:4f53\:8a00\:6b62\:3081 2-4 \:884c\"], \"Lead\": \"\:3053\:306e\:679a\:3067\:8a00\:3044\:305f\:3044\:3053\:3068 1 \:6587 (40 \:5b57\:4ee5\:5185\:3002\:30b9\:30e9\:30a4\:30c9\:3060\:3051\:898b\:3066\:3082\:4f55\:306e\:8a71\:304b\:5206\:304b\:308b\:5c0e\:5165\:6587)\", \"Details\": [\"\:5404 Point \:306b\:5bfe\:5fdc\:3059\:308b\:88dc\:8db3 1 \:884c (40 \:5b57\:4ee5\:5185\:3002\:4e0d\:8981\:306a\:3089 \"\")\"], \"Talk\": \"\:767a\:8868\:539f\:7a3f: Points \:3068\:540c\:3058\:9806\:306b 1 \:8981\:70b9\:306b\:3064\:304d 1 \:6587\:306e\:3067\:3059\:30fb\:307e\:3059\:8abf (\:8981\:70b9\:306b\:7121\:3044\:8a71\:984c\:304b\:3089\:59cb\:3081\:306a\:3044)\", \"Importance\": 0-1, \"Difficulty\": 0-1, \"Domains\": [\"\:9818\:57df\"]}],\n" <>
  " \"Edges\": [{\"From\": \"<Id>\", \"To\": \"<Id>\", \"EdgeKind\": \"Motivates|Derives|LeadsTo|Prerequisite|Supports|Explains|Contrasts\", \"Weight\": 0-1}],\n" <>
  " \"Remove\": [\"<\:4e0d\:8981\:306a\:6bb5\:843d\:306e Id>\"]}";
iSWRefineRulesText[] :=
  "- \:56f3 (fig*) \:3068\:5f0f (eq*) \:306e Id \:306f\:6b8b\:3057\:3001Label / Summary / Points \:3092\:4ed8\:3051\:308b (\:56f3\:8868\:306f\:4f5c\:308a\:76f4\:3055\:306a\:3044)\:3002\n" <>
  "- 1 \:679a\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:306a\:3089\:306a\:3044\:77ed\:3044\:6bb5\:843d\:30fb\:3064\:306a\:304e\:306e\:6bb5\:843d\:306f Remove \:3059\:308b\:304b\:3001\:96a3\:306e\:6bb5\:843d\:306e Points \:306b\:5438\:53ce\:3057\:3066 Remove \:3059\:308b\:30021 \:7bc0\:3042\:305f\:308a\:6b8b\:3059\:30ce\:30fc\:30c9\:306f 2\:301c8 \:500b\:304c\:76ee\:5b89\:3002\n" <>
  "- \:7bc0 (s*) \:81ea\:4f53\:306b\:3082 Label (\:77ed\:304f) \:3068 Summary \:3092\:4ed8\:3051\:308b (\:7bc0\:306f Remove \:3057\:306a\:3044)\:3002\:9806\:5e8f\:8fba\:306f\:3059\:3079\:3066 From \:3092\:5148\:306b\:63d0\:793a\:3059\:308b\:5411\:304d\:3002\n" <>
  "- \:8074\:304d\:624b\:306b\:7121\:3044\:524d\:63d0\:77e5\:8b58\:304c\:3042\:308c\:3070 \"Layer\": \"Background\" \:306e\:65b0\:30ce\:30fc\:30c9 (Id \:306f bg_ \:3067\:59cb\:3081\:308b) \:3092\:8db3\:3057\:3001Prerequisite \:8fba\:3092\:5f35\:308b\:3002\n" <>
  "- \:4f7f\:3063\:3066\:3088\:3044 Id \:306f\:672c\:6587\:306b\:51fa\:305f\:65e2\:5b58 Id \:3068\:65b0\:898f\:306e bg_* \:3060\:3051\:3002\:6570\:5024\:306e\:4e3b\:5f35\:306b\:306f\:51fa\:5178 (\:56f3\:8868\:756a\:53f7\:30fb\:7bc0) \:3092 Points \:306b\:542b\:3081\:308b\:3002\n" <>
  "- \:672c\:6587\:306e $...$ (LaTeX \:306e\:884c\:5185\:6570\:5f0f) \:306f Label / Points / Details \:3067\:305d\:306e\:307e\:307e $...$ \:3067\:4f7f\:3044\:3001\:66f8\:304d\:63db\:3048\:306a\:3044 (\:30b9\:30e9\:30a4\:30c9\:3067\:306f\:5143\:306e\:7d44\:7248\:306b\:623b\:308b)\:3002\n" <>
  "- Talk (\:8aad\:307f\:4e0a\:3052\:539f\:7a3f) \:306b\:306f $...$ \:3092\:66f8\:304b\:306a\:3044\:3002\:5f0f\:306f\:30b9\:30e9\:30a4\:30c9\:306b\:51fa\:3066\:3044\:308b\:306e\:3067\:300c\:3053\:306e\:5f0f\:306f\:301c\:3092\:8868\:3057\:307e\:3059\:300d\:300c\:5de6\:8fba\:306e J \:306f\:301c\:300d\:306e\:3088\:3046\:306b\:753b\:9762\:306e\:5f0f\:3092\:6307\:3057\:3066\:610f\:5473\:3092\:8a9e\:308b (TeX \:3092\:305d\:306e\:307e\:307e\:8aad\:307f\:4e0a\:3052\:308b\:3068 frac \:3068\:767a\:58f0\:3055\:308c\:3066\:4f1d\:308f\:3089\:306a\:3044)\:3002\n" <>
  "- \:5f0f\:304c\:51fa\:308b\:30ce\:30fc\:30c9\:3067\:306f\:3001\:5f0f\:306b\:73fe\:308c\:308b\:8a18\:53f7\:306e\:610f\:5473\:3092 Points \:304b Details \:306b\:5fc5\:305a\:66f8\:304f (\:300c$u$ \:306f\:81ea\:7531\:30a8\:30cd\:30eb\:30ae\:30fc\:300d\:300c$x$ \:306f\:4f4d\:7f6e\:300d\:306e\:3088\:3046\:306b\:521d\:51fa\:3067\:4e00\:8a00)\:3002\:8a18\:53f7\:306e\:8aac\:660e\:304c\:7121\:3044\:307e\:307e\:5f0f\:3060\:3051\:8f09\:308b\:30b9\:30e9\:30a4\:30c9\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:30b9\:30e9\:30a4\:30c9\:306f\:305d\:308c\:3060\:3051\:898b\:3066\:3082\:5185\:5bb9\:304c\:5206\:304b\:308b\:3088\:3046\:306b: Lead (\:5c0e\:5165\:6587) + Points (\:4e3b\:5f35) + Details (\:5404 Point \:306e\:6839\:62e0\:30fb\:88dc\:8db3)\:3002\:56f3\:8868\:756a\:53f7 (\:56f32, Table 1 \:306a\:3069) \:306f Points / Details / Talk \:306b\:66f8\:304b\:306a\:3044 (\:305d\:306e\:679a\:306b\:56f3\:304c\:7121\:3044\:3068\:8aad\:3081\:306a\:3044\:3002\:56f3\:3092\:6839\:62e0\:306b\:3059\:308b\:8a71\:306f fig* \:30ce\:30fc\:30c9\:306e Points \:306b\:66f8\:304f)\:3002\:5f37\:8abf\:3057\:305f\:3044\:8a9e\:53e5\:306f **\:2026** \:3067\:56f2\:3080 (1 \:30ce\:30fc\:30c9 1\:301c2 \:304b\:6240\:307e\:3067)\:3002";

(* \:7bc0\:672c\:6587 (\:5168\:30da\:30fc\:30b8\:3001\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:5411\:3051\:306e\:672b\:5c3e\:6ce8\:8a18\:306f\:5916\:3059) *)
iSWRefineSectionBody[gid_String, sid_String] := Module[{t = SlideGraphSectionText[gid, sid, "MaxCharacters" -> 200000]},
  If[! StringQ[t], Return["=== \:7bc0 " <> sid <> " (\:672c\:6587\:306a\:3057) ==="]];
  StringReplace[t, RegularExpression["\n\\(\:3053\:306e\:672c\:6587\:306f\:8aad\:3080\:305f\:3081\:306e\:3082\:306e[^\n]*$"] -> ""]];

(* \:4ed5\:4e0a\:3052\:306e\:56de\:306e\:5bfe\:8c61\:30ce\:30fc\:30c9: \:6e21\:3055\:308c\:305f Id \:304c\:7bc0\:306a\:3089\:305d\:306e\:672c\:6587\:30ce\:30fc\:30c9\:3078\:5e83\:3052\:308b *)
iSWRefinePassIds[kg_, index_Association, ids0_List] := Module[{rows = Association[(#["Id"] -> #) & /@ iSWKGSectionRows[kg]]},
  Select[DeleteDuplicates[Flatten[Map[If[KeyExistsQ[rows, #], Prepend[rows[#]["Own"], #], #] &, ids0]]],
    KeyExistsQ[index, #] && iSWNodeNeedsPassQ[index[#]] &]];
iSWRefineTalkPrompt[spec_Association, gid_String, sectionIds_List, metaBlocks_String] := Module[{kg = iSWKGResolve[gid], index, rows, ids, items},
  index = If[AssociationQ[kg], Association[(#["Id"] -> #) & /@ kg["Nodes"]], <||>];
  ids = iSWRefinePassIds[kg, index, sectionIds];
  items = Map[Function[id, With[{n = index[id]}, <|"Id" -> id, "Label" -> SourceVault`SourceVaultKGText[n, "Label"],
    "Points" -> SourceVault`SourceVaultKGText[n, "Points"], "Summary" -> SourceVault`SourceVaultKGText[n, "Summary"],
    "Text" -> StringTake[Replace[Lookup[n, "Text", ""], Except[_String] -> ""], UpTo[1200]]|>]], ids];
  metaBlocks <>
  "SlideWorkflow \:306e\:30b9\:30e9\:30a4\:30c9\:4ed5\:4e0a\:3052\:3002\:4ee5\:4e0b\:306e\:5404\:30ce\:30fc\:30c9 (\:30b9\:30e9\:30a4\:30c9 1 \:679a = Label \:304c\:984c\:76ee\:3001Points \:304c\:7b87\:6761\:66f8\:304d\:3001Text \:304c\:5143\:306e\:672c\:6587) \:306b Lead (\:5c0e\:5165\:6587) / Details (\:5404 Point \:306e\:88dc\:8db3) / Talk (\:539f\:7a3f) \:3092\:4ed8\:3051\:308b\:3002\:30b9\:30e9\:30a4\:30c9\:3060\:3051\:898b\:3066\:3082\:5185\:5bb9\:304c\:5206\:304b\:308b\:3088\:3046\:306b\:3059\:308b\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <> If[StringQ[spec["Story"]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "\:898f\:5247 (\:53b3\:5b88): Lead \:306f 1 \:6587 40 \:5b57\:4ee5\:5185 (\:3053\:306e\:679a\:3067\:8a00\:3044\:305f\:3044\:3053\:3068)\:3002Details \:306f Points \:3068\:540c\:3058\:9577\:3055\:306e\:914d\:5217\:3067\:3001\:5404 Point \:306e\:6839\:62e0\:30fb\:88dc\:8db3\:3092 1 \:884c 40 \:5b57\:4ee5\:5185 (\:4e0d\:8981\:306a\:3089 \"\")\:3002Talk \:306f Points \:3068\:540c\:3058\:9806\:306b 1 \:8981\:70b9\:306b\:3064\:304d 1\:301c2 \:6587\:306e\:3067\:3059\:30fb\:307e\:3059\:8abf\:3067\:3001\:8981\:70b9\:306b\:7121\:3044\:8a71\:984c\:304b\:3089\:59cb\:3081\:306a\:3044 (\:5192\:982d\:306e\:6982\:8981\:8aac\:660e\:304c\:7b87\:6761\:66f8\:304d\:3068\:98df\:3044\:9055\:3046\:3068\:8074\:304d\:624b\:304c\:8ff7\:3046)\:3002Talk \:306f\:8aad\:307f\:4e0a\:3052\:539f\:7a3f\:306a\:306e\:3067 $...$ \:306e\:6570\:5f0f\:3092\:66f8\:304b\:305a\:3001\:5f0f\:306f\:300c\:3053\:306e\:5f0f\:300d\:300c\:5de6\:8fba\:300d\:306e\:3088\:3046\:306b\:753b\:9762\:3092\:6307\:3057\:3066\:8a9e\:308b\:3002\:5f0f\:306b\:51fa\:308b\:8a18\:53f7\:306e\:610f\:5473\:306f Lead \:304b Details \:3067\:8aac\:660e\:3059\:308b\:3002\:56f3\:8868\:756a\:53f7 (\:56f32, Table 1 \:306a\:3069) \:306f\:66f8\:304b\:306a\:3044\:3002\:5f37\:8abf\:306f **\:2026** (1\:301c2 \:304b\:6240)\:3002$...$ \:306e\:6570\:5f0f\:306f\:305d\:306e\:307e\:307e\:3002Text \:306b\:7121\:3044\:4e8b\:5b9f\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "\:51fa\:529b (\:53b3\:5b88): JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3002\:8aac\:660e\:6587\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:7121\:3057:\n{\"Nodes\": [{\"Id\": \"<Id>\", \"Lead\": \"...\", \"Details\": [\"...\"], \"Talk\": \"...\"}]}\n\n=== \:30ce\:30fc\:30c9 ===\n" <>
  SourceVault`SourceVaultKGToJSON[<|"Nodes" -> items|>]];

iSWRefinePrompt[spec_Association, gid_String, sectionIds_List, metaBlocks_String] :=
  Which[TrueQ[$iSWRefineVisual], iSWRefineVisualPrompt[spec, gid, sectionIds, metaBlocks],
  TrueQ[$iSWRefineTalkOnly], iSWRefineTalkPrompt[spec, gid, sectionIds, metaBlocks],
  TrueQ[$iSWRefineScenario], iSWRefineScenarioPrompt[spec, gid, sectionIds, metaBlocks], True,
  metaBlocks <>
  "SlideWorkflow \:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:63a8\:6572\:3002GraphId \"" <> gid <> "\" \:306f\:548c\:8a33\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:306e\:6bb5\:843d\:3092\:305d\:306e\:307e\:307e\:30ce\:30fc\:30c9\:306b\:3057\:305f\:7b2c\:4e00\:6b21 KG \:3067\:3001\:30e9\:30d9\:30eb\:306f\:6bb5\:843d\:5192\:982d\:3001\:8981\:70b9\:306f\:7a7a\:3001\:8fba\:306f Contains / Precedes \:3060\:3051\:3002\:4ee5\:4e0b\:306e\:7bc0\:306e\:672c\:6587\:3092\:8aad\:307f\:3001\:767a\:8868\:7528\:306e KG \:3078\:78e8\:304f\:5dee\:5206 JSON \:3092\:8fd4\:3059\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <>
  If[StringQ[spec["Story"]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "\:51fa\:529b (\:53b3\:5b88): \:6b21\:306e\:5f62\:306e JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3092\:8fd4\:3059\:3002\:8aac\:660e\:6587\:30fb\:524d\:7f6e\:304d\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:306f\:4ed8\:3051\:306a\:3044\:3002\n" <>
  iSWRefineSchemaText[] <> "\n\:898f\:5247:\n" <> iSWRefineRulesText[] <> "\n\n=== \:672c\:6587 ===\n" <>
  StringRiffle[Map[iSWRefineSectionBody[gid, #] &, sectionIds], "\n\n"]];

(* ---- \:56f3\:89e3\:306e\:56de (Mode -> "Visual"): \:56f3\:306e\:7121\:3044\:30ce\:30fc\:30c9\:306b\:3001\:8868\:304b\:6982\:5ff5\:56f3 (WL \:30b3\:30fc\:30c9) \:3092 1 \:3064\:4ed8\:3051\:308b ---- *)
$iSWRefineVisual = False;
iSWNodeNeedsVisualQ[n_Association] := SourceVault`SourceVaultKGText[n, "Points"] =!= {} &&
  Replace[Lookup[n, "Assets", {}], Except[_List] -> {}] === {} && ! TrueQ[Lookup[n, "VisualDone", False]];
iSWFigNodeQ[n_Association] := AnyTrue[Replace[Lookup[n, "Assets", {}], Except[_List] -> {}],
  AssociationQ[#] && MemberQ[{"NotebookFigure", "PDFFigure", "PDFImage", "DeckSlide", "Image"}, Lookup[#, "Type", ""]] &];
iSWRefineVisualPrompt[spec_Association, gid_String, sectionIds_List, metaBlocks_String] := Module[
  {kg = iSWKGResolve[gid], index, ids, items, adj},
  index = If[AssociationQ[kg], Association[(#["Id"] -> #) & /@ kg["Nodes"]], <||>];
  ids = iSWRefinePassIds[kg, index, sectionIds];
  adj = If[AssociationQ[kg], Merge[Join[Map[#["From"] -> #["To"] &, kg["Edges"]], Map[#["To"] -> #["From"] &, kg["Edges"]]], DeleteDuplicates], <||>];
  items = Map[Function[id, With[{n = index[id]}, <|"Id" -> id, "Layer" -> Lookup[n, "Layer", ""],
    "Label" -> SourceVault`SourceVaultKGText[n, "Label"], "Lead" -> SourceVault`SourceVaultKGText[n, "Lead"],
    "Points" -> SourceVault`SourceVaultKGText[n, "Points"], "Summary" -> SourceVault`SourceVaultKGText[n, "Summary"],
    "PaperFigures" -> Map[SourceVault`SourceVaultKGText[index[#], "Label"] &,
      Select[Lookup[adj, id, {}], KeyExistsQ[index, #] && iSWFigNodeQ[index[#]] &]]|>]], ids];
  metaBlocks <>
  "SlideWorkflow \:306e\:30b9\:30e9\:30a4\:30c9\:56f3\:89e3\:3002\:4ee5\:4e0b\:306e\:5404\:30ce\:30fc\:30c9 (\:30b9\:30e9\:30a4\:30c9 1 \:679a = Label \:304c\:984c\:76ee\:3001Lead \:304c\:5c0e\:5165\:6587\:3001Points \:304c\:7b87\:6761\:66f8\:304d) \:306b\:3001" <>
  "\:30b9\:30e9\:30a4\:30c9\:3092\:898b\:305f\:3060\:3051\:3067\:5206\:304b\:308a\:3084\:3059\:304f\:306a\:308b\:56f3\:304b\:8868\:3092 1 \:3064\:4ed8\:3051\:308b\:3002\:56f3\:3084\:5199\:771f\:304c\:4e3b\:5f79\:3067\:3001\:7b87\:6761\:66f8\:304d\:304c\:305d\:308c\:3092\:8aac\:660e\:3059\:308b\:767a\:8868\:3092\:76ee\:6307\:3059\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <> If[StringQ[spec["Story"]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "\:9078\:3073\:65b9:\n" <>
  "- \:6bd4\:8f03\:30fb\:4e00\:89a7\:30fb\:7528\:8a9e\:30fb\:6761\:4ef6\:30fb\:624b\:9806\:306e\:4e26\:3073 \:2192 \"Table\" (1 \:884c\:76ee\:304c\:898b\:51fa\:3057\:3001\:7d9a\:3051\:3066 2\:301c6 \:884c\:30012\:301c4 \:5217\:30011 \:30bb\:30eb 25 \:5b57\:4ee5\:5185)\:3002\n" <>
  "- \:4ed5\:7d44\:307f\:30fb\:6d41\:308c\:30fb\:9589\:30eb\:30fc\:30d7\:30fb\:69cb\:9020\:30fb\:5b9a\:6027\:7684\:306a\:5909\:5316 \:2192 \"Code\" (Wolfram Language \:3067\:6982\:5ff5\:56f3\:30fb\:6a21\:5f0f\:56f3\:3092\:63cf\:304f)\:3002\n" <>
  "- PaperFigures (\:305d\:306e\:30ce\:30fc\:30c9\:306b\:7d50\:3070\:308c\:305f\:8ad6\:6587\:306e\:56f3) \:3067\:8db3\:308a\:308b\:3068\:304d\:3001\:56f3\:306b\:3057\:3066\:3082\:5206\:304b\:308a\:3084\:3059\:304f\:306a\:3089\:306a\:3044\:3068\:304d \:2192 \"None\"\:3002\n" <>
  "- \:8ad6\:6587\:306e\:5b9f\:6e2c\:30c7\:30fc\:30bf\:3092\:4f5c\:56f3\:3057\:76f4\:3055\:306a\:3044 (\:6570\:5024\:306e\:634f\:9020\:306b\:306a\:308b)\:3002Code \:306f\:6a21\:5f0f\:56f3\:3068\:5b9a\:6027\:7684\:306a\:66f2\:7dda\:3060\:3051\:306b\:3057\:3001\:5b9a\:6027\:7684\:306a\:66f2\:7dda\:306e\:8ef8\:306b\:6570\:5024\:3092\:4ed8\:3051\:306a\:3044\:3002\n\n" <>
  "Code \:306e\:898f\:5247 (\:53b3\:5b88):\n" <>
  "- \:5168\:4f53\:304c 1 \:3064\:306e\:5f0f\:3067\:3001Graphics / Plot \:7cfb / GraphicsRow / Graph \:306e\:3069\:308c\:304b\:3092\:8fd4\:3059\:3002\:88dc\:52a9\:306e\:5024\:306f Module / With \:306e\:4e2d\:306b\:7f6e\:304f (\:5927\:57df\:5909\:6570\:306b\:4ee3\:5165\:3057\:306a\:3044)\:3002\n" <>
  "- \:4f7f\:3063\:3066\:3088\:3044\:306e\:306f\:4f5c\:56f3\:3068\:6570\:5b66\:306e\:7d44\:8fbc\:307f\:95a2\:6570\:3060\:3051: Graphics, Plot, ListLinePlot, ParametricPlot, BarChart, GraphicsRow, Graph, " <>
  "Line, Arrow, Arrowheads, Rectangle, Disk, Circle, Polygon, BezierCurve, Text, Style, Inset, Table, Range, Map, Module, With \:306a\:3069\:3002" <>
  "Import / Export / \:30d5\:30a1\:30a4\:30eb / \:30cd\:30c3\:30c8\:30ef\:30fc\:30af / Symbol / ToExpression \:306f\:4f7f\:308f\:306a\:3044\:3002\n" <>
  "- \:8272: \:6a59 RGBColor[0.878, 0.486, 0.078]\:3001\:81d9\:8102 RGBColor[0.616, 0.11, 0.11]\:3001\:7070 GrayLevel[0.35]\:3001\:9762 RGBColor[0.98, 0.965, 0.94]\:3001\:67a0 RGBColor[0.9, 0.85, 0.77]\:3002\n" <>
  "- \:6587\:5b57\:306f\:65e5\:672c\:8a9e\:3067\:77ed\:304f (1 \:30e9\:30d9\:30eb 12 \:5b57\:7a0b\:5ea6)\:3002ImageSize \:3068 FontFamily \:306f\:4ed8\:3051\:306a\:3044 (\:3053\:3061\:3089\:3067\:63c3\:3048\:308b)\:300240 \:884c\:4ee5\:5185\:3002\n" <>
  "- Caption \:306f\:56f3\:306e\:4e0b\:306b\:51fa\:3059\:4e00\:8a00 (20 \:5b57\:4ee5\:5185\:3001\:300c\:6982\:5ff5\:56f3: \:2026\:300d\:306e\:3088\:3046\:306b)\:3002\n\n" <>
  "\:51fa\:529b (\:53b3\:5b88): JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3002\:5168\:30ce\:30fc\:30c9\:306b 1 \:3064\:305a\:3064\:8fd4\:3059\:3002\:8aac\:660e\:6587\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:7121\:3057:\n" <>
  "{\"Nodes\": [{\"Id\": \"<Id>\", \"Visual\": {\"Type\": \"Table\", \"Rows\": [[\"\:898b\:51fa\:3057\", \"\:898b\:51fa\:3057\"], [\"\:2026\", \"\:2026\"]]}}, " <>
  "{\"Id\": \"<Id>\", \"Visual\": {\"Type\": \"Code\", \"Code\": \"Graphics[{...}]\", \"Caption\": \"\:6982\:5ff5\:56f3: \:2026\"}}, " <>
  "{\"Id\": \"<Id>\", \"Visual\": {\"Type\": \"None\"}}]}\n\n=== \:30ce\:30fc\:30c9 ===\n" <>
  SourceVault`SourceVaultKGToJSON[<|"Nodes" -> items|>]];

(* \:8868: \:884c = \:6587\:5b57\:5217\:306e\:5217 (\:6570\:5024\:306f\:6587\:5b57\:5217\:306b)\:3002\:898b\:51fa\:3057\:884c\:306e\:5217\:6570\:306b\:305d\:308d\:3048\:3001\:9577\:3044\:30bb\:30eb\:306f\:5207\:308b *)
iSWCleanRows[rows_] := Module[{rs, w},
  rs = Select[Replace[rows, Except[_List] -> {}], ListQ];
  rs = Map[Function[r, Map[Function[c, With[{s = StringTrim[Which[StringQ[c], c, NumericQ[c], ToString[c], True, ""]]},
    If[StringLength[s] > 40, StringTake[s, 39] <> "\:2026", s]]], r]], rs];
  If[Length[rs] < 2, Return[$Failed]];
  w = Length[First[rs]];
  If[w < 2 || w > 4, Return[$Failed]];
  Take[PadRight[Take[#, UpTo[w]], w, ""] & /@ rs, UpTo[8]]];

iSWVisualAssetOf[v_] := Module[{type},
  If[! AssociationQ[v], Return[None]];
  type = ToString[Lookup[v, "Type", "None"]];
  Switch[type,
    "Table", With[{rows = iSWCleanRows[Lookup[v, "Rows", {}]]},
      If[rows === $Failed, $Failed, <|"Type" -> "Table", "Rows" -> rows|>]],
    "Code", With[{code = Lookup[v, "Code", ""], cap = Lookup[v, "Caption", ""]},
      If[StringQ[code] && iSWFigureFromCode[code] =!= $Failed,
        <|"Type" -> "WLFigure", "Code" -> code, "Caption" -> If[StringQ[cap], StringTake[cap, UpTo[40]], ""]|>, $Failed]],
    _, None]];

(* \:53d7\:3051\:53d6\:3063\:305f\:56f3\:89e3\:3092\:8cc7\:7523\:306b\:3059\:308b\:3002\:56f3\:89e3\:3092\:8a66\:3057\:305f\:30ce\:30fc\:30c9\:306b\:306f VisualDone \:3092\:4ed8\:3051\:3066\:3001\:6b21\:306e\:56de\:3067\:805e\:304d\:76f4\:3055\:306a\:3044 *)
iSWVisualNodes[nodes_List] := Map[Function[n, With[{a = iSWVisualAssetOf[Lookup[n, "Visual", None]]},
    Which[
      AssociationQ[a],
        $iSWRefineRun[If[a["Type"] === "Table", "Tables", "Figures"]] = Lookup[$iSWRefineRun, If[a["Type"] === "Table", "Tables", "Figures"], 0] + 1;
        <|"Id" -> n["Id"], "Assets" -> {a}, "VisualDone" -> True|>,
      a === $Failed,
        $iSWRefineRun["Rejected"] = Lookup[$iSWRefineRun, "Rejected", 0] + 1;
        <|"Id" -> n["Id"], "VisualDone" -> True|>,
      True,
        $iSWRefineRun["NoVisual"] = Lookup[$iSWRefineRun, "NoVisual", 0] + 1;
        <|"Id" -> n["Id"], "VisualDone" -> True|>]]], nodes];

iSWRefineExtractJSON[resp_String] := Module[{t, a, b},
  t = StringReplace[resp, {"```json" -> "", "```JSON" -> "", "```" -> ""}];
  a = StringPosition[t, "{", 1]; b = StringPosition[t, "}"];
  If[a === {} || b === {} || b[[-1, 1]] <= a[[1, 1]], $Failed, StringTake[t, {a[[1, 1]], b[[-1, 1]]}]]];

(* \:53d7\:7406: Nodes \:306f\:30d0\:30c3\:30c1\:306e Id \:304b bg_*\:3001Edges \:306e\:7aef\:70b9\:306f KG \:306e\:65e2\:5b58 Id \:304b bg_*\:3001Remove \:306f\:30d0\:30c3\:30c1\:306e\:672c\:6587\:30ce\:30fc\:30c9\:3060\:3051 (\:7bc0\:306f\:6b8b\:3059) *)
iSWRefineSanitize[delta_Association, batchIds_List, kgIds_List] := Module[{d = KeyMap[ToString, delta], nodeOk, edgeOk},
  nodeOk[id_] := (MemberQ[batchIds, id] && id =!= "root") || StringStartsQ[id, "bg_"];
  edgeOk[id_] := MemberQ[kgIds, id] || MemberQ[batchIds, id] || StringStartsQ[id, "bg_"];
  d["Nodes"] = Select[Replace[Lookup[d, "Nodes", {}], Except[_List] -> {}],
    AssociationQ[#] && StringQ[Lookup[#, "Id", None]] && nodeOk[#["Id"]] &];
  d["Edges"] = Select[Replace[Lookup[d, "Edges", {}], Except[_List] -> {}],
    AssociationQ[#] && StringQ[Lookup[#, "From", None]] && StringQ[Lookup[#, "To", None]] && edgeOk[#["From"]] && edgeOk[#["To"]] &];
  d["Remove"] = If[TrueQ[$iSWRefineTalkOnly], {}, Select[Replace[Lookup[d, "Remove", {}], Except[_List] -> {}],
    StringQ[#] && MemberQ[batchIds, #] && ! StringStartsQ[#, "s"] && # =!= "root" &]];
  Which[
    TrueQ[$iSWRefineVisual], d["Nodes"] = iSWVisualNodes[d["Nodes"]]; d["Edges"] = {},
    TrueQ[$iSWRefineTalkOnly], d["Nodes"] = Map[KeyTake[#, {"Id", "Lead", "Details", "Talk"}] &, d["Nodes"]]; d["Edges"] = {}];
  d];

iSWRefinePrivacy[nb_, kg_Association] := Module[{deckPL, nodePL, relPL},
  deckPL = If[Head[nb] === NotebookObject, Quiet @ Check[Lookup[iSWDirectiveMeta[nb], "PrivacyLevel", 0.], 0.], 0.];
  If[! NumericQ[deckPL], deckPL = 0.];
  nodePL = Max[Prepend[Select[Lookup[kg["Nodes"], "PrivacyLevel", 0.], NumericQ], 0.]];
  (* \:30b7\:30ca\:30ea\:30aa\:306e\:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc\:3082 LLM \:306b\:6e21\:308b\:306e\:3067\:3001\:305d\:306e\:6a5f\:5bc6\:5ea6\:3082\:6570\:3048\:308b *)
  relPL = Max[Join[{0.}, Select[Map[Lookup[#, "PrivacyLevel", 0.] &,
    Select[Replace[Lookup[kg, "Related", {}], Except[_List] -> {}], AssociationQ]], NumericQ]]];
  N[Max[deckPL, nodePL, relPL]]];

(* \:56de\:306e\:7a2e\:985e (\:63a8\:6572 / \:4ed5\:4e0a\:3052 / \:56f3\:89e3) \:306f\:958b\:59cb\:6642\:306b ctx \:3078\:5199\:3057\:3001\:9023\:9396\:306e\:5404\:6bb5\:306f\:305d\:308c\:3067\:52d5\:304f\:3002\:5927\:57df\:306e\:65d7\:306f\:958b\:59cb\:76f4\:5f8c\:306b\:65e2\:5b9a\:3078\:623b\:3059
   (\:9023\:9396\:306e\:9014\:4e2d\:3067\:5225\:306e\:30dc\:30bf\:30f3\:304c\:65d7\:3092\:66f8\:304d\:63db\:3048\:3066\:3082\:3001\:52d5\:3044\:3066\:3044\:308b\:56de\:306e\:7a2e\:985e\:306f\:5909\:308f\:3089\:306a\:3044\:3002\:8a08\:7b97\:3068\:81ea\:713633: \:63a8\:6572\:306e\:9014\:4e2d\:3067\:56f3\:89e3\:304c\:59cb\:307e\:308a\:3001
   \:5f8c\:534a 4 \:7bc0\:304c\:63a8\:6572\:3055\:308c\:306a\:3044\:307e\:307e\:751f\:6210\:3055\:308c\:305f) *)
$iSWRefineScenario = False;
iSWRefineFlagsNow[] := <|"TalkOnly" -> TrueQ[$iSWRefineTalkOnly], "Visual" -> TrueQ[$iSWRefineVisual],
  "EnrichAll" -> TrueQ[$iSWRefineEnrichAll], "Scenario" -> TrueQ[$iSWRefineScenario]|>;
SetAttributes[iSWWithRefineFlags, HoldRest];
iSWWithRefineFlags[ctx_Association, expr_] := With[{f = Replace[Lookup[ctx, "Flags", None], Except[_Association] :> iSWRefineFlagsNow[]]},
  Block[{$iSWRefineTalkOnly = TrueQ[f["TalkOnly"]], $iSWRefineVisual = TrueQ[f["Visual"]], $iSWRefineEnrichAll = TrueQ[f["EnrichAll"]],
      $iSWRefineScenario = TrueQ[f["Scenario"]]},
    expr]];
iSWRefineResetFlags[] := ($iSWRefineTalkOnly = False; $iSWRefineVisual = False; $iSWRefineEnrichAll = True;
  $iSWRefineScenario = False;);

(* \:672a\:63a8\:6572\:306e\:7bc0: \:672c\:6587\:30ce\:30fc\:30c9\:304c\:3042\:308b\:306e\:306b\:63a8\:6572\:304c\:6e08\:3093\:3067\:3044\:306a\:3044\:7bc0 (\:63a8\:6572\:304c\:9014\:4e2d\:3067\:6b62\:307e\:3063\:305f\:3001\:305d\:306e\:7bc0\:306e\:554f\:3044\:5408\:308f\:305b\:304c\:843d\:3061\:305f)\:3002
   \:305d\:306e\:7bc0\:306e\:7b87\:6761\:66f8\:304d\:306f\:6bb5\:843d\:306e\:66f8\:304d\:51fa\:3057 (\:300c\:2026\:300d\:3067\:5207\:308c\:305f\:4eee\:306e\:984c\:76ee) \:306e\:307e\:307e\:306b\:306a\:308b\:3002\:56f3\:89e3\:30fb\:4ed5\:4e0a\:3052\:30fb\:8abf\:6574\:306f\:5148\:306b\:3053\:306e\:7bc0\:3092\:63a8\:6572\:3057\:3001\:751f\:6210\:306f\:8b66\:544a\:3059\:308b *)
iSWUnrefinedSections[kg_Association] := Module[{index = Association[(#["Id"] -> #) & /@ kg["Nodes"]], rawQ},
  (* seed \:306e\:307e\:307e\:306e\:6bb5\:843d = \:672c\:6587 (Text) \:304c\:3042\:308b\:306e\:306b\:8981\:70b9\:304c\:7121\:3044 (\:624b\:3067\:4f5c\:3063\:305f KG \:306e\:672c\:6587\:306e\:7121\:3044\:30ce\:30fc\:30c9\:306f\:6570\:3048\:306a\:3044) *)
  rawQ[id_] := With[{n = Lookup[index, id, <||>]},
    StringTrim[Replace[Lookup[n, "Text", ""], Except[_String] -> ""]] =!= "" && ! TrueQ[Lookup[n, "Hidden", False]] &&
      ! MatchQ[SourceVault`SourceVaultKGText[n, "Points"], {__String}]];
  Lookup[Select[Block[{$iSWRefineTalkOnly = False}, iSWKGSectionRows[kg]],
    ! TrueQ[#["Done"]] && AnyTrue[#["Own"], rawQ] &], "Id", {}]];
iSWUnrefinedSections[_] := {};
iSWUnrefinedNote[kg_Association, ids_List] := With[{index = Association[(#["Id"] -> #) & /@ kg["Nodes"]]},
  StringRiffle[Map[# <> If[KeyExistsQ[index, #], " " <> StringTake[SourceVault`SourceVaultKGText[index[#], "Label"], UpTo[24]], ""] &,
    Take[ids, UpTo[4]]], ", "] <> If[Length[ids] > 4, " \:2026", ""]];

(* \:672a\:63a8\:6572\:306e\:7bc0\:3092\:5148\:306b\:63a8\:6572\:3057\:3001\:7d42\:308f\:3063\:305f\:3089 then \:3092\:547c\:3076 *)
iSWRefineFirst[nb_, spec_Association, kg_Association, ids_List, maxNodes_, then_, note_List] := Module[{r},
  iSWStatusIf[nb, iSL["\:63a8\:6572\:304c\:6e08\:3093\:3067\:3044\:306a\:3044\:7bc0\:304c\:3042\:308a\:307e\:3059 (" <> iSWUnrefinedNote[kg, ids] <> ")\:3002\:5148\:306b\:63a8\:6572\:3057\:307e\:3059\:2026",
    "Some sections are not refined yet (" <> iSWUnrefinedNote[kg, ids] <> "); refining them first..."]];
  iSWRefineResetFlags[];
  r = iSWRefineStart[nb, spec, kg, If[IntegerQ[maxNodes] && maxNodes > 0, maxNodes, 8], ids, then, note];
  If[AssociationQ[r], Append[r, "RefineFirst" -> ids], r]];

iSWRefineStart[nb_, spec_Association, kg_Association, maxNodes_Integer, selection_, then_ : None, thenNote_ : None] := Module[
  {gid = spec["Graph"], batches, ctx, pl, flags = iSWRefineFlagsNow[], kg1},
  If[! iSWLLMReadyQ[], iSWRefineResetFlags[];
    Return[Failure["NoLLM", <|"MessageTemplate" -> "LLM query function is not registered (load NBAccess/claudecode)"|>]]];
  If[iSWRefineBusyQ[],
    iSWRefineResetFlags[];
    iSWStatusIf[nb, iSL["KG \:63a8\:6572\:3092\:5b9f\:884c\:4e2d\:3067\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044", "A KG refinement run is already in progress"]];
    Return[<|"Status" -> "Busy", "Graph" -> gid|>]];
  kg1 = iSWKGCiteRepair[gid, kg];
  (* \:30b7\:30ca\:30ea\:30aa\:304b\:3089\:4f5c\:3063\:305f KG \:306e\:672c\:63a8\:6572\:306f\:300c\:7b4b\:66f8\:304d\:306e\:5c55\:958b\:300d(\:7bc0\:3054\:3068\:306b\:65b0\:3057\:3044\:679a\:3092\:4f5c\:308b) *)
  flags["Scenario"] = ! TrueQ[flags["TalkOnly"]] && ! TrueQ[flags["Visual"]] && Lookup[kg1, "Kind", ""] === "Scenario";
  batches = iSWWithRefineFlags[<|"Flags" -> flags|>, iSWRefineBatches[kg1, maxNodes, selection]];
  (* \:4f55\:3082\:3057\:306a\:3044\:3067\:8fd4\:308b\:3068\:304d\:3082\:56de\:306e\:7a2e\:985e\:3092\:623b\:3059 (\:623b\:3055\:306a\:3044\:3068\:5f8c\:306e\:63a8\:6572\:3084\:7bc0\:306e\:4e00\:89a7\:304c\:4ed5\:4e0a\:3052\:306e\:56de\:306e\:307e\:307e\:52d5\:304f) *)
  iSWRefineResetFlags[];
  If[batches === {},
    iSWStatusIf[nb, iSL["\:5168\:7bc0\:304c\:63a8\:6572\:6e08\:307f\:3067\:3059 (\:6b21\:306f\:300c\:5468\:8fba\:77e5\:8b58\:300d\:307e\:305f\:306f\:300c\:8a08\:753b\:300d)", "All sections are refined (next: background or plan)"]];
    If[Head[nb] === NotebookObject, iSWStatusClearLater[nb]];
    If[then =!= None, Quiet[then[]]];
    Return[<|"Status" -> "UpToDate", "Graph" -> gid, "Batches" -> 0|>]];
  pl = iSWRefinePrivacy[nb, kg1];
  ctx = <|"Spec" -> spec, "PL" -> pl, "Total" -> Length[batches],
    "Meta" -> If[Head[nb] === NotebookObject, iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb], ""],
    "Flags" -> flags, "Then" -> then, "ThenNote" -> thenNote|>;
  $iSWRefineRun = <|"OK" -> 0, "NG" -> 0, "Failed" -> {}, "Warnings" -> {}, "Calls" -> 0,
    "Figures" -> 0, "Tables" -> 0, "NoVisual" -> 0, "Rejected" -> 0|>;
  $iSWRefineBusy = True; $iSWRefineBusySince = AbsoluteTime[];
  iSWRefineChain[nb, gid, batches, 1, ctx];
  <|"Status" -> "Submitted", "Graph" -> gid, "Batches" -> Length[batches], "Sections" -> Flatten[batches], "PrivacyLevel" -> pl|>];

iSWRefineChain[nb_, gid_String, batches_List, idx_Integer, ctx_Association] :=
  If[idx > Length[batches],
    $iSWRefineBusy = False;
    iSWRefineFinish[nb, gid, ctx],
    iSWRefineRunOne[nb, gid, batches, idx, ctx, 0, ""]];

iSWRefineRunOne[nb_, gid_String, batches_List, idx_Integer, ctx_Association, retry_Integer, note_String] := Module[{ids = batches[[idx]], prompt,
    visual = TrueQ[Lookup[Replace[Lookup[ctx, "Flags", <||>], Except[_Association] -> <||>], "Visual", $iSWRefineVisual]]},
  $iSWRefineBusySince = AbsoluteTime[];
  iSWStatusIf[nb, iSL[Which[visual, "KG \:56f3\:89e3 ",
    TrueQ[Lookup[Replace[Lookup[ctx, "Flags", <||>], Except[_Association] -> <||>], "Scenario", False]], "KG \:5c55\:958b ",
    True, "KG \:63a8\:6572 "] <> ToString[idx] <> "/" <> ToString[Length[batches]] <> " (" <> StringRiffle[ids, ", "] <> ")" <> If[retry > 0, " \:518d\:554f\:5408\:305b", ""] <> "...",
    "Refining KG " <> ToString[idx] <> "/" <> ToString[Length[batches]] <> " (" <> StringRiffle[ids, ", "] <> ")" <> If[retry > 0, " retry", ""] <> "..."]];
  prompt = iSWWithRefineFlags[ctx, iSWRefinePrompt[ctx["Spec"], gid, ids, ctx["Meta"]]] <> note;
  $iSWRefineRun["Calls"] = $iSWRefineRun["Calls"] + 1;
  With[{n2 = nb, g = gid, b = batches, i2 = idx, c = ctx, r = retry},
    NBAccess`$NBLLMQueryFunc[prompt,
      Function[resp, iSWRefineApply[n2, g, b, i2, c, r, resp]],
      n2, Fallback -> iSWFallback[], PrivacyLevel -> ctx["PL"]]];
  Null];

iSWRefineApply[nb_, gid_String, batches_List, idx_Integer, ctx_Association, retry_Integer, resp_] :=
  iSWWithRefineFlags[ctx, iSWRefineApply0[nb, gid, batches, idx, ctx, retry, resp]];
iSWRefineApply0[nb_, gid_String, batches_List, idx_Integer, ctx_Association, retry_Integer, resp_] := Module[
  {ids = batches[[idx]], kg, json, delta, ownOf, batchIds, res, why},
  kg = iSWKGResolve[gid];
  json = If[StringQ[resp] && ! StringStartsQ[resp, "Error" | "[ERROR]"], iSWRefineExtractJSON[resp], $Failed];
  delta = If[StringQ[json], Quiet @ Check[Developer`ReadRawJSONString[json], $Failed], $Failed];
  If[AssociationQ[kg] && AssociationQ[delta],
    ownOf = Association[Map[#["Id"] -> #["Own"] &, iSWKGSectionRows[kg]]];
    batchIds = Join[ids, Flatten[Lookup[ownOf, ids, {}]]];
    delta = If[TrueQ[$iSWRefineScenario], iSWScenarioSanitize[delta, ids, kg],
      iSWRefineSanitize[delta, batchIds, Lookup[kg["Nodes"], "Id"]]];
    res = SlideGraphIngest[gid, delta, "Merge" -> True],
    res = $Failed];
  If[MatchQ[res, _Success],
    $iSWRefineRun["OK"] = $iSWRefineRun["OK"] + 1;
    $iSWRefineRun["Warnings"] = Join[$iSWRefineRun["Warnings"], Replace[Quiet @ Check[res["Warnings"], {}], Except[_List] -> {}]];
    iSWRefineChain[nb, gid, batches, idx + 1, ctx],
    why = Which[! StringQ[resp], "\:5fdc\:7b54\:304c\:6587\:5b57\:5217\:3067\:306a\:3044", ! StringQ[json], "JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8\:304c\:898b\:3064\:304b\:3089\:306a\:3044",
      ! AssociationQ[delta], "JSON \:3092\:89e3\:6790\:3067\:304d\:306a\:3044", True, StringTake[ToString[res], UpTo[200]]];
    If[retry < 1,
      iSWRefineRunOne[nb, gid, batches, idx, ctx, retry + 1,
        "\n\n\:524d\:56de\:306e\:5fdc\:7b54\:306f\:53d6\:308a\:8fbc\:3081\:306a\:304b\:3063\:305f (" <> why <> ")\:3002\:4e0a\:306e\:5f62\:306e JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3092\:8fd4\:3059\:3002"],
      $iSWRefineRun["NG"] = $iSWRefineRun["NG"] + 1;
      $iSWRefineRun["Failed"] = Append[$iSWRefineRun["Failed"], ids];
      iSWRefineChain[nb, gid, batches, idx + 1, ctx]]]];

iSWRefineFinish[nb_, gid_String, ctx_Association : <||>] := Module[{kg = iSWKGResolve[gid], rows, done, total, msg, talkOnly, visual,
    f = Replace[Lookup[ctx, "Flags", None], Except[_Association] :> iSWRefineFlagsNow[]],
    then = Lookup[ctx, "Then", None], thenNote = Lookup[ctx, "ThenNote", None]},
  talkOnly = TrueQ[f["TalkOnly"]]; visual = TrueQ[f["Visual"]];
  iSWRefineResetFlags[];
  rows = If[AssociationQ[kg], iSWKGSectionRows[kg], {}];
  done = Count[rows, r_ /; TrueQ[r["Done"]]]; total = Length[rows];
  msg = iSL[Which[talkOnly, "KG \:4ed5\:4e0a\:3052 (\:5c0e\:5165\:6587\:30fb\:88dc\:8db3\:30fb\:539f\:7a3f) \:5b8c\:4e86: ", TrueQ[f["Scenario"]], "KG \:5c55\:958b (\:30b7\:30ca\:30ea\:30aa) \:5b8c\:4e86: ",
      True, "KG \:63a8\:6572 \:5b8c\:4e86: "] <> ToString[$iSWRefineRun["OK"]] <> " \:30d0\:30c3\:30c1" <>
      If[$iSWRefineRun["NG"] > 0, " (\:5931\:6557 " <> ToString[$iSWRefineRun["NG"]] <> ": " <> StringRiffle[Flatten[$iSWRefineRun["Failed"]], ", "] <> ")", ""] <>
      "\:3001\:6e08 " <> ToString[done] <> "/" <> ToString[total] <> " \:7bc0\:3002" <>
        If[MatchQ[thenNote, {_String, _String}], thenNote[[1]], "\:6b21\:306f\:300c\:5468\:8fba\:77e5\:8b58\:300d\:307e\:305f\:306f\:300c\:8a08\:753b\:300d"],
    "KG refinement done: " <> ToString[$iSWRefineRun["OK"]] <> " batches" <>
      If[$iSWRefineRun["NG"] > 0, " (" <> ToString[$iSWRefineRun["NG"]] <> " failed: " <> StringRiffle[Flatten[$iSWRefineRun["Failed"]], ", "] <> ")", ""] <>
      ", " <> ToString[done] <> "/" <> ToString[total] <> " sections refined. " <>
        If[MatchQ[thenNote, {_String, _String}], thenNote[[2]], "Next: background or plan"]];
  If[visual,
    msg = iSL["KG \:56f3\:89e3 \:5b8c\:4e86: " <> ToString[$iSWRefineRun["OK"]] <> " \:30d0\:30c3\:30c1" <>
        If[$iSWRefineRun["NG"] > 0, " (\:5931\:6557 " <> ToString[$iSWRefineRun["NG"]] <> ")", ""] <>
        "\:3001\:56f3 " <> ToString[Lookup[$iSWRefineRun, "Figures", 0]] <> " / \:8868 " <> ToString[Lookup[$iSWRefineRun, "Tables", 0]] <>
        " / \:4e0d\:8981 " <> ToString[Lookup[$iSWRefineRun, "NoVisual", 0]] <> " / \:5374\:4e0b " <> ToString[Lookup[$iSWRefineRun, "Rejected", 0]] <>
        "\:3002\:6b21\:306f\:300c\:8a08\:753b\:300d\:300c\:751f\:6210\:300d",
      "KG visuals done: " <> ToString[$iSWRefineRun["OK"]] <> " batches, figures " <> ToString[Lookup[$iSWRefineRun, "Figures", 0]] <>
        " / tables " <> ToString[Lookup[$iSWRefineRun, "Tables", 0]] <> " / none " <> ToString[Lookup[$iSWRefineRun, "NoVisual", 0]] <>
        " / rejected " <> ToString[Lookup[$iSWRefineRun, "Rejected", 0]]]];
  iSWStatusIf[nb, msg];
  If[Head[nb] === NotebookObject,
    Quiet @ Check[iSWEnsureEndMarkerAtEnd[nb]; SelectionMove[nb, After, Notebook];
      NotebookWrite[nb, Cell[msg, "Text"]], Null];
    iSWStatusClearLater[nb]];
  If[then =!= None, Quiet[then[]]];
  <|"Status" -> "Done", "OK" -> $iSWRefineRun["OK"], "NG" -> $iSWRefineRun["NG"], "Done" -> done, "Sections" -> total,
    "Figures" -> Lookup[$iSWRefineRun, "Figures", 0], "Tables" -> Lookup[$iSWRefineRun, "Tables", 0],
    "NoVisual" -> Lookup[$iSWRefineRun, "NoVisual", 0], "Rejected" -> Lookup[$iSWRefineRun, "Rejected", 0]|>];

Options[SlideGraphRefine] = {"Mode" -> Automatic, "Sections" -> All, "BatchNodes" -> 8, "Audience" -> Automatic, "Story" -> Automatic,
  "Overview" -> Automatic, "PDF" -> Automatic, "Refine" -> Automatic};
$iSWThenVisualNote := {"\:7d9a\:3051\:3066\:56f3\:89e3\:3057\:307e\:3059", "continuing with the visual pass"};
$iSWThenFinishNote := {"\:7d9a\:3051\:3066\:4ed5\:4e0a\:3052\:307e\:3059", "continuing with the finishing pass"};
$iSWThenAdjustNote := {"\:7d9a\:3051\:3066\:8abf\:6574\:3057\:307e\:3059", "continuing with the adjustment"};
SlideGraphRefine[opts : OptionsPattern[]] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideGraphRefine[nb, opts]]];
SlideGraphRefine[nb_NotebookObject, OptionsPattern[]] := Module[{spec, kg, un},
  If[iSWRefineBusyQ[],
    iSWStatusIf[nb, iSL["KG \:306e\:63a8\:6572\:30fb\:56f3\:89e3\:3092\:5b9f\:884c\:4e2d\:3067\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044", "A KG refinement run is already in progress"]];
    Return[<|"Status" -> "Busy"|>]];
  spec = SlideGraphSpec[nb];
  kg = iSWKGResolve[spec["Graph"]];
  If[! AssociationQ[kg], iSWStatus[nb, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; Return[kg]];
  Which[
    OptionValue["Mode"] === "Agent",
      If[! iSWAgentAvailableQ[], Return[iSWNoAgentFailure[]]];
      iSWGraphDelegate[nb, iSWGraphRefineTask[spec, kg, iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb]],
        "KG \:306e\:63a8\:6572 (\:7bc0\:3054\:3068) \:3092\:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:306b\:59d4\:8b72", "Delegated section-wise KG refinement to agent"];
      Success["Delegated", <|"GraphId" -> spec["Graph"], "Sections" -> Count[kg["Nodes"], n_ /; n["Kind"] === "Section"]|>],
    OptionValue["Mode"] === "Visual",
      (* \:63a8\:6572\:304c\:9014\:4e2d\:3067\:6b62\:307e\:3063\:305f\:7bc0\:304c\:3042\:308c\:3070\:3001\:5148\:306b\:305d\:306e\:7bc0\:3092\:63a8\:6572\:3059\:308b (\:56f3\:89e3\:306f\:8981\:70b9\:306e\:3042\:308b\:30ce\:30fc\:30c9\:306b\:3057\:304b\:4ed8\:304b\:306a\:3044) *)
      If[OptionValue["Refine"] =!= False && (un = iSWUnrefinedSections[kg]) =!= {},
        Return[With[{bn = OptionValue["BatchNodes"], sel = OptionValue["Sections"], ov = OptionValue["Overview"]},
          iSWRefineFirst[nb, spec, kg, un, bn,
            Function[SlideGraphRefine[nb, "Mode" -> "Visual", "Refine" -> False, "Overview" -> ov,
              "BatchNodes" -> bn, "Sections" -> sel]], $iSWThenVisualNote]]]];
      (* \:8ad6\:6587 1 \:30da\:30fc\:30b8\:76ee\:306e\:56f3 (\:30b7\:30b9\:30c6\:30e0\:306e\:5168\:4f53\:50cf) \:304c\:307e\:3060\:3069\:306e\:30ce\:30fc\:30c9\:306b\:3082\:7121\:3051\:308c\:3070\:3001\:5148\:306b\:305d\:306e\:679a\:3092\:8db3\:3057\:3066\:304b\:3089\:56f3\:89e3\:3059\:308b *)
      If[OptionValue["Overview"] =!= False && iSWOverviewNeededQ[nb, kg],
        Return[With[{bn = OptionValue["BatchNodes"], sel = OptionValue["Sections"]},
          SlideGraphAdjust[nb, $iSWOverviewInstruction, "Refine" -> False,
            "Then" -> Function[SlideGraphRefine[nb, "Mode" -> "Visual", "Overview" -> False, "Refine" -> False,
              "BatchNodes" -> bn, "Sections" -> sel]]]]]];
      $iSWRefineTalkOnly = True; $iSWRefineVisual = True;
      iSWRefineStart[nb, spec, kg, OptionValue["BatchNodes"], OptionValue["Sections"]],
    MemberQ[{"Talk", "Detail", "Enrich"}, OptionValue["Mode"]],
      If[OptionValue["Refine"] =!= False && (un = iSWUnrefinedSections[kg]) =!= {},
        Return[With[{m = OptionValue["Mode"], bn = OptionValue["BatchNodes"], sel = OptionValue["Sections"]},
          iSWRefineFirst[nb, spec, kg, un, bn,
            Function[SlideGraphRefine[nb, "Mode" -> m, "Refine" -> False, "BatchNodes" -> bn, "Sections" -> sel]],
            $iSWThenFinishNote]]]];
      $iSWRefineTalkOnly = True; $iSWRefineVisual = False; $iSWRefineEnrichAll = OptionValue["Mode"] =!= "Talk";
      iSWRefineStart[nb, spec, kg, OptionValue["BatchNodes"], OptionValue["Sections"]],
    True,
      $iSWRefineTalkOnly = False; $iSWRefineVisual = False;
      iSWRefineStart[nb, spec, kg, OptionValue["BatchNodes"], OptionValue["Sections"]]]];
(* ===================== \:8abf\:6574 (v1.28): \:751f\:6210\:3057\:305f\:3042\:3068\:3067\:3001\:6307\:793a\:3092\:66f8\:3044\:3066 KG \:3092\:76f4\:3059 =====================
   \:30b9\:30e9\:30a4\:30c9\:306f KG \:304b\:3089\:6c7a\:5b9a\:7684\:306b\:4f5c\:308a\:76f4\:3059\:306e\:3067\:3001\:76f4\:3059\:306e\:306f KG (\:30ce\:30fc\:30c9\:306e\:8ffd\:52a0\:30fb\:6587\:306e\:4fee\:6b63\:30fb\:96a0\:3059\:30fb\:56f3\:306e\:6307\:5b9a)\:3002
   LLM \:306f\:5dee\:5206 JSON \:3092\:8fd4\:3057\:3001\:3053\:3053\:3067\:691c\:67fb\:3057\:3066\:304b\:3089 Merge \:3059\:308b\:3002\:53cd\:6620\:5f8c\:306b\:300c\:751f\:6210\:300d\:3067\:4f5c\:308a\:76f4\:3059 *)
$iSWQ = "\"";
$iSWAdjustCellOpts = {
  CellFrame -> {{2, 0}, {0, 0}}, CellFrameColor -> RGBColor[0.3, 0.45, 0.75],
  Background -> RGBColor[0.93, 0.95, 0.99], FontSize -> 11,
  FontColor -> GrayLevel[0.25], CellMargins -> {{66, 20}, {4, 4}},
  CellDingbat -> StyleBox["\[FilledSmallSquare]", FontColor -> RGBColor[0.3, 0.45, 0.75]]};
$iSWAdjustHintJa = "\:3053\:3053\:306b\:76f4\:3057\:305f\:3044\:3053\:3068\:3092\:66f8\:3044\:3066\:3001\:3082\:3046\:4e00\:5ea6\:300c\:8abf\:6574\:300d\:3092\:62bc\:3059 (\:4f8b: \:8ad6\:6587\:306e\:6700\:521d\:306e\:30da\:30fc\:30b8\:306e\:56f3\:3092\:8aac\:660e\:3059\:308b\:30b9\:30e9\:30a4\:30c9\:3092\:3001\:7d50\:8ad6\:306e\:679a\:306e\:5f8c\:306b\:5165\:308c\:308b)";
$iSWAdjustHintEn = "Write what to change here, then press Adjust again (e.g. add a slide explaining the first-page figure after the conclusion)";
iSWAdjustText[raw_String] := Module[{s = StringTrim[raw]},
  s = StringTrim[StringReplace[s, StartOfString ~~ ("\:8abf\:6574" | "Adjust") ~~ (":" | "\:ff1a") -> ""]];
  If[StringStartsQ[s, StringTake[$iSWAdjustHintJa, 12]] || StringStartsQ[s, StringTake[$iSWAdjustHintEn, 20]], "", s]];
iSWAdjustText[_] := "";

SlideInsertAdjust[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideInsertAdjust[nb]]];
SlideInsertAdjust[nb_NotebookObject] := Module[{story = Quiet[Cells[nb, CellStyle -> "SlideStory"]]},
  (* \:30b9\:30c8\:30fc\:30ea\:30fc\:30bb\:30eb\:304c\:3042\:308c\:3070\:305d\:306e\:5f8c\:308d (\:524d\:7f6e\:304d) \:306b\:7f6e\:304f *)
  If[ListQ[story] && story =!= {}, SelectionMove[Last[story], After, Cell]];
  iSWInsertMeta[nb, "", "SlideAdjust", iSL[$iSWAdjustHintJa, $iSWAdjustHintEn], $iSWAdjustCellOpts]];

(* \:672a\:9069\:7528\:306e\:8abf\:6574\:30bb\:30eb (\:6587\:66f8\:306e\:9806\:3067\:6700\:521d\:306e\:3082\:306e) *)
iSWAdjustPendingCell[nb_NotebookObject] := Module[{cells = Quiet[Cells[nb, CellStyle -> "SlideAdjust"]]},
  If[! ListQ[cells], Return[None]];
  SelectFirst[cells, With[{c = Quiet[NotebookRead[#]]}, Head[c] === Cell && FreeQ[c, "SWAdjustApplied"]] &, None]];
iSWAdjustMarkApplied[co_CellObject, summary_String] := Quiet[
  SetOptions[co, TaggingRules -> {"SWAdjustApplied" -> DateString["ISODateTime"], "SWAdjustSummary" -> summary},
    CellFrameColor -> GrayLevel[0.7], Background -> GrayLevel[0.96],
    CellDingbat -> StyleBox["\[Checkmark]", FontColor -> GrayLevel[0.5]]]];
iSWAdjustMarkApplied[___] := Null;

(* \:8ad6\:6587 PDF \:306e locator: \:6587\:732e\:6b04 \:2192 KG \:306e\:51fa\:5178 \:306e\:9806\:306b\:3001PDF \:306b\:89e3\:6c7a\:3067\:304d\:308b\:3082\:306e *)
iSWAdjustPDFRef[nb_, kg_, opt_ : Automatic] := Module[{cands = {}},
  If[StringQ[opt], Return[opt]];
  If[Head[nb] === NotebookObject,
    cands = Join[cands, Lookup[Select[Replace[Quiet[iSWReferencesList[nb]], Except[_List] -> {}], AssociationQ], "Locator", Nothing]]];
  If[AssociationQ[kg],
    With[{srcs = Select[Replace[Lookup[kg, "Sources", {}], Except[_List] -> {}], AssociationQ]},
      cands = Join[cands, Lookup[srcs, "Reference", Nothing], Lookup[srcs, "Locator", Nothing]]]];
  SelectFirst[DeleteDuplicates[Select[cands, StringQ]],
    With[{p = Quiet[iSWResolveRefPath[#]]}, StringQ[p] && StringEndsQ[p, ".pdf", IgnoreCase -> True] && FileExistsQ[p]] &, None]];
iSWAdjustKey[kg_Association] := FirstCase[Replace[Lookup[kg, "Sources", {}], Except[_List] -> {}],
  s_Association /; StringQ[Lookup[s, "Key", None]] :> s["Key"], Lookup[kg, "GraphId", ""]];

(* 1 \:30da\:30fc\:30b8\:76ee\:306e\:56f3 (\:5168\:4f53\:50cf) \:3092\:4f7f\:3063\:3066\:3044\:308b\:30ce\:30fc\:30c9\:304c\:3042\:308b\:304b / \:8db3\:3059\:3079\:304d\:304b *)
iSWOverviewUsedQ[kg_Association] := AnyTrue[
  Flatten[Replace[Lookup[kg["Nodes"], "Assets", {}], Except[_List] -> {}, {1}]],
  AssociationQ[#] && Lookup[#, "Type", ""] === "PDFImage" && Lookup[#, "Page", 0] === 1 &];
iSWOverviewNeededQ[nb_, kg_, opt_ : Automatic] := AssociationQ[kg] && ! iSWOverviewUsedQ[kg] &&
  With[{ref = iSWAdjustPDFRef[nb, kg, opt]},
    StringQ[ref] && With[{l = SlidePDFImages[ref, "Page" -> 1, "MinSize" -> 150]}, ListQ[l] && l =!= {}]];
$iSWOverviewInstruction := iSL[
  "\:8ad6\:6587\:306e 1 \:30da\:30fc\:30b8\:76ee\:306b\:3042\:308b\:56f3 (PDFImage \:306e Page 1, N 1\:3002\:30b7\:30b9\:30c6\:30e0\:5168\:4f53\:306e\:4ed5\:7d44\:307f\:3092 1 \:679a\:3067\:793a\:3059\:3001\:8ad6\:6587\:3067\:3044\:3061\:3070\:3093\:5927\:4e8b\:306a\:56f3) \:3092\:8aac\:660e\:3059\:308b\:30b9\:30e9\:30a4\:30c9\:3092 1 \:679a\:8ffd\:52a0\:3059\:308b\:3002" <>
  "\:4f4d\:7f6e\:306f\:7d50\:8ad6\:30fb\:8981\:70b9\:306e\:679a\:306e\:76f4\:5f8c\:3067\:3001\:5e8f\:8ad6\:3088\:308a\:524d\:3002\:56f3\:306e\:4e2d\:306e\:8981\:7d20\:3068\:305d\:306e\:3064\:306a\:304c\:308a (\:4f55\:3092\:4f55\:306b\:5909\:63db\:3057\:3001\:3069\:3053\:3078\:623b\:3059\:304b) \:3092\:3001KG \:306e\:672c\:6587\:306b\:3042\:308b\:8a00\:8449\:3067\:8981\:70b9\:306b\:3059\:308b\:3002Importance \:306f 0.95\:3002",
  "Add one slide that explains the figure on the first page of the paper (PDFImage Page 1, N 1: the overview of the whole system, " <>
  "the most important figure). Place it right after the conclusion / highlights slide, before the introduction. " <>
  "Make the points describe the parts of the figure and how they connect, in the words of the KG text. Importance 0.95."];

iSWAdjustPDFInfo[kg_Association, ref_] := Module[{p1},
  If[! StringQ[ref], Return["- \:8ad6\:6587 PDF: \:898b\:3064\:304b\:3089\:306a\:3044 (PDFImage \:306f\:4f7f\:3048\:306a\:3044)"]];
  p1 = SlidePDFImages[ref, "Page" -> 1, "MinSize" -> 150];
  "- \:8ad6\:6587 PDF \:306e\:57cb\:3081\:8fbc\:307f\:753b\:50cf: " <>
    If[ListQ[p1] && p1 =!= {},
      "1 \:30da\:30fc\:30b8\:76ee\:306b " <> ToString[Length[p1]] <> " \:679a (\:8ad6\:6587\:306e\:6700\:521d\:306e\:56f3\:3002\:30b7\:30b9\:30c6\:30e0\:306e\:5168\:4f53\:50cf\:3092\:793a\:3059\:3053\:3068\:304c\:591a\:3044)" <>
        If[iSWOverviewUsedQ[kg], "\:3002\:3059\:3067\:306b\:4f7f\:308f\:308c\:3066\:3044\:308b", "\:3002\:307e\:3060\:3069\:306e\:30b9\:30e9\:30a4\:30c9\:306b\:3082\:7121\:3044"],
      "1 \:30da\:30fc\:30b8\:76ee\:306b\:306f\:7121\:3044"] <>
    "\:3002{" <> $iSWQ <> "Type" <> $iSWQ <> ": " <> $iSWQ <> "PDFImage" <> $iSWQ <> ", " <> $iSWQ <> "Page" <> $iSWQ <> ": 1, " <> $iSWQ <> "N" <> $iSWQ <> ": 1} \:306e\:3088\:3046\:306b\:6307\:3059\:3002" <>
    "\:307b\:304b\:306e\:30da\:30fc\:30b8\:3082 Page \:3067\:6307\:305b\:308b\:304c\:3001\:8ad6\:6587\:306e\:56f3\:306f fig* \:30ce\:30fc\:30c9 ({" <> $iSWQ <> "Type" <> $iSWQ <> ": " <> $iSWQ <> "Figure" <> $iSWQ <> ", " <> $iSWQ <> "Of" <> $iSWQ <> ": " <> $iSWQ <> "fig3" <> $iSWQ <> "}) \:3092\:4f7f\:3046"];

iSWAdjustAssetTag[n_Association] := With[{as = Select[Replace[Lookup[n, "Assets", {}], Except[_List] -> {}], AssociationQ]},
  If[as === {}, "", " | \:56f3: " <> StringRiffle[DeleteDuplicates[Lookup[as, "Type", ""]], ","]]];

(* \:6307\:793a\:306b\:51fa\:3066\:304f\:308b\:30b9\:30e9\:30a4\:30c9\:756a\:53f7 (\:300c43 \:4ee5\:964d\:300d\:300c17 \:679a\:76ee\:300d\:300c\:30b9\:30e9\:30a4\:30c9 5\:300d\:300c20\:301c24\:300d) *)
iSWAdjustSlideRefs[instruction_String, n_Integer] := Module[{s, d = DigitCharacter .., ws = WhitespaceCharacter ..., refs},
  If[n < 1, Return[{}]];
  s = StringReplace[instruction, Thread[CharacterRange["\:ff10", "\:ff19"] -> CharacterRange["0", "9"]]];
  refs = Join[
    StringCases[s, a : d ~~ ws ~~ Repeated["\:679a\:76ee" | "\:756a\:76ee" | "\:30da\:30fc\:30b8\:76ee", {0, 1}] ~~ ws ~~ ("\:4ee5\:964d" | "\:4ee5\:5f8c" | "\:304b\:3089\:6700\:5f8c" | "\:304b\:3089\:5f8c") :>
      Range[FromDigits[a], n]],
    StringCases[s, a : d ~~ ws ~~ Repeated["\:679a\:76ee" | "\:756a\:76ee", {0, 1}] ~~ ws ~~ ("\:301c" | "\:ff5e" | "~" | "-" | "\:2013" | "\:304b\:3089") ~~ ws ~~ b : d :>
      If[FromDigits[a] <= FromDigits[b] <= FromDigits[a] + 40, Range[FromDigits[a], FromDigits[b]], {}]],
    StringCases[s, ("\:30b9\:30e9\:30a4\:30c9" | "Slide" | "slide" | "#") ~~ ws ~~ a : d :> {FromDigits[a]}],
    StringCases[s, a : d ~~ ws ~~ ("\:679a\:76ee" | "\:756a\:76ee") :> {FromDigits[a]}]];
  Take[Select[DeleteDuplicates[Flatten[refs]], IntegerQ[#] && 1 <= # <= n &], UpTo[15]]];
iSWAdjustSlideRefs[_, _] := {};

iSWAdjustNodeDetail[n_Association] := Module[{pts = SourceVault`SourceVaultKGText[n, "Points"],
    lead = SourceVault`SourceVaultKGText[n, "Lead"], text = Replace[Lookup[n, "Text", ""], Except[_String] -> ""]},
  "  [" <> n["Id"] <> "] " <> SourceVault`SourceVaultKGText[n, "Label"] <>
    If[StringQ[lead] && lead =!= "", "\n    \:5c0e\:5165\:6587: " <> lead, ""] <>
    If[MatchQ[pts, {__String}], "\n    \:8981\:70b9: " <> StringRiffle[pts, " / "], "\n    \:8981\:70b9: (\:7121\:3044\:3002\:63a8\:6572\:3055\:308c\:3066\:3044\:306a\:3044\:6bb5\:843d)"] <>
    If[text =!= "", "\n    \:5143\:306e\:672c\:6587: " <> StringTake[StringReplace[text, "\n" -> " "], UpTo[600]], ""]];
iSWAdjustSlideDetail[index_Association, slides_List, k_Integer, label_Integer] := Module[{sl = slides[[k]], subs, ids},
  subs = Replace[Lookup[sl, "Sub", {}], Except[_List] -> {}];
  ids = Select[DeleteDuplicates[Join[{Lookup[sl, "NodeId", ""]}, Cases[subs, a_Association :> Lookup[a, "NodeId", ""]]]],
    StringQ[#] && KeyExistsQ[index, #] &];
  "\:30b9\:30e9\:30a4\:30c9 " <> ToString[label] <> ": " <> ToString[Lookup[sl, "Title", ""]] <> "\n" <>
    StringRiffle[Map[iSWAdjustNodeDetail[index[#]] &, ids], "\n"]];

(* \:30c7\:30c3\:30ad\:306e\:679a\:756a\:53f7 = \:8a08\:753b\:306e\:756a\:53f7 + \:5148\:982d\:306e\:679a (\:30bf\:30a4\:30c8\:30eb\:306a\:3069 KG \:304b\:3089\:4f5c\:3063\:3066\:3044\:306a\:3044\:679a)\:3002\:8a08\:753b\:306e\:6700\:521d\:306e\:679a\:306e\:984c\:76ee\:3092\:30c7\:30c3\:30ad\:3067\:63a2\:3059 *)
iSWAdjustDeckOffset[nb_NotebookObject, slides_List] := Module[{titles = Quiet[iSWSlideTitles[nb]], norm, t1, pos},
  If[! ListQ[titles] || slides === {}, Return[0]];
  norm[s_] := StringDelete[ToString[s], WhitespaceCharacter | "(\:7d9a\:304d)" | "\:ff08\:7d9a\:304d\:ff09" | "**"];
  t1 = norm[Lookup[First[slides], "Title", ""]];
  If[t1 === "", Return[0]];
  pos = FirstPosition[norm /@ titles, t1, {0}][[1]];
  Max[0, pos - 1]];
iSWAdjustDeckOffset[___] := 0;

iSWAdjustPrompt[spec_Association, kg_Association, slides_List, instruction_String, pdfInfo_String, metaBlocks_String,
    offset_Integer : 0] := Module[
  {nodes, secs = iSWKGSectionIdSet[kg], slideTxt, nodeTxt, figTxt, index = Association[(#["Id"] -> #) & /@ kg["Nodes"]], refs, detailTxt},
  nodes = SortBy[kg["Nodes"], {Replace[Lookup[#, "Order", None], Except[_?NumericQ] -> 10^6], #["Id"]} &];
  slideTxt = StringRiffle[MapIndexed[ToString[First[#2] + offset] <> ". " <> ToString[Lookup[#1, "Title", ""]] <>
    " [" <> ToString[Lookup[#1, "NodeId", ""]] <> "]" &, slides], "\n"];
  nodeTxt = StringRiffle[Map[Function[n,
    n["Id"] <> " | " <> SourceVault`SourceVaultKGText[n, "Label"] <>
      If[MemberQ[secs, n["Id"]] || n["Id"] === Lookup[kg, "Root", "root"],
        " | \:7bc0: " <> StringTake[SourceVault`SourceVaultKGText[n, "Summary"], UpTo[80]], ""] <>
      If[! MemberQ[secs, n["Id"]] && n["Id"] =!= Lookup[kg, "Root", "root"] && Lookup[n, "Layer", ""] === "Paper" &&
        ! MatchQ[SourceVault`SourceVaultKGText[n, "Points"], {__String}], " | \:8981\:70b9\:306a\:3057", ""] <>
      If[TrueQ[Lookup[n, "Hidden", False]], " | \:96a0\:3059", ""] <> iSWAdjustAssetTag[n]], nodes], "\n"];
  refs = Select[iSWAdjustSlideRefs[instruction, Length[slides] + offset], # > offset &];
  detailTxt = If[refs === {}, "",
    "=== \:6307\:793a\:306b\:51fa\:3066\:304d\:305f\:30b9\:30e9\:30a4\:30c9\:306e\:4e2d\:8eab (\:30ce\:30fc\:30c9\:3054\:3068\:306e\:984c\:76ee\:30fb\:5c0e\:5165\:6587\:30fb\:8981\:70b9\:30fb\:5143\:306e\:672c\:6587) ===\n" <>
      StringTake[StringRiffle[Map[iSWAdjustSlideDetail[index, slides, # - offset, #] &, refs], "\n"], UpTo[24000]] <> "\n\n"];
  figTxt = StringRiffle[Map[#["Id"] <> " (" <> SourceVault`SourceVaultKGText[#, "Label"] <> ")" &,
    Select[nodes, iSWFigNodeQ]], ", "];
  metaBlocks <>
  "SlideWorkflow \:306e\:30b9\:30e9\:30a4\:30c9\:8abf\:6574\:3002\:767a\:8868\:30b9\:30e9\:30a4\:30c9\:306f\:77e5\:8b58\:30b0\:30e9\:30d5 (KG) \:304b\:3089\:6c7a\:5b9a\:7684\:306b\:4f5c\:308a\:76f4\:3059\:306e\:3067\:3001\:30b9\:30e9\:30a4\:30c9\:3067\:306f\:306a\:304f KG \:3092\:5dee\:5206\:3067\:76f4\:3059\:3002" <>
  "\:5229\:7528\:8005\:306e\:6307\:793a\:306b\:5f93\:3044\:3001\:4e0b\:306e\:5f62\:306e JSON \:3092\:8fd4\:3059\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <>
  If[StringQ[Lookup[spec, "Story", None]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "=== \:5229\:7528\:8005\:306e\:6307\:793a ===\n" <> instruction <> "\n\n" <>
  "=== \:3044\:307e\:306e\:30b9\:30e9\:30a4\:30c9\:69cb\:6210 (\:756a\:53f7. \:984c\:76ee [\:30ce\:30fc\:30c9 Id]) ===\n" <>
    If[offset > 0, "(\:756a\:53f7\:306f\:30c7\:30c3\:30ad\:306e\:679a\:756a\:53f7\:3002\:5148\:982d\:306e " <> ToString[offset] <> " \:679a (\:30bf\:30a4\:30c8\:30eb\:306a\:3069) \:306f KG \:304b\:3089\:4f5c\:3063\:3066\:3044\:306a\:3044)\n", ""] <>
    slideTxt <> "\n\n" <> detailTxt <>
  "=== KG \:306e\:30ce\:30fc\:30c9 (\:51fa\:73fe\:9806\:3002Id | \:984c\:76ee | \:7bc0\:306e\:8981\:7d04 | \:56f3) ===\n" <> nodeTxt <> "\n\n" <>
  "=== \:4f7f\:3048\:308b\:56f3 ===\n" <>
  "- \:8ad6\:6587\:306e\:56f3\:306e\:30ce\:30fc\:30c9: " <> figTxt <> "\n" <> pdfInfo <> "\n" <>
  "- \:8868: {" <> $iSWQ <> "Type" <> $iSWQ <> ": " <> $iSWQ <> "Table" <> $iSWQ <> ", " <> $iSWQ <> "Rows" <> $iSWQ <> ": [[" <> $iSWQ <> "\:898b\:51fa\:3057" <> $iSWQ <> ", " <> $iSWQ <> "\:898b\:51fa\:3057" <> $iSWQ <> "], [..]]}\n" <>
  "- \:6982\:5ff5\:56f3 (Wolfram Language \:306e\:4f5c\:56f3\:30b3\:30fc\:30c9\:3002\:4f5c\:56f3\:3068\:6570\:5b66\:306e\:7d44\:8fbc\:307f\:95a2\:6570\:3060\:3051\:3002Import \:3084\:30d5\:30a1\:30a4\:30eb\:64cd\:4f5c\:306f\:4e0d\:53ef): {" <>
    $iSWQ <> "Type" <> $iSWQ <> ": " <> $iSWQ <> "Code" <> $iSWQ <> ", " <> $iSWQ <> "Code" <> $iSWQ <> ": " <> $iSWQ <> "Graphics[...]" <> $iSWQ <> ", " <>
    $iSWQ <> "Caption" <> $iSWQ <> ": " <> $iSWQ <> "\:6982\:5ff5\:56f3: ..." <> $iSWQ <> "}\n\n" <>
  "=== \:51fa\:529b (\:53b3\:5b88): JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3002\:8aac\:660e\:6587\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:7121\:3057 ===\n" <>
  "{" <> $iSWQ <> "Nodes" <> $iSWQ <> ": [{" <> $iSWQ <> "Id" <> $iSWQ <> ": " <> $iSWQ <> "adj_..." <> $iSWQ <> ", " <>
    $iSWQ <> "After" <> $iSWQ <> ": " <> $iSWQ <> "<\:3053\:306e\:5f8c\:308d\:306b\:7f6e\:304f\:65e2\:5b58\:30ce\:30fc\:30c9 Id>" <> $iSWQ <> ", " <>
    $iSWQ <> "Parent" <> $iSWQ <> ": " <> $iSWQ <> "<\:5165\:308c\:308b\:7bc0\:306e Id (\:7701\:7565\:53ef)>" <> $iSWQ <> ", " <>
    $iSWQ <> "Label" <> $iSWQ <> ": " <> $iSWQ <> "\:984c\:76ee" <> $iSWQ <> ", " <> $iSWQ <> "Lead" <> $iSWQ <> ": " <> $iSWQ <> "\:5c0e\:5165\:6587" <> $iSWQ <> ", " <>
    $iSWQ <> "Points" <> $iSWQ <> ": [" <> $iSWQ <> "\:8981\:70b9" <> $iSWQ <> "], " <> $iSWQ <> "Details" <> $iSWQ <> ": [" <> $iSWQ <> "\:88dc\:8db3" <> $iSWQ <> "], " <>
    $iSWQ <> "Talk" <> $iSWQ <> ": " <> $iSWQ <> "\:539f\:7a3f" <> $iSWQ <> ", " <> $iSWQ <> "Importance" <> $iSWQ <> ": 0.9, " <>
    $iSWQ <> "Assets" <> $iSWQ <> ": [..]}], " <> $iSWQ <> "Hide" <> $iSWQ <> ": [" <> $iSWQ <> "<\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:5916\:3059\:30ce\:30fc\:30c9 Id>" <> $iSWQ <> "]}\n\n" <>
  "\:898f\:5247:\n" <>
  "- \:65b0\:3057\:3044\:30b9\:30e9\:30a4\:30c9\:306f\:65b0\:3057\:3044\:30ce\:30fc\:30c9\:306b\:3059\:308b (Id \:306f adj_ \:3067\:59cb\:3081\:308b)\:3002After \:3067\:4f4d\:7f6e\:3092\:6c7a\:3081\:3001Label \:3068 Points \:306f\:5fc5\:305a\:66f8\:304f\:3002\n" <>
  "- \:65e2\:5b58\:306e\:30b9\:30e9\:30a4\:30c9\:3092\:76f4\:3059\:3068\:304d\:306f\:3001\:305d\:306e Id \:306b\:5909\:3048\:305f\:3044\:30ad\:30fc\:3060\:3051\:3092\:66f8\:304f (Label / Lead / Points / Details / Talk / Importance / Assets / After)\:3002\n" <>
  "- \:30b9\:30e9\:30a4\:30c9\:304b\:3089\:5916\:3059\:3068\:304d\:306f Hide \:306b Id \:3092\:5165\:308c\:308b (KG \:304b\:3089\:306f\:6d88\:3055\:306a\:3044)\:3002\:623b\:3059\:3068\:304d\:306f {" <> $iSWQ <> "Id" <> $iSWQ <> ": .., " <> $iSWQ <> "Hidden" <> $iSWQ <> ": false}\:3002\n" <>
  "- Importance \:306f\:30b9\:30e9\:30a4\:30c9\:306b\:9078\:3070\:308c\:308b\:5f37\:3055 (0\:301c1)\:3002\:5fc5\:305a\:51fa\:3057\:305f\:3044\:679a\:306f 0.9 \:4ee5\:4e0a\:3002\n" <>
  "- \:6587: Lead \:306f 1 \:6587 40 \:5b57\:4ee5\:5185\:3001Points \:306f\:4f53\:8a00\:6b62\:3081 2\:301c5 \:500b\:3001Details \:306f Points \:3068\:540c\:3058\:9577\:3055 (\:4e0d\:8981\:306a\:3089 " <> $iSWQ <> $iSWQ <> ")\:3002" <>
  "Talk \:306f\:8aad\:307f\:4e0a\:3052\:539f\:7a3f\:306a\:306e\:3067 $...$ \:3092\:66f8\:304b\:305a\:3001\:753b\:9762\:306e\:56f3\:3084\:5f0f\:3092\:6307\:3057\:3066\:8a9e\:308b\:3002\:56f3\:8868\:756a\:53f7 (\:56f32 \:306a\:3069) \:306f\:305d\:306e\:679a\:306b\:3042\:308b\:56f3\:3060\:3051\:3002KG \:306b\:7121\:3044\:4e8b\:5b9f\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:65e2\:5b58\:306e\:679a\:306e\:7b87\:6761\:66f8\:304d\:3092\:76f4\:3059\:3068\:304d\:306f\:3001\:305d\:306e\:30ce\:30fc\:30c9\:306e\:5143\:306e\:672c\:6587\:304b\:3089\:8981\:70b9 (Points) \:3068\:5c0e\:5165\:6587 (Lead) \:3092\:4f5c\:308a\:76f4\:3059\:3002\:300c\:2026\:300d\:3067\:5207\:308c\:305f\:7b87\:6761\:66f8\:304d\:306f\:63a8\:6572\:3055\:308c\:3066\:3044\:306a\:3044\:6bb5\:843d\:306e\:66f8\:304d\:51fa\:3057\:3002\n" <>
  "- \:6307\:793a\:306b\:95a2\:4fc2\:3057\:306a\:3044\:30ce\:30fc\:30c9\:306f\:8fd4\:3055\:306a\:3044\:3002"];

(* \:65b0\:3057\:3044\:30ce\:30fc\:30c9\:306e Order: After \:306e\:76f4\:5f8c (\:6b21\:306e\:30ce\:30fc\:30c9\:3068\:306e\:4e2d\:70b9) *)
iSWAdjustOrderAfter[orders_Association, a_String] := Module[{oa = Lookup[orders, a, None], later},
  If[! NumericQ[oa], Return[None]];
  later = Select[Values[orders], NumericQ[#] && # > oa &];
  If[later === {}, oa + 1., (oa + Min[later])/2.]];

iSWAdjustAsset[spec_, index_Association, pdfRef_] := Module[{type},
  If[! AssociationQ[spec], Return[$Failed]];
  type = ToString[Lookup[spec, "Type", ""]];
  Switch[type,
    "PDFImage", With[{p = Lookup[spec, "Page", 1], k = Lookup[spec, "N", 1]},
      If[StringQ[pdfRef] && IntegerQ[p] && IntegerQ[k] && p >= 1 && k >= 1 &&
          With[{l = SlidePDFImages[pdfRef, "Page" -> p, "MinSize" -> 0]}, ListQ[l] && Length[l] >= k],
        <|"Type" -> "PDFImage", "Ref" -> pdfRef, "Page" -> p, "N" -> k|>, $Failed]],
    "Figure", With[{of = Lookup[spec, "Of", ""]},
      If[StringQ[of] && KeyExistsQ[index, of] && MatchQ[Lookup[index[of], "Assets", {}], {__Association}],
        First[index[of]["Assets"]], $Failed]],
    "Table" | "Code", Replace[iSWVisualAssetOf[spec], None -> $Failed],
    _, $Failed]];

(* LLM \:306e\:5dee\:5206\:3092\:691c\:67fb\:3057\:3066 Merge \:7528\:306e\:5dee\:5206\:306b\:3059\:308b *)
iSWAdjustDelta[kg_Association, raw_Association, pdfRef_, key_String] := Module[
  {index = Association[(#["Id"] -> #) & /@ kg["Nodes"]], orders, parent, secs, rootId = Lookup[kg, "Root", "root"],
   nodes = {}, edges = {}, added = {}, changed = {}, hidden = {}, warn = {}, newIds = {}},
  orders = Association[Map[#["Id"] -> Lookup[#, "Order", None] &, kg["Nodes"]]];
  parent = Association[Map[#["To"] -> #["From"] &, Reverse[Select[kg["Edges"], #["EdgeKind"] === "Contains" &]]]];
  secs = iSWKGSectionIdSet[kg];
  Do[
    Module[{id, isNew, m, after, par, specs, assets},
      id = StringTrim[ToString[Lookup[n, "Id", ""]]];
      If[id === "" || id === rootId && ! KeyExistsQ[index, id], Continue[]];
      If[! KeyExistsQ[index, id] && ! MemberQ[newIds, id] && ! StringStartsQ[id, "adj_"],
        id = "adj_" <> StringReplace[id, Except[WordCharacter] -> "_"]];
      isNew = ! KeyExistsQ[index, id] && ! MemberQ[newIds, id];
      m = Select[KeyTake[n, {"Label", "Lead", "Talk", "Summary", "Kind", "Cite"}], StringQ];
      Do[If[MatchQ[Lookup[n, k, None], {___String}], m[k] = n[k]], {k, {"Points", "Details"}}];
      If[NumericQ[Lookup[n, "Importance", None]], m["Importance"] = Clip[N[n["Importance"]], {0., 1.}]];
      If[BooleanQ[Lookup[n, "Hidden", None]], m["Hidden"] = n["Hidden"]];
      specs = Replace[Lookup[n, "Assets", {}], Except[_List] -> {}];
      assets = Map[iSWAdjustAsset[#, index, pdfRef] &, specs];
      If[MemberQ[assets, $Failed], AppendTo[warn, id <> ": \:4f7f\:3048\:306a\:3044\:56f3\:306e\:6307\:5b9a\:3092\:843d\:3068\:3057\:305f"]];
      assets = Select[assets, AssociationQ];
      If[assets =!= {},
        m["Assets"] = assets; m["VisualDone"] = True;
        If[! StringQ[Lookup[m, "Cite", None]],
          With[{a = First[assets]},
            Which[
              a["Type"] === "PDFImage", m["Cite"] = "(" <> key <> ") p." <> ToString[a["Page"]],
              KeyExistsQ[a, "Ref"] && AnyTrue[Values[index], MemberQ[Replace[Lookup[#, "Assets", {}], Except[_List] -> {}], a] &],
                With[{src = SelectFirst[Values[index], MemberQ[Replace[Lookup[#, "Assets", {}], Except[_List] -> {}], a] &]},
                  With[{c = SourceVault`SourceVaultKGText[src, "Cite"]}, If[c =!= "", m["Cite"] = c]]],
              True, Null]]]];
      after = Lookup[n, "After", None];
      If[StringQ[after] && (KeyExistsQ[orders, after]) && after =!= id,
        With[{o = iSWAdjustOrderAfter[orders, after]}, If[NumericQ[o], m["Order"] = o; orders[id] = o]];
        AppendTo[edges, <|"From" -> after, "To" -> id, "EdgeKind" -> "Precedes", "Weight" -> 0.9|>]];
      If[isNew,
        If[! StringQ[Lookup[m, "Label", None]] || ! MatchQ[Lookup[m, "Points", {}], {__String}],
          AppendTo[warn, id <> ": \:984c\:76ee\:3068\:8981\:70b9\:306e\:7121\:3044\:65b0\:3057\:3044\:30b9\:30e9\:30a4\:30c9\:306f\:8db3\:3055\:306a\:304b\:3063\:305f"]; Continue[]];
        par = Lookup[n, "Parent", None];
        If[! (StringQ[par] && (MemberQ[secs, par] || par === rootId)),
          par = If[StringQ[after], Lookup[parent, after, rootId], rootId]];
        If[! KeyExistsQ[m, "Order"],
          With[{kids = Select[Keys[Select[parent, # === par &]], NumericQ[Lookup[orders, #, None]] &]},
            m["Order"] = If[kids === {}, Replace[Lookup[orders, par, 0], Except[_?NumericQ] -> 0] + 0.1,
              Max[Lookup[orders, kids]] + 0.1]; orders[id] = m["Order"]]];
        m = Join[<|"Id" -> id, "Kind" -> "Concept", "Layer" -> "Paper", "Importance" -> 0.9, "VisualDone" -> True,
          "Source" -> <|"Ref" -> key, "Kind" -> "Adjust"|>|>, m];
        parent[id] = par;
        AppendTo[edges, <|"From" -> par, "To" -> id, "EdgeKind" -> "Contains"|>];
        AppendTo[newIds, id]; AppendTo[added, id],
        m["Id"] = id; AppendTo[changed, id]];
      AppendTo[nodes, m]],
    {n, Select[Replace[Lookup[raw, "Nodes", {}], Except[_List] -> {}], AssociationQ]}];
  Do[If[StringQ[h] && KeyExistsQ[index, h] && h =!= rootId,
      AppendTo[nodes, <|"Id" -> h, "Hidden" -> True|>]; AppendTo[hidden, h]],
    {h, Replace[Lookup[raw, "Hide", {}], Except[_List] -> {}]}];
  <|"Delta" -> <|"Nodes" -> nodes, "Edges" -> edges|>, "Added" -> added, "Changed" -> DeleteDuplicates[changed],
    "Hidden" -> hidden, "Warnings" -> warn|>];

$iSWAdjustLast = None;
iSWAdjustApply[nb_, gid_String, co_, pdfRef_, key_String, then_, resp_] := Module[{kg, json, raw, d, res, msg, st},
  $iSWRefineBusy = False;
  kg = iSWKGResolve[gid];
  json = If[StringQ[resp] && ! StringStartsQ[resp, "Error" | "[ERROR]"], iSWRefineExtractJSON[resp], $Failed];
  raw = If[StringQ[json], Quiet @ Check[Developer`ReadRawJSONString[json], $Failed], $Failed];
  Which[
    ! AssociationQ[kg] || ! AssociationQ[raw],
      st = "Failed"; d = <|"Added" -> {}, "Changed" -> {}, "Hidden" -> {}, "Warnings" -> {}|>;
      msg = iSL["\:8abf\:6574\:3092\:53cd\:6620\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f: LLM \:306e\:5fdc\:7b54\:304b\:3089 JSON \:3092\:8aad\:3081\:307e\:305b\:3093", "Adjustment failed: no JSON in the LLM reply"],
    True,
      d = iSWAdjustDelta[kg, raw, pdfRef, key];
      If[d["Delta"]["Nodes"] === {} && d["Delta"]["Edges"] === {},
        st = "NoChange";
        msg = iSL["\:8abf\:6574: \:76f4\:3059\:3068\:3053\:308d\:304c\:3042\:308a\:307e\:305b\:3093\:3067\:3057\:305f", "Adjust: nothing to change"],
        res = SlideGraphIngest[gid, d["Delta"], "Merge" -> True];
        If[MatchQ[res, _Success],
          st = "Applied";
          msg = iSL["\:8abf\:6574\:3092\:53cd\:6620\:3057\:307e\:3057\:305f: \:8ffd\:52a0 " <> ToString[Length[d["Added"]]] <> " / \:5909\:66f4 " <> ToString[Length[d["Changed"]]] <>
              " / \:96a0\:3059 " <> ToString[Length[d["Hidden"]]] <> "\:3002\:53e4\:3044\:751f\:6210\:30b9\:30e9\:30a4\:30c9\:3092\:6d88\:3057\:3066\:304b\:3089\:300c\:751f\:6210\:300d\:3092\:62bc\:3057\:3066\:304f\:3060\:3055\:3044",
            "Adjusted: added " <> ToString[Length[d["Added"]]] <> ", changed " <> ToString[Length[d["Changed"]]] <>
              ", hidden " <> ToString[Length[d["Hidden"]]] <> ". Delete the old generated slides, then press Generate"];
          iSWAdjustMarkApplied[co, msg],
          st = "Failed";
          msg = iSL["\:8abf\:6574\:3092\:53cd\:6620\:3067\:304d\:307e\:305b\:3093\:3067\:3057\:305f: ", "Adjustment failed: "] <> StringTake[ToString[res], UpTo[200]]]]];
  If[d["Warnings"] =!= {}, msg = msg <> iSL[" (\:6ce8\:610f: ", " (note: "] <> StringRiffle[d["Warnings"], " / "] <> ")"];
  iSWGraphApplyNote[nb, msg];
  $iSWAdjustLast = <|"Status" -> st, "Added" -> d["Added"], "Changed" -> d["Changed"], "Hidden" -> d["Hidden"],
    "Warnings" -> d["Warnings"], "Message" -> msg|>;
  If[then =!= None, Quiet[then[]]];
  $iSWAdjustLast];

Options[SlideGraphAdjust] = {"PDF" -> Automatic, "Then" -> None, "Cell" -> None, "Audience" -> Automatic, "Story" -> Automatic,
  "Refine" -> Automatic};
SlideGraphAdjust[opts : OptionsPattern[]] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideGraphAdjust[nb, opts]]];
SlideGraphAdjust[nb_NotebookObject, opts : OptionsPattern[]] := Module[{co, text},
  If[iSWRefineBusyQ[],
    iSWStatus[nb, iSL["KG \:306e\:63a8\:6572\:30fb\:56f3\:89e3\:30fb\:8abf\:6574\:3092\:5b9f\:884c\:4e2d\:3067\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044", "A KG run is in progress"]];
    Return[<|"Status" -> "Busy"|>]];
  co = iSWAdjustPendingCell[nb];
  If[co === None,
    SlideInsertAdjust[nb];
    iSWStatus[nb, iSL["\:8abf\:6574\:30bb\:30eb\:3092\:5165\:308c\:307e\:3057\:305f\:3002\:76f4\:3057\:305f\:3044\:3053\:3068\:3092\:66f8\:3044\:3066\:3001\:3082\:3046\:4e00\:5ea6\:300c\:8abf\:6574\:300d\:3092\:62bc\:3057\:3066\:304f\:3060\:3055\:3044",
      "Inserted an adjustment cell. Write what to change, then press Adjust again"]];
    Return[<|"Status" -> "CellInserted"|>]];
  text = iSWAdjustText[iCellText[NotebookRead[co]]];
  If[text === "",
    Quiet[SelectionMove[co, All, CellContents]];
    iSWStatus[nb, iSL["\:8abf\:6574\:30bb\:30eb\:306b\:76f4\:3057\:305f\:3044\:3053\:3068\:3092\:66f8\:3044\:3066\:304b\:3089\:300c\:8abf\:6574\:300d\:3092\:62bc\:3057\:3066\:304f\:3060\:3055\:3044", "Write the change into the adjustment cell first"]];
    Return[<|"Status" -> "EmptyInstruction"|>]];
  SlideGraphAdjust[nb, text, "Cell" -> co, opts]];
SlideGraphAdjust[nb_NotebookObject, instruction_String, opts : OptionsPattern[]] := Module[{spec, kg, un},
  spec = SlideGraphSpec[nb];
  kg = iSWKGResolve[spec["Graph"]];
  If[! AssociationQ[kg], iSWStatus[nb, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; Return[kg]];
  (* \:63a8\:6572\:304c\:9014\:4e2d\:3067\:6b62\:307e\:3063\:305f\:7bc0 (\:7b87\:6761\:66f8\:304d\:304c\:300c\:2026\:300d\:3067\:5207\:308c\:305f\:679a) \:306f\:3001\:5148\:306b\:63a8\:6572\:3057\:3066\:304b\:3089\:6307\:793a\:3092\:53cd\:6620\:3059\:308b *)
  If[OptionValue["Refine"] =!= False && (un = iSWUnrefinedSections[kg]) =!= {},
    If[iSWRefineBusyQ[], iSWStatus[nb, iSL["KG \:306e\:63a8\:6572\:30fb\:56f3\:89e3\:30fb\:8abf\:6574\:3092\:5b9f\:884c\:4e2d\:3067\:3059", "A KG run is in progress"]]; Return[<|"Status" -> "Busy"|>]];
    Return[With[{o = FilterRules[{opts}, Except["Refine"]]},
      iSWRefineFirst[nb, spec, kg, un, 8,
        Function[SlideGraphAdjust[nb, instruction, "Refine" -> False, Sequence @@ o]], $iSWThenAdjustNote]]]];
  iSWAdjustRun[nb, spec, kg, instruction, OptionValue["Cell"], OptionValue["PDF"], OptionValue["Then"],
    iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb]]];
SlideGraphAdjust[graphId_String, instruction_String, opts : OptionsPattern[]] := Module[{kg = iSWKGResolve[graphId], spec, un},
  If[! AssociationQ[kg], Return[kg]];
  spec = Join[$iSWStoryDefaults, <|"Graph" -> Lookup[kg, "GraphId", graphId], "Title" -> Lookup[kg, "Title", ""],
    "Language" -> Lookup[kg, "Language", "ja"]|>];
  If[OptionValue["Audience"] =!= Automatic, spec["Audience"] = OptionValue["Audience"]];
  If[StringQ[OptionValue["Story"]], spec["Story"] = OptionValue["Story"]];
  If[OptionValue["Refine"] =!= False && (un = iSWUnrefinedSections[kg]) =!= {},
    If[iSWRefineBusyQ[], Return[<|"Status" -> "Busy", "Graph" -> graphId|>]];
    Return[With[{o = FilterRules[{opts}, Except["Refine"]]},
      iSWRefineFirst[None, spec, kg, un, 8,
        Function[SlideGraphAdjust[graphId, instruction, "Refine" -> False, Sequence @@ o]], $iSWThenAdjustNote]]]];
  iSWAdjustRun[None, spec, kg, instruction, None, OptionValue["PDF"], OptionValue["Then"], ""]];

iSWAdjustRun[nb_, spec_Association, kg0_Association, instruction_String, co_, pdfOpt_, then_, metaBlocks_String] := Module[
  {gid = spec["Graph"], gen, pdfRef, key, prompt, pl, kg},
  If[! iSWLLMReadyQ[], Return[Failure["NoLLM", <|"MessageTemplate" -> "LLM query function is not registered (load NBAccess/claudecode)"|>]]];
  If[iSWRefineBusyQ[], iSWStatusIf[nb, iSL["KG \:306e\:63a8\:6572\:30fb\:56f3\:89e3\:30fb\:8abf\:6574\:3092\:5b9f\:884c\:4e2d\:3067\:3059", "A KG run is in progress"]]; Return[<|"Status" -> "Busy"|>]];
  kg = iSWKGCiteRepair[gid, kg0];
  iSWGenProgress[nb, "\:8abf\:6574: \:3044\:307e\:306e\:30b9\:30e9\:30a4\:30c9\:69cb\:6210\:3092\:78ba\:8a8d\:4e2d\:2026", "Adjust: reading the current slide plan..."];
  gen = If[Head[nb] === NotebookObject, SlideGraphGenerate[nb, "Realize" -> False],
    SlideGraphGenerate[gid, "Realize" -> False, "Audience" -> spec["Audience"]]];
  pdfRef = iSWAdjustPDFRef[nb, kg, pdfOpt];
  key = iSWAdjustKey[kg];
  prompt = With[{slides = If[AssociationQ[gen], gen["Outline"]["Slides"], {}]},
    iSWAdjustPrompt[spec, kg, slides, instruction, iSWAdjustPDFInfo[kg, pdfRef], metaBlocks,
      If[Head[nb] === NotebookObject, iSWAdjustDeckOffset[nb, slides], 0]]];
  pl = iSWRefinePrivacy[nb, kg];
  $iSWRefineBusy = True; $iSWRefineBusySince = AbsoluteTime[];
  iSWGenProgress[nb, "\:8abf\:6574: LLM \:306b\:554f\:3044\:5408\:308f\:305b\:4e2d\:2026", "Adjust: asking the LLM..."];
  With[{n2 = nb, g = gid, c = co, r = pdfRef, k = key, th = then},
    NBAccess`$NBLLMQueryFunc[prompt,
      Function[resp, iSWAdjustApply[n2, g, c, r, k, th, resp]],
      n2, Fallback -> iSWFallback[], PrivacyLevel -> pl]];
  <|"Status" -> "Submitted", "Graph" -> gid, "PDF" -> pdfRef, "PrivacyLevel" -> pl|>];

SlideGraphRefine[graphId_String, OptionsPattern[]] := Module[{kg = iSWKGResolve[graphId], spec, un},
  If[! AssociationQ[kg], Return[kg]];
  If[iSWRefineBusyQ[], Return[<|"Status" -> "Busy", "Graph" -> graphId|>]];
  spec = Join[$iSWStoryDefaults, <|"Graph" -> Lookup[kg, "GraphId", graphId], "Title" -> Lookup[kg, "Title", ""]|>];
  If[OptionValue["Audience"] =!= Automatic, spec["Audience"] = OptionValue["Audience"]];
  If[StringQ[OptionValue["Story"]], spec["Story"] = OptionValue["Story"]];
  If[MemberQ[{"Visual", "Talk", "Detail", "Enrich"}, OptionValue["Mode"]] && OptionValue["Refine"] =!= False &&
      (un = iSWUnrefinedSections[kg]) =!= {},
    Return[With[{m = OptionValue["Mode"], pdf = OptionValue["PDF"], au = OptionValue["Audience"], st = OptionValue["Story"],
        bn = OptionValue["BatchNodes"], sel = OptionValue["Sections"], ov = OptionValue["Overview"]},
      iSWRefineFirst[None, spec, kg, un, bn,
        Function[SlideGraphRefine[graphId, "Mode" -> m, "Refine" -> False, "Overview" -> ov, "PDF" -> pdf,
          "Audience" -> au, "Story" -> st, "BatchNodes" -> bn, "Sections" -> sel]],
        If[m === "Visual", $iSWThenVisualNote, $iSWThenFinishNote]]]]];
  If[OptionValue["Mode"] === "Visual" && OptionValue["Overview"] =!= False &&
      iSWOverviewNeededQ[None, kg, OptionValue["PDF"]],
    Return[With[{pdf = OptionValue["PDF"], au = OptionValue["Audience"], st = OptionValue["Story"], bn = OptionValue["BatchNodes"]},
      SlideGraphAdjust[graphId, $iSWOverviewInstruction, "PDF" -> pdf, "Refine" -> False,
        "Audience" -> spec["Audience"], "Story" -> Lookup[spec, "Story", ""],
        "Then" -> Function[SlideGraphRefine[graphId, "Mode" -> "Visual", "Overview" -> False, "Refine" -> False, "PDF" -> pdf,
          "Audience" -> au, "Story" -> st, "BatchNodes" -> bn]]]]]];
  $iSWRefineTalkOnly = MemberQ[{"Talk", "Detail", "Enrich", "Visual"}, OptionValue["Mode"]];
  $iSWRefineVisual = OptionValue["Mode"] === "Visual";
  $iSWRefineEnrichAll = OptionValue["Mode"] =!= "Talk";
  iSWRefineStart[None, spec, kg, OptionValue["BatchNodes"], OptionValue["Sections"]]];

(* ===================== v1.30: \:679a\:306e\:51fa\:3069\:3053\:308d\:3068\:3001\:751f\:6210\:3057\:76f4\:3057\:3066\:3082\:6d88\:3048\:306a\:3044\:8cea\:7591\:5fdc\:7b54 =====================
   KG \:304b\:3089\:4f5c\:3063\:305f\:679a\:306e\:984c\:76ee\:30bb\:30eb\:306b\:306f CellTags "KGNode:<id>" \:304c\:4ed8\:304f (md \:306e {expected=.. node=..})\:3002
   \:300c\:751f\:6210\:300d\:306f\:524d\:56de\:306e\:679a\:3092\:898b\:5206\:3051\:3066\:7f6e\:304d\:63db\:3048\:308b\:3002\:305d\:306e\:524d\:306b\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3092 KG \:306e\:30ce\:30fc\:30c9 ("QA") \:3078\:56de\:53ce\:3057\:3001
   \:6b21\:306e\:751f\:6210\:3067\:540c\:3058\:30ce\:30fc\:30c9\:306e\:679a\:3078 qa: \:3068\:3057\:3066\:623b\:3059 (\:624b\:3067\:76f4\:3057\:305f\:554f\:7b54\:3082\:6d88\:3048\:306a\:3044)\:3002\:300c\:767b\:9332\:300d\:306f\:5f93\:6765\:3069\:304a\:308a\:30c7\:30c3\:30ad\:306e\:30bb\:30eb\:304b\:3089\:713c\:304f *)
$iSWKGNodeTagPrefix = "KGNode:";
iSWKGNodeOfTags[tags_] := FirstCase[Flatten[{tags}], s_String /; StringStartsQ[s, $iSWKGNodeTagPrefix] :>
  StringDrop[s, StringLength[$iSWKGNodeTagPrefix]], None];

(* \:30c7\:30c3\:30ad\:306e\:679a\:3054\:3068: \:679a\:756a\:53f7\:30fb\:30ce\:30fc\:30c9 Id (\:7121\:3051\:308c\:3070 None)\:30fb\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:306e\:672c\:6587 (\:7121\:3051\:308c\:3070 "") *)
iSWKGDeckSlideNodes[nb_NotebookObject] := Module[{ranges, styles, cells},
  ranges = iSWSlideRanges[nb];
  If[ranges === {}, Return[{}]];
  styles = iSWCellStyles[nb]; cells = Cells[nb];
  Table[
    Module[{r = ranges[[i]], span, tIdx, qIdx, node = None, qa = ""},
      span = Range[r[[1]], Min[r[[2]], Length[styles]]];
      tIdx = SelectFirst[span, MemberQ[Flatten[{styles[[#]]}], "Subsection"] &, None];
      If[IntegerQ[tIdx], node = iSWKGNodeOfTags[iSWCellTags[cells[[tIdx]]]]];
      qIdx = SelectFirst[span, MemberQ[Flatten[{styles[[#]]}], "SlideQA"] &, None];
      If[IntegerQ[qIdx],
        qa = With[{c = Quiet[NotebookRead[cells[[qIdx]]]]}, If[Head[c] === Cell, iCellText[c], ""]]];
      <|"Slide" -> i, "Node" -> node, "QA" -> If[StringQ[qa], StringTrim[qa], ""]|>],
    {i, Length[ranges]}]];

(* \:679a\:3054\:3068\:306e\:8cea\:7591\:5fdc\:7b54\:3092\:30ce\:30fc\:30c9\:3054\:3068\:306b (\:540c\:3058\:30ce\:30fc\:30c9\:306e\:679a = \:672c\:4f53\:3068\:300c(\:7d9a\:304d)\:300d\:306e\:9806)\:3002KG \:306b\:7121\:3044 Id (agenda / glossary) \:306f\:6368\:3066\:308b *)
iSWKGQAByNode[rows_List, kg_Association] := With[{ids = Lookup[kg["Nodes"], "Id", {}]},
  GroupBy[Select[rows, AssociationQ[#] && StringQ[Lookup[#, "Node", None]] && MemberQ[ids, #["Node"]] &],
    #["Node"] &, Map[Lookup[#, "QA", ""] &]]];

iSWKGNodeQAList[n_Association] := Replace[Lookup[n, "QA", {}], {s_String :> {s}, Except[_List] -> {}}];

(* \:3044\:307e\:306e\:30c7\:30c3\:30ad\:306e\:554f\:7b54\:3092\:30ce\:30fc\:30c9\:3078\:5199\:3059 (\:30c7\:30c3\:30ad\:306b\:679a\:304c\:3042\:308b\:30ce\:30fc\:30c9\:3060\:3051\:3002\:7a7a\:306a\:3089\:6d88\:3059) *)
iSWKGApplyQA[kg_Association, byNode_Association] := Module[{changed = {}, nodes},
  nodes = Map[Function[n,
      If[! KeyExistsQ[byNode, n["Id"]], n,
        With[{new = If[AllTrue[byNode[n["Id"]], # === "" &], {}, byNode[n["Id"]]]},
          If[iSWKGNodeQAList[n] === new, n,
            AppendTo[changed, n["Id"]];
            If[new === {}, KeyDrop[n, "QA"], Append[n, "QA" -> new]]]]]],
    kg["Nodes"]];
  <|"KG" -> Append[kg, "Nodes" -> nodes], "Changed" -> changed|>];

iSWKGHarvestQA[nb_NotebookObject, gid_String] := Module[{kg = iSWKGResolve[gid], rows, byNode, r},
  If[! AssociationQ[kg], Return[<|"Status" -> "NoGraph", "Nodes" -> 0|>]];
  rows = Quiet @ Check[iSWKGDeckSlideNodes[nb], {}];
  If[! ListQ[rows], rows = {}];
  byNode = iSWKGQAByNode[rows, kg];
  If[byNode === <||>, Return[<|"Status" -> "NoSlides", "Nodes" -> 0|>]];
  r = iSWKGApplyQA[kg, byNode];
  Which[
    r["Changed"] === {}, <|"Status" -> "Unchanged", "Nodes" -> 0|>,
    StringQ[Quiet @ SourceVault`SourceVaultKGSave[r["KG"]]], <|"Status" -> "Saved", "Nodes" -> Length[r["Changed"]], "Changed" -> r["Changed"]|>,
    True, <|"Status" -> "SaveFailed", "Nodes" -> 0|>]];

(* \:751f\:6210: KG \:306e\:30ce\:30fc\:30c9\:306b\:4fdd\:5b58\:3057\:305f\:554f\:7b54\:3092\:3001\:305d\:306e\:30ce\:30fc\:30c9\:306e\:679a\:3078\:9806\:306b\:623b\:3059\:3002\:679a\:304c\:6e1b\:3063\:305f\:3068\:304d\:306f\:6b8b\:308a\:3092\:6700\:5f8c\:306e\:679a\:306b\:307e\:3068\:3081\:308b *)
iSWKGAttachQA[outline_Association, kg_Association] := Module[{index, slides, eligible, counts, seen = <||>},
  index = Association[(#["Id"] -> #) & /@ kg["Nodes"]];
  slides = Lookup[outline, "Slides", {}];
  eligible[s_] := With[{id = Lookup[s, "NodeId", None]},
    StringQ[id] && Lookup[s, "Kind", ""] =!= "Glossary" && KeyExistsQ[index, id] && iSWKGNodeQAList[index[id]] =!= {}];
  counts = Counts[Lookup[Select[slides, eligible], "NodeId", {}]];
  Append[outline, "Slides" -> Map[Function[s,
    If[! eligible[s], s,
      Module[{id = s["NodeId"], qa, k, txt},
        qa = iSWKGNodeQAList[index[id]];
        k = (seen[id] = Lookup[seen, id, 0] + 1);
        txt = Which[
          k > Length[qa], "",
          k === counts[id], StringRiffle[Select[qa[[k ;;]], StringQ[#] && StringTrim[#] =!= "" &], "\n"],
          True, If[StringQ[qa[[k]]], qa[[k]], ""]];
        If[StringTrim[txt] === "", s, Append[s, "QA" -> txt]]]]],
    slides]]];

(* \:524d\:56de\:306e\:751f\:6210\:30b9\:30e9\:30a4\:30c9\:3092\:6d88\:3059 (\:756a\:53f7\:306f\:5f8c\:308d\:304b\:3089) *)
iSWDeleteSlides[nb_NotebookObject, idxs_List] := Module[{ranges = iSWSlideRanges[nb], cells = Cells[nb], n = 0},
  Do[If[IntegerQ[i] && 1 <= i <= Length[ranges],
      Quiet[NotebookDelete[cells[[ranges[[i, 1]] ;; ranges[[i, 2]]]]]]; n++],
    {i, ReverseSort[DeleteDuplicates[idxs]]}];
  n];

(* \:30d1\:30ec\:30c3\:30c8\:306e\:300c\:751f\:6210\:300d: \:524d\:56de\:306e\:751f\:6210\:30b9\:30e9\:30a4\:30c9\:304c\:3042\:308c\:3070\:7f6e\:304d\:63db\:3048\:308b\:304b\:805e\:304f *)
iSWGraphApplyAction[nb_NotebookObject] := Module[{rows, old, choice},
  rows = Quiet @ Check[iSWKGDeckSlideNodes[nb], {}];
  old = If[ListQ[rows], Count[rows, r_Association /; StringQ[r["Node"]]], 0];
  choice = If[old > 0,
    ChoiceDialog[iSL[
      "\:524d\:56de\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:751f\:6210\:3057\:305f " <> ToString[old] <> " \:679a\:304c\:3042\:308a\:307e\:3059\:3002\n\n" <>
        "\:7f6e\:304d\:63db\:3048\:308b: \:524d\:56de\:306e\:679a\:3092\:6d88\:3057\:3066\:4f5c\:308a\:76f4\:3057\:307e\:3059\:3002\:8cea\:7591\:5fdc\:7b54\:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:306b\:4fdd\:5b58\:3057\:3066\:65b0\:3057\:3044\:679a\:3078\:5f15\:304d\:7d99\:304e\:307e\:3059 " <>
        "(\:624b\:3067\:76f4\:3057\:305f\:672c\:6587\:3068\:539f\:7a3f\:306f\:77e5\:8b58\:30b0\:30e9\:30d5\:304b\:3089\:4f5c\:308a\:76f4\:3055\:308c\:307e\:3059\:3002\:6b8b\:3057\:305f\:3044\:76f4\:3057\:306f\:300c\:8abf\:6574\:300d\:3067\:77e5\:8b58\:30b0\:30e9\:30d5\:306b\:5165\:308c\:3066\:304f\:3060\:3055\:3044)\:3002\n" <>
        "\:5f8c\:308d\:306b\:8ffd\:52a0: \:524d\:56de\:306e\:679a\:3092\:6b8b\:3057\:305f\:307e\:307e\:672b\:5c3e\:306b\:8db3\:3057\:307e\:3059\:3002",
      "There are " <> ToString[old] <> " slides generated from the knowledge graph last time.\n\n" <>
        "Replace: delete them and generate again. The Q&A is saved to the knowledge graph and carried over " <>
        "(hand edits to the slide text and talk are regenerated from the graph; use Adjust to keep them).\n" <>
        "Append: keep them and add the new slides at the end."],
      {iSL["\:7f6e\:304d\:63db\:3048\:308b", "Replace"] -> "Replace", iSL["\:5f8c\:308d\:306b\:8ffd\:52a0", "Append"] -> "Append", iSL["\:3084\:3081\:308b", "Cancel"] -> "Cancel"}],
    "Append"];
  If[! MemberQ[{"Replace", "Append"}, choice], Return[<|"Status" -> "Cancelled"|>]];
  SlideGraphApply[nb, "Mode" -> choice]];

(* ===================== v1.30: \:767a\:8868\:306e\:300c\:539f\:7a3f\:300d = \:30c8\:30fc\:30af\:30bb\:30eb\:306e\:7121\:3044\:679a\:306b\:3060\:3051\:539f\:7a3f\:3092\:66f8\:304f =====================
   \:65e7\:300c\:30b7\:30ca\:30ea\:30aa\:300d(SlideTalkBuild) \:306f\:30c8\:30fc\:30af\:30bb\:30eb\:3092 <deck>_talk.md \:306b\:675f\:306d\:308b\:66f8\:304d\:51fa\:3057\:3067\:3001\:30c8\:30fc\:30af\:30bb\:30eb\:304c\:6b63\:672c\:306b\:306a\:3063\:3066\:304b\:3089\:306f
   \:767a\:8868\:306b\:3082\:767b\:9332\:306b\:3082\:8981\:3089\:306a\:3044 (\:95a2\:6570\:3068\:3057\:3066\:306f\:6b8b\:3059)\:3002KG \:304b\:3089\:4f5c\:3063\:305f\:679a\:306f\:751f\:6210\:6642\:306b\:30ce\:30fc\:30c9\:306e\:539f\:7a3f\:304c\:5165\:308b\:306e\:3067\:3001\:3053\:3053\:3067\:66f8\:304f\:306e\:306f
   \:624b\:3067\:8db3\:3057\:305f\:679a\:3084\:5f93\:6765\:306e\:5c55\:958b\:3067\:539f\:7a3f\:3092\:4f5c\:3089\:306a\:304b\:3063\:305f\:679a *)
$iSWTalkFillBatch = 8;
iSWTalkFillPrompt[title_String, slides_List, targets_List, meta_String] :=
  meta <>
  "\:3042\:306a\:305f\:306f\:7814\:7a76\:767a\:8868\:306e\:539f\:7a3f\:3092\:66f8\:304f\:52a9\:624b\:3067\:3059\:3002\:767a\:8868\:300c" <> title <> "\:300d\:306e\:3046\:3061\:3001\:539f\:7a3f (\:8aad\:307f\:4e0a\:3052\:308b\:53f0\:672c) \:306e\:7121\:3044\:30b9\:30e9\:30a4\:30c9\:306b\:539f\:7a3f\:3092\:66f8\:3044\:3066\:304f\:3060\:3055\:3044\:3002\n\n" <>
  "\:767a\:8868\:5168\:4f53\:306e\:6d41\:308c (\:756a\:53f7 \:984c\:76ee / \:65e2\:306b\:3042\:308b\:539f\:7a3f\:306e\:5192\:982d):\n" <>
  StringRiffle[Map[Function[s, "  " <> ToString[s["Slide"]] <> " " <> iSWQAOneLine[s["Title"]] <>
    With[{t = StringTrim[ToString[Lookup[s, "Talk", ""]]]}, If[t === "", "", " / " <> StringTake[StringReplace[t, "\n" -> " "], UpTo[50]]]]], slides], "\n"] <>
  "\n\n=== \:539f\:7a3f\:3092\:66f8\:304f\:30b9\:30e9\:30a4\:30c9 ===\n" <>
  StringRiffle[Map[Function[s, "--- \:30b9\:30e9\:30a4\:30c9 " <> ToString[s["Slide"]] <> ": " <> iSWQAOneLine[s["Title"]] <> "\n" <>
    StringTake[ToString[s["Text"]], UpTo[1800]]], targets], "\n\n"] <>
  "\n\n\:898f\:5247 (\:53b3\:5b88):\n" <>
  "- \:3067\:3059\:30fb\:307e\:3059\:8abf\:3067 2\:301c6 \:6587\:3002\:5192\:982d\:3067\:524d\:306e\:30b9\:30e9\:30a4\:30c9\:304b\:3089\:306e\:3064\:306a\:304c\:308a\:3092\:4e00\:8a00\:8ff0\:3079\:308b (\:6bce\:56de\:9055\:3046\:8a00\:3044\:56de\:3057\:3067)\:3002\n" <>
  "- \:30b9\:30e9\:30a4\:30c9\:306e\:7b87\:6761\:66f8\:304d\:3068\:540c\:3058\:9806\:306b\:8aac\:660e\:3059\:308b\:3002\:30b9\:30e9\:30a4\:30c9\:306b\:7121\:3044\:4e8b\:5b9f\:30fb\:6570\:5024\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:8aad\:307f\:4e0a\:3052\:308b\:539f\:7a3f\:306a\:306e\:3067 $...$ \:3084 ** \:3084\:8a18\:53f7\:5217\:30fbURL \:3092\:66f8\:304b\:306a\:3044\:3002\:5f0f\:306f\:300c\:3053\:306e\:5f0f\:306f\:301c\:3092\:8868\:3057\:307e\:3059\:300d\:3068\:753b\:9762\:3092\:6307\:3057\:3066\:8a9e\:308b\:3002\n" <>
  "- \:56f3\:3084\:8868\:306e\:3042\:308b\:30b9\:30e9\:30a4\:30c9\:3067\:306f\:3001\:4f55\:304c\:63cf\:304b\:308c\:3066\:3044\:308b\:304b\:3092\:8a00\:8449\:3067\:6848\:5185\:3059\:308b\:3002\n\n" <>
  "\:51fa\:529b (\:53b3\:5b88): JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3002\:8aac\:660e\:6587\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:7121\:3057:\n" <>
  "{\"Talks\": [{\"Slide\": <\:756a\:53f7>, \"Talk\": \"\:539f\:7a3f\"}]}";

iSWTalkFillParse[resp_, targets_List] := Module[{json, d, rows},
  json = If[StringQ[resp] && ! StringStartsQ[resp, "Error" | "[ERROR]"], iSWRefineExtractJSON[resp], $Failed];
  d = If[StringQ[json], Quiet @ Check[Developer`ReadRawJSONString[json], $Failed], $Failed];
  rows = If[AssociationQ[d], Replace[Lookup[d, "Talks", {}], Except[_List] -> {}], {}];
  Association @ Cases[rows,
    r_Association /; IntegerQ[Lookup[r, "Slide", None]] && MemberQ[targets, r["Slide"]] &&
      StringQ[Lookup[r, "Talk", None]] && StringTrim[r["Talk"]] =!= "" :> (r["Slide"] -> StringTrim[r["Talk"]])]];

(* \:30b9\:30e9\:30a4\:30c9 n \:306b\:30c8\:30fc\:30af\:30bb\:30eb\:3092\:66f8\:304f (\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:304c\:3042\:308c\:3070\:305d\:306e\:524d) *)
iSWTalkWriteCell[nb_NotebookObject, n_Integer, text_String] := Module[{ranges, cells, styles, span, tIdx, qIdx, cell},
  ranges = iSWSlideRanges[nb];
  If[! (1 <= n <= Length[ranges]), Return[$Failed]];
  cells = Cells[nb]; styles = iSWCellStyles[nb];
  span = Range[ranges[[n, 1]], Min[ranges[[n, 2]], Length[styles]]];
  cell = iContentCell[{"Talk", text}];
  tIdx = SelectFirst[span, MemberQ[Flatten[{styles[[#]]}], "SlideTalk"] &, None];
  qIdx = SelectFirst[span, MemberQ[Flatten[{styles[[#]]}], "SlideQA"] &, None];
  Which[
    IntegerQ[tIdx], SelectionMove[cells[[tIdx]], All, Cell]; NotebookWrite[nb, cell, All],
    IntegerQ[qIdx], SelectionMove[cells[[qIdx]], Before, Cell]; NotebookWrite[nb, cell],
    True, SelectionMove[cells[[Last[span]]], After, Cell]; NotebookWrite[nb, cell]];
  n];

SlideTalkFill[] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideTalkFill[nb]]];
SlideTalkFill[nb_NotebookObject] := Module[{outline, n, slides, missing, title, meta, batches},
  If[! iSWRequireLLM[], Return[$Failed]];
  If[iSWTalkFillBusyQ[],
    iSWStatus[nb, iSL["\:539f\:7a3f\:3092\:66f8\:3044\:3066\:3044\:307e\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044", "Writing talks; wait until it finishes"]];
    Return[<|"Status" -> "Busy"|>]];
  (* \:4fdd\:5b58\:6e08\:307f\:3067\:76f4\:3057\:304c\:7121\:3051\:308c\:3070\:30d5\:30a1\:30a4\:30eb\:304b\:3089\:3001\:305d\:3046\:3067\:306a\:3051\:308c\:3070\:30ce\:30fc\:30c8\:30d6\:30c3\:30af\:304b\:3089\:8aad\:3080 (\:756a\:53f7\:306f FE \:306e\:30c7\:30c3\:30ad\:3068\:540c\:3058) *)
  outline = iTalkDeckOutline[iSWDeckSource[nb]];
  If[outline === $Failed,
    iSWStatus[nb, iSL["\:30b9\:30e9\:30a4\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093", "No slides found"]]; iSWStatusClearLater[nb];
    Return[$Failed]];
  n = outline["Count"];
  slides = Table[<|"Slide" -> i, "Title" -> outline["Titles"][[i]], "Text" -> outline["Markdown"][[i]],
    "Talk" -> outline["Talks"][[i]]|>, {i, n}];
  missing = Select[slides, ! (StringQ[#["Talk"]] && StringTrim[#["Talk"]] =!= "") &];
  If[missing === {},
    iSWStatus[nb, iSL["\:5168 " <> ToString[n] <> " \:679a\:306b\:539f\:7a3f\:304c\:3042\:308a\:307e\:3059 (\:539f\:7a3f\:3092 md \:306b\:66f8\:304d\:51fa\:3059\:306a\:3089 SlideTalkBuild[])",
      "All " <> ToString[n] <> " slides have a talk (SlideTalkBuild[] writes them to md)"]];
    iSWStatusClearLater[nb];
    Return[<|"Status" -> "Complete", "Slides" -> n, "Missing" -> 0|>]];
  title = With[{t = Lookup[SlideTalkMeta[nb], "Title", ""]},
    If[StringQ[t] && StringTrim[t] =!= "", t, Last[iSWDeckBaseName[nb]]]];
  meta = iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb] <> iSWStoryBlock[nb];
  batches = Partition[missing, UpTo[$iSWTalkFillBatch]];
  $iSWTalkFillRun = <|"Written" -> 0, "Failed" -> 0, "Busy" -> True, "Since" -> AbsoluteTime[]|>;
  iSWTalkFillChain[nb, <|"Title" -> title, "Slides" -> slides, "Meta" -> meta, "Batches" -> batches|>, 1];
  <|"Status" -> "Submitted", "Missing" -> Length[missing], "Batches" -> Length[batches]|>];

$iSWTalkFillRun = <|"Busy" -> False|>;
iSWTalkFillBusyQ[] := TrueQ[Lookup[$iSWTalkFillRun, "Busy", False]] &&
  AbsoluteTime[] - Lookup[$iSWTalkFillRun, "Since", 0] < 1200;

iSWTalkFillChain[nb_, ctx_Association, idx_Integer] := If[idx > Length[ctx["Batches"]],
  $iSWTalkFillRun["Busy"] = False;
  iSWGraphApplyNote[nb, iSL["\:539f\:7a3f\:3092 " <> ToString[$iSWTalkFillRun["Written"]] <> " \:679a\:306b\:66f8\:304d\:307e\:3057\:305f" <>
      If[$iSWTalkFillRun["Failed"] > 0, " (\:66f8\:3051\:306a\:304b\:3063\:305f\:679a " <> ToString[$iSWTalkFillRun["Failed"]] <> ")", ""] <>
      "\:3002\:5185\:5bb9\:3092\:78ba\:304b\:3081\:3066\:304b\:3089\:300c\:767b\:9332\:300d\:3057\:3066\:304f\:3060\:3055\:3044",
    "Wrote talks for " <> ToString[$iSWTalkFillRun["Written"]] <> " slides" <>
      If[$iSWTalkFillRun["Failed"] > 0, " (" <> ToString[$iSWTalkFillRun["Failed"]] <> " failed)", ""] <> ". Review, then Register."]],
  Module[{targets = ctx["Batches"][[idx]], prompt},
    $iSWTalkFillRun["Since"] = AbsoluteTime[];
    iSWStatus[nb, iSL["\:539f\:7a3f\:3092\:66f8\:3044\:3066\:3044\:307e\:3059 " <> ToString[idx] <> "/" <> ToString[Length[ctx["Batches"]]] <> "\:2026",
      "Writing talks " <> ToString[idx] <> "/" <> ToString[Length[ctx["Batches"]]] <> "..."]];
    prompt = iSWTalkFillPrompt[ctx["Title"], ctx["Slides"], targets, ctx["Meta"]];
    With[{n2 = nb, c = ctx, i2 = idx, nums = Lookup[targets, "Slide"]},
      NBAccess`$NBLLMQueryFunc[prompt,
        Function[resp, Module[{talks = iSWTalkFillParse[resp, nums]},
          (* \:5f8c\:308d\:306e\:679a\:304b\:3089\:66f8\:304f (\:524d\:306e\:679a\:306e\:30bb\:30eb\:4f4d\:7f6e\:304c\:305a\:308c\:306a\:3044) *)
          Do[If[KeyExistsQ[talks, k] && iSWTalkWriteCell[n2, k, talks[k]] =!= $Failed,
              $iSWTalkFillRun["Written"] = $iSWTalkFillRun["Written"] + 1,
              $iSWTalkFillRun["Failed"] = $iSWTalkFillRun["Failed"] + 1],
            {k, Reverse[nums]}];
          iSWTalkFillChain[n2, c, i2 + 1]]],
        n2, Fallback -> iSWFallback[]]]]];

iSWTalkFillAction[nb_] := SlideTalkFill[nb];

(* QA\:751f\:6210: KG \:304b\:3089\:4f5c\:3063\:305f\:679a\:306e\:300c\:5143\:306e\:8cc7\:6599\:300d(\:30ce\:30fc\:30c9\:306e\:672c\:6587\:3002\:7121\:3051\:308c\:3070\:89aa\:306e\:7bc0\:306e\:7b4b\:66f8\:304d\:3001\:8981\:7d04) \:3068\:51fa\:5178 *)
iSWQAKGSources[nb_NotebookObject] := Module[{none = <|"Graph" -> None, "Sources" -> <||>, "PL" -> None|>, rows, gid, kg, index, parent,
    src = <||>},
  rows = Quiet @ Check[iSWKGDeckSlideNodes[nb], {}];
  If[! ListQ[rows] || ! AnyTrue[rows, StringQ[Lookup[#, "Node", None]] &], Return[none]];
  gid = Quiet @ Check[SlideGraphSpec[nb]["Graph"], None];
  kg = If[StringQ[gid], iSWKGResolve[gid], $Failed];
  If[! AssociationQ[kg], Return[none]];
  index = Association[(#["Id"] -> #) & /@ kg["Nodes"]];
  parent = Association[Map[#["To"] -> #["From"] &, Select[kg["Edges"], #["EdgeKind"] === "Contains" &]]];
  Do[With[{id = Lookup[r, "Node", None]},
      If[StringQ[id] && KeyExistsQ[index, id], src[r["Slide"]] = iSWQANodeSource[index, parent, id]]],
    {r, rows}];
  <|"Graph" -> gid, "Sources" -> Select[src, StringQ[#] && # =!= "" &], "PL" -> iSWRefinePrivacy[nb, kg]|>];
iSWQANodeSource[index_Association, parent_Association, id_String] := Module[{n = index[id], txt, cite},
  txt = Replace[Lookup[n, "Text", ""], Except[_String] -> ""];
  If[StringTrim[txt] === "" && KeyExistsQ[index, Lookup[parent, id, None]],
    txt = Replace[Lookup[index[parent[id]], "Text", ""], Except[_String] -> ""]];
  If[StringTrim[txt] === "", txt = SourceVault`SourceVaultKGText[n, "Summary"]];
  If[! StringQ[txt], txt = ""];
  cite = SourceVault`SourceVaultKGText[n, "Cite"];
  StringTrim[StringTake[txt, UpTo[2000]] <> If[StringQ[cite] && cite =!= "", "\n(\:51fa\:5178: " <> cite <> ")", ""]]];

(* ===================== v1.30: \:30b7\:30ca\:30ea\:30aa\:304b\:3089\:77e5\:8b58\:30b0\:30e9\:30d5 (\:6587\:66f8\:304c\:7121\:3044\:3068\:304d) =====================
   \:6587\:732e\:6b04\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:7121\:3051\:308c\:3070\:3001\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:306b\:66f8\:3044\:305f\:7b4b\:66f8\:304d (\:30b7\:30ca\:30ea\:30aa) \:304b\:3089 KG \:3092\:4f5c\:308b:
   1. seed (\:6c7a\:5b9a\:7684): \:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:3092\:90e8 (\:7bc0) \:306b\:5206\:3051\:3001\:7bc0\:3054\:3068\:306b\:300c\:7b4b\:66f8\:304d\:300d\:30ce\:30fc\:30c9 (\:672c\:6587 = \:7b4b\:66f8\:304d\:3001\:8981\:70b9\:306a\:3057) \:3092\:7f6e\:304f
   2. \:95a2\:9023\:7814\:7a76 (\:975e\:540c\:671f): LLM \:304c\:7b4b\:66f8\:304d\:304b\:3089\:691c\:7d22\:8a9e\:3092\:51fa\:3057\:3001SourceVault \:306e\:6a2a\:65ad\:691c\:7d22 (\:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e\:8ad6\:6587\:30fbEagle) \:3067\:5019\:88dc\:3092\:96c6\:3081\:308b\:3002
      Story \:306e Survey: web \:306e\:3068\:304d\:3060\:3051 Web \:691c\:7d22\:3082\:4f7f\:3046 (\:691c\:7d22\:8a9e\:304c\:5916\:306b\:51fa\:308b\:306e\:3067\:3001\:66f8\:3044\:305f\:3068\:304d\:3060\:3051)\:3002
      \:516c\:958b\:3067\:304d\:306a\:3044\:5019\:88dc (PrivacyLevel >= 0.5) \:306f\:30c7\:30c3\:30ad\:306e PrivacyLevel \:304c\:305d\:308c\:4ee5\:4e0a\:306e\:3068\:304d\:3060\:3051\:4f7f\:3046
   3. \:5c55\:958b (\:63a8\:6572\:306e\:9023\:9396): \:7bc0\:3054\:3068\:306b\:7b4b\:66f8\:304d + \:5019\:88dc \:2192 \:767a\:8868\:7528\:306e\:30ce\:30fc\:30c9 (<\:7bc0>_1.. / \:95a2\:9023\:7814\:7a76 rw_<\:5019\:88dc\:756a\:53f7> / \:524d\:63d0 bg_\:2026)
   \:4ee5\:5f8c\:306f\:8ad6\:6587\:3068\:540c\:3058 (\:5468\:8fba\:77e5\:8b58 \:2192 \:56f3\:89e3 \:2192 \:8abf\:6574 \:2192 \:8a08\:753b \:2192 \:751f\:6210)\:3002\:9014\:4e2d\:3067\:6b62\:307e\:3063\:3066\:3082\:300c\:63a8\:6572\:300d\:3067\:7d9a\:304d\:304b\:3089\:5c55\:958b\:3059\:308b *)
$iSWPromptHintPrefixes := {StringTake[iSWPromptHintText["ja"], 12], StringTake[iSWPromptHintText["en"], 20]};
iSWPromptHintText["ja"] := "\:3053\:3053\:306b\:3053\:306e\:30b9\:30e9\:30a4\:30c9\:3067\:4f1d\:3048\:305f\:3044\:5185\:5bb9(\:30d7\:30ed\:30f3\:30d7\:30c8)\:3092\:66f8\:304d\:3001\:300c\:5c55\:958b\:300d\:3092\:62bc\:3059\:3002";
iSWPromptHintText["en"] := "Write the prompt for this slide here and press Expand.";
iSWScenarioHintQ[s_String] := AnyTrue[$iSWPromptHintPrefixes, StringStartsQ[StringTrim[s], #] &];

iSWScenarioTitleOf[s_String] := Module[{l = StringTrim[First[StringSplit[s, "\n"], ""]]},
  l = StringTrim[StringReplace[l, RegularExpression["^([-*\:30fb\:2022]|\\d+[.)\:ff0e\:3001])\\s*"] -> ""]];
  l = First[StringSplit[l, "\:3002" | ". " | "\:ff1a" | ": "], l];
  If[StringLength[l] > 40, StringTake[l, 39] <> "\:2026", l]];

(* 1 \:3064\:306e\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb\:3092\:90e8\:306b\:5206\:3051\:308b: \:898b\:51fa\:3057 (#) > \:884c\:982d\:306e\:756a\:53f7 (1. 2.) > \:7a7a\:884c\:3067\:533a\:5207\:3063\:305f\:584a > \:5168\:4f53\:3067 1 \:90e8 *)
iSWScenarioSplit[text_String] := Module[{t = StringTrim[StringReplace[text, "\r\n" -> "\n"]], lines, heads, blocks, mk},
  If[t === "", Return[{}]];
  lines = StringSplit[t, "\n", All];
  mk[hs_, titleFn_] := Module[{bounds = MapThread[{#1, #2} &, {hs, Append[Rest[hs] - 1, Length[lines]]}], pre, out},
    out = Map[Function[b, <|"Title" -> titleFn[lines[[b[[1]]]]],
        "Text" -> StringTrim[StringRiffle[lines[[b[[1]] ;; b[[2]]]], "\n"]]|>], bounds];
    pre = StringTrim[StringRiffle[lines[[1 ;; First[hs] - 1]], "\n"]];
    If[pre =!= "", Prepend[out, <|"Title" -> iSWScenarioTitleOf[pre], "Text" -> pre|>], out]];
  heads = Flatten[Position[lines, l_String /; StringMatchQ[l, RegularExpression["\\s*#{1,4}\\s+\\S.*"]], {1}, Heads -> False]];
  If[heads =!= {},
    Return[mk[heads, iSWScenarioTitleOf[StringReplace[#, RegularExpression["^\\s*#+\\s*"] -> ""]] &]]];
  heads = Flatten[Position[lines, l_String /; StringMatchQ[l, RegularExpression["\\d{1,2}[.)\:ff0e\:3001]\\s*\\S.*"]], {1}, Heads -> False]];
  If[Length[heads] >= 2, Return[mk[heads, iSWScenarioTitleOf]]];
  blocks = Select[StringTrim /@ StringSplit[t, RegularExpression["\\n\\s*\\n"]], # =!= "" &];
  Map[<|"Title" -> iSWScenarioTitleOf[#], "Text" -> #|> &, blocks]];

(* \:30c7\:30c3\:30ad\:306e\:30d7\:30ed\:30f3\:30d7\:30c8\:30bb\:30eb (\:524d\:7f6e\:304d\:30fb\:5404\:30b9\:30e9\:30a4\:30c9\:3001\:6587\:66f8\:306e\:9806) \:3092\:90e8\:306e\:4e26\:3073\:306b\:3059\:308b\:3002\:96db\:5f62\:306e\:307e\:307e\:306e\:30bb\:30eb\:306f\:8aad\:307e\:306a\:3044 *)
iSWScenarioParts[src_] := Module[{texts = iSWStyleTexts[src, "SlidePrompt"]},
  If[! ListQ[texts], texts = {}];
  Flatten[iSWScenarioSplit /@ Select[texts, StringQ[#] && StringTrim[#] =!= "" && ! iSWScenarioHintQ[#] &]]];

Options[SlideGraphSeedScenario] = {"Graph" -> Automatic, "Title" -> Automatic, "Language" -> Automatic, "Save" -> True,
  "Keep" -> "Background"};
SlideGraphSeedScenario[src_, OptionsPattern[]] := Module[{spec, parts, gid, title, lang, nodes, edges = {}, kg, prev, keep, res},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  spec = Which[
    Head[src] === NotebookObject || Head[src] === Notebook || (StringQ[src] && FileExistsQ[src]), SlideGraphSpec[src],
    True, $iSWStoryDefaults];
  parts = If[ListQ[src], src, iSWScenarioParts[src]];
  parts = Select[parts, AssociationQ[#] && StringQ[Lookup[#, "Text", None]] && StringTrim[#["Text"]] =!= "" &];
  If[parts === {},
    Return[Failure["NoScenario", <|"MessageTemplate" ->
      "no scenario: write the outline of the talk in prompt cells (Insert > Prompt), or add a translated paper notebook to References"|>]]];
  gid = Replace[OptionValue["Graph"], Automatic -> Lookup[spec, "Graph", None]];
  If[! StringQ[gid] || gid === "", gid = iSWKGDefaultGraphId[Lookup[spec, "Title", ""]]];
  title = Replace[OptionValue["Title"], Automatic -> Lookup[spec, "Title", ""]];
  If[! StringQ[title] || StringTrim[title] === "", title = Lookup[First[parts], "Title", gid]];
  lang = iSWKGLangCode[Replace[OptionValue["Language"], Automatic -> Lookup[spec, "Language", "ja"]]];
  nodes = {<|"Id" -> "root", "Kind" -> "Claim", "Label" -> title, "Summary" -> "", "Points" -> {},
    "Importance" -> 1., "Difficulty" -> 0.3, "Order" -> 0, "Layer" -> "Paper",
    "Text" -> StringRiffle[Lookup[parts, "Title", ""], " / "], "Source" -> <|"Kind" -> "Scenario"|>|>};
  Do[
    With[{p = parts[[i]], sid = "sc" <> ToString[i]},
      AppendTo[nodes, <|"Id" -> sid, "Kind" -> "Section",
        "Label" -> If[StringQ[p["Title"]] && p["Title"] =!= "", p["Title"], iSWScenarioTitleOf[p["Text"]]],
        "Summary" -> "", "Points" -> {}, "Importance" -> 0.9, "Difficulty" -> 0.4, "Order" -> i, "Layer" -> "Paper",
        "Text" -> p["Text"], "Source" -> <|"Kind" -> "Scenario", "Part" -> i|>|>];
      AppendTo[nodes, <|"Id" -> sid <> "_d", "Kind" -> "Concept", "Label" -> iSWSeedLabel[p["Text"]],
        "Summary" -> "", "Points" -> {}, "Importance" -> 0.8, "Difficulty" -> 0.4, "Order" -> i + 0.5, "Layer" -> "Paper",
        "Text" -> p["Text"], "Source" -> <|"Kind" -> "Scenario", "Part" -> i, "Draft" -> True|>|>];
      AppendTo[edges, <|"From" -> "root", "To" -> sid, "EdgeKind" -> "Contains", "Weight" -> 0.9|>];
      AppendTo[edges, <|"From" -> sid, "To" -> sid <> "_d", "EdgeKind" -> "Contains", "Weight" -> 0.9|>];
      If[i > 1, AppendTo[edges, <|"From" -> "sc" <> ToString[i - 1], "To" -> sid, "EdgeKind" -> "Precedes", "Weight" -> 0.6|>]]],
    {i, Length[parts]}];
  kg = SourceVault`SourceVaultKGFromJSON[<|"GraphId" -> gid, "Title" -> title, "Language" -> lang, "Kind" -> "Scenario",
    "Root" -> "root", "Sources" -> {<|"Key" -> "scenario", "Kind" -> "Scenario"|>}, "Nodes" -> nodes, "Edges" -> edges|>];
  If[! AssociationQ[kg], Return[kg]];
  kg["Seed"] = True;
  (* \:4f5c\:308a\:76f4\:3057: \:5468\:8fba\:77e5\:8b58 (Background \:5c64) \:3068\:305d\:306e\:8fba\:3060\:3051\:6b8b\:3059 *)
  If[OptionValue["Keep"] =!= None,
    prev = Quiet @ Check[SourceVault`SourceVaultKGLoad[gid], $Failed];
    If[AssociationQ[prev],
      keep = Select[Lookup[prev, "Nodes", {}], AssociationQ[#] && Lookup[#, "Layer", "Paper"] =!= "Paper" &];
      If[keep =!= {},
        With[{ids = Join[Lookup[keep, "Id"], Lookup[nodes, "Id"]]},
          res = SourceVault`SourceVaultKGMerge[kg, <|"Nodes" -> keep,
            "Edges" -> Select[Lookup[prev, "Edges", {}], AssociationQ[#] && MemberQ[ids, #["From"]] && MemberQ[ids, #["To"]] &&
              (MemberQ[Lookup[keep, "Id"], #["From"]] || MemberQ[Lookup[keep, "Id"], #["To"]]) &]|>]];
        If[AssociationQ[res] && KeyExistsQ[res, "Nodes"], kg = res; kg["Seed"] = True]]]];
  If[TrueQ[OptionValue["Save"]],
    res = SourceVault`SourceVaultKGSave[kg];
    If[! StringQ[res], Return[Failure["SaveFailed", <|"MessageTemplate" -> "could not save `1`", "MessageParameters" -> {gid}|>]]]];
  <|"Graph" -> gid, "Title" -> title, "Parts" -> Length[parts], "NodeCount" -> Length[kg["Nodes"]], "KG" -> kg|>];

(* ---- \:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc ---- *)
iSWSurveyMode[v_] := With[{s = ToLowerCase[StringTrim[ToString[v]]]},
  Which[
    s === "" || s === "none" || s === "automatic", "Local",
    StringContainsQ[s, "off" | "\:306a\:3057" | "\:7121\:3057" | "\:3057\:306a\:3044" | "no"], "Off",
    StringContainsQ[s, "web" | "\:30a6\:30a7\:30d6" | "all" | "\:5168\:90e8"], "Web",
    True, "Local"]];

iSWRelatedYear[r_Association] := Module[{d = ToString[Lookup[r, "Published", Lookup[r, "Date", ""]]], m},
  m = StringCases[d, RegularExpression["(19|20)\\d\\d"]];
  If[m === {}, "", First[m]]];

iSWRelatedAuthors[a_] := Module[{s = Which[StringQ[a], a, ListQ[a], StringRiffle[Select[a, StringQ], ", "], True, ""], parts},
  parts = StringTrim /@ StringSplit[s, "," | ";" | "\:3001" | " and "];
  Which[parts === {} || parts === {""}, "", Length[parts] > 2, First[parts] <> " et al.", True, StringRiffle[parts, ", "]]];

iSWRelatedRow[r_Association, q_String] := Module[{uri = Lookup[r, "URI", None], id = Lookup[r, "Id", None], url = Lookup[r, "URL", None], pl},
  pl = Lookup[r, "PrivacyLevel", 1.];
  <|"Key" -> FirstCase[{uri, id, url}, s_String /; s =!= "", ""],
    "Kind" -> ToString[Lookup[r, "Kind", ""]], "Id" -> If[StringQ[id], id, ""], "URI" -> If[StringQ[uri], uri, ""],
    "URL" -> If[StringQ[url], url, ""],
    "Title" -> StringTake[StringTrim[StringReplace[ToString[Lookup[r, "Title", ""]], RegularExpression["(?i)\\.(pdf|docx?|pptx?|txt|md)$"] -> ""]], UpTo[160]],
    "Authors" -> iSWRelatedAuthors[Lookup[r, "Authors", ""]], "Year" -> iSWRelatedYear[r],
    "Summary" -> StringTake[StringReplace[StringTrim[ToString[Lookup[r, "Summary", ""]]], "\n" -> " "], UpTo[300]],
    "PrivacyLevel" -> If[NumericQ[pl], N[pl], 1.], "Queries" -> {q}|>];

iSWRelatedSearchLocal[q_String] := If[Length[DownValues[SourceVault`SourceVaultSummaries]] === 0, {},
  With[{rows = Quiet @ Check[SourceVault`SourceVaultSummaries[q, "Providers" -> {"sources", "eagle"}, "Limit" -> 6], {}]},
    If[ListQ[rows], Map[iSWRelatedRow[#, q] &, Select[rows, AssociationQ]], {}]]];

iSWRelatedSearchWeb[q_String] := If[Length[DownValues[SourceVault`SourceVaultWebSearch]] === 0, {},
  With[{run = Quiet @ Check[SourceVault`SourceVaultWebSearch[q, "MaxResults" -> 5], $Failed]},
    If[! AssociationQ[run], {},
      Map[<|"Key" -> Lookup[#, "Url", ""], "Kind" -> "web", "Id" -> "", "URI" -> "", "URL" -> Lookup[#, "Url", ""],
          "Title" -> StringTake[StringTrim[ToString[Lookup[#, "Title", ""]]], UpTo[160]], "Authors" -> "", "Year" -> "",
          "Summary" -> StringTake[StringTrim[ToString[Lookup[#, "Snippet", ""]]], UpTo[300]],
          "PrivacyLevel" -> 0., "Queries" -> {q}|> &,
        Select[Replace[Lookup[run, "Results", {}], Except[_List] -> {}], AssociationQ[#] && StringQ[Lookup[#, "Url", None]] && #["Url"] =!= "" &]]]]];

(* \:540c\:3058\:6587\:732e\:3092 1 \:3064\:306b\:307e\:3068\:3081\:3001\:591a\:304f\:306e\:691c\:7d22\:8a9e\:306b\:5f53\:305f\:3063\:305f\:3082\:306e\:304b\:3089\:4e26\:3079\:308b\:3002\:516c\:958b\:3067\:304d\:306a\:3044\:5019\:88dc\:306f deckPL \:304c\:8a31\:3059\:3068\:304d\:3060\:3051 *)
iSWRelatedMerge[rows_List, maxC_Integer, deckPL_] := Module[{groups, merged, allowed},
  groups = GroupBy[Select[rows, AssociationQ[#] && #["Key"] =!= "" &], #["Key"] &];
  merged = KeyValueMap[Function[{k, rs}, Append[First[rs], "Queries" -> DeleteDuplicates[Flatten[Lookup[rs, "Queries", {}]]]]], groups];
  allowed = Select[merged, #["PrivacyLevel"] < 0.5 || (NumericQ[deckPL] && #["PrivacyLevel"] <= deckPL) &];
  (* \:5f53\:305f\:3063\:305f\:691c\:7d22\:8a9e\:306e\:591a\:3044\:9806\:3002\:540c\:6570\:306a\:3089\:898b\:3064\:304b\:3063\:305f\:9806 *)
  allowed = MapIndexed[Append[#1, "Pos" -> First[#2]] &, allowed];
  <|"Candidates" -> (KeyDrop[#, "Pos"] & /@ Take[SortBy[allowed, {-Length[#["Queries"]] &, #["Pos"] &}], UpTo[Max[0, maxC]]]),
    "Excluded" -> Length[merged] - Length[allowed]|>];

iSWRelatedCite[r_Association] := StringTrim[
  r["Title"] <> If[r["Authors"] =!= "" || r["Year"] =!= "",
    " (" <> StringRiffle[Select[{r["Authors"], r["Year"]}, # =!= "" &], ", "] <> ")", ""] <>
  With[{loc = FirstCase[{r["URL"], r["URI"], r["Id"]}, s_String /; s =!= "", ""]}, If[loc === "", "", " " <> loc]]];

iSWRelatedQueryPrompt[kg_Association, spec_Association, metaBlocks_String] := Module[{secs},
  secs = Select[kg["Nodes"], Lookup[#, "Kind", ""] === "Section" &];
  metaBlocks <>
  "\:767a\:8868\:306e\:7b4b\:66f8\:304d (\:30b7\:30ca\:30ea\:30aa) \:304b\:3089\:3001\:95a2\:9023\:7814\:7a76\:3068\:524d\:63d0\:77e5\:8b58\:3092\:63a2\:3059\:691c\:7d22\:8a9e\:3092\:4f5c\:308b\:3002\:691c\:7d22\:306f\:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e\:6587\:732e\:306e\:984c\:76ee\:30fb\:8981\:7d04\:3078\:306e\:90e8\:5206\:4e00\:81f4\:306a\:306e\:3067\:3001" <>
  "\:6587\:3067\:306f\:306a\:304f 1\:301c3 \:8a9e\:306e\:77ed\:3044\:8a9e\:53e5\:306b\:3059\:308b\:3002\:7b4b\:66f8\:304d\:306e\:4e2d\:5fc3\:306e\:624b\:6cd5\:540d\:30fb\:73fe\:8c61\:540d\:30fb\:5206\:91ce\:540d\:3092\:512a\:5148\:3057\:3001\:65e5\:672c\:8a9e\:3068\:82f1\:8a9e\:306e\:4e21\:65b9\:3092\:542b\:3081\:308b\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <>
  If[StringQ[spec["Story"]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "=== \:7b4b\:66f8\:304d ===\n" <>
  StringTake[StringRiffle[Map["[" <> #["Id"] <> "] " <> SourceVault`SourceVaultKGText[#, "Label"] <> "\n" <>
    StringTake[Replace[Lookup[#, "Text", ""], Except[_String] -> ""], UpTo[1500]] &, secs], "\n\n"], UpTo[9000]] <>
  "\n\n\:51fa\:529b (\:53b3\:5b88): JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3002\:8aac\:660e\:6587\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:7121\:3057:\n{\"Queries\": [\"\:8a9e\:53e5\", \"\:8a9e\:53e5\"]}  (4\:301c8 \:500b)"];

iSWRelatedQueries[resp_] := Module[{json, d, qs},
  json = If[StringQ[resp] && ! StringStartsQ[resp, "Error" | "[ERROR]"], iSWRefineExtractJSON[resp], $Failed];
  d = If[StringQ[json], Quiet @ Check[Developer`ReadRawJSONString[json], $Failed], $Failed];
  qs = If[AssociationQ[d], Replace[Lookup[d, "Queries", {}], Except[_List] -> {}], {}];
  Take[DeleteDuplicates[Select[StringTrim /@ Select[qs, StringQ], 1 <= StringLength[#] <= 40 &]], UpTo[10]]];

Options[SlideGraphRelated] = {"Web" -> Automatic, "MaxCandidates" -> 20, "Then" -> None, "Audience" -> Automatic,
  "Story" -> Automatic, "PrivacyLevel" -> Automatic};
SlideGraphRelated[opts : OptionsPattern[]] := With[{nb = iSWNotebook[]}, If[nb === $Failed, $Failed, SlideGraphRelated[nb, opts]]];
SlideGraphRelated[nb_NotebookObject, opts : OptionsPattern[]] := Module[{spec = SlideGraphSpec[nb], kg},
  kg = iSWKGResolve[spec["Graph"]];
  If[! AssociationQ[kg], iSWStatus[nb, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; Return[kg]];
  iSWRelatedRun[nb, spec, kg,
    Replace[OptionValue["Web"], Automatic :> (iSWSurveyMode[Lookup[spec, "Survey", ""]] === "Web")],
    OptionValue["MaxCandidates"], OptionValue["Then"], iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb],
    Replace[OptionValue["PrivacyLevel"], Automatic :> iSWRefinePrivacy[nb, kg]]]];
SlideGraphRelated[graphId_String, opts : OptionsPattern[]] := Module[{kg = iSWKGResolve[graphId], spec},
  If[! AssociationQ[kg], Return[kg]];
  spec = Join[$iSWStoryDefaults, <|"Graph" -> Lookup[kg, "GraphId", graphId], "Title" -> Lookup[kg, "Title", ""]|>];
  If[OptionValue["Audience"] =!= Automatic, spec["Audience"] = OptionValue["Audience"]];
  If[StringQ[OptionValue["Story"]], spec["Story"] = OptionValue["Story"]];
  iSWRelatedRun[None, spec, kg, TrueQ[OptionValue["Web"]], OptionValue["MaxCandidates"], OptionValue["Then"], "",
    Replace[OptionValue["PrivacyLevel"], Automatic :> iSWRefinePrivacy[None, kg]]]];

iSWRelatedRun[nb_, spec_Association, kg_Association, web_, maxC_, then_, metaBlocks_String, pl_] := Module[{gid = spec["Graph"]},
  If[! iSWLLMReadyQ[], Return[Failure["NoLLM", <|"MessageTemplate" -> "LLM query function is not registered (load NBAccess/claudecode)"|>]]];
  If[iSWRefineBusyQ[],
    iSWStatusIf[nb, iSL["KG \:306e\:63a8\:6572\:30fb\:56f3\:89e3\:30fb\:8abf\:6574\:3092\:5b9f\:884c\:4e2d\:3067\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044", "A KG run is in progress"]];
    Return[<|"Status" -> "Busy", "Graph" -> gid|>]];
  iSWStatusIf[nb, iSL["\:95a2\:9023\:7814\:7a76: \:7b4b\:66f8\:304d\:304b\:3089\:691c\:7d22\:8a9e\:3092\:4f5c\:3063\:3066\:3044\:307e\:3059\:2026", "Related work: drafting search terms from the scenario..."]];
  $iSWRefineBusy = True; $iSWRefineBusySince = AbsoluteTime[];
  With[{n2 = nb, g = gid, w = TrueQ[web], m = If[IntegerQ[maxC], maxC, 20], th = then, p = pl},
    NBAccess`$NBLLMQueryFunc[iSWRelatedQueryPrompt[kg, spec, metaBlocks],
      Function[resp, iSWRelatedApply[n2, g, resp, w, m, th, p]],
      n2, Fallback -> iSWFallback[], PrivacyLevel -> pl]];
  <|"Status" -> "Submitted", "Graph" -> gid, "Web" -> TrueQ[web]|>];

$iSWRelatedLast = None;
iSWRelatedApply[nb_, gid_String, resp_, web_, maxC_Integer, then_, pl_] := Module[{qs, rows = {}, merged, kg, saved},
  $iSWRefineBusy = False;
  qs = iSWRelatedQueries[resp];
  Do[
    iSWStatusIf[nb, iSL["\:95a2\:9023\:7814\:7a76\:3092\:691c\:7d22\:4e2d (" <> ToString[i] <> "/" <> ToString[Length[qs]] <> ": " <> qs[[i]] <> ")\:2026",
      "Searching related work (" <> ToString[i] <> "/" <> ToString[Length[qs]] <> ": " <> qs[[i]] <> ")..."]];
    rows = Join[rows, iSWRelatedSearchLocal[qs[[i]]]];
    If[TrueQ[web], rows = Join[rows, iSWRelatedSearchWeb[qs[[i]]]]],
    {i, Length[qs]}];
  merged = iSWRelatedMerge[rows, maxC, pl];
  kg = iSWKGResolve[gid];
  saved = AssociationQ[kg] && StringQ[Quiet @ SourceVault`SourceVaultKGSave[
    Join[kg, <|"Related" -> merged["Candidates"], "RelatedQueries" -> qs, "RelatedWeb" -> TrueQ[web],
      "RelatedAtUTC" -> DateString[DateObject[Now, TimeZone -> 0], "ISODateTime"] <> "Z"|>]]];
  $iSWRelatedLast = <|"Status" -> If[saved, "Saved", "SaveFailed"], "Queries" -> qs, "Candidates" -> Length[merged["Candidates"]],
    "Excluded" -> merged["Excluded"], "Web" -> TrueQ[web]|>;
  iSWStatusIf[nb, iSL["\:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc " <> ToString[Length[merged["Candidates"]]] <> " \:4ef6" <>
      If[merged["Excluded"] > 0, " (\:975e\:516c\:958b\:306e\:305f\:3081\:9664\:5916 " <> ToString[merged["Excluded"]] <> ")", ""] <>
      If[qs === {}, " (\:691c\:7d22\:8a9e\:3092\:4f5c\:308c\:307e\:305b\:3093\:3067\:3057\:305f)", " / \:691c\:7d22\:8a9e: " <> StringRiffle[Take[qs, UpTo[6]], ", "]] <>
      If[then =!= None, "\:3002\:7d9a\:3051\:3066\:5c55\:958b\:3057\:307e\:3059", ""],
    ToString[Length[merged["Candidates"]]] <> " related-work candidates" <>
      If[merged["Excluded"] > 0, " (" <> ToString[merged["Excluded"]] <> " non-public excluded)", ""] <>
      If[then =!= None, "; expanding the scenario next", ""]]];
  If[then =!= None, Quiet[then[]]];
  $iSWRelatedLast];

(* ---- \:5c55\:958b (\:63a8\:6572\:306e\:9023\:9396\:306e Scenario \:56de) ---- *)
iSWRelatedListText[related_List] := If[related === {}, "(\:5019\:88dc\:306a\:3057\:3002\:7b4b\:66f8\:304d\:3068\:4e00\:822c\:7684\:306a\:77e5\:8b58\:3060\:3051\:3067\:66f8\:304f)",
  StringRiffle[MapIndexed[Function[{r, i}, ToString[First[i]] <> ". " <> r["Title"] <>
    With[{m = StringRiffle[Select[{r["Authors"], r["Year"], r["Kind"]}, # =!= "" &], " / "]}, If[m === "", "", " / " <> m]] <>
    If[r["Summary"] === "", "", "\n   " <> StringTake[r["Summary"], UpTo[200]]]], related], "\n"]];

iSWRefineScenarioPrompt[spec_Association, gid_String, sectionIds_List, metaBlocks_String] := Module[
  {kg = iSWKGResolve[gid], index, secs, related},
  index = If[AssociationQ[kg], Association[(#["Id"] -> #) & /@ kg["Nodes"]], <||>];
  secs = SortBy[Select[Values[index], Lookup[#, "Kind", ""] === "Section" &], Lookup[#, "Order", 0] &];
  related = If[AssociationQ[kg], Replace[Lookup[kg, "Related", {}], Except[_List] -> {}], {}];
  metaBlocks <>
  "SlideWorkflow \:306e\:77e5\:8b58\:30b0\:30e9\:30d5\:4f5c\:6210 (\:30b7\:30ca\:30ea\:30aa\:304b\:3089)\:3002\:5229\:7528\:8005\:304c\:66f8\:3044\:305f\:767a\:8868\:306e\:7b4b\:66f8\:304d (\:30b7\:30ca\:30ea\:30aa) \:3092\:3001\:767a\:8868\:7528\:306e\:77e5\:8b58\:30b0\:30e9\:30d5 (KG) \:306b\:5c55\:958b\:3059\:308b\:3002" <>
  "\:5143\:306b\:306a\:308b\:8ad6\:6587\:306f\:7121\:3044\:3002\:7b4b\:66f8\:304d\:306e\:610f\:56f3\:3068\:9806\:5e8f\:3092\:4fdd\:3061\:3001\:8074\:304d\:624b\:306b\:5408\:308f\:305b\:3066\:5177\:4f53\:5316\:3059\:308b\:3002\:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc\:304c\:4ed8\:3044\:3066\:3044\:308c\:3070\:3001\:7b4b\:66f8\:304d\:306b\:95a2\:4fc2\:3059\:308b\:3082\:306e\:3092\:5f15\:7528\:3057\:3066\:7d39\:4ecb\:3059\:308b\:3002\n" <>
  "\:8074\:304d\:624b: " <> ToString[spec["Audience"]] <>
  If[StringQ[spec["Story"]] && spec["Story"] =!= "", "\n\:30b9\:30c8\:30fc\:30ea\:30fc\:6307\:793a: " <> spec["Story"], ""] <> "\n\n" <>
  "\:5168\:4f53\:306e\:7b4b\:66f8\:304d (\:4f4d\:7f6e\:3092\:628a\:63e1\:3059\:308b\:305f\:3081\:3002\:3053\:3053\:306b\:7121\:3044\:7bc0\:306f\:4f5c\:3089\:306a\:3044):\n" <>
  StringRiffle[Map["  [" <> #["Id"] <> "] " <> SourceVault`SourceVaultKGText[#, "Label"] &, secs], "\n"] <> "\n\n" <>
  "\:51fa\:529b (\:53b3\:5b88): \:6b21\:306e\:5f62\:306e JSON \:30aa\:30d6\:30b8\:30a7\:30af\:30c8 1 \:3064\:3060\:3051\:3002\:8aac\:660e\:6587\:30fb\:30b3\:30fc\:30c9\:30d5\:30a7\:30f3\:30b9\:306f\:4ed8\:3051\:306a\:3044\:3002\n" <>
  "{\"Nodes\": [{\"Id\": \"<\:7bc0 Id>\", \"Label\": \"\:7bc0\:306e\:77ed\:3044\:984c\:76ee\", \"Summary\": \"\:3067\:3059\:30fb\:307e\:3059\:8abf 1-2 \:6587\"},\n" <>
  " {\"Id\": \"<\:7bc0 Id>_1\", \"Kind\": \"Concept|Definition|Method|Experiment|Result|Example|Question|Conclusion\", \"Label\": \"\:4f53\:8a00\:6b62\:3081\:306e\:77ed\:3044\:984c\:76ee\", " <>
  "\"Lead\": \"\:3053\:306e\:679a\:3067\:8a00\:3044\:305f\:3044\:3053\:3068 1 \:6587 (40 \:5b57\:4ee5\:5185)\", \"Points\": [\"\:4f53\:8a00\:6b62\:3081 2-4 \:884c\"], \"Details\": [\"\:5404 Point \:306e\:88dc\:8db3 1 \:884c (\:4e0d\:8981\:306a\:3089 \\\"\\\")\"], " <>
  "\"Talk\": \"\:767a\:8868\:539f\:7a3f: Points \:3068\:540c\:3058\:9806\:306b 1 \:8981\:70b9 1\:301c2 \:6587\:306e\:3067\:3059\:30fb\:307e\:3059\:8abf\", \"Importance\": 0-1, \"Difficulty\": 0-1, \"Domains\": [\"\:9818\:57df\"], \"Ref\": [\:5019\:88dc\:756a\:53f7]},\n" <>
  " {\"Id\": \"rw_<\:5019\:88dc\:756a\:53f7>\", \"Parent\": \"<\:7bc0 Id>\", \"Label\": \"\:95a2\:9023\:7814\:7a76\:306e\:984c\:76ee\", \"Lead\": \"...\", \"Points\": [\"...\"], \"Talk\": \"...\", \"Importance\": 0-1},\n" <>
  " {\"Id\": \"bg_<\:82f1\:5c0f\:6587\:5b57>\", \"Layer\": \"Background\", \"Label\": \"\:524d\:63d0\:77e5\:8b58\", \"Summary\": \"...\", \"Points\": [\"...\"], \"Difficulty\": 0-1}],\n" <>
  " \"Edges\": [{\"From\": \"<Id>\", \"To\": \"<Id>\", \"EdgeKind\": \"Motivates|Derives|LeadsTo|Prerequisite|Supports|Explains|Contrasts|RelatedTo\", \"Weight\": 0-1}]}\n" <>
  "\:898f\:5247:\n" <>
  "- 1 \:7bc0\:3042\:305f\:308a 2\:301c6 \:30ce\:30fc\:30c9 (1 \:30ce\:30fc\:30c9 = \:30b9\:30e9\:30a4\:30c9 1 \:679a)\:3002Id \:306f <\:7bc0 Id>_1, <\:7bc0 Id>_2 \:2026 \:3067\:3001\:3053\:306e\:9806\:306b\:30b9\:30e9\:30a4\:30c9\:306b\:306a\:308b\:3002\:7bc0\:30ce\:30fc\:30c9\:81ea\:4f53\:306b\:3082 Label \:3068 Summary \:3092\:4ed8\:3051\:308b\:3002\n" <>
  "- \:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc\:3092\:7d39\:4ecb\:3059\:308b\:3068\:304d\:306f Id \:3092 rw_<\:5019\:88dc\:756a\:53f7> \:306b\:3057\:3001\:305d\:306e\:7bc0\:306b\:7f6e\:304f (Parent)\:3002Points \:306f\:5019\:88dc\:306e\:8981\:7d04\:306b\:3042\:308b\:3053\:3068\:3060\:3051\:3002\:672c\:6587\:306e\:30ce\:30fc\:30c9\:304c\:5019\:88dc\:306b\:4f9d\:62e0\:3059\:308b\:3068\:304d\:306f \"Ref\": [\:5019\:88dc\:756a\:53f7]\:3002\:5019\:88dc\:306b\:7121\:3044\:6587\:732e\:30fb\:8457\:8005\:30fb\:5e74\:3092\:4f5c\:3089\:306a\:3044\:3002\n" <>
  "- \:7b4b\:66f8\:304d\:306b\:7121\:3044\:5177\:4f53\:7684\:306a\:6570\:5024\:30fb\:5b9f\:9a13\:7d50\:679c\:3092\:4f5c\:3089\:306a\:3044\:3002\:8074\:304d\:624b\:306b\:7121\:3044\:524d\:63d0\:77e5\:8b58\:306f bg_ \:30ce\:30fc\:30c9\:306b\:3057\:3066 Prerequisite \:8fba\:3092\:5f35\:308b\:3002\:9806\:5e8f\:8fba\:306f From \:3092\:5148\:306b\:63d0\:793a\:3059\:308b\:5411\:304d\:3002\n" <>
  "- \:30b9\:30e9\:30a4\:30c9\:306f\:305d\:308c\:3060\:3051\:898b\:3066\:3082\:5185\:5bb9\:304c\:5206\:304b\:308b\:3088\:3046\:306b: Lead + Points + Details\:3002\:5f37\:8abf\:3057\:305f\:3044\:8a9e\:53e5\:306f **\:2026** (1 \:30ce\:30fc\:30c9 1\:301c2 \:304b\:6240)\:3002\:56f3\:8868\:756a\:53f7\:306f\:66f8\:304b\:306a\:3044\:3002\n" <>
  "- Talk (\:8aad\:307f\:4e0a\:3052\:539f\:7a3f) \:306b\:306f $...$ \:3084 ** \:3092\:66f8\:304b\:306a\:3044\:3002\:5f0f\:306f\:300c\:3053\:306e\:5f0f\:306f\:301c\:3092\:8868\:3057\:307e\:3059\:300d\:3068\:753b\:9762\:3092\:6307\:3057\:3066\:8a9e\:308b\:3002\:5f0f\:306b\:51fa\:308b\:8a18\:53f7\:306e\:610f\:5473\:306f Points \:304b Details \:306b\:66f8\:304f\:3002\n\n" <>
  "=== \:5c55\:958b\:3059\:308b\:7bc0 (\:7b4b\:66f8\:304d) ===\n" <>
  StringRiffle[Map[Function[sid, With[{n = Lookup[index, sid, <||>]},
    "[" <> sid <> "] " <> SourceVault`SourceVaultKGText[n, "Label"] <> "\n" <> Replace[Lookup[n, "Text", ""], Except[_String] -> ""]]],
    Select[sectionIds, KeyExistsQ[index, #] &]], "\n\n"] <>
  "\n\n=== \:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc (\:756a\:53f7. \:984c\:76ee / \:8457\:8005 / \:5e74 / \:7a2e\:985e \:3068\:8981\:7d04) ===\n" <> iSWRelatedListText[related]];

(* \:53d7\:7406: \:7bc0\:30ce\:30fc\:30c9 (Label / Summary)\:3001<\:7bc0>_n (\:65b0\:3057\:3044\:679a)\:3001rw_<\:5019\:88dc\:756a\:53f7>\:3001bg_*\:3002\:65b0\:3057\:3044\:679a\:306b\:306f\:7bc0\:304b\:3089\:306e Contains \:8fba\:3068\:9806\:5e8f\:3092\:4ed8\:3051\:3001
   \:679a\:304c\:3067\:304d\:305f\:7bc0\:306e\:7b4b\:66f8\:304d\:30ce\:30fc\:30c9 (<\:7bc0>_d) \:306f\:5916\:3059 *)
iSWScenarioSanitize[deltaIn_Association, sectionIds_List, kg_Association] := Module[
  {d = KeyMap[ToString, deltaIn], index, related, kgIds, nodes = {}, edges = {}, newIds = {}, count = <||>, bySec = <||>, secOf, contentKeys},
  index = Association[(#["Id"] -> #) & /@ kg["Nodes"]];
  kgIds = Keys[index];
  related = Replace[Lookup[kg, "Related", {}], Except[_List] -> {}];
  contentKeys = {"Kind", "Label", "Summary", "Lead", "Points", "Details", "Talk", "Importance", "Difficulty", "Domains"};
  secOf[id_String] := SelectFirst[sectionIds, StringStartsQ[id, # <> "_"] &, None];
  Do[
    Module[{id = StringTrim[ToString[Lookup[n, "Id", ""]]], sid, m, refs, k},
      Which[
        MemberQ[sectionIds, id],
          AppendTo[nodes, Join[<|"Id" -> id|>, Select[KeyTake[n, {"Label", "Summary"}], StringQ]]],
        StringStartsQ[id, "bg_"],
          AppendTo[nodes, Join[KeyTake[n, contentKeys], <|"Id" -> id, "Layer" -> "Background"|>]]; AppendTo[newIds, id],
        StringMatchQ[id, "rw_" ~~ DigitCharacter ..] && 1 <= (k = FromDigits[StringDrop[id, 3]]) <= Length[related],
          sid = Lookup[n, "Parent", None];
          If[! MemberQ[sectionIds, sid], sid = First[sectionIds]];
          m = Join[KeyTake[n, contentKeys], <|"Id" -> id, "Kind" -> "RelatedWork", "Layer" -> "Paper",
            "Cite" -> iSWRelatedCite[related[[k]]], "PrivacyLevel" -> related[[k]]["PrivacyLevel"],
            "Source" -> <|"Kind" -> "Related", "Ref" -> related[[k]]["Key"]|>|>];
          If[! StringQ[Lookup[m, "Label", None]], m["Label"] = related[[k]]["Title"]];
          (* \:540c\:3058\:5019\:88dc\:306f 1 \:3064\:306e\:7bc0\:306b\:3060\:3051\:7f6e\:304f (\:5148\:306b\:51fa\:305f\:7bc0\:3002\:65e2\:306b KG \:306b\:3042\:308c\:3070\:7f6e\:304d\:5834\:6240\:306f\:5909\:3048\:306a\:3044) *)
          If[! KeyExistsQ[index, id] && ! MemberQ[Flatten[Values[bySec]], id],
            If[! MemberQ[Keys[bySec], sid], bySec[sid] = {}];
            bySec[sid] = Append[bySec[sid], id]];
          AppendTo[nodes, m]; AppendTo[newIds, id],
        StringQ[secOf[id]] && id =!= secOf[id] <> "_d",
          sid = secOf[id];
          refs = Select[Replace[Lookup[n, "Ref", {}], {x_Integer :> {x}, Except[_List] -> {}}], IntegerQ[#] && 1 <= # <= Length[related] &];
          m = Join[KeyTake[n, contentKeys], <|"Id" -> id, "Layer" -> "Paper", "Source" -> <|"Kind" -> "Scenario", "Section" -> sid|>|>];
          If[refs =!= {},
            m["Cite"] = StringRiffle[iSWRelatedCite[related[[#]]] & /@ refs, "; "];
            m["PrivacyLevel"] = Max[Lookup[related[[refs]], "PrivacyLevel", 0.]]];
          If[! MemberQ[Keys[bySec], sid], bySec[sid] = {}];
          If[! MemberQ[bySec[sid], id], bySec[sid] = Append[bySec[sid], id]];
          AppendTo[nodes, m]; AppendTo[newIds, id],
        True, Null]],
    {n, Select[Replace[Lookup[d, "Nodes", {}], Except[_List] -> {}], AssociationQ]}];
  (* \:4e26\:3073: \:7bc0\:306e Order + 0.01 \:523b\:307f (LLM \:304c\:4e26\:3079\:305f\:9806)\:3002\:7bc0\:304b\:3089 Contains\:3001\:679a\:3069\:3046\:3057\:306f Precedes *)
  KeyValueMap[Function[{sid, ids},
      With[{o = Replace[Lookup[Lookup[index, sid, <||>], "Order", 0], Except[_?NumericQ] -> 0]},
        Do[
          nodes = Map[If[#["Id"] === ids[[j]], Append[#, "Order" -> o + 0.01 * j], #] &, nodes];
          AppendTo[edges, <|"From" -> sid, "To" -> ids[[j]], "EdgeKind" -> "Contains", "Weight" -> 0.9|>];
          If[j > 1, AppendTo[edges, <|"From" -> ids[[j - 1]], "To" -> ids[[j]], "EdgeKind" -> "Precedes", "Weight" -> 0.5|>]],
          {j, Length[ids]}]]],
    bySec];
  With[{ok = Join[kgIds, newIds]},
    edges = Join[edges, Select[Replace[Lookup[d, "Edges", {}], Except[_List] -> {}],
      AssociationQ[#] && StringQ[Lookup[#, "From", None]] && StringQ[Lookup[#, "To", None]] &&
        MemberQ[ok, #["From"]] && MemberQ[ok, #["To"]] && #["From"] =!= #["To"] &]]];
  <|"Nodes" -> nodes, "Edges" -> edges,
    "Remove" -> Select[(# <> "_d") & /@ Keys[bySec], KeyExistsQ[index, #] &]|>];

(* KG\:69cb\:7bc9\:306e\:7d20\:6750: Story \:306e Source: > \:6587\:732e\:306e\:548c\:8a33\:30ce\:30fc\:30c8 > \:30d7\:30ed\:30f3\:30d7\:30c8\:306e\:30b7\:30ca\:30ea\:30aa *)
iSWBuildSourceMode[v_] := With[{s = ToLowerCase[StringTrim[ToString[v]]]},
  Which[
    StringContainsQ[s, "scenario" | "\:30b7\:30ca\:30ea\:30aa" | "\:7b4b\:66f8\:304d" | "prompt" | "\:30d7\:30ed\:30f3\:30d7\:30c8"], "Scenario",
    StringContainsQ[s, "paper" | "\:6587\:732e" | "\:8ad6\:6587" | "document" | "\:6587\:66f8" | "notebook"], "Paper",
    True, Automatic]];

iSWScenarioBuild[nb_NotebookObject, spec_Association, parts_List] := Module[{seed, survey, refineFn, run},
  If[! iSWLLMReadyQ[], Return[Failure["NoLLM", <|"MessageTemplate" -> "LLM query function is not registered (load NBAccess/claudecode)"|>]]];
  If[iSWRefineBusyQ[],
    iSWStatus[nb, iSL["KG \:306e\:63a8\:6572\:30fb\:56f3\:89e3\:30fb\:8abf\:6574\:3092\:5b9f\:884c\:4e2d\:3067\:3059\:3002\:7d42\:308f\:308b\:307e\:3067\:5f85\:3063\:3066\:304f\:3060\:3055\:3044", "A KG run is in progress"]];
    Return[<|"Status" -> "Busy"|>]];
  seed = SlideGraphSeedScenario[parts, "Graph" -> spec["Graph"], "Title" -> spec["Title"], "Language" -> spec["Language"]];
  If[! AssociationQ[seed], iSWStatus[nb, ToString[Lookup[Replace[seed, Failure[_, a_] :> a], "MessageTemplate", seed]]]; Return[seed]];
  iSWStatus[nb, iSL["\:30b7\:30ca\:30ea\:30aa\:304b\:3089\:7b2c\:4e00\:6b21 KG \:3092\:4f5c\:308a\:307e\:3057\:305f (" <> ToString[seed["Parts"]] <> " \:90e8)",
    "Seeded the KG from the scenario (" <> ToString[seed["Parts"]] <> " parts)"]];
  survey = iSWSurveyMode[Lookup[spec, "Survey", ""]];
  refineFn = With[{n = nb, sp = spec}, Function[iSWRefineStart[n, sp, iSWKGResolve[sp["Graph"]], 8, All, None,
    {"\:6b21\:306f\:300c\:5468\:8fba\:77e5\:8b58\:300d\:300c\:56f3\:89e3\:300d\:3001\:305d\:3057\:3066\:300c\:751f\:6210\:300d", "Next: background, visuals, then generate"}]]];
  run = If[survey === "Off", refineFn[],
    iSWRelatedRun[nb, spec, seed["KG"], survey === "Web", 20, refineFn,
      iSWDirectivesBlock[nb] <> iSWDictionaryBlock[nb], iSWRefinePrivacy[nb, seed["KG"]]]];
  Success["SeededScenario", <|"GraphId" -> seed["Graph"], "Parts" -> seed["Parts"], "NodeCount" -> seed["NodeCount"],
    "Survey" -> survey, "Run" -> run|>]];

(* \:30b9\:30c8\:30fc\:30ea\:30fc\:306e\:96db\:5f62 (\:30b7\:30ca\:30ea\:30aa\:306e\:30c7\:30c3\:30ad): \:7b4b\:66f8\:304d\:306e\:90e8\:306e\:4e26\:3073\:3092\:9806\:5e8f\:306b\:3059\:308b *)
iSWStoryScenarioTemplate[parts_List, ja_] := Module[{titles = Take[Lookup[parts, "Title", ""], UpTo[12]]},
  If[TrueQ[ja],
    "Graph: \nAudience: \:5927\:5b66\:7406\:7cfb\:5b66\:90e8\:5352\nSlides: 20\nMinutes: \nLanguage: ja\nStrategy: Source\n" <>
      "Source: \:30b7\:30ca\:30ea\:30aa\n# Survey: \:95a2\:9023\:7814\:7a76\:306e\:63a2\:3057\:65b9 (local = \:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e\:6587\:732e\:3001web = Web \:691c\:7d22\:3082\:4f7f\:3046\:3001off = \:63a2\:3055\:306a\:3044)\nSurvey: local\n" <>
      "Story: \:7d50\:8ad6\:30d5\:30a1\:30fc\:30b9\:30c8\:3002\:6700\:521d\:306e 1 \:679a\:3067\:767a\:8868\:306e\:7d50\:8ad6\:3068\:65b0\:3057\:3055\:3092\:793a\:3059\:3002\n" <>
      "\:9806\:5e8f: " <> If[titles === {}, "\:7d50\:8ad6 \:2192 \:80cc\:666f \:2192 \:672c\:984c \:2192 \:307e\:3068\:3081", StringRiffle[titles, " \:2192 "]] <> "\:3002\n" <>
      "\:95a2\:9023\:7814\:7a76: \:53d6\:308a\:8fbc\:307f\:6e08\:307f\:306e\:6587\:732e\:304b\:3089\:7b4b\:66f8\:304d\:306b\:95a2\:4fc2\:3059\:308b\:7814\:7a76\:3092\:9078\:3073\:3001\:51fa\:5178\:3092\:4ed8\:3051\:3066\:7d39\:4ecb\:3059\:308b\:3002\n" <>
      "\:56f3\:3084\:8868\:3067\:793a\:305b\:308b\:5185\:5bb9\:306f\:56f3\:3092\:4e3b\:5f79\:306b\:3057\:3001\:7b87\:6761\:66f8\:304d\:306f\:305d\:306e\:8aac\:660e\:306b\:3059\:308b (\:7121\:3044\:6240\:306f\:6982\:5ff5\:56f3\:304b\:8868\:3092\:63cf\:304f)\:3002\n" <>
      "\:8074\:304d\:624b\:306f\:3053\:306e\:5206\:91ce\:306e\:5c02\:9580\:5bb6\:3067\:306f\:306a\:3044\:306e\:3067\:3001\:521d\:51fa\:306e\:7528\:8a9e\:306f\:4e00\:8a00\:3067\:8a00\:3044\:63db\:3048\:308b\:3002",
    "Graph: \nAudience: undergraduate\nSlides: 20\nMinutes: \nLanguage: en\nStrategy: Source\n" <>
      "Source: scenario\n# Survey: how to find related work (local = ingested sources, web = also web search, off = none)\nSurvey: local\n" <>
      "Story: conclusion first. The opening slide states the conclusion and what is new.\n" <>
      "Order: " <> If[titles === {}, "conclusion -> background -> main part -> summary", StringRiffle[titles, " -> "]] <> ".\n" <>
      "Related work: pick studies related to the scenario from the ingested sources and cite them.\n" <>
      "Let a figure or table carry each slide where possible, with the bullets explaining it.\n" <>
      "The audience is not from this field, so gloss every term on first use."]];

(* ===================== v1.30: \:77e5\:8b58\:30b0\:30e9\:30d5\:306e\:56f3 (SlideGraphVisualize) \:3068\:898b\:308b\:7a93 (SlideGraphViewer\:3001\:30d1\:30ec\:30c3\:30c8\:300cKG\:56f3\:300d) =====================
   \:56f3\:306f SourceVault_knowledgegraph \:306e SourceVaultKGVisualize\:3002\:3053\:3053\:306f\:30c7\:30c3\:30ad\:3068\:306e\:3064\:306a\:304e (Story \:30bb\:30eb\:306e\:8a08\:753b\:3092\:91cd\:306d\:308b\:3001
   \:30ce\:30fc\:30c9\:306e\:679a\:3078\:79fb\:52d5\:3059\:308b\:3001\:8abf\:6574\:30bb\:30eb\:3078\:66f8\:304f) \:3068\:7a93 (DynamicModule) \:3060\:3051\:3092\:6301\:3064\:3002\:7a93\:306e\:4e2d\:306e\:56f3\:306f\:898b\:3048\:3066\:3044\:308b\:8868\:793a\:3060\:3051\:3092\:63cf\:304d\:76f4\:3059
   (PaneSelector)\:3002KG \:306f\:30d5\:30a1\:30a4\:30eb\:306e\:65e5\:4ed8\:3068\:5927\:304d\:3055\:3067\:899a\:3048\:3066\:304a\:304d\:3001\:300c\:66f4\:65b0\:300d\:3067\:8aad\:307f\:76f4\:3059 *)
$iSWVizCache = <||>;
$iSWVizPlanCache = <||>;
iSWVizStamp[gid_String] := With[{f = Quiet @ Check[SourceVault`KGPrivate`iKGGraphFile[gid], $Failed]},
  If[StringQ[f] && FileExistsQ[f], {AbsoluteTime[FileDate[f]], FileByteCount[f]}, None]];
iSWVizKG[kg_Association] := kg;
iSWVizKG[gid_String] := Module[{st = iSWVizStamp[gid], hit = Lookup[$iSWVizCache, gid, None], kg},
  If[AssociationQ[hit] && st =!= None && hit["Stamp"] === st, Return[hit["KG"]]];
  kg = iSWKGResolve[gid];
  If[AssociationQ[kg], $iSWVizCache[gid] = <|"Stamp" -> st, "KG" -> kg|>];
  kg];

(* \:8a08\:753b (\:679a\:756a\:53f7\:306e\:91cd\:306d\:66f8\:304d\:7528)\:3002\:30c7\:30c3\:30ad\:304c\:3042\:308c\:3070 Story \:30bb\:30eb\:306e\:8074\:304d\:624b\:30fb\:679a\:6570\:3067 *)
iSWVizPlan[gid_String, deck_, rev_ : 0] := Module[{key = {gid, iSWVizStamp[gid], rev, Head[deck] === NotebookObject}, hit, p},
  hit = Lookup[$iSWVizPlanCache, Key[key], None];
  If[hit =!= None, Return[hit]];
  p = Quiet @ Check[SlideGraphPlan[If[Head[deck] === NotebookObject, deck, gid]], $Failed];
  p = If[AssociationQ[p], p["Plan"], None];
  $iSWVizPlanCache = <|Key[key] -> p|>;
  p];

Options[SlideGraphVisualize] = {"View" -> "Story", "Focus" -> None, "Radius" -> 1, "EdgeKinds" -> Automatic, "Layers" -> All,
  "Labels" -> Automatic, "Plan" -> Automatic, "Selected" -> None, "OnClick" -> None, "Language" -> Automatic,
  "Legend" -> True, "Hidden" -> True};
SlideGraphVisualize[opts : OptionsPattern[]] := SlideGraphVisualize[iSWResolveTargetNb[], opts];
SlideGraphVisualize[src_?iSWNotOptionQ, opts : OptionsPattern[]] := Module[{kg, plan},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  kg = If[StringQ[src], iSWVizKG[src], iSWKGResolve[src]];
  If[! AssociationQ[kg], Return[kg]];
  plan = Replace[OptionValue["Plan"], {
    Automatic :> If[Head[src] === NotebookObject, iSWVizPlan[kg["GraphId"], src], None],
    True :> iSWVizPlan[kg["GraphId"], src],
    False -> None}];
  SourceVault`SourceVaultKGVisualize[kg, "Plan" -> plan,
    Sequence @@ FilterRules[Join[{opts}, Options[SlideGraphVisualize]], Except["Plan"]]]];

SetAttributes[iSWVizSafe, HoldAll];
iSWVizSafe[expr_] := Quiet @ Check[expr, Style[iSL["\:56f3\:3092\:63cf\:3051\:307e\:305b\:3093\:3067\:3057\:305f", "Could not draw the graph"], RGBColor[0.7, 0.1, 0.1]]];

(* \:4e00\:884c\:306e\:8981\:7d04 *)
iSWVizSummaryLine[gid_String] := Module[{kg = iSWVizKG[gid], nodes, secs, paper, bg, rel, un, fig, qa, hid},
  If[! AssociationQ[kg], Return[Style[iSL["KG \:3092\:8aad\:3081\:307e\:305b\:3093", "Cannot read the KG"], RGBColor[0.7, 0.1, 0.1]]]];
  nodes = kg["Nodes"];
  secs = iSWKGSectionIdSet[kg];
  paper = Select[nodes, ! MemberQ[secs, #["Id"]] && #["Id"] =!= Lookup[kg, "Root", "root"] && Lookup[#, "Layer", ""] === "Paper" &&
    Lookup[#, "Kind", ""] =!= "RelatedWork" &];
  bg = Select[nodes, Lookup[#, "Layer", "Paper"] =!= "Paper" &];
  rel = Select[nodes, Lookup[#, "Kind", ""] === "RelatedWork" &];
  un = iSWUnrefinedSections[kg];
  fig = Count[nodes, n_ /; MatchQ[Lookup[n, "Assets", {}], {__Association}]];
  qa = Count[nodes, n_ /; MatchQ[Lookup[n, "QA", {}], {__String} | _String?(StringTrim[#] =!= "" &)]];
  hid = Count[nodes, n_ /; TrueQ[Lookup[n, "Hidden", False]]];
  Style[StringRiffle[{
    iSL[If[Lookup[kg, "Kind", ""] === "Scenario", "\:30b7\:30ca\:30ea\:30aa", "\:8ad6\:6587"], Lookup[kg, "Kind", ""]],
    iSL["\:7bc0 ", "sections "] <> ToString[Length[secs]],
    iSL["\:672c\:6587 ", "content "] <> ToString[Length[paper]],
    iSL["\:5468\:8fba\:77e5\:8b58 ", "background "] <> ToString[Length[bg]],
    iSL["\:95a2\:9023\:7814\:7a76 ", "related "] <> ToString[Length[rel]] <>
      With[{c = Length[Replace[Lookup[kg, "Related", {}], Except[_List] -> {}]]}, If[c > 0, iSL[" (\:5019\:88dc ", " (candidates "] <> ToString[c] <> ")", ""]],
    iSL["\:8fba ", "edges "] <> ToString[Length[kg["Edges"]]],
    iSL["\:56f3\:30fb\:8868 ", "with figures "] <> ToString[fig],
    iSL["\:8cea\:7591\:5fdc\:7b54 ", "with Q&A "] <> ToString[qa],
    If[hid > 0, iSL["\:96a0\:3059 ", "hidden "] <> ToString[hid], Nothing],
    If[un === {}, iSL["\:672a\:63a8\:6572\:306e\:7bc0\:306a\:3057", "all sections refined"],
      iSL["\:672a\:63a8\:6572\:306e\:7bc0 ", "unrefined sections "] <> ToString[Length[un]] <> " (" <> StringRiffle[Take[un, UpTo[5]], ", "] <> ")"]},
    "  \:00b7  "], 10, GrayLevel[0.3]]];

(* \:9078\:3093\:3060\:30ce\:30fc\:30c9\:306e\:8a73\:7d30 *)
iSWVizNeighborLines[kg_Association, id_String, lang_String] := Module[{index = Association[(#["Id"] -> #) & /@ kg["Nodes"]], lab, out = {}},
  lab[x_] := If[KeyExistsQ[index, x], SourceVault`SourceVaultKGText[index[x], "Label", lang], x];
  Do[With[{ins = Select[kg["Edges"], #["To"] === id && MemberQ[kinds[[2]], #["EdgeKind"]] &],
      outs = Select[kg["Edges"], #["From"] === id && MemberQ[kinds[[2]], #["EdgeKind"]] &]},
      If[ins =!= {}, AppendTo[out, {kinds[[1]] <> iSL[" \:2190 ", " <- "], StringRiffle[Take[lab /@ Lookup[ins, "From"], UpTo[6]], " / "]}]];
      If[outs =!= {}, AppendTo[out, {kinds[[1]] <> iSL[" \:2192 ", " -> "], StringRiffle[Take[lab /@ Lookup[outs, "To"], UpTo[6]], " / "]}]]],
    {kinds, {{iSL["\:5305\:542b", "contains"], {"Contains"}}, {iSL["\:9806\:5e8f", "order"], {"Precedes", "LeadsTo", "Derives", "Motivates"}},
      {iSL["\:524d\:63d0", "prerequisite"], {"Prerequisite"}}, {iSL["\:652f\:3048", "support"], {"Supports", "Explains"}},
      {iSL["\:95a2\:9023", "related"], {"Contrasts", "RelatedTo", "Cites"}}}}];
  out];

iSWVizDetail[gid_String, sel_, _] := Module[{kg = iSWVizKG[gid], n, lang, txt, pts, det, lead, talk, cite, qa, assets, nb},
  If[! StringQ[sel],
    Return[Pane[Style[iSL["\:56f3\:306e\:30ce\:30fc\:30c9\:3092\:30af\:30ea\:30c3\:30af\:3059\:308b\:304b\:3001\:4e0b\:3067\:691c\:7d22\:3057\:3066\:9078\:3076\:3068\:3001\:3053\:3053\:306b\:4e2d\:8eab\:304c\:51fa\:307e\:3059\:3002",
      "Click a node in the graph, or search below, to see its content here."], 10, GrayLevel[0.45]], 330]]];
  If[! AssociationQ[kg], Return[Style[iSL["KG \:3092\:8aad\:3081\:307e\:305b\:3093", "Cannot read the KG"], RGBColor[0.7, 0.1, 0.1]]]];
  n = SourceVault`SourceVaultKGNode[kg, sel];
  If[! AssociationQ[n], Return[Style[iSL["\:30ce\:30fc\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093: ", "No such node: "] <> sel, RGBColor[0.7, 0.1, 0.1]]]];
  lang = Lookup[kg, "Language", "ja"];
  pts = SourceVault`SourceVaultKGText[n, "Points", lang];
  det = Replace[SourceVault`SourceVaultKGText[n, "Details", lang], Except[_List] -> {}];
  lead = SourceVault`SourceVaultKGText[n, "Lead", lang];
  talk = SourceVault`SourceVaultKGText[n, "Talk", lang];
  cite = SourceVault`SourceVaultKGText[n, "Cite", lang];
  txt = Replace[Lookup[n, "Text", ""], Except[_String] -> ""];
  qa = Select[Replace[Lookup[n, "QA", {}], {s_String :> {s}, Except[_List] -> {}}], StringQ[#] && StringTrim[#] =!= "" &];
  assets = Lookup[Select[Replace[Lookup[n, "Assets", {}], Except[_List] -> {}], AssociationQ], "Type", {}];
  nb = iSWVizNeighborLines[kg, sel, lang];
  Pane[Column[Join[
      {Style[SourceVault`SourceVaultKGText[n, "Label", lang], Bold, 13, RGBColor[0.55, 0.28, 0.05]],
       Style[sel <> " \:00b7 " <> ToString[Lookup[n, "Kind", ""]] <> " \:00b7 " <> ToString[Lookup[n, "Layer", ""]] <>
         iSL[" \:00b7 \:91cd\:8981\:5ea6 ", " \:00b7 importance "] <> ToString[Round[Lookup[n, "Importance", 0.5], 0.01]] <>
         iSL[" \:00b7 \:96e3\:3057\:3055 ", " \:00b7 difficulty "] <> ToString[Round[Lookup[n, "Difficulty", 0.5], 0.01]], 9, GrayLevel[0.45]]},
      If[TrueQ[Lookup[n, "Hidden", False]], {Style[iSL["\:96a0\:3059 (\:30b9\:30e9\:30a4\:30c9\:306b\:3057\:306a\:3044)", "hidden (not on slides)"], 9, RGBColor[0.6, 0.3, 0.1]]}, {}],
      If[StringTrim[txt] =!= "" && ! MatchQ[pts, {__String}] && ! MemberQ[iSWKGSectionIdSet[kg], sel],
        {Style[iSL["\:672a\:63a8\:6572 (\:8981\:70b9\:304c\:7121\:3044)\:3002\:300c\:63a8\:6572\:300d\:3067\:8981\:70b9\:306b\:306a\:308a\:307e\:3059", "not refined yet (no points); Refine makes them"], 9, RGBColor[0.8, 0.1, 0.1]]}, {}],
      If[lead =!= "", {Style[lead, 11]}, {}],
      If[MatchQ[pts, {__String}],
        {Column[MapIndexed[Function[{p, k}, Column[{Style["\:2022 " <> p, 11],
            If[k[[1]] <= Length[det] && StringQ[det[[k[[1]]]]] && det[[k[[1]]]] =!= "", Style["   " <> det[[k[[1]]]], 9, GrayLevel[0.4]], Nothing]}]], pts],
          Spacings -> 0.2]}, {}],
      If[StringTrim[SourceVault`SourceVaultKGText[n, "Summary", lang]] =!= "" && ! MatchQ[pts, {__String}],
        {Style[SourceVault`SourceVaultKGText[n, "Summary", lang], 10]}, {}],
      If[talk =!= "", {Style[iSL["\:539f\:7a3f: ", "Talk: "] <> StringTake[talk, UpTo[220]] <> If[StringLength[talk] > 220, "\:2026", ""], 9, GrayLevel[0.3]]}, {}],
      If[assets =!= {}, {Style[iSL["\:56f3: ", "Assets: "] <> StringRiffle[DeleteDuplicates[assets], ", "], 9, RGBColor[0.4, 0.35, 0.65]]}, {}],
      If[qa =!= {}, {Style[iSL["\:8cea\:7591\:5fdc\:7b54: ", "Q&A: "] <> StringTake[StringRiffle[qa, "\n"], UpTo[200]], 9, RGBColor[0.7, 0.4, 0.1]]}, {}],
      If[cite =!= "", {Style[iSL["\:51fa\:5178: ", "Source: "] <> cite, 9, GrayLevel[0.35]]}, {}],
      If[StringTrim[txt] =!= "", {Style[iSL["\:672c\:6587: ", "Text: "] <> StringTake[StringReplace[txt, "\n" -> " "], UpTo[300]] <>
        If[StringLength[txt] > 300, "\:2026", ""], 9, GrayLevel[0.35]]}, {}],
      If[nb =!= {}, {Grid[Map[{Style[#[[1]], 9, Bold, GrayLevel[0.35]], Style[#[[2]], 9, GrayLevel[0.3]]} &, nb], Alignment -> {Left, Top}, Spacings -> {0.5, 0.2}]}, {}]],
    Spacings -> 0.45], 330]];

(* \:30ce\:30fc\:30c9\:3092\:9078\:3076\:4e00\:89a7 (\:691c\:7d22\:8a9e\:3067\:7d5e\:308b) *)
iSWVizNodeChoices[gid_String, query_] := Module[{kg = iSWVizKG[gid], lang, nodes, q = If[StringQ[query], StringTrim[query], ""]},
  If[! AssociationQ[kg], Return[{None -> "-"}]];
  lang = Lookup[kg, "Language", "ja"];
  nodes = SortBy[kg["Nodes"], {Replace[Lookup[#, "Order", None], Except[_?NumericQ] -> 10.^6] &, #["Id"] &}];
  If[q =!= "", nodes = Select[nodes, StringContainsQ[#["Id"] <> " " <> SourceVault`SourceVaultKGText[#, "Label", lang], q, IgnoreCase -> True] &]];
  Prepend[Map[#["Id"] -> (#["Id"] <> "  " <> StringTake[SourceVault`SourceVaultKGText[#, "Label", lang], UpTo[28]]) &, Take[nodes, UpTo[300]]],
    None -> iSL["(\:30ce\:30fc\:30c9\:3092\:9078\:3076)", "(pick a node)"]]];

(* \:305d\:306e\:30ce\:30fc\:30c9\:306e\:679a\:3078\:79fb\:52d5\:3059\:308b (\:8a70\:3081\:8fbc\:307e\:308c\:3066\:3044\:308c\:3070\:3001\:8a70\:3081\:8fbc\:307f\:5148\:306e\:679a\:3078) *)
iSWVizJump[nb_NotebookObject, gid_String, id_String] := Module[{rows, hit, plan, head, ranges, styles, cells, tIdx},
  rows = Quiet @ Check[iSWKGDeckSlideNodes[nb], {}];
  If[! ListQ[rows], rows = {}];
  hit = SelectFirst[rows, #["Node"] === id &, None];
  If[hit === None,
    plan = iSWVizPlan[gid, nb];
    head = If[AssociationQ[plan], SelectFirst[Select[plan["Slides"], AssociationQ], MemberQ[Replace[Lookup[#, "Packed", {}], Except[_List] -> {}], id] &, None], None];
    If[AssociationQ[head], hit = SelectFirst[rows, #["Node"] === head["NodeId"] &, None]]];
  If[hit === None,
    Return[iSL["\:3053\:306e\:30ce\:30fc\:30c9\:306e\:679a\:306f\:30c7\:30c3\:30ad\:306b\:3042\:308a\:307e\:305b\:3093 (\:307e\:3060\:751f\:6210\:3057\:3066\:3044\:306a\:3044\:304b\:3001\:8a08\:753b\:3067\:7701\:304b\:308c\:305f)",
      "No slide for this node in the deck (not generated yet, or left out by the plan)"]]];
  ranges = iSWSlideRanges[nb]; styles = iSWCellStyles[nb]; cells = Cells[nb];
  tIdx = SelectFirst[Range[ranges[[hit["Slide"], 1]], ranges[[hit["Slide"], 2]]], MemberQ[Flatten[{styles[[#]]}], "Subsection"] &,
    ranges[[hit["Slide"], 1]]];
  SelectionMove[cells[[tIdx]], All, Cell, AutoScroll -> True];
  SetSelectedNotebook[nb];
  iSL[ToString[hit["Slide"]] <> " \:679a\:76ee\:3078\:79fb\:52d5\:3057\:307e\:3057\:305f", "Moved to slide " <> ToString[hit["Slide"]]]];
iSWVizJump[_, _, _] := iSL["\:30c7\:30c3\:30ad\:304c\:958b\:3044\:3066\:3044\:307e\:305b\:3093", "No deck is open"];

(* \:8abf\:6574\:30bb\:30eb\:306b\:300c\:984c\:76ee (Id): \:300d\:3092\:66f8\:304f\:3002\:307e\:3060\:53cd\:6620\:3057\:3066\:3044\:306a\:3044\:8abf\:6574\:30bb\:30eb\:304c\:3042\:308c\:3070\:305d\:3053\:3078\:8db3\:3059 *)
iSWVizToAdjust[nb_NotebookObject, gid_String, id_String] := Module[{kg = iSWVizKG[gid], n, line, co, cur},
  n = If[AssociationQ[kg], SourceVault`SourceVaultKGNode[kg, id], None];
  If[! AssociationQ[n], Return[iSL["\:30ce\:30fc\:30c9\:304c\:898b\:3064\:304b\:308a\:307e\:305b\:3093", "No such node"]]];
  line = "\:300c" <> SourceVault`SourceVaultKGText[n, "Label", Lookup[kg, "Language", "ja"]] <> "\:300d(" <> id <> "): ";
  Quiet[SlideEnsureDeckStyles[nb]];
  co = iSWAdjustPendingCell[nb];
  If[co === None,
    With[{story = Quiet[Cells[nb, CellStyle -> "SlideStory"]]},
      If[ListQ[story] && story =!= {}, SelectionMove[Last[story], After, Cell], SelectionMove[nb, Before, Notebook]]];
    NotebookWrite[nb, Cell[line, "SlideAdjust"]],
    cur = iSWAdjustText[iCellText[NotebookRead[co]]];
    SelectionMove[co, All, Cell];
    NotebookWrite[nb, Cell[If[cur === "", line, iCellText[NotebookRead[co]] <> "\n" <> line], "SlideAdjust"], All]];
  SetSelectedNotebook[nb];
  iSL["\:8abf\:6574\:30bb\:30eb\:306b\:66f8\:304d\:307e\:3057\:305f\:3002\:76f4\:3057\:305f\:3044\:3053\:3068\:3092\:7d9a\:3051\:3066\:66f8\:304d\:3001\:300c\:8abf\:6574\:300d\:3092\:62bc\:3057\:3066\:304f\:3060\:3055\:3044",
    "Added to the adjustment cell. Write the change after it, then press Adjust"]];
iSWVizToAdjust[_, _, _] := iSL["\:30c7\:30c3\:30ad\:304c\:958b\:3044\:3066\:3044\:307e\:305b\:3093", "No deck is open"];

iSWVizPanel[gid_String, deck_] := With[{g = gid, d = deck, hasDeck = Head[deck] === NotebookObject,
    lang = With[{kg = iSWVizKG[gid]}, If[AssociationQ[kg], Lookup[kg, "Language", "ja"], "ja"]]},
  DynamicModule[{view = "Story", groups = {"Order", "Prerequisite", "Support"}, layers = {"Paper", "Background", "Related"},
      labels = Automatic, planQ = hasDeck, sel = None, radius = 1, rev = 0, query = "", msg = ""},
    Column[{
      Grid[{
        {Style[iSL["\:8868\:793a", "View"], Bold, 10],
         SetterBar[Dynamic[view], {"Story" -> iSL["\:8a71\:306e\:6d41\:308c", "Story"], "Sections" -> iSL["\:7bc0", "Sections"],
           "Focus" -> iSL["\:5468\:8fba", "Around"], "Plan" -> iSL["\:8a08\:753b", "Plan"], "Nodes" -> iSL["\:4e00\:89a7", "Nodes"]}],
         Button[iSL["\:66f4\:65b0", "Reload"], ($iSWVizCache = KeyDrop[$iSWVizCache, g]; rev = rev + 1), Method -> "Queued", ImageSize -> {70, Automatic}]},
        {Style[iSL["\:8fba", "Edges"], Bold, 10],
         TogglerBar[Dynamic[groups], {"Order" -> iSL["\:9806\:5e8f", "order"], "Prerequisite" -> iSL["\:524d\:63d0", "prerequisite"],
           "Support" -> iSL["\:652f\:3048", "support"], "Related" -> iSL["\:5bfe\:6bd4\:30fb\:95a2\:9023", "related"], "Contains" -> iSL["\:5305\:542b", "contains"]}],
         Row[{Checkbox[Dynamic[planQ], Enabled -> hasDeck], " ", iSL["\:8a08\:753b\:3092\:91cd\:306d\:308b (#n = \:679a\:756a\:53f7)", "overlay the plan (#n)"]}]},
        {Style[iSL["\:5c64", "Layers"], Bold, 10],
         TogglerBar[Dynamic[layers], {"Paper" -> iSL["\:672c\:6587", "content"], "Background" -> iSL["\:5468\:8fba\:77e5\:8b58", "background"],
           "Related" -> iSL["\:95a2\:9023\:7814\:7a76", "related work"]}],
         Row[{iSL["\:540d\:524d ", "labels "], SetterBar[Dynamic[labels], {Automatic -> iSL["\:4e3b\:8981", "main"], All -> iSL["\:3059\:3079\:3066", "all"], None -> iSL["\:7bc0\:3060\:3051", "sections"]}],
           Spacer[10], iSL["\:5468\:8fba\:306e\:534a\:5f84 ", "radius "], SetterBar[Dynamic[radius], {1, 2, 3}]}]}},
        Alignment -> {Left, Center}, Spacings -> {1, 0.6}],
      Dynamic[rev; iSWVizSummaryLine[g], TrackedSymbols :> {rev}],
      Grid[{{
        Framed[Pane[
          PaneSelector[{
            "Story" -> Dynamic[iSWVizSafe[SlideGraphVisualize[iSWVizKG[g], "View" -> "Story", "EdgeKinds" -> groups, "Layers" -> layers,
                "Labels" -> labels, "Plan" -> If[TrueQ[planQ], iSWVizPlan[g, d, rev], None], "OnClick" -> ((sel = #) &), "Legend" -> False]],
              TrackedSymbols :> {groups, layers, labels, planQ, rev}, SynchronousUpdating -> False],
            "Sections" -> Dynamic[iSWVizSafe[SlideGraphVisualize[iSWVizKG[g], "View" -> "Sections",
                "EdgeKinds" -> DeleteCases[groups, "Contains"], "Selected" -> sel, "OnClick" -> ((sel = #) &), "Legend" -> False]],
              TrackedSymbols :> {groups, sel, rev}, SynchronousUpdating -> False],
            "Focus" -> Dynamic[If[! StringQ[sel],
                Style[iSL["\:53f3\:306e\:4e00\:89a7\:304b\:56f3\:3067\:30ce\:30fc\:30c9\:3092\:9078\:3076\:3068\:3001\:305d\:306e\:5468\:8fba\:3092\:63cf\:304d\:307e\:3059", "Pick a node to draw its neighborhood"], 11, GrayLevel[0.45]],
                iSWVizSafe[SlideGraphVisualize[iSWVizKG[g], "View" -> "Focus", "Focus" -> sel, "Radius" -> radius,
                  "EdgeKinds" -> Join[groups, {"Contains"}], "Layers" -> layers, "Labels" -> labels,
                  "Plan" -> If[TrueQ[planQ], iSWVizPlan[g, d, rev], None], "OnClick" -> ((sel = #) &), "Legend" -> False]]],
              TrackedSymbols :> {sel, radius, groups, layers, labels, planQ, rev}, SynchronousUpdating -> False],
            "Plan" -> Dynamic[iSWVizSafe[With[{p = iSWVizPlan[g, d, rev], kg = iSWVizKG[g]},
                If[AssociationQ[p], SourceVault`SourceVaultKGPlanView[kg, p],
                  Style[iSL["\:8a08\:753b\:3092\:4f5c\:308c\:307e\:305b\:3093 (KG \:3092\:78ba\:304b\:3081\:3066\:304f\:3060\:3055\:3044)", "Cannot plan (check the KG)"], RGBColor[0.7, 0.1, 0.1]]]]],
              TrackedSymbols :> {rev}, SynchronousUpdating -> False],
            "Nodes" -> Dynamic[iSWVizSafe[SourceVault`SourceVaultKGView[iSWVizKG[g]]], TrackedSymbols :> {rev}, SynchronousUpdating -> False]},
            Dynamic[view]],
          ImageSize -> {880, 690}, Scrollbars -> True, AppearanceElements -> None], FrameStyle -> GrayLevel[0.85]],
        Column[{
          Framed[Pane[Dynamic[iSWVizDetail[g, sel, rev], TrackedSymbols :> {sel, rev}], ImageSize -> {340, 420}, Scrollbars -> {False, True}],
            FrameStyle -> GrayLevel[0.85]],
          Row[{
            Button[iSL["\:5468\:8fba\:3092\:898b\:308b", "Around"], (view = "Focus"), Enabled -> Dynamic[StringQ[sel]]],
            Button[iSL["\:30b9\:30e9\:30a4\:30c9\:3078", "Go to slide"], (msg = iSWVizJump[d, g, sel]), Enabled -> Dynamic[StringQ[sel] && hasDeck], Method -> "Queued"],
            Button[iSL["\:8abf\:6574\:306b\:66f8\:304f", "To Adjust"], (msg = iSWVizToAdjust[d, g, sel]), Enabled -> Dynamic[StringQ[sel] && hasDeck], Method -> "Queued"]}],
          Dynamic[Style[msg, 9, GrayLevel[0.35]]],
          Row[{iSL["\:691c\:7d22 ", "Search "], InputField[Dynamic[query], String, FieldSize -> 18, ContinuousAction -> False]}],
          Dynamic[PopupMenu[Dynamic[sel], iSWVizNodeChoices[g, query], FieldSize -> 26], TrackedSymbols :> {query, rev}],
          SourceVault`SourceVaultKGLegend[lang, 3]}, Spacings -> 0.6]}},
        Alignment -> {Left, Top}]}, Spacings -> 0.8],
    SaveDefinitions -> False]];

SlideGraphViewer[] := SlideGraphViewer[iSWResolveTargetNb[]];
SlideGraphViewer[src_] := Module[{kg, gid, title, deck},
  If[! iSWKGEnsure[], Return[iSWKGFail[]]];
  kg = If[StringQ[src], iSWVizKG[src], iSWKGResolve[src]];
  If[! AssociationQ[kg],
    If[Head[src] === NotebookObject, iSWStatus[src, iSL["KG \:304c\:7121\:3044 (\:5148\:306b KG\:69cb\:7bc9)", "No KG yet (build it first)"]]; iSWStatusClearLater[src]];
    Return[kg]];
  gid = kg["GraphId"];
  $iSWVizCache[gid] = <|"Stamp" -> iSWVizStamp[gid], "KG" -> kg|>;
  title = With[{t = Lookup[kg, "Title", ""]}, If[StringQ[t] && t =!= "", t, gid]];
  deck = If[Head[src] === NotebookObject, src, None];
  CreateDocument[{
      Cell[iSL["\:77e5\:8b58\:30b0\:30e9\:30d5: ", "Knowledge graph: "] <> title, "Subsection"],
      ExpressionCell[iSWVizPanel[gid, deck], "Output", ShowCellLabel -> False, CellMargins -> {{10, 10}, {6, 6}}]},
    WindowTitle -> iSL["\:77e5\:8b58\:30b0\:30e9\:30d5 \:2014 ", "Knowledge graph \:2014 "] <> title, WindowSize -> {1280, 900},
    Saveable -> False, ShowCellBracket -> False, WindowMargins -> {{40, Automatic}, {Automatic, 30}}]];

iSWGraphViewerAction[nb_] := SlideGraphViewer[nb];

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
  SlideGraphBuild[] / SlideGraphApply[]     \:2192 \:77e5\:8b58\:30b0\:30e9\:30d5 (KG) \:304b\:3089\:8074\:304d\:624b\:30fb\:6642\:9593\:306b\:5fdc\:3058\:305f\:30b9\:30e9\:30a4\:30c9\:3092\:751f\:6210 (v1.20)
      \:6587\:732e\:306b\:548c\:8a33\:30ce\:30fc\:30c8\:304c\:7121\:3051\:308c\:3070\:30d7\:30ed\:30f3\:30d7\:30c8\:306e\:30b7\:30ca\:30ea\:30aa\:304b\:3089 KG (\:95a2\:9023\:7814\:7a76\:306e\:5019\:88dc\:3064\:304d\:3002SlideGraphSeedScenario / SlideGraphRelated\:3001v1.30)
      \:300c\:751f\:6210\:300d\:306f\:524d\:56de\:306e\:751f\:6210\:30b9\:30e9\:30a4\:30c9\:3092\:7f6e\:304d\:63db\:3048\:3001\:8cea\:7591\:5fdc\:7b54\:306f KG \:306b\:4fdd\:5b58\:3057\:3066\:5f15\:304d\:7d99\:3050
  SlideGraphSurvey[{ids}, \"survey.nb\"]   \:2192 \:8907\:6570\:306e KG \:3092\:5408\:6210\:3057\:305f\:30b5\:30fc\:30d9\:30a4\:30c7\:30c3\:30ad
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
  SlidePDFFigure[\"key|path\", page]     \:2192 \:6587\:732e PDF \:306e\:30da\:30fc\:30b8/\:9818\:57df\:3092\:56f3\:3068\:3057\:3066\:5207\:308a\:51fa\:3057
  SlideInsertTalk[]                        \:2192 \:30c8\:30fc\:30af\:30bb\:30eb (\:767a\:8868\:539f\:7a3f\:3002Slideshow \:3067\:975e\:8868\:793a\:3001md \:3067\:306f talk: \:884c)
  SlideInsertQA[]                          \:2192 \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb (\:60f3\:5b9a\:554f\:7b54\:3002Q: / A: \:306e\:884c\:3002md \:3067\:306f qa: \:884c)
  SlideQAGenerate[]                        \:2192 \:5909\:66f4\:3055\:308c\:305f\:30b9\:30e9\:30a4\:30c9\:3068 QA \:7121\:3057\:30b9\:30e9\:30a4\:30c9\:3060\:3051\:60f3\:5b9a\:554f\:7b54\:3092\:4f5c\:308b (\:30d1\:30ec\:30c3\:30c8\:306e\:300cQA \:751f\:6210\:300d)
  SlideQAMarkCurrent[]                     \:2192 \:65e2\:5b58\:306e QA \:30bb\:30eb\:306b\:4eca\:306e\:30b9\:30e9\:30a4\:30c9\:306e\:5370\:3060\:3051\:6253\:3064 (LLM \:4e0d\:8981\:3001\:5185\:5bb9\:306f\:305d\:306e\:307e\:307e)
  SlideQAGenerateAll[] / SlideQAUpdateAll[] \:2192 \:5168\:679a\:4f5c\:308a\:76f4\:3059 / \:5168\:679a\:3092\:65e2\:5b58\:3092\:6d3b\:304b\:3057\:3066\:898b\:76f4\:3059
  SlideQAView[] / SlideQAStateView[]       \:2192 \:60f3\:5b9a\:554f\:7b54\:306e\:4e00\:89a7 / \:30b9\:30e9\:30a4\:30c9\:3054\:3068\:306e\:72b6\:614b (\:672a\:4f5c\:6210\:30fb\:8981\:66f4\:65b0)
  SlideQAFromPack[]                        \:2192 \:65e2\:5b58\:306e QA \:30d1\:30c3\:30af\:3092\:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:3078\:623b\:3059 (\:79fb\:884c\:7528\:3001LLM \:672a\:4f7f\:7528)
  SlideQABuild[]                           \:2192 \:8cea\:7591\:5fdc\:7b54\:30bb\:30eb\:2192 gpt-realtime \:304c\:5f15\:3051\:308b QA \:30d1\:30c3\:30af (\:300c\:767b\:9332\:300d\:304b\:3089\:3082\:81ea\:52d5)
  SlideDeckChangeStatus[]                  \:2192 \:300c\:767b\:9332\:300d\:304c\:4f55\:3092\:3084\:308a\:76f4\:3059\:304b (mp4 / QA \:306e\:5dee\:5206)
  SlideDeckMarkVideoCurrent[]              \:2192 \:4eca\:306e mp4 \:3092\:300c\:6700\:65b0\:300d\:3068\:3057\:3066\:8a18\:9332 (\:65e2\:5b58\:30c7\:30c3\:30ad\:306e\:79fb\:884c\:7528\:30021 \:56de\:3060\:3051\:306e\:518d\:751f\:6210\:3092\:907f\:3051\:308b)
      \:5c55\:958b\:306f\:5404\:30b9\:30e9\:30a4\:30c9\:672b\:5c3e\:306b talk: \:539f\:7a3f\:3092\:751f\:6210\:3002\:539f\:7a3f\:306e\:7121\:3044\:679a\:306f\:300c\:539f\:7a3f\:300d(SlideTalkFill) \:3067\:57cb\:3081\:308b
  SlidePDFImages[\"key|path\"]           \:2192 PDF \:57cb\:3081\:8fbc\:307f\:753b\:50cf(\:5199\:771f\:30fb\:30e9\:30b9\:30bf\:56f3)\:306e\:62bd\:51fa
  SlideDeckFigure[\"deck.nb\", n]        \:2192 \:904e\:53bb\:30c7\:30c3\:30ad\:306e\:30b9\:30e9\:30a4\:30c9 1 \:679a\:3092\:753b\:50cf\:5f15\:7528
      locator \:306f URL / arxiv:ID / Google Slides \:3082\:53ef (\:81ea\:52d5\:30c0\:30a6\:30f3\:30ed\:30fc\:30c9+PDF \:5316+\:30ad\:30e3\:30c3\:30b7\:30e5)\:3002\:539f\:56f3\:5f15\:7528\:304c\:65e2\:5b9a
  SlideTalkFill[] / SlideTalkBuild[\"deck.nb\"] \:2192 \:539f\:7a3f\:306e\:7121\:3044\:679a\:306b\:539f\:7a3f\:3092\:66f8\:304f / \:539f\:7a3f\:3092 deck_talk.md \:3078\:66f8\:304d\:51fa\:3057 (\:518d\:751f\:30fb\:767b\:9332\:306b\:306f\:4e0d\:8981)
  SlideDeckRegister[\"deck.nb\"]             \:2192 \:30bf\:30a4\:30c8\:30eb/URL/\:539f\:7a3f\:3092 SourceVault \:767b\:9332\:7c3f\:3078 (\:30c8\:30fc\:30af\:30bb\:30eb\:304b\:3089\:76f4\:63a5)
  SlideTalkMeta[nb, \"SlideURL\"->url]       \:2192 \:767b\:9332\:7528\:30e1\:30bf (URL/\:5225\:540d/PL) \:3092\:30c7\:30c3\:30ad\:306b\:6c38\:7d9a\:5316
  SlideDeckRegistry[]                      \:2192 \:767b\:9332\:6e08\:307f\:767a\:8868\:306e\:4e00\:89a7
  SlideDeckUpload[nb] / SlideUploadCredential[nb] \:2192 mp4 \:3092 sftp \:3067 web \:30b5\:30fc\:30d0\:3078\:914d\:7f6e (\:6307\:793a\:30bb\:30eb\:306e Host: \:884c) / \:30d1\:30b9\:30ef\:30fc\:30c9\:4fdd\:5b58 (NBAccess \:7ba1\:8f44)
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
SlideWorkflow`Private`$iSWAgentHeads = {"SlideThemeColor", "SlideApplyScenario",
  "SlideTable", "SlidePDFFigure", "SlidePDFImages", "SlideDeckFigure",
  "SlideSourceFile", "SlideDeckInsertScenario",
  "SlideDeckOverview", "SlideDeckSlides",
  "SlideNotebookOutline", "SlideNotebookText", "SlideNotebookFigure",
  "SlideNotebookFormula",
  "SlideGraphIngest", "SlideGraphSpec", "SlideGraphPlan", "SlideGraphPlanView",
  "SlideGraphGenerate", "SlideGraphApply", "SlideGraphView", "SlideGraphLoad", "SlideGraphShow",
  "SlideGraphSeed", "SlideGraphSectionText"};

Quiet @ Check[NBAccess`NBRegisterAllowedHeads[SlideWorkflow`Private`$iSWAgentHeads], Null];

(* 2026-09-12: \:8a31\:53ef head \:767b\:9332 (\:5c64 1) \:3060\:3051\:3067\:306f\:8db3\:308a\:306a\:3044\:3002EffectClass \:5c64 (\:5c64 2) \:3067\:306f
   SlideWorkflow` \:6587\:8108\:306e\:975e\:767b\:9332 head \:306f UnknownUserCode -> AskUserAllowed \:3068\:306a\:308a\:3001
   base \:304c Permit \:3067\:3082 NeedsApproval \:3078\:964d\:683c\:3059\:308b (NBAccess.wl \:306e NBImport override \:306e
   \:30b3\:30e1\:30f3\:30c8\:3068\:540c\:3058\:7f60)\:3002\:4fe1\:983c package head \:3068\:3057\:3066\:767b\:9332\:3059\:308b\:3068\:4e21\:65b9\:306e\:5c64\:304c Permit \:306b\:306a\:308b\:3002
   **"Slide*" \:306e\:30ef\:30a4\:30eb\:30c9\:30ab\:30fc\:30c9\:3067\:306f\:767b\:9332\:3057\:306a\:3044**: SlideDeckUpload (sftp \:3067 web \:3078\:516c\:958b) /
   SlideDeckExportVideo / SlidePlay / SlideRemoteStart \:307e\:3067\:627f\:8a8d\:4e0d\:8981\:306b\:306a\:3063\:3066\:3057\:307e\:3046\:3002
   \:30a8\:30fc\:30b8\:30a7\:30f3\:30c8\:304c\:5b9f\:969b\:306b\:547c\:3076\:8aad\:307f\:53d6\:308a\:7cfb + \:66f8\:8fbc\:307f\:306e\:552f\:4e00\:306e\:5165\:53e3\:3060\:3051\:3092\:5217\:6319\:3059\:308b\:3002 *)
Quiet @ Check[
  NBAccess`NBRegisterTrustedPackageHeads["SlideWorkflow`", SlideWorkflow`Private`$iSWAgentHeads],
  Null];

If[AssociationQ[ClaudeCode`$ClaudePackageKeywordMap],
  ClaudeCode`$ClaudePackageKeywordMap["SlideWorkflow"] =
    {"SlideWorkflow", "SlideDeck", "Sliden", "slide", "slideshow", "deck",
     "presentation",
     "\:30b9\:30e9\:30a4\:30c9", "\:30c7\:30c3\:30ad", "\:30d7\:30ec\:30bc\:30f3",
     "\:767a\:8868\:8cc7\:6599", "\:30b9\:30e9\:30a4\:30c9\:30b7\:30e7\:30fc", "\:8aad\:307f\:4e0a\:3052", "\:97f3\:58f0", "\:30ca\:30ec\:30fc\:30b7\:30e7\:30f3",
     "KG", "\:77e5\:8b58\:30b0\:30e9\:30d5", "\:30b5\:30fc\:30d9\:30a4"}
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