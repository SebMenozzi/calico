set(APP_NAME "app")

add_executable(${APP_NAME})

set(SHADERS
	${PROJECT_SOURCE_DIR}/Shaders/AAPLDirectionalLight.metal
	${PROJECT_SOURCE_DIR}/Shaders/AAPLFairy.metal
	${PROJECT_SOURCE_DIR}/Shaders/AAPLGBuffer.metal
	${PROJECT_SOURCE_DIR}/Shaders/AAPLPointLights.metal
	${PROJECT_SOURCE_DIR}/Shaders/AAPLShadow.metal
	${PROJECT_SOURCE_DIR}/Shaders/AAPLSkybox.metal
	${PROJECT_SOURCE_DIR}/Shaders/AAPLConfig.h
	${PROJECT_SOURCE_DIR}/Shaders/AAPLShaderCommon.h
	${PROJECT_SOURCE_DIR}/Shaders/AAPLShaderTypes.h
)

set(ASSETS
	${PROJECT_SOURCE_DIR}/Assets/Catalog.xcassets
	${PROJECT_SOURCE_DIR}/Assets/Meshes/Temple.mtl
	${PROJECT_SOURCE_DIR}/Assets/Meshes/Temple.obj
)

target_sources(${APP_NAME} PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/AppDelegate.swift
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/ViewController.swift
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/Float+Extensions.swift
)

# CODE_SIGN_STYLE: Set to Manual or Automatic signing
# DEVELOPMENT_TEAM_ID: Set to your team ID from Apple
# CODE_SIGN_IDENTITY: Set to your preferred code sign identity, to see list:
#                     => /usr/bin/env xcrun security find-identity -v -p codesigning
# CODE_SIGNING_REQUIRED: Set to YES or NO to indicate if code signing is required
set(CODE_SIGN_STYLE "Automatic")
set(DEVELOPMENT_TEAM_ID "2TE7AHNP9P")
set(CODE_SIGN_IDENTITY "Apple Development")
set(CODE_SIGNING_REQUIRED "YES")

if (CMAKE_SYSTEM_NAME STREQUAL iOS)
	set(RESOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/iOS/AppIcon.xcassets
		${CMAKE_CURRENT_SOURCE_DIR}/iOS/Storyboards/LaunchScreen.storyboard
		${SHADERS}
		${ASSETS}
	)

	set_target_properties(${APP_NAME} PROPERTIES
		MACOSX_BUNDLE TRUE
		XCODE_ATTRIBUTE_PRODUCT_NAME "Calico"
		XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "co.seb.calico-ios"
		MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/iOS/Info.plist"
		RESOURCE "${RESOURCES}"

		XCODE_ATTRIBUTE_CODE_SIGN_STYLE "${CODE_SIGN_STYLE}"
		XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${DEVELOPMENT_TEAM_ID}"
		XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${CODE_SIGN_IDENTITY}"
		XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "${CODE_SIGNING_REQUIRED}"

		XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
	)

	target_link_libraries(${APP_NAME} PUBLIC "-framework UIKit")
else ()
	set(RESOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/AppIcon.xcassets
		${SHADERS}
		${ASSETS}
	)

	target_sources(${APP_NAME} PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/main.swift
		${RESOURCES}
	)

	set_target_properties(${APP_NAME} PROPERTIES
		MACOSX_BUNDLE TRUE
		XCODE_ATTRIBUTE_PRODUCT_NAME "Calico"
		XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "co.seb.calico-macos"
		MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/macOS/Info.plist"
		RESOURCE "${RESOURCES}"

		XCODE_ATTRIBUTE_CODE_SIGN_STYLE "${CODE_SIGN_STYLE}"
		XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "${DEVELOPMENT_TEAM_ID}"
		XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "${CODE_SIGN_IDENTITY}"
		XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "${CODE_SIGNING_REQUIRED}"

		XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
	)

	target_link_libraries(${APP_NAME} PUBLIC "-framework AppKit")
endif()

target_link_libraries(${APP_NAME} PUBLIC
	"-framework CoreGraphics"
	"-framework QuartzCore"
	"-framework Metal"
)

# Group the files by folder in the IDE
source_group("Shaders" FILES ${SHADERS})
source_group("Assets" FILES ${ASSETS})