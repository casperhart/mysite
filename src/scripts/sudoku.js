export function gen_sudoku(wasm) {
  const memory = wasm.instance.exports.memory;
  const get_sudoku = wasm.instance.exports.get_sudoku;
  const buffer_offset = get_sudoku();

  const unsolved = new Uint8Array(memory.buffer, 0, 81);
  const solved = new Uint8Array(memory.buffer, 81, 81);
  const out1 = new TextDecoder().decode(unsolved);
  const out2 = new TextDecoder().decode(solved);

  const get_sudoku_buffer = wasm.instance.exports.get_sudoku_buffer;

  const test = new Uint8Array(memory.buffer, get_sudoku_buffer(), 81 + 81 + 4);
  console.log(new TextDecoder().decode(test));

  return [out1, out2];
}

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
