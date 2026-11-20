import bpy
import bmesh
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\stations"
os.makedirs(output_dir, exist_ok=True)

# Limpiar escena
bpy.ops.wm.read_factory_settings(use_empty=True)

def create_mat(name, color, roughness=0.4, metallic=0.0, emission=None, emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission:
            bsdf.inputs['Emission Color'].default_value = emission
            bsdf.inputs['Emission Strength'].default_value = emission_strength
    return mat

mat_stone = create_mat("ForgeStone", (0.16, 0.14, 0.18, 1.0), roughness=0.85)
mat_dark_iron = create_mat("ForgeIron", (0.22, 0.22, 0.26, 1.0), roughness=0.25, metallic=0.9)
mat_brass = create_mat("ForgeBrass", (0.9, 0.75, 0.25, 1.0), roughness=0.2, metallic=0.85)
mat_fire_coals = create_mat("ForgeEmbers", (1.0, 0.35, 0.05, 1.0), roughness=0.1, emission=(1.0, 0.35, 0.05, 1.0), emission_strength=8.0)
mat_wood = create_mat("ForgeWoodStump", (0.35, 0.22, 0.12, 1.0), roughness=0.75)

parts = []

# 1. Base del Horno de Mampostería
mesh_hearth = bpy.data.meshes.new("Forge_HearthBase")
bm = bmesh.new()
# Base escalonada
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 4.2
    v.co.y *= 3.0
    v.co.z *= 2.6
    v.co.z += 1.3
    v.co.y -= 0.5
# Hueco del fuego arqueado
bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=1.4, radius2=1.4, depth=1.8)
for v in bm.verts[-26:]:
    # Rotar 90 deg en X
    temp_y = v.co.y
    v.co.y = -v.co.z + 0.3
    v.co.z = temp_y + 1.2
bm.to_mesh(mesh_hearth)
bm.free()
obj_hearth = bpy.data.objects.new("Forge_HearthBase", mesh_hearth)
obj_hearth.data.materials.append(mat_stone)
bpy.context.collection.objects.link(obj_hearth)
parts.append(obj_hearth)

# 2. Chimenea Cónica Superior
mesh_chimney = bpy.data.meshes.new("Forge_ChimneyStack")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=1.2, radius2=0.75, depth=3.8)
for v in bm.verts:
    v.co.z += 2.6 + 1.9
    v.co.y -= 0.6
bm.to_mesh(mesh_chimney)
bm.free()
obj_chimney = bpy.data.objects.new("Forge_ChimneyStack", mesh_chimney)
obj_chimney.data.materials.append(mat_stone)
bpy.context.collection.objects.link(obj_chimney)
parts.append(obj_chimney)

# 3. Foso de Brasas y Carbones Ardientes
mesh_embers = bpy.data.meshes.new("Forge_MoltenEmbers")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=1.3, radius2=1.2, depth=0.4)
for v in bm.verts:
    v.co.z += 0.8
    v.co.y -= 0.2
bm.to_mesh(mesh_embers)
bm.free()
obj_embers = bpy.data.objects.new("Forge_MoltenEmbers", mesh_embers)
obj_embers.data.materials.append(mat_fire_coals)
bpy.context.collection.objects.link(obj_embers)
parts.append(obj_embers)

# 4. Tocón de Madera para el Yunque
mesh_stump = bpy.data.meshes.new("Forge_Stump")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=12, radius1=0.85, radius2=0.75, depth=1.4)
for v in bm.verts:
    v.co.z += 0.7
    v.co.y += 2.0
bm.to_mesh(mesh_stump)
bm.free()
obj_stump = bpy.data.objects.new("Forge_Stump", mesh_stump)
obj_stump.data.materials.append(mat_wood)
bpy.context.collection.objects.link(obj_stump)
parts.append(obj_stump)

# 5. Yunque Pesado Esculpido
mesh_anvil = bpy.data.meshes.new("Forge_AnvilBody")
bm = bmesh.new()
# Cuerpo del yunque
bmesh.ops.create_cube(bm, size=1.0)
for v in bm.verts:
    v.co.x *= 1.6
    v.co.y *= 0.75
    v.co.z *= 0.65
    v.co.z += 1.4 + 0.35
    v.co.y += 2.0
# Cuerno del yunque
bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.32, radius2=0.06, depth=0.95)
for v in bm.verts[-18:]:
    # Rotar para apuntar en X
    temp_z = v.co.z
    v.co.z = v.co.x + 1.75
    v.co.x = temp_z + 0.8 + 0.47
    v.co.y += 2.0
bm.to_mesh(mesh_anvil)
bm.free()
obj_anvil = bpy.data.objects.new("Forge_AnvilBody", mesh_anvil)
obj_anvil.data.materials.append(mat_dark_iron)
bpy.context.collection.objects.link(obj_anvil)
parts.append(obj_anvil)

# 6. Martillo Mágico de Forja (Flotando sobre el yunque en ángulo)
mesh_hammer = bpy.data.meshes.new("Forge_SpectralHammer")
bm = bmesh.new()
# Cabeza del martillo
bmesh.ops.create_cube(bm, size=0.45)
for v in bm.verts:
    v.co.x *= 1.8
    v.co.y *= 1.0
    v.co.z *= 1.0
    v.co.z += 2.9
    v.co.y += 2.0
# Mango del martillo
bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.06, radius2=0.06, depth=1.3)
for v in bm.verts[-18:]:
    # Inclinado 45 deg
    v.co.z += 3.3
    v.co.x -= 0.6
    v.co.y += 2.0
bm.to_mesh(mesh_hammer)
bm.free()
obj_hammer = bpy.data.objects.new("Forge_SpectralHammer", mesh_hammer)
obj_hammer.data.materials.append(mat_brass)
bpy.context.collection.objects.link(obj_hammer)
parts.append(obj_hammer)

# Exportar FBX
bpy.ops.object.select_all(action='DESELECT')
for p in parts:
    p.select_set(True)

fbx_out = os.path.join(output_dir, "Horno_Forja_3D_Blender.fbx")
bpy.ops.export_scene.fbx(
    filepath=fbx_out,
    use_selection=True,
    global_scale=1.0,
    axis_forward='-Z',
    axis_up='Y'
)
print(f"Exported FBX: {fbx_out}")

# Configurar cámara y renderizar preview
cam_data = bpy.data.cameras.new("ForgeCam")
cam_obj = bpy.data.objects.new("ForgeCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (5.5, -4.5, 4.2)
cam_obj.rotation_euler = (math.radians(65), 0, math.radians(45))

# Luces
l1 = bpy.data.lights.new("SunL", 'SUN')
l1.energy = 4.0
l1.color = (1.0, 0.95, 0.85)
lo1 = bpy.data.objects.new("SunL", l1)
lo1.rotation_euler = (math.radians(45), math.radians(30), 0)
bpy.context.collection.objects.link(lo1)

l_fire = bpy.data.lights.new("FireGlow", 'POINT')
l_fire.energy = 800
l_fire.color = (1.0, 0.45, 0.1)
lo_fire = bpy.data.objects.new("FireGlow", l_fire)
lo_fire.location = (0, -0.2, 1.2)
bpy.context.collection.objects.link(lo_fire)

preview_out = os.path.join(output_dir, "preview_horno_forja.png")
bpy.context.scene.render.resolution_x = 960
bpy.context.scene.render.resolution_y = 600
bpy.context.scene.render.filepath = preview_out
bpy.ops.render.render(write_still=True)
print(f"Rendered Preview: {preview_out}")
