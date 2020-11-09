note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE
inherit
	ETF_MOVE_INTERFACE
create
	make

feature
	rows: INTEGER_32
	columns: INTEGER_32
feature -- command
	move(row:INTEGER_32; column: INTEGER_32)
		require else
			move_precond(row, column)

    	do
    		rows:= row
    		columns := column
			-- perform some update on the model state
			if row = A then
				rows:= 1
			elseif row = B then
				rows:= 2
			elseif row = C then
				rows:= 3
			elseif row = D then
				rows:= 4
			elseif row = E then
				rows:=5
			elseif row = F then
				rows:=6
			elseif row = G then
				rows:=7
			elseif row = H then
				rows:=8
			elseif row = I then
				rows:=9
			elseif row = J then
				rows:=10
			end



			if model.is_game_started then
				if rows > 10 or rows < 0 or column <= model.column then
					if check_max_moves then
						if model.player_move_col /= column or model.player_move_row /= rows then
							if model.cursor_position >= 0 and model.cursor_position < model.history.count then
								model.reset_history
								model.reset_message
							end
							model.add_command(create {MOVE}.make(rows,column))
							model.history[model.cursor_position].execute


						else
							model.set_error ("The Starfighter is already at that location.")
						end
					else
						model.set_error ("The location to move to is out of the Starfighter's movement range.")
					end
				else
					model.set_error ("The location to move to is outside of the board.")
				end
			else
				model.set_error ("Not in game.")
			end
			etf_cmd_container.on_change.notify ([Current])

    	end

    check_max_moves:BOOLEAN
    	local
    		rows_diff: INTEGER_32
    		col_diff: INTEGER_32
    		moves: INTEGER_32
    	do
    		rows_diff:= rows - model.player_move_row
    		col_diff:= columns - model.player_move_col
    		moves:= rows_diff.abs + col_diff.abs

    		if moves > model.player_max_moves then
    			Result:= False
    		else
    			Result:= True
    		end
    	end

end
