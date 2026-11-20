import bpy
import bmesh
import mathutils
import math
import os

output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\stations"
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

def render_station_preview(filename, cam_loc, cam_rot, light_color):
    bpy.context.scene.render.resolution_x = 960
    bpy.context.scene.render.resolution_y = 600
    world = bpy.context.scene.world
    if not world:
        world = bpy.data.worlds.new("StationWorld")
        bpy.context.scene.world = world
    world.use_nodes = True
    bg_node = world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs['Color'].default_value = (0.04, 0.05, 0.07, 1.0)
        bg_node.inputs['Strength'].default_value = 0.5

    cam_data = bpy.data.cameras.new("StationCam")
    cam_data.lens = 45
    cam_obj = bpy.data.objects.new("StationCam", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj
    cam_obj.location = cam_loc
    cam_obj.rotation_euler = cam_rot

    l1 = bpy.data.lights.new("KeyL", 'POINT')
    l1.energy = 2200
    l1.color = light_color
    lo1 = bpy.data.objects.new("KeyL", l1)
    lo1.location = (cam_loc[0]*0.7, cam_loc[1]*0.7, cam_loc[2] + 2.0)
    bpy.context.collection.objects.link(lo1)

    l2 = bpy.data.lights.new("RimL", 'POINT')
    l2.energy = 1600
    l2.color = (0.4, 0.7, 1.0)
    lo2 = bpy.data.objects.new("RimL", l2)
    lo2.location = (-cam_loc[0]*0.8, -cam_loc[1]*0.8, cam_loc[2]*0.8)
    bpy.context.collection.objects.link(lo2)

    out_path = os.path.join(output_dir, filename)
    bpy.context.scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {out_path}")

def export_station(name, objects):
    for obj in objects:
        for p in obj.data.polygons:
            p.use_smooth = True
            
    total_tris = sum(sum(len(f.vertices)-2 for f in o.data.polygons) for o in objects)
    print(f"[{name.upper()}] Total Tris: {total_tris}")
    
    # Modular FBX
    bpy.ops.object.select_all(action='DESELECT')
    for obj in objects:
        obj.select_set(True)
        
    fbx_mod = os.path.join(output_dir, f"{name}_Modular.fbx")
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
    merged.name = f"{name}_Combined"

    fbx_comb = os.path.join(output_dir, f"{name}_Combined.fbx")
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
# 1. TIENDA / MERCADO ARCANO (Pavilion medieval con toldo, estantería y monedas)
# ==============================================================================
def build_market_station():
    clean_scene()
    mat_wood = create_material("M_Market_Wood", (0.35, 0.22, 0.12, 1.0), roughness=0.8)
    mat_stone = create_material("M_Market_Stone", (0.22, 0.24, 0.28, 1.0), roughness=0.85)
    mat_cloth = create_material("M_Market_Cloth", (0.85, 0.25, 0.20, 1.0), roughness=0.7)
    mat_gold = create_material("M_Market_Gold", (1.0, 0.85, 0.15, 1.0), roughness=0.2, metallic=0.9, emission=(1.0, 0.85, 0.15, 1.0), emission_strength=2.0)

    # 1. Base Dais & Counter
    sbm = bmesh.new()
    # Stone paved platform
    bmesh.ops.create_cone(sbm, cap_ends=True, segments=12, radius1=3.8, radius2=3.6, depth=0.35)
    for v in sbm.verts: v.co.z += 0.175
    # Curved counter
    bmesh.ops.create_cone(sbm, cap_ends=True, segments=8, radius1=2.2, radius2=2.1, depth=1.0)
    for v in sbm.verts[-18:]: v.co.z += 0.35 + 0.5
    m_base = bpy.data.meshes.new("Market_Structure")
    sbm.to_mesh(m_base); sbm.free()
    o_base = bpy.data.objects.new("Market_Structure", m_base)
    bpy.context.collection.objects.link(o_base); o_base.data.materials.append(mat_stone)

    # 2. Timber Pillars & Back Wall
    wbm = bmesh.new()
    # 4 Timber pillars
    for x, y in [(-1.8, -1.2), (1.8, -1.2), (-2.0, 1.4), (2.0, 1.4)]:
        bmesh.ops.create_cube(wbm, size=0.35)
        for v in wbm.verts[-8:]:
            v.co.z = (v.co.z + 0.5) * 3.2 + 0.35
            v.co.x += x; v.co.y += y
    # Back merchandise shelf
    bmesh.ops.create_cube(wbm, size=1.0)
    for v in wbm.verts[-8:]:
        v.co.x *= 2.8; v.co.y *= 0.4; v.co.z *= 2.2
        v.co.z += 1.8; v.co.y -= 1.1
    m_wood = bpy.data.meshes.new("Market_Timber")
    wbm.to_mesh(m_wood); wbm.free()
    o_wood = bpy.data.objects.new("Market_Timber", m_wood)
    bpy.context.collection.objects.link(o_wood); o_wood.data.materials.append(mat_wood)

    # 3. Cloth Striped Canopy
    cbm = bmesh.new()
    # Arched canopy roof
    for i in range(12):
        u1 = i / 12.0
        u2 = (i + 1) / 12.0
        x1 = -2.6 + u1 * 5.2
        x2 = -2.6 + u2 * 5.2
        # curved arch
        z1 = 3.4 + math.sin(u1 * math.pi) * 0.7
        z2 = 3.4 + math.sin(u2 * math.pi) * 0.7
        cbm.faces.new((
            cbm.verts.new((x1, -1.6, z1)),
            cbm.verts.new((x2, -1.6, z2)),
            cbm.verts.new((x2,  1.8, z2 - 0.4)),
            cbm.verts.new((x1,  1.8, z1 - 0.4))
        ))
    m_canopy = bpy.data.meshes.new("Market_Canopy")
    cbm.to_mesh(m_canopy); cbm.free()
    o_canopy = bpy.data.objects.new("Market_Canopy", m_canopy)
    bpy.context.collection.objects.link(o_canopy); o_canopy.data.materials.append(mat_cloth)

    # 4. Gold sacks & Magic crystal jars
    gbm = bmesh.new()
    for gx, gy in [(-1.2, 0.4), (1.1, 0.5), (0.2, 0.7)]:
        bmesh.ops.create_cone(gbm, cap_ends=True, segments=6, radius1=0.24, radius2=0.08, depth=0.38)
        for v in gbm.verts[-14:]:
            v.co.x += gx; v.co.y += gy; v.co.z += 1.35 + 0.19
    m_gold = bpy.data.meshes.new("Market_GoldGoods")
    gbm.to_mesh(m_gold); gbm.free()
    o_gold = bpy.data.objects.new("Market_GoldGoods", m_gold)
    bpy.context.collection.objects.link(o_gold); o_gold.data.materials.append(mat_gold)

    export_station("Station_Mercado", [o_base, o_wood, o_canopy, o_gold])
    render_station_preview("preview_station_mercado.png", (5.2, -6.5, 4.8), (math.radians(65), 0, math.radians(38)), (1.0, 0.85, 0.4))

# ==============================================================================
# 2. FORJA REAL (Horno con chimenea de piedra, foso de lava, yunque épico)
# ==============================================================================
def build_forge_station():
    clean_scene()
    mat_stone = create_material("M_Forge_Stone", (0.14, 0.12, 0.15, 1.0), roughness=0.9)
    mat_metal = create_material("M_Forge_Metal", (0.45, 0.48, 0.55, 1.0), roughness=0.3, metallic=0.85)
    mat_lava = create_material("M_Forge_Lava", (1.0, 0.35, 0.05, 1.0), roughness=0.1, emission=(1.0, 0.35, 0.05, 1.0), emission_strength=9.0)

    # 1. Stone Hearth & Chimney
    fbm = bmesh.new()
    # Base platform
    bmesh.ops.create_cone(fbm, cap_ends=True, segments=12, radius1=3.8, radius2=3.6, depth=0.35)
    for v in fbm.verts: v.co.z += 0.175
    # Back stone hearth chimney
    bmesh.ops.create_cube(fbm, size=1.0)
    for v in fbm.verts[-8:]:
        v.co.x *= 2.6; v.co.y *= 1.4; v.co.z *= 3.8
        v.co.z += 1.9; v.co.y -= 1.1
    # Chimney stack tapering up
    bmesh.ops.create_cone(fbm, cap_ends=True, segments=6, radius1=0.75, radius2=0.55, depth=2.4)
    for v in fbm.verts[-14:]:
        v.co.z += 3.8 + 1.2; v.co.y -= 1.1
    m_stone = bpy.data.meshes.new("Forge_Hearth")
    fbm.to_mesh(m_stone); fbm.free()
    o_stone = bpy.data.objects.new("Forge_Hearth", m_stone)
    bpy.context.collection.objects.link(o_stone); o_stone.data.materials.append(mat_stone)

    # 2. Heavy Anvil & Hammer
    abm = bmesh.new()
    # Anvil pedestal
    bmesh.ops.create_cube(abm, size=0.9)
    for v in abm.verts[-8:]:
        v.co.z += 0.8; v.co.y += 0.3
    # Anvil body
    bmesh.ops.create_cube(abm, size=1.0)
    for v in abm.verts[-8:]:
        v.co.x *= 1.4; v.co.y *= 0.6; v.co.z *= 0.55
        v.co.z += 1.5; v.co.y += 0.3
    # Anvil horn
    bmesh.ops.create_cone(abm, cap_ends=True, segments=6, radius1=0.3, radius2=0.08, depth=0.75)
    for v in abm.verts[-14:]:
        # rotate along Y to point horizontally
        temp_z = v.co.z
        v.co.z = v.co.x
        v.co.x = temp_z + 0.9 + 0.375
        v.co.z += 1.5; v.co.y += 0.3
    # Giant Smithing Hammer resting on anvil
    bmesh.ops.create_cube(abm, size=0.4)
    for v in abm.verts[-8:]:
        v.co.x *= 1.2; v.co.z += 1.9; v.co.y += 0.3; v.co.x -= 0.2
    bmesh.ops.create_cone(abm, cap_ends=True, segments=4, radius1=0.06, radius2=0.06, depth=1.1)
    for v in abm.verts[-10:]:
        v.co.z += 2.2; v.co.y += 0.3; v.co.x -= 0.6
    m_metal = bpy.data.meshes.new("Forge_Anvil")
    abm.to_mesh(m_metal); abm.free()
    o_metal = bpy.data.objects.new("Forge_Anvil", m_metal)
    bpy.context.collection.objects.link(o_metal); o_metal.data.materials.append(mat_metal)

    # 3. Molten Lava Pit / Glowing Coals
    lbm = bmesh.new()
    bmesh.ops.create_cube(lbm, size=1.0)
    for v in lbm.verts:
        v.co.x *= 1.8; v.co.y *= 0.8; v.co.z *= 0.25
        v.co.z += 0.95; v.co.y -= 0.6
    m_lava = bpy.data.meshes.new("Forge_LavaPit")
    lbm.to_mesh(m_lava); lbm.free()
    o_lava = bpy.data.objects.new("Forge_LavaPit", m_lava)
    bpy.context.collection.objects.link(o_lava); o_lava.data.materials.append(mat_lava)

    export_station("Station_Forja", [o_stone, o_metal, o_lava])
    render_station_preview("preview_station_forja.png", (5.2, -6.5, 4.8), (math.radians(65), 0, math.radians(38)), (1.0, 0.45, 0.1))

# ==============================================================================
# 3. MESA DE ENCANTAMIENTO (Atril de piedra, Gran Grimorio, amatistas flotantes)
# ==============================================================================
def build_enchant_station():
    clean_scene()
    mat_stone = create_material("M_Enchant_Stone", (0.15, 0.12, 0.20, 1.0), roughness=0.7)
    mat_rune = create_material("M_Enchant_Rune", (0.8, 0.3, 1.0, 1.0), roughness=0.1, emission=(0.8, 0.3, 1.0, 1.0), emission_strength=8.0)
    mat_book = create_material("M_Enchant_Book", (0.95, 0.92, 0.85, 1.0), roughness=0.5)

    # 1. Octagonal Tiered Stone Dais & Dragon Lectern
    ebm = bmesh.new()
    bmesh.ops.create_cone(ebm, cap_ends=True, segments=8, radius1=3.8, radius2=3.6, depth=0.35)
    for v in ebm.verts: v.co.z += 0.175
    # Inner octagonal step
    bmesh.ops.create_cone(ebm, cap_ends=True, segments=8, radius1=2.8, radius2=2.7, depth=0.25)
    for v in ebm.verts[-18:]: v.co.z += 0.35 + 0.125
    # Central stone lectern column
    bmesh.ops.create_cone(ebm, cap_ends=True, segments=6, radius1=0.65, radius2=0.45, depth=1.6)
    for v in ebm.verts[-14:]: v.co.z += 0.60 + 0.8
    # Lectern book rest shelf
    bmesh.ops.create_cube(ebm, size=1.0)
    for v in ebm.verts[-8:]:
        v.co.x *= 1.4; v.co.y *= 1.1; v.co.z *= 0.22
        # tilt book shelf
        v.co.y -= 0.15 * v.co.z
        v.co.z += 2.25
    m_stone = bpy.data.meshes.new("Enchant_Lectern")
    ebm.to_mesh(m_stone); ebm.free()
    o_stone = bpy.data.objects.new("Enchant_Lectern", m_stone)
    bpy.context.collection.objects.link(o_stone); o_stone.data.materials.append(mat_stone)

    # 2. Grand Floating Open Grimoire
    bbm = bmesh.new()
    # Left and right open pages
    for side in [-1, 1]:
        bmesh.ops.create_cube(bbm, size=1.0)
        for v in bbm.verts[-8:]:
            v.co.x *= 0.55; v.co.y *= 0.75; v.co.z *= 0.08
            v.co.x += side * 0.32
            v.co.z += 2.45 - side * 0.08
    m_book = bpy.data.meshes.new("Enchant_Grimoire")
    bbm.to_mesh(m_book); bbm.free()
    o_book = bpy.data.objects.new("Enchant_Grimoire", m_book)
    bpy.context.collection.objects.link(o_book); o_book.data.materials.append(mat_book)

    # 3. 4 Floating Amethyst Spires & Concentric Floor Runes
    rbm = bmesh.new()
    # Floor Runic Ring
    r_out = 2.4; r_in = 2.2; zf = 0.62
    for i in range(16):
        a1 = (2*math.pi*i)/16; a2 = (2*math.pi*(i+1))/16
        rbm.faces.new((
            rbm.verts.new((r_out*math.cos(a1), r_out*math.sin(a1), zf)),
            rbm.verts.new((r_out*math.cos(a2), r_out*math.sin(a2), zf)),
            rbm.verts.new((r_in *math.cos(a2), r_in *math.sin(a2), zf)),
            rbm.verts.new((r_in *math.cos(a1), r_in *math.sin(a1), zf))
        ))
    # 4 Orbiting Amethyst Crystals
    for i in range(4):
        ang = (2*math.pi*i)/4 + math.pi/4
        cx = 1.9 * math.cos(ang); cy = 1.9 * math.sin(ang)
        top = rbm.verts.new((cx, cy, 2.7))
        bot = rbm.verts.new((cx, cy, 1.7))
        cr = 0.22
        eq = [rbm.verts.new((cx + cr*math.cos(2*math.pi*k/5), cy + cr*math.sin(2*math.pi*k/5), 2.2)) for k in range(5)]
        rbm.verts.ensure_lookup_table()
        for k in range(5):
            rbm.faces.new((top, eq[k], eq[(k+1)%5]))
            rbm.faces.new((bot, eq[(k+1)%5], eq[k]))
    m_rune = bpy.data.meshes.new("Enchant_Crystals")
    rbm.to_mesh(m_rune); rbm.free()
    o_rune = bpy.data.objects.new("Enchant_Crystals", m_rune)
    bpy.context.collection.objects.link(o_rune); o_rune.data.materials.append(mat_rune)

    export_station("Station_Encantar", [o_stone, o_book, o_rune])
    render_station_preview("preview_station_encantar.png", (5.2, -6.5, 4.8), (math.radians(65), 0, math.radians(38)), (0.8, 0.3, 1.0))

# ==============================================================================
# 4. SANTUARIO DE MASCOTAS (Nido místico, pilares de bestia, Huevo Celestial con alas)
# ==============================================================================
def build_pet_nursery_station():
    clean_scene()
    mat_stone = create_material("M_Pet_Stone", (0.18, 0.26, 0.22, 1.0), roughness=0.75)
    mat_gold = create_material("M_Pet_Gold", (1.0, 0.85, 0.20, 1.0), roughness=0.15, metallic=0.9, emission=(1.0, 0.85, 0.20, 1.0), emission_strength=4.0)
    mat_egg = create_material("M_Pet_Egg", (0.2, 1.0, 0.75, 0.9), roughness=0.05, emission=(0.1, 0.95, 0.65, 1.0), emission_strength=6.0)

    # 1. Sacred Nest Dais & Carved Totem Posts
    nbm = bmesh.new()
    bmesh.ops.create_cone(nbm, cap_ends=True, segments=12, radius1=3.8, radius2=3.6, depth=0.35)
    for v in nbm.verts: v.co.z += 0.175
    # Inner nest bowl depression
    bmesh.ops.create_cone(nbm, cap_ends=True, segments=10, radius1=2.6, radius2=2.4, depth=0.45)
    for v in nbm.verts[-22:]: v.co.z += 0.35 + 0.225
    # 4 Guardian Totem Pillars around the nest
    for i in range(4):
        ang = (2*math.pi*i)/4
        px = 2.4 * math.cos(ang); py = 2.4 * math.sin(ang)
        bmesh.ops.create_cone(nbm, cap_ends=True, segments=6, radius1=0.35, radius2=0.20, depth=2.4)
        for v in nbm.verts[-14:]:
            v.co.x += px; v.co.y += py; v.co.z += 0.35 + 1.2
    m_stone = bpy.data.meshes.new("PetNursery_NestDais")
    nbm.to_mesh(m_stone); nbm.free()
    o_stone = bpy.data.objects.new("PetNursery_NestDais", m_stone)
    bpy.context.collection.objects.link(o_stone); o_stone.data.materials.append(mat_stone)

    # 2. Floating Celestial Mythical Egg
    ebm = bmesh.new()
    # Ovoid egg shape floating at Z = 2.4
    cz = 2.3
    # Stacked oval rings
    egg_profile = [(0.0, 0.15), (0.35, 0.55), (0.85, 0.75), (1.35, 0.65), (1.75, 0.40), (2.1, 0.1)]
    ring_verts = []
    v_bot = ebm.verts.new((0, 0, cz))
    for pz, pr in egg_profile:
        ring = []
        for k in range(10):
            ang = (2*math.pi*k)/10
            ring.append(ebm.verts.new((pr*math.cos(ang), pr*math.sin(ang), cz + pz)))
        ring_verts.append(ring)
    v_top = ebm.verts.new((0, 0, cz + 2.25))
    ebm.verts.ensure_lookup_table()
    for k in range(10): ebm.faces.new((v_bot, ring_verts[0][(k+1)%10], ring_verts[0][k]))
    for r in range(len(ring_verts)-1):
        for k in range(10):
            ebm.faces.new((ring_verts[r][k], ring_verts[r][(k+1)%10], ring_verts[r+1][(k+1)%10], ring_verts[r+1][k]))
    for k in range(10): ebm.faces.new((v_top, ring_verts[-1][k], ring_verts[-1][(k+1)%10]))
    m_egg = bpy.data.meshes.new("PetNursery_Egg")
    ebm.to_mesh(m_egg); ebm.free()
    o_egg = bpy.data.objects.new("PetNursery_Egg", m_egg)
    bpy.context.collection.objects.link(o_egg); o_egg.data.materials.append(mat_egg)

    # 3. Golden Angelic Wing Crests & Halo Cradle
    wbm = bmesh.new()
    # Dual golden wings flanking the floating egg
    for side in [-1, 1]:
        w_root = (side * 0.65, 0, cz + 1.0)
        w_tip  = (side * 1.55, -0.2, cz + 2.2)
        w_mid  = (side * 1.40,  0.2, cz + 1.4)
        w_bot  = (side * 0.75,  0.0, cz + 0.6)
        v1 = wbm.verts.new(w_root)
        v2 = wbm.verts.new(w_tip)
        v3 = wbm.verts.new(w_mid)
        v4 = wbm.verts.new(w_bot)
        wbm.faces.new((v1, v2, v3))
        wbm.faces.new((v1, v3, v4))
    # Golden Orbiting Rune Ring
    r_o = 1.35; r_i = 1.25
    for k in range(16):
        a1 = (2*math.pi*k)/16; a2 = (2*math.pi*(k+1))/16
        tilt = 0.25 * math.sin(a1)
        tilt2 = 0.25 * math.sin(a2)
        wbm.faces.new((
            wbm.verts.new((r_o*math.cos(a1), r_o*math.sin(a1), cz + 1.1 + tilt)),
            wbm.verts.new((r_o*math.cos(a2), r_o*math.sin(a2), cz + 1.1 + tilt2)),
            wbm.verts.new((r_i*math.cos(a2), r_i*math.sin(a2), cz + 1.1 + tilt2)),
            wbm.verts.new((r_i*math.cos(a1), r_i*math.sin(a1), cz + 1.1 + tilt))
        ))
    m_gold = bpy.data.meshes.new("PetNursery_GoldenWings")
    wbm.to_mesh(m_gold); wbm.free()
    o_gold = bpy.data.objects.new("PetNursery_GoldenWings", m_gold)
    bpy.context.collection.objects.link(o_gold); o_gold.data.materials.append(mat_gold)

    export_station("Station_Mascotas", [o_stone, o_egg, o_gold])
    render_station_preview("preview_station_mascotas.png", (5.2, -6.5, 4.8), (math.radians(65), 0, math.radians(38)), (0.2, 1.0, 0.7))

# Execute all 4 stations
print("=== GENERATING 4 STATIONS IN BLENDER ===")
build_market_station()
build_forge_station()
build_enchant_station()
build_pet_nursery_station()
print("=== ALL 4 STATIONS GENERATED & EXPORTED SUCCESSFULLY ===")
