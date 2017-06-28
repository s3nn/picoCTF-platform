gulp   = require 'gulp'
cjsx   = require 'gulp-cjsx'
gutil  = require 'gulp-util'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
minifyCss = require 'gulp-minify-css'

paths =
  dist: "./dist/"
  deployment: "/srv/http/ctf/"

gulp.task 'watch', ->
  gulp.watch ['./public/**/*'], ['copy']
  gulp.watch ['./public/css/**/*.css'], ['minify-css']
  gulp.watch ['./src/**/*.cjsx'], ['cjsx', 'build', 'deploy']

gulp.task "copy", ->
    gulp.src("public/**/*")
        .pipe gulp.dest paths.dist

gulp.task 'cjsx', ->
  gulp.src './src/**/*.cjsx'
  .pipe cjsx
    bare: true
  .on 'error', console.log
  .pipe gulp.dest(paths.dist + '/src/')

gulp.task 'minify-css', ->
  gulp.src('src/css/*.css')
  .pipe minifyCss(compatibility: 'ie8')
  .pipe gulp.dest(paths.dist + '/public/css/')

gulp.task 'build', ["cjsx"], ->
  browserify
    entries: [paths.dist + '/src/app_router.js']
    extensions: ['.js']
  .bundle()
  .pipe source 'build.js'
  .pipe gulp.dest paths.dist + '/src/'

gulp.task 'deploy', ['build'], ->
  gulp.src paths.dist + "/**/*"
      .pipe gulp.dest paths.deployment

gulp.task 'default', ['copy', 'build', 'minify-css', 'deploy']
