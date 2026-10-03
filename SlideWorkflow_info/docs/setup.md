# SlideWorkflow Setup Guide

## 1. Prerequisites

- **Mathematica / Wolfram Engine**: Version 13.0 or later is recommended. The package uses notebook expression manipulation, `Rasterize`, and `ScreenStyleEnvironment`.
- **OS**: Windows 11 is assumed. On macOS/Linux, adapt path separators and shell commands as needed.
- **External tools**:
  - To write mp4 files with `SlideDeckExportVideo`, FFmpeg may be required depending on your environment. If it is not installed, install it beforehand and add it to your PATH.
  - The package does not depend on the clipboard or window snapshots, so headless (wolframscript) environments produce the same results.
  - To use `SlideExpand[]` of the interactive editing layer with the default `$SlideExpandMode="Agent"`, you need an environment where `ClaudeEval` can be called via [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime). Without it, switching to `$SlideExpandMode = "Direct"` still works (see chapter 7).
  - To use the presentation features (the SlideTalk family, `SlidePlay`, real-time voice dialogue, `SlideRemoteStart` for the handheld remote, QA cells, and so on), [SourceVault](https://github.com/transreal/SourceVault) is required. Basic features such as slide generation and image/video export work without it. The handheld remote integration is Windows-only.
  - To upload a Sliden mp4 with `SlideDeckUpload` / `SlideDeckRegister`, you need an sftp destination (a `Host: sftp://user@host/dir` line in the Directive cell) and either the built-in `CopyFile` to a remote file or an sftp-capable `curl` (such as the one bundled with Git for Windows). The password is kept in the system credential store through NBAccess.
- **Fonts** (optional): "Hiragino Kaku Gothic Std" is used by default for title emphasis. If this font is not available on your Windows environment, override `$SlideHeavyFontFamily` with a font name available on your machine.

## 2. Installation

1. Get the repository.

   ```
   git clone https://github.com/transreal/SlideWorkflow.git
   ```

2. Place `SlideWorkflow.wl` directly in the same directory as your other `.wl` packages (hereafter `$packageDirectory`). Do not create subfolders; keep the layout flat.

3. On the Notebook side, add `$packageDirectory` to `$Path` (do not write a package-name subpath).

   ```wolfram
   AppendTo[$Path, $packageDirectory];
   ```

   If you already use claudecode, `$Path` is set automatically and this step is unnecessary.

4. Load the package in a UTF-8 environment.

   ```wolfram
   Block[{$CharacterEncoding = "UTF-8"},
     Needs["SlideWorkflow`", "SlideWorkflow.wl"]];
   ```

   Specifying only the file name works because `$packageDirectory` is on `$Path`.

   The former `SlideWorkflow_interactive.wl` (interactive editing features such as the palette, slide expansion, and translation) was merged into `SlideWorkflow.wl` on 2026-07-13. You do not need to `Needs` it separately.

## 3. Dependent Packages (optional)

- [NotebookExtensions](https://github.com/transreal/NotebookExtensions): If `NotebookExtensions`$fontFamily` is defined, `$SlideFontFamily` uses it automatically. The package works without it, but installing it is recommended for font consistency. Place it directly in `$packageDirectory` and load it with `Needs`.
- [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime): Required to use `SlideExpand[]` in the default `"Agent"` mode (the `ClaudeEval` execution path). If you do not use it, set `$SlideExpandMode = "Direct"`.
- [NBAccess](https://github.com/transreal/NBAccess): Used to call the LLM in `"Direct"` mode (`NBAccess`\`$NBLLMQueryFunc`) and to store the sftp password as a SystemCredential (`SlideUploadCredential`).
- [SourceVault](https://github.com/transreal/SourceVault): Used for local speech synthesis and playback of presentation scripts (`SlideTalkFromMarkdown`, etc.), real-time voice dialogue, the deck registry and QA packs, and literature/PDF references (`SlidePDFFigure`, etc.). Slide generation and image/video export work as usual without it. Place it directly in `$packageDirectory` and load it with `Needs`. The voice features rely on [SourceVault_voice](https://github.com/transreal/SourceVault_voice) and [SourceVault_realtime](https://github.com/transreal/SourceVault_realtime), and QA packs rely on [SourceVault_talkqa](https://github.com/transreal/SourceVault_talkqa).

## 4. API Key Settings

SlideWorkflow itself only performs local Notebook operations and image/video export, and uses no external API keys of its own. No settings are needed for these. When you use the `"Agent"` mode of `SlideExpand[]`, authentication and approval gates follow the settings of `ClaudeRuntime`/`ClaudeEval`. The settings for speech synthesis, real-time voice dialogue, and QA packs follow `SourceVault`. For sftp uploads, run `SlideUploadCredential[url]` once to save the password through NBAccess. Use `SlideUploadCredentialQ[url]` to check whether it is saved, and `SlideUploadCredential[url, None]` to delete it.

## 5. Basic Configuration Variables (adjust as needed)

```wolfram
$SlideImageSize = {1920, 1080};
$SlideStyleDefinitions = "Normal use.nb";
$SlideMargins = {{0, 0}, {0, 0}};
$SlideExpandMode = "Agent";
$SlideTranslationLanguage = "English";
```

- `$SlideTheme`: An association of color palettes for unifying figure colors.
- `$SlideStyleDefinitions`: The stylesheet name used for deck generation. The default is "Normal use.nb", following `Templates/slides-template.nb`.
- `$SlideIncludeInput`: The default for whether Input/Code cells are included in exports. `Automatic` (default) follows what the notebook displays (only collapsed or `CellOpen->False` cells are excluded). `True` is the same as `Automatic`. `False` excludes all Input/Code cells. `"Visual"` keeps only Input cells that contain figures (the old default). A cell with `"ShowInput"` in its `CellTags` is always kept.
- `$SlideExpandMode`: The execution path of `SlideExpand[]`. The default `"Agent"` goes through `ClaudeEval`/`ClaudeRuntime`, which supports literature search, figure generation, and approval gates for complex processing. The lightweight `"Direct"` calls `NBAccess`\`$NBLLMQueryFunc` directly.
- `$SlideTranslationLanguage`: The target language of `SlideTranslate[]`/`SlideTranslateDeck[]`. The default is `"English"` in a Japanese environment.
- `$SlideVisualsPerSlide`: When True (default), the expansion prompt of `SlideExpand[]` asks for "at least one figure or table on every slide in principle". Set it to False to return to the prose-centered generation.
- `$SlideTalkPerSlide`: When True (default), the expansion prompt requests a presentation script (`talk:`, polite style, 2–6 sentences) at the end of each slide, and the slide body is narrowed to figures/tables plus noun-ending phrases (a division of labor in which slide and talk together complete the explanation). False restores the earlier behavior.
- `$SlideExportExternal`: Whether the palette's image/mp4 export runs in a separate process (wolframscript). The default `Automatic` tries once and, if it cannot start (for example, no license seat), falls back to in-FE processing afterward. `True`/`False` fix the behavior.
- `$SlideHideToolbarInSlideshow`: When True (default), `SlideToggleScreenEnvironment[]` temporarily hides the notebook toolbar and dock cells when switching to SlideShow and restores them when returning to Working.

### Presentation (talk / voice) variables

These apply only when SourceVault is installed.

- `$SlideTalkLanguage`: The default language in which the presentation is read aloud (`"en"`, `"English"`, and so on). `Automatic` (default) uses `$Language`. A `Language:` line in the deck's Directive cell takes priority. `SlideTalkLanguage[nb]` returns the resolved code, and `SlideTalkLanguages[nb]` reports per-language translation status.
- `$SlideTalkSecondsPerSlide`: The default number of seconds per slide for the presentation scenario (default 25).
- `$SlideVoice`: The voice model name used for reading aloud. The default `Automatic` follows the default of `SourceVaultVoice[]`. Use `SlideVoices[]` to list candidates and `SlideCycleVoice[]` to switch.
- `$SlideRealtimeVoices`: The cloud voices (OpenAI Realtime) lined up in the voice toggle (default `{"marin", "cedar"}`).
- `$SlideVoiceProvider` / `$SlideVoiceModel` / `$SlideVoiceDefaultModel`: The provider and model for voice dialogue. The default provider is the first entry of the registry (`"OpenAI"`). The default model is `$SlideVoiceDefaultModel` (`"gpt-live-1"`). Use `SlideVoiceModels[]`, `SlideCycleVoiceProvider[]`, `SlideCycleVoiceModel[]`, and `SlideSetVoiceModel[model]` to inspect and switch them.
- `$SlideQuestionMode`: How questions are accepted during a presentation. `"QuestionTime"` (default) opens a question window after each slide and mutes the mic while reading. `"Words"` listens even while reading and stops only when `$SlideInterruptWords` is heard. `"Detect"` stops when a listener's voice is detected and lets gpt-live decide whether it is a question. `"Words"` and `"Detect"` work only with gpt-live-1. Switch with `SlideCycleQuestionMode[]` or `SlideSetQuestionMode[mode]`.
- `$SlideInterruptWords`: The words that may stop the presentation in `"Words"` mode (default `Automatic` = `$SourceVaultRealtimeInterruptWords`, that is, "質問" and "スライド"). Recognition uses local Vosk, which needs `SourceVaultRealtimeInstall["Vosk" -> True]` and `SourceVaultSpeechModel[]`.
- `$SlideQuestionSeconds` (default 3), `$SlideQuestionMaxSeconds` (default 60), `$SlideVoiceInputGate` (default 0, meaning no restriction): Control the question window, its upper limit, and the minimum input volume for accepting the mic.
- `$SlideVoiceGap` (default 0.8 s), `$SlideRenderSettle` (default 0.6 s), `$SlideVoiceTick` (default 0.3 s): The pause between slides, the wait for rendering to settle, and the polling period of the kernel-side ScheduledTask.
- `$SlidePrepareBeforePlay`: When True (default), `SlidePlay` synthesizes the local voice audio for all slides before playback starts (only slides not yet synthesized), so the audio is not interrupted by synthesis during playback.
- `$SlideSpeechRate` / `$SlideSpeechLatency`: Per-engine speech rate and per-slide latency used by `SlideTalkDuration`.
- `$SlideRemoteBindings` / `$SlideRemoteTick` / `$SlideRemoteAuto`: The handheld remote (Windows only). The default bindings map "MediaPrevTrack" to "Mic" and "MediaPlayPause" to "Play". Measure a button's virtual key with `SlideRemoteProbe[]`. Start and stop watching with `SlideRemoteStart[]`/`SlideRemoteStop[]`, and check the state with `SlideRemoteStatus[]`. With `$SlideRemoteAuto = True` (default), watching starts and stops together with the voice dialogue.
- `$SlideQAPerSlide` (default 3) and `$SlideQAVision` (default True): The number of expected questions per slide generated by `SlideQAGenerate`, and whether rendered slide images are attached to the LLM for slides that contain figures, photos, or tables. Images are cached in `<deck>_qa_images/`.
- `$SlideUploadMethod`: The transfer method for mp4 uploads. `Automatic` (default) tries `"Native"` (`CopyFile` to a remote file) and falls back to `"curl"`.

## 6. Verification

1. Check that the package is loaded.

   ```wolfram
   ?SlideDeckBuild
   ```

   If the usage message is displayed, loading succeeded.

2. Generate a deck from a sample scenario.

   ```wolfram
   md = "--- Title: Test / Event: Demo / Author: Imai / Date: 2026-07-13 ---\n## Slide1 {expected=30}\n- Hello";
   scenario = SlideScenarioFromMarkdown[md];
   nbfile = SlideDeckBuild[scenario, FileNameJoin[{$TemporaryDirectory, "test-slides.nb"}]];
   ```

   If a file path is returned without errors, it works.

3. Check the overview and thumbnails of the generated deck.

   ```wolfram
   SlideDeckOverview[nbfile]
   SlideDeckImages[nbfile]
   ```

   When you get a Dataset and a list of 16:9 images, installation and setup are complete.

4. If you use mp4 export, also check the following.

   ```wolfram
   SlideDeckExportVideo[nbfile, FileNameJoin[{$TemporaryDirectory, "test.mp4"}]]
   ```

   If no file is created, review the FFmpeg installation and PATH setting.

5. If you use the interactive editing layer, confirm that the palette opens.

   ```wolfram
   ShowSlidePalette[]
   ```

   If the palette appears and `?SlideAddSlide` and similar queries show usage messages, the integrated interactive editing features are available.

6. If you use the presentation features (SourceVault required), confirm that the presentation palette opens and that the voice list is populated.

   ```wolfram
   ShowSlideTalkPalette[]
   SlideVoices[]
   ```

   `SlideVoices[]` returns `{}` when SourceVault_voice is not loaded. `SlideInfo[]` opens a window summarizing the deck, script, estimated duration, voice, and voice dialogue state.

## 7. Interactive Editing Layer (Palette)

`SlideWorkflow` integrates palette features for interactive editing on slide Notebooks (formerly `SlideWorkflow_interactive.wl`, merged into the main file on 2026-07-13).

```wolfram
ShowSlidePalette[]
```

displays the palette. With `"Safe"->True`, the palette opens in a state completely non-interfering with ClaudeCode (for isolating freezes). The current version is available as `$SlideWorkflowInteractiveVersion`. The presentation palette (slideshow, playback, voice dialogue, camera, and voice/language/question settings) opens with `ShowSlideTalkPalette[]`, and also from a button on the authoring palette.

Main palette operations (all act on the current cell selection in the slide Notebook):

- `SlideAddSlide[]`: Inserts a new slide skeleton (navbar + title + prompt cell) right after the current slide. If you write something like "N slides" in the prompt, "Expand" can expand it into multiple slides at once (`SlideApplyScenario` splits multiple `##` into multiple slides).
- `SlideExpand[]`: Expands and updates the slide, using the selected `SlidePrompt` cell (or the body of the selected cell if there is none) as the instruction. By default (`$SlideExpandMode="Agent"`) it delegates to `ClaudeEval` (via `ClaudeRuntime`, with literature search, figure generation, and approval gates), and the agent applies the result by calling `SlideApplyScenario` at the end. The agent's work log is recorded after the end marker (Appendix). Directive and Dictionary cells are strictly followed, and existing figure and code cells are preserved with `<<FIGn>>` tokens.
- `SlideApplyScenario[slideNo, md]`: A deterministic function that replaces the target slide with scenario Markdown (the only write path of the expansion agent). `md` may contain multiple `##` (multi-slide expansion). `<<FIGn>>` refers to existing figure/code cells (n=1..k) or new figures (Graphics/Image, n=k+1..) passed with the `"Figures"` option. It returns `Success` on success and `Failure` on failure. If a new figure is a `Failure` / `$Failed` or an unevaluated image-processing expression, it writes nothing and returns `Failure["BadFigures"]`. `SlidePrompt` cells are automatically moved back to the first slide.
- `SlideTranslate[]` / `SlideTranslateRevert[]` / `SlideTranslateDeck[]`: Translate the text cells (headings, bullets, body) of the current slide, or of the whole deck (asynchronously, one slide at a time), into `$SlideTranslationLanguage`, and revert to the original. The original is never deleted. It remains in the cell's TaggingRules (`"documentation"` -> translationSrc / translation / showTranslation, as in documentation.wl; the original of a formatted cell is kept in `SWOrigContent`). Reverting therefore keeps the translation, and any hand corrections to it are also kept. Cells that already have a translation only switch display; only cells without a translation and cells whose original was edited are sent to the LLM, one slide at a time. Japanese strings inside figures on the same slide (Output / Print / Graphics cells) are translated as well, with the original figure in `SWOrigContent` and the translated one in `SWTransContent`. Option values such as font names and text embedded in images are not translated. The talk script (talk cells) is not translated by these functions; use `SlideTalkTranslate`.
- `SlideShowLanguage[]` / `SlideShowLanguage[nb, "Toggle" | "Original" | "Translation"]`: Switches the display of the whole deck between the original and the translation without calling the LLM. Cells without a translation stay in the original. Image and mp4 export follow the language currently displayed.
- `SlideInsertPrompt[]`: Inserts a `SlidePrompt` cell at the cursor (excluded from rasterization).
- `SlideInsertCitation[]`: Inserts a citation cell (small font) at the cursor. Place it right after a figure or quote and fill in a URL or (author, year).
- `SlideInsertReferences[]`: Inserts a reference list cell (the palette's "文献"). Write one reference per line as `[key] locator | memo`. `locator` is a URL / arxiv:ID / sv://URI / eagle:ID / PDF or notebook path (past slides allowed). The slide instruction (prompt) refers to it with `[key]`, and the expansion agent retrieves and cites it. Lines starting with `#` are comments.
- `SlideInsertTalk[]`: Inserts a talk cell (`SlideTalk` style, the presentation script for that slide). Place it at the end of each slide. Visible in Working, hidden in the SlideShow environment, and excluded from export. In md it corresponds to a `talk: script` line. When all slides have talk, `SlideTalkBuild` can bundle `<deck>_talk.md` without an LLM.
- `SlideInsertQA[]`: Inserts a Q&A cell (`SlideQA` style, the expected questions and answers for that slide). Place it at the end of each slide, next to the talk cell. Visible in Working, hidden in SlideShow, and excluded from image/mp4 export. In md it corresponds to a `qa:` line. Write each question as two lines, `Q: expected question` and `A: answer to read aloud` (optionally `cite: source` and `PL: 0.6`).
- `SlideInsertEndMarker[]`: Inserts a slide end marker at the cursor. Cells after it are not included in slides or export.
- `SlideInsertNote[]`: Inserts a note cell (compatible with `documentation.wl`, excluded from export). Visible in Working, hidden in SlideShow (the slide show environment).
- `SlideInsertDirective[]`: Inserts a Directive cell, which the LLM strictly follows during expansion and translation. Visible in Working, hidden in SlideShow. At the top of the deck, `Key: value` lines (`Title:`, `SlideURL:`, `Host: sftp://user@host/dir`, `Language:`, `Id:`) provide the deck-level presentation metadata read by `SlideTalkMeta`.
- `SlideInsertDictionary[]`: Inserts a Dictionary cell that specifies term correspondences for translation.
- `SlideInsertBibliography[]`: Inserts a bibliography cell (compatible with `documentation.wl`).
- `SlideToggleScreenEnvironment[]`: Switches the screen environment of the target notebook between Working and SlideShow (same as the Format menu's "Screen Style Environment"). Note, Directive, Dictionary, Bibliography, Prompt, Talk, and QA cells are visible in Working and hidden in SlideShow.
- `SlideTogglePrompts[]`: Toggles the visibility of all `SlidePrompt` cells.
- `SlideEnsureDeckStyles[nb]`: Embeds the style definitions for meta cells (Note / Directive / Dictionary / Bibliography / References / SlidePrompt / SlideTalk / SlideQA) into the deck. It is called automatically on insertion, expansion, and display switching.

Figure helpers usable in scenarios and code:

- `SlideTable[rows]`: Returns a table in the deck colors (`$SlideTheme`). `"HeaderRows"->n` (default 1) emphasizes header rows. A `| a | b |` table in scenario md produces the same table (a `| --- | --- |` line as the second row marks the first row as the header).
- `SlidePDFFigure[src, page]` (SourceVault required): Cuts a PDF page out as an Image. `src` can be a file path, `eagle:ID`, `sv://URI`, `src-ID`, URL, `arxiv:ID`, or a key of a References list. URLs, arXiv, and Google Slides are downloaded and cached automatically. Options include `"Crop"`, `"Trim"` (default `Automatic`), and `ImageResolution` (default 144). When quoting a literature PDF figure in a slide, add `cite:` right after it.

QA cell tools:

- `SlideQAEntries[nb]` returns the QA cells of the deck. `SlideQAView[nb]` shows their contents as a Dataset. `SlideQAStateView[nb]` shows per-slide state (not created / needs update / current / undeterminable).
- `SlideQAGenerate[nb]` writes LLM drafts of expected Q&A into the QA cells, asynchronously and one slide at a time. Its `"Mode"` is `"Regenerate"` (rebuild all), `"Update"` (let the LLM revise the existing ones), or `"Changed"` (default; slides without a QA cell and slides edited since). Other options are `"QuestionsPerSlide"`, `"Vision"`, and `"Slides"`. `SlideQAGenerateAll` and `SlideQAUpdateAll` are shortcuts for the first two modes. Treat generated text as a draft to be corrected by a person.
- `SlideQAMarkCurrent[nb]` stamps the current slide hash onto existing QA cells without calling the LLM or changing their text. Use it only after you have checked the contents.
- `SlideQAFromPack[nb]` writes an already registered QA pack back into slide QA cells (no LLM). `"Rebuild"` defaults to False.
- `SlideQABuild[nb|deck.nb]` bakes the QA cells into a SourceVault QA pack so that gpt-realtime can retrieve them during the presentation. Options are `"PrivacyLevel"`, `"Ingest"` (default True), and `"Enrich"` (default True).

Presentation script and playback (SourceVault required):

- Script: `SlideTalkFromMarkdown[md]` / `SlideTalkToMarkdown[talk]` convert between the presentation scenario Markdown and an association. `SlideTalkSkeleton[deck]` builds a deterministic skeleton without an LLM, `SlideTalkPrompt[deck]` returns an LLM prompt for a flowing script, and `SlideTalkBuild[deck]` writes `<deck>_talk.md` (the talk cells are the source of truth; slides lacking a script are filled with `SlideTalkFill`). `SlideTalkFile[deck]` returns the fallback path of `<deck>_talk.md`. `SlideTalkMeta[nb]` reads or persists deck-level metadata. `SlideTalkTranslate[nb]` translates the script with the LLM into talk cells tagged with `SWTalkLang`, so multiple languages can coexist.
- Playback: `SlidePlay[]` reads the script aloud with the local voice while advancing slides (when the screen environment is SlideShow), `SlidePause[]` pauses, `SlideStop[]` stops and resets, and `SlidePlayStatus[]` reports the state. `SlideShowSlide[spec]` changes the displayed slide by number, `"Next"`/`"Previous"`/`"First"`/`"Last"`, or a word in the heading or body. `SlideTitles[]` lists headings, `SlideCurrentNumber[]` returns the displayed slide number, and `SlideSpeakSlide[n]` reads slide n aloud.
- Index and estimates: `SlideIndex[]` returns the presentation index as a Dataset with Show and Play buttons per row. `SlideTalkDuration[]` estimates the duration (options `"Voice"`, `"Questions"`, `"View"`). `SlideVoicePrepare[]` synthesizes and caches voice for all slides in `<deck>_voice/`. `SlideInfo[]` opens the information window.
- Voice dialogue: `SlideToggleRealtime[]` toggles voice dialogue, `SlideToggleMic[]` mutes or unmutes the mic (`"Quiet" -> True` suppresses notification dialogs).
- Registration and upload: `SlideDeckRegister[...]` registers the presentation in SourceVault's registry and, when the Directive has a `Host:` line, uploads the Sliden mp4. Options include `"SlideURL"`, `"Title"`, `"Id"`, `"DeckFile"`, `"PrivacyLevel"`, `"SlideCount"`, and `"Upload"`. Running it again overwrites only the values you give. `SlideDeckRegistry[]` lists registered entries. `SlideDeckUpload[...]` sends `<deck>.mp4` by sftp and verifies delivery with a HEAD request on `SlideURL`. It skips the transfer if the same size is already served, unless `"Force"->True`. It re-exports the mp4 if the deck is newer (control with `"ExportVideo"`). `SlideDeckChangeStatus[nb]` reports what a registration would redo, and `SlideDeckMarkVideoCurrent[nb]` records the existing mp4 as current for the present slides. Use the latter only when the appearance really matches.

Related configuration variables (details in chapter 5):

- `$SlideExpandMode`: `"Agent"` (default) or `"Direct"`.
- `$SlideTranslationLanguage`: The target language. The default is `"English"` in a Japanese environment.
- `$SlideVisualsPerSlide` / `$SlideTalkPerSlide`: Switch how far the expansion prompt requests figures/tables and presentation scripts.
- `$SlideExportExternal` / `$SlideHideToolbarInSlideshow`: Control behavior for palette export and screen switching.

To use the `"Agent"` mode, an environment where `ClaudeEval` can be called via [ClaudeRuntime](https://github.com/transreal/ClaudeRuntime) is required. If it is not installed or you want a lightweight setup, switch to `$SlideExpandMode = "Direct"` and `SlideExpand[]` will call `NBAccess`\`$NBLLMQueryFunc` directly (the other palette features have no external dependencies). To use script reading and voice dialogue (`SlidePlay`, `SlideIndex`, `SlideRemoteStart`, and so on), [SourceVault](https://github.com/transreal/SourceVault) is required.