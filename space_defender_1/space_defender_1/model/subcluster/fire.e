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
			model.fire
			model.set_message ("fire")
		end

	undo
		do
			model.undo
		end
end
