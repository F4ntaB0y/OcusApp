import java.io.File 
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.focus_app" 
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // NDK Fix
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // START PERBAIKAN KRITIS: Aktifkan Java 8 Desugaring
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // START: Konfigurasi Signing untuk Release Build
    val signingProperties = Properties()
    val signingPropertiesFile = rootProject.file("key.properties")
    
    if (signingPropertiesFile.exists()) {
        signingProperties.load(FileInputStream(signingPropertiesFile))
    }

    signingConfigs {
        create("release") {
            storeFile = File(signingProperties["storeFile"] as String) 
            keyAlias = signingProperties["keyAlias"] as String
            storePassword = signingProperties["storePassword"] as String
            keyPassword = signingProperties["keyPassword"] as String
        }
    }
    // END: Konfigurasi Signing

    defaultConfig {
        applicationId = "com.example.focus_app" 
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") 
            isMinifyEnabled = true
        }
    }
}

// START PERBAIKAN KRITIS: Tambahkan Desugaring Dependency di luar blok android{}
dependencies {
    // Dependency ini digunakan oleh fitur notifikasi
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
// END PERBAIKAN KRITIS

flutter {
    source = "../.."
}