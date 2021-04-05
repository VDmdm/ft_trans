import consumer from "./consumer"

var canvas;
var prev;
var context;
var ball_size;
var player_1_score;
var player_2_score;
var ball_color;
var paddle_color;
var grid;
var game_id = null;
var paddleHeight;
var winner = null;
var subscribe = null;


var leftPaddle = {
	x: 0,
	y: 0,
	width: 0,
	height: 0,
	dy: 0
};

var rightPaddle = {
	x: 0,
	y: 0,
	width: 0,
	height: 0,
	dy: 0
};

var ball = {
	x: 0,
	y: 0,
	radius: 0,
	resetting: 0,
	dx: 0,
	dy: 0,
};

window.start_game = function() {
	canvas = document.getElementById("game");
	context= canvas.getContext("2d");
	ball_size = 1;
	player_1_score = 0;
	player_2_score = 0;
	ball_color = '#ffffff'
	paddle_color = '#ffffff'

	grid = 20;
	paddleHeight = grid * 6;

	leftPaddle = {
		x: grid / 2,
		y: canvas.height / 2 - paddleHeight / 2,
		width: grid,
		height: paddleHeight,
	};

	rightPaddle = {
		x: canvas.width - grid * 1.5,
		y: canvas.height / 2 - paddleHeight / 2,
		width: grid,
		height: paddleHeight,
	};

	ball = {
		x: canvas.width / 2 - (grid / 2),
		y: canvas.height / 2 - (grid / 2),
		radius: grid * ball_size,
		resetting: false,
	};
	drawFrame();
}

window.drawFrame = function() {
		context.clearRect(0, 0, canvas.width, canvas.height)
		context.beginPath();

		context.fillStyle = paddle_color;
		context.fillRect(leftPaddle.x, leftPaddle.y, leftPaddle.width, leftPaddle.height);
		context.fillRect(rightPaddle.x, rightPaddle.y, rightPaddle.width, rightPaddle.height);
		context.fill();

		context.fillStyle = paddle_color;
		context.fillRect(0, 0, canvas.width, grid);
		context.fillRect(0, canvas.height - grid, canvas.width, canvas.height);
		context.fill();

		context.font = "25px PixelarRegularW01-Regular";
		context.fillStyle = paddle_color;
		context.fillText(player_1_score + ' : ' + player_2_score, canvas.width / 2 - 18, 50);
		context.font = "40px PixelarRegularW01-Regular";
		if (typeof(winner) == "string" && winner == "p1") {
			context.fillText("win", 50, 50);
			context.fillText("lose", canvas.width - 120, 50);
		}
		else if (typeof(winner) == "string" && winner == "p2") {
			context.fillText("lose", 40, 50);
			context.fillText("win", canvas.width - 110, 50);
		}

		context.fillStyle = ball_color;
		context.fillRect(ball.x, ball.y, ball.radius, ball.radius);
		context.fill();
}

$(document).on("turbolinks:load", function() {
	if (subscribe && (!document.getElementById('game'))) {
		// consumer.subscriptions.remove(subscribe.unsubscribe());
		subscribe.unsubscribe();
		subscribe = null;
		game_id = null;
	}
	if (document.getElementById('game')) {
		var nick = $('#nickname').text()
		start_game();
		subscribe = consumer.subscriptions.create({ channel: 'GameChannel', game: $('#room-name').attr("data-room-id")}, {
		connected() {
			// Called when the subscription is ready for use on the server
			game_id = $('#room-name').attr("data-room-id");
		},

		disconnected() {
			// Called when the subscription has been terminated by the server
		},

		received(data) {
			// Called when there's incoming data on the websocket for this channel
			ball_color = data.ball_color;
			paddle_color = data.paddle_color;
			ball_size = data.ball_size;
			ball.x = data.ball_x;
			ball.y = data.ball_y;
			ball.radius = data.ball_radius;
			leftPaddle.y = data.paddle_p1_y;
			rightPaddle.y = data.paddle_p2_y;
			player_1_score = data.p1_score;
			player_2_score = data.p2_score;
			winner = data.winner;
			if ($('.p1').text() != data.p1_nickname)
				$('.p1').text(data.p1_nickname);
			if (typeof(data.p2_nickname) == "string")
				$('.p2').text(data.p2_nickname);
			else
				$('.p2').text("waiting...");
			drawFrame();
			if (nick == data.p1_nickname)
			{
				if (data.p1_status == "ready")
					$('#ready_btn').text("not ready?");
				else if (data.p1_status == "not ready" || data.p1_status == "lags")
				{
					$('#ready_btn').text("ready?");
					$('.p1').css("color","white");
				}
			}
			else if (nick == data.p2_nickname)
			{
				if (data.p2_status == "ready")
					$('#ready_btn').text("not ready?");
				else if (data.p2_status == "not ready" || data.p2_status == "lags")
					$('#ready_btn').text("ready?");
			}
			if (data.p1_status == "ready")
				$('.p1').css("color","yellow");
			else
				$('.p1').css("color","white");
			if (data.p2_status == "ready")
				$('.p2').css("color","yellow");
			else
				$('.p2').css("color","white");
			if (typeof(data.p2_nickname) != "string" && nick != data.p1_nickname)
				document.getElementById('game-block-join-link').style.display = 'block';
			else
				document.getElementById('game-block-join-link').style.display = 'none';
		},
		});
	}
})