set(APP_NAME "app")

add_executable(${APP_NAME})

set(CMAKE_Swift_FLAGS "${CMAKE_Swift_FLAGS} -import-objc-header ${CMAKE_CURRENT_SOURCE_DIR}/Shaders/Shader-Header.h" )

set(SHADERS
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLDirectionalLight.metal
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLFairy.metal
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLGBuffer.metal
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLPointLights.metal
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLShadow.metal
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLSkybox.metal
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLConfig.h
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLShaderCommon.h
	${CMAKE_CURRENT_SOURCE_DIR}/Shaders/AAPLShaderTypes.h
)

set(ASSETS
	${CMAKE_CURRENT_SOURCE_DIR}/Assets/Catalog.xcassets
	${CMAKE_CURRENT_SOURCE_DIR}/Assets/Meshes/Temple.mtl
	${CMAKE_CURRENT_SOURCE_DIR}/Assets/Meshes/Temple.obj
)

set(SHARED_SOURCES
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/Extensions/PlatformView+Layout.swift

	${CMAKE_CURRENT_SOURCE_DIR}/Shared/Platform/Operator.swift
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/Platform/PlatformEdgeInsets.swift
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/Platform/PlatformView.swift
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/Platform/PlatformViewController.swift

	${CMAKE_CURRENT_SOURCE_DIR}/Shared/AppDelegate.swift
	${CMAKE_CURRENT_SOURCE_DIR}/Shared/RootViewController.swift
)

target_sources(${APP_NAME} PRIVATE
	${SHARED_SOURCES}
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

	set(MACOS_SOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/main.swift
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/Window.swift
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/Label.swift
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/Font.swift
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/Color.swift
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/ImageView.swift
		${CMAKE_CURRENT_SOURCE_DIR}/macOS/Button.swift
	)

	set(MATH_SOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/Math/Math+Matrix.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Math/Math+Scalar.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Math/Math+TypeAlias.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Math/Math+Vector.swift
	)

	set(EDITOR_SOURCES
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/WindowController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Main/MainViewController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Main/RenderViewController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Main/SidebarViewController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/CreateProject/CreateProjectViewController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/CreateProject/CreateProjectView.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/CreateProject/CreateProjectItemView.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Console/ConsoleViewController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Console/Console.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Test/EditorViewController.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Test/RulerView.swift
		${CMAKE_CURRENT_SOURCE_DIR}/Editor/Test/TextView.swift
	)
	
	set(ECS_SOURCES
		${CMAKE_CURRENT_LIST_DIR}/ECS/ECS.swift
		${CMAKE_CURRENT_LIST_DIR}/ECS/ECS+Component.swift
		${CMAKE_CURRENT_LIST_DIR}/ECS/ECS+ComponentMask.swift
		${CMAKE_CURRENT_LIST_DIR}/ECS/ECS+Entity.swift
		${CMAKE_CURRENT_LIST_DIR}/ECS/ECS+Identifiers.swift
	)

	set(COMPONENTS_SOURCES
		${CMAKE_CURRENT_LIST_DIR}/Component/Camera+Component.swift
		${CMAKE_CURRENT_LIST_DIR}/Component/Component.swift
		${CMAKE_CURRENT_LIST_DIR}/Component/Tag+Component.swift
		${CMAKE_CURRENT_LIST_DIR}/Component/Transform+Component.swift
	)

	set(SCENE_SOURCES
		${CMAKE_CURRENT_LIST_DIR}/Scene/Object.swift
		${CMAKE_CURRENT_LIST_DIR}/Scene/Scene.swift
	)

	set(RENDERER_SOURCES
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Extensions/Metal+Extensions.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Extensions/ModelIO+Extensions.swift

		${CMAKE_CURRENT_LIST_DIR}/Renderer/Mesh/Material.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Mesh/Mesh.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Mesh/SubMesh.swift

		${CMAKE_CURRENT_LIST_DIR}/Renderer/Utilities/BufferView.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Utilities/Camera.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Utilities/RenderDestination.swift

		${CMAKE_CURRENT_LIST_DIR}/Renderer/DepthStencilStates.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/GBufferTextures.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/PipelineStates.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/Renderer.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/SinglePassDeferredRenderer.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/TraditionalDeferredRenderer.swift
		${CMAKE_CURRENT_LIST_DIR}/Renderer/VertexDescriptors.swift
	)

	# Group the files by folder in the IDE
	source_group("MacOS" FILES ${MACOS_SOURCES})
	source_group("Math" FILES ${MATH_SOURCES})
	source_group("Editor" FILES ${EDITOR_SOURCES})
	source_group("ECS" FILES ${ECS_SOURCES})
	source_group("Components" FILES ${COMPONENTS_SOURCES})
	source_group("Scene" FILES ${SCENE_SOURCES})
	source_group("Renderer" FILES ${RENDERER_SOURCES})

	target_sources(${APP_NAME} PRIVATE
		${MACOS_SOURCES}
		${MATH_SOURCES}
		${EDITOR_SOURCES}
		${ECS_SOURCES}
		${COMPONENTS_SOURCES}
		${SCENE_SOURCES}
		${RENDERER_SOURCES}
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
source_group("Shared" FILES ${SHARED_SOURCES})
source_group("Shaders" FILES ${SHADERS})
source_group("Assets" FILES ${ASSETS})