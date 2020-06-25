var http = require('http');
fs = require('fs');
const { parse } = require('querystring');

//create a server object:
http.createServer(function (req, res) {
  var url = req.url;
  if (url === '/numbers') {
    if (req.method == 'POST') {
      console.log('POST')
      let body = ''
      req.on('data', function (data) {
        body += data
        console.log('Partial body: ' + body)
      })
      req.on('end', function () {
        params = parse(body);
        console.log(params);
        let date = params.date.split('-');
        let promises = [];

        [0, 1, 2].forEach(function (id) {
          promises.push(fetch_numbers_trivia(date[id]));
          promises.push(fetch_numbers_math(date[id]));
          promises.push(fetch_numbers_year(date[id]));
        });

        Promise.all(promises).then(function (values) {
          console.log(values);
          res.writeHead(200, { 'Content-Type': 'text/html' })
          res.write(get_html(values));
          res.end()
        });
      })
    } else {
      console.log('GET')
      fs.readFile('index.html', function (err, data) {
        res.writeHead(200, { 'Content-Type': 'text/html', 'Content-Length': data.length });
        res.write(data);
        res.end();
      });
    }


  }
}).listen(3000, function () {
  console.log("server start at port 3000"); //the server object listens on port 3000
});

function get_html(sentences) {
  sentences = process(sentences);
  return `<!DOCTYPE html>
   <html>
   <head>
   <meta charset="UTF-8">
  <title>Insert title here</title>
   </head>
   <body>
   ${sentences.join('<br />')}
   </body>
   </html>`
}

function process(sentences) {
  let longest = sentences.reduce(function (a, b) { return a.length > b.length ? a : b; });
  let shortest = sentences.reduce(function (a, b) { return a.length < b.length ? a : b; });
  let average_char_count = sentences.join('').length / sentences.length
  sentences.push(`<br />longest sentence is:<br/>${longest}`);
  sentences.push(`shortest sentence is:<br/>${shortest}`);
  sentences.push(`average character count in sentence is ${average_char_count}`);
  return sentences;
}

async function fetch_numbers_trivia(number) {
  return new Promise((resolve, reject) => {
    http.get(`http://numbersapi.com/${number}/trivia?json`, (res) => {
      const { statusCode } = res;
      const contentType = res.headers['content-type'];

      let error;
      if (statusCode !== 200) {
        error = new Error('Request Failed.\n' +
          `Status Code: ${statusCode}`);
      } else if (!/^application\/json/.test(contentType)) {
        error = new Error('Invalid content-type.\n' +
          `Expected application/text but received ${contentType}`);
      }
      if (error) {
        reject(error.message);
        // Consume response data to free up memory
        res.resume();
        return;
      }

      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(rawData);
          resolve(parsedData.text);
        } catch (e) {
          reject(e.message);
        }
      });
    }).on('error', (e) => {
      reject(`Got error: ${e.message}`);
    });
  })
}

function fetch_numbers_year(number) {
  return new Promise((resolve, reject) => {
    http.get(`http://numbersapi.com/${number}/year?notfound=floor`, (res) => {
      const { statusCode } = res;
      const contentType = res.headers['content-type'];

      let error;
      if (statusCode !== 200) {
        error = new Error('Request Failed.\n' +
          `Status Code: ${statusCode}`);
      } else if (!/^text/.test(contentType)) {
        error = new Error('Invalid content-type.\n' +
          `Expected application/text but received ${contentType}`);
      }
      if (error) {
        reject(error.message);
        // Consume response data to free up memory
        res.resume();
        return;
      }

      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          const parsedData = rawData;
          resolve(parsedData);
        } catch (e) {
          reject(e.message);
        }
      });
    }).on('error', (e) => {
      reject(`Got error: ${e.message}`);
    });
  })
}

function fetch_numbers_math(number) {
  return new Promise((resolve, reject) => {
    http.get(`http://numbersapi.com/${number}/math?notfound=floor`, (res) => {
      const { statusCode } = res;
      const contentType = res.headers['content-type'];

      let error;
      if (statusCode !== 200) {
        error = new Error('Request Failed.\n' +
          `Status Code: ${statusCode}`);
      } else if (!/^text/.test(contentType)) {
        error = new Error('Invalid content-type.\n' +
          `Expected application/text but received ${contentType}`);
      }
      if (error) {
        reject(error.message);
        // Consume response data to free up memory
        res.resume();
        return;
      }

      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          const parsedData = rawData;
          resolve(parsedData);
        } catch (e) {
          reject(e.message);
        }
      });
    }).on('error', (e) => {
      reject(`Got error: ${e.message}`);
    });
  })
}
