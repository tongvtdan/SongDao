import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingProperties = Properties().apply {
    val propertiesFile = rootProject.file("key.properties")
    if (propertiesFile.exists()) {
        propertiesFile.inputStream().use(::load)
    }
}

fun signingValue(propertyName: String, environmentName: String): String? =
    System.getenv(environmentName)?.takeIf(String::isNotBlank)
        ?: signingProperties.getProperty(propertyName)?.takeIf(String::isNotBlank)

val releaseSigningValues = mapOf(
    "storeFile" to signingValue("storeFile", "SONGDAO_STORE_FILE"),
    "storePassword" to signingValue("storePassword", "SONGDAO_STORE_PASSWORD"),
    "keyAlias" to signingValue("keyAlias", "SONGDAO_KEY_ALIAS"),
    "keyPassword" to signingValue("keyPassword", "SONGDAO_KEY_PASSWORD"),
)
val missingReleaseSigningValues = releaseSigningValues
    .filterValues { it == null }
    .keys
val releaseSigningConfigured = missingReleaseSigningValues.isEmpty()
val releaseTaskRequested = gradle.startParameter.taskNames.any { taskName ->
    taskName.contains("release", ignoreCase = true)
}

if (releaseTaskRequested && !releaseSigningConfigured) {
    throw GradleException(
        "Release signing is not configured. Set all SONGDAO_* signing environment " +
            "variables or create android/key.properties. Missing: " +
            missingReleaseSigningValues.joinToString(),
    )
}

if (releaseSigningValues.values.any { it != null } && !releaseSigningConfigured) {
    throw GradleException(
        "Release signing is incomplete. Provide all four values in android/key.properties " +
            "or through SONGDAO_* environment variables. Missing: " +
            missingReleaseSigningValues.joinToString(),
    )
}

android {
    namespace = "com.dantino.songdao"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.dantino.songdao"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                keyAlias = releaseSigningValues.getValue("keyAlias")
                keyPassword = releaseSigningValues.getValue("keyPassword")
                storeFile = rootProject.file(releaseSigningValues.getValue("storeFile"))
                storePassword = releaseSigningValues.getValue("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningConfigured) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
