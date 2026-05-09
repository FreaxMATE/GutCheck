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

// Inject the AGP `namespace` for legacy Flutter plugins that still rely on the
// (now-removed) `package` attribute in AndroidManifest.xml. Required by
// isar_flutter_libs 3.1.0+1 (unmaintained) on AGP 8+.
subprojects {
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            val androidExt = project.extensions.getByName("android")
                as com.android.build.gradle.LibraryExtension
            if (androidExt.namespace == null) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val match = Regex("package=\"([^\"]+)\"").find(manifestFile.readText())
                    if (match != null) {
                        androidExt.namespace = match.groupValues[1]
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
