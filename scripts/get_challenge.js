bcrypt = require('bcrypt')

const s = bcrypt.hashSync(process.argv[2], process.argv[3]);
const c = bcrypt.hashSync(process.argv[4] + s, bcrypt.genSaltSync(4));

console.log(encodeURIComponent(c))
