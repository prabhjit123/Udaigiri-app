// ✅ Repository setup for buildscript
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.1")
    }
}

// ✅ Apply Google Services plugin
apply(plugin = "com.google.gms.google-services")

// ✅ For all projects, define repositories
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Optional: Customize build directory
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// ✅ Define clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
