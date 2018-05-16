import "phoenix_html"
import socket from "./socket"

var panels = {
  "random": {
    "name": 'panels:random',
    "idAappend": '-random',
    "channel": socket.channel('panels:random', {}),
    "buf": {
      "current": [],
      "voltage": []
    }
  },
  "real": {
    "name": 'panels:real',
    "idAappend": '-real',
    "channel": socket.channel('panels:real', {}),
    "buf": {
      "current": [],
      "voltage": []
    }
  }
};

var channelOn = function(panel) {
  panels[panel].channel.on('value', function (payload) {
    console.log(panels[panel].buf)
    console.log(payload)

    panels[panel].buf.current.push({
      x: payload.current.timestamp * 1000,
      y: payload.current.value
    });

    panels[panel].buf.voltage.push({
      x: payload.voltage.timestamp * 1000,
      y: payload.voltage.value
    });
  });
}

channelOn("random");
channelOn("real");

var makeChart = function(buf_name, label, borderColor, backgroundColor, panel) {
  var id = buf_name + panels[panel].idAappend;
  var ctx = document.getElementById(id).getContext('2d');
  console.log(ctx)
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
                          chart.data.datasets[0].data, panels[panel].buf[buf_name]
                      );
                      panels[panel].buf[buf_name] = [];
                  }
              }
          }
      }
  });
}

panels.random.channel.join();
panels.real.channel.join();
makeChart('current', "Corrente", 'rgb(255, 99, 132)', 'rgba(255, 99, 132, 0.5)', "random");
makeChart('voltage', "Voltagem", 'rgb(54, 162, 235)', 'rgba(54, 162, 235, 0.5)', "random");
makeChart('current', "Corrente", 'rgb(255, 99, 132)', 'rgba(255, 99, 132, 0.5)', "real");
makeChart('voltage', "Voltagem", 'rgb(54, 162, 235)', 'rgba(54, 162, 235, 0.5)', "real");



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

