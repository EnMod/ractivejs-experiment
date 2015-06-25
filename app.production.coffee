axis              = require 'axis'
rupture           = require 'rupture'
typographic       = require 'typographic'
dynamic_content   = require 'dynamic-content'
autoprefixer      = require 'autoprefixer-stylus'
js_pipeline       = require 'js-pipeline'
css_pipeline      = require 'css-pipeline'
lost              = require 'lost'

module.exports =
  ignores: ['readme.md', '**/_*', '.gitignore', '.gitattributes', 'ship.*conf']
  
  extensions: [
    # Bundle up the dependencies
    js_pipeline(files: 'libs/**/*.js', out: 'js/reqs.js', minify: true, hash: false)
    
    # minify the main.js
    js_pipeline(files: 'assets/js/*.ls', out: 'js/main.js', minify: true, hash: false)

    css_pipeline(files: 'assets/css/*.styl', out: 'css/style.css', minify: true, hash: false)
    dynamic_content()
  ]

  stylus:
    use: [axis(), rupture(), typographic(), autoprefixer()]

  postcss:
    use: [lost()]