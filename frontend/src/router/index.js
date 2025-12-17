import Vue from 'vue';
import Router from 'vue-router';
import store from '@/store';

Vue.use(Router);

const ClubSelect = () => import('@/views/club-select/index.vue');
const Login = () => import('@/views/login/index.vue');
const Dashboard = () => import('@/views/dashboard/index.vue');
const Dept = () => import('@/views/dept/index.vue');
const DeptDetail = () => import('@/views/dept/detail.vue');
const Member = () => import('@/views/member/index.vue');
const MemberDetail = () => import('@/views/member/detail.vue');
const Activity = () => import('@/views/activity/index.vue');
const ActivityDetail = () => import('@/views/activity/detail.vue');
const ActivityEdit = () => import('@/views/activity/edit.vue');
const Profile = () => import('@/views/profile/index.vue');
const Export = () => import('@/views/export/index.vue');

const router = new Router({
  mode: 'hash',
  routes: [
    { path: '/club-select', name: 'ClubSelect', component: ClubSelect },
    { path: '/login', name: 'Login', component: Login },
    { path: '/', redirect: '/dashboard' },
    { path: '/dashboard', name: 'Dashboard', component: Dashboard },
    { path: '/dept', name: 'Dept', component: Dept },
    { path: '/dept/:id', name: 'DeptDetail', component: DeptDetail },
    { path: '/member', name: 'Member', component: Member },
    { path: '/member/:id', name: 'MemberDetail', component: MemberDetail },
    { path: '/activity', name: 'Activity', component: Activity },
    { path: '/activity/:id', name: 'ActivityDetail', component: ActivityDetail },
    { path: '/activity/:id/edit', name: 'ActivityEdit', component: ActivityEdit },
    { path: '/profile', name: 'Profile', component: Profile },
    { path: '/export', name: 'Export', component: Export }
  ]
});

router.beforeEach(async (to, from, next) => {
  // 社团选择页直接放行
  if (to.path === '/club-select') {
    return next();
  }

  // 登录页检查是否选择了社团
  if (to.path === '/login') {
    const clubId = store.state.clubId;
    if (!clubId) {
      next('/club-select');
      return;
    }
    return next();
  }

  // 其他页面需要完整验证
  const clubId = store.state.clubId;
  const token = store.state.token;

  if (!clubId) {
    next('/club-select');
    return;
  }

  if (!token) {
    next('/login');
    return;
  }

  // 验证token有效性
  const isValid = await store.dispatch('validate');
  if (!isValid) {
    // token失效,清除社团信息,重新选择
    store.dispatch('clearClub');
    store.dispatch('logout');
    next('/club-select');
    return;
  }

  next();
});

export default router;
