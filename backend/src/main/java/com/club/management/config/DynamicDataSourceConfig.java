package com.club.management.config;

import com.club.management.entity.Club;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * 动态数据源配置
 */
@Configuration
public class DynamicDataSourceConfig {

    private static final Logger logger = LoggerFactory.getLogger(DynamicDataSourceConfig.class);

    @Value("${spring.datasource.master.url}")
    private String masterUrl;

    @Value("${spring.datasource.master.username}")
    private String masterUsername;

    @Value("${spring.datasource.master.password}")
    private String masterPassword;

    @Value("${spring.datasource.club.url-prefix}")
    private String clubUrlPrefix;

    @Value("${spring.datasource.club.url-suffix}")
    private String clubUrlSuffix;

    @Value("${spring.datasource.club.username}")
    private String clubUsername;

    @Value("${spring.datasource.club.password}")
    private String clubPassword;

    /**
     * 创建主数据源 (用于访问 club_master)
     */
    private DataSource createMasterDataSource() {
        logger.info("创建主数据源: {}", masterUrl);

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(masterUrl);
        config.setUsername(masterUsername);
        config.setPassword(masterPassword);
        config.setDriverClassName("com.mysql.cj.jdbc.Driver");

        // 连接池配置
        config.setMinimumIdle(5);
        config.setMaximumPoolSize(20);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        config.setPoolName("MasterPool");

        return new HikariDataSource(config);
    }

    /**
     * 创建社团数据源
     */
    private DataSource createClubDataSource(Club club) {
        String url = clubUrlPrefix + club.getDbName() + clubUrlSuffix;
        logger.info("创建社团数据源: {} - {}", club.getName(), url);

        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(url);
        config.setUsername(clubUsername);
        config.setPassword(clubPassword);
        config.setDriverClassName("com.mysql.cj.jdbc.Driver");

        // 连接池配置 (社团数据源使用较小的连接池)
        config.setMinimumIdle(3);
        config.setMaximumPoolSize(10);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        config.setPoolName("ClubPool-" + club.getId());

        return new HikariDataSource(config);
    }

    /**
     * 从主数据库加载所有社团配置
     */
    private Map<Long, Club> loadClubsFromMaster() {
        Map<Long, Club> clubs = new HashMap<>();
        DataSource masterDataSource = createMasterDataSource();

        try (Connection conn = masterDataSource.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT * FROM clubs WHERE status = 1");
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Club club = new Club();
                club.setId(rs.getLong("id"));
                club.setName(rs.getString("name"));
                club.setCode(rs.getString("code"));
                club.setDbName(rs.getString("db_name"));
                club.setStatus(rs.getInt("status"));

                clubs.put(club.getId(), club);
                logger.info("加载社团配置: {} - {}", club.getId(), club.getName());
            }

            logger.info("成功加载 {} 个社团配置", clubs.size());

        } catch (Exception e) {
            logger.error("加载社团配置失败", e);
            throw new RuntimeException("加载社团配置失败", e);
        }

        return clubs;
    }

    /**
     * 配置动态数据源
     */
    @Bean
    @Primary
    public DataSource dynamicDataSource() {
        logger.info("初始化动态数据源...");

        // 1. 加载所有社团配置
        Map<Long, Club> clubs = loadClubsFromMaster();

        // 2. 创建目标数据源Map，并先放入master
        Map<Object, Object> targetDataSources = new HashMap<>();
        DataSource masterDataSource = createMasterDataSource();
        targetDataSources.put("master", masterDataSource);

        // 3. 为每个社团创建数据源
        for (Club club : clubs.values()) {
            try {
                DataSource dataSource = createClubDataSource(club);
                targetDataSources.put(club.getId(), dataSource);
                logger.info("社团数据源创建成功: {} - {}", club.getId(), club.getName());
            } catch (Exception e) {
                logger.error("创建社团数据源失败: {} - {}", club.getId(), club.getName(), e);
            }
        }

        // 4. 设置默认数据源为 master（主库存放 clubs 表）
        DataSource defaultDataSource = masterDataSource;

        // 5. 配置动态数据源
        DynamicDataSource dynamicDataSource = new DynamicDataSource();
        dynamicDataSource.setTargetDataSources(targetDataSources);
        dynamicDataSource.setDefaultTargetDataSource(defaultDataSource);

        logger.info("动态数据源初始化完成，共 {} 个数据源", targetDataSources.size());

        return dynamicDataSource;
    }
}
