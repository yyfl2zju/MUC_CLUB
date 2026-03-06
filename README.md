# 社团管理系统（多社团版）

一个面向高校社团场景的管理平台，采用 `Spring Boot + Vue2` 前后端分离架构。  
系统支持多社团数据库隔离：同一套代码可服务多个社团，每个社团使用独立业务库，主库统一管理社团元数据。

## 项目特色

- **多社团数据库隔离**：登录时选择社团，业务请求自动路由到对应 `club_*` 数据库
- **完整业务闭环**：覆盖成员、部门、活动、审批、报名、附件、导出、统计、个人中心
- **角色权限控制**：基于角色的细粒度权限控制（社长/副社长/部长/副部长/干事/指导老师）
- **动态数据源切换**：JWT 携带 `clubId`，后端通过 `ThreadLocal + AbstractRoutingDataSource` 自动切库
- **导出与可视化**：支持 Excel/ZIP 导出与统计图表展示
- **可运维脚本**：提供 Windows/Linux 一键初始化 42 个社团数据库脚本

## 技术栈

### 后端技术

- 框架: Spring Boot `2.7.18`
- 认证: Spring Security + JWT
- ORM: MyBatis-Plus `3.5.3.1`
- 数据源: HikariCP + 动态数据源
- 数据库: MySQL `8.0+`
- 文档处理: Apache POI（Excel）+ iText（PDF）
- 构建工具: Maven
- JDK 版本: JDK `21`

### 前端技术

- 框架: Vue `2.6.14` + Vue Router + Vuex
- UI 组件: Element UI `2.15.14`
- HTTP 客户端: Axios `0.27.2`
- 图表库: ECharts `5.x`
- 样式预处理: Sass
- 构建工具: Vue CLI 4

## 功能模块

### 核心功能

- ✅ 登录认证：社团选择 + 学号/工号 + 密码登录 + JWT 校验
- ✅ 成员管理：分页查询、CRUD、导入、重置密码、详情查看
- ✅ 部门管理：列表、卡片统计、详情、增删改
- ✅ 活动管理：创建、编辑、删除、审批、参与人维护
- ✅ 活动报名：报名、状态更新、记录维护
- ✅ 附件管理：上传、下载、预览、删除、编辑
- ✅ 数据导出：Excel/ZIP 导出与历史记录
- ✅ 统计分析：看板、部门统计、活动统计
- ✅ 个人中心：资料维护、密码修改

### 多社团隔离机制

1. 前端登录携带 `clubId`
2. 后端签发 JWT（包含 `clubId`）
3. `DataSourceInterceptor` / `JwtAuthenticationFilter` 写入 `ClubContext`
4. `DynamicDataSource` 根据 `clubId` 路由到对应数据库
5. 请求结束清理上下文，避免线程复用污染


### 权限控制（当前实现）

| 角色 | 查看成员 | 编辑成员 | 创建活动 | 审批活动 | 导出数据 |
|------|----------|----------|----------|----------|----------|
| 社长 | 全部 | 全部 | ✅ | ✅ | ✅ |
| 副社长 | 全部 | 全部 | ✅ | ✅ | ✅ |
| 部长 | 本部门/受限 | 本部门/受限 | ✅ | ❌ | ✅ |
| 副部长 | 本部门 | ❌ | ❌ | ❌ | ✅ |
| 干事 | 自己 | 自己 | ❌ | ❌ | ❌ |
| 指导老师 | 全部 | ❌ | ❌ | ✅ | ✅ |

## 快速开始

### 环境要求

- JDK 21
- Maven 3.6+
- Node.js 16+（建议 18 LTS）
- MySQL 8.0+
- `mysql` 命令行客户端

### 1. 克隆项目

```bash
git clone https://github.com/yyfl2zju/MUC_CLUB
```

### 2. 初始化数据库（推荐一键）

默认主库：`mucclub`

#### Windows (PowerShell)

```powershell
cd database\scripts
.\init_all_42_clubs.ps1 -MySQLUser root
```

可选参数：
- `-MySQLHost localhost`
- `-MySQLPort 3306`
- `-MasterDatabase mucclub`

#### Linux / macOS

```bash
chmod +x database/scripts/init_all_42_clubs.sh
MYSQL_USER=root bash database/scripts/init_all_42_clubs.sh
```

可选环境变量：
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MASTER_DB`（默认 `mucclub`）

### 3. 手动初始化（单社团场景）

```bash
# 1) 初始化主库与社团元数据
mysql -u root -p < database/init/database_club_master_init.sql

# 2) 创建一个社团数据库（示例）
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS club_demo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 3) 初始化社团库表结构
mysql -u root -p club_demo < database/init/database_club_schema.sql
```

### 4. 配置后端

编辑：
- `backend/src/main/resources/application.yml`（开发）
- `backend/src/main/resources/application-prod.yml`（生产）

重点检查：
- `spring.datasource.master.*`
- `spring.datasource.club.*`
- `jwt.secret`
- `file.upload.path`

### 5. 启动后端服务

```bash
cd backend
mvn clean package -DskipTests
java -jar target/club-management-1.0.0.jar
```

后端默认地址：`http://localhost:8081/api`

### 6. 启动前端服务

```bash
cd frontend
npm install
npm run serve
```

前端默认地址：`http://localhost:5174`

### 7. 访问系统

- 前端地址：`http://localhost:5174`
- 后端接口：`http://localhost:8081/api`
- 先选择社团，再进行登录

## 登录与账号说明

- 当前精简数据库脚本默认仅初始化结构与基础部门，不强制写入测试账号
- 首次使用请通过后台导入/新增账号，或自行准备种子数据
- 存在开发联调用接口 `/auth/dev/token`，生产环境建议关闭

## 项目结构

```text
.
├── backend/                     # 后端项目（Spring Boot）
│   ├── src/main/java/com/club/management/
│   │   ├── controller/          # 控制器
│   │   ├── service/             # 业务层
│   │   ├── mapper/              # 数据访问层
│   │   ├── entity/              # 实体
│   │   ├── config/              # 安全、数据源、Web配置
│   │   └── common/              # 通用工具（Result/JwtUtil等）
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   ├── application-prod.yml
│   │   └── mapper/
│   ├── build.ps1
│   ├── deploy.sh
│   └── DEPLOYMENT_GUIDE.md
├── frontend/                    # 前端项目（Vue2）
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
├── database/                    # 数据库脚本
│   ├── init/
│   │   ├── database_club_master_init.sql
│   │   └── database_club_schema.sql
│   └── scripts/
│       ├── init_all_42_clubs.ps1
│       ├── init_all_42_clubs.sh
│       ├── restore_databases.sh
│       └── restore_club_databases.sh
├── nginx_config_baota.conf      # 宝塔Nginx样例
└── README.md
```

## 核心接口分组

- `/auth/*`：认证
- `/club/*`：社团元数据
- `/member/*`：成员
- `/dept/*`：部门
- `/activity/*`：活动与审批
- `/activity-member/*`：报名管理
- `/activity/{activityId}/attachment/*`：活动附件
- `/statistics/*`：统计
- `/export/*`：导出
- `/user/*`：个人中心与用户检索

## 测试说明

项目包含全面的UI自动化测试，使用Playwright框架：

# 运行测试
cd frontend
npm run test

# 生成测试报告
npm run test:report
测试覆盖
✅ 登录功能测试（正常登录、错误密码、空用户名/密码）
✅ 仪表盘功能测试（统计数据、图表显示、权限过滤）
✅ 成员管理功能测试（CRUD操作、批量导入、权限控制）
✅ 活动管理功能测试（创建、编辑、审批、删除）
✅ 活动参与管理测试（报名、取消报名、参与人员管理）
✅ 数据导出功能测试（Excel/PDF导出、下载）
✅ 响应式设计测试（桌面端、平板端、手机端）
✅ 权限控制测试（不同角色的权限验证）
✅ 个人中心测试（信息编辑、密码修改）

## 部署说明

### 开发环境

- 按“快速开始”执行即可

### 生产环境（简要）

1. 后端打包上传
2. 使用 `backend/deploy.sh` 启动（`--spring.profiles.active=prod`）
3. 前端执行 `npm run build`，将 `frontend/dist` 发布到 Nginx
4. 参考配置：`frontend/nginx.conf` 或 `nginx_config_baota.conf`

生产务必处理：
- 修改数据库密码
- 修改 JWT 密钥
- 配置上传目录权限
- 关闭或限制开发调试接口

## 常见问题

### 1. 新增社团后访问失败

- 确认主库 `clubs` 已新增该社团
- 确认已创建对应 `club_*` 库并执行 `database_club_schema.sql`
- 重启后端（当前实现启动时加载动态数据源）

### 2. 附件上传失败

- 检查 `file.upload.path` 是否存在且可写
- 检查 Nginx `client_max_body_size` 与后端限制一致

### 3. 登录后数据串社团

- 确认登录请求携带正确 `clubId`
- 确认 token 中包含 `clubId`
- 确认 `clubs.db_name` 与实际数据库名一致


