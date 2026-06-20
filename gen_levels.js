const fs = require('fs');

const levels = [
    // Level 1
    [
        [[0,0], [7,0]], [[7,1], [7,7]], // split 0
        [[0,1], [0,7]], [[1,7], [6,6]], // split 1
        [[1,1], [6,1]], [[6,2], [5,5]], [[4,5], [5,6]], // split 2
        [[1,2], [2,2]],
        [[2,3], [4,3]]
    ],
    // Level 2
    [
        [[0,0], [0,1]],
        [[0,2], [2,1]], [[2,0], [7,0]], [[7,1], [7,7]], // split 1
        [[0,3], [0,7]], [[1,7], [6,7]], [[6,6], [6,2]], [[5,2], [6,1]], // split 2
        [[1,3], [1,4]],
        [[2,4], [3,4]]
    ],
    // Level 3
    [
        [[0,0], [1,1]],
        [[0,3], [0,7]], [[1,7], [7,7]], [[7,6], [7,0]], [[6,0], [3,0]], // split 1
        [[1,3], [1,6]], [[2,6], [6,6]], [[6,5], [3,1]], // split 2
        [[2,3], [3,2]],
        [[3,3], [4,3]]
    ],
    // Level 4
    [
        [[0,0], [0,7]],
        [[1,0], [1,7]],
        [[2,0], [2,7]],
        [[3,0], [7,0]],
        [[3,1], [3,4]],
        [[3,5], [7,7]]
    ],
    // Level 5
    [
        [[0,0], [7,0]],
        [[0,1], [7,1]],
        [[0,2], [7,2]],
        [[0,3], [0,7]],
        [[1,3], [3,7]],
        [[4,3], [6,7]],
        [[7,3], [7,7]]
    ]
];

let out = "";
for (let i = 0; i < levels.length; i++) {
    const pairs = levels[i];
    out += `    // ── EX${i+1} : ${pairs.length} colours ──\n`;
    out += `    LevelConfig(\n`;
    out += `      id: ${i+1}, gridSize: 8, difficulty: 'Expert', difficultyIndex: 3,\n`;
    out += `      colorPairs: [\n`;
    for (let c = 0; c < pairs.length; c++) {
        const pair = pairs[c];
        out += `        ColorPair(GridPos(${pair[0][0]}, ${pair[0][1]}), GridPos(${pair[1][0]}, ${pair[1][1]}), ${c}),\n`;
    }
    out += `      ],\n`;
    out += `    ),\n\n`;
}

fs.writeFileSync('d:/puzzlify/puzzlify/levels.dart.txt', out);
