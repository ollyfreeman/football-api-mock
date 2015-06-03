module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        coffeelint: {
            app: ['src/app/*.coffee', 'src/test/*.coffee'],
            options: {
                configFile: './etc/config/coffeelint.json'
            }
        },

        coffee: {
            // application files
            glob_to_multiple: {
                expand: true,
                flatten: false,
                cwd: 'src',
                src: ['**/*.coffee'],
                dest: 'build',
                ext: '.js'
            }
        },

        nodeunit: {
            all: ['build/test/test-*.js']
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

    grunt.loadNpmTasks('grunt-coffeelint');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-nodeunit');
    grunt.loadNpmTasks('grunt-contrib-watch');

    grunt.registerTask('default', ['coffeelint', 'coffee', 'nodeunit']);}
