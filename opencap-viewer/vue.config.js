module.exports = {
    devServer: {
        proxy: {
            '/media': {
                target: 'http://localhost:8000',
                changeOrigin: true
            },
            '^/api': {
                target: 'http://127.0.0.1:8000',
                changeOrigin: true,
                withCredentials: true,  // 添加这一行来保留 cookie
                cookieDomainRewrite: 'localhost', // 重写cookie域名
                cookiePathRewrite: '/',  // 重写cookie路径
                pathRewrite: {
                    '^/api': ''
                },
                headers: {
                    'asd':'xcz',
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET,PUT,POST,DELETE,PATCH,OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
                    'Access-Control-Allow-Credentials': 'true'  // 允许携带凭证
                }
            }
        }
    },
    chainWebpack: config => {
        config.module
            .rule('vue')
            .use('vue-loader')
            .tap(options => {
                options.compiler = require('vue-template-babel-compiler')
                return options
            }),
            config
                .plugin('html')
                .tap(args => {
                    args[0].title = "BioFlex" // 在这里修改你的网站标题
                    return args
                })
    }
}
