module.exports = {
    devServer: {
        proxy: {
            '/media': {
                target: 'http://localhost:8000',
                changeOrigin: true
            },
            '/api': {
                target: 'http://localhost:8000',
                changeOrigin: false,
                secure: false,
                pathRewrite: {
                    '^/api': ''
                },
                // 添加以下配置
                withCredentials: true,
                cookieDomainRewrite: 'localhost'
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
