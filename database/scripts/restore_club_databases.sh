#!/bin/bash
# ========================================
# 社团管理系统 - 数据库恢复脚本
# 说明: 从备份恢复社团数据库
# 使用方法: ./restore_club_databases.sh <backup_file>
#          例如: ./restore_club_databases.sh backups/backup_20250115_120000.tar.gz
# ========================================

# 数据库配置
DB_USER="root"
DB_PASSWORD="your_password"  # 请修改为实际密码

# 检查参数
if [ $# -eq 0 ]; then
    echo "错误: 请指定备份文件"
    echo "使用方法: $0 <backup_file>"
    echo "示例: $0 backups/backup_20250115_120000.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"

# 检查备份文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    echo "错误: 备份文件不存在: $BACKUP_FILE"
    exit 1
fi

echo "======================================"
echo "社团数据库恢复开始"
echo "======================================"
echo "恢复时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "备份文件: $BACKUP_FILE"
echo ""

# 解压备份文件
TEMP_DIR=$(mktemp -d)
echo "正在解压备份文件到临时目录..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "错误: 解压备份文件失败"
    rm -rf "$TEMP_DIR"
    exit 1
fi
echo "  ✓ 解压成功"
echo ""

# 查找解压后的目录
BACKUP_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "backup_*" | head -n 1)
if [ -z "$BACKUP_DIR" ]; then
    echo "错误: 未找到备份目录"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 确认操作
echo "⚠  警告: 此操作将覆盖现有数据库，是否继续？"
read -p "请输入 'yes' 继续，或按 Ctrl+C 取消: " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "操作已取消"
    rm -rf "$TEMP_DIR"
    exit 0
fi
echo ""

# 恢复主数据库
if [ -f "$BACKUP_DIR/club_master.sql" ]; then
    echo "正在恢复主数据库: club_master"
    mysql -u"$DB_USER" -p"$DB_PASSWORD" club_master < "$BACKUP_DIR/club_master.sql" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "  ✓ club_master 恢复成功"
    else
        echo "  ✗ club_master 恢复失败"
    fi
    echo ""
fi

# 计数器
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

# 恢复所有社团数据库
for SQL_FILE in "$BACKUP_DIR"/club_*.sql; do
    if [ ! -f "$SQL_FILE" ]; then
        continue
    fi

    DB_NAME=$(basename "$SQL_FILE" .sql)

    # 跳过主数据库（已处理）
    if [ "$DB_NAME" == "club_master" ]; then
        continue
    fi

    ((TOTAL_COUNT++))
    echo "正在恢复数据库: $DB_NAME"

    mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$SQL_FILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "  ✓ $DB_NAME 恢复成功"
        ((SUCCESS_COUNT++))
    else
        echo "  ✗ $DB_NAME 恢复失败"
        ((FAIL_COUNT++))
    fi
done

echo ""
echo "======================================"
echo "恢复完成"
echo "======================================"
echo "总计: $((TOTAL_COUNT + 1)) 个数据库 (含主数据库)"
echo "成功: $((SUCCESS_COUNT + 1)) 个"
echo "失败: $FAIL_COUNT 个"
echo ""

# 清理临时文件
rm -rf "$TEMP_DIR"
echo "已清理临时文件"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✓ 所有数据库恢复成功！"
    exit 0
else
    echo "⚠ 部分数据库恢复失败，请检查日志"
    exit 1
fi
