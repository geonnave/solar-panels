import "phoenix_html"
import socket from "./socket"

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
    "buffers": {}
  }
};

var append = function(html) {
  var container_inner = document.getElementById("canvas-container").innerHTML
  document.getElementById("canvas-container").innerHTML = container_inner + html
}

var appendTitle = function(title) {
  append('<h4 style="text-align: center; margin: 0 auto; font-size: 24px">' + title + '</h4><br>')
}

var appendCanvas = function(canvas_id) {
  append('<canvas style="height: 220px; width: 100%" id="'+canvas_id+'"></canvas>')
}

var appendDivider = function() {
  append('<hr/>')
}

var channelOn = function(panel) {
  panels[panel].channel.on('value', function (payload) {

    for (var i in payload["solar"]) {
      var reading = payload["solar"][i]
      var id = reading["id"]
      var data = reading["data"]

      if (panels[panel].buffers[id] == undefined || panels[panel].buffers[id] == null) {
        appendTitle("Painel id = " + id)
        appendCanvas(id + "current" + panels[panel].idAappend, "220px")
        appendCanvas(id + "voltage" + panels[panel].idAappend, "220px")
        appendCanvas(id + "temperature" + panels[panel].idAappend, "220px")
        appendCanvas(id + "battery" + panels[panel].idAappend, "220px")
        appendDivider()
      }
    }


    for (var i in payload["solar"]) {
      var reading = payload["solar"][i]
      console.log(reading);
      var id = reading["id"]
      var data = reading["data"]

      if (panels[panel].buffers[id] == undefined || panels[panel].buffers[id] == null) {
        panels[panel].buffers[id] = {
          "current": [],
          "voltage": [],
          "temperature": [],
          "battery": []
        }
        makeChart(id, "current", "Corrente (I)", "rgb(54, 162, 235)", "rgba(54, 162, 235, 0.5)", panel, 1000 * 60);
        makeChart(id, "voltage", "Tensão (T)", 'rgb(255, 99, 132)', 'rgba(255, 99, 132, 0.5)', panel, 1000 * 60);
        makeChart(id, "temperature", "Temperatura (T)", 'rgb(0, 204, 0)', 'rgba(0, 204, 0, 0.5)', panel, 1000 * 60);
        makeChart(id, "battery", "Bateria (B)", 'rgb(0, 0, 0)', 'rgba(0, 0, 0, 0.5)', panel, 1000 * 60);
        // makeChart(id, "temperature", "Temperatura (T)", panel, 1000 * 60);
        // makeChart(id, "battery", "Bateria (B)", panel, 1000 * 60);
      }

      panels[panel].buffers[id].current.push({
        x: payload.timestamp * 1000,
        y: data["I"]
      });
      panels[panel].buffers[id].voltage.push({
        x: payload.timestamp * 1000,
        y: data["V"]
      });
      panels[panel].buffers[id].temperature.push({
        x: payload.timestamp * 1000,
        y: data["T"]
      });
      panels[panel].buffers[id].battery.push({
        x: payload.timestamp * 1000,
        y: data["B"]
      });
    }
  });
}

// channelOn("daily");
channelOn("real");

var makeChart = function(buffer_id, buffer_name, label, border_color, color, panel, duration) {
  var id = buffer_id + buffer_name + panels[panel].idAappend;
  var ctx = document.getElementById(id).getContext('2d');
  return new Chart(ctx, {
      type: 'line',
      data: {
          datasets: [{
              data: [],
              label: label,
              borderColor: border_color, // line color
              backgroundColor: color, // fill color
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
                  duration: duration,
                  onRefresh: function(chart) {
                      Array.prototype.push.apply(
                          chart.data.datasets[0].data, panels[panel].buffers[buffer_id][buffer_name]
                      );
                      panels[panel].buffers[buffer_id][buffer_name] = [];
                  }
              }
          }
      }
  });
}

panels.daily.channel.join();
panels.real.channel.join();


// makeChart('voltage', "Tensão (V)", "real", 1000 * 60);
