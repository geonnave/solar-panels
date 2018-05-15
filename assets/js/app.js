// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"


var channel = socket.channel('room:lobby', {}); // connect to chat "room"

channel.on('value', function (payload) {
  console.log(payload)
  document.getElementById("current").innerHTML = payload.current;
  document.getElementById("voltage").innerHTML = payload.voltage;
});

channel.join(); // join the channel.



    var buf = {};
    buf['Bitfinex'] = [[], []];
    // var ws = new WebSocket('ws://localhost:9998');
    var ws = new WebSocket('wss://api.bitfinex.com/ws/');
    ws.onopen = function() {
        ws.send(JSON.stringify({      // send subscribe request
            "event": "subscribe",
            "channel": "trades",
            "pair": "BTCUSD"
        }));
    };

    ws.onmessage = function(msg) {     // callback on message receipt
        var response = JSON.parse(msg.data);
        console.log(response)
        if (response[1] === 'te') {    // Only 'te' message type is needed
            buf['Bitfinex'][response[5] > 0 ? 0 : 1].push({
                x: response[3] * 1000, // timestamp in milliseconds
                y: response[4]         // price in US dollar
            });
        }
    }

    var id = 'Bitfinex';
    var ctx = document.getElementById(id).getContext('2d');
    var chart = new Chart(ctx, {
        type: 'line',
        data: {
            datasets: [{
                data: [],
                label: 'Buy',                     // 'buy' price data
                borderColor: 'rgb(255, 99, 132)', // line color
                backgroundColor: 'rgba(255, 99, 132, 0.5)', // fill color
                fill: false,                      // no fill
                lineTension: 0                    // straight line
            }, {
                data: [],
                label: 'Sell',                    // 'sell' price data
                borderColor: 'rgb(54, 162, 235)', // line color
                backgroundColor: 'rgba(54, 162, 235, 0.5)', // fill color
                fill: false,                      // no fill
                lineTension: 0                    // straight line
            }]
        },
        options: {
            title: {
                text: 'Voltage', // chart title
                display: true
            },
            scales: {
                xAxes: [{
                    type: 'realtime' // auto-scroll on X axis
                }]
            },
            plugins: {
                streaming: {
                    duration: 300000, // display data for the latest 300000ms (5 mins)
                    onRefresh: function(chart) { // callback on chart update interval
                        Array.prototype.push.apply(
                            chart.data.datasets[0].data, buf[id][0]
                        );            // add 'buy' price data to chart
                        Array.prototype.push.apply(
                            chart.data.datasets[1].data, buf[id][1]
                        );            // add 'sell' price data to chart
                        buf[id] = [[], []]; // clear buffer
                    }
                }
            }
        }
    });





// var ul = document.getElementById('msg-list');        // list of messages.
// var name = document.getElementById('name');          // name of message sender
// var msg = document.getElementById('msg');            // message input field

// // "listen" for the [Enter] keypress event to send a message:
// msg.addEventListener('keypress', function (event) {
//   if (event.keyCode == 13 && msg.value.length > 0) { // don't sent empty msg.
//     channel.push('shout', { // send the message to the server on "shout" channel
//       name: name.value,     // get value of "name" of person sending the message
//       message: msg.value    // get message text (value) from msg input field.
//     });
//     msg.value = '';         // reset the message input field for next message.
//   }
// });

