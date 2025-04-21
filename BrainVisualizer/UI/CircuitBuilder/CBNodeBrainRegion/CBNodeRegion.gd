extends CBNodeConnectableBase
class_name CBNodeRegion

var representing_region: BrainRegion:
	get: return _representing_region

var _representing_region: BrainRegion


## Called by CB right after instantiation
func setup(region_ref: BrainRegion) -> void:
	var input_path: NodePath = NodePath("Inputs")
	var output_path: NodePath = NodePath("Outputs")
	var recursive_path: NodePath = NodePath("") # Regions dont have recursives
	setup_base(recursive_path, input_path, output_path)
	
	_representing_region = region_ref
	CACHE_updated_region_name(region_ref.friendly_name)
	CACHE_updated_2D_position(region_ref.coordinates_2D)
	name = region_ref.region_ID
	
	_representing_region.friendly_name_updated.connect(CACHE_updated_region_name)
	_representing_region.coordinates_2D_updated.connect(CACHE_updated_2D_position)
	_representing_region.UI_highlighted_state_updated.connect(func(is_highlighted: bool): if is_highlighted != selected: selected = is_highlighted)
	# NOTE: Deletion of the of the region (node) is handled by CB

# Responses to changes in cache directly. NOTE: Connection and creation / deletion we won't do here and instead allow CB to handle it, since they can involve interactions with connections
#region CACHE Events and responses

## Updates the title text of the node
func CACHE_updated_region_name(name_text: StringName) -> void:
	title = name_text

## Updates the position within CB of the node
func CACHE_updated_2D_position(new_position: Vector2i) -> void:
	position_offset = new_position
	_dragged = false
	_on_node_move()


#endregion

#region User Interactions

func _on_single_left_click() -> void:
	BV.UI.selection_system.clear_all_highlighted()
	BV.UI.selection_system.add_to_highlighted(_representing_region)
	BV.UI.selection_system.select_objects(SelectionSystem.SOURCE_CONTEXT.FROM_CIRCUIT_BUILDER_CLICK)



func _on_double_left_click() -> void:
	double_clicked.emit(self)


signal double_clicked(self_ref: CBNodeRegion) ## Node was double clicked # TEMP



#func _gui_input(event):
#	var mouse_event: InputEventMouseButton
#	if event is InputEventMouseButton:
#		mouse_event = event as InputEventMouseButton
#		if mouse_event.double_click:
#			double_clicked.emit(self)
#			return
#		if mouse_event.is_pressed(): return
#		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
#			return
#		if !_dragged:
#			if _representing_region != null:
#				BV.UI.user_selected_single_cortical_area_independently(_representing_region)

	#	TODO TEMP

#endregion
