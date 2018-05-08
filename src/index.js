const promiseRetry = require("promise-retry")
const interactive = require("./interactive")
const generator = require("./generator")

const interaction = () => promiseRetry(retry => {
    const func = () => interactive()
    return func().catch(retry)
})

module.exports = async () => {
    const config = await interaction()
    await generator(config)
}

module.exports()
