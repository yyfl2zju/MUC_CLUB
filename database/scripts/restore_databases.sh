#!/bin/bash
# =====================================================
# 社团管理系统 - 数据库恢复脚本
# 说明: 从备份恢复数据库
# 使用方法: ./restore_databases.sh <backup_file>
# 示例: ./restore_databases.sh backups/20240115_120000.tar.gz
# =====================================================

# 数据库配置
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="wj20050223"  # 请修改为你的数据库密码

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}社团数据库恢复脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 检查参数
if [ $# -eq 0 ]; then
    echo -e "${RED}错误: 请指定备份文件！${NC}"
    echo -e "${YELLOW}使用方法: $0 <backup_file>${NC}"
    echo -e "${YELLOW}示例: $0 backups/20240115_120000.tar.gz${NC}"
    echo ""
    echo -e "${YELLOW}可用的备份文件:${NC}"
    ls -lht backups/*.tar.gz 2>/dev/null | head -5
    exit 1
fi

BACKUP_FILE="$1"

# 检查备份文件是否存在
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}错误: 备份文件 '$BACKUP_FILE' 不存在！${NC}"
    exit 1
fi

echo -e "${BLUE}备份文件: $BACKUP_FILE${NC}"
echo -e "${YELLOW}警告: 此操作将覆盖现有数据库！${NC}"
echo -n "确认继续? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}操作已取消。${NC}"
    exit 0
fi

echo ""

# 创建临时目录
TEMP_DIR=$(mktemp -d)
echo -e "${BLUE}解压备份文件到临时目录...${NC}"

tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR" 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ 解压失败！${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "${GREEN}✓ 解压完成${NC}"
echo ""

# 查找SQL文件
SQL_DIR=$(find "$TEMP_DIR" -type d -name "20*" | head -1)
if [ -z "$SQL_DIR" ]; then
    echo -e "${RED}错误: 未找到SQL文件目录！${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 恢复主数据库
echo -e "${BLUE}[1/2] 恢复主数据库 club_master...${NC}"
if [ -f "$SQL_DIR/club_master.sql" ]; then
    mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" < "$SQL_DIR/club_master.sql" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 主数据库恢复成功${NC}"
    else
        echo -e "${RED}✗ 主数据库恢复失败${NC}"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ 未找到主数据库备份文件${NC}"
fi

# 恢复社团数据库
echo ""
echo -e "${BLUE}[2/2] 恢复所有社团数据库...${NC}"

# 查找所有社团数据库备份文件
SQL_FILES=$(find "$SQL_DIR" -name "club_*.sql" | grep -v "club_master.sql")

# 计数器
total=$(echo "$SQL_FILES" | wc -l)
success=0
failed=0

# 循环恢复每个社团数据库
for sql_file in $SQL_FILES; do
    db_name=$(basename "$sql_file" .sql)
    echo -n "  ├─ 恢复 $db_name ... "

    mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" < "$sql_file" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC}"
        ((success++))
    else
        echo -e "${RED}✗ 失败${NC}"
        ((failed++))
    fi
done

# 清理临时文件
echo ""
echo -e "${BLUE}清理临时文件...${NC}"
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓ 清理完成${NC}"

# 输出统计信息
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}恢复完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "总计: $((total + 1)) 个数据库"
echo -e "${GREEN}成功: $((success + 1)) 个${NC}"
if [ $failed -gt 0 ]; then
    echo -e "${RED}失败: $failed 个${NC}"
fi
echo ""

echo -e "${GREEN}数据库恢复脚本执行完成！${NC}"
