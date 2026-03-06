# =====================================================
# 社团管理系统 - 一键初始化全部社团数据库 (PowerShell)
# 最小依赖:
# 1) database/init/database_club_master_init.sql
# 2) database/init/database_club_schema.sql
#
# 功能:
# 1) 初始化主库与 clubs 元数据
# 2) 根据 clubs.db_name 自动创建社团库
# 3) 初始化每个社团库的表结构与基础部门数据
# =====================================================

param(
    [string]$MySQLHost = "localhost",
    [int]$MySQLPort = 3306,
    [string]$MySQLUser = "root",
    [string]$MySQLPassword = "",
    [string]$MasterDatabase = "mucclub"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$databaseDir = Split-Path -Parent $scriptDir

$masterInitFile = Join-Path $databaseDir "init\database_club_master_init.sql"
$schemaFile = Join-Path $databaseDir "init\database_club_schema.sql"

$staticDatabases = @(
    "club_lxjb", "club_lxyx", "club_56jws", "club_kab", "club_muc", "club_jsjxh",
    "club_gybmsy", "club_jwjzxc", "club_jhctwh", "club_qhs", "club_qnjycyzdfwzx",
    "club_qnsh", "club_qnzq", "club_ruxingshe", "club_sswl", "club_syryjl",
    "club_szsc", "club_tjq", "club_tjqs", "club_wdqc", "club_xygz", "club_xyldw",
    "club_xhyqyx", "club_ylxxs", "club_yyjt", "club_yypqq", "club_ygbl", "club_zywh",
    "club_zlzq", "club_seca", "club_tsqwd", "club_qnyq", "club_wwybwg", "club_xbsj",
    "club_amyxyjjs", "club_ywzjpq", "club_zmpkqs", "club_qcpbxh", "club_hhfps",
    "club_ckqhs", "club_xskccz", "club_ymxcsgys"
)

function ConvertFrom-SecureToPlain([Security.SecureString]$secureString) {
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
}

function Resolve-MySQLPassword([string]$inputPassword) {
    if ($inputPassword -and $inputPassword.Trim() -ne "") {
        return $inputPassword
    }
    $secure = Read-Host "请输入MySQL密码" -AsSecureString
    return ConvertFrom-SecureToPlain $secure
}

function Test-MySQLCommand {
    return [bool](Get-Command mysql -ErrorAction SilentlyContinue)
}

function Test-MySQLConnection {
    & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser -N -e "SELECT 1;" 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

function Invoke-SqlFile([string]$sqlFile, [string]$dbName = "") {
    if (-not (Test-Path $sqlFile)) {
        return @{ Ok = $false; Error = "SQL文件不存在: $sqlFile" }
    }
    if ($dbName -and $dbName.Trim() -ne "") {
        $output = Get-Content -Path $sqlFile -Raw -Encoding UTF8 | & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser $dbName 2>&1
    } else {
        $output = Get-Content -Path $sqlFile -Raw -Encoding UTF8 | & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser 2>&1
    }
    if ($LASTEXITCODE -ne 0) {
        return @{ Ok = $false; Error = ($output | Out-String).Trim() }
    }
    return @{ Ok = $true; Error = "" }
}

function Get-ClubDatabasesFromMaster {
    $sql = "SELECT db_name FROM clubs WHERE status = 1 ORDER BY id;"
    $rows = & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser -N -e $sql $MasterDatabase 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $rows) {
        return @()
    }
    return @($rows | Where-Object { $_ -and $_.Trim() -ne "" } | ForEach-Object { $_.Trim() })
}

function New-ClubDatabase([string]$dbName) {
    $sql = "CREATE DATABASE IF NOT EXISTS $dbName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    & mysql -h $MySQLHost -P $MySQLPort -u $MySQLUser -e $sql 2>$null | Out-Null
    return $LASTEXITCODE -eq 0
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "社团数据库一键初始化（精简版）" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

if (-not (Test-MySQLCommand)) {
    Write-Host "错误: 未检测到 mysql 命令，请先安装并加入 PATH。" -ForegroundColor Red
    exit 1
}

foreach ($file in @($masterInitFile, $schemaFile)) {
    if (-not (Test-Path $file)) {
        Write-Host "错误: 缺少必要文件: $file" -ForegroundColor Red
        exit 1
    }
}

$MySQLPassword = Resolve-MySQLPassword $MySQLPassword
$env:MYSQL_PWD = $MySQLPassword

try {
    Write-Host "检查MySQL连接..." -ForegroundColor Yellow
    if (-not (Test-MySQLConnection)) {
        Write-Host "错误: MySQL连接失败，请检查连接参数与密码。" -ForegroundColor Red
        exit 1
    }
    Write-Host "MySQL连接成功。" -ForegroundColor Green

    Write-Host ""
    Write-Host "步骤 1/3: 初始化主库元数据..." -ForegroundColor Yellow
    $ret = Invoke-SqlFile $masterInitFile
    if (-not $ret.Ok) {
        Write-Host "主库初始化失败: $($ret.Error)" -ForegroundColor Red
        exit 1
    }
    Write-Host "主库初始化完成。" -ForegroundColor Green

    Write-Host ""
    Write-Host "步骤 2/3: 创建社团数据库..." -ForegroundColor Yellow
    $databases = Get-ClubDatabasesFromMaster
    if (-not $databases -or $databases.Count -eq 0) {
        Write-Host "警告: 无法从主库读取社团列表，回退到静态42库名单。" -ForegroundColor DarkYellow
        $databases = $staticDatabases
    }

    foreach ($dbName in $databases) {
        if (-not (New-ClubDatabase $dbName)) {
            Write-Host "建库失败: $dbName" -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "社团数据库创建完成，共 $($databases.Count) 个。" -ForegroundColor Green

    Write-Host ""
    Write-Host "步骤 3/3: 初始化社团库表结构..." -ForegroundColor Yellow
    $successCount = 0
    $failCount = 0
    $idx = 0

    foreach ($dbName in $databases) {
        $idx++
        Write-Host "[$idx/$($databases.Count)] $dbName" -NoNewline
        $schemaRet = Invoke-SqlFile $schemaFile $dbName
        if ($schemaRet.Ok) {
            Write-Host " -> 成功" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host " -> 失败" -ForegroundColor Red
            Write-Host "  错误: $($schemaRet.Error)" -ForegroundColor DarkYellow
            $failCount++
        }
    }

    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "初始化完成" -ForegroundColor Cyan
    Write-Host "社团库成功: $successCount" -ForegroundColor Green
    Write-Host "社团库失败: $failCount" -ForegroundColor Red
    Write-Host "======================================" -ForegroundColor Cyan

    if ($failCount -gt 0) {
        exit 1
    }
    exit 0
}
finally {
    $env:MYSQL_PWD = $null
}
