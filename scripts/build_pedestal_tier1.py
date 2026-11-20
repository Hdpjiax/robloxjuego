import bpy
import bmesh
import mathutils
import math
import os

# Clean scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Helper function to create materials with viewport colors
def create_material(name, color, roughness=0.5, metallic=0.0, emission=None, emission_strength=1.0):
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

mat_stone_dark = create_material("M_Pedestal_StoneBase", (0.12, 0.14, 0.18, 1.0), roughness=0.85)
mat_stone_light = create_material("M_Pedestal_StoneTrim", (0.35, 0.38, 0.45, 1.0), roughness=0.7)
mat_rune_glow = create_material("M_Pedestal_RuneGlow", (0.0, 0.85, 1.0, 1.0), roughness=0.2, emission=(0.0, 0.85, 1.0, 1.0), emission_strength=6.0)
mat_crystal = create_material("M_Pedestal_Crystal", (0.1, 0.9, 1.0, 0.8), roughness=0.1, emission=(0.0, 0.8, 1.0, 1.0), emission_strength=4.0)

# Helper rotation matrix
def get_rotation_matrix_z(angle_rad):
    return mathutils.Matrix.Rotation(angle_rad, 3, 'Z')

# 1. Create Stepped Stone Base (Plataforma Escalonada)
def create_pedestal_base():
    bm = bmesh.new()
    
    # Bottom tier (Octagonal / 16-sided for stylized look)
    # Radius 2.1m, Height 0.35m
    bmesh.ops.create_cone(
        bm,
        cap_ends=True,
        cap_tris=False,
        segments=16,
        radius1=2.1,
        radius2=2.0, # slight bevel/taper upwards
        depth=0.35
    )
    for v in bm.verts:
        v.co.z += 0.175
        
    # Second tier (Inner dais)
    # Radius 1.75m, Height 0.25m, sitting on top of bottom tier (Z from 0.35 to 0.60)
    top_mesh = bmesh.new()
    bmesh.ops.create_cone(
        top_mesh,
        cap_ends=True,
        cap_tris=False,
        segments=16,
        radius1=1.8,
        radius2=1.72,
        depth=0.25
    )
    for v in top_mesh.verts:
        v.co.z += 0.35 + 0.125
        
    # Third tier (Center standing disc, Z from 0.60 to 0.68)
    center_mesh = bmesh.new()
    bmesh.ops.create_cone(
        center_mesh,
        cap_ends=True,
        cap_tris=False,
        segments=16,
        radius1=1.35,
        radius2=1.35,
        depth=0.08
    )
    for v in center_mesh.verts:
        v.co.z += 0.60 + 0.04
        
    # Combine into single mesh
    mesh = bpy.data.meshes.new("Pedestal_Base_Stone")
    
    base_bm = bmesh.new()
    # Add bottom
    for v in bm.verts:
        base_bm.verts.new(v.co)
    base_bm.verts.ensure_lookup_table()
    for f in bm.faces:
        base_bm.faces.new([base_bm.verts[v.index] for v in f.verts])
        
    # Add top
    v_offset = len(base_bm.verts)
    for v in top_mesh.verts:
        base_bm.verts.new(v.co)
    base_bm.verts.ensure_lookup_table()
    for f in top_mesh.faces:
        base_bm.faces.new([base_bm.verts[v.index + v_offset] for v in f.verts])
        
    # Add center
    v_offset2 = len(base_bm.verts)
    for v in center_mesh.verts:
        base_bm.verts.new(v.co)
    base_bm.verts.ensure_lookup_table()
    for f in center_mesh.faces:
        base_bm.faces.new([base_bm.verts[v.index + v_offset2] for v in f.verts])

    base_bm.to_mesh(mesh)
    base_bm.free()
    bm.free()
    top_mesh.free()
    center_mesh.free()
    
    obj = bpy.data.objects.new("Pedestal_Base_Stone", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_stone_dark)
    return obj

# 2. Create Rune Trim & Emblems (Para material Neon en Roblox)
def create_rune_trim():
    bm = bmesh.new()
    
    # Runic ring between radius 1.40 and 1.55, Z = 0.61
    segments = 24
    r_outer = 1.55
    r_inner = 1.40
    h = 0.04
    z_base = 0.60
    
    outer_verts = []
    inner_verts = []
    for i in range(segments):
        angle = (2 * math.pi * i) / segments
        ca = math.cos(angle)
        sa = math.sin(angle)
        # bottom ring
        v_bo = bm.verts.new((r_outer * ca, r_outer * sa, z_base))
        v_bi = bm.verts.new((r_inner * ca, r_inner * sa, z_base))
        # top ring
        v_to = bm.verts.new((r_outer * ca, r_outer * sa, z_base + h))
        v_ti = bm.verts.new((r_inner * ca, r_inner * sa, z_base + h))
        outer_verts.append((v_bo, v_to))
        inner_verts.append((v_bi, v_ti))
        
    bm.verts.ensure_lookup_table()
    
    # Connect faces (segmented runic band with subtle notches)
    for i in range(segments):
        # skip every 6th segment to create magical runic breaks/notches
        if i % 6 == 0:
            continue
        next_i = (i + 1) % segments
        
        v_bo1, v_to1 = outer_verts[i]
        v_bi1, v_ti1 = inner_verts[i]
        v_bo2, v_to2 = outer_verts[next_i]
        v_bi2, v_ti2 = inner_verts[next_i]
        
        # Top face
        bm.faces.new((v_ti1, v_to1, v_to2, v_ti2))
        # Outer face
        bm.faces.new((v_bo1, v_bo2, v_to2, v_to1))
        # Inner face
        bm.faces.new((v_bi2, v_bi1, v_ti1, v_ti2))
        # End caps for notches
        if (i - 1) % 6 == 0:
            bm.faces.new((v_bi1, v_bo1, v_to1, v_ti1))
        if (next_i + 1) % 6 == 0 or next_i % 6 == 0:
            bm.faces.new((v_bo2, v_bi2, v_ti2, v_to2))

    # Center 8-pointed Arcane Star Inlay
    star_r1 = 0.68
    star_r2 = 0.26
    star_pts = 8
    star_verts_top = []
    center_top = bm.verts.new((0, 0, z_base + h + 0.015))
    
    for i in range(star_pts * 2):
        angle = (math.pi * i) / star_pts
        r = star_r1 if i % 2 == 0 else star_r2
        x = r * math.cos(angle)
        y = r * math.sin(angle)
        star_verts_top.append(bm.verts.new((x, y, z_base + h + 0.015)))
        
    bm.verts.ensure_lookup_table()
    for i in range(len(star_verts_top)):
        next_i = (i + 1) % len(star_verts_top)
        bm.faces.new((center_top, star_verts_top[i], star_verts_top[next_i]))
        
    mesh = bpy.data.meshes.new("Pedestal_Rune_Glow")
    bm.to_mesh(mesh)
    bm.free()
    
    obj = bpy.data.objects.new("Pedestal_Rune_Glow", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_rune_glow)
    return obj

# 3. Create 4 Stylized Guardian Obelisks / Pillars
def create_pillars():
    pillars_bm = bmesh.new()
    
    angles = [45, 135, 225, 315]
    dist = 1.72
    pillar_height = 1.35
    base_z = 0.35
    
    for ang_deg in angles:
        rad = math.radians(ang_deg)
        cx = dist * math.cos(rad)
        cy = dist * math.sin(rad)
        rot = rad + math.pi/4 # face inward
        
        pbm = bmesh.new()
        
        # Pillar Pedestal Base
        bmesh.ops.create_cube(pbm, size=0.45)
        for v in pbm.verts:
            v.co.z = (v.co.z + 0.5) * 0.35 + base_z # z from 0.35 to 0.70
            
        # Pillar Shaft (Tapered obelisk)
        shaft_w_bottom = 0.32
        shaft_w_top = 0.18
        z1 = base_z + 0.32
        z2 = z1 + pillar_height
        
        # Bottom quad
        v0 = pbm.verts.new((-shaft_w_bottom/2, -shaft_w_bottom/2, z1))
        v1 = pbm.verts.new(( shaft_w_bottom/2, -shaft_w_bottom/2, z1))
        v2 = pbm.verts.new(( shaft_w_bottom/2,  shaft_w_bottom/2, z1))
        v3 = pbm.verts.new((-shaft_w_bottom/2,  shaft_w_bottom/2, z1))
        
        # Top quad
        v4 = pbm.verts.new((-shaft_w_top/2, -shaft_w_top/2, z2))
        v5 = pbm.verts.new(( shaft_w_top/2, -shaft_w_top/2, z2))
        v6 = pbm.verts.new(( shaft_w_top/2,  shaft_w_top/2, z2))
        v7 = pbm.verts.new((-shaft_w_top/2,  shaft_w_top/2, z2))
        
        # Apex tip point
        apex = pbm.verts.new((0, 0, z2 + 0.22))
        
        # Faces for shaft
        pbm.faces.new((v0, v1, v5, v4))
        pbm.faces.new((v1, v2, v6, v5))
        pbm.faces.new((v2, v3, v7, v6))
        pbm.faces.new((v3, v0, v4, v7))
        
        # Pyramid cap faces
        pbm.faces.new((v4, v5, apex))
        pbm.faces.new((v5, v6, apex))
        pbm.faces.new((v6, v7, apex))
        pbm.faces.new((v7, v4, apex))
        
        # Rotate pillar to point towards center and translate to position
        bmesh.ops.rotate(
            pbm,
            verts=pbm.verts,
            cent=(0, 0, 0),
            matrix=get_rotation_matrix_z(rot)
        )
        bmesh.ops.translate(
            pbm,
            verts=pbm.verts,
            vec=(cx, cy, 0)
        )
        
        # Append to main pillars bmesh
        v_offset = len(pillars_bm.verts)
        for v in pbm.verts:
            pillars_bm.verts.new(v.co)
        pillars_bm.verts.ensure_lookup_table()
        for f in pbm.faces:
            pillars_bm.faces.new([pillars_bm.verts[v.index + v_offset] for v in f.verts])
        pbm.free()

    mesh = bpy.data.meshes.new("Pedestal_Pillars_Stone")
    pillars_bm.to_mesh(mesh)
    pillars_bm.free()
    
    obj = bpy.data.objects.new("Pedestal_Pillars_Stone", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_stone_light)
    return obj

# 4. Floating Focus Crystal in the center or above pillars
def create_floating_crystals():
    cbm = bmesh.new()
    
    angles = [45, 135, 225, 315]
    dist = 1.72
    crystal_z = 0.35 + 1.35 + 0.38 # floating slightly above pillar apex
    
    for ang_deg in angles:
        rad = math.radians(ang_deg)
        cx = dist * math.cos(rad)
        cy = dist * math.sin(rad)
        
        # Diamond / Octahedron crystal
        p_top = cbm.verts.new((cx, cy, crystal_z + 0.18))
        p_bot = cbm.verts.new((cx, cy, crystal_z - 0.18))
        
        cr = 0.09
        p0 = cbm.verts.new((cx + cr, cy, crystal_z))
        p1 = cbm.verts.new((cx, cy + cr, crystal_z))
        p2 = cbm.verts.new((cx - cr, cy, crystal_z))
        p3 = cbm.verts.new((cx, cy - cr, crystal_z))
        
        cbm.faces.new((p_top, p0, p1))
        cbm.faces.new((p_top, p1, p2))
        cbm.faces.new((p_top, p2, p3))
        cbm.faces.new((p_top, p3, p0))
        
        cbm.faces.new((p_bot, p1, p0))
        cbm.faces.new((p_bot, p2, p1))
        cbm.faces.new((p_bot, p3, p2))
        cbm.faces.new((p_bot, p0, p3))
        
    mesh = bpy.data.meshes.new("Pedestal_Floating_Crystals")
    cbm.to_mesh(mesh)
    cbm.free()
    
    obj = bpy.data.objects.new("Pedestal_Floating_Crystals", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_crystal)
    return obj

# Build components
base_obj = create_pedestal_base()
rune_obj = create_rune_trim()
pillars_obj = create_pillars()
crystals_obj = create_floating_crystals()

# Smooth shading
for obj in [base_obj, rune_obj, pillars_obj, crystals_obj]:
    for poly in obj.data.polygons:
        poly.use_smooth = True

# Count total polygons & tris
total_faces = 0
total_tris = 0
print("=== GEOMETRY OPTIMIZATION REPORT ===")
for obj in [base_obj, rune_obj, pillars_obj, crystals_obj]:
    tris = sum(len(f.vertices) - 2 for f in obj.data.polygons)
    faces = len(obj.data.polygons)
    total_faces += faces
    total_tris += tris
    print(f"Part: {obj.name:30} | Faces: {faces:4} | Tris: {tris:4}")

print(f"-------------------------------------------------------")
print(f"TOTAL POLYGONS (Faces): {total_faces} | TOTAL TRIANGLES: {total_tris}")
print("====================================")

# Output paths
output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\pedestals"
os.makedirs(output_dir, exist_ok=True)

fbx_modular_path = os.path.join(output_dir, "Pedestal_Tier1_Modular.fbx")
obj_path = os.path.join(output_dir, "Pedestal_Tier1_Modular.obj")

# Deselect all, then select modular parts
bpy.ops.object.select_all(action='DESELECT')
for obj in [base_obj, rune_obj, pillars_obj, crystals_obj]:
    obj.select_set(True)

# Export Modular FBX
bpy.ops.export_scene.fbx(
    filepath=fbx_modular_path,
    use_selection=True,
    global_scale=1.0,
    axis_forward='-Z',
    axis_up='Y',
    apply_scale_options='FBX_SCALE_ALL'
)
print(f"SUCCESS: Exported Modular FBX -> {fbx_modular_path}")

# Export OBJ
try:
    bpy.ops.wm.obj_export(filepath=obj_path)
    print(f"SUCCESS: Exported OBJ -> {obj_path}")
except Exception as e:
    print(f"OBJ export note: {e}")

# Also create merged single-mesh version
bpy.ops.object.select_all(action='DESELECT')
for obj in [base_obj, rune_obj, pillars_obj, crystals_obj]:
    obj.select_set(True)
bpy.context.view_layer.objects.active = base_obj
bpy.ops.object.duplicate()
merged_objs = [o for o in bpy.context.selected_objects]
bpy.context.view_layer.objects.active = merged_objs[0]
bpy.ops.object.join()
merged_obj = bpy.context.active_object
merged_obj.name = "Pedestal_Tier1_Combined"

fbx_merged_path = os.path.join(output_dir, "Pedestal_Tier1_Combined.fbx")
bpy.ops.object.select_all(action='DESELECT')
merged_obj.select_set(True)
bpy.ops.export_scene.fbx(
    filepath=fbx_merged_path,
    use_selection=True,
    global_scale=1.0,
    axis_forward='-Z',
    axis_up='Y',
    apply_scale_options='FBX_SCALE_ALL'
)
print(f"SUCCESS: Exported Combined FBX -> {fbx_merged_path}")
