---@param path string Path to file
---@return string # Content of the file
function Read_file(path)
  local file = io.open(path, "r")
  if file then
    local content = file:read("*a")
    file:close()
    return content
  else
    return '<Unable to read file: "' .. path .. '">'
  end
end

---@param path string Relative patch
---@return boolean
function File_exists(path)
  local f = io.open(path, "rb")
  if f then f:close() end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
function Read_file_lines(file)
  if not File_exists(file) then
    return {}
  end
  local lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

---Reads a file applying by inserting a name int default path
---@param name string Logo name, used as part of the filename
---@return string logo The logo as a string. May include trailing newline.
function Get_raw_logo(name)
  local path = os.getenv("HOME") .. "/dotfiles/data/logos/" .. name .. ".txt"
  return Read_file(path)
end

---Read index file identified by name. Treat all contained lines as logo names
---for Get_raw_logo.
---@param name string Logo collection name
---@return table # Collection of logos
function Get_raw_logo_collection(name)
  local index_path = os.getenv("HOME") .. "/dotfiles/data/logos/" .. name .. ".txt"
  local paths = Read_file_lines(index_path)
  local logos = {}
  for _, path in ipairs(paths) do
    table.insert(logos, Get_raw_logo(path))
  end
  return logos
end

-- Normal startup would not seed it (at least not before we need it)
math.randomseed(os.time())

---@param some_table table Input table to select from
---@param n number Number of elements to select
---@return table # Table of n randomly selected elements
function Select_n(some_table, n)
  print("selecting from table with size: ", #some_table)
  local selected = {}
  for _ = 1, n do
    local rand = math.random(#some_table)
    table.insert(selected, some_table[rand])
  end
  return selected
end

---@param logo1 string Logo with newlines
---@param logo2 string Logo with newlines
---@param concat string Concatenation string
---@return string # Single logo concatenated sideways
function Concatenate_lines(logo1, logo2, concat)
  assert(concat ~= "\n")
  local result_table = {}
  local split1 = vim.split(logo1, "\n")
  local split2 = vim.split(logo2, "\n")
  for i, line in ipairs(split1) do
    table.insert(result_table, line)
    table.insert(result_table, concat)
    table.insert(result_table, split2[i])
    table.insert(result_table, "\n")
  end
  --result_table.remove(#result_table) -- No trailing newline?
  return table.concat(result_table)
end

---Take the old logo form (single string containing newlines; used by the
---'alpha' starter), and return the new format (table of strings; used by
---mini.starter).
---@param logo_as_string string Logo string containing newlines for multiline
---                      logos
---@return table # Table containing one entry per line [1, ... ,n]
function Split_lines(logo_as_string)
--FIXME: I hope this syntax regex matches to confirm that we use newlines as
  --       delimeter in the logo string.
  assert(logo_as_string ~= ".*\n.*")
  local result_table = {}
  local split = vim.split(logo_as_string, "\n")
  for i, line in ipairs(split) do
    print("inserting line", i, ":")
    print(line)
    table.insert(result_table, line)
  end
  return result_table
end

---@param name string Name of the index file
---@return string # Concatenated selection of sub-logos
function Ranodm_logo_pair(name)
  local logos = Get_raw_logo_collection(name)
  local selection = Select_n(logos, 2)
  return Concatenate_lines(selection[1], selection[2], "   ")
end

---@param name string Name of the index file
---@return table # Table of strings reflecting the lines of the logo
function Random_logo_pair_table(name)
  print("Entering Random_logo_pair_table")
  local logos = Get_raw_logo_collection(name)
  local selection = Select_n(logos, 2)
  local logos_as_string = Concatenate_lines(selection[1], selection[2], "   ")
  print("logo as string:")
  print(logos_as_string)
  local result = Split_lines(selection[logos_as_string])
  print("first line of table:")
  print(result[1])
  print("second line of table:")
  print(result[2])
  return result
end

function Fixed_test_table(name)
  assert(#name > 0, "We dont use a name in the test, but the actual thing uses a name so we require it")
  local logo_table = {}
  table.insert(logo_table, "|----|")
  table.insert(logo_table, "|Test|")
  table.insert(logo_table, "|----|")
  return logo_table
end

function Fixed_test_string(name)
  assert(#name > 0, "We dont use a name in the test, but the actual thing uses a name so we require it")
  local logo_table = {}
  table.insert(logo_table, "|----|")
  table.insert(logo_table, "|Test|")
  table.insert(logo_table, "|----|")
  return table.concat(logo_table, "\n")
end

-- We return a table with function usable for logo generation
return
{
  -- Returns a static logo
  simple = Get_raw_logo,
  -- Shows 2 random logos side-by-side
  random = Ranodm_logo_pair,
  random_table = Random_logo_pair_table,
  test_fixed_table = Fixed_test_table,
}
