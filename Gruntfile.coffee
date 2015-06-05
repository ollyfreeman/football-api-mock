module.exports = (grunt) ->

    grunt.initConfig {
        # to allow importing data from package.json
        pkg: grunt.file.readJSON('package.json')

        coffeelint: {
            app: ['./app/*.coffee', './test/*.coffee']
            options: {
                configFile: './etc/config/coffeelint.json'
            }
        }

        mochaTest: {
            test: {
                src: ['./test/test-*.coffee']
            }
        }

        watch: {
          scripts: {
            files: ['**/*.coffee', 'etc/**']
            tasks: ['default']
            options: {
              spawn: true
            }
          }
        }
    }

    grunt.loadNpmTasks('grunt-coffeelint')
    grunt.loadNpmTasks('grunt-mocha-test')
    grunt.loadNpmTasks('grunt-contrib-watch')

    grunt.registerTask('default', ['coffeelint', 'mochaTest'])
