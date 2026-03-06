module.exports = {
  // 部署应用包的基本URL
  publicPath: '/',
  
  // 生产环境构建文件的目录
  outputDir: 'dist',
  
  // 放置生成的静态资源的目录
  assetsDir: 'static',
  
  // 生产环境是否生成 sourceMap
  productionSourceMap: false,
  
  // 开发服务器配置
  devServer: {
    port: 5174,
    open: false,
    proxy: {
      '/api': {
        target: 'http://localhost:8081',
        changeOrigin: true,
        pathRewrite: {
          '^/api': '/api'
        }
      }
    }
  },
  
  // CSS相关配置
  css: {
    loaderOptions: {
      scss: {
        additionalData: "@import '~@/styles/element-variables.scss';"
      }
    }
  }
};
