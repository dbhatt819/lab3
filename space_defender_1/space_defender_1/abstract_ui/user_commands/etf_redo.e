note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REDO
inherit
	ETF_REDO_INTERFACE
create
	make
feature -- command
	redo
    	do

			if model.is_game_started then
				if model.cursor_position = model.history.count then
					model.set_error ("Nothing left to redo.")
				else
					model.increment_cursor
					model.history[model.cursor_position].execute
				end

			else
				model.set_error ("Not in game.")
			end
			etf_cmd_container.on_change.notify ([Current])
    	end


end
