import consumer from "./consumer"

var prev;

$(document).on("turbolinks:load", function() {
  if (this.sub) {
    consumer.subscriptions.remove(this.sub);
    this.sub = null;
  }
  if (document.getElementById('game')) {
    var sub = consumer.subscriptions.create({ channel: 'GamepadChannel', game_room: $('#room-name').attr("data-room-id")}, {
      connected() {
        // Called when the subscription is ready for use on the server
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
      }
    });
    this.sub = sub;
    document.addEventListener('keydown', function (e) {
      if (this.sub)
      {
        if ((e.keyCode === 38 || e.keyCode === 87) && prev != -1) {
          this.sub.send({ game_room: $('#room-name').attr("data-room-id"), pad: -1 });
          prev = -1;
        }
        else if (e.keyCode === 40 || e.keyCode === 83 && prev != 1) {
          this.sub.send({ game_room: $('#room-name').attr("data-room-id"), pad: 1 });
          prev = 1;
        }
      }
    });
    document.addEventListener('keyup', function (e) {
      if (this.sub)
      {
        if (e.keyCode === 38 || e.keyCode === 87) {
          this.sub.send({ game_room: $('#room-name').attr("data-room-id"), pad: 0 });
          prev = 0;
        }
        else if (e.keyCode === 40 || e.keyCode === 83) {
          this.sub.send({ game_room: $('#room-name').attr("data-room-id"), pad: 0 });
          prev = 0;
        }
      }
    });
  }
})