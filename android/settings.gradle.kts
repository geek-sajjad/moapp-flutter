pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")

// Plugins like file_picker pin an older AGP on their buildscript classpath;
// reuse the project's AGP so nothing extra must be fetched from dl.google.com.
gradle.beforeProject {
    buildscript.configurations.getByName("classpath").resolutionStrategy.eachDependency {
        if (requested.group == "com.android.tools.build" && requested.name == "gradle") {
            useVersion("9.1.0")
        }
    }
}
