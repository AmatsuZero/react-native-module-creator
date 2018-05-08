const promiseRetry = require("promise-retry")
const interactive = require("./interactive")

const interaction = () => promiseRetry(retry => {
    const func = () => interactive()
    return func().catch(retry)
})

interaction().then(config => console.log(config.description))
