note
	description: "Summary description for {FIRE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FIRE

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
			model.fire
			model.set_message ("fire")
		end

	undo
		do
			model.undo
		end
end
