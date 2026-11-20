import bpy
import math
import os

# Helper to render current scene
def render_current_scene(out_path):
    bpy.context.scene.render.resolution_x = 960
    bpy.context.scene.render.resolution_y = 600
    world = bpy.context.scene.world
    if not world:
        world = bpy.data.worlds.new("ShowcaseWorld")
        bpy.context.scene.world = world
    world.use_nodes = True
    bg_node = world.node_tree.nodes.get("Background")
    if bg_node:
        bg_node.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
        bg_node.inputs['Strength'].default_value = 0.5

    cam_data = bpy.data.cameras.new("ShowcaseCam")
    cam_data.lens = 45
    cam_obj = bpy.data.objects.new("ShowcaseCam", cam_data)
    bpy.context.collection.objects.link(cam_obj)
    bpy.context.scene.camera = cam_obj
    cam_obj.location = (8.5, -8.5, 6.2)
    cam_obj.rotation_euler = (math.radians(62), 0, math.radians(45))

    # Center Light
    l1 = bpy.data.lights.new("CoreL", 'POINT')
    l1.energy = 2000
    l1.color = (1.0, 0.6, 0.2)
    lo1 = bpy.data.objects.new("CoreL", l1)
    lo1.location = (0, 0, 3.6)
    bpy.context.collection.objects.link(lo1)

    # Key
    l2 = bpy.data.lights.new("KeyL", 'POINT')
    l2.energy = 1500
    l2.color = (1.0, 0.9, 0.8)
    lo2 = bpy.data.objects.new("KeyL", l2)
    lo2.location = (6.0, -5.0, 7.0)
    bpy.context.collection.objects.link(lo2)

    bpy.context.scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)
    print(f"Rendered: {out_path}")

# Import Tier 5 (Fénix) and render
output_dir = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\pedestals"
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=os.path.join(output_dir, "Sanctum_Tier5_Fenix_Combined.fbx"))
render_current_scene(os.path.join(output_dir, "preview_tier5_fenix.png"))

# Import Tier 7 (Vórtice) and render
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=os.path.join(output_dir, "Sanctum_Tier7_Vortice_Combined.fbx"))
render_current_scene(os.path.join(output_dir, "preview_tier7_vortice.png"))
