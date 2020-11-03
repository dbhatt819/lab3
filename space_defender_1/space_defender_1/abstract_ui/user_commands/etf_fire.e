note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_FIRE
inherit
	ETF_FIRE_INTERFACE
create
	make
feature -- command
	fire
    	do
    		if model.cursor_position >= 0 and model.cursor_position < model.history.count then
				model.reset_history
				model.reset_message
    		end
    		if model.is_game_started then
    			model.add_command(create {FIRE}.make)
				model.history[model.cursor_position].execute

    		else
    			model.set_error ("Not in game.")
    		end
    		etf_cmd_container.on_change.notify ([Current])


    	end

end
