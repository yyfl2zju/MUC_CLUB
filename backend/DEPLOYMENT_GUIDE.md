# 后端部署指南

## 📋 部署前准备

### 1. 服务器环境要求
- ✅ 操作系统: Linux (CentOS/Ubuntu/Debian)
- ✅ Java: JDK 21
- ✅ MySQL: 8.0+
- ✅ 内存: 至少 1GB
- ✅ 磁盘: 至少 5GB

### 2. 本地环境要求
- ✅ Maven 3.6+
- ✅ JDK 21

---

## 🚀 部署步骤

### 步骤1: 本地打包

#### Windows PowerShell:
```powershell
# 进入后端目录
cd backend

# 执行打包脚本
.\build.ps1
```

#### 或手动打包:
```bash
mvn clean package -DskipTests
```

打包成功后，在 `target/` 目录会生成 `club-management-1.0.0.jar`

---

### 步骤2: 服务器准备

#### 2.1 安装 JDK 21

**宝塔面板方式:**
1. 登录宝塔面板
2. 软件商店 → 搜索 "OpenJDK"
3. 安装 "OpenJDK 21"

**命令行方式 (CentOS/RHEL):**
```bash
# 下载 OpenJDK 21
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz

# 解压
tar -zxvf jdk-21_linux-x64_bin.tar.gz -C /usr/local/

# 配置环境变量
echo 'export JAVA_HOME=/usr/local/jdk-21' >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
source /etc/profile

# 验证
java -version
```

#### 2.2 创建目录结构
```bash
# SSH登录服务器后执行
mkdir -p /www/server/club
mkdir -p /www/server/club/logs
mkdir -p /www/wwwroot/mucclub.xyz/uploads
mkdir -p /www/wwwroot/club/uploads

# 设置权限
chmod 755 /www/server/club
chmod 755 /www/server/club/logs
chmod 755 /www/wwwroot/mucclub.xyz/uploads
```

#### 2.3 配置数据库

确保MySQL数据库已初始化，并包含以下数据库：
- `mucclub` (主数据库，存储社团信息)
- 各个社团的独立数据库

```bash
# 检查数据库
mysql -u mucclub -p
> SHOW DATABASES;
> USE mucclub;
> SHOW TABLES;
```

---

### 步骤3: 上传JAR包

#### 方式A: 宝塔面板上传
1. 登录宝塔面板
2. 文件 → 进入 `/www/server/club/`
3. 上传 `target/club-management-1.0.0.jar`
4. 重命名为 `club-management.jar`

#### 方式B: SCP上传
```bash
# 在本地PowerShell执行
scp target/club-management-1.0.0.jar root@121.41.61.35:/www/server/club/club-management.jar
```

#### 方式C: FTP工具
使用 FileZilla 或 WinSCP 上传

---

### 步骤4: 上传部署脚本

上传 `deploy.sh` 到服务器 `/www/server/club/`

```bash
# 本地执行
scp deploy.sh root@121.41.61.35:/www/server/club/

# 服务器上设置可执行权限
chmod +x /www/server/club/deploy.sh
```

---

### 步骤5: 启动应用

#### 方式A: 使用部署脚本（推荐）
```bash
# SSH登录服务器
cd /www/server/club
bash deploy.sh
```

#### 方式B: 手动启动
```bash
cd /www/server/club

# 后台启动
nohup java -jar club-management.jar \
  --spring.profiles.active=prod \
  > logs/app.log 2>&1 &

# 记录PID
echo $! > app.pid
```

---

### 步骤6: 验证部署

#### 6.1 检查进程
```bash
# 查看进程
ps aux | grep club-management

# 查看端口
netstat -tuln | grep 8081
# 或
ss -tuln | grep 8081
```

#### 6.2 查看日志
```bash
# 实时查看日志
tail -f /www/server/club/logs/app.log

# 查看启动日志
tail -n 100 /www/server/club/logs/app.log

# 搜索错误
grep -i error /www/server/club/logs/app.log
```

#### 6.3 测试API
```bash
# 测试健康检查（如果有）
curl http://localhost:8081/api/health

# 测试社团列表接口
curl http://localhost:8081/api/club/list
```

---

## 🔧 管理命令

### 启动服务
```bash
cd /www/server/club
bash deploy.sh
```

### 停止服务
```bash
# 优雅停止
kill $(cat /www/server/club/app.pid)

# 强制停止
kill -9 $(cat /www/server/club/app.pid)
```

### 重启服务
```bash
cd /www/server/club
bash deploy.sh  # 脚本会自动停止旧进程并启动新进程
```

### 查看状态
```bash
# 查看进程
ps aux | grep club-management

# 查看端口
netstat -tuln | grep 8081

# 查看日志
tail -f /www/server/club/logs/app.log
```

---

## 🛠️ 故障排查

### 问题1: 启动失败 - 端口被占用
```bash
# 查找占用8081端口的进程
lsof -i:8081
# 或
netstat -tuln | grep 8081

# 结束进程
kill -9 <PID>
```

### 问题2: 数据库连接失败
```bash
# 检查MySQL是否运行
systemctl status mysql
# 或
systemctl status mysqld

# 测试数据库连接
mysql -h localhost -u mucclub -p
> SELECT 1;

# 检查配置文件中的数据库密码
```

### 问题3: 内存不足
```bash
# 查看内存使用
free -h

# 调整JVM参数（在deploy.sh中）
JAVA_OPTS="-Xms256m -Xmx512m"  # 减小内存占用
```

### 问题4: 文件上传失败
```bash
# 检查上传目录权限
ls -la /www/wwwroot/mucclub.xyz/uploads

# 设置正确权限
chown -R www:www /www/wwwroot/mucclub.xyz/uploads
chmod 755 /www/wwwroot/mucclub.xyz/uploads
```

### 问题5: 查看详细错误
```bash
# 查看完整日志
cat /www/server/club/logs/app.log

# 查看最近错误
tail -n 200 /www/server/club/logs/app.log | grep -i error

# 查看Spring启动日志
grep "Started ClubManagement" /www/server/club/logs/app.log
```

---

## 🔐 安全建议

### 1. 使用环境变量存储敏感信息
```bash
# 创建环境变量文件
cat > /www/server/club/env.sh << 'EOF'
export DB_PASSWORD="your_secure_password"
export JWT_SECRET="your_jwt_secret"
EOF

# 修改启动命令
source /www/server/club/env.sh
nohup java -jar club-management.jar \
  --spring.datasource.master.password=$DB_PASSWORD \
  --jwt.secret=$JWT_SECRET \
  --spring.profiles.active=prod \
  > logs/app.log 2>&1 &
```

### 2. 定期备份
```bash
# 备份数据库
mysqldump -u mucclub -p mucclub > backup_$(date +%Y%m%d).sql

# 备份上传文件
tar -czf uploads_backup_$(date +%Y%m%d).tar.gz /www/wwwroot/mucclub.xyz/uploads
```

### 3. 配置防火墙
```bash
# 开放8081端口（仅本地访问）
# 通过nginx代理，不需要对外开放8081端口

# 检查防火墙规则
firewall-cmd --list-all
```

---

## 📊 性能优化

### 1. JVM调优
```bash
# 在deploy.sh中优化JAVA_OPTS
JAVA_OPTS="-Xms512m -Xmx1024m \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -XX:+HeapDumpOnOutOfMemoryError \
  -XX:HeapDumpPath=/www/server/club/logs/"
```

### 2. 数据库连接池优化
已在 `application-prod.yml` 中配置：
- 最小空闲连接: 10
- 最大连接数: 30

### 3. 日志级别调整
生产环境已配置为 `info` 级别，减少日志输出。

---

## 🔄 更新部署

### 更新步骤:
1. 本地重新打包: `.\build.ps1`
2. 上传新的JAR包到服务器
3. 执行部署脚本: `bash deploy.sh`

部署脚本会自动停止旧版本并启动新版本。

---

## 📞 支持

如遇到问题，请查看：
- 应用日志: `/www/server/club/logs/app.log`
- Nginx日志: `/www/wwwlogs/121.41.61.35.error.log`
- 系统日志: `/var/log/messages`
