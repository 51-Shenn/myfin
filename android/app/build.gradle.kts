import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.myfin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.myfin"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use { localProperties.load(it) }
        }

        val fbAppId = localProperties.getProperty("facebook.app.id") ?: ""
        val fbClientToken = localProperties.getProperty("facebook.client.token") ?: ""

        resValue("string", "facebook_app_id", fbAppId)
        resValue("string", "facebook_client_token", fbClientToken)
        resValue("string", "fb_login_protocol_scheme", "fb$fbAppId")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

     signingConfigs {
        getByName("debug") {
            val keyStoreFile = project.property("MYAPP_DEBUG_STORE_FILE") as String
            storeFile = file(keyStoreFile)
            storePassword = project.property("MYAPP_DEBUG_STORE_PASSWORD") as String
            keyAlias = project.property("MYAPP_DEBUG_KEY_ALIAS") as String
            keyPassword = project.property("MYAPP_DEBUG_KEY_PASSWORD") as String
        }
    }


}

flutter {
    source = "../.."
}
