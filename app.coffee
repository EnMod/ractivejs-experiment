axis              = require 'axis'
rupture           = require 'rupture'
typographic       = require 'typographic'
dynamic_content   = require 'dynamic-content'
autoprefixer      = require 'autoprefixer-stylus'
lost              = require 'lost'

module.exports =
  ignores: ['readme.md', '**/_*', '.gitignore', 'ship.*conf']

  extensions: [
    js_pipeline(files: ['bower_components/handlebars/handlebars.js', 'bower_components/jquery/dist/jquery.js'], out: 'js/reqs.js', minify: true, hash: false)

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