import bpy
import bmesh
import mathutils
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\stations"
os.makedirs(output_dir, exist_ok=True)

fbx_path = os.path.join(output_dir, "Estante_Magico_3D_Blender.fbx")
preview_path = os.path.join(output_dir, "preview_estante_magico.png")

# 1. Clean scene
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

mat_dark_wood = create_mat("M_DarkWood", (0.18, 0.11, 0.06, 1.0), roughness=0.6)
mat_carved_wood = create_mat("M_CarvedWood", (0.24, 0.15, 0.08, 1.0), roughness=0.5)
mat_gold = create_mat("M_GoldTrim", (0.95, 0.78, 0.22, 1.0), roughness=0.25, metallic=0.9)
mat_glass = create_mat("M_Glass", (0.85, 0.92, 0.98, 0.4), roughness=0.1)
mat_potion_blue = create_mat("M_PotBlue", (0.05, 0.6, 1.0, 1.0), emission=(0.1, 0.7, 1.0, 1.0), emission_strength=3.5)
mat_potion_red = create_mat("M_PotRed", (1.0, 0.1, 0.25, 1.0), emission=(1.0, 0.15, 0.3, 1.0), emission_strength=3.5)
mat_potion_green = create_mat("M_PotGreen", (0.1, 1.0, 0.3, 1.0), emission=(0.15, 1.0, 0.35, 1.0), emission_strength=3.5)
mat_potion_purple = create_mat("M_PotPurple", (0.7, 0.15, 1.0, 1.0), emission=(0.75, 0.2, 1.0, 1.0), emission_strength=4.0)
mat_leather_book = create_mat("M_BookLeather", (0.35, 0.1, 0.12, 1.0), roughness=0.6)
mat_book_pages = create_mat("M_BookPages", (0.88, 0.85, 0.75, 1.0), roughness=0.8)
mat_scroll = create_mat("M_ScrollParchment", (0.9, 0.86, 0.72, 1.0), roughness=0.7)
mat_crystal = create_mat("M_CrystalCluster", (0.3, 0.85, 1.0, 1.0), emission=(0.4, 0.9, 1.0, 1.0), emission_strength=4.5)

# --- Base Cabinet / Frame ---
# Main backboard
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 2.5), scale=(3.4, 0.25, 4.8))
backboard = bpy.context.active_object
backboard.name = "Shelf_Backboard"
backboard.data.materials.append(mat_dark_wood)

# Outer Pillars (Left & Right)
for x in [-1.75, 1.75]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.16, depth=5.0, location=(x, 0.25, 2.5))
    pillar = bpy.context.active_object
    pillar.name = f"Pillar_{'L' if x < 0 else 'R'}"
    pillar.data.materials.append(mat_carved_wood)
    
    # Pillar Gold Rings
    for z in [0.2, 2.5, 4.8]:
        bpy.ops.mesh.primitive_torus_add(major_radius=0.2, minor_radius=0.03, location=(x, 0.25, z))
        ring = bpy.context.active_object
        ring.name = f"GoldRing_{x}_{z}"
        ring.data.materials.append(mat_gold)

# Top Ornate Arch / Pediment
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.15, 5.0), scale=(3.7, 0.45, 0.4))
top_trim = bpy.context.active_object
top_trim.name = "Shelf_TopTrim"
top_trim.data.materials.append(mat_gold)

bpy.ops.mesh.primitive_cylinder_add(radius=0.8, depth=0.35, location=(0, 0.15, 5.3), rotation=(math.pi/2, 0, 0))
top_arch = bpy.context.active_object
top_arch.name = "Shelf_ArchCrown"
top_arch.data.materials.append(mat_carved_wood)

# Arcane Crest Emblem in the Arch
bpy.ops.mesh.primitive_circle_add(radius=0.35, fill_type='NGON', location=(0, 0.35, 5.3), rotation=(math.pi/2, 0, 0))
emblem = bpy.context.active_object
emblem.name = "ArcaneEmblem"
emblem.data.materials.append(mat_gold)

# Bottom Sturdy Pedestal Base
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.25, 0.2), scale=(3.8, 0.9, 0.45))
base_plat = bpy.context.active_object
base_plat.name = "Shelf_Base"
base_plat.data.materials.append(mat_dark_wood)

# 4 Horizontal Shelves
shelf_heights = [1.1, 2.2, 3.3, 4.4]
for idx, z in enumerate(shelf_heights):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.3, z), scale=(3.5, 0.7, 0.12))
    sh = bpy.context.active_object
    sh.name = f"Shelf_Plank_{idx+1}"
    sh.data.materials.append(mat_carved_wood)

# --- Shelf 1 (Bottom): Heavy Spell Tomes & Giant Crystal Cluster ---
# Books stacked horizontally and vertically
book_colors = [mat_leather_book, mat_dark_wood, mat_potion_purple]
for b in range(5):
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-1.2 + b * 0.18, 0.3, 1.5), scale=(0.14, 0.5, 0.65))
    book = bpy.context.active_object
    book.name = f"Tome_V_{b}"
    book.data.materials.append(mat_leather_book)

# Large Crystal Geode on right side of shelf 1
bpy.ops.mesh.primitive_cone_add(radius1=0.22, radius2=0.04, depth=0.7, location=(1.1, 0.3, 1.55), rotation=(0.1, -0.15, 0.2))
crys1 = bpy.context.active_object
crys1.name = "ArcaneGeode_1"
crys1.data.materials.append(mat_crystal)

bpy.ops.mesh.primitive_cone_add(radius1=0.18, depth=0.55, location=(0.9, 0.25, 1.48), rotation=(-0.15, 0.2, -0.3))
crys2 = bpy.context.active_object
crys2.name = "ArcaneGeode_2"
crys2.data.materials.append(mat_crystal)

# --- Shelf 2: Potion Flasks (Blue, Red, Green) ---
pot_specs = [
    (-1.2, mat_potion_blue, "RoundFlask"),
    (-0.7, mat_potion_red, "TallFlask"),
    (-0.2, mat_potion_green, "RoundFlask"),
    (0.3, mat_potion_purple, "TallFlask"),
    (0.8, mat_potion_blue, "RoundFlask"),
    (1.2, mat_potion_red, "TallFlask"),
]

for x, pmat, ptype in pot_specs:
    if ptype == "RoundFlask":
        bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(x, 0.3, 2.45))
        pot_body = bpy.context.active_object
        pot_body.name = f"PotBody_{x}"
        pot_body.data.materials.append(pmat)
        
        bpy.ops.mesh.primitive_cylinder_add(radius=0.06, depth=0.16, location=(x, 0.3, 2.65))
        pot_neck = bpy.context.active_object
        pot_neck.name = f"PotNeck_{x}"
        pot_neck.data.materials.append(mat_glass)
        
        # Cork
        bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.08, location=(x, 0.3, 2.75))
        cork = bpy.context.active_object
        cork.name = f"Cork_{x}"
        cork.data.materials.append(mat_dark_wood)
    else:
        # Tall flask
        bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=0.45, location=(x, 0.3, 2.52))
        pot_body = bpy.context.active_object
        pot_body.name = f"TallPotBody_{x}"
        pot_body.data.materials.append(pmat)
        
        bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.08, location=(x, 0.3, 2.78))
        cork = bpy.context.active_object
        cork.name = f"CorkTall_{x}"
        cork.data.materials.append(mat_dark_wood)

# --- Shelf 3: Ancient Scrolls & Mystical Artifacts ---
# Parchment scrolls tied
for s in range(4):
    bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.55, location=(-1.1 + s * 0.22, 0.3, 3.5), rotation=(0, math.pi/2, 0))
    scr = bpy.context.active_object
    scr.name = f"Scroll_{s}"
    scr.data.materials.append(mat_scroll)

# Golden Chalice / Relic
bpy.ops.mesh.primitive_cone_add(radius1=0.15, radius2=0.25, depth=0.35, location=(0.3, 0.3, 3.6))
chalice = bpy.context.active_object
chalice.name = "GoldChalice"
chalice.data.materials.append(mat_gold)

# Floating Magic Orb on Stand
bpy.ops.mesh.primitive_cylinder_add(radius=0.2, depth=0.15, location=(1.1, 0.3, 3.45))
stand = bpy.context.active_object
stand.name = "OrbStand"
stand.data.materials.append(mat_gold)

bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(1.1, 0.3, 3.75))
orb = bpy.context.active_object
orb.name = "ArcaneOrb"
orb.data.materials.append(mat_potion_purple)

# --- Shelf 4 (Top): Rare Elixirs and Hourglass ---
for idx, x in enumerate([-1.0, -0.4, 0.4, 1.0]):
    col = mat_potion_blue if idx % 2 == 0 else mat_potion_green
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.16, location=(x, 0.3, 4.65))
    elix = bpy.context.active_object
    elix.name = f"RareElixir_{idx}"
    elix.data.materials.append(col)

# Select all and export FBX
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.fbx(filepath=fbx_path, use_selection=True)
print(f"[Blender] Estante Magico exported to: {fbx_path}")

# Setup Camera and Render Preview
bpy.context.scene.render.resolution_x = 960
bpy.context.scene.render.resolution_y = 720
world = bpy.context.scene.world or bpy.data.worlds.new("EstanteWorld")
bpy.context.scene.world = world
world.use_nodes = True
bg_node = world.node_tree.nodes.get("Background")
if bg_node:
    bg_node.inputs['Color'].default_value = (0.04, 0.05, 0.07, 1.0)
    bg_node.inputs['Strength'].default_value = 0.5

cam_data = bpy.data.cameras.new("EstanteCam")
cam_data.lens = 42
cam_obj = bpy.data.objects.new("EstanteCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (0, -6.5, 3.2)
cam_obj.rotation_euler = (math.radians(82), 0, 0)

# Key Light
l1 = bpy.data.lights.new("KeyLight", 'POINT')
l1.energy = 2500
l1.color = (1.0, 0.95, 0.8)
l1_obj = bpy.data.objects.new("KeyLight", l1)
l1_obj.location = (2.5, -4.5, 4.5)
bpy.context.collection.objects.link(l1_obj)

# Blue Rim Light
l2 = bpy.data.lights.new("RimLight", 'POINT')
l2.energy = 1800
l2.color = (0.3, 0.6, 1.0)
l2_obj = bpy.data.objects.new("RimLight", l2)
l2_obj.location = (-3.0, -2.0, 3.5)
bpy.context.collection.objects.link(l2_obj)

bpy.context.scene.render.filepath = preview_path
bpy.ops.render.render(write_still=True)
print(f"[Blender] Preview rendered to: {preview_path}")
