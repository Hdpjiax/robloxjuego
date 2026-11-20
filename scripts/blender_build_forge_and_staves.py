import bpy
import bmesh
import math
import mathutils
import os

print("[Blender] Iniciando creación del Horno de Forja 3D y Sistema de Bastones...")

# Limpiar escena
bpy.ops.wm.read_factory_settings(use_empty=True)

output_dir_stations = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\stations"
output_dir_staves = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\staves"
os.makedirs(output_dir_stations, exist_ok=True)
os.makedirs(output_dir_staves, exist_ok=True)

# Material helper
def create_mat(name, color, roughness=0.4, metallic=0.0, emission=None, emission_strength=2.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission and 'Emission Color' in bsdf.inputs:
            bsdf.inputs['Emission Color'].default_value = emission
            if 'Emission Strength' in bsdf.inputs:
                bsdf.inputs['Emission Strength'].default_value = emission_strength
    return mat

mat_stone = create_mat("ForgeStone", (0.22, 0.23, 0.26, 1.0), roughness=0.85)
mat_dark_brick = create_mat("DarkBrick", (0.16, 0.17, 0.20, 1.0), roughness=0.9)
mat_iron = create_mat("ForgedIron", (0.10, 0.11, 0.12, 1.0), roughness=0.35, metallic=0.9)
mat_bronze = create_mat("ForgeBronze", (0.75, 0.45, 0.15, 1.0), roughness=0.3, metallic=0.8)
mat_lava = create_mat("MoltenLava", (1.0, 0.35, 0.02, 1.0), roughness=0.1, emission=(1.0, 0.4, 0.05, 1.0), emission_strength=8.0)
mat_hammer_glow = create_mat("HammerRune", (1.0, 0.6, 0.1, 1.0), roughness=0.2, emission=(1.0, 0.6, 0.1, 1.0), emission_strength=5.0)

# ==============================================================================
# 1. CONSTRUCCIÓN DEL HORNO DE FORJA 3D (OVEN, CRUCIBLE, CHIMNEY, ANVIL, HAMMER)
# ==============================================================================
forge_objects = []

# A) Base del Horno de Mampostería
mesh_base = bpy.data.meshes.new("OvenBaseMesh")
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, verts=bm.verts, vec=(3.2, 2.6, 2.2))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, -1.2, 1.1))
bm.to_mesh(mesh_base)
bm.free()
obj_base = bpy.data.objects.new("Oven_Base", mesh_base)
obj_base.data.materials.append(mat_stone)
bpy.context.collection.objects.link(obj_base)
forge_objects.append(obj_base)

# B) Chimenea Cónica de Piedra
mesh_chimney = bpy.data.meshes.new("ChimneyMesh")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.85, radius2=0.55, depth=3.4)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, -1.2, 3.8))
bm.to_mesh(mesh_chimney)
bm.free()
obj_chimney = bpy.data.objects.new("Oven_Chimney", mesh_chimney)
obj_chimney.data.materials.append(mat_dark_brick)
bpy.context.collection.objects.link(obj_chimney)
forge_objects.append(obj_chimney)

# C) Crisol de Lava Ardiente (Hearth Firebox)
mesh_hearth = bpy.data.meshes.new("HearthMesh")
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, verts=bm.verts, vec=(1.8, 1.2, 1.1))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, -0.4, 1.1))
bm.to_mesh(mesh_hearth)
bm.free()
obj_hearth = bpy.data.objects.new("Oven_LavaCrucible", mesh_hearth)
obj_hearth.data.materials.append(mat_lava)
bpy.context.collection.objects.link(obj_hearth)
forge_objects.append(obj_hearth)

# D) Arco de Hierro Forjado que bordea la boca del horno
mesh_arch = bpy.data.meshes.new("ArchMesh")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=1.2, radius2=1.2, depth=0.3)
bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(90), 4, 'X'))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0.25, 1.4))
bm.to_mesh(mesh_arch)
bm.free()
obj_arch = bpy.data.objects.new("Oven_IronArch", mesh_arch)
obj_arch.data.materials.append(mat_iron)
bpy.context.collection.objects.link(obj_arch)
forge_objects.append(obj_arch)

# E) Yunque Maestro de Acero (Anvil)
mesh_anvil = bpy.data.meshes.new("AnvilMesh")
bm = bmesh.new()
# Cuerpo del yunque
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, verts=bm.verts, vec=(1.4, 0.7, 0.8))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 1.5, 0.8))
# Cuerno cónico del yunque
bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=0.25, radius2=0.04, depth=0.7)
bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(90), 4, 'Y'))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0.95, 1.5, 1.05))
bm.to_mesh(mesh_anvil)
bm.free()
obj_anvil = bpy.data.objects.new("Forge_Anvil", mesh_anvil)
obj_anvil.data.materials.append(mat_iron)
bpy.context.collection.objects.link(obj_anvil)
forge_objects.append(obj_anvil)

# F) Martillo de Herrero Encantado con Animación Keyframed de Golpe
mesh_hammer = bpy.data.meshes.new("HammerMesh")
bm = bmesh.new()
# Mango
bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=0.06, radius2=0.06, depth=1.1)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 0.55))
# Cabeza del martillo
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, verts=bm.verts, vec=(0.45, 0.28, 0.28))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 1.1))
bm.to_mesh(mesh_hammer)
bm.free()
obj_hammer = bpy.data.objects.new("Forge_Hammer", mesh_hammer)
obj_hammer.data.materials.append(mat_hammer_glow)
bpy.context.collection.objects.link(obj_hammer)
obj_hammer.location = (0, 1.5, 1.4)
obj_hammer.rotation_euler = (math.radians(-35), 0, 0)
forge_objects.append(obj_hammer)

# Animar el Martillo en Blender (Frames 1-30: Ciclo de golpe)
bpy.context.scene.frame_start = 1
bpy.context.scene.frame_end = 30

# Frame 1: Arriba preparado
bpy.context.scene.frame_set(1)
obj_hammer.location = (0, 1.5, 1.6)
obj_hammer.rotation_euler = (math.radians(-45), 0, 0)
obj_hammer.keyframe_insert(data_path="location", index=-1)
obj_hammer.keyframe_insert(data_path="rotation_euler", index=-1)

# Frame 10: Golpe seco sobre el yunque
bpy.context.scene.frame_set(10)
obj_hammer.location = (0, 1.5, 1.25)
obj_hammer.rotation_euler = (math.radians(0), 0, 0)
obj_hammer.keyframe_insert(data_path="location", index=-1)
obj_hammer.keyframe_insert(data_path="rotation_euler", index=-1)

# Frame 14: Rebote elástico
bpy.context.scene.frame_set(14)
obj_hammer.location = (0, 1.5, 1.4)
obj_hammer.rotation_euler = (math.radians(-15), 0, 0)
obj_hammer.keyframe_insert(data_path="location", index=-1)
obj_hammer.keyframe_insert(data_path="rotation_euler", index=-1)

# Frame 30: Regreso al reposo elevado
bpy.context.scene.frame_set(30)
obj_hammer.location = (0, 1.5, 1.6)
obj_hammer.rotation_euler = (math.radians(-45), 0, 0)
obj_hammer.keyframe_insert(data_path="location", index=-1)
obj_hammer.keyframe_insert(data_path="rotation_euler", index=-1)

# Render de previsualización del Horno de Forja
bpy.context.scene.render.resolution_x = 960
bpy.context.scene.render.resolution_y = 600

world = bpy.context.scene.world or bpy.data.worlds.new("ForgeWorld")
bpy.context.scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs['Color'].default_value = (0.05, 0.06, 0.09, 1.0)
    bg.inputs['Strength'].default_value = 0.6

cam_data = bpy.data.cameras.new("ForgeCam")
cam_data.lens = 40
cam_obj = bpy.data.objects.new("ForgeCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (3.5, 4.0, 3.2)
cam_obj.rotation_euler = (math.radians(65), 0, math.radians(135))

# Luces
l_lava = bpy.data.lights.new("LavaLight", 'POINT')
l_lava.energy = 1500
l_lava.color = (1.0, 0.45, 0.1)
lo_lava = bpy.data.objects.new("LavaLight", l_lava)
lo_lava.location = (0, -0.2, 1.4)
bpy.context.collection.objects.link(lo_lava)

l_key = bpy.data.lights.new("ForgeKey", 'POINT')
l_key.energy = 1800
l_key.color = (0.9, 0.95, 1.0)
lo_key = bpy.data.objects.new("ForgeKey", l_key)
lo_key.location = (2.5, 2.5, 4.0)
bpy.context.collection.objects.link(lo_key)

preview_forge_path = os.path.join(output_dir_stations, "preview_horno_forja.png")
bpy.context.scene.render.filepath = preview_forge_path
bpy.ops.render.render(write_still=True)
print(f"[Blender] Render de Horno de Forja guardado en: {preview_forge_path}")

# Exportar FBX del Horno
fbx_forge_path = os.path.join(output_dir_stations, "horno_forja_3d.fbx")
bpy.ops.export_scene.fbx(filepath=fbx_forge_path, use_selection=False, bake_anim=True)
print(f"[Blender] FBX de Horno exportado en: {fbx_forge_path}")

print("[Blender] Completado con éxito.")
