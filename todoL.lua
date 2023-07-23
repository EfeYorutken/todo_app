-- change this to where your todo list is located
local path = "C:\\Users\\user\\Desktop\\volt\\todo.md"

-- splits a string into a table based on substring "char"
-- NOTE : if #char > 1 this function breaks
local split = function(string, char)
	local temp = ""
	local res = {}

	for i=1,#string do
		if string.sub(string,i,i) ~= char then
			temp = temp .. string.sub(string,i,i)
		else
			res[#res +1] = temp
			temp = ""
		end
	end
	res[#res +1] = temp
	temp = ""

	return res

end

-- returns table, each element of which is a part of the files content
-- seperated by "split_char"
-- used for split the file line by line
local get_inf_from_file = function(path,split_char)
	local file = io.open(path, "r")
	local text = file:read("*a")
	io.close()
	return split(text, "\n")
end

-- here is how an "un-checked" item is written in an md file
-- - [ ] this is un-checked
-- and here is how the check version is written
-- - [x] this is un-checked
-- when splitted from the space character you get the following table
-- {"-","[","]","this","is"...}
-- this method essencially takes in a string, splits it from space
-- re-creates the original string by adding the space character back
-- except for the space between [ and ] characters which instead of a space is an x
-- then sets the line indicated by the index in the tab table to be new value (with the x)
local set_as_done = function(tab, index)
	local target_line = tab[index]
	local temp = split(target_line, " ")
	local new_line = temp[1] .. " " .. temp[2] .. "x" .. temp[3] .. " " .. table.concat(temp, 4,#temp)
	return new_line
end

-- get file content
-- calls set_as_done to create the content except for the change to the striken out item
-- re writes the file with the striken out item
local strike_out = function(path, index)
	local t = get_inf_from_file(path,"\n")
	t = set_as_done(t,index)
	local t2 = table.concat(t, "\n")
	local file = io.open(path, "w")
	file:write(t2)
	io.close()
end

-- given a path to a file and a table
-- if the file exists, empties the file
-- at the same time if the file does not exist creates an empty file
-- appends the content of the table to the file
local write_table_to_file = function(path, tab)
	local file = io.open(path, "w")
	file:write("")
	io.close()
	local file = io.open(path, "a")
	for _,v in pairs(tab) do
		file:write(v .. "\n")
	end
	io.close()
end

-- gets the content of the file and prints the content with numbers indicating indexes of the items
local print_content = function(path)
	local f = get_inf_from_file(path,"\n")
	for k,v in pairs(f) do
		print(k .. "\t" .. v)
	end
end

--given some amount of new items, appends them to the end of the file
local add_to_file = function(path, str, char)
	local tab = split(str, char)
	local file =  io.open(path, "a")
	for k,elem in pairs(tab) do
		file:write("- [ ] " .. elem .. "\n")
	end
	io.close()
end

-- re-writes all items in the file to the file unless the items index is the one in the paramater
local remove_from_file = function(path, index)
	local res = {}
	local old = get_inf_from_file(path,"\n")
	for i = 1, #old do
		if i ~= index then
			res[#res +1 ] = old[i]
		end
	end
	write_table_to_file(path, res)
end

-- we can display todo, strike out todo, write the stike out version to file, add to list, remove from list

local main = function(args)
	local command = args[1]
	local text = table.concat(args, " ", 2,#args)
	if command == "-a" then
		add_to_file(path, text, ",")
	elseif command == "-s" then	
		strike_out(path, tonumber(text))
	elseif command == "-r" then	
		remove_from_file(path, tonumber(text))
	elseif command == "-h" then
		print("-a : add\n-s : mark task as done\n-r : remove a task (delete)\n-h : display this menu\nnill : display todos")
	else
		print_content(path)
	end
end

main(arg)
