@tool
extends VBoxContainer


@export var title := 'Your Slide Title!': set = _set_title
@export var show_bottom_line := true: set = _set_show_bottom_line

@onready var _slideHeaderLabel: RichTextLabel = $Indent/SlideHeader
@onready var _bottomLine = %Divider


func _set_show_bottom_line(new_value: bool) -> void:
  show_bottom_line = new_value
  if not is_node_ready():
    await ready
  _bottomLine.visible = show_bottom_line


func _set_title(new_value: String) -> void:
  title = new_value
  
  # TODO: Figure out why this works when editing from the tool script,
  # but not when initially setting the property.
  if not _slideHeaderLabel:
    await ready
  
  _slideHeaderLabel.text = '[b]%s[/b]' % title
