import "phoenix_html"
import socket from "./socket"

var buf = {};
buf['current'] = [];
buf['voltage'] = [];

var channel = socket.channel('room:lobby', {}); // connect to chat "room"

channel.on('value', function (payload) {
  console.log(payload)

  buf['current'].push({
    x: payload.current.timestamp * 1000,
    y: payload.current.value
  });

  buf['voltage'].push({
    x: payload.voltage.timestamp * 1000,
    y: payload.voltage.value
  });
});

var makeChart = function(id, label, borderColor, backgroundColor) {
  var ctx = document.getElementById(id).getContext('2d');
  var chart = new Chart(ctx, {
      type: 'line',
      data: {
          datasets: [{
              data: [],
              label: label,
              borderColor: borderColor, // line color
              backgroundColor: backgroundColor, // fill color
              fill: false,                      // no fill
              lineTension: 0,                    // straight line,
              showLine: true
          }
          ]
      },
      options: {
          scales: {
              xAxes: [{
                  type: 'realtime' // auto-scroll on X axis
              }]
          },
          plugins: {
              streaming: {
                  duration: 1000 * 60,
                  onRefresh: function(chart) {
                      Array.prototype.push.apply(
                          chart.data.datasets[0].data, buf[id]
                      );
                      buf[id] = [];
                  }
              }
          }
      }
  });
}

channel.join(); // join the channel.
makeChart('current', "Corrente", 'rgb(255, 99, 132)', 'rgba(255, 99, 132, 0.5)');
makeChart('voltage', "Voltagem", 'rgb(54, 162, 235)', 'rgba(54, 162, 235, 0.5)');



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

