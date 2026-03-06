#!/bin/bash
# =====================================================
# 后端部署脚本（在服务器上执行）
# 使用方法: bash deploy.sh
# =====================================================

# 配置变量
APP_NAME="club-management"
JAR_NAME="club-management.jar"
DEPLOY_DIR="/www/server/club"
LOG_DIR="$DEPLOY_DIR/logs"
PID_FILE="$DEPLOY_DIR/app.pid"
LOG_FILE="$LOG_DIR/app.log"
JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"
PROFILE="prod"

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   社团管理系统后端部署脚本${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查是否已运行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat $PID_FILE)
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}正在停止旧的应用进程 (PID: $OLD_PID)...${NC}"
        kill $OLD_PID
        sleep 3
        
        # 强制结束
        if ps -p $OLD_PID > /dev/null 2>&1; then
            echo -e "${RED}强制结束进程...${NC}"
            kill -9 $OLD_PID
        fi
    fi
    rm -f $PID_FILE
fi

# 创建必要的目录
echo -e "${GREEN}创建必要的目录...${NC}"
mkdir -p $DEPLOY_DIR
mkdir -p $LOG_DIR
mkdir -p /www/wwwroot/mucclub.xyz/uploads
mkdir -p /www/wwwroot/club/uploads

# 设置权限
chmod 755 $DEPLOY_DIR
chmod 755 $LOG_DIR
chmod 755 /www/wwwroot/mucclub.xyz/uploads
chmod 755 /www/wwwroot/club/uploads

# 检查JAR文件
if [ ! -f "$DEPLOY_DIR/$JAR_NAME" ]; then
    echo -e "${RED}错误: 找不到 $JAR_NAME 文件！${NC}"
    echo -e "${YELLOW}请先上传 JAR 文件到 $DEPLOY_DIR 目录${NC}"
    exit 1
fi

# 备份日志
if [ -f "$LOG_FILE" ]; then
    BACKUP_LOG="$LOG_DIR/app.log.$(date +%Y%m%d_%H%M%S)"
    mv $LOG_FILE $BACKUP_LOG
    echo -e "${GREEN}旧日志已备份到: $BACKUP_LOG${NC}"
fi

# 启动应用
echo -e "${GREEN}启动应用...${NC}"
cd $DEPLOY_DIR

nohup java $JAVA_OPTS \
    -jar $JAR_NAME \
    --spring.profiles.active=$PROFILE \
    > $LOG_FILE 2>&1 &

NEW_PID=$!
echo $NEW_PID > $PID_FILE

echo -e "${GREEN}应用已启动 (PID: $NEW_PID)${NC}"

# 等待启动
echo -e "${YELLOW}等待应用启动...${NC}"
sleep 5

# 检查进程
if ps -p $NEW_PID > /dev/null 2>&1; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ 部署成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "PID: $NEW_PID"
    echo -e "日志文件: $LOG_FILE"
    echo -e "查看日志: tail -f $LOG_FILE"
    echo -e "停止服务: kill $NEW_PID"
    echo ""
    
    # 显示最近的日志
    echo -e "${YELLOW}最近的日志:${NC}"
    tail -n 20 $LOG_FILE
else
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}✗ 启动失败！${NC}"
    echo -e "${RED}========================================${NC}"
    echo -e "${YELLOW}查看错误日志:${NC}"
    tail -n 50 $LOG_FILE
    exit 1
fi
