extends OptionButton
class_name TemplateDropDown

signal template_picked(template: CorticalTemplate)

@export var _template_type: AbstractCorticalArea.CORTICAL_AREA_TYPE

var template_type: AbstractCorticalArea.CORTICAL_AREA_TYPE:
	get: return _template_type
	set(v):
		_template_type = v
		load_cortical_type_options(v)

var _stored_template_references: Array[CorticalTemplate] = []
var _default_width: float

func _ready() -> void:
	_default_width = custom_minimum_size.x
	load_cortical_type_options(_template_type)
	item_selected.connect(_on_user_pick)
	BV.UI.theme_changed.connect(_on_theme_change)
	_on_theme_change()

func load_cortical_type_options(type: AbstractCorticalArea.CORTICAL_AREA_TYPE) -> void:
	clear()
	_stored_template_references = []
	match(type):
		AbstractCorticalArea.CORTICAL_AREA_TYPE.IPU:
			for template: CorticalTemplate in FeagiCore.feagi_local_cache.IPU_templates.values():
				if !template.is_enabled:
					continue
				_stored_template_references.append(template)
				add_item(template.cortical_name)
		AbstractCorticalArea.CORTICAL_AREA_TYPE.OPU:
			for template: CorticalTemplate in FeagiCore.feagi_local_cache.OPU_templates.values():
				if !template.is_enabled:
					continue
				_stored_template_references.append(template)
				add_item(template.cortical_name)
		_:
			push_error("Unknown cortical area type for Template Drop Down!")

func get_selected_template() -> CorticalTemplate:
	return _stored_template_references[selected]

func _on_user_pick(index: int) -> void:
	template_picked.emit(_stored_template_references[index])

func _on_theme_change(_new_theme: Theme = null) -> void:
	custom_minimum_size.x = _default_width * BV.UI.loaded_theme_scale.x
