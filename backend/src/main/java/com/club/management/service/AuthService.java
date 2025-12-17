package com.club.management.service;

import com.club.management.entity.SysUser;
import com.club.management.entity.Member;
import com.club.management.mapper.SysUserMapper;
import com.club.management.mapper.MemberMapper;
import com.club.management.common.JwtUtil;
import com.club.management.common.Result;
import com.club.management.common.ErrorCode;
import com.club.management.config.ClubContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 认证服务
 */
@Service
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private MemberMapper memberMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    /**
     * 用户登录（支持多社团）
     * @param stuId 学号/工号
     * @param password 密码
     * @param clubId 社团ID
     */
    public Result<Map<String, Object>> login(String stuId, String password, Long clubId) {
        logger.info("用户登录: stuId={}, clubId={}", stuId, clubId);

        // 设置社团上下文用于数据源切换
        ClubContext.setClubId(clubId);

        try {
            // 首先尝试从member表查询
            Member member = memberMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<Member>()
                    .eq("stu_id", stuId)
            );

            if (member != null) {
                // 验证密码
                if (member.getPassword() != null && passwordEncoder.matches(password, member.getPassword())) {
                    // 生成包含clubId的JWT token
                    String token = jwtUtil.generateToken(member.getId(), member.getName(), member.getRole(), clubId);

                    Map<String, Object> result = new HashMap<>();
                    result.put("token", token);
                    result.put("user", member);
                    result.put("clubId", clubId);

                    logger.info("用户登录成功: stuId={}, clubId={}", stuId, clubId);
                    return Result.success("登录成功", result);
                } else {
                    logger.warn("密码错误: stuId={}", stuId);
                    return Result.businessError(ErrorCode.UNAUTHORIZED, "密码错误");
                }
            }

            // 如果member表中没有，尝试从sys_user表查询（兼容系统管理员）
            SysUser user = sysUserMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SysUser>()
                    .eq("stu_id", stuId)
            );

            if (user == null) {
                logger.warn("用户不存在: stuId={}", stuId);
                return Result.businessError(ErrorCode.UNAUTHORIZED, "用户不存在");
            }

            // 检查用户状态
            if (user.getStatus() == 0) {
                logger.warn("用户已被禁用: stuId={}", stuId);
                return Result.businessError(ErrorCode.UNAUTHORIZED, "用户已被禁用");
            }

            // 检查是否被锁定；若锁定已过期则重置失败计数（符合 SDS）
            if (user.getLockTime() != null) {
                if (user.getLockTime().isAfter(LocalDateTime.now())) {
                    logger.warn("账户已被锁定: stuId={}", stuId);
                    return Result.businessError(ErrorCode.UNAUTHORIZED, "账户已被锁定，请稍后再试");
                } else {
                    // 锁定期结束，重置计数与锁定时间
                    user.setLoginAttempts(0);
                    user.setLockTime(null);
                    sysUserMapper.updateById(user);
                }
            }

            // 验证密码
            if (!passwordEncoder.matches(password, user.getPassword())) {
                // 增加登录失败次数
                Integer attempts = user.getLoginAttempts() == null ? 0 : user.getLoginAttempts();
                user.setLoginAttempts(attempts + 1);
                if (user.getLoginAttempts() >= 5) {
                    user.setLockTime(LocalDateTime.now().plusMinutes(30));
                }
                sysUserMapper.updateById(user);
                logger.warn("密码错误: stuId={}", stuId);
                return Result.businessError(ErrorCode.UNAUTHORIZED, "密码错误");
            }

            // 登录成功，重置失败次数和锁定时间
            user.setLoginAttempts(0);
            user.setLockTime(null);
            sysUserMapper.updateById(user);

            // 生成包含clubId的JWT token
            String token = jwtUtil.generateToken(user.getId(), user.getName(), user.getRole(), clubId);

            Map<String, Object> result = new HashMap<>();
            result.put("token", token);
            result.put("user", user);
            result.put("clubId", clubId);

            logger.info("管理员登录成功: stuId={}, clubId={}", stuId, clubId);
            return Result.success("登录成功", result);
        } finally {
            // 清除社团上下文
            ClubContext.clear();
        }
    }

    /**
     * 用户登录（兼容旧版本，使用默认clubId=6）
     * @deprecated 请使用包含clubId参数的方法
     */
    @Deprecated
    public Result<Map<String, Object>> login(String stuId, String password) {
        return login(stuId, password, 6L);  // 默认使用数智实创社
    }

    /**
     * 验证token
     */
    public Result<Object> validateToken(String token) {
        try {
            Long userId = jwtUtil.getUserIdFromToken(token);
            String username = jwtUtil.getUsernameFromToken(token);
            if (userId == null || username == null) {
                return Result.businessError(ErrorCode.UNAUTHORIZED, "Token无效");
            }

            // 首先尝试从member表查询（使用userId）
            Member member = memberMapper.selectById(userId);
            if (member != null) {
                return Result.success(member);
            }

            // 如果member表中没有，尝试从sys_user表查询（兼容系统管理员）
            SysUser user = sysUserMapper.selectById(userId);
            if (user == null || user.getStatus() == 0) {
                return Result.businessError(ErrorCode.UNAUTHORIZED, "用户不存在或已被禁用");
            }

            return Result.success(user);
        } catch (Exception e) {
            e.printStackTrace(); // 添加调试信息
            return Result.businessError(ErrorCode.UNAUTHORIZED, "Token验证失败: " + e.getMessage());
        }
    }

    /**
     * 仅用于开发联调：通过 stuId 直接颁发 JWT，便于前端/接口测试
     */
    public Result<Map<String, Object>> issueTokenForStuId(String stuId) {
        SysUser user = sysUserMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SysUser>()
                        .eq("stu_id", stuId)
        );
        if (user == null || user.getStatus() == 0) {
            return Result.businessError(ErrorCode.UNAUTHORIZED, "用户不存在或已被禁用");
        }
        String token = jwtUtil.generateToken(user.getId(), user.getName(), user.getRole());
        Map<String, Object> result = new HashMap<>();
        result.put("token", token);
        result.put("user", user);
        return Result.success("OK", result);
    }
}
