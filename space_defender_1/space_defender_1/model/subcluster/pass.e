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
	model: ETF_SD_MAIN_MODEL
feature
	make
	local
		model_access: ETF_SD_MAIN_MODEL_ACCESS
	do
		model:= model_access.m
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
