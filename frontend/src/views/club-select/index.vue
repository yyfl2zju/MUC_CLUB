<template>
  <div class="club-select-page">
    <!-- 背景装饰 -->
    <div class="bg-decoration">
      <div class="circle circle-1"></div>
      <div class="circle circle-2"></div>
      <div class="circle circle-3"></div>
    </div>

    <div class="container">
      <div class="header">
        <div class="logo-section">
          <div class="main-logo">
            <span class="logo-icon">CM</span>
          </div>
          <h1 class="title">社团管理系统</h1>
        </div>
        <h2 class="subtitle">选择您的社团</h2>
        <el-input
          v-model="searchText"
          placeholder="搜索社团名称"
          prefix-icon="el-icon-search"
          clearable
          class="search-input"
        />
      </div>

      <div v-loading="loading" class="club-grid" element-loading-background="rgba(0, 0, 0, 0.1)">
        <el-card
          v-for="club in filteredClubs"
          :key="club.id"
          class="club-card"
          :body-style="{ padding: '32px 24px' }"
          shadow="hover"
          @click.native="selectClub(club)"
        >
          <div class="club-logo">
            <img v-if="club.logoUrl" :src="club.logoUrl" :alt="club.name" />
            <div v-else class="club-logo-placeholder" :style="{ background: club.themeColor || getRandomGradient() }">
              {{ club.name.substring(0, 2) }}
            </div>
          </div>
          <h3 class="club-name">{{ club.name }}</h3>
          <p class="club-desc">{{ club.description || '暂无简介' }}</p>
          <div class="club-action">
            <span class="action-text">点击进入</span>
            <i class="el-icon-arrow-right"></i>
          </div>
        </el-card>

        <el-empty 
          v-if="!loading && filteredClubs.length === 0" 
          description="未找到匹配的社团"
          :image-size="120"
        ></el-empty>
      </div>
    </div>
  </div>
</template>

<script>
import { getClubList } from '@/utils/api';

export default {
  name: 'ClubSelect',
  data() {
    return {
      clubs: [],
      searchText: '',
      loading: false,
      gradients: [
        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
        'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
        'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
        'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
        'linear-gradient(135deg, #30cfd0 0%, #330867 100%)',
        'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
        'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
        'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
        'linear-gradient(135deg, #ff6e7f 0%, #bfe9ff 100%)',
        'linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%)',
        'linear-gradient(135deg, #f77062 0%, #fe5196 100%)'
      ]
    };
  },
  computed: {
    filteredClubs() {
      if (!this.searchText) return this.clubs;
      return this.clubs.filter(club =>
        club.name.toLowerCase().includes(this.searchText.toLowerCase())
      );
    }
  },
  async mounted() {
    await this.loadClubs();
  },
  methods: {
    async loadClubs() {
      this.loading = true;
      try {
        const res = await getClubList();
        if (res.code === 200) {
          this.clubs = res.data || [];
        } else {
          this.$message.error(res.message || '加载社团列表失败');
        }
      } catch (e) {
        this.$message.error('加载社团列表失败');
        console.error('加载社团列表失败:', e);
      } finally {
        this.loading = false;
      }
    },
    async selectClub(club) {
      try {
        await this.$store.dispatch('selectClub', club.id);
        this.$router.push('/login');
      } catch (e) {
        this.$message.error('选择社团失败');
        console.error('选择社团失败:', e);
      }
    },
    getRandomGradient() {
      return this.gradients[Math.floor(Math.random() * this.gradients.length)];
    }
  }
};
</script>

<style lang="scss" scoped>
.club-select-page {
  position: relative;
  min-height: 100vh;
  padding: 60px 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  overflow: hidden;

  // 背景装饰
  .bg-decoration {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    pointer-events: none;

    .circle {
      position: absolute;
      border-radius: 50%;
      background: rgba(102, 126, 234, 0.08);
      animation: float 20s infinite ease-in-out;

      &.circle-1 {
        width: 300px;
        height: 300px;
        top: -100px;
        right: -100px;
        animation-delay: 0s;
      }

      &.circle-2 {
        width: 200px;
        height: 200px;
        bottom: 100px;
        left: -50px;
        animation-delay: 5s;
      }

      &.circle-3 {
        width: 150px;
        height: 150px;
        top: 50%;
        right: 10%;
        animation-delay: 10s;
      }
    }
  }

  @keyframes float {
    0%, 100% {
      transform: translateY(0) scale(1);
      opacity: 0.3;
    }
    50% {
      transform: translateY(-30px) scale(1.1);
      opacity: 0.6;
    }
  }

  .container {
    position: relative;
    z-index: 1;
    max-width: 1400px;
    margin: 0 auto;
  }

  .header {
    text-align: center;
    margin-bottom: 60px;
    animation: fadeInDown 0.8s ease-out;

    .logo-section {
      margin-bottom: 30px;

      .main-logo {
        display: inline-block;
        width: 80px;
        height: 80px;
        margin-bottom: 20px;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 20px;
        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
        display: flex;
        align-items: center;
        justify-content: center;
        animation: pulse 2s infinite;

        .logo-icon {
          font-size: 36px;
          font-weight: bold;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
        }
      }

      .title {
        margin: 0;
        color: #2c3e50;
        font-size: 42px;
        font-weight: 700;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        letter-spacing: 2px;
      }
    }

    .subtitle {
      margin: 0 0 30px;
      color: #34495e;
      font-size: 28px;
      font-weight: 500;
    }

    .search-input {
      max-width: 500px;
      margin: 0 auto;

      ::v-deep .el-input__inner {
        height: 50px;
        line-height: 50px;
        border-radius: 25px;
        border: none;
        background: rgba(255, 255, 255, 0.95);
        font-size: 16px;
        padding-left: 50px;
        box-shadow: 0 5px 25px rgba(0, 0, 0, 0.15);
        transition: all 0.3s;

        &:focus {
          box-shadow: 0 8px 35px rgba(0, 0, 0, 0.25);
        }
      }

      ::v-deep .el-input__prefix {
        left: 20px;
        font-size: 18px;
      }
    }
  }

  @keyframes fadeInDown {
    from {
      opacity: 0;
      transform: translateY(-30px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes pulse {
    0%, 100% {
      transform: scale(1);
    }
    50% {
      transform: scale(1.05);
    }
  }

  .club-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 30px;
    animation: fadeInUp 0.8s ease-out 0.3s both;

    @media (max-width: 1200px) {
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 25px;
    }

    @media (max-width: 768px) {
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 20px;
    }

    @media (max-width: 576px) {
      grid-template-columns: 1fr;
    }
  }

  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(30px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .club-card {
    cursor: pointer;
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    border-radius: 16px;
    border: none;
    background: rgba(255, 255, 255, 0.98);
    overflow: hidden;
    position: relative;

    &::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 4px;
      background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
      transform: scaleX(0);
      transition: transform 0.3s;
    }

    &:hover {
      transform: translateY(-10px);
      box-shadow: 0 15px 40px rgba(0, 0, 0, 0.25);

      &::before {
        transform: scaleX(1);
      }

      .club-logo-placeholder {
        transform: scale(1.1) rotate(5deg);
      }

      .club-action {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .club-logo {
      width: 100px;
      height: 100px;
      margin: 0 auto 20px;
      border-radius: 50%;
      overflow: hidden;
      box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }

      &-placeholder {
        width: 100%;
        height: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        font-size: 36px;
        font-weight: bold;
        transition: all 0.3s;
        text-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
      }
    }

    .club-name {
      text-align: center;
      margin: 0 0 12px;
      font-size: 20px;
      color: #2c3e50;
      font-weight: 600;
      letter-spacing: 0.5px;
    }

    .club-desc {
      text-align: center;
      margin: 0 0 20px;
      font-size: 14px;
      color: #7f8c8d;
      line-height: 1.6;
      min-height: 66px;
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
    }

    .club-action {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding-top: 15px;
      border-top: 1px solid #ecf0f1;
      color: #667eea;
      font-size: 15px;
      font-weight: 500;
      opacity: 0;
      transform: translateY(-10px);
      transition: all 0.3s;

      i {
        font-size: 16px;
        transition: transform 0.3s;
      }
    }

    &:hover .club-action i {
      transform: translateX(5px);
    }
  }

  ::v-deep .el-empty {
    padding: 60px 0;

    .el-empty__description p {
      color: #7f8c8d;
      font-size: 16px;
    }
  }
}
</style>
