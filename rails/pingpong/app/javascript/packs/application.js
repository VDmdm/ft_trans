// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.


import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"


Rails.start()
Turbolinks.start()
ActiveStorage.start()

$(document).on("turbolinks:load", function() {
		$("#btnSubmit").attr("disabled", true);
		$("#users_search input").keyup(function() {
			$.get($("#users_search").attr("action"), $("#users_search").serialize(), null, "script");
			return false;
		  });
});

window.friend_invites_list_switch = function(sending) {
	if (sending)
	{
		document.getElementById('block-incoming').style.display = 'none';
		document.getElementById('block-sending').style.display = 'block';
		document.getElementById('switch-invites-btn-incoming').className = "";
		document.getElementById('switch-invites-btn-swnding').className = "btn-active";
	}
	else
	{
		document.getElementById('block-incoming').style.display = 'block';
		document.getElementById('block-sending').style.display = 'none';
		document.getElementById('switch-invites-btn-incoming').className = "btn-active";
		document.getElementById('switch-invites-btn-swnding').className = "";
	}
}

var canvas;
var context;
var max_speed;
var start_y;
var speed;
var ball_size;
var speed_up;
var random_mode;
var ball_down_mode;
var rate_speed;
var ball_down_rate;
var player_1_score;
var player_2_score;
var ball_color;
var paddle_color;
var background_color;

var grid;
var paddleHeight;
var maxPaddleY;
var paddleSpeed;

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

$(document).on("turbolinks:load", function() {
    if (!document.getElementById('game-preview')) {
      return;
    }
    start_game_preview();
});

window.start_game_preview = function() {
	canvas = document.getElementById("game-preview");
	context= canvas.getContext("2d");
	max_speed = 6.0;
	start_y = 10;
	speed = 2;
	ball_size = 1;
	speed_up = false;
	random_mode = false;
	ball_down_mode = false;
	rate_speed = 0.05;
	ball_down_rate = 0.05;
	player_1_score = 0;
	player_2_score = 0;
	ball_color = '#ffffff'
	background_color = '#000000'
	paddle_color = '#ffffff'

	grid = 13;
	paddleHeight = grid * 6;
	maxPaddleY = canvas.height - grid - paddleHeight;
	paddleSpeed = 4;

	leftPaddle = {
		x: grid / 2,
		y: canvas.height / 2 - paddleHeight / 2,
		width: grid,
		height: paddleHeight,
		dy: 0
	};

	rightPaddle = {
		x: canvas.width - grid * 1.5,
		y: canvas.height / 2 - paddleHeight / 2,
		width: grid,
		height: paddleHeight,
		dy: 0
	};

	ball = {
		x: canvas.width / 2 - (grid / 2),
		y: canvas.height / 2 - (grid / 2),
		radius: grid * ball_size,
		resetting: false,
		dx: speed,
		dy: -speed
	};

	var file_exist = false;

	window.main_loop_prewiew =  function() {
		drawFrame();
		check_collision();
		if (check_game_condition())
			setTimeout('main_loop_prewiew()', 1000);
		else
			setTimeout('main_loop_prewiew()', 5);
	}
	

	function drawFrame() {
		context.clearRect(0, 0, canvas.width, canvas.height)
		context.beginPath();
		if (file_exist)
		{
			context.clearRect(0, 0, canvas.width, canvas.height);
			context.drawImage(output,0,0,output.width,output.height,0,0,canvas.width,canvas.height);
		}

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
		context.fillText(player_1_score + ' : ' + player_2_score, canvas.width / 2 - 15, 30);

		context.fillStyle = ball_color;
		context.fillRect(ball.x, ball.y, ball.radius, ball.radius);
		context.fill();
	}
	

	function check_collision() {
		ball.y += ball.dy;
		ball.x += ball.dx;

		if ((ball.x) + ball.dx <= 0 || (ball.x + grid) + ball.dx >= canvas.width)
			ball.resetting = true;

		if (ball.y + ball.dy - grid <= 0 || (ball.y + ball.radius) + ball.dy + grid >= canvas.height)
			ball.dy = -1 * ball.dy;

		if (collides(ball, leftPaddle) || collides(ball, rightPaddle)) {
			if (speed_up && Math.abs(ball.dx) < max_speed)
				ball.dx = -1 * (ball.dx + (ball.dx * rate_speed));
			else
				ball.dx = -1 * ball.dx;
			if (random_mode)
				ball.dy = getRandomArbitrary(-start_y / 2, start_y / 2);
			if (ball_down_mode)
				ball.radius = ball.radius - (ball.radius * ball_down_rate)
		}
		
		paddleMotion(leftPaddle);
		paddleMotion(rightPaddle);
	}

	function paddleMotion(paddle) {
		paddle.y += paddle.dy;
		if (paddle.y > maxPaddleY)
			paddle.y = maxPaddleY;
		if (paddle.y < grid)
			paddle.y = grid;
	}

	function getRandomArbitrary(min, max) {
		return Math.random() * (max - min) + min;
	}

	function check_game_condition() {
		if (ball.resetting)
		{
			if ((ball.x + ball.radius) + ball.dx >= canvas.width)
				player_1_score += 1;
			else
				player_2_score += 1;
			ball.x = canvas.width / 2;
			ball.y = canvas.height / 2;
			ball.resetting = false;
			ball.radius = grid * ball_size;
			ball.dx = speed;
			ball.dy = -speed;
			return true;
		}
		return false;
	}

	function checkSign(num) {
		if (num > 0)
			return -1;
		else
			return 1;
	}

	function collides(obj_1, obj_2) {
		var left_x = obj_1.x;
		var right_x = obj_1.x + (obj_1.radius);
		if (left_x >= obj_2.x && left_x <= obj_2.x + obj_2.width &&
			obj_1.y >= obj_2.y && obj_1.y <= obj_2.y + obj_2.height)
		{
			obj_1.x = obj_2.x + obj_2.width;
			return true;
		}
		else if (right_x >= obj_2.x && right_x <= obj_2.x + obj_2.width &&
				obj_1.y >= obj_2.y && obj_1.y <= obj_2.y + obj_2.height)
		{
			obj_1.x = obj_2.x - obj_1.radius;
			return true;
		}
			
		return false;
	}

	document.addEventListener('keydown', function (e) {
		if (e.keyCode === 38) {
			rightPaddle.dy = -paddleSpeed;
		}
		else if (e.keyCode === 40) {
			rightPaddle.dy = paddleSpeed;
		}
		if (e.keyCode === 87) {
			leftPaddle.dy = -paddleSpeed;
		}
		else if (e.keyCode === 83) {
			leftPaddle.dy = paddleSpeed;
		}
	});
	
	document.addEventListener('keyup', function (e) {
		if (e.keyCode === 38 || e.keyCode === 40) {
			rightPaddle.dy = 0;
		}
		if (e.keyCode === 83 || e.keyCode === 87) {
			leftPaddle.dy = 0;
		}
	});

	const output = document.getElementById('output');

	if (window.FileList && window.File && window.FileReader) {
		document.getElementById('game_upload-bg-image').addEventListener('change', event => {
			output.src = '';
			file_exist = false;
			document.getElementById('file_exist').value = false;
			if (event.target.files[0])
			{
				background_color = "none";
				var file = event.target.files[0];
				if (!file.type || !file.type.match('image.*')) {
					
					return;
				}
				const reader = new FileReader();
				reader.addEventListener('load', event => {
					output.src = event.target.result;
					file_exist = true;
					document.getElementById('file_exist').value = true;
				});
				reader.readAsDataURL(file);
			}
		});
	}

	window.change_ballcolor = function(value) {
		ball_color = value;
	}

	window.change_backcolor = function(value) {
		document.getElementById('game-preview').style.backgroundColor = value;
		background_color = value;
	}

	window.change_paddlecolor = function(value) {
		paddle_color = value;
	}

	window.change_ballspeed = function(value) {
		document.getElementById('input_value_speed').value = value;
		speed = 2 * value;
	}

	window.change_balldownmode = function(value) {
		ball_down_mode = value;
	}

	window.change_speedup = function(value) {
		speed_up = value;
	}

	window.change_randommode = function(value) {
		random_mode = value;
	}

	window.change_ballsize = function(value) {
		document.getElementById('input_value_size').value = value;
		ball_size = value;
	}

	window.onload = function() {
		main_loop_prewiew();
	}
}