note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			i := 0
			row := 0
			column :=0
			projectile_max_moves := 0
			player_max_moves := 0
			current_player_moves:= 0
			is_game_started:= False
			projectile_col:= 0
			is_fire:= False
			create arr.make_empty
			arr.force ("A", 1)
			arr.force ("B", 2)
			arr.force ("C", 3)
			arr.force ("D", 4)
			arr.force ("E", 5)
			arr.force ("F", 6)
			arr.force ("G", 7)
			arr.force ("H", 8)
			arr.force ("I", 9)
			arr.force ("J", 10)
			create projectile_pos.make(0)
			is_player_dead:= False
			create element_removed.default_create
			create history.make_empty
			cursor_position:= 0
			create error.make_empty
			create message.make_empty
			is_error:= False
			create message_array.make_empty
			create command_name.make_empty
			create player_move_starting_pos.default_create
			new_window:= True

		end

feature -- model attributes
	i : INTEGER
	row: INTEGER_32
	column: INTEGER_32
	projectile_max_moves: INTEGER_32
	player_max_moves: INTEGER_32
	is_game_started: BOOLEAN
	row_mov: INTEGER_32
	col_mov: INTEGER_32
	current_player_moves: INTEGER_32

	arr : ARRAY[STRING]
	ceil : REAL_32
	ceiling_num : REAL_64
	player_move_row: INTEGER
	player_move_col: INTEGER
	projectile_col: INTEGER
	projectile_row: INTEGER
	is_fire: BOOLEAN
	projectile_pos: ARRAYED_LIST[TUPLE[proj_row: INTEGER; proj_col: INTEGER; times: INTEGER]]
	is_player_dead: BOOLEAN
	element_removed: TUPLE[r:INTEGER;c: INTEGER; t: INTEGER]
	error: STRING
	message:STRING
	is_error: BOOLEAN
	message_array: ARRAY[STRING]
	command_name: STRING
	new_window: BOOLEAN
	state_normal: INTEGER
	state_error: INTEGER
	--something not to touch
	player_move_starting_pos: TUPLE[r: INTEGER; c: INTEGER]

feature -- undo/redo related features
	history: ARRAY[COMMAND]
	cursor_position: INTEGER

	add_command(c: COMMAND)
		do
			history.force(c, history.count+1)
			cursor_position:= cursor_position + 1
		end

	decrement_cursor
		do
			cursor_position:= cursor_position - 1
		end

	increment_cursor
		do
			cursor_position:= cursor_position + 1
		end

	delete_all_history
		do
			cursor_position:= 0
			history.make_empty
		end

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			i := i + 1
		end

	play(r: INTEGER_32; c: INTEGER_32; s_move: INTEGER_32; p_move: INTEGER_32)
		do
				state_normal:= state_normal + 1
				state_error:= 0
				is_game_started:= True
				row := r
				column:= c
				player_max_moves:= s_move
				projectile_max_moves := p_move
				ceiling_num := r/2
				player_move_row:= ceiling_num.ceiling
				player_move_col:= 1
				is_player_dead:= False
				create element_removed.default_create
		end

	abort
		do
			reset
			new_window:=False
			state_normal:= state_normal + 1
			state_error:= 0
		end
	move(r: INTEGER_32; c: INTEGER_32)


		local
			x: INTEGER
			current_projectile_moves: INTEGER
			m: INTEGER
			n: INTEGER

		do
			row_mov:= r
			col_mov:= c
			player_move_starting_pos.r := player_move_row
			player_move_starting_pos.c := player_move_col
			state_normal:= state_normal + 1
			state_error:= 0
			current_projectile_moves:= 0

				--incremention of projectile positions first
				from
					m:= current_projectile_moves
				until
					m = projectile_max_moves
				loop
					from
						x:= 1
					until
						x > projectile_pos.count
					loop
							projectile_pos.at(x).proj_col:= projectile_pos.at(x).proj_col + 1
							x:= x+1
					end
					m:= m+ 1
				end

				--Increment once every turn for projectile
				from
					n:= 1
				until
					n > projectile_pos.count
				loop
						projectile_pos.at(n).times:= projectile_pos.at(n).times + 1
						n:= n+1

				end

				--move vertical first
				from
					player_move_row:= player_move_row
				until
					player_move_row = row_mov
				loop
					if r < player_move_row then

						player_move_row:= player_move_row - 1

					elseif r > player_move_row then

						player_move_row:= player_move_row + 1

					end

					--Checking for collision vertically
					from
						x:= 1
					until
						x > projectile_pos.count
					loop
						if projectile_pos.at(x).proj_col = player_move_col and projectile_pos.at(x).proj_row = player_move_row then
								row_mov:= player_move_row
								element_removed:= projectile_pos.at(x)
								is_player_dead:= True
								x:= projectile_pos.count
								--is_game_started:= False
						end
						x:= x+1
					end

				end --Vertical end

				if not is_player_dead then


					--move horizontal second
					from
						player_move_col:= player_move_col
					until
						player_move_col = col_mov

					loop
						if c < player_move_col then
							player_move_col:= player_move_col - 1

						elseif c > player_move_col then
							player_move_col:= player_move_col + 1

						end

						--Checking for collision Horizontally
						from
							x:= 1
						until
							x > projectile_pos.count
						loop
							if projectile_pos.at(x).proj_col = player_move_col and projectile_pos.at(x).proj_row = player_move_row then
									col_mov:= player_move_col
									element_removed:= projectile_pos.at(x)
									is_player_dead:= True
									x:= projectile_pos.count
									--is_game_started:= False
							end
							x:= x + 1
						end
					end

				end

				projectile_pos.prune(element_removed)

		end

	fire
		local
			m: INTEGER
			x: INTEGER
			n: INTEGER
			j: INTEGER
		do
			state_normal:= state_normal + 1
			state_error:= 0
			from
				m:= 0
			until
				m = projectile_max_moves
			loop

				from
					x:= 1
				until
					x > projectile_pos.count
				loop
						projectile_pos.at(x).proj_col:= projectile_pos.at(x).proj_col + 1
						x:= x+1
				end

				from
					j:= 1
				until
					j > projectile_pos.count
				loop
					if projectile_pos.at(j).proj_col = player_move_col and projectile_pos.at(j).proj_row = player_move_row then

							element_removed:= projectile_pos.at(j)
							is_player_dead:= True
							projectile_pos.go_i_th (j)
							projectile_pos.remove
							j:= projectile_pos.count

					end
					j:= j + 1
				end
				m:= m+ 1

			end


			--Increment once every turn for projectile
			from
				n:= 1
			until
				n > projectile_pos.count
			loop
					projectile_pos.at(n).times:= projectile_pos.at(n).times + 1
					n:= n+1

			end

			if not is_player_dead then
				projectile_pos.extend([player_move_row, player_move_col+1, 1])
			end
		end

	pass
		local
			m: INTEGER
			x: INTEGER
			n: INTEGER
			j: INTEGER
		do
			state_normal:= state_normal + 1
			state_error:= 0
			from
				m:= 0
			until
				m = projectile_max_moves
			loop

				from
					x:= 1
				until
					x > projectile_pos.count
				loop
						projectile_pos.at(x).proj_col:= projectile_pos.at(x).proj_col + 1
						x:= x+1
				end
				from
					j:= 1
				until
					j > projectile_pos.count
				loop
					if projectile_pos.at(j).proj_col = player_move_col and projectile_pos.at(j).proj_row = player_move_row then

							element_removed:= projectile_pos.at(j)
							is_player_dead:= True
							projectile_pos.go_i_th (j)
							projectile_pos.remove
							j:= projectile_pos.count

					end
					j:= j + 1
				end

				m:= m+ 1

			end


			--Increment once every turn for projectile
			from
				n:= 1
			until
				n > projectile_pos.count
			loop
				projectile_pos.at(n).times:= projectile_pos.at(n).times + 1
				n:= n+1

			end
		end

	--undo move with projectiles
	move_undo(r: INTEGER_32; c: INTEGER_32)
		local
			x: INTEGER
			current_projectile_moves: INTEGER
			m: INTEGER
			n: INTEGER
		do
			row_mov:= r
			col_mov:= c
			state_normal:= state_normal - 1
			state_error:= 0

			--incremention of projectile positions first
				from
					m:= current_projectile_moves
				until
					m = projectile_max_moves
				loop
					from
						x:= 1
					until
						x > projectile_pos.count
					loop
							projectile_pos.at(x).proj_col:= projectile_pos.at(x).proj_col - 1
							x:= x+1
					end
					m:= m+ 1
				end

				from
				n:= 1
				until
					n > projectile_pos.count
				loop
					if projectile_pos.at (n).times = 1 then
						projectile_pos.go_i_th (n)
						projectile_pos.remove
					else

					projectile_pos.at(n).times:= projectile_pos.at(n).times - 1
					end

					n:= n+1

				end

			--move vertical first
				from
					player_move_row:= player_move_row
				until
					player_move_row = row_mov
				loop
					if r < player_move_row then

						player_move_row:= player_move_row - 1

					elseif r > player_move_row then

						player_move_row:= player_move_row + 1

					end
				end
				--move horizontal second
				from
					player_move_col:= player_move_col
				until
					player_move_col = col_mov

				loop
					if c < player_move_col then
						player_move_col:= player_move_col - 1

					elseif c > player_move_col then
						player_move_col:= player_move_col + 1

					end
				end


		end

	undo
		local
			m: INTEGER
			x: INTEGER
			n: INTEGER
		do
			state_normal:= state_normal - 1
			state_error:= 0
			from
				m:= 0
			until
				m = projectile_max_moves
			loop

				from
					x:= 1
				until
					x > projectile_pos.count
				loop
						projectile_pos.at(x).proj_col:= projectile_pos.at(x).proj_col - 1
						x:= x+1
				end

				m:= m+ 1

			end

			from
				n:= 1
			until
				n > projectile_pos.count
			loop
				if projectile_pos.at (n).times = 1 then
					projectile_pos.go_i_th (n)
					projectile_pos.remove
				else

				projectile_pos.at(n).times:= projectile_pos.at(n).times - 1
				end

				n:= n+1

			end



		end

	reset_history
		do
			history.remove_tail (history.count - cursor_position)
		end
	reset_message
		do
			message_array.remove_tail (message_array.count - cursor_position)
		end

	set_error(e: STRING)
		do
			state_error:= state_error + 1
			is_error:= True
			error:= e
		end

	set_message(c: STRING)

		do
			command_name:= c
			message:= ""
			if command_name ~ "pass" then
				projectile_message
				if player_move_row = element_removed.r and player_move_col = element_removed.c then
					message.append ("  ")
					message.append ("A projectile moves and collides with the Starfighter: [" + arr.at (element_removed.r).out + "," + (element_removed.c - projectile_max_moves).out + "] -> [")
					message.append (arr.at (player_move_row).out + "," + player_move_col.out + "]")
					message.append ("%N")
				else
					message.append ("  ")
					message.append ("The Starfighter stays at: [" + arr.at (player_move_row).out + "," + player_move_col.out + "]")
					message.append ("%N")
				end
				message_array.force(message, message_array.count+1)

			elseif command_name ~ "fire" then

				projectile_message
				if player_move_row = element_removed.r and player_move_col = element_removed.c then
					message.append ("  ")
					message.append ("A projectile moves and collides with the Starfighter: [" + arr.at (element_removed.r).out + "," + (element_removed.c - projectile_max_moves).out + "] -> [")
					message.append (arr.at (player_move_row).out + "," + player_move_col.out + "]")
					message.append ("%N")
				else
					message.append ("  ")
					message.append ("The Starfighter fires a projectile at: [" + arr.at (player_move_row).out + "," + (player_move_col).out + "]")
					message.append ("%N")
				end
				message_array.force(message, message_array.count+1)

			elseif command_name ~ "move" then
				projectile_message
				if player_move_row = element_removed.r and player_move_col = element_removed.c then
					message.append ("  ")
					message.append ("The Starfighter moves and collides with a projectile: [" + arr.at (player_move_starting_pos.r).out + "," + (player_move_starting_pos.c).out + "] -> [")
					message.append (arr.at (player_move_row).out + "," + player_move_col.out + "]")
					message.append ("%N")
				else
					message.append ("  ")
					message.append ("The Starfighter moves: [" + arr.at (player_move_starting_pos.r).out + "," + (player_move_starting_pos.c).out + "] -> [")
					message.append (arr.at (player_move_row).out + "," + player_move_col.out + "]")
					message.append ("%N")
				end
				message_array.force(message, message_array.count+1)


			end

		end

	reset
			-- Reset model state.
		do
			make
		end
feature --extra

	check_projectile(r: INTEGER; c: INTEGER): BOOLEAN
		local
			x: INTEGER
		do
			Result:= False
			from
				x:= 1
			until
				x > projectile_pos.count
			loop
				if c = projectile_pos.at(x).proj_col and r = projectile_pos.at(x).proj_row then
					Result:= True
					x:= projectile_pos.count
				end
				x:= x+1
			end
		end

	projectile_message
		local
			x:INTEGER
		do

			from
				x:= 1
			until
				x > projectile_pos.count
			loop
					if command_name ~ "fire" then
						if player_move_col + 1 /= projectile_pos.at(x).proj_col then
							if projectile_pos.at (x).proj_col > column and (projectile_pos.at (x).proj_col - projectile_max_moves) <= column then
								message.append ("  ")
								message.append ("A projectile moves: [" + arr.at (projectile_pos.at (x).proj_row).out)
								message.append("," + (projectile_pos.at (x).proj_col - projectile_max_moves).out + "] -> out of the board")
								message.append ("%N")
							elseif projectile_pos.at (x).proj_col <= column and (projectile_pos.at (x).proj_col - projectile_max_moves) <= column then
								message.append ("  ")
								message.append ("A projectile moves: [" + arr.at (projectile_pos.at (x).proj_row).out)
								message.append("," + (projectile_pos.at (x).proj_col - projectile_max_moves).out + "] -> [")
								message.append (arr.at (projectile_pos.at (x).proj_row).out + ",")
								message.append ((projectile_pos.at (x).proj_col.out) + "]")
								message.append ("%N")
							end
						end
					else
						if projectile_pos.at (x).proj_col > column and (projectile_pos.at (x).proj_col - projectile_max_moves) <= column then
								message.append ("  ")
								message.append ("A projectile moves: [" + arr.at (projectile_pos.at (x).proj_row).out)
								message.append("," + (projectile_pos.at (x).proj_col - projectile_max_moves).out + "] -> out of the board")
								message.append ("%N")
						elseif projectile_pos.at (x).proj_col <= column and (projectile_pos.at (x).proj_col - projectile_max_moves) <= column then
							message.append ("  ")
							message.append ("A projectile moves: [" + arr.at (projectile_pos.at (x).proj_row).out)
							message.append("," + (projectile_pos.at (x).proj_col - projectile_max_moves).out + "] -> [")
							message.append (arr.at (projectile_pos.at (x).proj_row).out + ",")
							message.append ((projectile_pos.at (x).proj_col.out) + "]")
							message.append ("%N")
						end
					end
					x:= x+1
			end
		end
feature -- queries
	out : STRING

		do

			create Result.make_from_string("")


			if new_window then
				Result.append("Welcome to Space Defender Version 1.")
				new_window:= False
			elseif is_error then
				Result.append ("  ")
				Result.append("state:")
				Result.append(state_normal.out + "." + state_error.out)
				Result.append(", error")
				Result.append ("%N")
				Result.append (error)
				is_error:= False
				error:= ""
			elseif is_game_started then
				Result.append ("  ")
				Result.append("state:")
				Result.append(state_normal.out + "." + state_error.out)
				Result.append(", ok")
				Result.append ("%N")

				if cursor_position > 0 and cursor_position <= message_array.count then
					Result.append(message_array.at (cursor_position))
				end

				Result.append (" ")
				Result.append (" ")
				Result.append (" ")
				Result.append (" ")
				Result.append (" ")
				Result.append (" ")

				--# of Columns
				across
					1 |..| column is col
				loop
					Result.append (col.out)
					if col < column then
						Result.append (" ")
					end


					if col<9 then
						Result.append(" ")
					end
				end

				Result.append ("%N")
				--Grid
				across
					1 |..| row is r
				loop
					Result.append (" ")
					Result.append (" ")
					Result.append (" ")
					Result.append (" ")
					Result.append (arr[r].out)
					Result.append (" ")
					across
						1 |..| column is c
						loop
							if is_player_dead and element_removed.r = r and element_removed.c = c then
								Result.append("X")
								Result.append(" ")
								Result.append(" ")
							elseif c = player_move_col and r = player_move_row and (not is_player_dead) then
								Result.append("S")
								Result.append(" ")
								Result.append(" ")
							elseif check_projectile(r,c) then
								Result.append("*")
								Result.append(" ")
								Result.append(" ")
							else
								Result.append("_")
								Result.append(" ")
								Result.append(" ")
							end
					end
					if r < row then
						Result.append("%N")
					end

				end
				if is_player_dead then
					Result.append("%N")
					Result.append ("  ")
					Result.append ("The game is over. Better luck next time!")
					is_game_started:= False
				end


			elseif not is_game_started then
				Result.append ("  ")
				Result.append("state:")
				Result.append(state_normal.out + "." + state_error.out)
				Result.append(", ok")
				Result.append ("%N")
				Result.append ("  ")
				Result.append ("Game has been exited.")

			end
		end

end




