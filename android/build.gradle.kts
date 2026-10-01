allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Compile plugins against an installed SDK platform (android-35 isn't installed
// and can't be downloaded from here).
subprojects {
    if (!state.executed) {
        afterEvaluate {
            extensions.findByType(com.android.build.api.dsl.LibraryExtension::class.java)?.compileSdk = 36
        }
    }
}
