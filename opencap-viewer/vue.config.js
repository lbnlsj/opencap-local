module.exports = {
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
