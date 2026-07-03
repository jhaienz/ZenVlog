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

// isar_flutter_libs 3.1.0+1 predates AGP 8's mandatory namespace; inject it
// from the plugin's Gradle group until Isar ships an AGP-compatible release.
subprojects {
    fun patchNamespace(project: Project) {
        project.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let { ext ->
            if (ext.namespace == null) {
                ext.namespace = project.group.toString()
            }
            if ((ext.compileSdk ?: 0) < 34) {
                ext.compileSdk = 36
            }
        }
    }
    if (state.executed) patchNamespace(this) else afterEvaluate { patchNamespace(this) }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
