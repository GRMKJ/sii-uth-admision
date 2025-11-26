import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Ensure older pub packages that don't specify an Android namespace (AGP 7+)
// get assigned one so the build doesn't fail. This targets the
// `root_jailbreak_detector` plugin module specifically.
subprojects {
    plugins.withId("com.android.library") {
        if (project.name == "root_jailbreak_detector") {
            extensions.configure<LibraryExtension>("android") {
                namespace = "com.ozanorfa.rootjailbreakdetector.root_jailbreak_detector"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
