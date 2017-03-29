local query = require 'query'


function travaltable(  t )

    for k, v in pairs(t) do
        print(k,v)
    end
end

local r = query:find('user'):select('name,pwd'):where{
        name=111,
        pwd=123456,
}

travaltable(r.sql)

local r = query:find('user'):select('name,pwd'):where{
        'and',
        'bir > 1992',
        {
            'and',
            {
                sex = 1
            },
        }
}

print(r:getSql())


local r = query:find('user'):select('name,pwd'):where{
        'or',
        'bir > 1992',
        {
            'or',
            {
                sex = 1
            },
        }
}

travaltable(r.sql)

local r = query:find('user'):select('name,pwd'):where{
        'and',
        'bir > 1992',
        {
            'or',
            {
                sex = 1
            },
        }
}

travaltable(r.sql)


local r = query:find('user'):select('name,pwd'):where{
        'or',
        'bir > 1992',
        {
            'and',
            {
                sex = 1
            },
        }
}

travaltable(r.sql)


local r = query:find('user'):select('name,pwd'):where{
        'or',
        'bir > 1992',
        {
            'and',
            {
                sex = 1
            },
        },
        {
            'between','uid',100,1000
        },
        {
            'in',
            'id',
            {1,2,3,4,5}
        },
        {
            'in',
            'id',
            function ( )
                return 'select id from course where  cid = 100'
                -- return query:find('course'):where({
                --         cid=100
                --     })
            end
        }
}

travaltable(r.sql)



local r = query:find('user'):select('name,pwd'):where{
        'or',
        'bir > 1992',
        {
            'and',
            {
                sex = 1
            },
        },
        {
            'between','uid',100,1000
        },
        {
            'not in',
            'id',
            {1,2,3,4,5}
        },
        {
            'not in',
            'id',
            function ( )
                return 'select id from course where  cid = 100'
                -- return query:find('course'):where({
                --         cid=100
                --     })
            end
        }
}

travaltable(r.sql)


local r = query:find('user'):select('name,pwd'):where{
        'and',
        {
            'like',
            'name',
            {
                'zhang',
                'li'
            }
        }
}

travaltable(r.sql)


local r = query:find('user'):select('name,pwd'):where{
        'and',
        {
            'like',
            'name',
            {
                'zhang',
                'li'
            }
        },
        {
            'like',
            'name',
            'hh'
        }
}

travaltable(r.sql)


local r = query:find('user'):select('name,pwd'):where{
       'and',
        {
            'not like',
            'name',
            {
                'zhang',
                'li'
            }
        },
        {
            'not like',
            'name',
            'h---h'
        }
}

travaltable(r.sql)



--  优先级bug  需要修正，
 print("\n")
print('--------------------------- bug 区 ---------------------------------------')
local r = query:find('user'):select('name,pwd'):where{
      'and',
        {
            'or not like',
            'name',
            {
                'zhang',
                'li'
            }
        },
        {
            'like',
            'name',
            'h---h'
        },

}

travaltable(r.sql)
 print('--------------------------- bug 区 ---------------------------------------')
 print("\n")

local r = query:find('user'):select('name,pwd'):where{
        'or',
        {
            'or not like',
            'name',
            {
                'zhang',
                'li'
            }
        },
        {
            'like',
            'name',
            'h---h'
        },
}


travaltable(r.sql)
