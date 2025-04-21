extends Node
class_name WindowManager
## Coordinates all the visible windows

const _PREFAB_CREATE_MORPHOLOGY: PackedScene = preload("res://BrainVisualizer/UI/Windows/CreateMorphology/WindowCreateMorphology.tscn")
const _PREFAB_MAPPING_EDITOR: PackedScene = preload("res://BrainVisualizer/UI/Windows/MappingEditor/WindowMappingEditor.tscn")
const _PREFAB_MORPHOLOGY_MANAGER: PackedScene = preload("res://BrainVisualizer/UI/Windows/MorphologyManager/WindowMorphologyManager.tscn")
const _PREFAB_CREATE_CORTICAL: PackedScene = preload("res://BrainVisualizer/UI/Windows/CreateCorticalArea/WindowCreateCorticalArea.tscn")
const _PREFAB_QUICK_CONNECT: PackedScene = preload("res://BrainVisualizer/UI/Windows/QuickConnect/WindowQuickConnect.tscn")
const _PREFAB_QUICK_CONNECT_NEURON: PackedScene = preload("res://BrainVisualizer/UI/Windows/QuickConnectNeuron/WindowQuickConnectNeuron.tscn")
const _PREFAB_CORTICAL_VIEW: PackedScene = preload("res://BrainVisualizer/UI/Windows/View_Cortical_Areas/WindowViewCorticalArea.tscn")
const _PREFAB_QUICK_MENU: PackedScene = preload("res://BrainVisualizer/UI/Windows/QuickMenu/WindowQuickMenu.tscn")
const _PREFAB_CLONE_CORTICAL: PackedScene = preload("res://BrainVisualizer/UI/Windows/CloneCorticalArea/WindowCloneCorticalArea.tscn")
const _PREFAB_IMPORT_AMALGAMATION: PackedScene = preload("res://BrainVisualizer/UI/Windows/AmalgamationRequest/WindowAmalgamationRequest.tscn")
const _PREFAB_CONFIGURABLE_POPUP: PackedScene = preload("res://BrainVisualizer/UI/Windows/ConfigurablePopup/WindowConfigurablePopup.tscn")
const _PREFAB_DEVELOPER_OPTIONS: PackedScene = preload("res://BrainVisualizer/UI/Windows/Developer_Options/WindowDeveloperOptions.tscn")
const _PREFAB_SELECT_GENOME_OBJECT: PackedScene = preload("res://BrainVisualizer/UI/Windows/SelectGenomeObject/WindowSelectGenomeObject.tscn")
const _PREFAB_CREATE_REGION: PackedScene = preload("res://BrainVisualizer/UI/Windows/CreateRegion/WindowCreateRegion.tscn")
const _PREFAB_EDIT_REGION: PackedScene = preload("res://BrainVisualizer/UI/Windows/EditRegion/WindowEditRegion.tscn")
const _PREFAB_MOVE_TO_REGION: PackedScene = preload("res://BrainVisualizer/UI/Windows/AddToRegion/WindowAddToRegion.tscn")
const _PREFAB_CONFIRM_DELETION: PackedScene = preload("res://BrainVisualizer/UI/Windows/ConfirmDeletion/WindowConfirmDeletion.tscn")
const _PREFAB_ADV_CORTICAL_PROPERTIES: PackedScene = preload("res://BrainVisualizer/UI/Windows/AdvancedCorticalProperties/AdvancedCorticalProperties.tscn")
const _PREFAB_OPTIONS: PackedScene = preload("res://BrainVisualizer/UI/Windows/OptionsMenu/WindowOptionsMenu.tscn")
const _PREFAB_VIEW_PREVIEWS: PackedScene = preload("res://BrainVisualizer/UI/Windows/ViewPreviews/WindowViewPreviews.tscn")


var loaded_windows: Dictionary

var _window_memory_states: Dictionary = {
}

func spawn_options() -> void:
	var options_window: WindowOptionsMenu = _default_spawn_window(_PREFAB_OPTIONS, WindowOptionsMenu.WINDOW_NAME) as WindowOptionsMenu
	options_window.setup()

func spawn_adv_cortical_properties(cortical_areas: Array[AbstractCorticalArea]) -> void:
	var cortical_window: AdvancedCorticalProperties = _default_spawn_window(_PREFAB_ADV_CORTICAL_PROPERTIES, AdvancedCorticalProperties.WINDOW_NAME) as AdvancedCorticalProperties
	cortical_window.setup(cortical_areas)

func spawn_create_morphology() -> void:
	var create_morphology: WindowCreateMorphology = _default_spawn_window(_PREFAB_CREATE_MORPHOLOGY, WindowCreateMorphology.WINDOW_NAME) as WindowCreateMorphology
	create_morphology.setup()

func spawn_manager_morphology(morphology_to_preload: BaseMorphology = null) -> void:
	var morphology_manager: WindowMorphologyManager = _default_spawn_window(_PREFAB_MORPHOLOGY_MANAGER, WindowMorphologyManager.WINDOW_NAME) as WindowMorphologyManager
	morphology_manager.setup(morphology_to_preload)

func spawn_developer_options() -> void:
	var developer_window: WindowDeveloperOptions = _default_spawn_window(_PREFAB_DEVELOPER_OPTIONS, WindowDeveloperOptions.WINDOW_NAME)
	developer_window.setup()

func spawn_mapping_editor(source: GenomeObject, destination: GenomeObject, partial_mapping: PartialMappingSet = null) -> WindowMappingEditor:
	var mapping_editor: WindowMappingEditor = _default_spawn_window(_PREFAB_MAPPING_EDITOR, WindowMappingEditor.WINDOW_NAME) as WindowMappingEditor
	mapping_editor.setup(source, destination, partial_mapping)
	return mapping_editor

func spawn_create_cortical() -> void:
	var create_cortical: WindowCreateCorticalArea = _default_spawn_window(_PREFAB_CREATE_CORTICAL, WindowCreateCorticalArea.WINDOW_NAME) as WindowCreateCorticalArea
	create_cortical.setup()

func spawn_confirm_deletion(objects_to_delete: Array[GenomeObject], is_deleting_single_region_internals_instead_of_raising: bool = false) -> void:
	var confirm_deletion: WindowConfirmDeletion = _default_spawn_window(_PREFAB_CONFIRM_DELETION, WindowConfirmDeletion.WINDOW_NAME) as WindowConfirmDeletion
	confirm_deletion.setup(objects_to_delete, is_deleting_single_region_internals_instead_of_raising)

func spawn_clone_cortical(cloning_from: AbstractCorticalArea) -> void:
	var clone_cortical: WindowCloneCorticalArea = _default_spawn_window(_PREFAB_CLONE_CORTICAL, WindowCloneCorticalArea.WINDOW_NAME) as WindowCloneCorticalArea
	clone_cortical.setup(cloning_from)

func spawn_quick_connect(initial_source_area: AbstractCorticalArea = null) -> void:
	var quick_connect: WindowQuickConnect = _default_spawn_window(_PREFAB_QUICK_CONNECT, WindowQuickConnect.WINDOW_NAME) as WindowQuickConnect
	quick_connect.setup(initial_source_area)

func spawn_quick_connect_neuron(mode: WindowQuickConnectNeuron.MODE, initial_source_area: AbstractCorticalArea = null) -> void:
	var quick_connect_neuron: WindowQuickConnectNeuron = _default_spawn_window(_PREFAB_QUICK_CONNECT_NEURON, WindowQuickConnectNeuron.WINDOW_NAME) as WindowQuickConnectNeuron
	quick_connect_neuron.setup(mode, initial_source_area)

func spawn_cortical_view() -> void:
	var view_cortical: WindowViewCorticalArea = _default_spawn_window(_PREFAB_CORTICAL_VIEW, WindowViewCorticalArea.WINDOW_NAME) as WindowViewCorticalArea
	view_cortical.setup()

func spawn_select_genome_object(view_config: SelectGenomeObjectSettings) -> WindowSelectGenomeObject:
	var select_genome_object: WindowSelectGenomeObject = _default_spawn_window(_PREFAB_SELECT_GENOME_OBJECT, WindowSelectGenomeObject.WINDOW_NAME) as WindowSelectGenomeObject
	select_genome_object.setup(view_config)
	return select_genome_object

func spawn_popup(popup_definition: ConfigurablePopupDefinition) -> WindowConfigurablePopup:
	var configurable_popup: WindowConfigurablePopup = _default_spawn_window(_PREFAB_CONFIGURABLE_POPUP, popup_definition.window_name) as WindowConfigurablePopup
	configurable_popup.setup(popup_definition)
	return configurable_popup

func spawn_create_region(parent_region: BrainRegion, selected_objects: Array[GenomeObject]) -> void:
	var create_region: WindowCreateRegion = _default_spawn_window(_PREFAB_CREATE_REGION, WindowCreateRegion.WINDOW_NAME) as WindowCreateRegion
	create_region.setup(parent_region, selected_objects)

func spawn_edit_region(editing_region: BrainRegion) -> void:
	var edit_region: WindowEditRegion = _default_spawn_window(_PREFAB_EDIT_REGION, WindowEditRegion.WINDOW_NAME) as WindowEditRegion
	edit_region.setup(editing_region)

func spawn_move_to_region(objects: Array[GenomeObject], starting_region: BrainRegion) -> void:
	var move_to_region: WindowAddToRegion = _default_spawn_window(_PREFAB_MOVE_TO_REGION, WindowAddToRegion.WINDOW_NAME) as WindowAddToRegion
	move_to_region.setup(objects, starting_region)

func spawn_quick_cortical_menu(selected_objects: Array[GenomeObject]) -> void:
	var quick_cortical_menu: QuickCorticalMenu = _default_spawn_window(_PREFAB_QUICK_MENU, QuickCorticalMenu.WINDOW_NAME) as QuickCorticalMenu
	quick_cortical_menu.setup(selected_objects)

func spawn_view_previews() -> void:
	var view_previews: WindowViewPreviews = _default_spawn_window(_PREFAB_VIEW_PREVIEWS, WindowViewPreviews.WINDOW_NAME) as WindowViewPreviews
	view_previews.setup()

func spawn_amalgamation_window(amalgamation_ID: StringName, genome_title: StringName, circuit_size: Vector3i) -> void:
	if "import_amalgamation" in loaded_windows:
		return # no need to keep opening this window
	var import_amalgamation: WindowAmalgamationRequest = _default_spawn_window(_PREFAB_IMPORT_AMALGAMATION, WindowAmalgamationRequest.WINDOW_NAME) as WindowAmalgamationRequest
	import_amalgamation.setup(amalgamation_ID, genome_title, circuit_size)

func force_close_window(window_name: StringName) -> void:
	if window_name in loaded_windows.keys():
		_window_memory_states[window_name] = loaded_windows[window_name].export_window_details()
		loaded_windows[window_name].queue_free()
		loaded_windows.erase(window_name)

func bring_window_to_top(window: Control) -> void:
		print("UI: WINDOW: Changing window order...")
		move_child(window, -1)

func force_close_all_windows() -> void:
	print("UI: All windows being forced closed")
	for window in loaded_windows.keys():
		force_close_window(window)

func _default_spawn_window(prefab: PackedScene, window_name: StringName, force_close_if_open: bool = true) -> BaseDraggableWindow:
	if (window_name in loaded_windows.keys()) && force_close_if_open:
		loaded_windows[window_name].close_window()
	var new_window: BaseDraggableWindow = prefab.instantiate()
	add_child(new_window)
	loaded_windows[window_name] = new_window
	new_window.close_window_requested.connect(force_close_window)
	# if we have no memopry of the window, load the defaults from the window itself
	if window_name not in _window_memory_states:
		_window_memory_states[window_name] = new_window.export_default_window_details()
	else:
		new_window.import_window_details(_window_memory_states[window_name])
	new_window.position = _window_memory_states[window_name]["position"]
	bring_window_to_top(new_window)
	new_window.bring_window_to_top_request.connect(_bring_window_to_top_str)
	return new_window

func _bring_window_to_top_str(window_name: StringName) -> void:
	if !(window_name in loaded_windows):
		push_error("WindowManager: Unknown window %s!" % window_name)
		return
	bring_window_to_top(loaded_windows[window_name])
