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

subprojects {
    val proj = this
    fun forceSdk() {
        if (proj.plugins.hasPlugin("com.android.library") || proj.plugins.hasPlugin("com.android.application")) {
            val ext = proj.extensions.findByName("android")
            if (ext != null) {
                try {
                    ext.javaClass.getMethod("setCompileSdkVersion", Int::class.java).invoke(ext, 36)
                } catch (e: Exception) {}
            }
        }
    }
    if (proj.state.executed) {
        forceSdk()
    } else {
        proj.afterEvaluate { forceSdk() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
