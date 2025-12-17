package com.club.management.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.club.management.entity.Club;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 社团 Mapper 接口
 */
@Mapper
public interface ClubMapper extends BaseMapper<Club> {

    /**
     * 查询所有启用的社团
     */
    @Select("SELECT * FROM clubs WHERE status = 1 ORDER BY id")
    List<Club> selectActiveClubs();

    /**
     * 根据社团代码查询社团
     */
    @Select("SELECT * FROM clubs WHERE code = #{code} LIMIT 1")
    Club selectByCode(String code);

    /**
     * 根据数据库名称查询社团
     */
    @Select("SELECT * FROM clubs WHERE db_name = #{dbName} LIMIT 1")
    Club selectByDbName(String dbName);
}
