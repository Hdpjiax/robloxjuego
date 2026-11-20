import bpy
import math

# Setup camera and lighting for beauty shot render
# Set render engine
bpy.context.scene.render.engine = 'BLENDER_EEVEE_NEXT' if hasattr(bpy.types, 'RenderSettings') and 'BLENDER_EEVEE_NEXT' in [e.identifier for e in bpy.types.RenderSettings.bl_rna.properties['engine'].enum_items] else 'BLENDER_EEVEE'

bpy.context.scene.render.resolution_x = 960
bpy.context.scene.render.resolution_y = 600
bpy.context.scene.render.film_transparent = False

# Background color (dark atmospheric studio)
world = bpy.context.scene.world
if not world:
    world = bpy.data.worlds.new("StudioWorld")
    bpy.context.scene.world = world
world.use_nodes = True
bg_node = world.node_tree.nodes.get("Background")
if bg_node:
    bg_node.inputs['Color'].default_value = (0.05, 0.06, 0.09, 1.0)
    bg_node.inputs['Strength'].default_value = 0.5

# Add Camera
cam_data = bpy.data.cameras.new("RenderCam")
cam_data.lens = 50
cam_obj = bpy.data.objects.new("RenderCam", cam_data)
bpy.context.collection.objects.link(cam_obj)
bpy.context.scene.camera = cam_obj

# Position camera (isometric 3/4 view looking down at pedestal)
cam_obj.location = (4.5, -4.5, 3.2)
# Rotation towards center (0, 0, 0.8)
cam_obj.rotation_euler = (math.radians(65), 0, math.radians(45))

# Key light (Warm arcane white/cyan)
key_light_data = bpy.data.lights.new(name="KeyLight", type='POINT')
key_light_data.energy = 800
key_light_data.color = (0.7, 0.9, 1.0)
key_light_obj = bpy.data.objects.new("KeyLight", key_light_data)
key_light_obj.location = (3.5, -2.5, 4.0)
bpy.context.collection.objects.link(key_light_obj)

# Rim light (Vibrant Cyan)
rim_light_data = bpy.data.lights.new(name="RimLight", type='POINT')
rim_light_data.energy = 1200
rim_light_data.color = (0.0, 0.8, 1.0)
rim_light_obj = bpy.data.objects.new("RimLight", rim_light_data)
rim_light_obj.location = (-3.5, 3.5, 2.5)
bpy.context.collection.objects.link(rim_light_obj)

# Fill light (Subtle soft purple)
fill_light_data = bpy.data.lights.new(name="FillLight", type='POINT')
fill_light_data.energy = 300
fill_light_data.color = (0.6, 0.4, 0.9)
fill_light_obj = bpy.data.objects.new("FillLight", fill_light_data)
fill_light_obj.location = (-3.0, -3.0, 2.0)
bpy.context.collection.objects.link(fill_light_obj)

preview_path = r"c:\Users\Antonio Garcia\Downloads\robloxjuego\assets\models\pedestals\preview_tier1.png"
bpy.context.scene.render.filepath = preview_path
bpy.ops.render.render(write_still=True)
print(f"RENDER COMPLETE: {preview_path}")
