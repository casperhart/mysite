export function formatSudoku(sudoku) {
  if (sudoku.length !== 81) {
    throw new Error("Invalid Sudoku string length");
  }

  let formatted = "";
  for (let i = 0; i < 9; i++) {
    let row = sudoku.slice(i * 9, (i + 1) * 9);
    row = row.slice(0, 3) + "|" + row.slice(3, 6) + "|" + row.slice(6, 9);
    row = row.split("").join(" ").replace("0", ".");

    formatted += row + "<br>";

    if (i % 3 === 2 && i !== 8) {
      formatted += "------+-------+------<br>"; // Add horizontal dividers
    }
  }

  return formatted.trim();
}
