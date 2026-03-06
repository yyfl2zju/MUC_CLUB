# =====================================================
# Windows 本地打包脚本
# 使用方法: .\build.ps1
# =====================================================

Write-Host "========================================" -ForegroundColor Green
Write-Host "   社团管理系统后端打包脚本" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 进入后端目录
$BackendDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $BackendDir

Write-Host "`n[1/3] 清理旧的构建文件..." -ForegroundColor Yellow
mvn clean

if ($LASTEXITCODE -ne 0) {
    Write-Host "清理失败！" -ForegroundColor Red
    exit 1
}

Write-Host "`n[2/3] 编译打包（跳过测试）..." -ForegroundColor Yellow
mvn package -DskipTests

if ($LASTEXITCODE -ne 0) {
    Write-Host "打包失败！请检查代码和配置。" -ForegroundColor Red
    exit 1
}

Write-Host "`n[3/3] 打包完成！" -ForegroundColor Green

# 查找生成的JAR文件
$JarFile = Get-ChildItem -Path "target" -Filter "club-management-*.jar" -Exclude "*.original" | Select-Object -First 1

if ($JarFile) {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "✓ 打包成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "JAR文件: $($JarFile.FullName)" -ForegroundColor Cyan
    Write-Host "文件大小: $([math]::Round($JarFile.Length/1MB, 2)) MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "后续步骤:" -ForegroundColor Yellow
    Write-Host "1. 将 target\$($JarFile.Name) 上传到服务器 /www/server/club/" -ForegroundColor White
    Write-Host "2. 重命名为: club-management.jar" -ForegroundColor White
    Write-Host "3. 在服务器执行: bash deploy.sh" -ForegroundColor White
    Write-Host ""
    
    # 本地测试运行命令
    Write-Host "本地测试命令:" -ForegroundColor Yellow
    Write-Host "java -jar target\$($JarFile.Name) --spring.profiles.active=dev" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "警告: 找不到生成的JAR文件！" -ForegroundColor Red
}
