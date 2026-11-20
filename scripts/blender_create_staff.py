import bpy
import bmesh
import math
import mathutils
import os

# Clear existing objects
bpy.ops.wm.read_factory_settings(use_empty=True)

# Create materials
def create_mat(name, color, roughness=0.3, metallic=0.0, emission=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if emission:
            bsdf.inputs['Emission Color'].default_value = emission
            bsdf.inputs['Emission Strength'].default_value = 4.0
    return mat

mat_wood = create_mat("StaffWood", (0.28, 0.17, 0.10, 1.0), roughness=0.7)
mat_leather = create_mat("StaffLeather", (0.16, 0.11, 0.08, 1.0), roughness=0.8)
mat_gold = create_mat("StaffGold", (0.95, 0.78, 0.22, 1.0), roughness=0.25, metallic=0.9)
mat_gem = create_mat("StaffGem", (0.1, 0.85, 1.0, 1.0), roughness=0.1, emission=(0.15, 0.9, 1.0, 1.0))
mat_gem_core = create_mat("StaffGemCore", (0.4, 0.95, 1.0, 1.0), roughness=0.05, emission=(0.4, 0.95, 1.0, 1.0))
mat_runic_ring = create_mat("RunicRing", (0.2, 0.9, 1.0, 1.0), roughness=0.2, emission=(0.2, 0.9, 1.0, 1.0))

parts = []

# 1. Main Shaft (Cylinder with gentle taper)
mesh_shaft = bpy.data.meshes.new("Staff_Shaft")
bm = bmesh.new()
# Shaft length ~ 4.2 units, radius ~ 0.075 to 0.09
bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=16, radius1=0.075, radius2=0.095, depth=4.2)
# Center shaft from Y=-1.8 to Y=+2.4
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 0.2))
bm.to_mesh(mesh_shaft)
bm.free()
obj_shaft = bpy.data.objects.new("Staff_Shaft", mesh_shaft)
obj_shaft.data.materials.append(mat_wood)
bpy.context.collection.objects.link(obj_shaft)
parts.append(obj_shaft)

# 2. Leather Grip Wrap (Middle lower section)
mesh_grip = bpy.data.meshes.new("Staff_Grip")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=16, radius1=0.098, radius2=0.102, depth=1.2)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, -0.4))
bm.to_mesh(mesh_grip)
bm.free()
obj_grip = bpy.data.objects.new("Staff_Grip", mesh_grip)
obj_grip.data.materials.append(mat_leather)
bpy.context.collection.objects.link(obj_grip)
parts.append(obj_grip)

# 3. Golden Metal Collars & Rings (Above and below grip)
for z_col in [-1.02, 0.22, 1.4, 2.3]:
    mesh_ring = bpy.data.meshes.new("Staff_Ring")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=16, radius1=0.115, radius2=0.115, depth=0.1)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, z_col))
    bm.to_mesh(mesh_ring)
    bm.free()
    obj_ring = bpy.data.objects.new(f"Staff_Ring_{z_col}", mesh_ring)
    obj_ring.data.materials.append(mat_gold)
    bpy.context.collection.objects.link(obj_ring)
    parts.append(obj_ring)

# 4. Pommel (Bottom base)
mesh_pommel = bpy.data.meshes.new("Staff_Pommel")
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=2, radius=0.18)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, -1.95))
bm.to_mesh(mesh_pommel)
bm.free()
obj_pommel = bpy.data.objects.new("Staff_Pommel", mesh_pommel)
obj_pommel.data.materials.append(mat_gold)
bpy.context.collection.objects.link(obj_pommel)
parts.append(obj_pommel)

# Pommel Jewel
mesh_pommel_jewel = bpy.data.meshes.new("Staff_PommelJewel")
bm = bmesh.new()
bmesh.ops.create_icosphere(bm, subdivisions=1, radius=0.11)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, -2.12))
bm.to_mesh(mesh_pommel_jewel)
bm.free()
obj_pj = bpy.data.objects.new("Staff_PommelJewel", mesh_pommel_jewel)
obj_pj.data.materials.append(mat_gem)
bpy.context.collection.objects.link(obj_pj)
parts.append(obj_pj)

# 5. Crown Head Base (Flared capital at Z = 2.4)
mesh_head = bpy.data.meshes.new("Staff_HeadBase")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=16, radius1=0.11, radius2=0.24, depth=0.35)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 2.45))
bm.to_mesh(mesh_head)
bm.free()
obj_head = bpy.data.objects.new("Staff_HeadBase", mesh_head)
obj_head.data.materials.append(mat_gold)
bpy.context.collection.objects.link(obj_head)
parts.append(obj_head)

# 6. Crescent Dragon Claws / Wings around the floating gem (4 curved prongs)
for i in range(4):
    ang = i * (math.pi / 2)
    mesh_claw = bpy.data.meshes.new(f"Staff_Claw_{i}")
    bm = bmesh.new()
    # Curved prong reaching up and out then curling in
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=8, radius1=0.06, radius2=0.02, depth=0.85)
    # Tilt claw
    bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(-16), 4, 'X'))
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0.32, 2.9))
    bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(ang, 4, 'Z'))
    bm.to_mesh(mesh_claw)
    bm.free()
    obj_claw = bpy.data.objects.new(f"Staff_Claw_{i}", mesh_claw)
    obj_claw.data.materials.append(mat_gold)
    bpy.context.collection.objects.link(obj_claw)
    parts.append(obj_claw)

# 7. FLOATING ARCANUM CORE GEM (Faceted Octahedron Crystal at Z = 3.0)
mesh_gem = bpy.data.meshes.new("Staff_ArcaneCore")
bm = bmesh.new()
# Octahedron / Double-pyramid crystal
bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=6, radius1=0.28, radius2=0.0, depth=0.45)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 0.225))
bm2 = bmesh.new()
bmesh.ops.create_cone(bm2, cap_ends=True, cap_tris=False, segments=6, radius1=0.0, radius2=0.28, depth=0.45)
bmesh.ops.translate(bm2, verts=bm2.verts, vec=(0, 0, -0.225))
for f in bm2.faces:
    bm.faces.new([bm.verts.new(v.co) for v in f.verts])
bm2.free()
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 3.05))
bm.to_mesh(mesh_gem)
bm.free()
obj_gem = bpy.data.objects.new("Staff_ArcaneCore", mesh_gem)
obj_gem.data.materials.append(mat_gem_core)
bpy.context.collection.objects.link(obj_gem)
parts.append(obj_gem)

# 8. Floating Runic Orbital Ring around the gem
mesh_orbit = bpy.data.meshes.new("Staff_OrbitRing")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=False, cap_tris=False, segments=24, radius1=0.44, radius2=0.46, depth=0.04)
# Tilt orbit ring 25 degrees
bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(25), 4, 'X'))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 3.05))
bm.to_mesh(mesh_orbit)
bm.free()
obj_orbit = bpy.data.objects.new("Staff_OrbitRing", mesh_orbit)
obj_orbit.data.materials.append(mat_runic_ring)
bpy.context.collection.objects.link(obj_orbit)
parts.append(obj_orbit)

out_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\staves"
fbx_path = os.path.join(out_dir, "Baston_Principal_Modular.fbx")

# Select all parts and export FBX
for o in bpy.data.objects:
    o.select_set(True)
bpy.context.view_layer.objects.active = obj_shaft
bpy.ops.export_scene.fbx(filepath=fbx_path, use_selection=True)

# Render Camera and Lighting
cam_data = bpy.data.cameras.new("Cam")
cam_obj = bpy.data.objects.new("Cam", cam_data)
cam_obj.location = (2.2, -4.6, 1.2)
cam_obj.rotation_euler = (math.radians(82), 0, math.radians(25))
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj

light_data = bpy.data.lights.new("Sun", type='SUN')
light_data.energy = 4.0
light_obj = bpy.data.objects.new("Sun", light_data)
light_obj.rotation_euler = (math.radians(50), math.radians(30), 0)
bpy.context.collection.objects.link(light_obj)

# Point light for gem glow
gem_light_data = bpy.data.lights.new("GemLight", type='POINT')
gem_light_data.energy = 80.0
gem_light_data.color = (0.2, 0.85, 1.0)
gem_light_obj = bpy.data.objects.new("GemLight", gem_light_data)
gem_light_obj.location = (0, 0, 3.1)
bpy.context.collection.objects.link(gem_light_obj)

# Point light for fill
fill_light_data = bpy.data.lights.new("FillLight", type='POINT')
fill_light_data.energy = 30.0
fill_light_data.color = (1.0, 0.9, 0.8)
fill_light_obj = bpy.data.objects.new("FillLight", fill_light_data)
fill_light_obj.location = (-1.5, -2.5, 0.5)
bpy.context.collection.objects.link(fill_light_obj)

bpy.context.scene.render.resolution_x = 900
bpy.context.scene.render.resolution_y = 1200
preview_png = os.path.join(out_dir, "preview_baston_principal.png")
bpy.context.scene.render.filepath = preview_png
bpy.ops.render.render(write_still=True)

print(f"Exported FBX to {fbx_path} and preview to {preview_png}")
