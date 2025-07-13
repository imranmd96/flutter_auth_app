import chalk from 'chalk';

/**
 * Creates a formatted box-style output in the terminal with colored borders and content
 * 
 * @param title The title to display above the box (e.g. 'API GATEWAY')
 * @param status The status to display next to the title (e.g. 'ONLINE')
 * @param rows Array of objects with label and value to display in rows
 * @param options Optional configuration for colors and URL
 */
export const logBoxTable = (
  title: string,
  status: string,
  rows: { label: string; value: string }[],
  options?: {
    urlMessage?: string;
    urlValue?: string;
  }
): void => {
  // Calculate the padding needed based on the longest value
  const longestValue = Math.max(...rows.map(row => row.value.length));
  const padding = Math.max(28, longestValue + 2); // Minimum 28 chars, or longer if needed
  
  // Title bar
  console.log('\n');
  console.log(chalk.bgMagenta.white.bold(` ${title} `) + ' ' + chalk.bgGreen.black(` ${status} `));
  
  // Box-style status info
  console.log(chalk.blue('┌────────────────────────────────────────┐'));
  
  // Content rows
  rows.forEach(({ label, value }) => {
    console.log(
      `${chalk.blue('│')} ${chalk.yellow.bold(label)}:      ${chalk.cyan.bold(value.padEnd(padding))} ${chalk.blue('│')}`
    );
  });
  
  // Bottom border
  console.log(chalk.blue('└────────────────────────────────────────┘'));
  
  // URL indicator (if provided)
  if (options?.urlMessage && options?.urlValue) {
    console.log(chalk.bgBlue.white.bold(` ${options.urlMessage}: ${options.urlValue} `));
  }
  
  console.log('\n');
};

/**
 * Creates a smaller box for displaying special information
 * 
 * @param title The title to display above the box
 * @param items Array of strings to display in the box
 */
export const logInfoBox = (
  title: string,
  items: string[]
): void => {
  // Find the longest item for padding calculation
  const longestItem = Math.max(...items.map(item => item.length));
  const width = Math.max(30, longestItem + 4);
  
  // Top with title
  console.log('\n');
  console.log(chalk.bgGreen.black.bold(` ${title} `));
  console.log(chalk.blue('┌' + '─'.repeat(width) + '┐'));
  
  // Content items
  items.forEach(item => {
    console.log(`${chalk.blue('│')} ${chalk.cyan(item.padEnd(width))} ${chalk.blue('│')}`);
  });
  
  // Bottom
  console.log(chalk.blue('└' + '─'.repeat(width) + '┘'));
  console.log('\n');
};

/**
 * Creates a table with colored heading row and multiple data rows
 * 
 * @param title The title of the table
 * @param headers Array of column headers
 * @param rows Array of rows, each containing values for each column
 */
export const logDataTable = (
  title: string,
  headers: string[],
  rows: string[][]
): void => {
  // Calculate column widths based on content
  const columnWidths = headers.map((header, index) => {
    const valuesInColumn = rows.map(row => row[index] || '');
    return Math.max(
      header.length,
      ...valuesInColumn.map(val => val.length),
      10 // Minimum width
    );
  });
  
  // Calculate total width including borders and padding
  const totalWidth = columnWidths.reduce((sum, width) => sum + width, 0) + 
                     (columnWidths.length + 1) * 3 - 2; // Account for borders
  
  // Title
  console.log('\n');
  console.log(chalk.bgCyan.black.bold(` ${title} `));
  
  // Top border
  console.log(chalk.yellow('┌' + '─'.repeat(totalWidth) + '┐'));
  
  // Headers row
  let headerRow = chalk.yellow('│');
  headers.forEach((header, i) => {
    headerRow += chalk.bgBlue.white.bold(` ${header.padEnd(columnWidths[i])} `) + chalk.yellow('│');
  });
  console.log(headerRow);
  
  // Separator
  console.log(chalk.yellow('├' + headers.map((_, i) => '─'.repeat(columnWidths[i] + 2)).join('┼') + '┤'));
  
  // Data rows
  rows.forEach(row => {
    let dataRow = chalk.yellow('│');
    row.forEach((cell, i) => {
      dataRow += ` ${chalk.white(cell.padEnd(columnWidths[i]))} ${chalk.yellow('│')}`;
    });
    console.log(dataRow);
  });
  
  // Bottom border
  console.log(chalk.yellow('└' + '─'.repeat(totalWidth) + '┘'));
  console.log('\n');
}; 