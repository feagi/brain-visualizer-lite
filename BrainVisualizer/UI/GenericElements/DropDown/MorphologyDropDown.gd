extends OptionButton
class_name MorphologyDropDown
## Dropdown specifically intended to list Morphologies by name

signal user_selected_morphology(morphology_reference: BaseMorphology)

## If true, show names in the dropdown instead of the cortical IDs
#@export var display_names_instead_of_IDs: bool = true
# If true, will automatically remove morphologies from the drop down that were removed from cache
@export var sync_removed_morphologies: bool = true
# If true, will automatically add morphologies from the drop down that were added to the cache
@export var sync_added_morphologies: bool = true

@export var load_available_morphologies_on_start = true

## If True, will hide the circle selection icon on the dropdown
@export var hide_circle_select_icon: bool = true

var _listed_morphologies: Array[BaseMorphology] = []
var _popup: PopupMenu
var _default_width: float

func _ready():
	_default_width = custom_minimum_size.x
	_popup = get_popup()
	if load_available_morphologies_on_start:
		reload_available_morphologies()
	item_selected.connect(_user_selected_option)
	if sync_removed_morphologies:
		FeagiCore.feagi_local_cache.morphologies.morphology_about_to_be_removed.connect(_morphology_was_deleted_from_cache)
	if sync_added_morphologies:
		FeagiCore.feagi_local_cache.morphologies.morphology_added.connect(_morphology_was_added_to_cache)
	BV.UI.theme_changed.connect(_on_theme_change)
	_on_theme_change()

func reload_available_morphologies() -> void:
	var morphologies: Array[BaseMorphology] = []
	morphologies.assign(FeagiCore.feagi_local_cache.morphologies.available_morphologies.values())
	overwrite_morphologies(morphologies)

## Clears all listed morphologies
func clear_all_morphologies() -> void:
	_listed_morphologies = []
	clear()

## Replace morphology listing with a new one
func overwrite_morphologies(new_morphology: Array[BaseMorphology]) -> void:
	clear_all_morphologies()
	for morphology in new_morphology:
		add_morphology(morphology)

## Add a singular morphology to the end of the drop down
func add_morphology(new_morphology: BaseMorphology) -> void:
	_listed_morphologies.append(new_morphology)
	add_item(new_morphology.name) # using name only since as of writing, morphologies do not have IDs
	if hide_circle_select_icon:
		_popup.set_item_as_radio_checkable(_popup.get_item_count() - 1, false) # Remove Circle Selection
	

## Retrieves selected morphology. If none is selected, returns a Null Morphology
func get_selected_morphology() -> BaseMorphology:
	if selected == -1: 
		return NullMorphology.new()
	return _listed_morphologies[selected]

## retrieves the morphology name of the selected morphology
## Returns "" if none is selected!
func get_selected_morphology_name() -> StringName:
	if selected == -1: 
		return &""
	return _listed_morphologies[selected].name

## Set the drop down selection to a specific (contained) morphology
func set_selected_morphology(set_morphology: BaseMorphology) -> void:
	var index: int = _listed_morphologies.find(set_morphology)
	if index == -1:
		push_warning("Attemped to set morphology drop down to an item that the drop down does not contain! Skipping!")
		return
	select(index)

func set_selected_morphology_by_name(morphology_name: StringName) -> void:
	if morphology_name not in FeagiCore.feagi_local_cache.morphologies.available_morphologies.keys():
		push_error("Attempted to set morphology dropdown to morphology not found in cache by name of " + morphology_name + ". Skipping!")
		return
	set_selected_morphology(FeagiCore.feagi_local_cache.morphologies.available_morphologies[morphology_name])

## Set the dropdown to select nothing
func deselect_all() -> void:
	select(-1)

## Remove morphology from listing
func remove_morphology(removing: BaseMorphology) -> void:
	var index: int = _listed_morphologies.find(removing)
	if index == -1:
		push_warning("Attempted to remove morphology that the drop down does not contain! Skipping!")
		return
	_listed_morphologies.remove_at(index)
	remove_item(index)

func _user_selected_option(index: int) -> void:
	user_selected_morphology.emit(_listed_morphologies[index])

func _morphology_was_deleted_from_cache(deleted_morphology: BaseMorphology) -> void:
	if deleted_morphology not in _listed_morphologies:
		return
	remove_morphology(deleted_morphology)

func _morphology_was_added_to_cache(added_morphology: BaseMorphology) -> void:
	if added_morphology not in _listed_morphologies:
		add_morphology(added_morphology)

func _on_theme_change(_new_theme: Theme = null) -> void:
	custom_minimum_size.x = _default_width * BV.UI.loaded_theme_scale.x
