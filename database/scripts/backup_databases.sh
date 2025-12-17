#!/bin/bash
# =====================================================
# 社团管理系统 - 数据库备份脚本
# 说明: 备份所有社团数据库和主数据库
# =====================================================

# 数据库配置
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="wj20050223"  # 请修改为你的数据库密码

# 备份配置
BACKUP_DIR="./backups"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_PATH="$BACKUP_DIR/$DATE"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}社团数据库备份脚本${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# 创建备份目录
mkdir -p "$BACKUP_PATH"

# 备份主数据库
echo -e "${BLUE}[1/2] 备份主数据库 club_master...${NC}"
mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
    --databases club_master \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    > "$BACKUP_PATH/club_master.sql" 2>/dev/null

if [ $? -eq 0 ]; then
    SIZE=$(du -sh "$BACKUP_PATH/club_master.sql" | cut -f1)
    echo -e "${GREEN}✓ 主数据库备份成功 ($SIZE)${NC}"
else
    echo -e "${RED}✗ 主数据库备份失败${NC}"
    exit 1
fi

# 获取所有社团数据库列表
echo ""
echo -e "${BLUE}[2/2] 备份所有社团数据库...${NC}"

CLUB_DBS=$(mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
    -N -e "SHOW DATABASES LIKE 'club_%';" 2>/dev/null | grep -v "club_master")

# 计数器
total=$(echo "$CLUB_DBS" | wc -l)
success=0
failed=0

# 循环备份每个社团数据库
for db_name in $CLUB_DBS; do
    echo -n "  ├─ 备份 $db_name ... "

    mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" \
        --databases "$db_name" \
        --single-transaction \
        --routines \
        --triggers \
        --events \
        > "$BACKUP_PATH/${db_name}.sql" 2>/dev/null

    if [ $? -eq 0 ]; then
        SIZE=$(du -sh "$BACKUP_PATH/${db_name}.sql" | cut -f1)
        echo -e "${GREEN}✓ ($SIZE)${NC}"
        ((success++))
    else
        echo -e "${RED}✗ 失败${NC}"
        ((failed++))
    fi
done

# 压缩备份文件
echo ""
echo -e "${BLUE}压缩备份文件...${NC}"
cd "$BACKUP_DIR"
tar -czf "${DATE}.tar.gz" "$DATE" 2>/dev/null

if [ $? -eq 0 ]; then
    ARCHIVE_SIZE=$(du -sh "${DATE}.tar.gz" | cut -f1)
    echo -e "${GREEN}✓ 压缩完成 ($ARCHIVE_SIZE)${NC}"

    # 删除未压缩的SQL文件
    rm -rf "$DATE"
    echo -e "${GREEN}✓ 清理临时文件完成${NC}"
else
    echo -e "${RED}✗ 压缩失败${NC}"
fi

cd - > /dev/null

# 输出统计信息
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}备份完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "备份位置: $BACKUP_DIR/${DATE}.tar.gz"
echo -e "总计: $((total + 1)) 个数据库 (1个主库 + $total 个社团库)"
echo -e "${GREEN}成功: $((success + 1)) 个${NC}"
if [ $failed -gt 0 ]; then
    echo -e "${RED}失败: $failed 个${NC}"
fi
echo ""

# 显示备份文件列表
echo -e "${YELLOW}最近5次备份:${NC}"
ls -lht "$BACKUP_DIR" | grep "tar.gz" | head -5
echo ""

echo -e "${GREEN}备份脚本执行完成！${NC}"
