# 社团管理系统（多社团数据库隔离版）

> 当前项目根目录即本 README 所在目录：`club_management-main/club_management-main`。
> 发布到新仓库时，应以该目录作为仓库根目录，而不是外层 `club` 目录。

## 1. 项目简介

本项目是高校社团管理平台，采用前后端分离架构，核心目标是“一套后端 + 一套前端 + 多社团独立数据库”。

核心特性：
- 登录前先选择社团，登录后全部业务自动落到该社团数据库
- 主库 `mucclub` 统一管理社团元数据，社团库 `club_*` 承载业务数据
- JWT 中携带 `clubId`，后端通过动态数据源实现请求级别的数据库切换

## 2. 功能范围

- 认证登录：社团选择、学号/工号密码登录、Token 校验
- 成员管理：分页查询、详情、新增、编辑、删除、重置密码、Excel 导入
- 部门管理：列表、卡片统计、详情、新增、修改、删除
- 活动管理：创建、编辑、删除、审批、负责人/部门/参与人维护
- 活动报名：报名、报名状态维护、报名记录查询
- 活动附件：上传、下载、预览、删除、编辑说明
- 统计分析：看板、部门维度统计、活动维度统计
- 数据导出：Excel/ZIP 导出、导出历史下载
- 个人中心：资料维护、密码修改

## 3. 技术栈

### 3.1 后端
- Spring Boot `2.7.18`
- Spring Security（JWT 无状态认证）
- MyBatis-Plus `3.5.3.1`
- HikariCP（连接池）
- MySQL Driver `8.0.33`
- Java `21`

### 3.2 前端
- Vue `2.6.14`
- Vue Router `3.5.4`
- Vuex `3.6.2`
- Element UI `2.15.14`
- Axios `0.27.2`
- Node.js 建议 `18 LTS`（16+可运行）

### 3.3 数据库
- MySQL `8.0+`
- 字符集统一 `utf8mb4`

## 4. 架构与请求链路

### 4.1 运行形态
- 前端：默认 `5174`（开发）
- 后端：默认 `8081`，上下文路径 `/api`
- 主库：`mucclub`
- 社团库：`club_xxx`

### 4.2 动态数据源切换流程

1. 前端登录请求提交 `clubId`
2. 后端登录成功后签发 JWT（claims 含 `clubId`）
3. 请求进入 `JwtAuthenticationFilter` / `DataSourceInterceptor`
4. `ClubContext`（ThreadLocal）写入当前 `clubId`
5. `DynamicDataSource.determineCurrentLookupKey()` 决定路由库
6. MyBatis 在对应数据源执行 SQL
7. 请求结束清理 `ClubContext`，避免线程复用污染

关键类：
- `backend/src/main/java/com/club/management/config/DynamicDataSourceConfig.java`
- `backend/src/main/java/com/club/management/config/DynamicDataSource.java`
- `backend/src/main/java/com/club/management/config/ClubContext.java`
- `backend/src/main/java/com/club/management/config/DataSourceInterceptor.java`
- `backend/src/main/java/com/club/management/config/JwtAuthenticationFilter.java`
- `backend/src/main/java/com/club/management/common/JwtUtil.java`

## 5. 目录结构

```text
.
├── backend/
│   ├── src/main/java/com/club/management/
│   │   ├── controller/
│   │   ├── service/
│   │   ├── mapper/
│   │   ├── entity/
│   │   ├── config/
│   │   └── common/
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   ├── application-prod.yml
│   │   └── mapper/
│   ├── build.ps1
│   ├── deploy.sh
│   └── DEPLOYMENT_GUIDE.md
├── frontend/
│   ├── src/
│   │   ├── views/
│   │   ├── components/
│   │   ├── router/
│   │   ├── store/
│   │   └── utils/
│   ├── .env.development
│   ├── .env.production
│   ├── vue.config.js
│   └── nginx.conf
├── database/
│   ├── init/
│   │   ├── database_club_master_init.sql
│   │   └── database_club_schema.sql
│   └── scripts/
│       ├── init_all_42_clubs.ps1
│       ├── init_all_42_clubs.sh
│       ├── restore_databases.sh
│       └── restore_club_databases.sh
├── nginx_config_baota.conf
└── README.md
```

## 6. 环境准备

- JDK 21
- Maven 3.6+
- Node.js 16+（建议 18 LTS）
- MySQL 8.0+
- 命令行可用 `mysql`

## 7. 快速启动（开发环境）

### 7.1 拉取并进入项目目录

```bash
git clone <your-repo-url>
cd club_management-main/club_management-main
```

### 7.2 初始化数据库（推荐一键）

#### Windows PowerShell

```powershell
cd database\scripts
.\init_all_42_clubs.ps1 -MySQLHost localhost -MySQLPort 3306 -MySQLUser root -MasterDatabase mucclub
```

#### Linux/macOS

```bash
chmod +x database/scripts/init_all_42_clubs.sh
MYSQL_HOST=localhost MYSQL_PORT=3306 MYSQL_USER=root MASTER_DB=mucclub bash database/scripts/init_all_42_clubs.sh
```

### 7.3 手动初始化（单社团/测试场景）

```bash
# 1) 初始化主库 + clubs 元数据
mysql -u root -p < database/init/database_club_master_init.sql

# 2) 创建社团库（示例）
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS club_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 3) 初始化社团库结构
mysql -u root -p club_demo < database/init/database_club_schema.sql
```

### 7.4 启动后端

1. 检查配置文件：
- `backend/src/main/resources/application.yml`
- `backend/src/main/resources/application-prod.yml`

2. 启动：

```bash
cd backend
mvn clean package -DskipTests
java -jar target/club-management-1.0.0.jar
```

后端地址：`http://localhost:8081/api`

### 7.5 启动前端

```bash
cd frontend
npm install
npm run serve
```

前端地址：`http://localhost:5174`

## 8. 配置说明

### 8.1 后端关键配置

`application.yml`（开发）与 `application-prod.yml`（生产）重点字段：

- `server.port`
- `server.servlet.context-path`
- `spring.datasource.master.*`
- `spring.datasource.club.*`
- `jwt.secret`
- `jwt.expiration`
- `file.upload.path`
- `logging.file.name`（生产）

建议：
- 生产环境通过环境变量或启动参数覆盖数据库密码与 JWT 密钥
- 生产环境关闭 SQL 控制台日志（已在 `application-prod.yml` 配置）

### 8.2 前端关键配置

- `frontend/.env.development`
- `frontend/.env.production`
- `frontend/vue.config.js`

当前默认：
- `VUE_APP_BASE_API=/api`
- 开发代理目标：`http://localhost:8081`

## 9. 数据库说明

### 9.1 主库 `mucclub`

关键表：`clubs`
- 保存社团元数据：`id/name/code/db_name/status/theme_color/...`
- `database_club_master_init.sql` 默认写入 42 个社团（幂等更新）

### 9.2 社团库 `club_*`

`database_club_schema.sql` 初始化以下核心表：
- `dept`
- `member`
- `sys_user`
- `activity`
- `activity_approver`
- `activity_dept`
- `activity_member`
- `activity_attachment`
- `sys_log`
- `sys_message`（历史兼容）

### 9.3 初始化脚本（保留最关键）

`database/init/`：
- `database_club_master_init.sql`
- `database_club_schema.sql`

`database/scripts/`：
- `init_all_42_clubs.ps1`
- `init_all_42_clubs.sh`

## 10. 接口分组

- `/auth/*` 认证（登录、Token 校验、开发 token）
- `/club/*` 社团元数据
- `/member/*` 成员管理
- `/dept/*` 部门管理
- `/activity/*` 活动管理与审批
- `/activity-member/*` 活动报名
- `/activity/{activityId}/attachment/*` 活动附件
- `/statistics/*` 统计
- `/export/*` 导出
- `/user/*` 个人中心与用户检索

## 11. 权限规则（当前实现）

权限主要在 Service 层硬编码判断：

- 成员新增/删除/重置密码：社长、副社长
- 成员编辑：社长、副社长（部长受部门限制；指导老师不可维护档案）
- 部门删除：社长、副社长
- 活动创建/编辑：社长、副社长、部长
- 活动删除：社长、副社长
- 报名列表/报名状态维护：社长、副社长、部长
- 导出：社长、副社长、部长、副部长、指导老师（含系统管理员兼容）

## 12. 生产部署参考

### 12.1 后端

- 本地打包：`backend/build.ps1` 或 `mvn clean package -DskipTests`
- 服务器部署：`backend/deploy.sh`
- 详细文档：`backend/DEPLOYMENT_GUIDE.md`

### 12.2 前端

```bash
cd frontend
npm install
npm run build
```

构建产物在 `frontend/dist`。

Nginx 可参考：
- `frontend/nginx.conf`（通用模板）
- `nginx_config_baota.conf`（宝塔示例）

## 13. 常见问题

### 13.1 登录后提示无权限或数据错社团
- 确认登录请求是否携带了正确 `clubId`
- 确认 JWT 中包含 `clubId`
- 确认 `clubs` 表中的 `db_name` 与实际数据库一致

### 13.2 新增社团后访问失败
- 在主库 `clubs` 先写入社团元数据
- 创建对应 `club_xxx` 数据库并执行 `database_club_schema.sql`
- 重启后端（当前实现在启动时加载社团数据源）

### 13.3 上传附件失败
- 检查 `file.upload.path` 是否存在且具备写权限
- 检查 Nginx `client_max_body_size` 与后端大小限制一致

### 13.4 脚本执行失败
- 确认 `mysql` 命令可用
- 确认用户对 `mucclub` 和所有 `club_*` 库有建库/建表权限
- 优先使用初始化脚本，不要直接用带历史密码的恢复脚本模板

## 14. 已知限制与改进建议

- 动态数据源在应用启动时初始化，新增社团后通常需要重启服务
- 权限逻辑散落在 Service 层，建议后续统一到注解/AOP 鉴权
- 部分恢复脚本仍含示例明文密码，需要上线前改为环境变量输入
- `/auth/dev/token` 仅用于联调，生产必须关闭

## 15. 交接文档

详细交接请见 `PROJECT_HANDOVER.md`（本地交接用文档）。
