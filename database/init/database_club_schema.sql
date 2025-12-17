-- 社团管理系统 - 数据库表结构初始化脚本（仅表结构，无示例数据）
-- 用于批量初始化多个社团数据库
-- 使用方法: mysql -u root -p <database_name> < database_club_schema.sql

-- 1. 创建部门表
CREATE TABLE IF NOT EXISTS dept (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '部门ID',
    name VARCHAR(50) NOT NULL COMMENT '部门名称',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    intro VARCHAR(500) COMMENT '部门简介',
    sort INT DEFAULT 0 COMMENT '排序'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- 2. 创建成员表
CREATE TABLE IF NOT EXISTS member (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '成员ID',
    stu_id VARCHAR(20) NOT NULL UNIQUE COMMENT '学号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    gender ENUM('男', '女') NOT NULL COMMENT '性别',
    college VARCHAR(100) NOT NULL COMMENT '学院',
    major VARCHAR(100) COMMENT '专业',
    grade ENUM('大一', '大二', '大三', '大四', '研一', '研二', '研三') COMMENT '年级',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    join_date DATE COMMENT '加入日期',
    leave_date DATE COMMENT '离开日期',
    dept_id BIGINT COMMENT '部门ID',
    role ENUM('社长', '副社长', '部长', '副部长', '干事', '指导老师') NOT NULL COMMENT '角色',
    password VARCHAR(255) NOT NULL COMMENT '密码',
    create_by BIGINT COMMENT '创建人',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (dept_id) REFERENCES dept(id) ON DELETE SET NULL,
    FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成员表';

-- 3. 创建系统用户表
CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '用户ID',
    stu_id VARCHAR(20) NOT NULL UNIQUE COMMENT '学号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    role ENUM('社长', '副社长', '部长', '副部长', '干事', '指导老师') NOT NULL COMMENT '角色',
    password VARCHAR(255) NOT NULL COMMENT '密码',
    status TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-启用',
    login_attempts TINYINT DEFAULT 0 COMMENT '登录失败次数',
    lock_time DATETIME COMMENT '锁定时间',
    create_by BIGINT COMMENT '创建人',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- 4. 创建活动表
CREATE TABLE IF NOT EXISTS activity (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '活动ID',
    name VARCHAR(200) NOT NULL COMMENT '活动名称',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME NOT NULL COMMENT '结束时间',
    location VARCHAR(200) COMMENT '活动地点',
    type ENUM('例会', '比赛', '志愿', '外出') NOT NULL COMMENT '活动类型',
    description TEXT COMMENT '活动描述',
    attachments JSON COMMENT '附件信息',
    status TINYINT DEFAULT 0 COMMENT '状态：0-待审批，1-已通过，2-已驳回',
    reject_reason VARCHAR(200) COMMENT '驳回理由',
    create_by BIGINT NOT NULL COMMENT '创建人',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动表';

-- 5. 创建活动审批人表
CREATE TABLE IF NOT EXISTS activity_approver (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '审批记录ID',
    activity_id BIGINT NOT NULL COMMENT '活动ID',
    user_id BIGINT NOT NULL COMMENT '审批人ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    status TINYINT DEFAULT 0 COMMENT '审批状态：0-待审批，1-已通过，2-已驳回',
    approval_time DATETIME COMMENT '审批时间',
    FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动审批人表';

-- 6. 创建活动参与人员表
CREATE TABLE IF NOT EXISTS activity_member (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '参与记录ID',
    activity_id BIGINT NOT NULL COMMENT '活动ID',
    member_id BIGINT NOT NULL COMMENT '成员ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    signup_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
    signup_status TINYINT DEFAULT 0 COMMENT '报名状态: 0-已报名, 1-已确认, 2-已取消',
    notes VARCHAR(500) COMMENT '备注信息',
    FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动参与人员表';

-- 7. 创建活动负责部门表
CREATE TABLE IF NOT EXISTS activity_dept (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '负责部门记录ID',
    activity_id BIGINT NOT NULL COMMENT '活动ID',
    dept_id BIGINT NOT NULL COMMENT '部门ID',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
    FOREIGN KEY (dept_id) REFERENCES dept(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动负责部门表';

-- 8. 创建活动附件表
CREATE TABLE IF NOT EXISTS activity_attachment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '附件ID',
    activity_id BIGINT NOT NULL COMMENT '活动ID',
    file_name VARCHAR(255) NOT NULL COMMENT '文件存储名称',
    original_name VARCHAR(255) NOT NULL COMMENT '原始文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT NOT NULL COMMENT '文件大小（字节）',
    file_type VARCHAR(100) COMMENT '文件类型',
    file_ext VARCHAR(20) COMMENT '文件扩展名',
    upload_by BIGINT NOT NULL COMMENT '上传人ID',
    upload_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',
    description VARCHAR(500) COMMENT '附件说明',
    download_count INT DEFAULT 0 COMMENT '下载次数',
    FOREIGN KEY (activity_id) REFERENCES activity(id) ON DELETE CASCADE,
    FOREIGN KEY (upload_by) REFERENCES member(id) ON DELETE CASCADE,
    INDEX idx_activity_id (activity_id),
    INDEX idx_upload_by (upload_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动附件表';

-- 9. 创建导出历史表
CREATE TABLE IF NOT EXISTS export_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '导出记录ID',
    export_type ENUM('dept', 'member', 'activity', 'message') NOT NULL COMMENT '导出类型',
    export_format ENUM('excel', 'pdf') NOT NULL COMMENT '导出格式',
    file_name VARCHAR(255) NOT NULL COMMENT '文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小',
    status INT DEFAULT 0 COMMENT '状态：0-处理中，1-已完成，2-失败',
    create_by BIGINT NOT NULL COMMENT '创建人',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    FOREIGN KEY (create_by) REFERENCES member(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='导出历史表';

-- 10. 创建操作日志表
CREATE TABLE IF NOT EXISTS operation_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    operator VARCHAR(100) NOT NULL COMMENT '操作人',
    operation VARCHAR(200) NOT NULL COMMENT '操作内容',
    method VARCHAR(100) COMMENT '操作方法',
    params TEXT COMMENT '请求参数',
    ip VARCHAR(50) COMMENT 'IP地址',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';
