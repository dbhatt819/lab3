note
	description: "Summary description for {PASS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PASS

inherit COMMAND

create
	make

feature
	model: ETF_MODEL
feature
	make
	local
		model_excess: ETF_MODEL_ACCESS
	do
		model:= model_excess.m
	end
	
feature
	execute
		do
			model.pass
			model.set_message("pass")
		end

	undo
		do
			model.undo
		end
end
