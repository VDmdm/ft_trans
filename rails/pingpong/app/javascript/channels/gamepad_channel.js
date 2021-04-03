import consumer from "./consumer"

var prev;
var game_id = null;

var bla = function (e) {
  if (this.sub)
  {
    if ((e.keyCode === 38 || e.keyCode === 87) && prev != -1) {
      this.sub.send({ gamepad: $('#room-name').attr("data-room-id"), pad: -1 });
      prev = -1;
    }
    else if (e.keyCode === 40 || e.keyCode === 83 && prev != 1) {
      this.sub.send({ gamepad: $('#room-name').attr("data-room-id"), pad: 1 });
      prev = 1;
    }
  }
}

var bla2 = function (e) {
  if (this.sub)
  {
    if (e.keyCode === 38 || e.keyCode === 87) {
      this.sub.send({ gamepad: $('#room-name').attr("data-room-id"), pad: 0 });
      prev = 0;
    }
    else if (e.keyCode === 40 || e.keyCode === 83) {
      this.sub.send({ gamepad: $('#room-name').attr("data-room-id"), pad: 0 });
      prev = 0;
    }
  }
}

$(document).on("turbolinks:load", function() {
  //  if (this.sub && (!document.getElementById('game') || (game_id && game_id != $('#room-name').attr("data-room-id")))) {
  //    consumer.subscriptions.remove(this.sub);
  //    this.sub = null;
  //    game_id = null;
  // }
  if (document.getElementById('game')) {
    var sub = consumer.subscriptions.create({ channel: 'GamepadChannel', gamepad: $('#room-name').attr("data-room-id")}, {
      connected() {
        // Called when the subscription is ready for use on the server
        document.addEventListener('keydown', bla);
        document.addEventListener('keyup', bla2);
        this.game_id = $('#room-name').attr("data-room-id");
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
        document.removeEventListener('keydown', bla);
        document.removeEventListener('keyup', bla2);
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
      }
    });
    this.sub = sub;
  }
})