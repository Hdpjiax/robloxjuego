import bpy
import math

bpy.context.scene.render.resolution_x = 1080
bpy.context.scene.render.resolution_y = 675
bpy.context.scene.render.film_transparent = False

# Atmospheric World
world = bpy.context.scene.world
if not world:
    world = bpy.data.worlds.new("SanctumWorld")
    bpy.context.scene.world = world
world.use_nodes = True
bg_node = world.node_tree.nodes.get("Background")
if bg_node:
    bg_node.inputs['Color'].default_value = (0.04, 0.05, 0.08, 1.0)
    bg_node.inputs['Strength'].default_value = 0.6

# Add Camera positioned to capture the wider multi-player sanctum
cam_data = bpy.data.cameras.new("GrandCam")
cam_data.lens = 45
cam_obj = bpy.data.objects.new("GrandCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj

# Camera distance for 9m wide structure
cam_obj.location = (8.5, -8.5, 6.2)
cam_obj.rotation_euler = (math.radians(62), 0, math.radians(45))

# Arcane Lighting Setup
# Central core illumination
core_light_data = bpy.data.lights.new(name="CoreLight", type='POINT')
core_light_data.energy = 2200
core_light_data.color = (0.0, 0.85, 1.0)
core_light_obj = bpy.data.objects.new("CoreLight", core_light_data)
core_light_obj.location = (0, 0, 3.6)
bpy.context.collection.objects.link(core_light_obj)

# Key Light (Moonlight / Arcane Cyan)
key_light_data = bpy.data.lights.new(name="KeyLight", type='POINT')
key_light_data.energy = 1500
key_light_data.color = (0.75, 0.90, 1.0)
key_light_obj = bpy.data.objects.new("KeyLight", key_light_data)
key_light_obj.location = (6.0, -5.0, 7.0)
bpy.context.collection.objects.link(key_light_obj)

# Rim Light (Magenta/Deep Purple for magical contrast)
rim_light_data = bpy.data.lights.new(name="RimLight", type='POINT')
rim_light_data.energy = 1800
rim_light_data.color = (0.65, 0.2, 0.95)
rim_light_obj = bpy.data.objects.new("RimLight", rim_light_data)
rim_light_obj.location = (-6.5, 6.5, 4.0)
bpy.context.collection.objects.link(rim_light_obj)

preview_path = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\pedestals\preview_grand_sanctum.png"
bpy.context.scene.render.filepath = preview_path
bpy.ops.render.render(write_still=True)
print(f"RENDER COMPLETE: {preview_path}")
