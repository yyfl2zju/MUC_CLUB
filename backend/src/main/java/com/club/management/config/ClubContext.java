package com.club.management.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 社团上下文 - 使用ThreadLocal存储当前线程的社团ID
 */
public class ClubContext {

    private static final Logger logger = LoggerFactory.getLogger(ClubContext.class);

    private static final ThreadLocal<Long> clubIdHolder = new ThreadLocal<>();

    /**
     * 设置当前社团ID
     */
    public static void setClubId(Long clubId) {
        logger.debug("设置社团上下文: clubId = {}", clubId);
        clubIdHolder.set(clubId);
    }

    /**
     * 获取当前社团ID
     */
    public static Long getClubId() {
        Long clubId = clubIdHolder.get();
        logger.debug("获取社团上下文: clubId = {}", clubId);
        return clubId;
    }

    /**
     * 清除当前社团ID
     */
    public static void clear() {
        Long clubId = clubIdHolder.get();
        logger.debug("清除社团上下文: clubId = {}", clubId);
        clubIdHolder.remove();
    }

    /**
     * 判断是否已设置社团ID
     */
    public static boolean hasClubId() {
        return clubIdHolder.get() != null;
    }
}
