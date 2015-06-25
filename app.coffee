axis              = require 'axis'
rupture           = require 'rupture'
typographic       = require 'typographic'
dynamic_content   = require 'dynamic-content'
autoprefixer      = require 'autoprefixer-stylus'
js_pipeline       = require 'js-pipeline'
lost              = require 'lost'

module.exports =
  ignores: ['readme.md', '**/_*', '.gitignore', '.gitattributes', 'ship.*conf', 'bower_components/**/*', 'bower.json']

  extensions: [
    js_pipeline(files: 'libs/**/*.js', out: 'js/reqs.js', minify: true, hash: false)

    dynamic_content()
  ]

  stylus:
    use: [axis(), rupture(), typographic(), autoprefixer()]
    sourcemap: true

  postcss:
    use: [lost()]

  jade:
    pretty: true

  server:
    clean_urls: true