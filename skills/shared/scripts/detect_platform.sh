#!/bin/bash
# Platform Detection Script
# Detects Rails, iOS Swift, or Android Kotlin projects

detect_platform() {
    local project_root="${1:-.}"

    # Priority 1: Check for Android Kotlin
    # Android projects typically have: gradle.properties + build.gradle.kts + app/ directory
    if [ -f "$project_root/gradle.properties" ]; then
        # Additional validation: check for app/ directory (standard Android structure)
        if [ -d "$project_root/app" ] || [ -f "$project_root/build.gradle.kts" ]; then
            echo "android-kotlin"
            return 0
        fi
    fi

    # Priority 2: Check for iOS Swift
    # iOS projects typically have: .xcodeproj or .xcworkspace + Podfile
    if [ -f "$project_root/Podfile" ]; then
        # Check for .xcodeproj or .xcworkspace in root
        if find "$project_root" -maxdepth 1 -name "*.xcodeproj" -type d 2>/dev/null | grep -q .; then
            echo "ios-swift"
            return 0
        fi
        if find "$project_root" -maxdepth 1 -name "*.xcworkspace" -type d 2>/dev/null | grep -q .; then
            echo "ios-swift"
            return 0
        fi
    fi

    # Priority 3: Check for Ruby on Rails
    # Rails projects typically have: Gemfile + config.ru + Rakefile + config/ directory
    if [ -f "$project_root/Gemfile" ]; then
        # Check for Rails-specific files
        if [ -f "$project_root/config.ru" ] || [ -f "$project_root/Rakefile" ]; then
            # Validate it's actually Rails (not iOS/Android Gemfile for Fastlane)
            if [ -d "$project_root/config" ] && [ -d "$project_root/app" ]; then
                echo "rails"
                return 0
            fi
        fi
        # Fallback: check Gemfile content for rails gem
        if grep -q "gem ['\"]rails['\"]" "$project_root/Gemfile" 2>/dev/null; then
            echo "rails"
            return 0
        fi
    fi

    # Fallback: Additional checks for edge cases

    # iOS fallback: Swift Package Manager only (no CocoaPods)
    if [ -f "$project_root/Package.swift" ]; then
        if find "$project_root" -maxdepth 1 -name "*.xcodeproj" -type d 2>/dev/null | grep -q .; then
            echo "ios-swift"
            return 0
        fi
    fi

    # Android fallback: old Groovy-based build.gradle
    if [ -f "$project_root/build.gradle" ]; then
        if grep -q "com.android.application" "$project_root/build.gradle" 2>/dev/null; then
            echo "android-kotlin"
            return 0
        fi
    fi

    # Unknown platform
    echo "unknown"
    return 1
}

# If script is executed directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    detect_platform "$@"
fi
