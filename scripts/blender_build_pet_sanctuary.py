import bpy
import bmesh
import mathutils
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\stations"
os.makedirs(output_dir, exist_ok=True)

fbx_path = os.path.join(output_dir, "Santuario_Mascotas_3D_Blender.fbx")
preview_path = os.path.join(output_dir, "preview_santuario_mascotas.png")

bpy.ops.wm.read_factory_settings(use_empty=True)

def create_mat(name, color, roughness=0.4, metallic=0.0, emission=None, emission_strength=2.0):
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

mat_mossy_stone = create_mat("M_MossStone", (0.2, 0.25, 0.22, 1.0), roughness=0.7)
mat_ancient_bark = create_mat("M_AncientBark", (0.16, 0.11, 0.08, 1.0), roughness=0.8)
mat_spirit_foliage = create_mat("M_SpiritFoliage", (0.1, 0.9, 0.55, 1.0), emission=(0.15, 0.95, 0.6, 1.0), emission_strength=3.5)
mat_mana_water = create_mat("M_ManaWater", (0.05, 0.8, 0.95, 0.7), emission=(0.1, 0.85, 1.0, 1.0), emission_strength=2.5)
mat_gold_trim = create_mat("M_SanctuaryGold", (0.95, 0.75, 0.2, 1.0), roughness=0.25, metallic=0.9)
mat_velvet_cushion = create_mat("M_VelvetCushion", (0.05, 0.5, 0.45, 1.0), roughness=0.7)
mat_familiar_spirit = create_mat("M_FamiliarSpirit", (0.2, 1.0, 0.7, 1.0), emission=(0.3, 1.0, 0.8, 1.0), emission_strength=5.0)

# 1. Circular Mossy Stone Sanctuary Basin
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=3.5, depth=0.5, location=(0, 0, 0.25))
base_plat = bpy.context.active_object
base_plat.name = "Sanctuary_BasePlatform"
base_plat.data.materials.append(mat_mossy_stone)

# Inner Water Pool Basin
bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=2.6, depth=0.15, location=(0, 0, 0.55))
water = bpy.context.active_object
water.name = "ManaPool_Water"
water.data.materials.append(mat_mana_water)

# Basin Gold Lip Ring
bpy.ops.mesh.primitive_torus_add(major_radius=2.65, minor_radius=0.08, location=(0, 0, 0.55))
basin_lip = bpy.context.active_object
basin_lip.name = "Basin_GoldLip"
basin_lip.data.materials.append(mat_gold_trim)

# 2. Central Fairy Spirit Tree Trunk
bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=2.8, location=(0, 0, 1.8), rotation=(0.1, -0.08, 0))
trunk = bpy.context.active_object
trunk.name = "SpiritTree_Trunk"
trunk.data.materials.append(mat_ancient_bark)

# Main Branches
branch_angles = [0, 2.1, 4.2]
for idx, ang in enumerate(branch_angles):
    bx = math.cos(ang) * 0.9
    by = math.sin(ang) * 0.9
    bpy.ops.mesh.primitive_cylinder_add(radius=0.18, depth=1.6, location=(bx, by, 3.2), rotation=(0.4 * math.cos(ang), 0.4 * math.sin(ang), ang))
    br = bpy.context.active_object
    br.name = f"Branch_{idx+1}"
    br.data.materials.append(mat_ancient_bark)
    
    # Glowing Foliage Cloud on each branch
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.85, location=(bx * 1.5, by * 1.5, 3.8))
    fol = bpy.context.active_object
    fol.name = f"SpiritFoliage_{idx+1}"
    fol.data.materials.append(mat_spirit_foliage)

# Top Canopy Foliage
bpy.ops.mesh.primitive_uv_sphere_add(radius=1.1, location=(0, 0, 4.3))
top_fol = bpy.context.active_object
top_fol.name = "SpiritFoliage_Crown"
top_fol.data.materials.append(mat_spirit_foliage)

# 3. Floating Familiar Spirits Hovering (Arcane wisp orbs with trails)
wisp_angles = [0.8, 2.6, 4.8]
for idx, ang in enumerate(wisp_angles):
    wx = math.cos(ang) * 1.8
    wy = math.sin(ang) * 1.8
    wz = 2.4 + math.sin(ang) * 0.4
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.2, location=(wx, wy, wz))
    wisp = bpy.context.active_object
    wisp.name = f"FamiliarWisp_{idx+1}"
    wisp.data.materials.append(mat_familiar_spirit)

# 4. 3 Velvet Pet Resting Perches around the pool
perch_angles = [1.2, 3.2, 5.2]
for idx, ang in enumerate(perch_angles):
    px = math.cos(ang) * 2.2
    py = math.sin(ang) * 2.2
    # Stone plinth
    bpy.ops.mesh.primitive_cylinder_add(radius=0.45, depth=0.4, location=(px, py, 0.7))
    plinth = bpy.context.active_object
    plinth.name = f"PetPlinth_{idx+1}"
    plinth.data.materials.append(mat_mossy_stone)
    
    # Soft velvet cushion for pets
    bpy.ops.mesh.primitive_cylinder_add(radius=0.4, depth=0.15, location=(px, py, 0.95))
    cushion = bpy.context.active_object
    cushion.name = f"PetCushion_{idx+1}"
    cushion.data.materials.append(mat_velvet_cushion)

# Export FBX
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.fbx(filepath=fbx_path, use_selection=True)
print(f"[Blender] Santuario de Mascotas exported to: {fbx_path}")

# Camera & Preview
bpy.context.scene.render.resolution_x = 960
bpy.context.scene.render.resolution_y = 720
world = bpy.data.worlds.new("PetWorld")
bpy.context.scene.world = world

cam_data = bpy.data.cameras.new("PetCam")
cam_data.lens = 45
cam_obj = bpy.data.objects.new("PetCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (0, -8.0, 4.6)
cam_obj.rotation_euler = (math.radians(68), 0, 0)

# Lights
l1 = bpy.data.lights.new("PetLight", 'POINT')
l1.energy = 2800
l1.color = (0.2, 1.0, 0.7)
l1_obj = bpy.data.objects.new("PetLight", l1)
l1_obj.location = (0, -3.5, 4.8)
bpy.context.collection.objects.link(l1_obj)

bpy.context.scene.render.filepath = preview_path
bpy.ops.render.render(write_still=True)
print(f"[Blender] Preview rendered to: {preview_path}")
