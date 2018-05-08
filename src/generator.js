const fs = require("fs")
const util = require("util")

const createDir = path => {
    if (fs.existsSync(path)) return
    return util.promisify(fs.mkdir)(path)
}

module.exports = async (config) => {
    await createDir(config.path)
}
