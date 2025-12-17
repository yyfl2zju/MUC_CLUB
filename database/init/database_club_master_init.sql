-- =====================================================
-- 社团管理系统 - 主数据库初始化脚本
-- 数据库名: club_master
-- 说明: 存储所有社团的基本信息和全局配置
-- =====================================================

-- 创建主数据库
CREATE DATABASE IF NOT EXISTS club_master CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE club_master;

-- =====================================================
-- 创建社团表 (clubs)
-- =====================================================
CREATE TABLE IF NOT EXISTS clubs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '社团ID',
    name VARCHAR(100) NOT NULL UNIQUE COMMENT '社团名称',
    code VARCHAR(50) NOT NULL UNIQUE COMMENT '社团代码(用于数据库命名)',
    db_name VARCHAR(100) NOT NULL UNIQUE COMMENT '数据库名称',
    logo_url VARCHAR(500) COMMENT '社团Logo URL',
    description TEXT COMMENT '社团简介',
    contact_person VARCHAR(50) COMMENT '联系人',
    contact_phone VARCHAR(20) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    status TINYINT DEFAULT 1 COMMENT '状态: 0-禁用, 1-启用',
    theme_color VARCHAR(20) DEFAULT '#4167b1' COMMENT '主题颜色',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_status (status),
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社团表';

-- =====================================================
-- 插入34个社团的初始数据
-- =====================================================
INSERT INTO clubs (id, name, code, db_name, status, theme_color, description) VALUES
(1, '青年就业创业指导服务中心', 'qnjycyzdfwzx', 'club_qnjycyzdfwzx', 1, '#FF6B6B', '为青年提供就业创业指导和服务'),
(2, 'KAB创业俱乐部', 'kab', 'club_kab', 1, '#4ECDC4', '致力于培养大学生的创业意识和创业能力'),
(3, 'SECA大学生英语交流协会', 'seca', 'club_seca', 1, '#45B7D1', '提供英语学习和交流平台'),
(4, '计算机协会社团', 'jsjxh', 'club_jsjxh', 1, '#5F27CD', '计算机技术学习与交流社团'),
(5, '山樱日语学习与中日文化交流社', 'syryjl', 'club_syryjl', 1, '#FD79A8', '日语学习与中日文化交流'),
(6, '数智实创社', 'szsc', 'club_szsc', 1, '#4167b1', '数字技术与智能创新实践社团(默认社团)'),
(7, '虚幻引擎研习社', 'xhyqyx', 'club_xhyqyx', 1, '#A29BFE', '虚幻引擎技术学习与应用'),
(8, '"力型兼备"健身社', 'lxjb', 'club_lxjb', 1, '#00B894', '健身运动与体能训练'),
(9, '56街舞社', '56jws', 'club_56jws', 1, '#FDCB6E', '街舞文化与舞蹈艺术'),
(10, '光影·捕梦摄影协会', 'gybmsy', 'club_gybmsy', 1, '#6C5CE7', '摄影技术与艺术创作'),
(11, '迹无疆自行车协会', 'jwjzxc', 'club_jwjzxc', 1, '#00CEC9', '自行车骑行与户外运动'),
(12, '棋魂社', 'qhs', 'club_qhs', 1, '#2D3436', '围棋、象棋等棋类文化'),
(13, '青年羽球社团', 'qnyq', 'club_qnyq', 1, '#74B9FF', '羽毛球运动与竞技'),
(14, '青年足球协会', 'qnzq', 'club_qnzq', 1, '#55EFC4', '足球运动与团队协作'),
(15, '藤毽球协会', 'tjq', 'club_tjq', 1, '#FAB1A0', '藤毽球运动推广'),
(16, '铁煞拳武道社', 'tsqwd', 'club_tsqwd', 1, '#E17055', '武术与防身技能'),
(17, '网动青春', 'wdqc', 'club_wdqc', 1, '#0984E3', '网球运动与体育精神'),
(18, '星耀拉丁舞协会', 'xyldw', 'club_xyldw', 1, '#FD79A8', '拉丁舞艺术与表演'),
(19, '艺缘画社', 'yyhs', 'club_yyhs', 1, '#FDCB6E', '绘画艺术与创作交流'),
(20, '友谊乒乓球社', 'yypqq', 'club_yypqq', 1, '#E84393', '乒乓球运动与技术'),
(21, '音悦吉他协会', 'yyjt', 'club_yyjt', 1, '#6C5CE7', '吉他音乐与演奏技巧'),
(22, '跃无止境排球协会', 'ywzjpq', 'club_ywzjpq', 1, '#FF7675', '排球运动与竞技精神'),
(23, '塞上未来社团', 'sswl', 'club_sswl', 1, '#00B894', '探索未来发展与创新'),
(24, '西部实践社', 'xbsj', 'club_xbsj', 1, '#DFE6E9', '社会实践与志愿服务'),
(25, '校友工作协会', 'xygz', 'club_xygz', 1, '#00CEC9', '校友联络与服务'),
(26, '自立自强社', 'zlzq', 'club_zlzq', 1, '#FDCB6E', '培养自立自强精神'),
(27, '"励行"研习社', 'lxyx', 'club_lxyx', 1, '#A29BFE', '学术研究与思想交流'),
(28, 'MUC模拟政协社团', 'muc', 'club_muc', 1, '#E17055', '政治协商与议事能力培养'),
(29, '与共辩论社', 'ygbl', 'club_ygbl', 1, '#74B9FF', '辩论技巧与思辨能力'),
(30, '惊鸿传统文化活动', 'jhctwh', 'club_jhctwh', 1, '#FD79A8', '传统文化传承与推广'),
(31, '青年书画社团', 'qnsh', 'club_qnsh', 1, '#2D3436', '书法绘画艺术交流'),
(32, '文物与博物馆学会', 'wwybwg', 'club_wwybwg', 1, '#636E72', '文物保护与博物馆学'),
(33, '雅乐轩相声社', 'ylxxs', 'club_ylxxs', 1, '#FDCB6E', '相声曲艺与传统艺术'),
(34, '中医文化社', 'zywh', 'club_zywh', 1, '#00B894', '中医文化与养生知识');

-- =====================================================
-- 创建索引以提高查询性能
-- =====================================================
CREATE INDEX idx_clubs_status ON clubs(status);
CREATE INDEX idx_clubs_code ON clubs(code);
CREATE INDEX idx_clubs_name ON clubs(name);

-- =====================================================
-- 验证数据插入
-- =====================================================
SELECT COUNT(*) AS total_clubs,
       SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) AS active_clubs,
       SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) AS inactive_clubs
FROM clubs;

-- =====================================================
-- 显示所有社团列表
-- =====================================================
SELECT id, name, code, db_name, status, theme_color
FROM clubs
ORDER BY id;

-- =====================================================
-- 完成主数据库初始化
-- =====================================================
SELECT '主数据库 club_master 初始化完成！共创建 34 个社团记录。' AS message;
