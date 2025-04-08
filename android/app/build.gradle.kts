plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") version "4.4.2" apply false
}

buildscript 
{
    repositories 
    {
        google() 
        mavenCentral()
    }
    dependencies {
        // Add Google Services plugin here
        classpath("com.google.gms:google-services:4.3.15")  
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

android {
    namespace = "com.example.cw6"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

     defaultConfig {
        applicationId = "com.example.cw6" // Your package name
        minSdkVersion(23)
        targetSdkVersion(33)
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
}

dependencies 
{
  implementation("com.google.firebase:firebase-analytics-ktx:21.0.0") // Example dependency
  implementation(platform("com.google.firebase:firebase-bom:33.12.0"))
}

flutter {
    source = "../.."
}
apply plugin: 'com.google.gms.google-services'  
