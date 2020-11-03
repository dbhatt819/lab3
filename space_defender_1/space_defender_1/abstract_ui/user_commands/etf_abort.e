note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_ABORT
inherit
	ETF_ABORT_INTERFACE
create
	make
feature -- command
	abort
    	do
	    	if model.is_game_started then

				model.delete_all_history
	    		model.abort

	    	else
				model.set_error ("Not in game.")

	    	end
	    	etf_cmd_container.on_change.notify ([Current])
    	end

end
