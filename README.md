# OWO TÀ

OWO TÀ is a mobile-first 3D action-adventure prototype built as an independently owned commercial project. This private repository is the permanent source of truth for design, engineering, assets, and platform builds.

## Ownership and constraints

- Original project source remains in the Olori24/owo-ta repository.
- No proprietary game-generation dependency is required.
- No paid external service is required for core development.
- No secrets or private credentials belong in the repository.
- Only original or properly licensed assets may be shipped.

## Stack

- Godot 4.3 stable and GDScript
- Blender for 3D asset creation
- GitHub and GitHub Actions
- Android APK/AAB export

## Current milestone

The foundation includes a bootable Godot project, a minimal startup scene, mobile-oriented rendering defaults, Android export configuration, CI validation, and engineering/licensing documentation. The next gameplay milestone is a real 3D district and third-person controller.

## Quick validation

~~~bash
chmod +x scripts/*.sh
./scripts/validate_project.sh
~~~

For engine-level validation, install the pinned Godot 4.3 stable editor and matching export templates, then run:

~~~bash
godot --headless --editor --path . --quit
godot --headless --path . --script res://scripts/ProjectValidation.gd
~~~

## Android export setup

A fresh checkout needs all of the following before Android export:

1. Install the Godot 4.3 stable editor.
2. In Godot's Editor > Manage Export Templates, install the matching 4.3 stable export templates.
3. Install the matching Android Gradle build template into this project. The CI workflow performs this with the Godot --install-android-build-template command.
4. Install JDK 17 and Android SDK command-line tools, platform-tools, Android 34 platform, and build-tools 34.0.0.
5. Set JAVA_HOME and ANDROID_HOME (or ANDROID_SDK_ROOT) in the shell. In Godot Editor, configure the Java SDK and Android SDK paths under Editor Settings > Export > Android.
6. Run scripts/build_android.sh. It checks prerequisites and invokes Godot; it does not install Java, the Android SDK, or the editor export templates.

The GitHub Actions workflow provisions these tools and uploads a debug APK artifact when manually dispatched or when changes are pushed to main. A successful project validation is not evidence that an APK has been exported; only a completed export workflow with an uploaded artifact proves that.

## Licensing

Godot's engine license does not replace the licenses of bundled third-party components. Before release, inspect the exact engine/export-template version's third-party notices and include all applicable notices with the game distribution. See docs/license-register.md.

## Project documentation

- docs/engineering-foundation.md
- docs/branching-and-contribution.md
- docs/asset-inventory.md
- docs/license-register.md
