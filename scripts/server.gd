extends Node3D

var server := TCPServer.new()
var connection = null

signal jump_signal
signal move_forward
signal move_backward
signal move_left
signal move_right
signal stop_signal

# Port number to listen for BCI commands
var port := 12345 

func _ready():
	# Start the server
	var error = server.listen(port)
	if error != OK:
		print("Error starting server on port ", port)
	else:
		print("Server listening on port ", port)

func _process(_delta):
	# Accept new clients if any are connecting
	if server.is_connection_available():
		connection = server.take_connection()

	# Handle incoming data from BCI
	if connection and connection.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		var data = connection.get_available_bytes()
		if data > 0:
			var received_commands = connection.get_utf8_string(data)
			var command_array = received_commands.split("\n") # In case there are more commands in one string
			for command in command_array:
				if command != "":
					handle_command(command)

func handle_command(command):
	match command:
		"jump":
			jump_signal.emit()
		"move_forward":
			move_forward.emit()
		"move_backward":
			move_backward.emit()
		"move_left":
			move_left.emit()
		"move_right":
			move_right.emit()
		"stop":
			stop_signal.emit()
		_:
			print("Unknown command: ", command)
