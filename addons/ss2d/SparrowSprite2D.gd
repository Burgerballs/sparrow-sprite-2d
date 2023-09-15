@tool
extends AnimatedSprite2D
class_name SparrowSprite2D

var frames:SpriteFrames # this holds the converted sparrow data
var anim_holder:SpriteFrames # this holds the usable animations

func _init():
	anim_holder = SpriteFrames.new()

# THIS IS STOLEN FROM THE NOVA ENGINE BTW ALL CREDIT GOES TO THEM LOL!!!!!!!!!
func loadFrames(path, optimized) -> void:
	if path == "":
		return
	
	var base_path:StringName = path.get_basename()
	var texture:Texture = load(base_path + ".png")
	
	if texture == null:
		print(base_path + " loading failed.")
		return
	
	frames = SpriteFrames.new()
	frames.remove_animation("default")
	
	var xml:XMLParser = XMLParser.new()
	xml.open(base_path + ".xml")
	
	var previous_atlas:AtlasTexture
	var previous_rect:Rect2
	
	while xml.read() == OK:
		if xml.get_node_type() != XMLParser.NODE_TEXT:
			var node_name:StringName = xml.get_node_name()
			
			if node_name.to_lower() == "subtexture":
				var frame_data:AtlasTexture
				
				var animation_name = xml.get_named_attribute_value("name")
				animation_name = animation_name.left(len(animation_name) - 4)
				
				var frame_rect:Rect2 = Rect2(
					Vector2(
						xml.get_named_attribute_value("x").to_float(),
						xml.get_named_attribute_value("y").to_float()
					),
					Vector2(
						xml.get_named_attribute_value("width").to_float(),
						xml.get_named_attribute_value("height").to_float()
					)
				)
				
				if optimized and previous_rect == frame_rect:
					frame_data = previous_atlas
				else:
					frame_data = AtlasTexture.new()
					frame_data.atlas = texture
					frame_data.region = frame_rect
					
					if xml.has_attribute("frameX"):
						var margin:Rect2
						
						var raw_frame_x:int = xml.get_named_attribute_value("frameX").to_int()
						var raw_frame_y:int = xml.get_named_attribute_value("frameY").to_int()
						
						var raw_frame_width:int = xml.get_named_attribute_value("frameWidth").to_int()
						var raw_frame_height:int = xml.get_named_attribute_value("frameHeight").to_int()
						
						var frame_size_data:Vector2 = Vector2(
							raw_frame_width,
							raw_frame_height
						)
						
						if frame_size_data == Vector2.ZERO:
							frame_size_data = frame_rect.size
						
						margin = Rect2(Vector2(-raw_frame_x, -raw_frame_y),
								Vector2(raw_frame_width - frame_rect.size.x,
										raw_frame_height - frame_rect.size.y)
						)
						
						if margin.size.x < abs(margin.position.x):
							margin.size.x = abs(margin.position.x)
						if margin.size.y < abs(margin.position.y):
							margin.size.y = abs(margin.position.y)
						
						frame_data.margin = margin
					
					frame_data.filter_clip = true
					
					previous_atlas = frame_data
					previous_rect = frame_rect
				
				if not frames.has_animation(animation_name):
					frames.add_animation(animation_name)
					frames.set_animation_loop(animation_name, false)
					frames.set_animation_speed(animation_name, 24)
				
				frames.add_frame(animation_name, frame_data)


func add_anim_from_name(name:String, sparrow_anim_name:String, fps:int, loop:bool):
	anim_holder.add_animation(name)
	for i in frames.get_frame_count(sparrow_anim_name.replace('0', '')):
		anim_holder.add_frame(name, frames.get_frame_texture(sparrow_anim_name.replace('0', ''), i), 1, i)
		anim_holder.set_animation_speed(name, fps)
		anim_holder.set_animation_loop(name, loop)
	sprite_frames = anim_holder
		
func add_anim_from_indices(name:String, sparrow_anim_name:String, fps:int, loop:bool,indices:Array[int]):
	anim_holder.add_animation(name)
	for i in indices.size():
		var animnumber = indices[i]
		if animnumber > frames.get_frame_count(sparrow_anim_name.replace('0', ''))-1:
			animnumber = frames.get_frame_count(sparrow_anim_name.replace('0', ''))-1
		anim_holder.add_frame(name, frames.get_frame_texture(sparrow_anim_name.replace('0', ''), animnumber), 1, i)
		anim_holder.set_animation_speed(name, fps)
		anim_holder.set_animation_loop(name, loop)
	sprite_frames = anim_holder
