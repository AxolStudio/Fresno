const fs = require('fs');
const path = require('path');
const root = path.resolve(process.argv[2] || '.');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');
const actions = read('source/globals/Actions.hx');
const title = read('source/states/TitleState.hx');
const play = read('source/states/PlayState.hx');
const ending = read('source/states/GameWinState.hx');
const checks = [
  ['controller_jump', /Actions\.jump\.addGamepad\(A,\s*PRESSED\)/.test(actions)],
  ['dedicated_menu_confirm', !/else if \(Actions\.any\.triggered\)/.test(title)],
  ['pause_restart', /Restart Level/.test(play)],
  ['pause_main_menu', /Main Menu/.test(play)],
  ['pause_quit', /Quit to Launcher/.test(play)],
  ['ending_escape', /Actions\.backUI\.triggered/.test(ending)],
  ['ending_font_asset', !/assets\/image\/fat_text\.xml/.test(ending)]
];
const report = {kind: 'source-contract-only', passed: checks.every(c => c[1]), checks: checks.map(([name, passed]) => ({name, passed}))};
console.log(JSON.stringify(report, null, 2));
process.exitCode = report.passed ? 0 : 1;
