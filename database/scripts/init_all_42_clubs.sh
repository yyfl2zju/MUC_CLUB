#!/usr/bin/env bash

# =====================================================
# 社团管理系统 - 一键初始化全部社团数据库 (Linux/macOS)
# 最小依赖:
# 1) database/init/database_club_master_init.sql
# 2) database/init/database_club_schema.sql
#
# 功能:
# 1) 初始化主库与 clubs 元数据
# 2) 根据 clubs.db_name 自动创建社团库
# 3) 初始化每个社团库的表结构与基础部门数据
# =====================================================

set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-localhost}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
MASTER_DB="${MASTER_DB:-mucclub}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATABASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

MASTER_INIT_FILE="${DATABASE_DIR}/init/database_club_master_init.sql"
SCHEMA_FILE="${DATABASE_DIR}/init/database_club_schema.sql"

STATIC_DATABASES=(
  club_lxjb club_lxyx club_56jws club_kab club_muc club_jsjxh
  club_gybmsy club_jwjzxc club_jhctwh club_qhs club_qnjycyzdfwzx
  club_qnsh club_qnzq club_ruxingshe club_sswl club_syryjl
  club_szsc club_tjq club_tjqs club_wdqc club_xygz club_xyldw
  club_xhyqyx club_ylxxs club_yyjt club_yypqq club_ygbl club_zywh
  club_zlzq club_seca club_tsqwd club_qnyq club_wwybwg club_xbsj
  club_amyxyjjs club_ywzjpq club_zmpkqs club_qcpbxh club_hhfps
  club_ckqhs club_xskccz club_ymxcsgys
)

run_sql_file() {
  local sql_file="$1"
  local db_name="${2:-}"

  if [[ ! -f "$sql_file" ]]; then
    echo "错误: SQL文件不存在: $sql_file"
    return 1
  fi

  if [[ -n "$db_name" ]]; then
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" "$db_name" < "$sql_file"
  else
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" < "$sql_file"
  fi
}

get_databases_from_master() {
  mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -N \
    -e "SELECT db_name FROM clubs WHERE status = 1 ORDER BY id;" "$MASTER_DB" 2>/dev/null || true
}

create_database() {
  local db_name="$1"
  mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" \
    -e "CREATE DATABASE IF NOT EXISTS ${db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >/dev/null
}

echo "======================================"
echo "社团数据库一键初始化（精简版）"
echo "======================================"

if ! command -v mysql >/dev/null 2>&1; then
  echo "错误: 未检测到 mysql 命令，请先安装 MySQL 客户端。"
  exit 1
fi

for f in "$MASTER_INIT_FILE" "$SCHEMA_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "错误: 缺少必要文件: $f"
    exit 1
  fi
done

if [[ -z "$MYSQL_PASSWORD" ]]; then
  read -rsp "请输入MySQL密码: " MYSQL_PASSWORD
  printf '\n'
fi

export MYSQL_PWD="$MYSQL_PASSWORD"
trap 'unset MYSQL_PWD' EXIT

echo "检查MySQL连接..."
if ! mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -N -e "SELECT 1;" >/dev/null 2>&1; then
  echo "错误: MySQL连接失败，请检查连接参数与密码。"
  exit 1
fi
echo "MySQL连接成功。"

echo ""
echo "步骤 1/3: 初始化主库元数据..."
run_sql_file "$MASTER_INIT_FILE"
echo "主库初始化完成。"

echo ""
echo "步骤 2/3: 创建社团数据库..."
mapfile -t DATABASES < <(get_databases_from_master)
if [[ "${#DATABASES[@]}" -eq 0 ]]; then
  echo "警告: 无法从主库读取社团列表，回退到静态42库名单。"
  DATABASES=("${STATIC_DATABASES[@]}")
fi

for db in "${DATABASES[@]}"; do
  create_database "$db"
done
echo "社团数据库创建完成，共 ${#DATABASES[@]} 个。"

echo ""
echo "步骤 3/3: 初始化社团库表结构..."
SUCCESS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT="${#DATABASES[@]}"
INDEX=0

for db in "${DATABASES[@]}"; do
  INDEX=$((INDEX + 1))
  echo -n "[$INDEX/$TOTAL_COUNT] $db"
  if run_sql_file "$SCHEMA_FILE" "$db"; then
    echo " -> 成功"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo " -> 失败"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
done

echo ""
echo "======================================"
echo "初始化完成"
echo "社团库成功: $SUCCESS_COUNT"
echo "社团库失败: $FAIL_COUNT"
echo "======================================"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi
