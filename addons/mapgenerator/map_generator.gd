class_name MapGenerator extends RefCounted

var cell_generator := CellGenerator.new();

func run() -> void:
	cell_generator.run();
	
