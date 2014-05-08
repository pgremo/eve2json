gulp = require 'gulp'
mocha = require 'gulp-mocha'
lint = require 'gulp-coffeelint'
clean = require 'gulp-clean'

gulp.task 'clean', ->
  gulp.src 'index.js', read: false
    .pipe clean()

gulp.task 'lint', ->
  gulp
    .src ['index.coffee', 'test/**/*.coffee']
    .pipe lint()
    .pipe lint.reporter()

gulp.task 'test', ->
  gulp.src 'test/**/*.coffee'
    .pipe mocha reporter: 'spec'

gulp.task 'default', ['lint', 'test']
