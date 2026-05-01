$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $root "tutorial_01.md"
$output = Join-Path $root "chapter0.html"

function HtmlEscape([string]$text) {
    return [System.Net.WebUtility]::HtmlEncode($text)
}

function InlineMarkdown([string]$text) {
    $escaped = HtmlEscape $text
    $escaped = [regex]::Replace($escaped, "(https?://[^\s<]+)", '<a href="$1">$1</a>')
    return $escaped
}

$lines = Get-Content -LiteralPath $source -Encoding UTF8
$start = -1
$end = $lines.Count

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq "# Chapter 0 Unityをインストールしよう") {
        $start = $i
        break
    }
}

if ($start -lt 0) {
    throw "Chapter 0 heading was not found."
}

for ($i = $start + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like "# Chapter 1*") {
        $end = $i
        break
    }
}

$chapterLines = $lines[$start..($end - 1)]
$body = New-Object System.Collections.Generic.List[string]
$inList = $false

function CloseListIfNeeded {
    if ($script:inList) {
        $script:body.Add("</ul>")
        $script:inList = $false
    }
}

foreach ($line in $chapterLines) {
    $trim = $line.Trim()

    if ($trim.Length -eq 0) {
        CloseListIfNeeded
        continue
    }

    $imageMatch = [regex]::Match($trim, '^!\[(.*?)\]\((.*?)\)$')
    if ($imageMatch.Success) {
        CloseListIfNeeded
        $alt = HtmlEscape $imageMatch.Groups[1].Value
        $src = HtmlEscape $imageMatch.Groups[2].Value
        $body.Add("<figure><img src=""$src"" alt=""$alt""></figure>")
        continue
    }

    $cardMatch = [regex]::Match($trim, '^@\[card\]\((.*?)\)$')
    if ($cardMatch.Success) {
        CloseListIfNeeded
        $href = HtmlEscape $cardMatch.Groups[1].Value
        $body.Add("<p class=""link-card""><a href=""$href"">$href</a></p>")
        continue
    }

    if ($trim.StartsWith("- ")) {
        if (-not $inList) {
            $body.Add("<ul>")
            $inList = $true
        }
        $body.Add("<li>$(InlineMarkdown $trim.Substring(2))</li>")
        continue
    }

    CloseListIfNeeded

    $headingMatch = [regex]::Match($trim, '^(#{1,6})\s+(.*)$')
    if ($headingMatch.Success) {
        $level = $headingMatch.Groups[1].Value.Length
        $content = InlineMarkdown $headingMatch.Groups[2].Value
        $body.Add("<h$level>$content</h$level>")
        continue
    }

    $body.Add("<p>$(InlineMarkdown $trim)</p>")
}

CloseListIfNeeded

$html = @"
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Chapter 0 Unityをインストールしよう</title>
  <style>
    :root {
      color-scheme: light;
      --text: #202124;
      --muted: #5f6368;
      --line: #dadce0;
      --bg: #ffffff;
      --accent: #2563eb;
      --soft: #f6f8fb;
    }

    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      line-height: 1.8;
    }

    main {
      max-width: 880px;
      margin: 0 auto;
      padding: 40px 24px 72px;
    }

    h1 {
      margin: 0 0 24px;
      padding-bottom: 16px;
      border-bottom: 1px solid var(--line);
      font-size: 2rem;
      line-height: 1.35;
    }

    h2 {
      margin-top: 44px;
      padding-bottom: 8px;
      border-bottom: 1px solid var(--line);
      font-size: 1.45rem;
    }

    h3 {
      margin-top: 32px;
      font-size: 1.15rem;
    }

    p {
      margin: 14px 0;
    }

    ul {
      margin: 12px 0 20px;
      padding-left: 1.4rem;
      background: var(--soft);
      border: 1px solid var(--line);
      border-radius: 8px;
      padding-top: 12px;
      padding-bottom: 12px;
    }

    li + li {
      margin-top: 4px;
    }

    a {
      color: var(--accent);
      overflow-wrap: anywhere;
    }

    figure {
      margin: 20px 0 28px;
    }

    img {
      display: block;
      max-width: 100%;
      height: auto;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: #fff;
    }

    .link-card {
      border: 1px solid var(--line);
      border-radius: 8px;
      background: var(--soft);
      padding: 12px 14px;
    }

    @media (max-width: 640px) {
      main {
        padding: 28px 16px 56px;
      }

      h1 {
        font-size: 1.55rem;
      }
    }
  </style>
</head>
<body>
  <main>
$($body -join "`n")
  </main>
</body>
</html>
"@

Set-Content -LiteralPath $output -Value $html -Encoding UTF8
Write-Host "Created chapter0.html"

