package com.club.management.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 社团实体类
 */
@Data
@TableName("clubs")
public class Club {

    /**
     * 社团ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 社团名称
     */
    private String name;

    /**
     * 社团代码(用于数据库命名)
     */
    private String code;

    /**
     * 数据库名称
     */
    private String dbName;

    /**
     * 社团Logo URL
     */
    private String logoUrl;

    /**
     * 社团简介
     */
    private String description;

    /**
     * 联系人
     */
    private String contactPerson;

    /**
     * 联系电话
     */
    private String contactPhone;

    /**
     * 联系邮箱
     */
    private String contactEmail;

    /**
     * 状态: 0-禁用, 1-启用
     */
    private Integer status;

    /**
     * 主题颜色
     */
    private String themeColor;

    /**
     * 创建时间
     */
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    private LocalDateTime updateTime;
}
