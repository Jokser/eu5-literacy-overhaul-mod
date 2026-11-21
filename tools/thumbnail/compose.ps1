param([string]$Dir, [string]$Variant)
Add-Type -AssemblyName System.Drawing
$W = 512; $H = 512
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'; $g.InterpolationMode = 'HighQualityBicubic'; $g.TextRenderingHint = 'AntiAliasGridFit'
# background: dark leather gradient + gold frame
$rect = New-Object System.Drawing.Rectangle 0, 0, $W, $H
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.Color]::FromArgb(255,74,52,32)), ([System.Drawing.Color]::FromArgb(255,24,16,10)), 90
$g.FillRectangle($bg, $rect)
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath; $glowPath.AddEllipse(56, 150, 400, 330)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush $glowPath
$glow.CenterColor = [System.Drawing.Color]::FromArgb(110,255,226,160); $glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0,255,226,160))
$g.FillPath($glow, $glowPath)
$gold = [System.Drawing.Color]::FromArgb(255,201,163,92)
$g.DrawRectangle((New-Object System.Drawing.Pen $gold, 6), 9, 9, $W-19, $H-19)
$g.DrawRectangle((New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160,201,163,92)), 1), 20, 20, $W-41, $H-41)
# title
$parch = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255,240,226,190))
$shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(170,0,0,0))
$sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'
$f1 = New-Object System.Drawing.Font 'Georgia', 46, ([System.Drawing.FontStyle]::Bold)
foreach ($t in @(@('LITERACY', 34), @('OVERHAUL', 92))) {
  $g.DrawString($t[0], $f1, $shadow, (New-Object System.Drawing.RectangleF 3, ($t[1]+3), $W, 70), $sf)
  $g.DrawString($t[0], $f1, $parch, (New-Object System.Drawing.RectangleF 0, $t[1], $W, 70), $sf)
}
$g.DrawLine((New-Object System.Drawing.Pen $gold, 2), 120, 160, 392, 160)
function Put($name, $x, $y, $s) { $img = [System.Drawing.Image]::FromFile((Join-Path $Dir "$name.png")); $g.DrawImage($img, $x, $y, $s, $s); $img.Dispose() }
if ($Variant -eq 'estates') {
  Put 'global_nobles_max_literacy_advance' 18 240 200
  Put 'global_burghers_max_literacy_advance' 294 240 200
  Put 'global_clergy_max_literacy_advance' 131 170 250
  $f2 = New-Object System.Drawing.Font 'Georgia', 17, ([System.Drawing.FontStyle]::Italic)
  $g.DrawString(('Nobles  ' + [char]0x00B7 + '  Clergy  ' + [char]0x00B7 + '  Burghers'), $f2, $parch, (New-Object System.Drawing.RectangleF 0, 450, $W, 30), $sf)
} else {
  Put 'printing_press_advance' 116 168 280
  $f2 = New-Object System.Drawing.Font 'Georgia', 17, ([System.Drawing.FontStyle]::Italic)
  $g.DrawString('A learned elite, an illiterate countryside', $f2, $parch, (New-Object System.Drawing.RectangleF 0, 450, $W, 30), $sf)
}
$bmp.Save((Join-Path $Dir "thumb_$Variant.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
