scriptPath = arg[0]
srcDir = string.sub(scriptPath, 1, string.find(scriptPath, "main.lua")-2)
libDir = srcDir.."/../lib"

package.cpath = string.format("%s;%s/?.so", package.cpath, srcDir)
package.path = string.format(
    "%s;%s/?.lua;%s/alloui-lua/lua/?.lua;%s/alloui-lua/lib/cpml/?.lua;%s/alloui-lua/lib/pl/lua/?.lua",
    package.path,
    srcDir,
    libDir,
    libDir,
    libDir
)

require("liballonet")
Client = require("alloui.client")
ui = require("alloui.ui")
require("app")