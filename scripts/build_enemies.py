import bpy
import bmesh
import mathutils
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\enemies"
os.makedirs(output_dir, exist_ok=True)

def clean_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def create_material(name, color, roughness=0.5, metallic=0.0, emission=None, emission_strength=1.0, alpha=1.0):
    mat = bpy.data.materials.new(name=name)
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs['Base Color'].default_value = color
        bsdf.inputs['Roughness'].default_value = roughness
        bsdf.inputs['Metallic'].default_value = metallic
        if 'Alpha' in bsdf.inputs:
            bsdf.inputs['Alpha'].default_value = alpha
        if emission and 'Emission Color' in bsdf.inputs:
            bsdf.inputs['Emission Color'].default_value = emission
            if 'Emission Strength' in bsdf.inputs:
                bsdf.inputs['Emission Strength'].default_value = emission_strength
    return mat

def render_enemy_preview(filename, cam_loc, cam_rot, light_color):
    bpy.context.scene.render.resolution_x = 960
    bpy.context.scene.render.resolution_y = 600
    world = bpy.context.scene.world
    if not world:
        world = bpy.data.worlds.new("EnemyWorld")
        bpy.context.scene.world = world
    world.use_nodes = True
    bg_node = world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs['Color'].default_value = (0.04, 0.05, 0.07, 1.0)
        bg_node.inputs['Strength'].default_value = 0.5

    cam_data = bpy.data.cameras.new("EnemyCam")
    cam_data.lens = 50
    cam_obj = bpy.data.objects.new("EnemyCam", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj
    cam_obj.location = cam_loc
    cam_obj.rotation_euler = cam_rot

    # Key light
    l1 = bpy.data.lights.new("KeyL", 'POINT')
    l1.energy = 1600
    l1.color = light_color
    lo1 = bpy.data.objects.new("KeyL", l1)
    lo1.location = (cam_loc[0]*0.7, cam_loc[1]*0.7, cam_loc[2] + 1.0)
    bpy.context.collection.objects.link(lo1)

    # Rim light
    l2 = bpy.data.lights.new("RimL", 'POINT')
    l2.energy = 2200
    l2.color = (0.3, 0.7, 1.0)
    lo2 = bpy.data.objects.new("RimL", l2)
    lo2.location = (-cam_loc[0]*0.8, -cam_loc[1]*0.8, cam_loc[2]*0.7)
    bpy.context.collection.objects.link(lo2)

    out_path = os.path.join(output_dir, filename)
    bpy.context.scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {out_path}")

def export_enemy(mob_name, objects):
    for obj in objects:
        for p in obj.data.polygons:
            p.use_smooth = True
            
    total_tris = sum(sum(len(f.vertices)-2 for f in o.data.polygons) for o in objects)
    print(f"[{mob_name.upper()}] Total Tris: {total_tris}")
    
    # Modular FBX
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:
        obj.select_set(True)
        
    fbx_mod = os.path.join(output_dir, f"{mob_name}_Modular.fbx")
    bpy.ops.export_scene.fbx(
        filepath=fbx_mod,
        use_selection=True,
        global_scale=1.0,
        axis_forward='-Z',
        axis_up='Y',
        apply_scale_options='FBX_SCALE_ALL'
    )
    print(f"Exported Modular: {fbx_mod}")

    # Combined FBX
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.duplicate()
    dupes = [o for o in bpy.context.selected_objects]
    bpy.context.view_layer.objects.active = dupes[0]
    bpy.ops.object.join()
    merged = bpy.context.active_object
    merged.name = f"{mob_name}_Combined"

    fbx_comb = os.path.join(output_dir, f"{mob_name}_Combined.fbx")
    bpy.ops.object.select_all(action='DESELECT')
    merged.select_set(True)
    bpy.ops.export_scene.fbx(
        filepath=fbx_comb,
        use_selection=True,
        global_scale=1.0,
        axis_forward='-Z',
        axis_up='Y',
        apply_scale_options='FBX_SCALE_ALL'
    )
    bpy.data.objects.remove(merged, do_unlink=True)

# ==============================================================================
# 1. SLIME RÚNICO ESTILIZADO (Gota orgánico squash & stretch, ojos, núcleo)
# ==============================================================================
def build_slime_runico():
    clean_scene()
    mat_jelly = create_material("M_Slime_Jelly", (0.1, 0.9, 0.45, 0.75), roughness=0.1, alpha=0.75)
    mat_eyes = create_material("M_Slime_Eyes", (0.05, 0.05, 0.08, 1.0), roughness=0.2)
    mat_pupil = create_material("M_Slime_Pupils", (1.0, 1.0, 1.0, 1.0), roughness=0.1, emission=(1.0, 1.0, 1.0, 1.0), emission_strength=2.0)
    mat_core = create_material("M_Slime_Core", (0.2, 1.0, 0.8, 1.0), roughness=0.05, emission=(0.2, 1.0, 0.8, 1.0), emission_strength=8.0)

    # Body (Teardrop Jelly)
    bm = bmesh.new()
    segs = 16
    rings = 8
    
    # Profile curve from bottom to curved tip
    # (z, radius, y_offset for cute backward curl)
    profile = [
        (0.00, 1.10,  0.00), # Flat bottom
        (0.20, 1.55,  0.00), # Squash bulge base
        (0.55, 1.70,  0.02), # Belly widest
        (0.95, 1.50,  0.00), # Mid waist
        (1.40, 1.10, -0.08), # Upper taper
        (1.80, 0.65, -0.20), # Tip neck
        (2.15, 0.22, -0.35), # Tip curl
    ]
    
    ring_verts = []
    # Bottom center vert
    v_bottom = bm.verts.new((0, 0, 0))
    
    for (pz, pr, py) in profile:
        cur_ring = []
        for i in range(segs):
            ang = (2 * math.pi * i) / segs
            vx = pr * math.cos(ang)
            vy = pr * math.sin(ang) + py
            cur_ring.append(bm.verts.new((vx, vy, pz)))
        ring_verts.append(cur_ring)
        
    # Top tip vert
    v_top = bm.verts.new((0, -0.42, 2.30))
    bm.verts.ensure_lookup_table()
    
    # Connect bottom cap
    for i in range(segs):
        bm.faces.new((v_bottom, ring_verts[0][(i+1)%segs], ring_verts[0][i]))
        
    # Connect intermediate rings
    for r in range(len(ring_verts) - 1):
        for i in range(segs):
            next_i = (i + 1) % segs
            bm.faces.new((
                ring_verts[r][i],
                ring_verts[r][next_i],
                ring_verts[r+1][next_i],
                ring_verts[r+1][i]
            ))
            
    # Connect top cap
    for i in range(segs):
        bm.faces.new((v_top, ring_verts[-1][i], ring_verts[-1][(i+1)%segs]))
        
    m_body = bpy.data.meshes.new("Slime_Body_Jelly")
    bm.to_mesh(m_body); bm.free()
    o_body = bpy.data.objects.new("Slime_Body_Jelly", m_body)
    bpy.context.collection.objects.link(o_body); o_body.data.materials.append(mat_jelly)

    # Eyes & Highlights (Anime style)
    ebm = bmesh.new()
    for side in [-1, 1]:
        # Eye sclera (black/dark cute oval)
        ex = side * 0.55
        ey = 1.48 # front of belly
        ez = 0.85
        
        # 8-sided disc facing forward
        eye_center = ebm.verts.new((ex, ey, ez))
        ring = []
        for i in range(8):
            ang = (2 * math.pi * i) / 8
            rx = 0.22 * math.cos(ang)
            rz = 0.30 * math.sin(ang)
            ring.append(ebm.verts.new((ex + rx, ey + 0.02, ez + rz)))
        ebm.verts.ensure_lookup_table()
        for i in range(8):
            ebm.faces.new((eye_center, ring[i], ring[(i+1)%8]))
            
        # Pupil gleam (white shiny dot)
        gx = ex + side * 0.06
        gy = ey + 0.04
        gz = ez + 0.10
        gleam_center = ebm.verts.new((gx, gy, gz))
        g_ring = []
        for i in range(6):
            ang = (2 * math.pi * i) / 6
            g_ring.append(ebm.verts.new((gx + 0.08*math.cos(ang), gy, gz + 0.08*math.sin(ang))))
        ebm.verts.ensure_lookup_table()
        for i in range(6):
            ebm.faces.new((gleam_center, g_ring[i], g_ring[(i+1)%6]))
            
    m_eyes = bpy.data.meshes.new("Slime_Eyes")
    ebm.to_mesh(m_eyes); ebm.free()
    o_eyes = bpy.data.objects.new("Slime_Eyes", m_eyes)
    bpy.context.collection.objects.link(o_eyes); o_eyes.data.materials.append(mat_eyes)

    # Floating Inner Runic Core (Diamond crystal inside gelatin)
    cbm = bmesh.new()
    cz = 0.85
    c_top = cbm.verts.new((0, 0, cz + 0.38))
    c_bot = cbm.verts.new((0, 0, cz - 0.38))
    cr = 0.22
    eq = [cbm.verts.new((cr*math.cos(2*math.pi*k/6), cr*math.sin(2*math.pi*k/6), cz)) for k in range(6)]
    cbm.verts.ensure_lookup_table()
    for k in range(6):
        cbm.faces.new((c_top, eq[k], eq[(k+1)%6]))
        cbm.faces.new((c_bot, eq[(k+1)%6], eq[k]))
        
    # Orbiting rune band around core
    or_r = 0.38
    for k in range(12):
        a1 = (2*math.pi*k)/12; a2 = (2*math.pi*(k+1))/12
        tilt = 0.08
        cbm.faces.new((
            cbm.verts.new((or_r*math.cos(a1), or_r*math.sin(a1), cz + tilt*math.sin(a1))),
            cbm.verts.new((or_r*math.cos(a2), or_r*math.sin(a2), cz + tilt*math.sin(a2))),
            cbm.verts.new(((or_r-0.04)*math.cos(a2), (or_r-0.04)*math.sin(a2), cz + tilt*math.sin(a2))),
            cbm.verts.new(((or_r-0.04)*math.cos(a1), (or_r-0.04)*math.sin(a1), cz + tilt*math.sin(a1)))
        ))
    m_core = bpy.data.meshes.new("Slime_Inner_Core")
    cbm.to_mesh(m_core); cbm.free()
    o_core = bpy.data.objects.new("Slime_Inner_Core", m_core)
    bpy.context.collection.objects.link(o_core); o_core.data.materials.append(mat_core)

    export_enemy("Slime_Runico", [o_body, o_eyes, o_core])
    render_enemy_preview("preview_enemy_slime.png", (3.2, -3.8, 2.4), (math.radians(72), 0, math.radians(40)), (0.2, 1.0, 0.5))

# ==============================================================================
# 2. GOLEM DE CRISTAL RÚNICO (Rocas flotantes, torso masivo, cristales, puños)
# ==============================================================================
def build_golem_cristal():
    clean_scene()
    mat_stone = create_material("M_Golem_Stone", (0.16, 0.17, 0.22, 1.0), roughness=0.85)
    mat_trim = create_material("M_Golem_Trim", (0.30, 0.33, 0.42, 1.0), roughness=0.7)
    mat_crystal = create_material("M_Golem_Crystal", (0.1, 0.9, 1.0, 0.9), roughness=0.05, emission=(0.1, 0.9, 1.0, 1.0), emission_strength=7.5)
    mat_rune = create_material("M_Golem_Rune", (0.0, 0.85, 1.0, 1.0), roughness=0.1, emission=(0.0, 0.85, 1.0, 1.0), emission_strength=8.0)

    # 1. Torso & Head (Massive faceted boulder torso)
    tbm = bmesh.new()
    # Torso upper wedge
    bmesh.ops.create_cone(tbm, cap_ends=True, segments=7, radius1=1.1, radius2=1.45, depth=1.3)
    for v in tbm.verts[-16:]:
        v.co.z += 2.6
    # Beveled boulder head sitting sunken into chest
    bmesh.ops.create_cube(tbm, size=0.85)
    for v in tbm.verts[-8:]:
        v.co.z += 3.35
        v.co.y += 0.25 # head slightly forward
    # Lower floating waist rock
    bmesh.ops.create_cone(tbm, cap_ends=True, segments=6, radius1=0.75, radius2=0.55, depth=0.6)
    for v in tbm.verts[-14:]:
        v.co.z += 1.6
    # Floating thigh/shin rocks (Levitating golem limbs)
    for side in [-1, 1]:
        lx = side * 0.85
        bmesh.ops.create_cone(tbm, cap_ends=True, segments=6, radius1=0.45, radius2=0.35, depth=0.9)
        for v in tbm.verts[-14:]:
            v.co.x += lx; v.co.z += 0.75
    m_torso = bpy.data.meshes.new("Golem_Body_Stone")
    tbm.to_mesh(m_torso); tbm.free()
    o_torso = bpy.data.objects.new("Golem_Body_Stone", m_torso)
    bpy.context.collection.objects.link(o_torso); o_torso.data.materials.append(mat_stone)

    # 2. Heavy Floating Arms & Knuckle Fists
    abm = bmesh.new()
    for side in [-1, 1]:
        sx = side * 1.95
        # Floating shoulder pauldron boulder
        bmesh.ops.create_cone(abm, cap_ends=True, segments=6, radius1=0.65, radius2=0.45, depth=0.75)
        for v in abm.verts[-14:]:
            v.co.x += sx; v.co.z += 2.9
        # Forearm rock
        bmesh.ops.create_cone(abm, cap_ends=True, segments=6, radius1=0.50, radius2=0.40, depth=0.85)
        for v in abm.verts[-14:]:
            v.co.x += sx * 1.15; v.co.z += 2.0; v.co.y += 0.25
        # Heavy stone knuckle fist
        bmesh.ops.create_cube(abm, size=0.75)
        for v in abm.verts[-8:]:
            v.co.x += sx * 1.15; v.co.z += 1.15; v.co.y += 0.45
    m_arms = bpy.data.meshes.new("Golem_Arms_Stone")
    abm.to_mesh(m_arms); abm.free()
    o_arms = bpy.data.objects.new("Golem_Arms_Stone", m_arms)
    bpy.context.collection.objects.link(o_arms); o_arms.data.materials.append(mat_trim)

    # 3. Crystal Clusters protruding from shoulders & back
    cbm = bmesh.new()
    # Left & Right shoulder crystals
    for side in [-1, 1]:
        sx = side * 1.85
        # 3 crystal spikes per shoulder
        for j, (ox, oy, oz, length) in enumerate([(0, -0.1, 0.45, 0.8), (0.25*side, 0.15, 0.35, 0.65), (-0.2*side, 0.1, 0.3, 0.5)]):
            top = cbm.verts.new((sx + ox + side*0.15, oy, 2.9 + oz + length))
            bot = cbm.verts.new((sx + ox, oy, 2.9 + oz))
            cr = 0.14
            eq = [cbm.verts.new((sx + ox + cr*math.cos(2*math.pi*k/5), oy + cr*math.sin(2*math.pi*k/5), 2.9 + oz + 0.2)) for k in range(5)]
            cbm.verts.ensure_lookup_table()
            for k in range(5):
                cbm.faces.new((top, eq[k], eq[(k+1)%5]))
                cbm.faces.new((bot, eq[(k+1)%5], eq[k]))
    # Back spine crystal shards
    for bz in [2.3, 2.7, 3.1]:
        top = cbm.verts.new((0, -1.2, bz + 0.2))
        bot = cbm.verts.new((0, -0.6, bz))
        eq = [cbm.verts.new((0.15*math.cos(2*math.pi*k/4), -0.8 + 0.15*math.sin(2*math.pi*k/4), bz + 0.05)) for k in range(4)]
        cbm.verts.ensure_lookup_table()
        for k in range(4):
            cbm.faces.new((top, eq[k], eq[(k+1)%4]))
            cbm.faces.new((bot, eq[(k+1)%4], eq[k]))
    m_cryst = bpy.data.meshes.new("Golem_Crystal_Spikes")
    cbm.to_mesh(m_cryst); cbm.free()
    o_cryst = bpy.data.objects.new("Golem_Crystal_Spikes", m_cryst)
    bpy.context.collection.objects.link(o_cryst); o_cryst.data.materials.append(mat_crystal)

    # 4. Glowing Runic Chest Core & Visor Eyes
    rbm = bmesh.new()
    # Chest Core Arcane Star
    c_center = rbm.verts.new((0, 0.95, 2.55))
    star = []
    for i in range(12):
        ang = (2*math.pi*i)/12
        r = 0.38 if i%2==0 else 0.18
        star.append(rbm.verts.new((r*math.cos(ang), 0.96, 2.55 + r*math.sin(ang))))
    rbm.verts.ensure_lookup_table()
    for i in range(12):
        rbm.faces.new((c_center, star[i], star[(i+1)%12]))
    # Visor Eye Slot
    rbm.faces.new((
        rbm.verts.new((-0.26, 0.72, 3.42)),
        rbm.verts.new(( 0.26, 0.72, 3.42)),
        rbm.verts.new(( 0.26, 0.72, 3.32)),
        rbm.verts.new((-0.26, 0.72, 3.32))
    ))
    m_runes = bpy.data.meshes.new("Golem_Runes_Glow")
    rbm.to_mesh(m_runes); rbm.free()
    o_runes = bpy.data.objects.new("Golem_Runes_Glow", m_runes)
    bpy.context.collection.objects.link(o_runes); o_runes.data.materials.append(mat_rune)

    export_enemy("Golem_Cristal", [o_torso, o_arms, o_cryst, o_runes])
    render_enemy_preview("preview_enemy_golem.png", (4.8, -5.5, 3.6), (math.radians(70), 0, math.radians(42)), (0.1, 0.85, 1.0))

# ==============================================================================
# 3. ESPECTRO / MURCIÉLAGO DE SOMBRA ARCANA (Alas cristalinas, fuego espectral)
# ==============================================================================
def build_murcielago_sombra():
    clean_scene()
    mat_shadow = create_material("M_Bat_Shadow", (0.06, 0.04, 0.10, 1.0), roughness=0.7)
    mat_wings = create_material("M_Bat_Wings", (0.65, 0.15, 0.95, 0.85), roughness=0.1, emission=(0.65, 0.15, 0.95, 1.0), emission_strength=4.0)
    mat_eyes = create_material("M_Bat_Eyes", (1.0, 0.10, 0.45, 1.0), roughness=0.05, emission=(1.0, 0.10, 0.45, 1.0), emission_strength=9.0)

    # 1. Torso, Head & Wispy Phantom Tail
    bbm = bmesh.new()
    # Sleek curved aerodynamic torso
    bmesh.ops.create_cone(bbm, cap_ends=True, segments=8, radius1=0.35, radius2=0.22, depth=1.1)
    for v in bbm.verts[-18:]:
        v.co.z += 1.8; v.co.y -= 0.15
    # Head & Pointed Feline/Bat Ears
    bmesh.ops.create_cone(bbm, cap_ends=True, segments=7, radius1=0.28, radius2=0.15, depth=0.55)
    for v in bbm.verts[-16:]:
        v.co.z += 2.5; v.co.y += 0.2
    # Two stylized sharp ears / horns
    for side in [-1, 1]:
        hx = side * 0.18
        top = bbm.verts.new((hx * 1.5, 0.15, 3.10))
        bot = bbm.verts.new((hx, 0.20, 2.70))
        eq = [bbm.verts.new((hx + 0.1*math.cos(2*math.pi*k/4), 0.20 + 0.1*math.sin(2*math.pi*k/4), 2.78)) for k in range(4)]
        bbm.verts.ensure_lookup_table()
        for k in range(4):
            bbm.faces.new((top, eq[k], eq[(k+1)%4]))
            bbm.faces.new((bot, eq[(k+1)%4], eq[k]))
    # Wispy spectral phantom tail tapering downwards
    tail_pts = [(0, -0.3, 1.25, 0.18), (0, -0.5, 0.85, 0.12), (0, -0.7, 0.45, 0.06), (0, -0.85, 0.15, 0.01)]
    for i in range(len(tail_pts)-1):
        x1, y1, z1, r1 = tail_pts[i]
        x2, y2, z2, r2 = tail_pts[i+1]
        for k in range(6):
            a1 = (2*math.pi*k)/6; a2 = (2*math.pi*(k+1))/6
            bbm.faces.new((
                bbm.verts.new((x1 + r1*math.cos(a1), y1 + r1*math.sin(a1), z1)),
                bbm.verts.new((x1 + r1*math.cos(a2), y1 + r1*math.sin(a2), z1)),
                bbm.verts.new((x2 + r2*math.cos(a2), y2 + r2*math.sin(a2), z2)),
                bbm.verts.new((x2 + r2*math.cos(a1), y2 + r2*math.sin(a1), z2))
            ))
    m_body = bpy.data.meshes.new("Bat_Body_Shadow")
    bbm.to_mesh(m_body); bbm.free()
    o_body = bpy.data.objects.new("Bat_Body_Shadow", m_body)
    bpy.context.collection.objects.link(o_body); o_body.data.materials.append(mat_shadow)

    # 2. Angular Crystal Membrane Wings (Span ~3.6 meters)
    wbm = bmesh.new()
    for side in [-1, 1]:
        # Wing joints: Shoulder, Elbow, Wrist, 3 Finger tips
        p_sh = (side * 0.28, 0.0, 2.2)
        p_el = (side * 1.10, 0.25, 2.6)
        p_wr = (side * 1.85, 0.15, 2.4)
        
        # 3 Sharp Wing Claws/Tips
        f1 = (side * 2.30, 0.25, 2.7)  # Top wing tip
        f2 = (side * 2.10, 0.05, 1.9)  # Mid blade
        f3 = (side * 1.55, -0.15, 1.35) # Bottom blade
        p_flank = (side * 0.25, -0.2, 1.4) # Body attachment
        
        # Wing Membrane Facets
        v_sh = wbm.verts.new(p_sh)
        v_el = wbm.verts.new(p_el)
        v_wr = wbm.verts.new(p_wr)
        v_f1 = wbm.verts.new(f1)
        v_f2 = wbm.verts.new(f2)
        v_f3 = wbm.verts.new(f3)
        v_fl = wbm.verts.new(p_flank)
        
        # Faceted crystal membrane quads/tris
        wbm.faces.new((v_sh, v_el, v_wr))
        wbm.faces.new((v_el, v_f1, v_wr))
        wbm.faces.new((v_wr, v_f1, v_f2))
        wbm.faces.new((v_wr, v_f2, v_f3))
        wbm.faces.new((v_wr, v_f3, v_sh))
        wbm.faces.new((v_sh, v_f3, v_fl))
    m_wings = bpy.data.meshes.new("Bat_Wings_Crystal")
    wbm.to_mesh(m_wings); wbm.free()
    o_wings = bpy.data.objects.new("Bat_Wings_Crystal", m_wings)
    bpy.context.collection.objects.link(o_wings); o_wings.data.materials.append(mat_wings)

    # 3. Spectral Eyes & Arcane Flame Crest
    fbm = bmesh.new()
    # Sharp angled demonic/spectral eyes
    for side in [-1, 1]:
        ex = side * 0.14
        ey = 0.38
        ez = 2.52
        fbm.faces.new((
            fbm.verts.new((ex, ey, ez + 0.08)),
            fbm.verts.new((ex + side*0.12, ey - 0.02, ez + 0.04)),
            fbm.verts.new((ex + side*0.08, ey - 0.02, ez - 0.04)),
            fbm.verts.new((ex, ey, ez - 0.02))
        ))
    # Glowing Spectral Chest Gem
    c_top = fbm.verts.new((0, 0.22, 2.15))
    c_bot = fbm.verts.new((0, 0.22, 1.75))
    c_left = fbm.verts.new((-0.12, 0.22, 1.95))
    c_right = fbm.verts.new((0.12, 0.22, 1.95))
    fbm.faces.new((c_top, c_left, c_bot, c_right))
    m_eyes = bpy.data.meshes.new("Bat_Eyes_Flame")
    fbm.to_mesh(m_eyes); fbm.free()
    o_eyes = bpy.data.objects.new("Bat_Eyes_Flame", m_eyes)
    bpy.context.collection.objects.link(o_eyes); o_eyes.data.materials.append(mat_eyes)

    export_enemy("Murcielago_Sombra", [o_body, o_wings, o_eyes])
    render_enemy_preview("preview_enemy_bat.png", (3.8, -4.5, 3.0), (math.radians(70), 0, math.radians(40)), (0.8, 0.2, 1.0))

# Execute all 3
print("=== GENERATING 3 ENEMIES IN BLENDER ===")
build_slime_runico()
build_golem_cristal()
build_murcielago_sombra()
print("=== ALL 3 ENEMIES GENERATED & EXPORTED SUCCESSFULLY ===")
