const { Converter } = require('ffmpeg-stream');
const { createReadStream, readdirSync } = require('fs');
const path = require('path');

(async () => {
  const converter = new Converter();

  const files = readdirSync('inputs')
    .filter(f => f.endsWith('.png'))
    .sort()
    .map(f => path.join('inputs', f));

  const input = converter.createInputStream({ f: 'image2pipe', r: 10 });

  converter.createOutputToFile('outputs/output.gif', {
    vf: 'scale=512:-1',
    r: 60,
  });

  for (const file of files) {
    await new Promise((resolve, reject) =>
      createReadStream(file)
        .on('end', resolve)
        .on('error', reject)
        .pipe(input, { end: false })
    );
  }
  input.end();

  await converter.run();
})();
