note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_UNDO
inherit
	ETF_UNDO_INTERFACE
create
	make
feature -- command
	undo
    	do
			if model.is_game_started then
				if model.cursor_position < 1 then
					model.set_error ("Nothing left to undo.")
				else
					model.history[model.cursor_position].undo
					model.decrement_cursor
				end
			else
				model.set_error ("Not in game.")
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
