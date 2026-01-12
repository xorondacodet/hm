# ============================================================================
# Xoron iOS Integration Tests - CMake Configuration
# Standalone test runner (no XCTest dependency for CMake/Ninja builds)
# ============================================================================

cmake_minimum_required(VERSION 3.20)
project(XoronIOSIntegrationTests LANGUAGES C CXX OBJC OBJCXX)

# Fix for older CMake versions
if(POLICY CMP0057)
    cmake_policy(SET CMP0057 NEW)
endif()
set(CMAKE_POLICY_VERSION_MINIMUM 3.5)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# iOS-specific settings
if(NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")
    message(FATAL_ERROR "This CMakeLists.txt is for iOS only")
endif()

# Test executable (builds as iOS app bundle)
# No XCTest dependency - uses standalone test runner
add_executable(XoronIOSIntegrationTests MACOSX_BUNDLE
    test_ios_integration.mm
)

# Link frameworks using -framework flag (more reliable for iOS cross-compilation)
target_link_libraries(XoronIOSIntegrationTests PRIVATE
    "-framework Foundation"
    "-framework UIKit"
    "-framework CoreGraphics"
)

# Include directories
target_include_directories(XoronIOSIntegrationTests PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../..
)

# Set iOS deployment target and bundle properties
set_target_properties(XoronIOSIntegrationTests PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.xoron.ios.tests"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "15.0"
    XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "YES"
    XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
    XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
)

# Compiler flags for Objective-C++
target_compile_options(XoronIOSIntegrationTests PRIVATE
    -fobjc-arc
)

# Set source file language explicitly
set_source_files_properties(test_ios_integration.mm PROPERTIES
    LANGUAGE OBJCXX
)

# Test configuration
enable_testing()
add_test(NAME iOSIntegrationTests
    COMMAND XoronIOSIntegrationTests
)
