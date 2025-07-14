"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.logDataTable = exports.logInfoBox = exports.logBoxTable = void 0;
const chalk_1 = __importDefault(require("chalk"));
const logBoxTable = (title, status, rows, options) => {
    const longestValue = Math.max(...rows.map(row => row.value.length));
    const padding = Math.max(28, longestValue + 2);
    console.log('\n');
    console.log(chalk_1.default.bgMagenta.white.bold(` ${title} `) + ' ' + chalk_1.default.bgGreen.black(` ${status} `));
    console.log(chalk_1.default.blue('┌────────────────────────────────────────┐'));
    rows.forEach(({ label, value }) => {
        console.log(`${chalk_1.default.blue('│')} ${chalk_1.default.yellow.bold(label)}:      ${chalk_1.default.cyan.bold(value.padEnd(padding))} ${chalk_1.default.blue('│')}`);
    });
    console.log(chalk_1.default.blue('└────────────────────────────────────────┘'));
    if ((options === null || options === void 0 ? void 0 : options.urlMessage) && (options === null || options === void 0 ? void 0 : options.urlValue)) {
        console.log(chalk_1.default.bgBlue.white.bold(` ${options.urlMessage}: ${options.urlValue} `));
    }
    console.log('\n');
};
exports.logBoxTable = logBoxTable;
const logInfoBox = (title, items) => {
    const longestItem = Math.max(...items.map(item => item.length));
    const width = Math.max(30, longestItem + 4);
    console.log('\n');
    console.log(chalk_1.default.bgGreen.black.bold(` ${title} `));
    console.log(chalk_1.default.blue('┌' + '─'.repeat(width) + '┐'));
    items.forEach(item => {
        console.log(`${chalk_1.default.blue('│')} ${chalk_1.default.cyan(item.padEnd(width))} ${chalk_1.default.blue('│')}`);
    });
    console.log(chalk_1.default.blue('└' + '─'.repeat(width) + '┘'));
    console.log('\n');
};
exports.logInfoBox = logInfoBox;
const logDataTable = (title, headers, rows) => {
    const columnWidths = headers.map((header, index) => {
        const valuesInColumn = rows.map(row => row[index] || '');
        return Math.max(header.length, ...valuesInColumn.map(val => val.length), 10);
    });
    const totalWidth = columnWidths.reduce((sum, width) => sum + width, 0) +
        (columnWidths.length + 1) * 3 - 2;
    console.log('\n');
    console.log(chalk_1.default.bgCyan.black.bold(` ${title} `));
    console.log(chalk_1.default.yellow('┌' + '─'.repeat(totalWidth) + '┐'));
    let headerRow = chalk_1.default.yellow('│');
    headers.forEach((header, i) => {
        headerRow += chalk_1.default.bgBlue.white.bold(` ${header.padEnd(columnWidths[i])} `) + chalk_1.default.yellow('│');
    });
    console.log(headerRow);
    console.log(chalk_1.default.yellow('├' + headers.map((_, i) => '─'.repeat(columnWidths[i] + 2)).join('┼') + '┤'));
    rows.forEach(row => {
        let dataRow = chalk_1.default.yellow('│');
        row.forEach((cell, i) => {
            dataRow += ` ${chalk_1.default.white(cell.padEnd(columnWidths[i]))} ${chalk_1.default.yellow('│')}`;
        });
        console.log(dataRow);
    });
    console.log(chalk_1.default.yellow('└' + '─'.repeat(totalWidth) + '┘'));
    console.log('\n');
};
exports.logDataTable = logDataTable;
//# sourceMappingURL=logger.utils.js.map