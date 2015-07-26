fs = require 'fs'
path = require 'path'
open = require 'open'

gulp = require 'gulp'
coffee = require 'gulp-coffee'
rename = require 'gulp-rename'
uglify = require 'gulp-uglify'

gulp.task 'build-dev', ->
  gulp.src 'src/stained-glass.coffee'
  .pipe coffee()
  .pipe gulp.dest 'dist/'

gulp.task 'build', ['build-dev'], ->
  gulp.src 'dist/stained-glass.js'
  .pipe uglify()
  .pipe rename 'stained-glass.min.js'
  .pipe gulp.dest 'dist/'

gulp.task 'watch', ->
  gulp.watch 'src/stained-glass.coffee', [ 'build-dev' ]

gulp.task 'clean', (done) ->
  fs.unlink 'dist', done

gulp.task 'default', ['build']
