gulp   = require 'gulp'
coffee = require 'gulp-coffeescript'
watch  = require 'gulp-watch'

resources =
  code :
    src : [
      'src/*.coffee'
      'src/**/*.coffee'
    ]
    dest : 'dist'
  tests :
    src : [
      'test/src/*.coffee'
      'test/src/**/*.coffee'
    ]
    dest : 'test/dist'

# build source code
gulp.task 'build:code', ->
  gulp
    .src resources.code.src
    .pipe coffee( bare : true ).on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest resources.code.dest

# build test
gulp.task 'build:test', ->
  gulp
    .src resources.tests.src
    .pipe coffee( bare : true ).on( 'error', ( err ) ->
      console.log err.message
      @emit 'end'
    )
    .pipe gulp.dest resources.tests.dest

# build all
gulp.task 'build', [
  'build:code'
  'build:test'
]

# watch on dev
gulp.task 'watch', ->
  gulp.watch resources.code.src, [ 'build:code' ]
  gulp.watch resources.tests.src, [ 'build:test' ]

# dev task
gulp.task 'dev', [
  'build'
  'watch'
]

gulp.task 'default', [ 'build' ]
