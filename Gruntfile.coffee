module.exports = (grunt) ->

    grunt.initConfig({
        # to allow importing data from package.json
        pkg: grunt.file.readJSON('package.json')

        coffeelint: {
            app: ['src/app/*.coffee', 'src/test/*.coffee'],
            options: {
                configFile: './etc/config/coffeelint.json'
            }
        },

        coffee: {
            glob_to_multiple: {
                expand: true,
                flatten: false,
                cwd: 'src',
                src: ['**/*.coffee'],
                dest: 'build',
                ext: '.js'
            }
        },

        mochaTest: {
            test: {
                src: ['build/test/test-*.js']
            }
        },

        watch: {
          scripts: {
            files: ['**/*.coffee', 'etc/**'],
            tasks: ['default'],
            options: {
              spawn: true,
            },
          },
        }
    });

    grunt.loadNpmTasks('grunt-coffeelint')
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks('grunt-mocha-test')
    grunt.loadNpmTasks('grunt-contrib-watch')

    grunt.registerTask('default', ['coffeelint', 'coffee', 'mochaTest'])
