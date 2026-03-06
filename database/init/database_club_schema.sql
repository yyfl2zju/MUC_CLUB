-- =====================================================
-- 社团管理系统 - 单社团数据库表结构初始化脚本
-- 用途:
-- 1. 初始化单个社团数据库基础表
-- 2. 可重复执行（幂等）
-- 3. 不包含业务数据（仅表结构）
--
-- 使用方式:
-- mysql -u <user> -p <club_db_name> < database/init/database_club_schema.sql
-- =====================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. 部门表
CREATE TABLE IF NOT EXISTS dept (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '部门ID',
  name VARCHAR(50) NOT NULL COMMENT '部门名称',
  intro VARCHAR(500) DEFAULT NULL COMMENT '部门简介',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uk_dept_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- 2. 成员表
CREATE TABLE IF NOT EXISTS member (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '成员ID',
  stu_id VARCHAR(20) NOT NULL COMMENT '学号/工号',
  name VARCHAR(50) NOT NULL COMMENT '姓名',
  gender ENUM('男', '女') NOT NULL COMMENT '性别',
  college VARCHAR(100) NOT NULL COMMENT '学院',
  major VARCHAR(100) DEFAULT NULL COMMENT '专业',
  grade ENUM('大一', '大二', '大三', '大四', '研一', '研二', '研三') DEFAULT NULL COMMENT '年级',
  phone VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  email VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  join_date DATE DEFAULT NULL COMMENT '入社日期',
  leave_date DATE DEFAULT NULL COMMENT '离社日期',
  dept_id BIGINT DEFAULT NULL COMMENT '部门ID',
  role ENUM('社长', '副社长', '部长', '副部长', '干事', '指导老师') NOT NULL COMMENT '角色',
  password VARCHAR(255) NOT NULL COMMENT 'BCrypt密码',
  create_by BIGINT DEFAULT NULL COMMENT '创建人ID',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uk_member_stu_id (stu_id),
  KEY idx_member_dept_id (dept_id),
  KEY idx_member_role (role),
  CONSTRAINT fk_member_dept_id FOREIGN KEY (dept_id) REFERENCES dept(id) ON DELETE SET NULL,
  CONSTRAINT fk_member_create_by FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成员表';

-- 3. 系统用户表（登录认证）
CREATE TABLE IF NOT EXISTS sys_user (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '系统用户ID',
  stu_id VARCHAR(20) NOT NULL COMMENT '学号/工号',
  name VARCHAR(50) NOT NULL COMMENT '姓名',
  role ENUM('社长', '副社长', '部长', '副部长', '干事', '指导老师', '系统管理员') NOT NULL COMMENT '角色',
  dept_id BIGINT DEFAULT NULL COMMENT '部门ID（兼容 /user/search）',
  password VARCHAR(255) NOT NULL COMMENT 'BCrypt密码',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态:0禁用,1启用',
  login_attempts TINYINT NOT NULL DEFAULT 0 COMMENT '连续失败次数',
  lock_time DATETIME DEFAULT NULL COMMENT '锁定截止时间',
  create_by BIGINT DEFAULT NULL COMMENT '创建人ID',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY uk_sys_user_stu_id (stu_id),
  KEY idx_sys_user_role (role),
  KEY idx_sys_user_status (status),
  KEY idx_sys_user_dept_id (dept_id),
  CONSTRAINT fk_sys_user_dept_id FOREIGN KEY (dept_id) REFERENCES dept(id) ON DELETE SET NULL,
  CONSTRAINT fk_sys_user_create_by FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- 4. 活动表
CREATE TABLE IF NOT EXISTS activity (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '活动ID',
  name VARCHAR(200) NOT NULL COMMENT '活动名称',
  start_time DATETIME NOT NULL COMMENT '开始时间',
  end_time DATETIME NOT NULL COMMENT '结束时间',
  location VARCHAR(200) DEFAULT NULL COMMENT '活动地点',
  type ENUM('例会', '比赛', '志愿', '外出') NOT NULL COMMENT '活动类型',
  description TEXT COMMENT '活动描述',
  attachments TEXT COMMENT '附件JSON文本（历史兼容字段）',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0待审批,1已通过,2已驳回',
  reject_reason VARCHAR(200) DEFAULT NULL COMMENT '驳回原因',
  create_by BIGINT NOT NULL COMMENT '创建人ID',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_activity_status (status),
  KEY idx_activity_create_by (create_by),
  KEY idx_activity_start_time (start_time),
  CONSTRAINT fk_activity_create_by FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动表';

-- 5. 活动审批人
CREATE TABLE IF NOT EXISTS activity_approver (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '审批记录ID',
  activity_id BIGINT NOT NULL COMMENT '活动ID',
  user_id BIGINT NOT NULL COMMENT '审批人（member.id）',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '审批状态:0待审,1通过,2驳回',
  approval_time DATETIME DEFAULT NULL COMMENT '审批时间',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_activity_approver (activity_id, user_id),
  KEY idx_activity_approver_user (user_id),
  CONSTRAINT fk_activity_approver_activity FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
  CONSTRAINT fk_activity_approver_user FOREIGN KEY (user_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动审批人关系表';

-- 6. 活动责任部门
CREATE TABLE IF NOT EXISTS activity_dept (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '关系ID',
  activity_id BIGINT NOT NULL COMMENT '活动ID',
  dept_id BIGINT NOT NULL COMMENT '部门ID',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY uk_activity_dept (activity_id, dept_id),
  KEY idx_activity_dept_dept (dept_id),
  CONSTRAINT fk_activity_dept_activity FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
  CONSTRAINT fk_activity_dept_dept FOREIGN KEY (dept_id) REFERENCES dept(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动责任部门关系表';

-- 7. 活动报名记录
CREATE TABLE IF NOT EXISTS activity_member (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '报名记录ID',
  activity_id BIGINT NOT NULL COMMENT '活动ID',
  member_id BIGINT NOT NULL COMMENT '成员ID',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  signup_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
  signup_status TINYINT NOT NULL DEFAULT 0 COMMENT '报名状态:0已报名,1已确认,2已取消',
  notes VARCHAR(500) DEFAULT NULL COMMENT '备注',
  UNIQUE KEY uk_activity_member (activity_id, member_id),
  KEY idx_activity_member_member (member_id),
  CONSTRAINT fk_activity_member_activity FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
  CONSTRAINT fk_activity_member_member FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动报名表';

-- 8. 活动附件
CREATE TABLE IF NOT EXISTS activity_attachment (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '附件ID',
  activity_id BIGINT NOT NULL COMMENT '活动ID',
  file_name VARCHAR(255) NOT NULL COMMENT '服务器文件名',
  original_name VARCHAR(255) NOT NULL COMMENT '原文件名',
  file_path VARCHAR(500) NOT NULL COMMENT '相对路径',
  file_size BIGINT NOT NULL COMMENT '文件大小（字节）',
  file_type VARCHAR(100) DEFAULT NULL COMMENT 'MIME类型',
  file_ext VARCHAR(20) DEFAULT NULL COMMENT '扩展名',
  upload_by BIGINT NOT NULL COMMENT '上传人ID',
  upload_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
  description VARCHAR(500) DEFAULT NULL COMMENT '附件说明',
  download_count INT NOT NULL DEFAULT 0 COMMENT '下载次数',
  KEY idx_attachment_activity_id (activity_id),
  KEY idx_attachment_upload_by (upload_by),
  CONSTRAINT fk_attachment_activity FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
  CONSTRAINT fk_attachment_upload_by FOREIGN KEY (upload_by) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动附件表';

-- 9. 系统日志（后端 LogService 使用）
CREATE TABLE IF NOT EXISTS sys_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
  operator VARCHAR(100) NOT NULL COMMENT '操作人',
  operation VARCHAR(200) NOT NULL COMMENT '操作内容',
  method VARCHAR(100) DEFAULT NULL COMMENT '请求方法',
  params TEXT COMMENT '请求参数',
  ip VARCHAR(50) DEFAULT NULL COMMENT 'IP地址',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  KEY idx_sys_log_create_time (create_time),
  KEY idx_sys_log_operator (operator)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统日志表';

-- 10. 站内消息（兼容旧迁移脚本）
CREATE TABLE IF NOT EXISTS sys_message (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '消息ID',
  recipient_id BIGINT NOT NULL COMMENT '接收人ID',
  sender_id BIGINT DEFAULT NULL COMMENT '发送人ID',
  title VARCHAR(100) NOT NULL COMMENT '标题',
  content VARCHAR(2000) NOT NULL COMMENT '内容',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '状态:0未读,1已读',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  KEY idx_sys_message_recipient_id (recipient_id),
  KEY idx_sys_message_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内消息表';

-- 11. 基础部门种子数据（最小可用集）
INSERT INTO dept (id, name, intro, sort) VALUES
  (1, '宣传部', '负责品牌宣传、活动物料和内容运营', 10),
  (2, '技术部', '负责技术支持、平台维护和信息化建设', 20),
  (3, '培训服务部', '负责成员培训、活动保障和志愿服务', 30),
  (4, '办公室', '负责综合协调、文档归档和行政事务', 40)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  intro = VALUES(intro),
  sort = VALUES(sort);

SET FOREIGN_KEY_CHECKS = 1;

SELECT '社团库表结构与基础部门数据初始化完成。' AS message;
