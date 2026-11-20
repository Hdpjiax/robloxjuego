import bpy
import bmesh
import math
import mathutils
import os

print("[Blender] Creando render de exhibición de los 6 arquetipos de bastones y el horno de forja...")

bpy.ops.wm.read_factory_settings(use_empty=True)

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\staves"
os.makedirs(output_dir, exist_ok=True)

def create_mat(name, color, roughness=0.3, metallic=0.0, emission=None, emission_strength=2.0):
    mat = bpy.data.materials.new(name=name)
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

mat_dark_wood = create_mat("DarkWood", (0.22, 0.14, 0.08, 1.0), roughness=0.7)
mat_silver = create_mat("Silver", (0.85, 0.88, 0.92, 1.0), roughness=0.2, metallic=0.95)
mat_gold = create_mat("Gold", (0.95, 0.78, 0.22, 1.0), roughness=0.25, metallic=0.9)
mat_obsidian = create_mat("Obsidian", (0.05, 0.05, 0.07, 1.0), roughness=0.1, metallic=0.4)
mat_celestial = create_mat("CelestialGold", (1.0, 0.9, 0.45, 1.0), roughness=0.15, metallic=0.9)

# 6 Gem materials for the 6 rarities
mat_gem_comun = create_mat("GemComun", (0.4, 0.8, 1.0, 1.0), roughness=0.1, emission=(0.3, 0.7, 1.0, 1.0), emission_strength=3.0)
mat_gem_poco = create_mat("GemPoco", (0.2, 0.9, 0.4, 1.0), roughness=0.1, emission=(0.2, 0.9, 0.4, 1.0), emission_strength=3.5)
mat_gem_raro = create_mat("GemRaro", (0.1, 0.6, 1.0, 1.0), roughness=0.1, emission=(0.1, 0.5, 1.0, 1.0), emission_strength=4.0)
mat_gem_epico = create_mat("GemEpico", (0.8, 0.2, 1.0, 1.0), roughness=0.1, emission=(0.7, 0.2, 1.0, 1.0), emission_strength=4.5)
mat_gem_legend = create_mat("GemLegend", (1.0, 0.6, 0.05, 1.0), roughness=0.08, emission=(1.0, 0.5, 0.05, 1.0), emission_strength=5.5)
mat_gem_mitico = create_mat("GemMitico", (1.0, 0.15, 0.4, 1.0), roughness=0.05, emission=(1.0, 0.2, 0.4, 1.0), emission_strength=7.0)

# Build a modular staff
def build_staff(x_pos, shaft_mat, gem_mat, finial_type, halo_type):
    # Shaft
    mesh = bpy.data.meshes.new(f"Shaft_{x_pos}")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.065, radius2=0.085, depth=4.2)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(x_pos, 0, 2.1))
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(f"Shaft_{x_pos}", mesh)
    obj.data.materials.append(shaft_mat)
    bpy.context.collection.objects.link(obj)

    # Grip
    mesh_g = bpy.data.meshes.new(f"Grip_{x_pos}")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.09, radius2=0.095, depth=1.1)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(x_pos, 0, 1.4))
    bm.to_mesh(mesh_g)
    bm.free()
    obj_g = bpy.data.objects.new(f"Grip_{x_pos}", mesh_g)
    obj_g.data.materials.append(mat_gold)
    bpy.context.collection.objects.link(obj_g)

    # Core Gem
    mesh_gem = bpy.data.meshes.new(f"Gem_{x_pos}")
    bm = bmesh.new()
    if finial_type == "ball":
        bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=12, radius=0.35)
    elif finial_type == "crystal":
        bmesh.ops.create_cone(bm, cap_ends=True, segments=6, radius1=0.35, radius2=0.02, depth=0.9)
    else:
        bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.38)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(x_pos, 0, 4.3))
    bm.to_mesh(mesh_gem)
    bm.free()
    obj_gem = bpy.data.objects.new(f"Gem_{x_pos}", mesh_gem)
    obj_gem.data.materials.append(gem_mat)
    bpy.context.collection.objects.link(obj_gem)

    # Finial Claws / Crown
    mesh_crown = bpy.data.meshes.new(f"Crown_{x_pos}")
    bm = bmesh.new()
    for i in range(4):
        ang = math.radians(i * 90)
        cx = math.cos(ang) * 0.28
        cy = math.sin(ang) * 0.28
        bmesh.ops.create_cone(bm, cap_ends=True, segments=8, radius1=0.05, radius2=0.01, depth=0.8)
        bmesh.ops.rotate(bm, verts=bm.verts[-10:], cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(-15), 4, 'X'))
        bmesh.ops.translate(bm, verts=bm.verts[-10:], vec=(x_pos + cx, cy, 4.2))
    bm.to_mesh(mesh_crown)
    bm.free()
    obj_crown = bpy.data.objects.new(f"Crown_{x_pos}", mesh_crown)
    obj_crown.data.materials.append(mat_gold)
    bpy.context.collection.objects.link(obj_crown)

    # Orbit ring
    if halo_type:
        mesh_h = bpy.data.meshes.new(f"Halo_{x_pos}")
        bm = bmesh.new()
        bmesh.ops.create_cone(bm, cap_ends=True, segments=24, radius1=0.6, radius2=0.6, depth=0.04)
        bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(30), 4, 'X'))
        bmesh.ops.translate(bm, verts=bm.verts, vec=(x_pos, 0, 4.3))
        bm.to_mesh(mesh_h)
        bm.free()
        obj_h = bpy.data.objects.new(f"Halo_{x_pos}", mesh_h)
        obj_h.data.materials.append(gem_mat)
        bpy.context.collection.objects.link(obj_h)

# 6 Staff Archetypes
build_staff(-3.75, mat_dark_wood, mat_gem_comun, "ball", False)       # Común
build_staff(-2.25, mat_silver, mat_gem_poco, "crystal", False)        # Poco Común
build_staff(-0.75, mat_silver, mat_gem_raro, "crystal", True)         # Raro
build_staff(0.75, mat_gold, mat_gem_epico, "icosphere", True)          # Épico
build_staff(2.25, mat_obsidian, mat_gem_legend, "crystal", True)       # Legendario
build_staff(3.75, mat_celestial, mat_gem_mitico, "icosphere", True)    # Mítico

# Pedestal Floor
mesh_ped = bpy.data.meshes.new("PedestalFloor")
bm = bmesh.new()
bmesh.ops.create_cube(bm, size=1.0)
bmesh.ops.scale(bm, verts=bm.verts, vec=(10.0, 3.0, 0.4))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, -0.2))
bm.to_mesh(mesh_ped)
bm.free()
obj_ped = bpy.data.objects.new("PedestalFloor", mesh_ped)
obj_ped.data.materials.append(mat_obsidian)
bpy.context.collection.objects.link(obj_ped)

# Setup Camera & Scene
bpy.context.scene.render.resolution_x = 1200
bpy.context.scene.render.resolution_y = 675

cam_data = bpy.data.cameras.new("ShowcaseCam")
cam_data.lens = 38
cam_obj = bpy.data.objects.new("ShowcaseCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (0, -7.0, 2.7)
cam_obj.rotation_euler = (math.radians(82), 0, 0)

# Lighting
world = bpy.context.scene.world or bpy.data.worlds.new("ShowcaseWorld")
bpy.context.scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
    bg.inputs['Strength'].default_value = 0.5

# Key light
l_key = bpy.data.lights.new("KeyLight", 'POINT')
l_key.energy = 3500
l_key.color = (0.9, 0.95, 1.0)
lo_key = bpy.data.objects.new("KeyLight", l_key)
lo_key.location = (0, -4.5, 5.0)
bpy.context.collection.objects.link(lo_key)

# Rim light from behind
l_rim = bpy.data.lights.new("RimLight", 'POINT')
l_rim.energy = 2200
l_rim.color = (0.5, 0.7, 1.0)
lo_rim = bpy.data.objects.new("RimLight", l_rim)
lo_rim.location = (0, 3.5, 4.0)
bpy.context.collection.objects.link(lo_rim)

preview_staves_path = os.path.join(output_dir, "preview_100_staves_showcase.png")
bpy.context.scene.render.filepath = preview_staves_path
bpy.ops.render.render(write_still=True)
print(f"[Blender] Render de exhibición de bastones guardado en: {preview_staves_path}")
