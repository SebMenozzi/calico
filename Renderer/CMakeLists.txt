set(MODULE Renderer)

set(EXTENSIONS_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/Extensions/Metal+Extensions.swift
    ${CMAKE_CURRENT_LIST_DIR}/Extensions/ModelIO+Extensions.swift
    ${CMAKE_CURRENT_LIST_DIR}/Extensions/SIMD+Extensions.swift
)

set(MESH_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/Mesh/Material.swift
    ${CMAKE_CURRENT_LIST_DIR}/Mesh/Mesh.swift
    ${CMAKE_CURRENT_LIST_DIR}/Mesh/SubMesh.swift
)

set(UTILITIES_SOURCES
    ${CMAKE_CURRENT_LIST_DIR}/Utilities/BufferView.swift
    ${CMAKE_CURRENT_LIST_DIR}/Utilities/Camera.swift
    ${CMAKE_CURRENT_LIST_DIR}/Utilities/RenderDestination.swift
    ${CMAKE_CURRENT_LIST_DIR}/Utilities/Transform.swift
)

calico_library(${MODULE}
    ${EXTENSIONS_SOURCES}
    ${MESH_SOURCES}
    ${UTILITIES_SOURCES}
    ${CMAKE_CURRENT_LIST_DIR}/DepthStencilStates.swift
    ${CMAKE_CURRENT_LIST_DIR}/GBufferTextures.swift
    ${CMAKE_CURRENT_LIST_DIR}/PipelineStates.swift
    ${CMAKE_CURRENT_LIST_DIR}/Renderer.swift
    ${CMAKE_CURRENT_LIST_DIR}/Scene.swift
    ${CMAKE_CURRENT_LIST_DIR}/SinglePassDeferredRenderer.swift
    ${CMAKE_CURRENT_LIST_DIR}/TraditionalDeferredRenderer.swift
    ${CMAKE_CURRENT_LIST_DIR}/VertexDescriptors.swift
)

# Group the files by folder in the IDE
source_group("Extensions" FILES ${EXTENSIONS_SOURCES})
source_group("Meshes" FILES ${MESH_SOURCES})
source_group("Utilities" FILES ${UTILITIES_SOURCES})