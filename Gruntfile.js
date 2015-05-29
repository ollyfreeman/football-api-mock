module.exports = function(grunt) {

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        coffeelint: {
            app: ['src/app/*.coffee', 'src/test/*.coffee'],
            options: {
                configFile: 'coffeelint.json'
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
        }
    });

    grunt.loadNpmTasks('grunt-coffeelint');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-nodeunit');

    grunt.registerTask('default', ['coffeelint', 'coffee', 'nodeunit']);}
