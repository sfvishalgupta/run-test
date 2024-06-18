const console = require('console');
const fs = require('fs');
const { Console } = require('console');
const { Transform } = require('stream');
const readDirMain = fs.readdirSync(process.argv[2]);
const finalData = [];
function table(input) {
    // @see https://stackoverflow.com/a/67859384
    const ts = new Transform({ transform(chunk, enc, cb) { cb(null, chunk) } })
    const logger = new Console({ stdout: ts })
    logger.table(input)
    const table = (ts.read() || '').toString()
    let result = '';
    for (let row of table.split(/[\r\n]+/)) {
        let r = row.replace(/[^┬]*┬/, '┌');
        r = r.replace(/^├─*┼/, '├');
        r = r.replace(/│[^│]*/, '');
        r = r.replace(/^└─*┴/, '└');
        r = r.replace(/'/g, ' ');
        result += `${r}\n`;
    }
    console.log(result);
}


readDirMain.forEach((dirNext) => {
    if (
        fs.lstatSync(process.argv[2] + "/" + dirNext).isDirectory()) {
        const file = process.argv[2] + "/" + dirNext + "/coverage/coverage-summary.json";
        if (fs.existsSync(file)) {
            const data = require(file)["total"];
            finalData.push({
                "Folder": process.argv[2].split("/").pop() + "/" + dirNext,
                "% Stmts": parseFloat(data["statements"]["pct"]).toFixed(2),
                "% Branch": parseFloat(data["branches"]["pct"]).toFixed(2),
                "% Funcs": parseFloat(data["functions"]["pct"]).toFixed(2),
                "% Lines": parseFloat(data["lines"]["pct"]).toFixed(2)
            })
        }
    }
});
// console.table(finalData, ["Folder", "% Stmts", "% Branch", "% Funcs", "% Lines"]);

table(finalData);