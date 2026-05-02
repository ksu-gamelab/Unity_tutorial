$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$imageDir = Join-Path $root "images\tutorial_01"
New-Item -ItemType Directory -Force -Path $imageDir | Out-Null

$files = @("01.md", "02.md", "03.md", "04.md", "05.md", "06.md")
$chapterTitles = @(
    "Chapter 0 Unityをインストールしよう",
    "Chapter 1 Unityプロジェクトを作ろう",
    "Chapter 2 ゲームオブジェクトを作成・配置しよう",
    "Chapter 3 コンポーネントをアタッチしよう",
    "Chapter 4 ピンボールゲームを作ろう",
    "Chapter 5 ピンボールゲームを完成させよう"
)

$chapterGoals = @(
    @("Unity Hubをインストールする", "Unity EditorのLTS版をインストールする", "Visual StudioのUnity開発環境を準備する"),
    @("2Dプロジェクトを作成する", "テンプレートファイルをインポートする", "GameObjectとComponentの考え方を知る"),
    @("Gameビューの画面サイズを設定する", "ゲームオブジェクトの移動・サイズ変更・回転を行う", "Spriteの表示順序と色を変更する"),
    @("Rigidbody2Dでボールを落下させる", "Collider2Dで当たり判定を付ける", "独自Scriptコンポーネントで回転する動きを追加する"),
    @("スペースキーでボールを発射する仕組みを作る", "ゴールや障害物を配置する", "衝突時に効果音を鳴らす"),
    @("使えるコンポーネントを整理する", "ゲームオブジェクトを複製・階層化して管理する", "画像やBGMを使ってゲームを作り込む")
)

$chapterChecks = @(
    @("Unity Hubにサインインできている", "Unity EditorのLTS版がインストール済みになっている", "Visual Studio InstallerでUnity開発に必要な項目が入っている"),
    @("Projectウィンドウにテンプレートのフォルダが表示されている", "Sceneビューに背景・ボール・四角形が表示されている", "次章で編集するプロジェクトを開いた状態になっている"),
    @("背景画像がカメラ範囲に合う大きさになっている", "床・左右の壁が配置されている", "追加したSpriteが背景に隠れず表示されている"),
    @("再生するとボールが落下する", "ボールが床をすり抜けずに止まる", "RotateScriptを付けたオブジェクトが回転する"),
    @("スペースキーを押すとボールが落下し、発射台で跳ね返る", "複数のゴールや障害物を配置できている", "ゴールにボールが当たったときに効果音が鳴る"),
    @("ヒエラルキー上でオブジェクトを整理できている", "複製したオブジェクトを使ってステージを作り込めている", "他の人が遊べる状態を目指して調整できている")
)

function Strip-FrontMatter($text) {
    return [regex]::Replace($text, "\A---\r?\n.*?\r?\n---\r?\n", "", [System.Text.RegularExpressions.RegexOptions]::Singleline)
}

function Raise-Headings($text) {
    return [regex]::Replace($text, "^(#{1,5})\s", '$1# ', [System.Text.RegularExpressions.RegexOptions]::Multiline)
}

function BulletList($items) {
    return ($items | ForEach-Object { "- $_" }) -join "`n"
}

function Normalize-ImageBlocks([string]$text) {
    $text = [regex]::Replace($text, '\s*(!\[[^\]]*\]\([^)]+\))\s*', {
        param($match)
        return "`n`n$($match.Groups[1].Value)`n`n"
    })

    $lines = $text -split "\r?\n"
    $result = New-Object System.Collections.Generic.List[string]

    foreach ($line in $lines) {
        $isImageLine = $line.Trim() -match '^!\[.*?\]\(.*?\)$'

        if ($isImageLine -and $result.Count -gt 0 -and $result[$result.Count - 1].Trim().Length -gt 0) {
            $result.Add("")
        }

        $result.Add($line)

        if ($isImageLine) {
            $result.Add("")
        }
    }

    return (($result -join "`n") -replace "(\r?\n){3,}", "`n`n").Trim()
}

$combinedParts = New-Object System.Collections.Generic.List[string]

$frontMatter = @"
---
title: "Unity初心者向けピンボールゲームチュートリアル"
free: false
---

この資料では、Unityを使って2Dピンボールゲームを作りながら、ゲームオブジェクトとコンポーネントの基本を学びます。

Unityでのゲーム開発で最初に理解したいことは、GameObject（ゲームオブジェクト）とComponent（コンポーネント）の関係です。シーン内にゲームオブジェクトを配置し、そこへコンポーネントをアタッチすることで、表示・物理・音・スクリプトによる振る舞いを追加できます。

"@
$combinedParts.Add($frontMatter.TrimEnd())

$allTextForImages = ""

for ($i = 0; $i -lt $files.Count; $i++) {
    $path = Join-Path $root $files[$i]
    $body = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $body = Strip-FrontMatter $body

    $body = $body.Replace("New projyect", "New project")
    $body = $body.Replace("Inport Unity Package", "Import Unity Package")
    $body = $body.Replace("Visual Studio Commusity", "Visual Studio Community")
    $body = $body.Replace("UnityHubが最新出ない場合", "UnityHubが最新でない場合")
    $body = $body.Replace("物理現象を適応", "物理現象を適用")
    $body = $body.Replace("物理現象を適用させる性質", "物理演算を適用する性質")
    $body = $body.Replace("0にしします", "0にします")
    $body = $body.Replace("ここまで使ってきたものコンポーネント", "ここまで使ってきたコンポーネント")
    $body = $body.Replace("鳴らしたいBGMを設定します", "鳴らしたい効果音を設定します")
    $body = $body.Replace("RigidBody2D", "Rigidbody2D")
    $body = $body.Replace("Foward", "Forward")
    $body = $body.Replace("~~Collider**2D**", "Collider**2D**")
    $body = $body.Replace("FaceBook", "Facebook")

    if ($files[$i] -eq "04.md") {
        $body = $body.Replace(
            "床のゲームオブジェクトにも当たり判定を追加しましょう。四角形のゲームオブジェクトには、Box Collider2Dがいいでしょう。",
            "床のゲームオブジェクトにも当たり判定を追加しましょう。Rigidbody2Dは「物理で動く性質」、Collider2Dは「ぶつかる形」を与えるコンポーネントです。ボールと床の両方にCollider2Dがないと、見た目では重なっていても衝突しません。四角形のゲームオブジェクトには、Box Collider2Dがいいでしょう。"
        )
    }

    if ($files[$i] -eq "05.md") {
        $body = $body.Replace(
            "CatapultScriptコンポーネントは、衝突したオブジェクトに対して上方向の力を加えるコンポーネントで、時間経過で変化するオブジェクトのサイズが大きいほど、強い力で衝突したオブジェクトを上方向に突き上げる振る舞いをします。",
            "CatapultScriptコンポーネントは、発射台やバネのように、衝突したオブジェクトを上方向へ押し出すコンポーネントです。このチュートリアルで用意しているCatapultScriptでは、時間経過で変化するオブジェクトのサイズが大きいほど、強い力で衝突したオブジェクトを上方向に突き上げる振る舞いをします。"
        )
    }

    $body = Raise-Headings $body.Trim()
    $body = Normalize-ImageBlocks $body

    $chapter = @"

# $($chapterTitles[$i])

## この章のゴール
$(BulletList $chapterGoals[$i])

$body

## ここまでできたらOK
$(BulletList $chapterChecks[$i])
"@
    $combinedParts.Add($chapter.Trim())
    $allTextForImages += "`n" + $body
}

$combined = ($combinedParts -join "`n`n")

$urlMatches = [regex]::Matches($combined, "!\[\]\((https://storage\.googleapis\.com/zenn-user-upload/[^)]+)\)")
$urls = New-Object System.Collections.Generic.List[string]
foreach ($match in $urlMatches) {
    $url = $match.Groups[1].Value
    if (-not $urls.Contains($url)) {
        $urls.Add($url)
    }
}

$map = @{}
for ($i = 0; $i -lt $urls.Count; $i++) {
    $url = $urls[$i]
    $basename = [System.IO.Path]::GetFileNameWithoutExtension(([Uri]$url).AbsolutePath)
    $ext = [System.IO.Path]::GetExtension(([Uri]$url).AbsolutePath)
    if ([string]::IsNullOrWhiteSpace($ext)) { $ext = ".png" }
    $localName = "{0:D3}_{1}{2}" -f ($i + 1), $basename, $ext
    $localPath = Join-Path $imageDir $localName
    if (-not (Test-Path -LiteralPath $localPath)) {
        Invoke-WebRequest -Uri $url -OutFile $localPath
    }
    $relative = "images/tutorial_01/$localName"
    $map[$url] = $relative
}

foreach ($url in $map.Keys) {
    $combined = $combined.Replace($url, $map[$url])
}

$outPath = Join-Path $root "tutorial_01.md"
Set-Content -LiteralPath $outPath -Value $combined -Encoding UTF8

Write-Host "Created tutorial_01.md"
Write-Host ("Downloaded/linked images: {0}" -f $urls.Count)

