package com.club.management.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;

/**
 * 动态数据源 - 根据社团ID动态切换数据源
 */
public class DynamicDataSource extends AbstractRoutingDataSource {

    private static final Logger logger = LoggerFactory.getLogger(DynamicDataSource.class);

    /**
     * 默认社团ID (数智实创社)
     */
    private static final String MASTER_KEY = "master";

    /**
     * 确定当前数据源的key
     * 返回值对应配置的targetDataSources中的key
     */
    @Override
    protected Object determineCurrentLookupKey() {
        Long clubId = ClubContext.getClubId();

        // 如果没有设置clubId,使用master（主库存放 clubs 表）
        if (clubId == null) {
            logger.debug("未设置社团ID,使用master数据源");
            return MASTER_KEY;
        }

        logger.debug("当前数据源key: clubId = {}", clubId);
        return clubId;
    }
}
