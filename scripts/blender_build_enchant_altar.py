import bpy
import bmesh
import mathutils
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\stations"
os.makedirs(output_dir, exist_ok=True)

fbx_path = os.path.join(output_dir, "Altar_Encantar_3D_Blender.fbx")
preview_path = os.path.join(output_dir, "preview_altar_encantar.png")

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

mat_dark_stone = create_mat("M_ObsidianStone", (0.08, 0.07, 0.12, 1.0), roughness=0.55)
mat_carved_runes = create_mat("M_PurpleRuneGlow", (0.8, 0.2, 1.0, 1.0), emission=(0.85, 0.25, 1.0, 1.0), emission_strength=5.0)
mat_gold_trim = create_mat("M_AltarGold", (0.95, 0.75, 0.2, 1.0), roughness=0.25, metallic=0.9)
mat_crystal_amethyst = create_mat("M_AmethystShard", (0.65, 0.1, 0.95, 1.0), emission=(0.7, 0.15, 1.0, 1.0), emission_strength=6.0)
mat_leather_tome = create_mat("M_TomeLeather", (0.28, 0.06, 0.35, 1.0), roughness=0.5)
mat_parchment = create_mat("M_TomeParchment", (0.92, 0.88, 0.78, 1.0), roughness=0.8)

# 1. Octagonal Base Platform
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=3.2, depth=0.5, location=(0, 0, 0.25))
base1 = bpy.context.active_object
base1.name = "Altar_Base_Octagon"
base1.data.materials.append(mat_dark_stone)

bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.7, depth=0.4, location=(0, 0, 0.6))
base2 = bpy.context.active_object
base2.name = "Altar_Step_2"
base2.data.materials.append(mat_gold_trim)

# 2. Main Central Pedestal with Runic Grooves
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.6, depth=1.6, location=(0, 0, 1.5))
pedestal = bpy.context.active_object
pedestal.name = "Altar_CentralPedestal"
pedestal.data.materials.append(mat_dark_stone)

# Glowing Runic Ring inside pedestal
bpy.ops.mesh.primitive_torus_add(major_radius=1.62, minor_radius=0.06, location=(0, 0, 1.5))
rune_ring = bpy.context.active_object
rune_ring.name = "RuneRing_Center"
rune_ring.data.materials.append(mat_carved_runes)

# Altar Table Top Slab
bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.0, depth=0.35, location=(0, 0, 2.4))
table_top = bpy.context.active_object
table_top.name = "Altar_TableTop"
table_top.data.materials.append(mat_dark_stone)

# Gold rim on table top
bpy.ops.mesh.primitive_torus_add(major_radius=2.02, minor_radius=0.05, location=(0, 0, 2.4))
top_rim = bpy.context.active_object
top_rim.name = "Altar_TopRim"
top_rim.data.materials.append(mat_gold_trim)

# 3. Floating Arcane Grimoire (Hovering and open)
tome_z = 3.2
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, tome_z), scale=(1.8, 1.3, 0.12))
tome_cover = bpy.context.active_object
tome_cover.name = "Tome_Cover"
tome_cover.data.materials.append(mat_leather_tome)

# Left & Right Pages Angled
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.42, 0, tome_z + 0.1), scale=(0.85, 1.2, 0.1), rotation=(0, math.radians(14), 0))
page_l = bpy.context.active_object
page_l.name = "Tome_Page_L"
page_l.data.materials.append(mat_parchment)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0.42, 0, tome_z + 0.1), scale=(0.85, 1.2, 0.1), rotation=(0, math.radians(-14), 0))
page_r = bpy.context.active_object
page_r.name = "Tome_Page_R"
page_r.data.materials.append(mat_parchment)

# Glowing Arcane Rune Circle floating above the Tome
bpy.ops.mesh.primitive_circle_add(radius=0.8, fill_type='NGON', location=(0, 0, tome_z + 0.35), rotation=(math.radians(10), 0, 0))
rune_circle = bpy.context.active_object
rune_circle.name = "FloatingSpellCircle"
rune_circle.data.materials.append(mat_carved_runes)

# 4. 4 Orbiting Floating Amethyst Shards
for i in range(4):
    ang = i * (math.pi / 2) + 0.3
    ox = math.cos(ang) * 2.3
    oy = math.sin(ang) * 2.3
    oz = 2.8 + math.sin(i) * 0.3
    bpy.ops.mesh.primitive_cone_add(radius1=0.18, radius2=0.03, depth=0.8, location=(ox, oy, oz), rotation=(0.2, 0.3, ang))
    shard = bpy.context.active_object
    shard.name = f"OrbitAmethyst_{i+1}"
    shard.data.materials.append(mat_crystal_amethyst)

# 5. Twin Braziers (Left & Right)
for x in [-2.4, 2.4]:
    # Brazier stand
    bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=2.0, location=(x, 0, 1.0))
    bstand = bpy.context.active_object
    bstand.name = f"BrazierStand_{'L' if x < 0 else 'R'}"
    bstand.data.materials.append(mat_gold_trim)
    
    # Brazier Bowl
    bpy.ops.mesh.primitive_cone_add(radius1=0.2, radius2=0.55, depth=0.45, location=(x, 0, 2.15))
    bowl = bpy.context.active_object
    bowl.name = f"BrazierBowl_{'L' if x < 0 else 'R'}"
    bowl.data.materials.append(mat_dark_stone)
    
    # Ethereal Crystal Flame
    bpy.ops.mesh.primitive_cone_add(radius1=0.35, depth=0.7, location=(x, 0, 2.65))
    flame = bpy.context.active_object
    flame.name = f"CrystalFlame_{'L' if x < 0 else 'R'}"
    flame.data.materials.append(mat_crystal_amethyst)

# Export FBX
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.fbx(filepath=fbx_path, use_selection=True)
print(f"[Blender] Altar de Encantar exported to: {fbx_path}")

# Camera & Preview
bpy.context.scene.render.resolution_x = 960
bpy.context.scene.render.resolution_y = 720
world = bpy.data.worlds.new("AltarWorld")
bpy.context.scene.world = world

cam_data = bpy.data.cameras.new("AltarCam")
cam_data.lens = 45
cam_obj = bpy.data.objects.new("AltarCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (0, -7.5, 4.2)
cam_obj.rotation_euler = (math.radians(70), 0, 0)

# Lights
l1 = bpy.data.lights.new("AltarLight", 'POINT')
l1.energy = 2600
l1.color = (0.8, 0.4, 1.0)
l1_obj = bpy.data.objects.new("AltarLight", l1)
l1_obj.location = (0, -3.0, 4.5)
bpy.context.collection.objects.link(l1_obj)

bpy.context.scene.render.filepath = preview_path
bpy.ops.render.render(write_still=True)
print(f"[Blender] Preview rendered to: {preview_path}")
