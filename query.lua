-- inpired by
--  https://github.com/yiisoft/yii2/blob/master/framework/db/Query.php
--  https://github.com/noname007/yii2/blob/master/framework/db/QueryInterface.php


local _M  = {}
-- local db = require 'orange.store.mysql_db'


local sql_key = {
    'select',
    -- 'distinct',
    'from',
    -- 'on',
    'where',
    'groupBy',
    'having',
    'orderBy',
    'limit',
    'offset'
}

local sql_v = {
    select = 'select'
}

local function build(sql_arr)
    local r = {}

    for k,v in ipairs(sql_key) do
        print(k,v)
        print(sql_arr[v])

        if sql_arr[v] then
            r[#r + 1] = ' '.. v .. ' ' .. sql_arr[v]
        end
    end

    return table.concat(r,' ')
end



function _M:find( table_name )
    if not table_name or type(table_name) ~= 'string' then
        error('tabel name illegal')
    end

    local t = {}
    t._attributes = {}
    t.sql = {}
    t.sql.from = table_name
    t._sql_str = nil

    setmetatable(t,{
            __index=self,
    })
    return t
end


function _M:select( columns, opts )

    local value_type = type(columns)

    if value_type == 'string' then
        self.sql.select = columns
    elseif value_type  == 'table' then
        self.sql.select = table.concat(columns,',')
    end

    return self
end


function _M:distinct( yes )
    self.sql.distinct = yes and 'distinct' or ''
    return self
end

function _M:from( table )
    local value_type = type(table)
    if value_type == 'string' then

        self.sql.from = table

    elseif value_type ==  'function' then

        local r = table()
        self.sql.from = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')

    elseif value_type == 'table' then

        local r = {}

        if table[1] then
            r = table
        else
            for k,v in pairs(table) do
                r[#r + 1] =  k .. ' ' .. i
            end
        end

        self.sql.from = table.concat(r,',')
    end


    return self

end

---------------------------------------
-- @condition string|table|function
-- @opts table
---------------------------------------
function _M:where( condition, opts )

    function build_where(condition)

        local condition_type = type(condition)

        if condition_type == 'string' then
            return condition
        elseif condition_type == 'function' then
            local r = condition()
            return (type(r) == 'string') and r or error('calculated result by condition() illegal')
        elseif condition_type ~= 'table' then
            error('condition illegal')
        end

        if condition[1] then
            -- array
            for k, _ in pairs(condition) do
                if type(k) ~= 'number' then
                    error('condition illegal : find hash')
                end
            end

            local operator = condition[1]

            if operator == 'and' then

                local t = {'true'}

                for i = 2,#condition do

                    local  v = condition[i]

                    local condition_type = type(v)

                    if condition_type  == 'string' then

                        t[#t + 1] = v

                    elseif condition_type  == 'function' then

                        local r = v()
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by condition() illegal')

                    elseif condition_type == 'table' then

                        local r = build_where(v)
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')

                    else

                        error('and condition illegal')

                    end
                end
                return table.concat(t, ' and ')

            elseif operator == 'or' then

                local t = {'false'}

                for i = 2,#condition do

                    local  v = condition[i]

                    local condition_type = type(v)

                    if condition_type  == 'string' then

                        t[#t + 1] = v

                    elseif condition_type  == 'function' then

                        local r = v()
                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by condition() illegal')

                    elseif condition_type == 'table' then

                        local r = build_where(v)

                        t[#t + 1] = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')

                    else

                        error('or condition illegal')

                    end
                end

                return table.concat(t, ' or ')

            elseif operator == 'between' then

                return  condition[2] .. ' between '.. condition[3] .. ' and ' .. condition[4]

            elseif operator == 'in' then

                local value_type = type(condition[3])

                if value_type == 'function' then

                    local r = condition[3]()
                    r = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')
                    return condition[2] .. ' in (' ..  r ..')'

                else

                    return condition[2] .. ' in (' ..  table.concat(condition[3]) ..')'

                end

            elseif operator == 'not in' then

                local value_type = type(condition[3])

                if value_type == 'function' then

                    local r = condition[3]()
                    r = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')
                    return condition[2] .. ' not in (' ..  r ..')'

                else

                    return condition[2] .. ' not in (' ..  table.concat(condition[3]) ..')'

                end
                -- condition[1] = 'in'
                -- return ' not ' .. build_where(condition)
            elseif operator == 'like' then

                local value_type = type(condition[3])

                if value_type == 'string' then

                    return condition[2] .. ' like  %' .. condition[3] .. '% '

                elseif value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' like %' .. v ..'% '
                    end

                    return table.concat(r,' and ')
                else
                    error('like illegal')
                end

            elseif operator == 'not like' then
                local value_type = type(condition[3])

                if value_type == 'string' then

                    return condition[2] .. ' not like  %' .. condition[3] .. '% '

                elseif value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' not like %' .. v ..'% '
                    end

                    return table.concat(r,' and ')
                else
                    error('like illegal')
                end
            elseif operator == 'or like' then

                local value_type = type(condition[3])

                if value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' like %' .. v ..'% '
                    end

                    return table.concat(r,' or ')
                else
                    error('like illegal')
                end

            elseif operator == 'or not like' then

                local value_type = type(condition[3])

                if value_type == 'string' then

                    return condition[2] .. ' not like  %' .. condition[3] .. '% '

                elseif value_type == 'table' then
                    local r = {}
                    for _,v in ipairs(condition[3]) do
                        r[#r + 1] = condition[2] .. ' not like %' .. v ..'% '
                    end

                    return table.concat(r,' or ')
                else
                    error('like illegal')
                end

            -- elseif operator == 'exists' then
            -- elseif operator == 'not exists' then
            end

        else
             -- hash
            local t = {}
            local i = 1

            for k, v in pairs(condition) do
                if type(k) == 'number' then
                    error('condition illegal : find array')
                end
                t[i] = ' `' .. k ..'` = `' .. v..'` '
                i = i + 1
            end
            return table.concat(t,' and ')
        end
    end

    self.sql.where = build_where(condition)

    return self
end

function _M:join( type, table, on, opts )

    return self
end

function _M:groupBy( columns )

    local value_type  =  type(columns)

    if value_type == 'string' then

        self.sql.groupBy = columns

    elseif value_type ==  'table' then

        local r = {}

        for k,v in pairs(columns) do
            r[#r + 1] = k .. (v or '')
        end

        self.sql.groupBy =  table.concat(r,',')
    end


    return self
end

function _M:having( condition, opts )
    self.sql.having = condition
    return self
end



function _M:union( sql )

    local value_type  =  type(sql)

    if value_type == 'string' then
        self.sql.union = sql
    elseif value_type ==  'function' then
        local r = sql()
        self.sql.union = (type(r) == 'string') and r or error('calculated result by build_where(table) illegal')
    end

    return self
end


function _M:limit( limit )
    self.sql.limit = limit
    return self
end

function _M:offset( offset )
    self.sql.offset = offset
    return self
end

function _M:orderBy( columns )

    local value_type  =  type(columns)

    if value_type == 'string' then

        self.sql.orderBy = columns

    elseif value_type ==  'table' then

        local r = {}

        for k,v in pairs(columns) do
            r[#r + 1] = k .. (v or '')
        end

        self.sql.orderBy =  table.concat(r,',')
    end

    return self

end

function _M:getSql()
    
    if not self._sql_str then
        self._sql_str = build(self.sql)
    end

    return self._sql_str
end

function _M:all( ... )
    return self
end

function _M:one( ... )
    return self
end

return _M



