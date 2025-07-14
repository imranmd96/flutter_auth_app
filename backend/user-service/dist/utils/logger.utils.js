import chalk from 'chalk';
export const logBoxTable = (title, status, rows, options) => {
    const longestValue = Math.max(...rows.map(row => row.value.length));
    const padding = Math.max(28, longestValue + 2);
    console.log('\n');
    console.log(chalk.bgMagenta.white.bold(` ${title} `) + ' ' + chalk.bgGreen.black(` ${status} `));
    console.log(chalk.blue('┌────────────────────────────────────────┐'));
    rows.forEach(({ label, value }) => {
        console.log(`${chalk.blue('│')} ${chalk.yellow.bold(label)}:      ${chalk.cyan.bold(value.padEnd(padding))} ${chalk.blue('│')}`);
    });
    console.log(chalk.blue('└────────────────────────────────────────┘'));
    if ((options === null || options === void 0 ? void 0 : options.urlMessage) && (options === null || options === void 0 ? void 0 : options.urlValue)) {
        console.log(chalk.bgBlue.white.bold(` ${options.urlMessage}: ${options.urlValue} `));
    }
    console.log('\n');
};
export const logInfoBox = (title, items) => {
    const longestItem = Math.max(...items.map(item => item.length));
    const width = Math.max(30, longestItem + 4);
    console.log('\n');
    console.log(chalk.bgGreen.black.bold(` ${title} `));
    console.log(chalk.blue('┌' + '─'.repeat(width) + '┐'));
    items.forEach(item => {
        console.log(`${chalk.blue('│')} ${chalk.cyan(item.padEnd(width))} ${chalk.blue('│')}`);
    });
    console.log(chalk.blue('└' + '─'.repeat(width) + '┘'));
    console.log('\n');
};
export const logDataTable = (title, headers, rows) => {
    const columnWidths = headers.map((header, index) => {
        const valuesInColumn = rows.map(row => row[index] || '');
        return Math.max(header.length, ...valuesInColumn.map(val => val.length), 10);
    });
    const totalWidth = columnWidths.reduce((sum, width) => sum + width, 0) +
        (columnWidths.length + 1) * 3 - 2;
    console.log('\n');
    console.log(chalk.bgCyan.black.bold(` ${title} `));
    console.log(chalk.yellow('┌' + '─'.repeat(totalWidth) + '┐'));
    let headerRow = chalk.yellow('│');
    headers.forEach((header, i) => {
        headerRow += chalk.bgBlue.white.bold(` ${header.padEnd(columnWidths[i])} `) + chalk.yellow('│');
    });
    console.log(headerRow);
    console.log(chalk.yellow('├' + headers.map((_, i) => '─'.repeat(columnWidths[i] + 2)).join('┼') + '┤'));
    rows.forEach(row => {
        let dataRow = chalk.yellow('│');
        row.forEach((cell, i) => {
            dataRow += ` ${chalk.white(cell.padEnd(columnWidths[i]))} ${chalk.yellow('│')}`;
        });
        console.log(dataRow);
    });
    console.log(chalk.yellow('└' + '─'.repeat(totalWidth) + '┘'));
    console.log('\n');
};
//# sourceMappingURL=logger.utils.js.map