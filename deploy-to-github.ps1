Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  PrimeEstate Portal - GitHub Pages Deploy" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: GitHub login
Write-Host "STEP 1: Logging into GitHub..." -ForegroundColor Yellow
Write-Host "A browser window will open. Sign in with your GitHub account." -ForegroundColor Gray
Write-Host ""
gh auth login --web --git-protocol https
if ($LASTEXITCODE -ne 0) {
    Write-Host "Login failed. Please try again." -ForegroundColor Red
    exit 1
}
Write-Host "Logged in!" -ForegroundColor Green
Write-Host ""

# Step 2: Get GitHub username
$username = gh api user --jq ".login"
Write-Host "STEP 2: GitHub username: $username" -ForegroundColor Yellow
$repoName = "primeestate-property-portal"
$baseUrl = "https://" + $username + ".github.io/" + $repoName
Write-Host "Your site will be live at: $baseUrl" -ForegroundColor Cyan
Write-Host ""

# Step 3: Update QR code URLs in HTML files
Write-Host "STEP 3: Updating QR codes to GitHub Pages URL..." -ForegroundColor Yellow

$htmlFiles = @("index.html", "qr-sheet.html")
foreach ($f in $htmlFiles) {
    if (Test-Path $f) {
        $c = Get-Content $f -Raw
        $c = $c -replace "https://bitter-sites-learn\.loca\.lt", $baseUrl
        $c = $c -replace "http://primeestate-demo\.surge\.sh", $baseUrl
        $c = $c -replace "https://primeestate-demo\.surge\.sh", $baseUrl
        $c = $c -replace "http://localhost:8080", $baseUrl
        $c | Set-Content $f -Encoding UTF8
        Write-Host "  Updated: $f" -ForegroundColor Green
    }
}
Write-Host ""

# Step 4: Git init and commit
Write-Host "STEP 4: Setting up Git repository..." -ForegroundColor Yellow
git init
git add .
git commit -m "Initial commit: PrimeEstate Property QR Portal"
Write-Host ""

# Step 5: Create GitHub repo and push
Write-Host "STEP 5: Creating GitHub repo and pushing..." -ForegroundColor Yellow
gh repo create $repoName --public --source=. --remote=origin --push
Write-Host ""

# Step 6: Enable GitHub Pages
Write-Host "STEP 6: Enabling GitHub Pages..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
$pagesEndpoint = "repos/" + $username + "/" + $repoName + "/pages"
gh api $pagesEndpoint -X POST -f "source[branch]=main" -f "source[path]=/"
Write-Host ""

# Done
Write-Host "============================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your live site:" -ForegroundColor White
Write-Host "  $baseUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "QR Sheet (printable):" -ForegroundColor White
$qrSheet = $baseUrl + "/qr-sheet.html"
Write-Host "  $qrSheet" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: GitHub Pages takes ~2 minutes to go live." -ForegroundColor Yellow
Write-Host ""
Start-Process $baseUrl
