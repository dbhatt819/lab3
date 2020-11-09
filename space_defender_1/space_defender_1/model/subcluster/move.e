note
	description: "Summary description for {MOVE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MOVE
inherit COMMAND

create
	make

feature
	row: INTEGER_32
	col: INTEGER_32
	model: ETF_SD_MAIN_MODEL
	diff_row: INTEGER_32
	diff_col: INTEGER_32
	is_undo:BOOLEAN

feature



	make(r: INTEGER_32; c: INTEGER_32)
		local
			model_access: ETF_SD_MAIN_MODEL_ACCESS

		do
			model:= model_access.m
			row:= r
			col:= c

			diff_row:= r - model.player_move_row
			diff_col:= c - model.player_move_col

		end
feature
	execute
		do
			model.move(row,col)
			model.set_message ("move")
		end

	undo
		do
			model.move_undo(model.player_move_row - diff_row, model.player_move_col - diff_col)

		end
end
