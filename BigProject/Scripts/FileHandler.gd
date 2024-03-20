class_name FileHandler extends Node

#region Data
static func save_data(filePath : String, data : Dictionary) -> void:
	if FileAccess.file_exists(filePath):
		# Opening file for writing
		var fileData = FileAccess.open(filePath, FileAccess.WRITE)
		if fileData == null:
			print("Cannot open file '" + filePath + "'.")
			fileData.close()
			return
		# Writing to file
		fileData.store_var(data)
		fileData.close()
	else:
		print("File '" + filePath + "' does not exist.")

static func load_data(filePath : String) -> Dictionary:
	if FileAccess.file_exists(filePath):
		# Opening file for reading
		var fileData = FileAccess.open(filePath, FileAccess.READ)
		if fileData == null:
			print("Cannot open file '" + filePath + "'.")
			return {}
		# Reading data
		var data : Dictionary
		var rawData : Variant = fileData.get_var()
		if rawData != null:
			data = rawData
		fileData.close()
		return data
	else:
		print("File '" + filePath + "' does not exist.")
	return {}
#endregion
	
#region JSON
static func save_json(filePath : String, data : Dictionary) -> void:
	if FileAccess.file_exists(filePath):
		# Opening file for writing
		var fileData = FileAccess.open(filePath, FileAccess.WRITE)
		if fileData == null:
			print("Cannot open file '" + filePath + "'.")
			fileData.close()
			return
		# Writing to file
		fileData.store_line(JSON.stringify(data, "\t", true, true))
		fileData.close()
	else:
		print("File '" + filePath + "' does not exist.")

static func load_json(filePath : String) -> Dictionary:
	if FileAccess.file_exists(filePath):
		# Opening file for reading
		var fileData = FileAccess.open(filePath, FileAccess.READ)
		if fileData == null:
			print("Cannot open file '" + filePath + "'.")
			return {}
		# Reading data
		var data : Dictionary
		var rawData = fileData.get_as_text()
		if rawData != null: 
			data = JSON.parse_string(rawData)
		fileData.close()
		return data
	else:
		print("File '" + filePath + "' does not exist.")
	return {}
#endregion
