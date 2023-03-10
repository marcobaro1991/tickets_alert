const express = require('express')
const fs = require('fs')

const app = express()
const port = 3000

app.get('/heart-bit', (request, response) => {
    response.header("Content-Type", 'application/json')
    response.send(JSON.stringify({"happy": true}))
});

app.get('/fansale/json/offer', (request, response) => {

    if (!request.query.hasOwnProperty('groupEventId')) {
        response.status(404).send('Not found')
    }

    if ("error_group_event_id" === request.query.groupEventId) {
        response.status(500).send(null)
    }

    response.header("Content-Type", 'application/json')
    response.send(build_data_response(request.query.groupEventId))

});

app.listen(port, () => {
    console.log(`[server]: Server is running at http://localhost:${port}`);
});

const build_data_response = (event_id) => {

    let data = require('./response/success_empty_data.json')
    const file_path = './response/success_' + event_id + '.json'

    if (fs.existsSync(file_path)) {
        data = require(file_path)
    }

    return JSON.stringify(data)
}