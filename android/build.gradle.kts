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

    // Patch legacy Flutter plugins for AGP 8+ compatibility. Notably required by
    // isar_flutter_libs 3.1.0+1 (unmaintained). Must register BEFORE the
    // evaluationDependsOn(":app") block below, which forces subproject eval.
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            val androidExt = project.extensions.getByName("android")
                as com.android.build.gradle.LibraryExtension

            // 1. Inject `namespace` if the plugin still relies on the
            //    (now-removed) `package` attribute in AndroidManifest.xml.
            if (androidExt.namespace == null) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val match = Regex("package=\"([^\"]+)\"").find(manifestFile.readText())
                    if (match != null) {
                        androidExt.namespace = match.groupValues[1]
                    }
                }
            }

            // 2. Force compileSdk >= 34. Older Flutter plugins pin compileSdk 30
            //    while their transitive androidx deps reference attributes that
            //    were only added in API 31+ (e.g. android:attr/lStar). Mismatch
            //    surfaces as "AAPT: error: resource android:attr/lStar not found".
            val currentCompileSdk = androidExt.compileSdk ?: 0
            if (currentCompileSdk < 34) {
                androidExt.compileSdk = 34
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
