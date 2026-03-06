# 社团管理系统（多社团版）

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.18-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Vue](https://img.shields.io/badge/Vue-2.6.14-4fc08d.svg)](https://vuejs.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)

前后端分离的高校社团管理系统，支持 42 个社团独立数据库隔离运行。  
后端通过 JWT 中的 `clubId` 动态切换数据源，实现单套代码多社团并行。

## 1. 技术栈

- 后端: Spring Boot 2.7.18 + Spring Security + MyBatis-Plus + JWT
- 前端: Vue2 + Vue Router + Vuex + Element UI + Axios
- 数据库: MySQL 8.0+
- 构建: Maven 3.6+ / Node.js 16+（建议 18 LTS）

## 2. 项目结构

```text
.
├── backend/                     # Java 后端
├── frontend/                    # Vue 前端
├── database/                    # SQL 与数据库脚本
│   ├── init/                    # 初始化 SQL（主库、社团表结构）
│   └── scripts/                 # 批量初始化/备份恢复脚本
├── DEPLOYMENT_BAOTA.md          # 宝塔部署文档（旧版，需结合本文）
└── README.md
```

## 3. 核心功能

- 社团选择与登录（登录前可查看社团列表）
- 成员管理（分页、导入、重置密码、个人中心）
- 部门管理（卡片、详情、成员统计）
- 活动管理（创建、审批流、报名、参与人维护）
- 活动附件（上传、下载、预览、权限控制）
- 导出（Excel/ZIP，支持活动详情导出）
- 统计看板（成员、部门、活动维度）

## 4. 环境要求

- JDK 21
- Maven 3.6+
- Node.js 16+（建议 18 LTS）
- MySQL 8.0+
- MySQL 客户端命令 `mysql`（脚本依赖）

## 5. 快速启动

### 5.1 克隆项目

```bash
git clone <repository-url>
cd club_management-main/club_management-main
```

### 5.2 初始化数据库（推荐一键）

默认主库名为 `mucclub`。  
初始化会创建 `mucclub.clubs` 以及 42 个 `club_*` 社团库。

#### Windows (PowerShell)

```powershell
cd database\scripts
.\init_all_42_clubs.ps1 -MySQLUser root
```

可选参数:
- `-MySQLHost localhost`
- `-MySQLPort 3306`
- `-MasterDatabase mucclub`

#### Linux / macOS

```bash
chmod +x database/scripts/init_all_42_clubs.sh
MYSQL_USER=root bash database/scripts/init_all_42_clubs.sh
```

可选环境变量:
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MASTER_DB`（默认 `mucclub`）

### 5.3 手动初始化（单社团场景）

```bash
# 1) 初始化主库与社团元数据
mysql -u root -p < database/init/database_club_master_init.sql

# 2) 手动创建一个社团数据库（示例）
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS club_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 3) 初始化该社团库表结构与基础部门数据
mysql -u root -p club_demo < database/init/database_club_schema.sql
```

### 5.4 启动后端

修改配置文件:
- `backend/src/main/resources/application.yml`
- `backend/src/main/resources/application-prod.yml`（生产）

重点检查:
- `spring.datasource.master.*`
- `spring.datasource.club.*`
- `jwt.secret`
- `file.upload.path`

注意:
- `spring.datasource.club.username` 对应账号需要对所有 `club_*` 库有读写权限
- 若主库名仍配置为 `mucclub`，请确保初始化脚本也使用 `mucclub`

启动:

```bash
cd backend
mvn clean package -DskipTests
java -jar target/club-management-1.0.0.jar
```

默认后端地址:
- `http://localhost:8081/api`

### 5.5 启动前端

```bash
cd frontend
npm install
npm run serve
```

默认前端地址:
- `http://localhost:5174`

开发代理:
- `/api` -> `http://localhost:8081`

## 6. 默认账号说明

- 精简版数据库脚本只初始化结构与基础部门，不自动写入成员账号
- 首次使用请通过系统后台添加账号，或按需自行准备导入 SQL

## 7. 数据库脚本说明

`database/init/`:

- `database_club_master_init.sql`: 初始化主库 `mucclub` + `clubs` 元数据
- `database_club_schema.sql`: 单个社团库表结构 + 基础部门种子数据

`database/scripts/`:

- `init_all_42_clubs.ps1`: Windows 一键初始化（主库+建库+表结构）
- `init_all_42_clubs.sh`: Linux/macOS 一键初始化

## 8. 关键接口前缀

- `/auth/*` 认证
- `/club/*` 社团元数据（登录前可访问）
- `/member/*` 成员
- `/dept/*` 部门
- `/activity/*` 活动与审批
- `/activity-member/*` 活动报名
- `/activity/{id}/attachment/*` 活动附件
- `/statistics/*` 统计
- `/export/*` 导出
- `/user/*` 用户中心

## 9. 已知注意事项

- `ExportService` 当前导出历史保存在内存，服务重启后历史丢失
- `/auth/dev/token` 为开发联调用接口，生产环境建议关闭
- 新增社团后，动态数据源在当前实现中通常需要重启后端以加载新库连接

