<template>
  <div class="login-page">
    <el-card class="login-card">
      <div class="club-info" v-if="clubInfo">
        <h3>{{ clubInfo.name }}</h3>
        <a @click="changeClub" class="change-club-link">切换社团</a>
      </div>

      <h2 class="title">社团管理系统</h2>
      <el-form :model="form" @submit.native.prevent="onSubmit">
        <el-form-item label="学号/工号">
          <el-input v-model="form.stuId" autocomplete="username" />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="form.password" type="password" autocomplete="current-password" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="onSubmit" style="width: 100%;">登录</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
export default {
  data() {
    return {
      form: { stuId: '', password: '' },
      loading: false
    };
  },
  computed: {
    clubInfo() {
      return this.$store.state.clubInfo;
    }
  },
  mounted() {
    // 如果没有选择社团,跳转到社团选择页
    if (!this.$store.state.clubId) {
      this.$router.replace('/club-select');
    }
  },
  methods: {
    changeClub() {
      this.$store.dispatch('clearClub');
      this.$router.replace('/club-select');
    },
    async onSubmit() {
      if (this.loading) return;

      if (!this.form.stuId || !this.form.password) {
        this.$message.warning('请输入学号和密码');
        return;
      }

      this.loading = true;
      try {
        await this.$store.dispatch('doLogin', {
          ...this.form,
          clubId: this.$store.state.clubId
        });
        this.$router.replace('/dashboard');
      } catch (e) {
        this.$message.error(e.message || '登录失败');
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--theme-bg, #def0f9);
}

.login-card {
  width: 400px;
  max-width: 90%;

  .club-info {
    text-align: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #eee;

    h3 {
      margin: 0 0 10px;
      color: #4167b1;
      font-size: 16px;
      font-weight: 600;
    }

    .change-club-link {
      color: #409eff;
      font-size: 14px;
      cursor: pointer;
      text-decoration: none;
      transition: color 0.3s;

      &:hover {
        color: #66b1ff;
        text-decoration: underline;
      }
    }
  }

  .title {
    text-align: center;
    color: #4167b1;
    margin-bottom: 30px;
    font-size: 24px;
    font-weight: 600;
  }
}
</style>
