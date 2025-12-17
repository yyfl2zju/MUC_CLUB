# 社团管理系统 - 数据库批量初始化脚本 (PowerShell 版本)
# 说明: 为所有社团数据库批量初始化表结构
# 使用方法: .\init_all_club_databases.ps1

param(
    [string]$MySQLUser = "root",
    [string]$MySQLPassword = "wj20050223"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "社团数据库批量初始化开始" -ForegroundColor Yellow
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 社团数据库列表
$databases = @(
    "club_qnjycyzdfwzx",
    "club_kab",
    "club_seca",
    "club_jsjxh",
    "club_syryjl",
    "club_szsc",
    "club_xhyqyx",
    "club_lxjb",
    "club_56jws",
    "club_gybmsy",
    "club_jwjzxc",
    "club_qhs",
    "club_qnyq",
    "club_qnzq",
    "club_tjq",
    "club_tsqwd",
    "club_wdqc",
    "club_xyldw",
    "club_yyhs",
    "club_yypqq",
    "club_yyjt",
    "club_ywzjpq",
    "club_sswl",
    "club_xbsj",
    "club_xygz",
    "club_zlzq",
    "club_lxyx",
    "club_muc",
    "club_ygbl",
    "club_jhctwh",
    "club_qnsh",
    "club_wwybwg",
    "club_ylxxs",
    "club_zywh"
)

# 获取脚本所在目录
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$databaseDir = Split-Path -Parent $scriptDir
$schemaFile = Join-Path $databaseDir "init\database_club_schema.sql"

# 检查 schema 文件是否存在
if (-not (Test-Path $schemaFile)) {
    Write-Host "错误: 找不到 $schemaFile 文件" -ForegroundColor Red
    Write-Host "请确保 database/init/database_club_schema.sql 文件存在" -ForegroundColor Yellow
    exit 1
}

Write-Host "使用 schema 文件: $schemaFile" -ForegroundColor Green
Write-Host ""

# 设置环境变量传递密码
$env:MYSQL_PWD = $MySQLPassword

# 计数器
$successCount = 0
$failCount = 0
$totalCount = $databases.Count

Write-Host "总计需要初始化: $totalCount 个数据库" -ForegroundColor Yellow
Write-Host ""

# 遍历所有数据库并初始化表结构
foreach ($dbName in $databases) {
    Write-Host "正在初始化数据库: $dbName ... " -NoNewline
    
    # 执行 SQL 脚本 - 直接使用文件重定向，避免编码问题
    $errorOutput = cmd /c "mysql -u $MySQLUser $dbName < `"$schemaFile`" 2>&1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[成功]" -ForegroundColor Green
        $successCount++
    } else {
        Write-Host "[失败]" -ForegroundColor Red
        if ($errorOutput) {
            Write-Host "  错误信息: $errorOutput" -ForegroundColor Yellow
        }
        $failCount++
    }
}

# 清除密码环境变量
$env:MYSQL_PWD = $null

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "初始化完成" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "总计: $totalCount 个数据库" -ForegroundColor White
Write-Host "成功: $successCount 个" -ForegroundColor Green
Write-Host "失败: $failCount 个" -ForegroundColor Red

if ($failCount -gt 0) {
    Write-Host ""
    Write-Host "⚠ 部分数据库初始化失败，请检查上面的错误信息" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ""
    Write-Host "✓ 所有数据库初始化成功！" -ForegroundColor Green
    exit 0
}
