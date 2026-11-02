## Slides target nodes from one set of anchor positions to another.
class_name SlideToAnchorStep extends SlideStep


@export var animatedNodePaths : Array[NodePath]: set = _set_animatedNodePaths
@export var target_anchors := Vector4.INF ## Left, Top, Right, Bottom. Same as specified in editor.
# @export var target_position := Vector2.ZERO
# enum AXES { X, Y, BOTH }
# @export var axis: AXES = AXES.BOTH

var _animatedNodes : Array[Node]
var _old_anchors : Dictionary
var _slideTween: Tween


func _set_animatedNodePaths(new_value: Array) -> void:
  animatedNodePaths = new_value
  _animatedNodes = []
  if not slide:
    await slide_set
    if not slide.is_inside_tree():
      await slide.tree_entered
  for animatedNodePath in animatedNodePaths:
    _animatedNodes.push_back(slide.get_node(animatedNodePath))


func _get_destination_anchors(targetNode: Control) -> Vector4:
  return Vector4(
    target_anchors.x if target_anchors.x < INF else targetNode.anchor_left,
    target_anchors.y if target_anchors.y < INF else targetNode.anchor_top,
    target_anchors.z if target_anchors.z < INF else targetNode.anchor_right,
    target_anchors.w if target_anchors.w < INF else targetNode.anchor_bottom,
  )


func _kill_tween() -> void:
  _slideTween.kill()
  _slideTween = null


func _update_old_anchors() -> void:
  _old_anchors = {}
  for animatedNode in _animatedNodes:
    _old_anchors[animatedNode] = Vector4(
        animatedNode.anchor_left,
        animatedNode.anchor_top,
        animatedNode.anchor_right,
        animatedNode.anchor_bottom,
    )


# Runs when the slide moves to the next step.
func next() -> void:
  step_next_began.emit()
  if _slideTween:
    _kill_tween()
  else:
    _update_old_anchors()
  
  _slideTween = slide.create_tween().set_parallel(true)
  for animatedNode in _animatedNodes:
    var destination_anchors := _get_destination_anchors(animatedNode)
    #print('DBG: animatedNode %s start %s destination %s' % [animatedNode.name, animatedNode.position, destination_position])
    _slideTween.tween_property(animatedNode, "anchor_left", destination_anchors.x, animation_duration).from(_old_anchors[animatedNode].x).set_ease(ease_type).set_trans(trans_type)
    _slideTween.tween_property(animatedNode, "anchor_top", destination_anchors.y, animation_duration).from(_old_anchors[animatedNode].y).set_ease(ease_type).set_trans(trans_type)
    _slideTween.tween_property(animatedNode, "anchor_right", destination_anchors.z, animation_duration).from(_old_anchors[animatedNode].z).set_ease(ease_type).set_trans(trans_type)
    _slideTween.tween_property(animatedNode, "anchor_bottom", destination_anchors.w, animation_duration).from(_old_anchors[animatedNode].w).set_ease(ease_type).set_trans(trans_type)
  
  await _slideTween.finished
  _slideTween = null
  step_next_ended.emit()
  
  
# Runs when the slide moves to the previous step.
func previous() -> void:
  step_previous_began.emit()
  if _slideTween:
    _kill_tween()
  
  _slideTween = slide.create_tween().set_parallel(true)
  for animatedNode in _animatedNodes:
    var origin_anchors := _get_destination_anchors(animatedNode)
    _slideTween.tween_property(animatedNode, "anchor_left", _old_anchors[animatedNode].x, animation_duration).from(origin_anchors.x).set_ease(ease_type).set_trans(trans_type)
    _slideTween.tween_property(animatedNode, "anchor_top", _old_anchors[animatedNode].y, animation_duration).from(origin_anchors.y).set_ease(ease_type).set_trans(trans_type)
    _slideTween.tween_property(animatedNode, "anchor_right", _old_anchors[animatedNode].z, animation_duration).from(origin_anchors.z).set_ease(ease_type).set_trans(trans_type)
    _slideTween.tween_property(animatedNode, "anchor_bottom", _old_anchors[animatedNode].w, animation_duration).from(origin_anchors.w).set_ease(ease_type).set_trans(trans_type)
  
  await _slideTween.finished
  _slideTween = null
  step_previous_ended.emit()
