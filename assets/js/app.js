import "phoenix_html"
import socket from "./socket"

$('.ui.dropdown').dropdown();

var panels = {
  "daily": {
    "name": 'panels:daily',
    "idAappend": '-daily',
    "channel": socket.channel('panels:daily', {}),
    "buffer": {
      "current": [],
      "voltage": []
    }
  },
  "real": {
    "name": 'panels:real',
    "idAappend": '-real',
    "channel": socket.channel('panels:real', {}),
    "buffer": {
      "current": [],
      "voltage": []
    }
  }
};

var channelOn = function(panel) {
  panels[panel].channel.on('value', function (payload) {
    console.log(payload)

    panels[panel].buffer.current.push({
      x: payload.timestamp * 1000,
      y: payload.current
    });

    panels[panel].buffer.voltage.push({
      x: payload.timestamp * 1000,
      y: payload.voltage
    });
  });
}

// channelOn("daily");
channelOn("real");

var makeChart = function(buffer_name, label, borderColor, backgroundColor, panel) {
  var id = buffer_name + panels[panel].idAappend;
  var ctx = document.getElementById(id).getContext('2d');
  console.log(ctx)
  return new Chart(ctx, {
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
                          chart.data.datasets[0].data, panels[panel].buffer[buffer_name]
                      );
                      panels[panel].buffer[buffer_name] = [];
                  }
              }
          }
      }
  });
}

// panels.daily.channel.join();
panels.real.channel.join();
// makeChart('current', "Corrente (A)", 'rgb(255, 99, 132)', 'rgba(255, 99, 132, 0.5)', "daily");
// makeChart('voltage', "Voltagem (V)", 'rgb(54, 162, 235)', 'rgba(54, 162, 235, 0.5)', "daily");
var realCurrentChart = makeChart('current', "Corrente (A)", 'rgb(255, 99, 132)', 'rgba(255, 99, 132, 0.5)', "real");
var realVoltageChart = makeChart('voltage', "Voltagem (V)", 'rgb(54, 162, 235)', 'rgba(54, 162, 235, 0.5)', "real");



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

