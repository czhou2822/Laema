@tool
extends RefCounted
## Discovers numeric level columns from the same metadata as the normal controls.

const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")
const ReactionRanges = preload("res://scripts/config/combat_reaction_ranges.gd")


static func tables(config: Dictionary, section: String) -> Array:
	if section == "moves":
		return _impact_tables(config)
	var grouped: Dictionary = {}
	for field in Catalog.fields(config, section):
		var keys: Array = field["path"]
		if keys.size() < 4 or not keys[-2] is int or field["kind"] != "number":
			continue
		var path := keys.slice(0, keys.size() - 2)
		var levels: Variant = Store.read_value(config, path)
		if not levels is Array or levels.size() < 2:
			continue
		var id := Store.path_label(path)
		if not grouped.has(id):
			grouped[id] = {"id": id, "path": path, "section": section, "columns": {}}
		var key: String = keys.back()
		var columns: Dictionary = grouped[id]["columns"]
		if not columns.has(key):
			columns[key] = {"key": key, "label": field["label"], "unit": field["unit"], "cells": []}
		var cell: Dictionary = field.duplicate(true)
		cell["row"] = keys[-2]
		columns[key]["cells"].append(cell)
	var result: Array = []
	for table in grouped.values():
		var columns: Array = []
		for column in table["columns"].values():
			column["cells"].sort_custom(func(a: Dictionary, b: Dictionary): return a["row"] < b["row"])
			var editable := 0
			for cell in column["cells"]:
				if not cell["readonly"]:
					editable += 1
			if editable >= 2:
				columns.append(column)
		if not columns.is_empty():
			table["columns"] = columns
			result.append(table)
	return result


static func _impact_tables(config: Dictionary) -> Array:
	var definitions: Dictionary = {}
	for field in Catalog.fields(config, "moves"):
		definitions[field["id"]] = field
	var result: Array = []
	for school in ["fire", "water", "air", "earth"]:
		var paths: Array = []
		var cells: Array = []
		var labels: Array = []
		for position in range(1, 6):
			var path: Array = ["moves", "%s_x%d" % [school, position]]
			var id := Store.path_label(path + ["impact"])
			if not definitions.has(id):
				continue
			var field: Dictionary = definitions[id].duplicate(true)
			field["row"] = position - 1
			paths.append(path)
			cells.append(field)
			labels.append("X%d" % position)
		if cells.size() == 5:
			result.append({"id": "moves." + school, "path": ["moves"], "section": "moves",
				"title": school.capitalize() + " X1–X5 Impact", "group": school.capitalize() + " / X1–X5",
				"row_paths": paths, "row_heading": "Move", "row_labels": labels,
				"columns": [{"key": "impact", "label": "Impact", "unit": "", "cells": cells}]})
	return result


static func rows(config: Dictionary, table: Dictionary) -> Array:
	if table.has("row_paths"):
		var result: Array = []
		for path in table["row_paths"]:
			result.append(Store.read_value(config, path))
		return result
	var source: Variant = Store.read_value(config, table["path"])
	return source if source is Array else []


static func initial_rule(config: Dictionary, column: Dictionary) -> Dictionary:
	var editable: Array = []
	for cell in column["cells"]:
		if not cell["readonly"]:
			editable.append(cell)
	var first: Dictionary = editable[0]
	var second: Dictionary = editable[1]
	var start: float = Store.read_value(config, first["path"])
	var next: float = Store.read_value(config, second["path"])
	return {"start": start, "increment": (next - start) / float(second["row"] - first["row"]), "start_row": first["row"], "field": first}


static func fill(config: Dictionary, table: Dictionary, rules: Dictionary) -> Dictionary:
	if rules.is_empty():
		return {"ok": false, "error": "Select at least one numeric column to fill."}
	var source := rows(config, table)
	if source.size() < 2:
		return {"ok": false, "error": "The level table is missing or too short. Refresh Fill series."}
	var candidate: Array = source.duplicate(true)
	var changes: Array = []
	for key in rules:
		var column: Dictionary = {}
		for entry in table["columns"]:
			if entry["key"] == key:
				column = entry
		if column.is_empty() or not rules[key] is Dictionary:
			return {"ok": false, "error": "Only editable numeric level columns support series fill."}
		var rule: Dictionary = rules[key]
		for component in ["start", "increment"]:
			var number: Variant = rule.get(component)
			if not (number is float or number is int) or not is_finite(float(number)):
				return {"ok": false, "error": "Series start and increment must be finite numbers."}
		var first_row: int = initial_rule(config, column)["start_row"]
		for cell in column["cells"]:
			if cell["readonly"]:
				continue
			var row: int = cell["row"]
			if row >= candidate.size() or not candidate[row] is Dictionary or not candidate[row].has(key):
				return {"ok": false, "error": "The level table changed. Refresh Fill series."}
			var value := snappedf(float(rule["start"]) + float(rule["increment"]) * (row - first_row), float(cell["step"]))
			if not is_finite(value) or value < float(cell["minimum"]) or (not cell["allow_greater"] and value > float(cell["maximum"])):
				return {"ok": false, "error": "Level %d %s is outside its allowed range." % [row + 1, column["label"]]}
			var number: Variant = int(round(value)) if cell["integer"] else value
			if candidate[row][key] != number:
				changes.append({"path": cell["path"], "after": number})
			candidate[row][key] = number
	if table["path"] == ["hit_reaction", "combat_levels"]:
		var error := ReactionRanges.validation_error(candidate)
		if not error.is_empty():
			return {"ok": false, "error": error}
	return {"ok": true, "error": "", "levels": candidate, "changes": changes}
