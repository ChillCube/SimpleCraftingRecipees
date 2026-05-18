extends Item
class_name CraftableItem

@export var materials: Array[Item] = []  ## Items needed to craft this (can have duplicates)
@export var byproducts: Array[Item] = []  ## Extra items received when crafting (can have duplicates)
@export var can_be_broken_down: bool = false
@export var broken_down_loss_blacklist: Array[Item] = []  ## Materials NOT returned when breaking down
@export var crafting_time : float = 0;

## Craft from inventory
func craft_from(inventory: Inventory) -> bool:
	# Check if we have all required materials
	if not can_craft(inventory):
		return false
	
	# Consume materials
	for material in materials:
		inventory.delete_item(material)
	
	# Add this item to inventory
	var new_item = duplicate()
	inventory.add_item(new_item)
	
	# Add byproducts
	for byproduct in byproducts:
		var byproduct_copy = byproduct.duplicate()
		inventory.add_item(byproduct_copy)
	
	return true

## Break down the item back into materials (respecting blacklist)
func break_down() -> Array[Item]:
	var items: Array[Item] = []
	
	if not can_be_broken_down:
		return items
	
	# Add materials back, skipping blacklisted ones
	for material in materials:
		if not _is_blacklisted(material):
			var material_copy = material.duplicate()
			items.append(material_copy)
	
	return items

## Check if item can be crafted with given inventory
func can_craft(inventory: Inventory) -> bool:
	# Create a copy of materials to track what we've found
	var needed_materials: Array[Item] = materials.duplicate()
	
	for item in inventory.items:
		var index = needed_materials.find(item)
		if index != -1:
			needed_materials.remove_at(index)
	
	return needed_materials.is_empty()

## Check if a material is blacklisted
func _is_blacklisted(material: Item) -> bool:
	for blacklisted in broken_down_loss_blacklist:
		if material == blacklisted:
			return true
	return false

## Get requirements as text
func get_requirements_text() -> String:
	if materials.is_empty():
		return "No materials required"
	
	# Count unique items and their quantities
	var material_counts: Dictionary = {}
	for material in materials:
		material_counts[material._name] = material_counts.get(material._name, 0) + 1
	
	var text = "Requires: "
	var idx = 0
	for material_name in material_counts.keys():
		var quantity = material_counts[material_name]
		text += "%dx %s" % [quantity, material_name]
		if idx < material_counts.size() - 1:
			text += ", "
		idx += 1
	
	return text

## Get crafting results as text (including byproducts)
func get_results_text() -> String:
	var results: Array[Item] = [self] + byproducts
	
	# Count unique items
	var item_counts: Dictionary = {}
	for item in results:
		item_counts[item._name] = item_counts.get(item._name, 0) + 1
	
	var text = "Produces: "
	var idx = 0
	for item_name in item_counts.keys():
		var quantity = item_counts[item_name]
		text += "%dx %s" % [quantity, item_name]
		if idx < item_counts.size() - 1:
			text += ", "
		idx += 1
	
	return text

## Get breakdown results as text (showing what you get back)
func get_breakdown_text() -> String:
	if not can_be_broken_down:
		return "Cannot be broken down"
	
	# Count materials that aren't blacklisted
	var item_counts: Dictionary = {}
	for material in materials:
		if not _is_blacklisted(material):
			item_counts[material._name] = item_counts.get(material._name, 0) + 1
	
	if item_counts.is_empty():
		return "Breaking down yields nothing (all materials lost)"
	
	var text = "Breakdown yields: "
	var idx = 0
	for item_name in item_counts.keys():
		var quantity = item_counts[item_name]
		text += "%dx %s" % [quantity, item_name]
		if idx < item_counts.size() - 1:
			text += ", "
		idx += 1
	
	# Show what's lost
	var lost_items: Dictionary = {}
	for material in materials:
		if _is_blacklisted(material):
			lost_items[material._name] = lost_items.get(material._name, 0) + 1
	
	if not lost_items.is_empty():
		text += "\nLost: "
		idx = 0
		for item_name in lost_items.keys():
			var quantity = lost_items[item_name]
			text += "%dx %s" % [quantity, item_name]
			if idx < lost_items.size() - 1:
				text += ", "
			idx += 1
	
	return text

## Get missing materials as array
func get_missing_materials(inventory: Inventory) -> Array[Item]:
	var missing: Array[Item] = []
	var needed_materials: Array[Item] = materials.duplicate()
	
	for item in inventory.items:
		var index = needed_materials.find(item)
		if index != -1:
			needed_materials.remove_at(index)
	
	return needed_materials

## Get percentage of materials you get back when breaking down
func get_breakdown_recovery_percentage() -> float:
	if materials.is_empty():
		return 0.0
	
	var total_materials: float = materials.size()
	var lost_materials: float = 0.0
	
	for material in materials:
		if _is_blacklisted(material):
			lost_materials += 1
	
	return (total_materials - lost_materials) / total_materials
