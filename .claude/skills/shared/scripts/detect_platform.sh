#!/bin/bash
# Platform Detection Script
# Detects Rails, iOS Swift, or Android Kotlin projects

detect_platform() {
    local project_root="${1:-.}"

    # Check for Android Kotlin (gradle.properties at root)
    if [ -f "$project_root/gradle.properties" ]; then
        echo "android-kotlin"
        return 0
    fi

    # Check for iOS Swift (any .xcodeproj folder)
    if find "$project_root" -maxdepth 2 -name "*.xcodeproj" -type d 2>/dev/null | grep -q .; then
        echo "ios-swift"
        return 0
    fi

    # Check for Ruby on Rails (Gemfile with rails gem)
    if [ -f "$project_root/Gemfile" ] && grep -q "gem ['\"]rails['\"]" "$project_root/Gemfile"; then
        echo "rails"
        return 0
    fi

    # Fallback: check additional indicators

    # iOS fallback: Package.swift or Podfile
    if [ -f "$project_root/Package.swift" ] || [ -f "$project_root/Podfile" ]; then
        echo "ios-swift"
        return 0
    fi

    # Android fallback: build.gradle with android plugin
    if [ -f "$project_root/build.gradle" ] && grep -q "com.android.application" "$project_root/build.gradle"; then
        echo "android-kotlin"
        return 0
    fi

    if [ -f "$project_root/build.gradle.kts" ] && grep -q "com.android.application" "$project_root/build.gradle.kts"; then
        echo "android-kotlin"
        return 0
    fi

    # Unknown platform
    echo "unknown"
    return 1
}

# If script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    detect_platform "$@"
fi
