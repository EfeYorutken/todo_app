-- change this to where your todo list is located
local path = ""

--splits the string "str" by character "char" and returns the result as as table
local split = function(str,char)
	local res = {}
	local temp = ""
	for i = 1, #str do
		if string.sub(str,i,i) == char then
			res[#res + 1] = temp
			temp = ""
		else
			temp = temp .. string.sub(str,i,i)
		end
	end
	res[#res + 1] = temp
	return res
end

--reads the content of the file indicated byt "path", splits is by "split_char"
--and returnst the result as a table
local get_inf_from_file = function(path,split_char)
	local f = io.open(path,"r")
	local content = f:read("*a")
	io.close(f)
	return split(content,split_char)
end

--given a table, overwritest the content of the file indicated by "paht"
--with elements of "tab" at each line
local write_table_to_file = function(path, tab)
	local file = io.open(path,"w")
	file:write(table.concat(tab,"\n"))
	io.close(file)
end

--transforms a line such as
-- - [ ] important todo item
-- to
-- - [x] important todo item
local strike_out = function(path,index)
	local content = get_inf_from_file(path,"\n")
	local target = split(content[index]," ")
	local new_line = target[1] .. " " .. target[2] .. "x" .. table.concat(target," ",3)
	content[index] = new_line
	write_table_to_file(path,content)
end

-- reads the content of the file indicated by "path" into a table
-- creates a new table without the element at "index"
-- over writes the content of the file with the new table
local remove = function(path,index)
	local res = {}
	local t = get_inf_from_file(path,"\n")
	for i = 1,#t do
		if i ~= index then
			res[#res + 1] = t[i]
		end
	end
	write_table_to_file(path,res)
end

--appends the elements of the table "tab" to the end of the file indicated by
--"path"
local add = function(path,tab)
	local res = {}
	for _,v in pairs(get_inf_from_file(path,"\n"))do
		res[#res + 1] = v
	end

	for _,v in pairs(tab)do
		res[#res + 1] = "- [ ] " .. v
	end

	write_table_to_file(path,res)
end

local main = function(args)
	local command = args[1]
	local rest = table.concat(args," ",2)
	if command == "-a" then
		add(path,split(rest,","))
	elseif command == "-s" then
		strike_out(path,tonumber(split(rest," ")[1]))
	elseif command == "-r" then
		remove(path,tonumber(split(rest," ")[1]))
	elseif command == "-h" then
		print("<nothing> \t prints todos")
		print("-a <element1,element2...> \t adds new element1,element2 and so on (items must be seperated by commas)")
		print("-s <index> \t marks item at index as done")
		print("-r <index> \t removes item at index <index>")
	else
    -- makes no sense but some how works
    local t = split(table.concat(get_inf_from_file(path),"\n"),"\n")
    for i = 1, #t do
      print(i,"\t",t[i])
    end
	end
end

main(arg)
