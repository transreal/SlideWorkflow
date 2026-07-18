(* SlideWorkflow end-to-end test suite (ASCII only) *)

$pass = 0; $fail = 0;
check[label_, cond_] := If[TrueQ[cond],
  $pass++; Print["PASS  ", label],
  $fail++; Print["FAIL  ", label]];

pkg = FileNameJoin[{"C:", "Users", "imai_", "Dropbox", "Mathematica-oneDrive", "MyPackages", "SlideWorkflow.wl"}];
tdir = FileNameJoin[{DirectoryName[$InputFileName], "slidewf_test"}];
If[!DirectoryQ[tdir], CreateDirectory[tdir]];

(* ---- T1: load ---- *)
Get[pkg];
check["T1 package loads", MemberQ[$Packages, "SlideWorkflow`"] &&
  ValueQ[SlideWorkflow`$SlideImageSize]];

(* ---- test assets ---- *)
imgA = FileNameJoin[{tdir, "imgA.png"}];
imgB = FileNameJoin[{tdir, "imgB.png"}];
pageP = FileNameJoin[{tdir, "page.png"}];
Export[imgA, Image[ConstantArray[{1., 0.2, 0.2}, {270, 480}]]];
Export[imgB, Image[ConstantArray[{0.2, 0.8, 0.2}, {400, 600}]]];
Export[pageP, Image[ConstantArray[{0.1, 0.2, 0.9}, {1080, 1920}]]];

longbullets = StringRiffle[Table[
  "- bullet line number " <> ToString[i] <> " with a reasonably long tail to consume vertical space in the rendered slide output",
  {i, 24}], "\n"];

md = StringRiffle[{
  "---",
  "Title: SlideWorkflow Test Deck",
  "Event: Verification Meeting",
  "Author: Imai",
  "Date: 2026/07/13",
  "---",
  "",
  "## \:6982\:8981 overview {expected=20}",
  "- point one",
  "  - sub point",
  "    - subsub point",
  "> paragraph under level three",
  "plain text line",
  "![w=300](" <> imgA <> ")",
  "",
  "## two figures",
  "![](" <> imgA <> ")![](" <> imgB <> ")",
  "",
  "## !image " <> pageP,
  "",
  "## overflow slide",
  longbullets,
  ""}, "\n"];

(* ---- T2: markdown -> scenario ---- *)
sc = SlideScenarioFromMarkdown[md];
check["T2a slide count 4", Length[sc["Slides"]] === 4];
check["T2b meta", sc["Title"] === "SlideWorkflow Test Deck" && sc["Author"] === "Imai"];
s1 = sc["Slides"][[1]];
check["T2c expected seconds", s1["ExpectedSeconds"] === 20];
check["T2d styles", (First /@ s1["Content"]) ===
  {"Item", "Subitem", "Subsubitem", "SubsubitemParagraph", "Text", "Image"}];
check["T2e image width", s1["Content"][[6, 2, "Width"]] === 300];
check["T2f images pair", sc["Slides"][[2, "Content", 1, 1]] === "Images" &&
  Length[sc["Slides"][[2, "Content", 1, 2]]] === 2];
check["T2g imagepage", sc["Slides"][[3, "ImagePage"]] === pageP];

(* ---- T3: round trip ---- *)
md2 = SlideScenarioToMarkdown[sc];
sc2 = SlideScenarioFromMarkdown[md2];
check["T3 markdown round trip", sc2 === sc];

(* ---- T4: build ---- *)
deck = FileNameJoin[{tdir, "deck.nb"}];
r = SlideDeckBuild[sc, deck];
check["T4a build returns path", r === deck && FileExistsQ[deck]];
data = SlideDeckSlides[deck];
check["T4b slide count 5 (title+4)", Length[data["Slides"]] === 5];
titles = SlideWorkflow`Private`iSlideTitle /@ data["Slides"];
check["T4c titles", titles[[2]] === "\:6982\:8981 overview" && titles[[5]] === "overflow slide"];
check["T4d prelude has Section header", MemberQ[data["Prelude"], Cell[_, "Section", ___]]];
check["T4e expected tag", MemberQ[data["Slides"][[2]],
  Cell[_, "Subsection", ___, CellTags -> {"Expected:20", "Top"}, ___]]];

(* ---- T5: overview ---- *)
ov = SlideDeckOverview[deck];
check["T5 overview dataset", Head[ov] === Dataset && Length[ov] === 5];

(* ---- T6/T7: rasterize ---- *)
ovflseen = False;
imgs = Quiet[
  Check[SlideDeckImages[deck], ovflseen = True; $Failed, SlideDeckImages::ovflw],
  SlideDeckImages::ovflw];
(* Check returns fallback on message; re-evaluate without Check to get images *)
If[imgs === $Failed && ovflseen,
  imgs = Quiet[SlideDeckImages[deck], SlideDeckImages::ovflw]];
check["T6a five images", MatchQ[imgs, {__Image}] && Length[imgs] === 5];
check["T6b all 1920x1080", AllTrue[ImageDimensions /@ imgs, # === {1920, 1080} &]];
check["T6c overflow warned", ovflseen];
pv = PixelValue[imgs[[4]], {960, 540}];
check["T7a imagepage center blue", pv[[3]] > 0.7 && pv[[1]] < 0.3];
check["T7b title slide mostly white", Mean[Flatten[ImageData[ImageTake[imgs[[1]], {1, 50}, {1800, 1920}]]]] > 0.95];

(* ---- T8: export images ---- *)
outdir = FileNameJoin[{tdir, "deck_slides"}];
files = SlideDeckExportImages[deck, outdir];
check["T8 png files", MatchQ[files, {__String}] && AllTrue[files, FileExistsQ] && Length[files] === 5];

(* ---- T9: export video ---- *)
mp4 = FileNameJoin[{tdir, "deck.mp4"}];
vres = SlideDeckExportVideo[imgs, mp4];
dur = QuantityMagnitude[Import[mp4, "Duration"]];
check["T9a mp4 written", vres === mp4 && FileExistsQ[mp4]];
check["T9b sliden duration 179/30s", Abs[dur - 179/30.] < 0.2];

(* ---- T10: edits ---- *)
v2 = FileNameJoin[{tdir, "deck_v2.nb"}];
newslide = <|"Title" -> "replaced slide", "Content" -> {{"Item", "new item"}}|>;
SlideDeckReplaceSlide[deck, 3, newslide, "Target" -> v2];
t0 = SlideWorkflow`Private`iSlideTitle /@ SlideDeckSlides[deck]["Slides"];
t2 = SlideWorkflow`Private`iSlideTitle /@ SlideDeckSlides[v2]["Slides"];
check["T10a replace to target", t2[[3]] === "replaced slide" && t0[[3]] === "two figures"];
SlideDeckInsertSlide[v2, 2, <|"Title" -> "inserted", "Content" -> {}|>];
check["T10b insert in place + backup", FileExistsQ[v2 <> ".bak"] &&
  Length[SlideDeckSlides[v2]["Slides"]] === 6 &&
  SlideWorkflow`Private`iSlideTitle[SlideDeckSlides[v2]["Slides"][[2]]] === "inserted"];
SlideDeckDeleteSlide[v2, 2];
check["T10c delete", Length[SlideDeckSlides[v2]["Slides"]] === 5];
SlideDeckMoveSlide[v2, 2, 3];
tm = SlideWorkflow`Private`iSlideTitle /@ SlideDeckSlides[v2]["Slides"];
check["T10d move", tm[[3]] === "\:6982\:8981 overview"];

(* ---- T11: real template smoke ---- *)
tpl = FileNameJoin[{"C:", "Users", "imai_", "Dropbox", "Mathematica-oneDrive", "MyPackages", "Templates", "slides-template.nb"}];
tdata = SlideDeckSlides[tpl];
check["T11a template slides 4", Length[tdata["Slides"]] === 4];
timgs = Quiet[SlideDeckImages[tpl, "Slides" -> 1 ;; 2], SlideDeckImages::ovflw];
check["T11b template raster", MatchQ[timgs, {__Image}] &&
  AllTrue[ImageDimensions /@ timgs, # === {1920, 1080} &]];
Export[FileNameJoin[{tdir, "tpl1.png"}], timgs[[1]]];
Export[FileNameJoin[{tdir, "tpl2.png"}], timgs[[2]]];
Export[FileNameJoin[{tdir, "deck2.png"}], imgs[[2]]];
Export[FileNameJoin[{tdir, "deck5.png"}], imgs[[5]]];

(* ---- T12: cite / keep / end-appendix markdown extensions ---- *)
md12 = StringRiffle[{
  "## quoted figure",
  "- claim from a paper",
  "cite: (Turing, 1936)",
  "<<FIG2>>",
  "![](" <> imgA <> ")",
  "",
  "## !end",
  "appendix memo line 1",
  "appendix memo line 2",
  ""}, "\n"];
sc12 = SlideScenarioFromMarkdown[md12];
check["T12a cite parsed", MemberQ[sc12["Slides"][[1, "Content"]], {"Cite", "(Turing, 1936)"}]];
check["T12b keep parsed", MemberQ[sc12["Slides"][[1, "Content"]], {"Keep", 2}]];
check["T12c appendix parsed", sc12["Appendix"] === {"appendix memo line 1", "appendix memo line 2"}];
check["T12d round trip", SlideScenarioFromMarkdown[SlideScenarioToMarkdown[sc12]] === sc12];

(* ---- T13: cite cell + keep cell build ---- *)
keepCell = Cell[BoxData[ToBoxes[Graphics[{Disk[]}, ImageSize -> 100]]], "Input"];
cells13 = Block[{SlideWorkflow`Private`$iSlideKeepCells = {Null, keepCell}},
  SlideWorkflow`Private`iBuildSlideCells[sc12["Slides"][[1]]]];
check["T13a cite cell small font", MemberQ[cells13,
  Cell[TextData[StyleBox[s_String /; StringContainsQ[s, "(Turing, 1936)"],
    ___, FontSize -> 9, ___]], "Text", ___, CellTags -> "Citation", ___]]];
check["T13b keep cell placed", MemberQ[cells13, keepCell]];

(* ---- T14: build with end marker + appendix ---- *)
deck14 = FileNameJoin[{tdir, "deck14.nb"}];
SlideDeckBuild[md12, deck14];
d14 = SlideDeckSlides[deck14];
check["T14a slides exclude end/appendix", Length[d14["Slides"]] === 2]; (* title + 1 *)
check["T14b appendix present", Length[d14["Appendix"]] >= 3 &&
  SlideWorkflow`Private`iEndMarkerNavQ[First[d14["Appendix"]]]];
check["T14c appendix memo cells", Count[d14["Appendix"],
  Cell[s_String /; StringStartsQ[s, "appendix memo line"], "Text", ___]] === 2];

(* ---- T15: edits preserve appendix ---- *)
v14 = FileNameJoin[{tdir, "deck14_v2.nb"}];
SlideDeckReplaceSlide[deck14, 2, <|"Title" -> "replaced", "Content" -> {{"Item", "x"}}|>, "Target" -> v14];
d15 = SlideDeckSlides[v14];
check["T15 appendix preserved on edit", Length[d15["Appendix"]] === Length[d14["Appendix"]]];

(* ---- T16: raster filter excludes meta/prompt cells, keeps citation ---- *)
f16 = SlideWorkflow`Private`iRasterFilterCells[{
  Cell["", "SlideShowNavigationBar", CellTags -> "SlideShowHeader"],
  Cell["t", "Subsection"],
  Cell["memo", "Note"],
  Cell["dir", "Directive"],
  Cell["dict", "Dictionary"],
  Cell["bib", "Bibliography"],
  Cell["prompt", "SlidePrompt"],
  Cell[TextData[StyleBox["\:51fa\:5178: x", FontSize -> 9]], "Text", CellTags -> "Citation"],
  Cell["body", "Item"]}, Automatic];
check["T16 meta excluded, citation kept", (First /@ f16) ===
  {"t", TextData[StyleBox["\:51fa\:5178: x", FontSize -> 9]], "body"}];

(* ---- T17: interactive layer (FE 非依存部分) ---- *)
(* 2026-07-13: interactive layer merged into SlideWorkflow.wl (single file) *)
check["T17a interactive merged into base", Length[DownValues[SlideExpand]] > 0 &&
  Length[DownValues[ShowSlidePalette]] > 0 &&
  StringQ[SlideWorkflow`$SlideWorkflowInteractiveVersion] &&
  !FileExistsQ[FileNameJoin[{"C:", "Users", "imai_", "Dropbox", "Mathematica-oneDrive",
    "MyPackages", "SlideWorkflow_interactive.wl"}]]];
resp17 = "```markdown\nnote before\n## New Title {expected=30}\n- point\ncite: https://example.org\n<<FIG1>>\n```";
norm17 = SlideWorkflow`Private`iSWNormalizeScenarioResponse[resp17, "fallback"];
check["T17b normalize strips fences and preface", StringStartsQ[norm17, "## New Title"]];
sc17 = SlideScenarioFromMarkdown[norm17];
check["T17c normalized parses", Length[sc17["Slides"]] === 1 &&
  MemberQ[sc17["Slides"][[1, "Content"]], {"Cite", "https://example.org"}] &&
  MemberQ[sc17["Slides"][[1, "Content"]], {"Keep", 1}]];
norm17b = SlideWorkflow`Private`iSWNormalizeScenarioResponse["- a\n- b", "MyTitle"];
check["T17d title fallback", StringStartsQ[norm17b, "## MyTitle"]];
p17 = SlideWorkflow`Private`iSWParseNumbered["[1] Hello\\nWorld\n[2] Second line\njunk\n[3] Third"];
check["T17e numbered parse", p17[1] === "Hello\nWorld" && p17[3] === "Third" &&
  StringStartsQ[p17[2], "Second line"]];

(* ---- T18: slide -> markdown with keeps ---- *)
slidecells18 = {
  Cell["", "SlideShowNavigationBar", CellTags -> "SlideShowHeader"],
  Cell["Title18", "Subsection", CellTags -> {"Expected:25", "Top"}],
  Cell["p", "SlidePrompt"],
  Cell["i1", "Item"],
  Cell["i2", "Subitem"],
  Cell["para", "ItemParagraph"],
  keepCell,
  Cell[TextData[StyleBox["\:51fa\:5178: (X, 2020)", FontSize -> 9]], "Text", CellTags -> "Citation"],
  Cell["plain", "Text"]};
{md18, keeps18} = SlideWorkflow`Private`iSWSlideToMarkdown[slidecells18];
check["T18a md lines", md18 === StringRiffle[{
  "## Title18 {expected=25}", "- i1", "  - i2", "> para", "<<FIG1>>",
  "cite: (X, 2020)", "plain"}, "\n"]];
check["T18b keeps", keeps18 === {keepCell}];
check["T18c expand prompt has cite rule", StringContainsQ[
  SlideWorkflow`Private`iSWExpandPrompt["p", "t", md18, 1, ""], "cite:"]];

(* ---- T19: agent-mode task template (SlideApplyScenario \:5951\:7d04) ---- *)
task19 = SlideWorkflow`Private`iSWExpandAgentTask[3, "prompt text", "Title X", md18, 2];
check["T19a task names apply fn once", StringContainsQ[task19, "SlideApplyScenario[3, md]"] &&
  StringContainsQ[task19, "\"Figures\"->{g1, ...}"]];
check["T19b task has cite + theme + font rules", StringContainsQ[task19, "cite:"] &&
  StringContainsQ[task19, "SlideThemeColor"] && StringContainsQ[task19, "$SlideFontFamily"] &&
  StringContainsQ[task19, "Module"]];
check["T19c fig numbering k+1", StringContainsQ[task19, "<<FIG3>>"] &&
  StringContainsQ[task19, "<<FIG2>>"]];
check["T19d mode default Agent", SlideWorkflow`$SlideExpandMode === "Agent"];

(* ---- T19e/f: k=0 wording + dispatch-bypass eval cell ---- *)
task19e = SlideWorkflow`Private`iSWExpandAgentTask[1, "p", "", "## t\n- a", 0];
check["T19e no FIG range when k=0", !StringContainsQ[task19e, "FIG0"] &&
  StringContainsQ[task19e, "<<FIG1>>"]];
cell19f = SlideWorkflow`Private`iSWAgentEvalCell["dummy task"];
s19f = ToString[cell19f, InputForm];
check["T19f eval cell bypasses dispatch", MatchQ[cell19f, Cell[BoxData[_], "Input", ___]] &&
  StringContainsQ[s19f, "ClaudeEval"] &&
  StringContainsQ[s19f, "ClaudeEvalPromptRouterDispatch"] &&
  StringContainsQ[s19f, "ClaudeEvalNaturalDispatch"] &&
  StringContainsQ[s19f, "ClaudeEvalMode"] && StringContainsQ[s19f, "Single"] &&
  StringContainsQ[s19f, "dummy task"]];

(* ---- T20: figure normalization ---- *)
f20a = SlideWorkflow`Private`iSWFigureCell[Graphics[{Disk[]}]];
f20b = SlideWorkflow`Private`iSWFigureCell[Image[ConstantArray[0.5, {10, 10}]]];
f20c = SlideWorkflow`Private`iSWFigureCell[keepCell];
check["T20 figure cells", MatchQ[f20a, Cell[BoxData[_], "Input", ___]] &&
  MatchQ[f20b, Cell[BoxData[_], "Input", ___]] && f20c === keepCell &&
  SlideWorkflow`Private`iVisualCellQ[f20a]];

(* ---- T21: \:7e26\:3042\:3075\:308c\:6642\:306e\:81ea\:52d5\:30ea\:30d5\:30ed\:30fc (\:5168\:5e45\:6d3b\:7528) ---- *)
contentRight[img_] := Module[{d = ImageData[ColorConvert[img, "Grayscale"]], cols},
  cols = Position[Total[1 - d, {1}], _?(# > 0.5 &)];
  If[cols === {}, 0, Max[Flatten[cols]]]];

md21 = StringRiffle[Join[
  {"## fits already", "- short bullet one", "- short bullet two", "",
   "## tall slide"},
  Table["- \:9805\:76ee " <> ToString[i] <>
    ": \:7e26\:306b\:3042\:3075\:308c\:308b\:307b\:3069\:9577\:3081\:306e\:672c\:6587\:3092\:6301\:3064\:7b87\:6761\:66f8\:304d\:9805\:76ee\:3067\:3059\:3002\:6298\:308a\:8fd4\:3057\:5e45\:3092\:5e83\:3052\:308c\:3070\:884c\:6570\:304c\:6e1b\:308a\:3001\:5168\:5e45\:3092\:4f7f\:3048\:308b\:306f\:305a\:3067\:3059\:3002",
    {i, 12}]], "\n"];
deck21 = FileNameJoin[{tdir, "deck21.nb"}];
SlideDeckBuild[md21, deck21, "TitleSlide" -> False];
off21 = Quiet[SlideDeckImages[deck21, "Reflow" -> False], SlideDeckImages::ovflw];
on21 = Quiet[SlideDeckImages[deck21], SlideDeckImages::ovflw];
check["T21a dims unchanged", AllTrue[Join[ImageDimensions /@ off21, ImageDimensions /@ on21],
  # === {1920, 1080} &]];
check["T21b fitting slide untouched by reflow", ImageData[on21[[1]]] === ImageData[off21[[1]]]];
check["T21c tall slide uses more width with reflow",
  contentRight[on21[[2]]] > contentRight[off21[[2]]] + 100];
check["T21d tall slide reaches near right margin",
  contentRight[on21[[2]]] > 1920 - 100 - 250];
Export[FileNameJoin[{tdir, "t21_off.png"}], off21[[2]]];
Export[FileNameJoin[{tdir, "t21_on.png"}], on21[[2]]];

Print["==== pass: ", $pass, "  fail: ", $fail, " ===="];
If[$fail > 0, Exit[1]];
