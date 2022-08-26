.PHONY: *

install:
	test -d media/lua/client/lib || mkdir -vp media/lua/client/lib
	cd media/lua/client/lib && wget https://raw.githubusercontent.com/rxi/json.lua/master/json.lua -O json.lua