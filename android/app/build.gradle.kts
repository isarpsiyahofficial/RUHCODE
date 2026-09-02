plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseStoreFile = providers.gradleProperty("RUH_RELEASE_STORE_FILE")
    .orElse(providers.environmentVariable("RUH_RELEASE_STORE_FILE"))
    .orNull
val releaseStorePassword = providers.gradleProperty("RUH_RELEASE_STORE_PASSWORD")
    .orElse(providers.environmentVariable("RUH_RELEASE_STORE_PASSWORD"))
    .orNull
val releaseKeyAlias = providers.gradleProperty("RUH_RELEASE_KEY_ALIAS")
    .orElse(providers.environmentVariable("RUH_RELEASE_KEY_ALIAS"))
    .orNull
val releaseKeyPassword = providers.gradleProperty("RUH_RELEASE_KEY_PASSWORD")
    .orElse(providers.environmentVariable("RUH_RELEASE_KEY_PASSWORD"))
    .orNull
val releaseSigningAvailable = listOf(
    releaseStoreFile,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.ruhcode.ruh_code"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.ruhcode.ruh_code"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningAvailable) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            // Never sign production releases with the debug keystore. CI source/asset
            // packaging may build an unsigned release when production credentials are
            // intentionally absent; the signed-release gate supplies all four values.
            if (releaseSigningAvailable) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter { source = "../.." }
