note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_PLAY
inherit
	ETF_PLAY_INTERFACE
create
	make

feature -- command
	play(row: INTEGER_32 ; column: INTEGER_32 ; player_mov: INTEGER_32 ; project_mov: INTEGER_32)
		require else
			play_precond(row, column, player_mov, project_mov)

    	do
    		if model.is_game_started then
    			model.set_error("Please end the current game before starting a new one.")
    		else
				if player_mov > (row-1 + column -1)  then
					model.set_error ("Starfighter movement should not exceed row - 1 + column - 1 size of the board.")
				else
					model.play(row, column, player_mov, project_mov)

				end

			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
