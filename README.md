# 社团管理系统（多社团版）

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.18-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Vue](https://img.shields.io/badge/Vue-2.6.14-4fc08d.svg)](https://vuejs.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

一个专为高校社团设计的现代化管理系统，前后端分离架构（Spring Boot 2.7 + Vue 2 + MySQL 8），覆盖成员、部门、活动、导出等核心场景。本版支持多个社团独立数据库并行管理，实现真正的数据隔离。


## 🛠️ 技术栈

### 后端技术
| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 2.7.18 | 基础框架 |
| Spring Security | 2.7.18 | 安全认证 |
| MyBatis-Plus | 3.5.3.1 | ORM 框架 |
| MySQL | 8.0+ | 数据库 |
| HikariCP | 默认 | 连接池 |
| JWT | 0.11.5 | Token 认证 |
| Apache POI | 5.2.3 | Excel 导出 |
| iText | 7.2.5 | PDF 导出 |
| Lombok | 默认 | 代码简化 |
| Maven | 3.6+ | 构建工具 |

### 前端技术
| 技术 | 版本 | 说明 |
|------|------|------|
| Vue.js | 2.6.14 | 前端框架 |
| Vue Router | 3.5.4 | 路由管理 |
| Vuex | 3.6.2 | 状态管理 |
| Element UI | 2.15.14 | UI 组件库 |
| Axios | 0.27.2 | HTTP 客户端 |
| ECharts | 5.5.0 | 数据可视化 |
| Sass | 1.72.0 | CSS 预处理器 |
| Vue CLI | 4.5.0 | 脚手架工具 |


## 📦 功能模块

### 1. 社团选择与认证
- **社团选择**：首次访问展示所有启用社团，支持搜索和卡片式选择
- **用户认证**：JWT Token 登录，支持学号/工号 + 密码认证
- **多角色支持**：社长、副社长、部长、副部长、干事、指导老师
- **Token 管理**：自动刷新、过期重定向、跨社团隔离

### 2. 成员管理
- **成员档案**：完整的成员信息管理（学号、姓名、性别、部门、角色等）
- **批量导入**：支持 Excel 批量导入成员数据
- **权限控制**：根据角色限制查看和编辑范围
  - 社长/副社长/指导老师：查看所有成员
  - 部长/副部长：仅查看本部门成员
  - 干事：仅查看自己的信息
- **信息编辑**：支持头像上传、个人信息修改、密码修改

### 3. 部门管理
- **部门 CRUD**：创建、查看、编辑、删除部门
- **成员统计**：实时显示各部门成员数量
- **部门详情**：查看部门成员列表和基本信息
- **权限限制**：仅社长和副社长可管理部门

### 4. 活动管理
- **活动创建**：支持活动基本信息、时间地点、参与部门设置
- **多签审批**：配置多个审批人，支持顺序审批和并行审批
- **活动报名**：成员在线报名、取消报名
- **附件管理**：
  - 上传活动相关文件（图片、文档等）
  - 在线预览（图片、PDF）
  - 下载附件
  - 附件权限控制
- **活动状态**：草稿、待审批、已通过、已拒绝、进行中、已结束

### 5. 数据导出
- **Excel 导出**：
  - 成员名单导出
  - 活动参与记录导出
  - 部门统计导出
- **PDF 导出**：
  - 成员档案 PDF
  - 活动详情 PDF
  - 统计报表 PDF
- **导出历史**：记录所有导出操作，支持重新下载

### 6. 数据统计与可视化
- **仪表盘**：实时显示关键指标
  - 成员总数、部门数量
  - 活动统计（进行中、已结束）
  - 近期活动报名情况
- **图表展示**：基于 ECharts
  - 部门成员分布（饼图）
  - 活动参与趋势（折线图）
  - 月度活动统计（柱状图）

### 7. 个人中心
- **个人信息**：查看和编辑个人资料
- **密码修改**：修改登录密码
- **我的活动**：查看已报名和参与的活动

### 权限控制矩阵

| 角色 | 查看档案 | 编辑档案 | 创建活动 | 审批活动 | 管理部门 | 导出数据 |
|------|----------|----------|----------|----------|----------|----------|
| 社长 | 全部 | 全部 | ✅ | ✅ | ✅ | ✅ |
| 副社长 | 全部 | 全部 | ✅ | ✅ | ✅ | ✅ |
| 部长 | 本部门 | 本部门 | ✅ | ❌ | ❌ | ✅ |
| 副部长 | 本部门 | ❌ | ❌ | ❌ | ❌ | ✅ |
| 干事 | 自己 | 自己 | ❌ | ❌ | ❌ | ❌ |
| 指导老师 | 全部 | ❌ | ❌ | ✅ | ❌ | ✅ |


## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd club_management-main/club_management-main
```

### 2. 数据库准备


#### Windows (PowerShell) - 推荐

```powershell
cd database

# 步骤 1: 创建并初始化主数据库
mysql -u root -p < init/database_club_master_init.sql

# 步骤 2: 创建所有社团数据库
mysql -u root -p < init/create_all_club_databases.sql

# 步骤 3: 批量初始化所有社团数据库的表结构
.\scripts\init_all_club_databases.ps1

# 步骤 4：插入数智实创社数据

```


### 3. 后端配置与启动

#### 3.1 配置文件修改

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    master:
      url: jdbc:mysql://localhost:3306/club_master?...
      username: root        # 修改为你的 MySQL 用户名
      password: your_password  # 修改为你的 MySQL 密码

    club:
      url-prefix: jdbc:mysql://localhost:3306/
      username: root        # 修改为你的 MySQL 用户名
      password: your_password  # 修改为你的 MySQL 密码

# 修改 JWT 密钥（生产环境必须修改）
jwt:
  secret: your-256-bit-secret-key
  expiration: 86400000
```

#### 3.2 构建与运行

```bash
cd backend

# 清理并打包（跳过测试）
mvn clean package -DskipTests

# 运行应用
java -jar target/club-management-1.0.0.jar

# 或者使用 Maven 直接运行
mvn spring-boot:run
```

**验证后端启动成功**：
- 访问 `http://localhost:8081/api/auth/validate` 应返回 401（未认证）
- 日志中应显示多个数据源初始化成功

### 4. 前端配置与启动

#### 4.1 安装依赖

```bash
cd frontend

# 安装 Node.js 依赖
npm install

# 如果 npm 速度慢，可以使用 cnpm 或配置淘宝镜像
# npm config set registry https://registry.npmmirror.com
```

#### 4.2 开发模式运行

```bash
# 启动开发服务器
npm run serve
```

**默认配置**：
- 前端地址: `http://localhost:5174`
- API 代理: `/api` → `http://localhost:8081` (配置在 `vue.config.js`)


### 5. 数据库管理（可选）

```bash
# 进入数据库管理目录
cd database

# 备份数据库
bash scripts/backup_databases.sh

# 恢复数据库
bash scripts/restore_databases.sh backups/backup_file.tar.gz

# 删除所有 club 数据库（Windows）
.\scripts\drop_all_club_databases.ps1

# 删除所有 club 数据库（Linux/Mac）
bash scripts/drop_all_club_databases.sh
```



