plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace = "com.arttech.booktrackerapp"
    compileSdk = 34 // Рекомендуется указать конкретную версию, а не flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId = "com.arttech.booktrackerapp"
        minSdk = 21 // Рекомендуется указать конкретную версию
        targetSdk = 34 // Рекомендуется указать конкретную версию
        versionCode = flutterVersionCode.toInteger()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // <<< ДОБАВЬТЕ ЭТОТ БЛОК >>>
    applicationVariants.all { variant ->
        variant.outputs.all { output ->
            // Формируем новое имя файла. v${defaultConfig.versionName} возьмет версию из defaultConfig
            def newName = "BookTracker-v${defaultConfig.versionName}-${variant.buildType.name}.apk"
            outputFileName = newName
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Ваши зависимости...
}