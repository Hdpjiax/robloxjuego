import bpy
import bmesh
import mathutils
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\pedestals"
os.makedirs(output_dir, exist_ok=True)

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

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

def get_rotation_matrix_z(angle_rad):
    return mathutils.Matrix.Rotation(angle_rad, 3, 'Z')

def export_model(tier_num, tier_name, objects):
    # Smooth all
    for obj in objects:
        for p in obj.data.polygons:
            p.use_smooth = True
            
    # Count tris
    total_tris = sum(sum(len(f.vertices)-2 for f in o.data.polygons) for o in objects)
    print(f"[{tier_name.upper()}] Total Tris: {total_tris}")
    
    # Export Modular FBX
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:
        obj.select_set(True)
        
    fbx_path = os.path.join(output_dir, f"Sanctum_Tier{tier_num}_{tier_name}_Modular.fbx")
    bpy.ops.export_scene.fbx(
        filepath=fbx_path,
        use_selection=True,
        global_scale=1.0,
        axis_forward='-Z',
        axis_up='Y',
        apply_scale_options='FBX_SCALE_ALL'
    )
    print(f"Exported: {fbx_path}")
    
    # Export Combined FBX
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.duplicate()
    dupes = [o for o in bpy.context.selected_objects]
    bpy.context.view_layer.objects.active = dupes[0]
    bpy.ops.object.join()
    merged = bpy.context.active_object
    merged.name = f"Sanctum_Tier{tier_num}_{tier_name}_Combined"
    
    fbx_comb_path = os.path.join(output_dir, f"Sanctum_Tier{tier_num}_{tier_name}_Combined.fbx")
    bpy.ops.object.select_all(action='DESELECT')
    merged.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=fbx_comb_path,
        use_selection=True,
        global_scale=1.0,
        axis_forward='-Z',
        axis_up='Y',
        apply_scale_options='FBX_SCALE_ALL'
    )
    bpy.data.objects.remove(merged, do_unlink=True)

# ==============================================================================
# TIER 2: AMATISTA (Cristales y Geodas Púrpuras)
# ==============================================================================
def build_tier2_amatista():
    clean_scene()
    mat_stone = create_material("M_Amatista_Stone", (0.10, 0.08, 0.14, 1.0), roughness=0.8)
    mat_trim = create_material("M_Amatista_Trim", (0.22, 0.16, 0.30, 1.0), roughness=0.6)
    mat_neon = create_material("M_Amatista_Neon", (0.75, 0.35, 1.0, 1.0), roughness=0.1, emission=(0.75, 0.35, 1.0, 1.0), emission_strength=7.0)
    mat_crystal = create_material("M_Amatista_Crystal", (0.85, 0.45, 1.0, 0.9), roughness=0.05, emission=(0.85, 0.45, 1.0, 1.0), emission_strength=5.0)

    # Base: Octagonal stepped crystal dais
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=16, radius1=4.6, radius2=4.4, depth=0.22)
    for v in bm.verts: v.co.z += 0.11
    s2 = bmesh.new()
    bmesh.ops.create_cone(s2, cap_ends=True, segments=16, radius1=3.9, radius2=3.8, depth=0.18)
    for v in s2.verts: v.co.z += 0.22 + 0.09
    s3 = bmesh.new()
    bmesh.ops.create_cone(s3, cap_ends=True, segments=16, radius1=3.35, radius2=3.3, depth=0.08)
    for v in s3.verts: v.co.z += 0.40 + 0.04
    
    # Merge base
    base_bm = bmesh.new()
    for mesh_b in [bm, s2, s3]:
        off = len(base_bm.verts)
        for v in mesh_b.verts: base_bm.verts.new(v.co)
        base_bm.verts.ensure_lookup_table()
        for f in mesh_b.faces: base_bm.faces.new([base_bm.verts[v.index + off] for v in f.verts])
        mesh_b.free()
    m_base = bpy.data.meshes.new("Sanctum_T2_Base")
    base_bm.to_mesh(m_base); base_bm.free()
    o_base = bpy.data.objects.new("Sanctum_T2_Base", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # Rune Floor: Hexagonal Crystal Lattice
    rbm = bmesh.new()
    z_f = 0.485; h = 0.03
    # Double faceted hexagonal rings
    for r1, r2, seg in [(3.1, 3.25, 24), (2.3, 2.4, 18), (1.6, 1.7, 12)]:
        for i in range(seg):
            a1 = (2*math.pi*i)/seg; a2 = (2*math.pi*(i+1))/seg
            v1 = rbm.verts.new((r2*math.cos(a1), r2*math.sin(a1), z_f+h))
            v2 = rbm.verts.new((r2*math.cos(a2), r2*math.sin(a2), z_f+h))
            v3 = rbm.verts.new((r1*math.cos(a2), r1*math.sin(a2), z_f+h))
            v4 = rbm.verts.new((r1*math.cos(a1), r1*math.sin(a1), z_f+h))
            rbm.faces.new((v1, v2, v3, v4))
    # Center geode star
    c_top = rbm.verts.new((0, 0, z_f+h+0.01))
    star_pts = []
    for i in range(16):
        ang = (2*math.pi*i)/16
        r = 1.1 if i%2==0 else 0.45
        star_pts.append(rbm.verts.new((r*math.cos(ang), r*math.sin(ang), z_f+h+0.005)))
    rbm.verts.ensure_lookup_table()
    for i in range(16):
        rbm.faces.new((c_top, star_pts[i], star_pts[(i+1)%16]))
    m_rune = bpy.data.meshes.new("Sanctum_T2_Rune")
    rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Sanctum_T2_Rune", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_neon)

    # Monoliths: 6 Sharp Amethyst Obelisks
    pbm = bmesh.new()
    for i in range(6):
        ang = (2*math.pi*i)/6
        cx = 4.15 * math.cos(ang); cy = 4.15 * math.sin(ang)
        # Crystal cluster base
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=6, radius1=0.38, radius2=0.28, depth=0.5)
        for v in pbm.verts[-14:]:
            v.co.z += 0.22 + 0.25; v.co.x += cx; v.co.y += cy
        # Floating sharp crystal shard
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=5, radius1=0.25, radius2=0.08, depth=1.8)
        for v in pbm.verts[-12:]:
            v.co.z += 0.22 + 0.5 + 0.2 + 0.9; v.co.x += cx; v.co.y += cy
    m_pillars = bpy.data.meshes.new("Sanctum_T2_Pillars")
    pbm.to_mesh(m_pillars); pbm.free()
    o_pillars = bpy.data.objects.new("Sanctum_T2_Pillars", m_pillars)
    bpy.context.collection.objects.link(o_pillars); o_pillars.data.materials.append(mat_trim)

    # Floating Nexus: Massive Amethyst Geode Cluster (Center high 3.6m)
    cbm = bmesh.new()
    cz = 3.6
    # Central crystal
    top = cbm.verts.new((0, 0, cz + 0.85)); bot = cbm.verts.new((0, 0, cz - 0.85))
    eq = [cbm.verts.new((0.35*math.cos(2*math.pi*i/6), 0.35*math.sin(2*math.pi*i/6), cz)) for i in range(6)]
    cbm.verts.ensure_lookup_table()
    for i in range(6):
        cbm.faces.new((top, eq[i], eq[(i+1)%6]))
        cbm.faces.new((bot, eq[(i+1)%6], eq[i]))
    # 4 orbiting smaller satellite crystals
    for j in range(4):
        jang = (2*math.pi*j)/4
        jx = 0.75*math.cos(jang); jy = 0.75*math.sin(jang)
        j_top = cbm.verts.new((jx, jy, cz + 0.35)); j_bot = cbm.verts.new((jx, jy, cz - 0.35))
        j_eq = [cbm.verts.new((jx + 0.12*math.cos(2*math.pi*k/4), jy + 0.12*math.sin(2*math.pi*k/4), cz)) for k in range(4)]
        cbm.verts.ensure_lookup_table()
        for k in range(4):
            cbm.faces.new((j_top, j_eq[k], j_eq[(k+1)%4]))
            cbm.faces.new((j_bot, j_eq[(k+1)%4], j_eq[k]))
    m_nexus = bpy.data.meshes.new("Sanctum_T2_Nexus")
    cbm.to_mesh(m_nexus); cbm.free()
    o_nexus = bpy.data.objects.new("Sanctum_T2_Nexus", m_nexus)
    bpy.context.collection.objects.link(o_nexus); o_nexus.data.materials.append(mat_crystal)

    export_model(2, "Amatista", [o_base, o_rune, o_pillars, o_nexus])

# ==============================================================================
# TIER 3: ESMERALDA (Jade Ancestral & Naturaleza Mística)
# ==============================================================================
def build_tier3_esmeralda():
    clean_scene()
    mat_stone = create_material("M_Esmeralda_Stone", (0.07, 0.14, 0.10, 1.0), roughness=0.8)
    mat_trim = create_material("M_Esmeralda_Trim", (0.15, 0.28, 0.20, 1.0), roughness=0.55)
    mat_neon = create_material("M_Esmeralda_Neon", (0.0, 0.98, 0.55, 1.0), roughness=0.1, emission=(0.0, 0.98, 0.55, 1.0), emission_strength=7.5)
    mat_crystal = create_material("M_Esmeralda_Crystal", (0.2, 1.0, 0.6, 0.9), roughness=0.05, emission=(0.1, 0.9, 0.5, 1.0), emission_strength=5.5)

    # Base: 12-sided pagoda terraced stone dais
    base_bm = bmesh.new()
    for rad, dep, z_off in [(4.6, 0.22, 0.11), (3.9, 0.18, 0.31), (3.35, 0.08, 0.44)]:
        t = bmesh.new()
        bmesh.ops.create_cone(t, cap_ends=True, segments=20, radius1=rad, radius2=rad*0.97, depth=dep)
        for v in t.verts: v.co.z += z_off
        off = len(base_bm.verts)
        for v in t.verts: base_bm.verts.new(v.co)
        base_bm.verts.ensure_lookup_table()
        for f in t.faces: base_bm.faces.new([base_bm.verts[v.index + off] for v in f.verts])
        t.free()
    m_base = bpy.data.meshes.new("Sanctum_T3_Base"); base_bm.to_mesh(m_base); base_bm.free()
    o_base = bpy.data.objects.new("Sanctum_T3_Base", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # Rune Floor: Mystical Lotus Mandala
    rbm = bmesh.new()
    z_f = 0.485; h = 0.03
    for rad1, rad2, seg in [(3.05, 3.20, 32), (2.25, 2.35, 24), (1.65, 1.75, 16)]:
        for i in range(seg):
            a1 = (2*math.pi*i)/seg; a2 = (2*math.pi*(i+1))/seg
            rbm.faces.new((
                rbm.verts.new((rad2*math.cos(a1), rad2*math.sin(a1), z_f+h)),
                rbm.verts.new((rad2*math.cos(a2), rad2*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a2), rad1*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a1), rad1*math.sin(a1), z_f+h))
            ))
    # 8-petal Lotus Center
    c_top = rbm.verts.new((0, 0, z_f+h+0.01))
    petals = []
    for i in range(16):
        ang = (2*math.pi*i)/16
        r = 1.25 if i%2==0 else 0.55
        petals.append(rbm.verts.new((r*math.cos(ang), r*math.sin(ang), z_f+h+0.005)))
    rbm.verts.ensure_lookup_table()
    for i in range(16):
        rbm.faces.new((c_top, petals[i], petals[(i+1)%16]))
    m_rune = bpy.data.meshes.new("Sanctum_T3_Rune"); rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Sanctum_T3_Rune", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_neon)

    # Monoliths: 6 Ancient Jade Shrine Pillars
    pbm = bmesh.new()
    for i in range(6):
        ang = (2*math.pi*i)/6
        cx = 4.15 * math.cos(ang); cy = 4.15 * math.sin(ang)
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=8, radius1=0.40, radius2=0.32, depth=0.5)
        for v in pbm.verts[-18:]: v.co.z += 0.47; v.co.x += cx; v.co.y += cy
        # Jade Pillar Shaft
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=8, radius1=0.26, radius2=0.22, depth=1.6)
        for v in pbm.verts[-18:]: v.co.z += 0.72 + 0.8; v.co.x += cx; v.co.y += cy
        # Capstone Pagoda Bevel
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=8, radius1=0.36, radius2=0.08, depth=0.35)
        for v in pbm.verts[-18:]: v.co.z += 0.72 + 1.6 + 0.175; v.co.x += cx; v.co.y += cy
    m_pillars = bpy.data.meshes.new("Sanctum_T3_Pillars"); pbm.to_mesh(m_pillars); pbm.free()
    o_pillars = bpy.data.objects.new("Sanctum_T3_Pillars", m_pillars)
    bpy.context.collection.objects.link(o_pillars); o_pillars.data.materials.append(mat_trim)

    # Floating Nexus: Levitating Jade Arcane Orb with Lotus Cradle
    cbm = bmesh.new()
    cz = 3.65
    top = cbm.verts.new((0, 0, cz + 0.55)); bot = cbm.verts.new((0, 0, cz - 0.55))
    eq = [cbm.verts.new((0.45*math.cos(2*math.pi*k/10), 0.45*math.sin(2*math.pi*k/10), cz)) for k in range(10)]
    cbm.verts.ensure_lookup_table()
    for k in range(10):
        cbm.faces.new((top, eq[k], eq[(k+1)%10]))
        cbm.faces.new((bot, eq[(k+1)%10], eq[k]))
    # Dual Lotus Orbit Rings
    for tilt, r_o, r_i in [(0.12, 0.78, 0.70), (-0.12, 0.90, 0.82)]:
        for k in range(16):
            a1 = (2*math.pi*k)/16; a2 = (2*math.pi*(k+1))/16
            cbm.faces.new((
                cbm.verts.new((r_o*math.cos(a1), r_o*math.sin(a1), cz + tilt*math.sin(a1))),
                cbm.verts.new((r_o*math.cos(a2), r_o*math.sin(a2), cz + tilt*math.sin(a2))),
                cbm.verts.new((r_i*math.cos(a2), r_i*math.sin(a2), cz + tilt*math.sin(a2))),
                cbm.verts.new((r_i*math.cos(a1), r_i*math.sin(a1), cz + tilt*math.sin(a1)))
            ))
    m_nexus = bpy.data.meshes.new("Sanctum_T3_Nexus"); cbm.to_mesh(m_nexus); cbm.free()
    o_nexus = bpy.data.objects.new("Sanctum_T3_Nexus", m_nexus)
    bpy.context.collection.objects.link(o_nexus); o_nexus.data.materials.append(mat_crystal)

    export_model(3, "Esmeralda", [o_base, o_rune, o_pillars, o_nexus])

# ==============================================================================
# TIER 4: ZAFIRO DE MAREAS (Mármol Blanco & Océano Profundo)
# ==============================================================================
def build_tier4_zafiro():
    clean_scene()
    mat_stone = create_material("M_Zafiro_Stone", (0.80, 0.84, 0.92, 1.0), roughness=0.45) # White polished marble
    mat_trim = create_material("M_Zafiro_Trim", (0.45, 0.55, 0.70, 1.0), roughness=0.5)
    mat_neon = create_material("M_Zafiro_Neon", (0.05, 0.55, 1.0, 1.0), roughness=0.1, emission=(0.05, 0.55, 1.0, 1.0), emission_strength=8.0)
    mat_crystal = create_material("M_Zafiro_Crystal", (0.2, 0.75, 1.0, 0.85), roughness=0.05, emission=(0.1, 0.65, 1.0, 1.0), emission_strength=6.0)

    # Base: Fluted Atlantean Marble Dais
    base_bm = bmesh.new()
    for rad, dep, z_off in [(4.6, 0.22, 0.11), (3.9, 0.18, 0.31), (3.35, 0.08, 0.44)]:
        t = bmesh.new()
        bmesh.ops.create_cone(t, cap_ends=True, segments=24, radius1=rad, radius2=rad*0.96, depth=dep)
        for v in t.verts: v.co.z += z_off
        off = len(base_bm.verts)
        for v in t.verts: base_bm.verts.new(v.co)
        base_bm.verts.ensure_lookup_table()
        for f in t.faces: base_bm.faces.new([base_bm.verts[v.index + off] for v in f.verts])
        t.free()
    m_base = bpy.data.meshes.new("Sanctum_T4_Base"); base_bm.to_mesh(m_base); base_bm.free()
    o_base = bpy.data.objects.new("Sanctum_T4_Base", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # Rune Floor: Wave Crests & Tidal Concentric Seal
    rbm = bmesh.new()
    z_f = 0.485; h = 0.03
    for rad1, rad2, seg in [(3.10, 3.25, 36), (2.35, 2.45, 28), (1.70, 1.80, 20)]:
        for i in range(seg):
            a1 = (2*math.pi*i)/seg; a2 = (2*math.pi*(i+1))/seg
            rbm.faces.new((
                rbm.verts.new((rad2*math.cos(a1), rad2*math.sin(a1), z_f+h)),
                rbm.verts.new((rad2*math.cos(a2), rad2*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a2), rad1*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a1), rad1*math.sin(a1), z_f+h))
            ))
    # Triple-Tide Spiral Center
    c_top = rbm.verts.new((0, 0, z_f+h+0.01))
    tide_pts = []
    for i in range(18):
        ang = (2*math.pi*i)/18
        r = 1.30 if i%3==0 else (0.8 if i%3==1 else 0.45)
        tide_pts.append(rbm.verts.new((r*math.cos(ang), r*math.sin(ang), z_f+h+0.005)))
    rbm.verts.ensure_lookup_table()
    for i in range(18):
        rbm.faces.new((c_top, tide_pts[i], tide_pts[(i+1)%18]))
    m_rune = bpy.data.meshes.new("Sanctum_T4_Rune"); rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Sanctum_T4_Rune", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_neon)

    # Monoliths: 6 Fluted Atlantean Spire Obelisks
    pbm = bmesh.new()
    for i in range(6):
        ang = (2*math.pi*i)/6
        cx = 4.15 * math.cos(ang); cy = 4.15 * math.sin(ang)
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=10, radius1=0.42, radius2=0.34, depth=0.45)
        for v in pbm.verts[-22:]: v.co.z += 0.445; v.co.x += cx; v.co.y += cy
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=10, radius1=0.28, radius2=0.14, depth=1.75)
        for v in pbm.verts[-22:]: v.co.z += 0.67 + 0.875; v.co.x += cx; v.co.y += cy
    m_pillars = bpy.data.meshes.new("Sanctum_T4_Pillars"); pbm.to_mesh(m_pillars); pbm.free()
    o_pillars = bpy.data.objects.new("Sanctum_T4_Pillars", m_pillars)
    bpy.context.collection.objects.link(o_pillars); o_pillars.data.materials.append(mat_trim)

    # Floating Nexus: Tidal Pearl & Double Planetary Water Rings
    cbm = bmesh.new()
    cz = 3.65
    top = cbm.verts.new((0, 0, cz + 0.50)); bot = cbm.verts.new((0, 0, cz - 0.50))
    eq = [cbm.verts.new((0.40*math.cos(2*math.pi*k/12), 0.40*math.sin(2*math.pi*k/12), cz)) for k in range(12)]
    cbm.verts.ensure_lookup_table()
    for k in range(12):
        cbm.faces.new((top, eq[k], eq[(k+1)%12]))
        cbm.faces.new((bot, eq[(k+1)%12], eq[k]))
    for ang_tilt, r_o, r_i in [(0.25, 0.82, 0.74), (-0.25, 0.82, 0.74)]:
        for k in range(18):
            a1 = (2*math.pi*k)/18; a2 = (2*math.pi*(k+1))/18
            cbm.faces.new((
                cbm.verts.new((r_o*math.cos(a1), r_o*math.sin(a1), cz + ang_tilt*math.cos(a1))),
                cbm.verts.new((r_o*math.cos(a2), r_o*math.sin(a2), cz + ang_tilt*math.cos(a2))),
                cbm.verts.new((r_i*math.cos(a2), r_i*math.sin(a2), cz + ang_tilt*math.cos(a2))),
                cbm.verts.new((r_i*math.cos(a1), r_i*math.sin(a1), cz + ang_tilt*math.cos(a1)))
            ))
    m_nexus = bpy.data.meshes.new("Sanctum_T4_Nexus"); cbm.to_mesh(m_nexus); cbm.free()
    o_nexus = bpy.data.objects.new("Sanctum_T4_Nexus", m_nexus)
    bpy.context.collection.objects.link(o_nexus); o_nexus.data.materials.append(mat_crystal)

    export_model(4, "Zafiro", [o_base, o_rune, o_pillars, o_nexus])

# ==============================================================================
# TIER 5: FRAGUA ÍGNEA DEL FÉNIX (Obsidiana Volcánica & Magma)
# ==============================================================================
def build_tier5_fenix():
    clean_scene()
    mat_stone = create_material("M_Fenix_Stone", (0.08, 0.05, 0.06, 1.0), roughness=0.9) # Dark volcanic basalt
    mat_trim = create_material("M_Fenix_Trim", (0.24, 0.12, 0.14, 1.0), roughness=0.7)
    mat_neon = create_material("M_Fenix_Neon", (1.0, 0.35, 0.05, 1.0), roughness=0.1, emission=(1.0, 0.35, 0.05, 1.0), emission_strength=8.5)
    mat_crystal = create_material("M_Fenix_Crystal", (1.0, 0.20, 0.0, 0.9), roughness=0.05, emission=(1.0, 0.25, 0.0, 1.0), emission_strength=6.5)

    # Base: Jagged 8-pointed volcanic stone bastion
    base_bm = bmesh.new()
    for rad, dep, z_off in [(4.6, 0.22, 0.11), (3.9, 0.18, 0.31), (3.35, 0.08, 0.44)]:
        t = bmesh.new()
        bmesh.ops.create_cone(t, cap_ends=True, segments=16, radius1=rad, radius2=rad*0.95, depth=dep)
        for v in t.verts: v.co.z += z_off
        off = len(base_bm.verts)
        for v in t.verts: base_bm.verts.new(v.co)
        base_bm.verts.ensure_lookup_table()
        for f in t.faces: base_bm.faces.new([base_bm.verts[v.index + off] for v in f.verts])
        t.free()
    m_base = bpy.data.meshes.new("Sanctum_T5_Base"); base_bm.to_mesh(m_base); base_bm.free()
    o_base = bpy.data.objects.new("Sanctum_T5_Base", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # Rune Floor: Magma Fissures & Phoenix Wings
    rbm = bmesh.new()
    z_f = 0.485; h = 0.03
    for rad1, rad2, seg in [(3.10, 3.25, 24), (2.35, 2.45, 16), (1.70, 1.80, 12)]:
        for i in range(seg):
            a1 = (2*math.pi*i)/seg; a2 = (2*math.pi*(i+1))/seg
            rbm.faces.new((
                rbm.verts.new((rad2*math.cos(a1), rad2*math.sin(a1), z_f+h)),
                rbm.verts.new((rad2*math.cos(a2), rad2*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a2), rad1*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a1), rad1*math.sin(a1), z_f+h))
            ))
    # 8 Radiant Phoenix Wing Crest Rays
    c_top = rbm.verts.new((0, 0, z_f+h+0.015))
    wing_pts = []
    for i in range(16):
        ang = (2*math.pi*i)/16
        r = 1.35 if i%2==0 else 0.40
        wing_pts.append(rbm.verts.new((r*math.cos(ang), r*math.sin(ang), z_f+h+0.005)))
    rbm.verts.ensure_lookup_table()
    for i in range(16):
        rbm.faces.new((c_top, wing_pts[i], wing_pts[(i+1)%16]))
    m_rune = bpy.data.meshes.new("Sanctum_T5_Rune"); rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Sanctum_T5_Rune", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_neon)

    # Monoliths: 6 Volcanic Fire Braziers / Horned Spikes
    pbm = bmesh.new()
    for i in range(6):
        ang = (2*math.pi*i)/6
        cx = 4.15 * math.cos(ang); cy = 4.15 * math.sin(ang)
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=6, radius1=0.45, radius2=0.38, depth=0.5)
        for v in pbm.verts[-14:]: v.co.z += 0.47; v.co.x += cx; v.co.y += cy
        # Sharp flame horns
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=6, radius1=0.30, radius2=0.08, depth=1.65)
        for v in pbm.verts[-14:]: v.co.z += 0.72 + 0.825; v.co.x += cx; v.co.y += cy
    m_pillars = bpy.data.meshes.new("Sanctum_T5_Pillars"); pbm.to_mesh(m_pillars); pbm.free()
    o_pillars = bpy.data.objects.new("Sanctum_T5_Pillars", m_pillars)
    bpy.context.collection.objects.link(o_pillars); o_pillars.data.materials.append(mat_trim)

    # Floating Nexus: Blazing Phoenix Flame Core
    cbm = bmesh.new()
    cz = 3.65
    top = cbm.verts.new((0, 0, cz + 0.80)); bot = cbm.verts.new((0, 0, cz - 0.70))
    eq = [cbm.verts.new((0.42*math.cos(2*math.pi*k/8), 0.42*math.sin(2*math.pi*k/8), cz)) for k in range(8)]
    cbm.verts.ensure_lookup_table()
    for k in range(8):
        cbm.faces.new((top, eq[k], eq[(k+1)%8]))
        cbm.faces.new((bot, eq[(k+1)%8], eq[k]))
    # Corona Flame Shards
    for k in range(6):
        kang = (2*math.pi*k)/6
        kx = 0.72*math.cos(kang); ky = 0.72*math.sin(kang)
        cbm.faces.new((
            cbm.verts.new((kx, ky, cz + 0.4)),
            cbm.verts.new((kx*1.2, ky*1.2, cz)),
            cbm.verts.new((kx, ky, cz - 0.4)),
            cbm.verts.new((kx*0.8, ky*0.8, cz))
        ))
    m_nexus = bpy.data.meshes.new("Sanctum_T5_Nexus"); cbm.to_mesh(m_nexus); cbm.free()
    o_nexus = bpy.data.objects.new("Sanctum_T5_Nexus", m_nexus)
    bpy.context.collection.objects.link(o_nexus); o_nexus.data.materials.append(mat_crystal)

    export_model(5, "Fenix", [o_base, o_rune, o_pillars, o_nexus])

# ==============================================================================
# TIER 6: TEMPLO SOLAR DEL OCASO (Oro Divino & Radiación Solar)
# ==============================================================================
def build_tier6_solar():
    clean_scene()
    mat_stone = create_material("M_Solar_Stone", (0.28, 0.22, 0.12, 1.0), roughness=0.55) # Polished bronze-sandstone
    mat_trim = create_material("M_Solar_Trim", (0.50, 0.40, 0.18, 1.0), roughness=0.45)
    mat_neon = create_material("M_Solar_Neon", (1.0, 0.85, 0.15, 1.0), roughness=0.1, emission=(1.0, 0.85, 0.15, 1.0), emission_strength=8.5)
    mat_crystal = create_material("M_Solar_Crystal", (1.0, 0.90, 0.30, 0.9), roughness=0.05, emission=(1.0, 0.90, 0.30, 1.0), emission_strength=7.0)

    # Base: Circular Solar Amphitheater
    base_bm = bmesh.new()
    for rad, dep, z_off in [(4.6, 0.22, 0.11), (3.9, 0.18, 0.31), (3.35, 0.08, 0.44)]:
        t = bmesh.new()
        bmesh.ops.create_cone(t, cap_ends=True, segments=24, radius1=rad, radius2=rad*0.96, depth=dep)
        for v in t.verts: v.co.z += z_off
        off = len(base_bm.verts)
        for v in t.verts: base_bm.verts.new(v.co)
        base_bm.verts.ensure_lookup_table()
        for f in t.faces: base_bm.faces.new([base_bm.verts[v.index + off] for v in f.verts])
        t.free()
    m_base = bpy.data.meshes.new("Sanctum_T6_Base"); base_bm.to_mesh(m_base); base_bm.free()
    o_base = bpy.data.objects.new("Sanctum_T6_Base", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # Rune Floor: Grand Sunburst Corona & Sacred Solar Dial
    rbm = bmesh.new()
    z_f = 0.485; h = 0.03
    for rad1, rad2, seg in [(3.10, 3.25, 32), (2.35, 2.45, 24), (1.70, 1.80, 16)]:
        for i in range(seg):
            a1 = (2*math.pi*i)/seg; a2 = (2*math.pi*(i+1))/seg
            rbm.faces.new((
                rbm.verts.new((rad2*math.cos(a1), rad2*math.sin(a1), z_f+h)),
                rbm.verts.new((rad2*math.cos(a2), rad2*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a2), rad1*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a1), rad1*math.sin(a1), z_f+h))
            ))
    # 16 Golden Sun Rays radiating from central solar disc
    c_top = rbm.verts.new((0, 0, z_f+h+0.015))
    sun_pts = []
    for i in range(32):
        ang = (2*math.pi*i)/32
        r = 1.35 if i%2==0 else 0.50
        sun_pts.append(rbm.verts.new((r*math.cos(ang), r*math.sin(ang), z_f+h+0.005)))
    rbm.verts.ensure_lookup_table()
    for i in range(32):
        rbm.faces.new((c_top, sun_pts[i], sun_pts[(i+1)%32]))
    m_rune = bpy.data.meshes.new("Sanctum_T6_Rune"); rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Sanctum_T6_Rune", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_neon)

    # Monoliths: 6 Sun Pillars with Golden Halos
    pbm = bmesh.new()
    for i in range(6):
        ang = (2*math.pi*i)/6
        cx = 4.15 * math.cos(ang); cy = 4.15 * math.sin(ang)
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=8, radius1=0.42, radius2=0.34, depth=0.45)
        for v in pbm.verts[-18:]: v.co.z += 0.445; v.co.x += cx; v.co.y += cy
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=8, radius1=0.28, radius2=0.15, depth=1.75)
        for v in pbm.verts[-18:]: v.co.z += 0.67 + 0.875; v.co.x += cx; v.co.y += cy
        # Solar Halo Ring on pillar top
        pz = 0.67 + 1.75 + 0.15
        for k in range(8):
            a1 = (2*math.pi*k)/8; a2 = (2*math.pi*(k+1))/8
            pbm.faces.new((
                pbm.verts.new((cx + 0.22*math.cos(a1), cy + 0.22*math.sin(a1), pz)),
                pbm.verts.new((cx + 0.22*math.cos(a2), cy + 0.22*math.sin(a2), pz)),
                pbm.verts.new((cx + 0.16*math.cos(a2), cy + 0.16*math.sin(a2), pz)),
                pbm.verts.new((cx + 0.16*math.cos(a1), cy + 0.16*math.sin(a1), pz))
            ))
    m_pillars = bpy.data.meshes.new("Sanctum_T6_Pillars"); pbm.to_mesh(m_pillars); pbm.free()
    o_pillars = bpy.data.objects.new("Sanctum_T6_Pillars", m_pillars)
    bpy.context.collection.objects.link(o_pillars); o_pillars.data.materials.append(mat_trim)

    # Floating Nexus: Radiant Golden Sun Core with Multi-layered Solar Rays
    cbm = bmesh.new()
    cz = 3.65
    top = cbm.verts.new((0, 0, cz + 0.55)); bot = cbm.verts.new((0, 0, cz - 0.55))
    eq = [cbm.verts.new((0.45*math.cos(2*math.pi*k/12), 0.45*math.sin(2*math.pi*k/12), cz)) for k in range(12)]
    cbm.verts.ensure_lookup_table()
    for k in range(12):
        cbm.faces.new((top, eq[k], eq[(k+1)%12]))
        cbm.faces.new((bot, eq[(k+1)%12], eq[k]))
    # Dual Golden Sun Halos
    for r_out, r_in, h_off in [(0.85, 0.76, 0.0), (1.05, 0.98, 0.1)]:
        for k in range(16):
            a1 = (2*math.pi*k)/16; a2 = (2*math.pi*(k+1))/16
            cbm.faces.new((
                cbm.verts.new((r_out*math.cos(a1), r_out*math.sin(a1), cz + h_off)),
                cbm.verts.new((r_out*math.cos(a2), r_out*math.sin(a2), cz + h_off)),
                cbm.verts.new((r_in *math.cos(a2), r_in *math.sin(a2), cz + h_off)),
                cbm.verts.new((r_in *math.cos(a1), r_in *math.sin(a1), cz + h_off))
            ))
    m_nexus = bpy.data.meshes.new("Sanctum_T6_Nexus"); cbm.to_mesh(m_nexus); cbm.free()
    o_nexus = bpy.data.objects.new("Sanctum_T6_Nexus", m_nexus)
    bpy.context.collection.objects.link(o_nexus); o_nexus.data.materials.append(mat_crystal)

    export_model(6, "Solar", [o_base, o_rune, o_pillars, o_nexus])

# ==============================================================================
# TIER 7: VÓRTICE CÓSMICO DEL VACÍO (Abismo Interdimensional & Singularity)
# ==============================================================================
def build_tier7_vortice():
    clean_scene()
    mat_stone = create_material("M_Vortice_Stone", (0.05, 0.04, 0.08, 1.0), roughness=0.85) # Void obsidian
    mat_trim = create_material("M_Vortice_Trim", (0.16, 0.10, 0.24, 1.0), roughness=0.6)
    mat_neon = create_material("M_Vortice_Neon", (0.75, 0.10, 1.0, 1.0), roughness=0.1, emission=(0.75, 0.10, 1.0, 1.0), emission_strength=9.0)
    mat_crystal = create_material("M_Vortice_Crystal", (0.95, 0.15, 0.95, 0.9), roughness=0.05, emission=(0.95, 0.15, 0.95, 1.0), emission_strength=7.5)

    # Base: Stepped Abyss Vortex Dais (Octagonal Void Steps)
    base_bm = bmesh.new()
    for rad, dep, z_off in [(4.6, 0.22, 0.11), (3.9, 0.18, 0.31), (3.35, 0.08, 0.44)]:
        t = bmesh.new()
        bmesh.ops.create_cone(t, cap_ends=True, segments=16, radius1=rad, radius2=rad*0.94, depth=dep)
        for v in t.verts: v.co.z += z_off
        off = len(base_bm.verts)
        for v in t.verts: base_bm.verts.new(v.co)
        base_bm.verts.ensure_lookup_table()
        for f in t.faces: base_bm.faces.new([base_bm.verts[v.index + off] for v in f.verts])
        t.free()
    m_base = bpy.data.meshes.new("Sanctum_T7_Base"); base_bm.to_mesh(m_base); base_bm.free()
    o_base = bpy.data.objects.new("Sanctum_T7_Base", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # Rune Floor: Cosmic Spiral Galaxy & Interdimensional Seal
    rbm = bmesh.new()
    z_f = 0.485; h = 0.03
    for rad1, rad2, seg in [(3.10, 3.25, 32), (2.35, 2.45, 24), (1.70, 1.80, 16)]:
        for i in range(seg):
            a1 = (2*math.pi*i)/seg; a2 = (2*math.pi*(i+1))/seg
            rbm.faces.new((
                rbm.verts.new((rad2*math.cos(a1), rad2*math.sin(a1), z_f+h)),
                rbm.verts.new((rad2*math.cos(a2), rad2*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a2), rad1*math.sin(a2), z_f+h)),
                rbm.verts.new((rad1*math.cos(a1), rad1*math.sin(a1), z_f+h))
            ))
    # Cosmic Singularity Spiral in Center
    c_top = rbm.verts.new((0, 0, z_f+h+0.02))
    spiral_pts = []
    for i in range(24):
        ang = (2*math.pi*i)/24
        # logarithmic spiral effect
        r = 1.35 * (1.0 - (i / 48.0))
        spiral_pts.append(rbm.verts.new((r*math.cos(ang), r*math.sin(ang), z_f+h+0.005)))
    rbm.verts.ensure_lookup_table()
    for i in range(23):
        rbm.faces.new((c_top, spiral_pts[i], spiral_pts[i+1]))
    m_rune = bpy.data.meshes.new("Sanctum_T7_Rune"); rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Sanctum_T7_Rune", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_neon)

    # Monoliths: 6 Inward-Leaning Distorted Void Spikes
    pbm = bmesh.new()
    for i in range(6):
        ang = (2*math.pi*i)/6
        cx = 4.15 * math.cos(ang); cy = 4.15 * math.sin(ang)
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=6, radius1=0.45, radius2=0.36, depth=0.45)
        for v in pbm.verts[-14:]: v.co.z += 0.445; v.co.x += cx; v.co.y += cy
        # Floating dimensional shard tilted inward towards the cosmic core
        bmesh.ops.create_cone(pbm, cap_ends=True, segments=5, radius1=0.30, radius2=0.08, depth=1.85)
        for v in pbm.verts[-12:]:
            # slight tilt inwards
            v.co.x -= 0.12 * math.cos(ang)
            v.co.y -= 0.12 * math.sin(ang)
            v.co.z += 0.67 + 0.925 + 0.15
            v.co.x += cx; v.co.y += cy
    m_pillars = bpy.data.meshes.new("Sanctum_T7_Pillars"); pbm.to_mesh(m_pillars); pbm.free()
    o_pillars = bpy.data.objects.new("Sanctum_T7_Pillars", m_pillars)
    bpy.context.collection.objects.link(o_pillars); o_pillars.data.materials.append(mat_trim)

    # Floating Nexus: Dimensional Void Hypercube with Triple Gyroscopic Cosmic Rings
    cbm = bmesh.new()
    cz = 3.65
    # Central Singularity Octahedron
    top = cbm.verts.new((0, 0, cz + 0.65)); bot = cbm.verts.new((0, 0, cz - 0.65))
    eq = [cbm.verts.new((0.40*math.cos(2*math.pi*k/8), 0.40*math.sin(2*math.pi*k/8), cz)) for k in range(8)]
    cbm.verts.ensure_lookup_table()
    for k in range(8):
        cbm.faces.new((top, eq[k], eq[(k+1)%8]))
        cbm.faces.new((bot, eq[(k+1)%8], eq[k]))
    # Triple Gyroscopic Void Rings (X, Y, Z tilted)
    for rot_axis in [0.0, math.pi/3, 2*math.pi/3]:
        for k in range(16):
            a1 = (2*math.pi*k)/16; a2 = (2*math.pi*(k+1))/16
            r_o = 0.88; r_i = 0.80
            # tilt coordinates
            p1 = (r_o*math.cos(a1), r_o*math.sin(a1)*math.cos(rot_axis), cz + r_o*math.sin(a1)*math.sin(rot_axis))
            p2 = (r_o*math.cos(a2), r_o*math.sin(a2)*math.cos(rot_axis), cz + r_o*math.sin(a2)*math.sin(rot_axis))
            p3 = (r_i*math.cos(a2), r_i*math.sin(a2)*math.cos(rot_axis), cz + r_i*math.sin(a2)*math.sin(rot_axis))
            p4 = (r_i*math.cos(a1), r_i*math.sin(a1)*math.cos(rot_axis), cz + r_i*math.sin(a1)*math.sin(rot_axis))
            cbm.faces.new((cbm.verts.new(p1), cbm.verts.new(p2), cbm.verts.new(p3), cbm.verts.new(p4)))
    m_nexus = bpy.data.meshes.new("Sanctum_T7_Nexus"); cbm.to_mesh(m_nexus); cbm.free()
    o_nexus = bpy.data.objects.new("Sanctum_T7_Nexus", m_nexus)
    bpy.context.collection.objects.link(o_nexus); o_nexus.data.materials.append(mat_crystal)

    export_model(7, "Vortice", [o_base, o_rune, o_pillars, o_nexus])

# Execute all
print("=== GENERATING ALL SANCTUMS (TIERS 2 TO 7) ===")
build_tier2_amatista()
build_tier3_esmeralda()
build_tier4_zafiro()
build_tier5_fenix()
build_tier6_solar()
build_tier7_vortice()
print("=== ALL SANCTUMS GENERATED & OPTIMIZED SUCCESSFULLY ===")
