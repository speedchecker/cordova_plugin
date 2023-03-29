module.exports = function (context) {
    var fs = require('fs');
    var path = require('path');
    var buildGradle = path.join(context.opts.plugin.dir, 'src', 'android', 'build.gradle');

    // Auxiliary function to get the value of a preference from the config.xml
    var getPreferenceConfig = function (name) {
        var config = fs.readFileSync("./config.xml").toString();
        var preferenceValue = getPreferenceValueFromConfig(config, name);
        return preferenceValue
    }

    var getPreferenceValueFromConfig = function (config, name) {
        var value = config.match(new RegExp('name="' + name + '" value="(.*?)"', "i"))
        if (value && value[1]) {
            return value[1]
        } else {
            return null
        }
    }

    var username = getPreferenceConfig('speedcheckerapi_username') || '';
    var password = getPreferenceConfig('speedcheckerapi_password') || '';

    // Defining new content that we want to add
    var UpdateContent = `
repositories {
    google()
    mavenCentral()
    jcenter()
    maven {
        url 'https://maven.speedcheckerapi.com/artifactory/libs-release'
        credentials {
            username = "${username}"
            password = "${password}"
        }
    }
}

dependencies {
    implementation("com.speedchecker:android-sdk:4.2.194-medux")
    implementation("com.android.volley:volley:1.2.0")
}
`;

    // Save the modified content to the file
    fs.writeFileSync(buildGradle, UpdateContent, 'utf-8');
};
