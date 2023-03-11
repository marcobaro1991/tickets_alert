const express = require('express')

const app = express()
const port = 3001

app.use(express.json())

app.get('/heart-bit', (request, response) => {
    response.header("Content-Type", 'application/json')
    response.send(JSON.stringify({"happy": true}))
});

app.post('/bot*/sendMessage', (request, response) => {

    const {chat_id, text, parse_mode} = request.body

    if("message with error response" === text){
        response.status(500).send(null)
    }

    response.header("Content-Type", 'application/json')

    const data = require('./response/message_send_success.json')
    return response.send(JSON.stringify(data))

});

app.listen(port, () => {
    console.log(`[server]: Server is running at http://localhost:${port}`);
});
