import bpy
import bmesh
import mathutils
import math
import os

# Clean scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Helper function to create materials with viewport colors and emissions
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

mat_stone_dark = create_material("M_Sanctum_StoneDark", (0.08, 0.09, 0.12, 1.0), roughness=0.85)
mat_stone_trim = create_material("M_Sanctum_StoneTrim", (0.28, 0.32, 0.40, 1.0), roughness=0.65)
mat_rune_neon = create_material("M_Sanctum_RuneNeon", (0.0, 0.9, 1.0, 1.0), roughness=0.1, emission=(0.0, 0.9, 1.0, 1.0), emission_strength=8.0)
mat_crystal_glow = create_material("M_Sanctum_CrystalGlow", (0.2, 0.95, 1.0, 0.9), roughness=0.05, emission=(0.1, 0.9, 1.0, 1.0), emission_strength=6.0)

def get_rotation_matrix_z(angle_rad):
    return mathutils.Matrix.Rotation(angle_rad, 3, 'Z')

# 1. Broad Stepped Sanctum Dais (Capacidad multijugador masiva: 32 studs / 9m diámetro)
def create_sanctum_base():
    bm = bmesh.new()
    
    # Outer Step 1: Radius 4.6m (~32 studs), height 0.22m (fácil acceso para caminar)
    bmesh.ops.create_cone(
        bm,
        cap_ends=True,
        cap_tris=False,
        segments=24,
        radius1=4.6,
        radius2=4.45,
        depth=0.22
    )
    for v in bm.verts:
        v.co.z += 0.11
        
    # Middle Step 2: Radius 3.9m, height 0.18m (Z from 0.22 to 0.40)
    step2_bm = bmesh.new()
    bmesh.ops.create_cone(
        step2_bm,
        cap_ends=True,
        cap_tris=False,
        segments=24,
        radius1=4.0,
        radius2=3.85,
        depth=0.18
    )
    for v in step2_bm.verts:
        v.co.z += 0.22 + 0.09
        
    # Main Inner Training Floor: Radius 3.3m (Z from 0.40 to 0.48)
    floor_bm = bmesh.new()
    bmesh.ops.create_cone(
        floor_bm,
        cap_ends=True,
        cap_tris=False,
        segments=24,
        radius1=3.4,
        radius2=3.35,
        depth=0.08
    )
    for v in floor_bm.verts:
        v.co.z += 0.40 + 0.04
        
    # Merge all stepped platforms into base_bm
    base_bm = bmesh.new()
    for v in bm.verts:
        base_bm.verts.new(v.co)
    base_bm.verts.ensure_lookup_table()
    for f in bm.faces:
        base_bm.faces.new([base_bm.verts[v.index] for v in f.verts])
        
    v_off1 = len(base_bm.verts)
    for v in step2_bm.verts:
        base_bm.verts.new(v.co)
    base_bm.verts.ensure_lookup_table()
    for f in step2_bm.faces:
        base_bm.faces.new([base_bm.verts[v.index + v_off1] for v in f.verts])
        
    v_off2 = len(base_bm.verts)
    for v in floor_bm.verts:
        base_bm.verts.new(v.co)
    base_bm.verts.ensure_lookup_table()
    for f in floor_bm.faces:
        base_bm.faces.new([base_bm.verts[v.index + v_off2] for v in f.verts])

    mesh = bpy.data.meshes.new("Sanctum_Base_Stone")
    base_bm.to_mesh(mesh)
    
    base_bm.free()
    bm.free()
    step2_bm.free()
    floor_bm.free()
    
    obj = bpy.data.objects.new("Sanctum_Base_Stone", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_stone_dark)
    return obj

# 2. Intricate Arcane Sacred Geometry & Runic Floor Inlay (Para Roblox Neon)
def create_runic_floor():
    bm = bmesh.new()
    z_floor = 0.485 # slightly above stone floor
    h = 0.03
    
    # Helper to generate a flat concentric ring band
    def add_ring_band(b_mesh, r_in, r_out, segs, pattern_skip=0):
        outer_pts = []
        inner_pts = []
        for i in range(segs):
            angle = (2 * math.pi * i) / segs
            ca = math.cos(angle)
            sa = math.sin(angle)
            v_bo = b_mesh.verts.new((r_out * ca, r_out * sa, z_floor))
            v_bi = b_mesh.verts.new((r_in  * ca, r_in  * sa, z_floor))
            v_to = b_mesh.verts.new((r_out * ca, r_out * sa, z_floor + h))
            v_ti = b_mesh.verts.new((r_in  * ca, r_in  * sa, z_floor + h))
            outer_pts.append((v_bo, v_to))
            inner_pts.append((v_bi, v_ti))
            
        b_mesh.verts.ensure_lookup_table()
        for i in range(segs):
            if pattern_skip > 0 and (i % pattern_skip == 0):
                continue
            next_i = (i + 1) % segs
            v_bo1, v_to1 = outer_pts[i]
            v_bi1, v_ti1 = inner_pts[i]
            v_bo2, v_to2 = outer_pts[next_i]
            v_bi2, v_ti2 = inner_pts[next_i]
            
            b_mesh.faces.new((v_ti1, v_to1, v_to2, v_ti2)) # Top
            b_mesh.faces.new((v_bo1, v_bo2, v_to2, v_to1)) # Outer
            b_mesh.faces.new((v_bi2, v_bi1, v_ti1, v_ti2)) # Inner
            
            if pattern_skip > 0:
                if (i - 1) % pattern_skip == 0:
                    b_mesh.faces.new((v_bi1, v_bo1, v_to1, v_ti1))
                if (next_i + 1) % pattern_skip == 0 or next_i % pattern_skip == 0:
                    b_mesh.faces.new((v_bo2, v_bi2, v_ti2, v_to2))

    # Outer Arcane Runic Ring with 24 glyph segments and 6 magical break gaps
    add_ring_band(bm, r_in=3.10, r_out=3.26, segs=36, pattern_skip=6)
    
    # Middle Celestial Concentric Band
    add_ring_band(bm, r_in=2.40, r_out=2.48, segs=32, pattern_skip=0)
    add_ring_band(bm, r_in=1.75, r_out=1.83, segs=28, pattern_skip=0)
    
    # 12 Radiating Runic Rays connecting outer and inner circles
    num_rays = 12
    ray_w = 0.05
    for i in range(num_rays):
        angle = (2 * math.pi * i) / num_rays
        ca = math.cos(angle)
        sa = math.sin(angle)
        perp_x = -sa * (ray_w / 2)
        perp_y =  ca * (ray_w / 2)
        
        r1 = 1.83
        r2 = 2.40
        p1 = bm.verts.new((r1 * ca + perp_x, r1 * sa + perp_y, z_floor + h))
        p2 = bm.verts.new((r2 * ca + perp_x, r2 * sa + perp_y, z_floor + h))
        p3 = bm.verts.new((r2 * ca - perp_x, r2 * sa - perp_y, z_floor + h))
        p4 = bm.verts.new((r1 * ca - perp_x, r1 * sa - perp_y, z_floor + h))
        bm.faces.new((p1, p2, p3, p4))

    # Central Sacred Geometry 12-pointed Arcane Seal
    center_top = bm.verts.new((0, 0, z_floor + h + 0.01))
    pts_12 = []
    r_star_outer = 1.25
    r_star_inner = 0.45
    for i in range(24):
        angle = (2 * math.pi * i) / 24
        r = r_star_outer if i % 2 == 0 else r_star_inner
        x = r * math.cos(angle)
        y = r * math.sin(angle)
        pts_12.append(bm.verts.new((x, y, z_floor + h + 0.005)))
        
    bm.verts.ensure_lookup_table()
    for i in range(len(pts_12)):
        next_i = (i + 1) % len(pts_12)
        bm.faces.new((center_top, pts_12[i], pts_12[next_i]))

    mesh = bpy.data.meshes.new("Sanctum_Rune_Glow")
    bm.to_mesh(mesh)
    bm.free()
    
    obj = bpy.data.objects.new("Sanctum_Rune_Glow", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_rune_neon)
    return obj

# 3. 6 Outer Perimeter Levitation Monoliths (Sin estorbar el centro para los jugadores)
def create_perimeter_monoliths():
    pbm = bmesh.new()
    
    # 6 Monoliths symmetrically around perimeter at radius 4.15m (en el escalón exterior)
    num_monoliths = 6
    radius = 4.15
    base_z = 0.22
    
    for i in range(num_monoliths):
        angle_rad = (2 * math.pi * i) / num_monoliths
        cx = radius * math.cos(angle_rad)
        cy = radius * math.sin(angle_rad)
        rot = angle_rad + math.pi/2 # Oriented facing the center!
        
        mono_bm = bmesh.new()
        
        # Lower Stone Pedestal socket (Beveled base)
        bmesh.ops.create_cone(
            mono_bm,
            cap_ends=True,
            cap_tris=False,
            segments=6,
            radius1=0.42,
            radius2=0.35,
            depth=0.45
        )
        for v in mono_bm.verts:
            v.co.z += 0.225 + base_z
            
        # Floating Upper Monolith (Levita encima del pedestal socket)
        # Ancient runic split shard
        float_gap = 0.15
        mono_h = 1.70
        z_start = base_z + 0.45 + float_gap
        
        # Hexagonal tapered floating shard
        bmesh.ops.create_cone(
            mono_bm,
            cap_ends=True,
            cap_tris=False,
            segments=6,
            radius1=0.28,
            radius2=0.12,
            depth=mono_h
        )
        for v in mono_bm.verts[-14:]: # the newly created shard vertices
            v.co.z += (mono_h / 2) + z_start
            
        # Rotate and translate
        bmesh.ops.rotate(
            mono_bm,
            verts=mono_bm.verts,
            cent=(0, 0, 0),
            matrix=get_rotation_matrix_z(rot)
        )
        bmesh.ops.translate(
            mono_bm,
            verts=mono_bm.verts,
            vec=(cx, cy, 0)
        )
        
        # Append to main
        v_offset = len(pbm.verts)
        for v in mono_bm.verts:
            pbm.verts.new(v.co)
        pbm.verts.ensure_lookup_table()
        for f in mono_bm.faces:
            pbm.faces.new([pbm.verts[v.index + v_offset] for v in f.verts])
        mono_bm.free()

    mesh = bpy.data.meshes.new("Sanctum_Perimeter_Monoliths")
    pbm.to_mesh(mesh)
    pbm.free()
    
    obj = bpy.data.objects.new("Sanctum_Perimeter_Monoliths", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_stone_trim)
    return obj

# 4. Floating Crystals (6 en los monolitos + 1 Núcleo Cósmico Arcano Elevado en el cielo)
def create_floating_nexus_crystals():
    cbm = bmesh.new()
    
    # 6 Crystals floating between socket and shard of each monolith
    num_monoliths = 6
    radius = 4.15
    crystal_z = 0.22 + 0.45 + 0.08
    
    for i in range(num_monoliths):
        angle_rad = (2 * math.pi * i) / num_monoliths
        cx = radius * math.cos(angle_rad)
        cy = radius * math.sin(angle_rad)
        
        # Octahedron floating focus crystal
        p_top = cbm.verts.new((cx, cy, crystal_z + 0.22))
        p_bot = cbm.verts.new((cx, cy, crystal_z - 0.22))
        cr = 0.12
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

    # Grand Floating Arcane Spire Core (Flotando a 3.8m sobre el centro, sin tocar a los jugadores)
    core_z = 3.60
    core_top = cbm.verts.new((0, 0, core_z + 0.70))
    core_bot = cbm.verts.new((0, 0, core_z - 0.70))
    core_r = 0.38
    
    core_equator = []
    for i in range(8):
        ang = (2 * math.pi * i) / 8
        ex = core_r * math.cos(ang)
        ey = core_r * math.sin(ang)
        core_equator.append(cbm.verts.new((ex, ey, core_z)))
        
    cbm.verts.ensure_lookup_table()
    for i in range(8):
        next_i = (i + 1) % 8
        cbm.faces.new((core_top, core_equator[i], core_equator[next_i]))
        cbm.faces.new((core_bot, core_equator[next_i], core_equator[i]))

    # Orbital Magic Ring around the Floating Core
    orbit_r_out = 0.72
    orbit_r_in  = 0.65
    orbit_h = 0.04
    for i in range(16):
        a1 = (2 * math.pi * i) / 16
        a2 = (2 * math.pi * (i + 1)) / 16
        # Slight tilt of orbital ring for high-fantasy wizard look
        tilt = 0.15
        
        v1 = cbm.verts.new((orbit_r_out * math.cos(a1), orbit_r_out * math.sin(a1), core_z + tilt * math.sin(a1)))
        v2 = cbm.verts.new((orbit_r_out * math.cos(a2), orbit_r_out * math.sin(a2), core_z + tilt * math.sin(a2)))
        v3 = cbm.verts.new((orbit_r_in  * math.cos(a2), orbit_r_in  * math.sin(a2), core_z + tilt * math.sin(a2)))
        v4 = cbm.verts.new((orbit_r_in  * math.cos(a1), orbit_r_in  * math.sin(a1), core_z + tilt * math.sin(a1)))
        cbm.faces.new((v1, v2, v3, v4))

    mesh = bpy.data.meshes.new("Sanctum_Floating_Nexus")
    cbm.to_mesh(mesh)
    cbm.free()
    
    obj = bpy.data.objects.new("Sanctum_Floating_Nexus", mesh)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat_crystal_glow)
    return obj

# 5. Build and Assemble
base_obj = create_sanctum_base()
rune_obj = create_runic_floor()
monoliths_obj = create_perimeter_monoliths()
nexus_obj = create_floating_nexus_crystals()

# Smooth shading
for obj in [base_obj, rune_obj, monoliths_obj, nexus_obj]:
    for poly in obj.data.polygons:
        poly.use_smooth = True

# Geometry Metrics
total_faces = 0
total_tris = 0
print("=== GRAND SANCTUM GEOMETRY REPORT ===")
for obj in [base_obj, rune_obj, monoliths_obj, nexus_obj]:
    tris = sum(len(f.vertices) - 2 for f in obj.data.polygons)
    faces = len(obj.data.polygons)
    total_faces += faces
    total_tris += tris
    print(f"Part: {obj.name:32} | Faces: {faces:4} | Tris: {tris:4}")

print(f"-----------------------------------------------------------------")
print(f"TOTAL POLYGONS (Faces): {total_faces} | TOTAL TRIANGLES: {total_tris}")
print("=====================================")

# Export Paths
output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\pedestals"
os.makedirs(output_dir, exist_ok=True)

fbx_modular_path = os.path.join(output_dir, "Sanctum_Grand_Tier1_Modular.fbx")
obj_path = os.path.join(output_dir, "Sanctum_Grand_Tier1_Modular.obj")

# Export Modular FBX
bpy.ops.object.select_all(action='DESELECT')
for obj in [base_obj, rune_obj, monoliths_obj, nexus_obj]:
    obj.select_set(True)

bpy.ops.export_scene.fbx(
    filepath=fbx_modular_path,
    use_selection=True,
    global_scale=1.0,
    axis_forward='-Z',
    axis_up='Y',
    apply_scale_options='FBX_SCALE_ALL'
)
print(f"SUCCESS: Exported Modular FBX -> {fbx_modular_path}")

try:
    bpy.ops.wm.obj_export(filepath=obj_path)
    print(f"SUCCESS: Exported OBJ -> {obj_path}")
except Exception as e:
    print(f"OBJ Note: {e}")

# Merged version
bpy.ops.object.select_all(action='DESELECT')
for obj in [base_obj, rune_obj, monoliths_obj, nexus_obj]:
    obj.select_set(True)
bpy.context.view_layer.objects.active = base_obj
bpy.ops.object.duplicate()
merged_objs = [o for o in bpy.context.selected_objects]
bpy.context.view_layer.objects.active = merged_objs[0]
bpy.ops.object.join()
merged_obj = bpy.context.active_object
merged_obj.name = "Sanctum_Grand_Tier1_Combined"

fbx_merged_path = os.path.join(output_dir, "Sanctum_Grand_Tier1_Combined.fbx")
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
