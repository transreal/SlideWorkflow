# 発表シナリオ / スライドデッキ登録簿 仕様 v0.1

対象: `SlideWorkflow.wl` / `SourceVault_slidedeck.wl` (新設) / `SourceVault_mcp.wl` /
`SourceVault_servicemanager.wl` / `VRCRealtime.wl` / `VRCRealtime_worker.py` /
`VRCRealtime_private_tts.py`

作成: 2026-08-15

---

## 1. 動機と現状の問題

VRChat 上のボット (VRCRealtime) は Sliden 用 mp4 を操作パネルへ投入してスライドを
自動発表できる。しかし現状には 2 つの欠落がある。

1. **発表タイトルからスライドを引けない。**
   `VRCRealtime_worker.py` に `PRESENTATION_CATALOG` というハードコード表があり、
   「計算と自然31」1 件だけが登録されている。新しい発表を足すたびに Python を
   編集する必要があり、資料の所在 (SourceVault) とも二重管理になっている。

2. **発話が「1 枚ごとの説明」でしかない。**
   `_narrate_presentation_slide` はスライド画像を Realtime へ送り
   「この画像を説明して」と指示する。結果として各スライドは正しいが、
   導入・伏線・前スライドとの接続・まとめが無く、1 つの発表としての流れがない。

## 2. 方針 (責務分界)

| 層 | 責務 |
|---|---|
| `SlideWorkflow.wl` | スライドデッキ本体、**発表シナリオ (原稿)** の作成・編集・保存。パレット UI。登録簿への登録操作 |
| `SourceVault_slidedeck.wl` (新設) | 登録簿 (タイトル / URL / シナリオ URI) の**保管と照会**。release gate。MCP / service command への供給 |
| `SourceVault_mcp.wl` | MCP tool `sourcevault_slidedeck` (LLM クライアント向け) |
| `SourceVault_servicemanager.wl` | service command `SlideDeckLookup` (音声ブリッジ向けの同一関数 2 経路目) |
| `VRCRealtime.wl` | VRChat 制御と発表実行。**タイトル指定**での開始。シナリオはそのまま worker へ渡すだけ |
| `VRCRealtime_worker.py` | 原稿があればそれを話し、無ければ従来の画像説明にフォールバック |

原則: **スライドとシナリオの中身は SlideWorkflow の管轄**、
**その所在と公開可否は SourceVault の管轄**、**VRChat の挙動は VRCRealtime の管轄**。
VRCRealtime は原稿を*作らない*。SourceVault は原稿を*書き換えない*。

## 3. データモデル

### 3.1 発表シナリオ Markdown (人間が編集する正本)

```markdown
---
Title: 計算と自然31
Aliases: 計算と自然集会31, CN31
Event: 計算と自然の物理と情報 第31回
Author: 今井克暢
Date: 2026/08/20
SlideURL: https://transreal.sakura.ne.jp/cn/31.mp4
Deck: 第31回-slides.nb
Language: Japanese
PrivacyLevel: 0
SecondsPerSlide: 25
NarrationInstructions: 専門外の聴衆にも分かるように説明してください。
---

# Opening
本日は … というお話をします。全体は 3 部構成で、まず … 。

## 1 タイトル {seconds=20}
（1 枚目の原稿）

## 2 背景 {seconds=35}
（2 枚目の原稿。前スライドからの接続を含む）

# Closing
以上です。ご清聴ありがとうございました。
```

- front matter は先頭の `---` … `---`。`Key: value` のみ。
- `# Opening` / `# Closing` (別名 `# オープニング` / `# クロージング` / `# まとめ`) は
  スライド外の導入・締め。省略可。
- `## <番号> <スライドタイトル> {seconds=秒}` が 1 枚ぶんの原稿。
  番号は省略可 (省略時は出現順)。`{seconds=..}` も省略可。
- 本文は素のテキスト。箇条書き禁止ではないが、**読み上げられる文章**として書く。

### 3.2 コンパイル済みシナリオ JSON (機械が読む従属物)

登録時に `.md` から生成される。MCP / 音声ブリッジが読むのはこちらだけで、
Markdown パーサは SlideWorkflow 側の 1 実装のみに閉じる。

```json
{"version":1,"id":"cn31","title":"計算と自然31","language":"Japanese",
 "opening":"…","closing":"…",
 "slides":[{"slide":1,"title":"タイトル","seconds":20,"text":"…"}]}
```

### 3.3 登録簿エントリ

`<root>/slidedecks/registry.json`:

```json
{"Version":1,"Entries":[{
  "Id":"cn31","Title":"計算と自然31","Aliases":["計算と自然集会31","CN31"],
  "SlideURL":"https://transreal.sakura.ne.jp/cn/31.mp4",
  "TalkURI":"sv://slidetalk/cn31","TalkFile":"talks/cn31.md","TalkJSON":"talks/cn31.json",
  "DeckFile":"C:\\…\\第31回-slides.nb","SlideCount":24,
  "SecondsPerSlide":25.0,"StartSlide":1,"EndSlide":null,
  "NarrationInstructions":"…","Event":"…","Author":"…","Date":"…",
  "PrivacyLevel":0.0,"UpdatedAtUTC":"2026-08-15T00:00:00Z"}]}
```

`<root>` は `SourceVaultCoreRoot[]` (機械間で共有される udb) 配下。
解決できない環境では `LOCALAPPDATA/SourceVault/slidedecks`。

### 3.4 privacy

- `PrivacyLevel` は**登録時に明示**される (既定 0.0 = 公開発表資料)。
- 読み出し側は **欠落を 1.0 とみなす fail-closed**。
- `PrivacyLevel >= 0.5` のエントリは、OpenAI 側プロセスへ渡る経路
  (MCP の `includeTalk`、音声ブリッジ) では **原稿本文を返さない**
  (`talkWithheld: true`)。タイトル/URL のメタデータのみ。
- `DeckFile` はローカル絶対パスなので **クラウド側へは返さない**。

## 4. タイトル照合

「計算と自然集会31 のプレゼンを開始」のように、登録名と完全一致しない呼び方が来る。

1. NFKC 正規化 → casefold → 英数字と CJK のみ残す。
2. 完全一致 → エイリアス完全一致 → 前方一致 (双方向) → 文字 bigram Jaccard。
3. 末尾の数字列が両者に有り、かつ**異なる**場合はスコアを 0 にする
   (「31」と「30」を混同しない、が最重要)。
4. しきい値 0.34 未満は不一致 (Missing)。

## 5. API

### 5.1 SlideWorkflow.wl (新規公開シンボル)

| 関数 | 役割 |
|---|---|
| `SlideTalkFromMarkdown[md]` | 3.1 → 連想 |
| `SlideTalkToMarkdown[talk]` | 連想 → 3.1 (ラウンドトリップ) |
| `SlideTalkBuild[nbfile, opts]` | デッキ全体から LLM で**流れのある原稿**を生成し 3.1 の Markdown を返す。LLM 不在時は決定論的な骨格を返す |
| `SlideTalkFile[nbfile]` | `<deck>_talk.md` の規約パス |
| `SlideDeckRegister[nbfile\|talkfile, opts]` | 3.3 の登録 (SourceVault へ委譲) |
| `SlideDeckRegistry[]` | 登録一覧 (Dataset は `…View` 側) |

`SlideTalkBuild` は 1 回の LLM 呼び出しで全スライド分を書く。
これは「流れ」がスライド間の関係から生まれるため、
1 枚ずつ独立に生成しては要件を満たせないという理由による。
入力はデッキ全体の scenario markdown (既存の `iSWSlideToMarkdown`) と
front matter、`Directive` / `Dictionary` セル。

### 5.2 SourceVault_slidedeck.wl (新設)

| 関数 | 役割 |
|---|---|
| `SourceVaultSlideDeckRoot[]` | `<root>/slidedecks` |
| `SourceVaultSlideDeckRegister[entry, talk]` | 登録簿へ upsert。talk (連想) を `.json` に、原本 md があれば `.md` に保存 |
| `SourceVaultSlideDeckUnregister[id]` | 削除 |
| `SourceVaultSlideDeckRegistry[]` | 全エントリ |
| `SourceVaultSlideDeckLookup[query]` | §4 の照合。Missing か 1 件 |
| `SourceVaultSlideDeckTalk[id]` | コンパイル済み talk |
| `SourceVaultSlideDeckPresentationSpec[query, opts]` | 発表実行に必要な payload 一式 (§5.3) |

### 5.3 発表 payload (MCP / service command / worker で同一)

```json
{"found":true,"id":"cn31","title":"計算と自然31",
 "url":"https://…/31.mp4","secondsPerSlide":25.0,
 "startSlide":1,"endSlide":null,"slideCount":24,
 "narrationInstructions":"…","privacyLevel":0.0,
 "talkWithheld":false,
 "talk":{"opening":"…","closing":"…",
         "slides":[{"slide":1,"seconds":20.0,"text":"…"}]}}
```

### 5.4 MCP tool / service command

- MCP: `sourcevault_slidedeck` — `{action: "list"|"lookup"|"spec", title, includeTalk}`。
- service command: `{"Command":"SlideDeckLookup","Title":…,"IncludeTalk":true}`
  → `{"Status":"OK","SlideDeck":{…§5.3…}}`。
  音声ブリッジ (private TTS broker) はこちらを使う。MCP エンベロープの
  再パースを Python 側に持ち込まないため。**同一関数の 2 経路**である。

### 5.5 VRCRealtime.wl

- `VRCRealtimeStartPresentation["計算と自然31"]` — http(s) でない引数は
  **タイトル**として `SourceVaultSlideDeckPresentationSpec` で解決する。
  URL を直接渡す従来の呼び方は変更なし。
- `VRCRealtimeListPresentations[]` — 登録済み発表の一覧。
- オプション `"Talk" -> Automatic | None | <|…|>`。
  `Automatic` = 登録簿の原稿を使う。`None` = 従来の画像説明。

## 6. 発表実行 (worker)

```
presentation-start
  ├ preparing        mp4 取得 → 元解像度スライド抽出
  ├ opening          talk.opening を発話 (あれば)
  ├ narrating  n=…   原稿があれば原稿を、無ければ画像説明を発話
  ├ advancing_console
  └ closing          talk.closing を発話 (あれば)
```

原稿がある場合の Realtime への指示:

- スライド画像は**同期の根拠**として添付し続ける (どの枚を話しているかを固定する)。
- 「添付原稿の主旨をそのまま、自然な発表口調で話す。原稿に無い事実を足さない。
   読み上げ調にしない。終わったら次へ進む合図や質問をせずに停止する」。
- 想定秒数はスライドごとの `seconds`、無ければ `secondsPerSlide`。

原稿が無い / `talkWithheld` の場合は従来の指示に完全にフォールバックする
(機能低下であって障害ではない)。

state に `presentationTalkAvailable` / `presentationTalkSlides` /
`presentationScripted` / `presentationCatalogRoute` を追加し、
「原稿を使ったのか画像説明に落ちたのか」を外から観測できるようにする。
これが無いと、流れの無い発表を聞いても原因 (原稿未登録 / gate による withheld /
lookup 失敗) を区別できない。

## 6.1 質疑応答 (v0.2 追加)

```
narrating n
  └ question_window     チャット「質問があればどうぞ」+ マイク開放 (既定 5 秒)
       ├ 無音で満了     → advancing_console
       ├ 発話あり       → 回答 → 「それでは再開します」→ advancing_console
       ├ pause          → タイマー停止、resume まで待つ
       └ stop           → 発表終了 (status=stopped)
  …
closing
  └ final_questions     「この発表に関して質問があればどうぞ」+ 窓 (既定 120 秒)
```

- **マイクは窓の中だけ開く。** 発表中はミュートのままにする。開けっぱなしにすると
  ボットが自分のナレーションに反応する。窓の出口 (return / 例外 / stop の全経路) で
  必ず閉じる。
- 窓の間だけ視覚ゲートの会話セッションを立てる。厳密なネームプレート/口元ゲートは
  「部屋の向こうから会話を始める」ための仕組みで、聴衆の質問には合わない。
- **制御は function tool `presentation_control` (pause / resume / stop)。**
  音声認識テキストの語句一致ではなくモデルの tool 呼び出しにするのは、
  入力文字起こしを有効にしていないため (有効化は追加課金と遅延になる)。
  停止の実行は発表スレッドが引き取る。websocket スレッドからナレーション中に止めると
  コンソール制御とミュート状態が中途半端に残る。
- **モード変更 (`set_avatar_mode` / control file の `mode`) は発表を終了する。**
  owner-follow コントローラの有無に依存させない。会話離脱 (`conversation_control` leave)
  も同じ。
- 質問への回答は必ず `sourcevault_lookup` を先に通す。この tool は
  `SourceVaultLocalVoiceSearch` → **KB (Graph-RAG) 先行ルート**なので、高速索引が
  最初に引かれる。KB が外したときだけ adapter 横断検索へ落ちる。
- **`web_search` は opt-in** (`VRCRealtimeStart` の `"EnableVoiceWebSearch"`、既定 False)。
  室内の誰の質問でもクエリが外部へ出る経路になるため
  (経路 6 = web 外部送信対策は未解決課題として記録済み)。有効時も
  「`sourcevault_lookup` が空振りしたときだけ」と instructions で縛る。
  返すのは題名/URL/抜粋のみで本文取得はしない。
- 無限に開いたままにならないよう hard cap (既定 `max(窓秒×20, 1800秒)`) を置く。
  超過は `presentationStoppedBy = "question_window_timeout"`。

state: `presentationQAOpen` / `presentationQuestionsAnswered` / `presentationPaused` /
`presentationLastControl` / `presentationStoppedBy`。

## 7. パレット

`ShowSlidePalette[]` の「書き出し」節の下に「発表」節を追加する。

| ボタン | 動作 |
|---|---|
| 発表シナリオ | `SlideTalkBuild` → `<deck>_talk.md` に保存 → エディタで開く |
| 登録 | `<deck>_talk.md` (無ければダイアログ) から §3.3 を登録。タイトル / mp4 URL は front matter を既定値としてダイアログで確認 |

既存の「シナリオmd(概略)」は**スライド本文**の書き出しであり別物なので、
新ボタンのラベルは「発表シナリオ」とする。

## 8. 失敗モード

| 失敗 | 挙動 |
|---|---|
| 登録簿に無いタイトル | worker は「その発表は登録されていません」と発話し、開始しない |
| SourceVault service 停止 | lookup 失敗。`presentationCatalogRoute = "unavailable"`。既定 mp4 のみの内蔵フォールバックへ (状態に明示) |
| 原稿の枚数がスライド数と食い違う | 原稿がある枚だけ原稿、他は画像説明。`presentationScripted` は枚ごとに記録 |
| `PrivacyLevel >= 0.5` | 原稿を返さず `talkWithheld: true`。worker は画像説明へ |

## 9. テスト

- `test codes/slidedeck_registry_test.wls` — Markdown 往復、照合 (集会31 / 30 との
  取り違え不可)、fail-closed、payload 形状、登録 upsert。
- `test codes/VRCRealtime_talk_unit.py` — talk 付き `presentation-start` の
  指示文組み立て、opening/closing、原稿欠落時のフォールバック、broker の
  `kind: presentation` 往復。
- 既存の `slideworkflow_test.wls` / `VRCRealtime_worker_unit.py` は不変で通ること。
