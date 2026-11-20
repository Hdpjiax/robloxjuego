import bpy
import bmesh
import math
import mathutils
import os

print("[Blender] Generando vista completa del Bastón Principal y los 6 Arquetipos...")
bpy.ops.wm.read_factory_settings(use_empty=True)

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\staves"

def create_mat(name, color, roughness=0.35, metallic=0.0, emission=None, emission_strength=1.0):
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

mat_wood = create_mat("StaffWood", (0.35, 0.22, 0.14, 1.0), roughness=0.6)
mat_leather = create_mat("StaffLeather", (0.22, 0.14, 0.10, 1.0), roughness=0.8)
mat_gold = create_mat("StaffGold", (0.95, 0.78, 0.22, 1.0), roughness=0.25, metallic=0.9)
mat_gem = create_mat("StaffGem", (0.0, 0.85, 1.0, 1.0), roughness=0.05, emission=(0.0, 0.85, 1.0, 1.0), emission_strength=5.0)
mat_ring = create_mat("StaffRing", (0.2, 0.95, 1.0, 1.0), roughness=0.1, emission=(0.2, 0.95, 1.0, 1.0), emission_strength=3.5)

# Build Complete Staff Model
# 1. Shaft (Length 4.5)
mesh_shaft = bpy.data.meshes.new("Staff_Shaft")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.07, radius2=0.085, depth=4.2)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 2.1))
bm.to_mesh(mesh_shaft)
bm.free()
obj_shaft = bpy.data.objects.new("Staff_Shaft", mesh_shaft)
obj_shaft.data.materials.append(mat_wood)
bpy.context.collection.objects.link(obj_shaft)

# 2. Leather Grip
mesh_grip = bpy.data.meshes.new("Staff_Grip")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.092, radius2=0.095, depth=1.1)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 1.5))
bm.to_mesh(mesh_grip)
bm.free()
obj_grip = bpy.data.objects.new("Staff_Grip", mesh_grip)
obj_grip.data.materials.append(mat_leather)
bpy.context.collection.objects.link(obj_grip)

# Gold Rings
for z_off in [0.95, 2.05]:
    mesh_r = bpy.data.meshes.new(f"Ring_{z_off}")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.105, radius2=0.105, depth=0.08)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, z_off))
    bm.to_mesh(mesh_r)
    bm.free()
    obj_r = bpy.data.objects.new(f"Ring_{z_off}", mesh_r)
    obj_r.data.materials.append(mat_gold)
    bpy.context.collection.objects.link(obj_r)

# 3. Pommel
mesh_pommel = bpy.data.meshes.new("Staff_Pommel")
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=12, radius=0.16)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 0.05))
bm.to_mesh(mesh_pommel)
bm.free()
obj_pommel = bpy.data.objects.new("Staff_Pommel", mesh_pommel)
obj_pommel.data.materials.append(mat_gold)
bpy.context.collection.objects.link(obj_pommel)

# 4. Crown Collar
mesh_collar = bpy.data.meshes.new("Staff_Collar")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=0.11, radius2=0.16, depth=0.25)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 4.25))
bm.to_mesh(mesh_collar)
bm.free()
obj_collar = bpy.data.objects.new("Staff_Collar", mesh_collar)
obj_collar.data.materials.append(mat_gold)
bpy.context.collection.objects.link(obj_collar)

# 5. Dragon Claws (4 prongs)
for i in range(4):
    ang = i * (math.pi / 2)
    mesh_c = bpy.data.meshes.new(f"Claw_{i}")
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=10, radius1=0.045, radius2=0.012, depth=0.75)
    # Rotate slightly outward and curl up
    bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(-18), 4, 'X'))
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0.22, 4.6))
    bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(ang, 4, 'Z'))
    bm.to_mesh(mesh_c)
    bm.free()
    obj_c = bpy.data.objects.new(f"Claw_{i}", mesh_c)
    obj_c.data.materials.append(mat_gold)
    bpy.context.collection.objects.link(obj_c)

# 6. Core Crystal (Faceted double cone)
mesh_gem = bpy.data.meshes.new("Core_Crystal")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=6, radius1=0.24, radius2=0.0, depth=0.38)
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 0.19))
bmesh.ops.create_cone(bm, cap_ends=True, segments=6, radius1=0.0, radius2=0.24, depth=0.38)
bmesh.ops.translate(bm, verts=bm.verts[-8:], vec=(0, 0, -0.19))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 4.65))
bm.to_mesh(mesh_gem)
bm.free()
obj_gem = bpy.data.objects.new("Core_Crystal", mesh_gem)
obj_gem.data.materials.append(mat_gem)
bpy.context.collection.objects.link(obj_gem)

# 7. Orbit Ring
mesh_ring = bpy.data.meshes.new("Orbit_Ring")
bm = bmesh.new()
bmesh.ops.create_cone(bm, cap_ends=True, segments=24, radius1=0.45, radius2=0.45, depth=0.035)
bmesh.ops.rotate(bm, verts=bm.verts, cent=(0,0,0), matrix=mathutils.Matrix.Rotation(math.radians(35), 4, 'X'))
bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, 4.65))
bm.to_mesh(mesh_ring)
bm.free()
obj_ring = bpy.data.objects.new("Orbit_Ring", mesh_ring)
obj_ring.data.materials.append(mat_ring)
bpy.context.collection.objects.link(obj_ring)

# Scene, Camera & Lighting
bpy.context.scene.render.resolution_x = 800
bpy.context.scene.render.resolution_y = 1000

world = bpy.context.scene.world or bpy.data.worlds.new("StaffWorld")
bpy.context.scene.world = world
world.use_nodes = True
bg = world.node_tree.nodes.get("Background")
if bg:
    bg.inputs['Color'].default_value = (0.03, 0.04, 0.06, 1.0)
    bg.inputs['Strength'].default_value = 0.5

cam_data = bpy.data.cameras.new("StaffCam")
cam_data.lens = 45
cam_obj = bpy.data.objects.new("StaffCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj
cam_obj.location = (0, -7.2, 2.6)
cam_obj.rotation_euler = (math.radians(90), 0, 0)

# Key Light
l1 = bpy.data.lights.new("KeyL", 'POINT')
l1.energy = 2600
l1.color = (1.0, 0.95, 0.88)
lo1 = bpy.data.objects.new("KeyL", l1)
lo1.location = (2.0, -3.5, 4.5)
bpy.context.collection.objects.link(lo1)

# Fill Light (Cyan)
l2 = bpy.data.lights.new("FillL", 'POINT')
l2.energy = 1600
l2.color = (0.2, 0.8, 1.0)
lo2 = bpy.data.objects.new("FillL", l2)
lo2.location = (-2.5, -2.5, 3.0)
bpy.context.collection.objects.link(lo2)

# Rim Light
l3 = bpy.data.lights.new("RimL", 'POINT')
l3.energy = 1800
l3.color = (1.0, 0.8, 0.4)
lo3 = bpy.data.objects.new("RimL", l3)
lo3.location = (0, 3.0, 3.5)
bpy.context.collection.objects.link(lo3)

preview_path = os.path.join(output_dir, "preview_baston_principal_hd.png")
bpy.context.scene.render.filepath = preview_path
bpy.ops.render.render(write_still=True)
print(f"[Blender] Render HD del Bastón guardado en: {preview_path}")
