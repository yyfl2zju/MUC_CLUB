-- =====================================================
-- 社团管理系统 - 主数据库初始化脚本
-- 数据库名: mucclub
-- 作用:
-- 1. 创建主数据库与 clubs 元数据表
-- 2. 初始化 42 个社团元数据（幂等更新）
-- =====================================================

CREATE DATABASE IF NOT EXISTS mucclub
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE mucclub;

CREATE TABLE IF NOT EXISTS clubs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '社团ID',
  name VARCHAR(100) NOT NULL UNIQUE COMMENT '社团名称',
  code VARCHAR(50) NOT NULL UNIQUE COMMENT '社团代码',
  db_name VARCHAR(100) NOT NULL UNIQUE COMMENT '社团数据库名',
  logo_url VARCHAR(500) DEFAULT NULL COMMENT '社团Logo URL',
  description TEXT COMMENT '社团简介',
  contact_person VARCHAR(50) DEFAULT NULL COMMENT '联系人',
  contact_phone VARCHAR(20) DEFAULT NULL COMMENT '联系电话',
  contact_email VARCHAR(100) DEFAULT NULL COMMENT '联系邮箱',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用,1-启用',
  theme_color VARCHAR(20) NOT NULL DEFAULT '#4167b1' COMMENT '主题色',
  create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  KEY idx_status (status),
  KEY idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社团主数据表';

INSERT INTO clubs (id, name, code, db_name, status, theme_color, description, contact_person) VALUES
  (1, '力型兼备健身社', 'lxjb', 'club_lxjb', 1, '#00B894', '健身运动与体能训练', '刘昊炜'),
  (2, '励行研习社', 'lxyx', 'club_lxyx', 1, '#A29BFE', '学术研究与思想交流', '杨杰'),
  (3, '56街舞社', '56jws', 'club_56jws', 1, '#FDCB6E', '街舞文化与舞蹈艺术', '周雪青'),
  (4, 'KAB创业俱乐部', 'kab', 'club_kab', 1, '#4ECDC4', '致力于培养大学生的创业意识和创业能力', '万泳仪'),
  (5, 'MUC模拟政协社团', 'muc', 'club_muc', 1, '#E17055', '政治协商与议事能力培养', NULL),
  (6, '计算机协会', 'jsjxh', 'club_jsjxh', 1, '#5F27CD', '计算机技术学习与交流社团', '段振昌'),
  (7, '光影·捕梦摄影协会', 'gybmsy', 'club_gybmsy', 1, '#6C5CE7', '摄影技术与艺术创作', '杜天翔'),
  (8, '迹无疆自行车协会', 'jwjzxc', 'club_jwjzxc', 1, '#00CEC9', '自行车骑行与户外运动', '陈崟灿'),
  (9, '惊鸿传统文化活动社', 'jhctwh', 'club_jhctwh', 1, '#FD79A8', '传统文化传承与推广', '刘雨诺'),
  (10, '棋魂社', 'qhs', 'club_qhs', 1, '#2D3436', '围棋、象棋等棋类文化', '黄子誉'),
  (11, '青年就业创业指导服务中心', 'qnjycyzdfwzx', 'club_qnjycyzdfwzx', 1, '#FF6B6B', '为青年提供就业创业指导和服务', '苟红燕'),
  (12, '青年书画社团', 'qnsh', 'club_qnsh', 1, '#2D3436', '书法绘画艺术交流', '赵艺泽'),
  (13, '青年足球协会', 'qnzq', 'club_qnzq', 1, '#55EFC4', '足球运动与团队协作', '阿布都合力力·库尔班'),
  (14, '儒行社', 'ruxingshe', 'club_ruxingshe', 1, '#8B4513', '儒家文化传承与弘扬', '刘思航'),
  (15, '塞上未来社团', 'sswl', 'club_sswl', 1, '#00B894', '探索未来发展与创新', NULL),
  (16, '山樱日语学习与中日文化交流社', 'syryjl', 'club_syryjl', 1, '#FD79A8', '日语学习与中日文化交流', '刘紫蕴'),
  (17, '数智实创社', 'szsc', 'club_szsc', 1, '#4167b1', '数字技术与智能创新实践社团', '林晓彤'),
  (18, '太极拳协会', 'tjq', 'club_tjq', 1, '#FAB1A0', '太极拳运动推广', '尚玲伊'),
  (19, '藤毽球协会', 'tjqs', 'club_tjqs', 1, '#FFA07A', '藤毽球运动推广', '周嘉威'),
  (20, '网动青春社团', 'wdqc', 'club_wdqc', 1, '#0984E3', '网球运动与体育精神', '葛宇帆'),
  (21, '校友工作协会', 'xygz', 'club_xygz', 1, '#00CEC9', '校友联络与服务', '董瑞'),
  (22, '星耀拉丁舞社', 'xyldw', 'club_xyldw', 1, '#FD79A8', '拉丁舞艺术与表演', '朱耘春'),
  (23, '虚幻引擎研习社', 'xhyqyx', 'club_xhyqyx', 1, '#A29BFE', '虚幻引擎技术学习与应用', '杜靖洋'),
  (24, '雅乐轩相声社', 'ylxxs', 'club_ylxxs', 1, '#FDCB6E', '相声曲艺与传统艺术', '李家齐'),
  (25, '音悦吉他协会', 'yyjt', 'club_yyjt', 1, '#6C5CE7', '吉他音乐与演奏技巧', '董欣怡'),
  (26, '友谊乒乓球社', 'yypqq', 'club_yypqq', 1, '#E84393', '乒乓球运动与技术', '黄宇龙'),
  (27, '与共辩论社', 'ygbl', 'club_ygbl', 1, '#74B9FF', '辩论技巧与思辨能力', '雷祚昆'),
  (28, '中医文化社', 'zywh', 'club_zywh', 1, '#00B894', '中医文化与养生知识', '叶思凤'),
  (29, '自立自强社', 'zlzq', 'club_zlzq', 1, '#FDCB6E', '培养自立自强精神', '徐雨菲'),
  (30, 'SECA大学生英语交流协会', 'seca', 'club_seca', 1, '#45B7D1', '提供英语学习和交流平台', '吴雨轩'),
  (31, '铁煞拳武道社', 'tsqwd', 'club_tsqwd', 1, '#E17055', '武术与防身技能', '杜梦瑶'),
  (32, '青年羽球社', 'qnyq', 'club_qnyq', 1, '#74B9FF', '羽毛球运动与竞技', '黄昱元'),
  (33, '文物与博物馆学会', 'wwybwg', 'club_wwybwg', 1, '#636E72', '文物保护与博物馆学', '赵雯淼'),
  (34, '西部实践社', 'xbsj', 'club_xbsj', 1, '#DFE6E9', '社会实践与志愿服务', NULL),
  (35, '爱幕有戏音乐剧社', 'amyxyjjs', 'club_amyxyjjs', 1, '#FF69B4', '音乐剧表演与创作', '魏世娇'),
  (36, '跃无止境排球协会', 'ywzjpq', 'club_ywzjpq', 1, '#FF7675', '排球运动与竞技精神', '陈其然'),
  (37, '逐梦匹克球社', 'zmpkqs', 'club_zmpkqs', 1, '#32CD32', '匹克球运动推广', '张佳伟'),
  (38, '青春跑步协会', 'qcpbxh', 'club_qcpbxh', 1, '#FF8C00', '跑步运动与健康生活', '赵小龙'),
  (39, '合寰飞盘社', 'hhfps', 'club_hhfps', 1, '#87CEEB', '飞盘运动与团队协作', '马丞秀'),
  (40, '创客启航社', 'ckqhs', 'club_ckqhs', 1, '#9370DB', '创客精神与科技创新', '杨航行'),
  (41, '学生科创成长协会', 'xskccz', 'club_xskccz', 1, '#4169E1', '科技创新与学术成长', '陈佳宜'),
  (42, '遗脉相传手工艺社', 'ymxcsgys', 'club_ymxcsgys', 1, '#D2691E', '传统手工艺传承与创新', '胡赵玥')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  code = VALUES(code),
  db_name = VALUES(db_name),
  status = VALUES(status),
  theme_color = VALUES(theme_color),
  description = VALUES(description),
  contact_person = VALUES(contact_person);

SELECT 'mucclub 初始化完成，clubs 表已同步 42 个社团。' AS message;
