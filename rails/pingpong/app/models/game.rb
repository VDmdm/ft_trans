class Game < ApplicationRecord
	has_one_attached :bg_image

	enum status: [ :pending, :ended ]
    belongs_to :p1, class_name: "User", foreign_key: "p1_id"
    belongs_to :p2, class_name: "User", foreign_key: "p2_id", optional: true
    
    validates  :name, presence: true, length: { maximum: 15, minimum: 4 }, uniqueness: true

    validates  :rating, presence: true, allow_blank: true
    validates  :private, presence: true, allow_blank: true
    validates  :passcode, presence: true, length: { maximum: 4, minimum: 4 }, if: :private?
    validates  :bg_image, attached: true, content_type: [:png, :jpg, :jpeg], size: { less_than: 10.megabytes , message: 'filesize to big' }, allow_blank: true

    validates  :ball_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :bg_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :random_mode, presence: true, allow_blank: true
    validates  :paddle_color, format: { with: /\A#[a-f0-9]{6}\z/, message: "Wrong color format!" }
    validates  :ball_size, :inclusion => 0.5..2.0
    validates  :speed_rate, :inclusion => 0.5..2.0

    # basic game logic and methods

    attr_accessor   :canvas_width,
                    :canvas_height,
                    :grid,
                    :speed,
                    :max_paddle_y,
                    :min_paddle_y,
                    :paddle_height,
                    :paddle_R,
                    :paddle_L,
                    :max_speed,
                    :ball_down_rate,
                    :ball

    after_initialize :set_params

    def start
        self.update(:started => DateTime.now)
        GameStateHash.instance.add_kv("paddle_p1_#{self.id}", 0)
        GameStateHash.instance.add_kv("paddle_p2_#{self.id}", 0)
        while true
            render()
            return if GameStateHash.instance.return_value("status_#{self.id}") == 'ended'
            check_collision()
            paddle_motion()
            if @ball[:reset]
                update_game_condition()
                @ball[:reset] = false
                sleep(2)
            else
                sleep(0.003)
            end
        end
    end

    private
    def set_params
        @canvas_width = 1064
        @canvas_height = 514
        @grid = 20
        @speed = 2 * self.speed_rate
        @max_speed = 6
        @paddle_height = @grid * 6
        @min_paddle_y = @grid
        @max_paddle_y = @canvas_height - @grid - @paddle_height

        @paddle_R = {
            x: @canvas_width - @grid * 1.5,
            y: @canvas_height / 2 - @paddle_height / 2,
            width: @grid,
            height: @paddle_height,
            dy: 0
        }

        @paddle_L = {
            x: @grid / 2,
            y: @canvas_height / 2 - @paddle_height / 2,
            width: @grid,
            height: @paddle_height,
            dy: 0
        }

        @ball = {
            x: @canvas_width / 2 - (@grid / 2),
            y: @canvas_height / 2 - (@grid / 2),
            radius: @grid * self.ball_size,
            resset: false,
            dx: @speed,
            dy: -@speed
        }

    end

    def render
        def render
            data = {"paddle_color": self.paddle_color,
                    "ball_color": self.ball_color,
                    "ball_size": self.ball_size,
                    "ball_x": self.ball[:x],
                    "ball_y":  self.ball[:y],
                    "ball_radius": self.ball[:radius],
                    "paddle_p1_y": self.paddle_L[:y],
                    "paddle_p2_y": self.paddle_R[:y],
                    "p1_score": self.p1_score,
                    "p2_score": self.p2_score }
            GameChannel.broadcast_to self, data
        end
    end

    def check_collision
        @ball[:y] += @ball[:dy]
        @ball[:x] += @ball[:dx]
        if (@ball[:x] + @ball[:dx] <= 0 ||
            @ball[:x] + @ball[:radius] + @ball[:dx] >= @canvas_width)
            @ball[:reset] = true;
        end

        if (@ball[:y] + @ball[:dy] - @grid <= 0 ||
            (@ball[:y] + @ball[:radius]) + @ball[:dy] + @grid >= @canvas_height)
            @ball[:dy] = -1 * @ball[:dy];
        end

        if (collides(@ball, @paddle_L) || collides(@ball, @paddle_R))
            if (self.ball_speedup_mode && @ball[:dx].abs() < @max_speed)
                @ball[:dx] = -1 * (@ball[:dx] + (@ball[:dx] * self.speed_rate));
            else
                @ball[:dx] = -1 * @ball[:dx];
            end
            if (self.random_mode)
                @ball[:dy] = rand(-5..5);
            end
            if (self.ball_down_mode)
                @ball[:radius] = @ball[:radius] - (@ball[:radius] * self.ball_down_rate)
            end
        end

    end

    def collides(obj_1, obj_2)
		left_x = obj_1[:x]
		right_x = obj_1[:x] + obj_1[:radius]
		if (left_x >= obj_2[:x] && left_x <= obj_2[:x] + obj_2[:width] &&
			obj_1[:y] >= obj_2[:y] && obj_1[:y] <= obj_2[:y] + obj_2[:height])
            
            obj_1[:x] = obj_2[:x] + obj_2[:width]
			return true
        elsif (right_x >= obj_2[:x] && right_x <= obj_2[:x] + obj_2[:width] &&
				obj_1[:y] >= obj_2[:y] && obj_1[:y] <= obj_2[:y] + obj_2[:height])
			obj_1[:x] = obj_2[:x] - obj_1[:radius]
			return true
        end
		return false
    end
    
    def paddle_motion

        @paddle_L[:y] += GameStateHash.instance.return_value("paddle_p1_#{self.id}")
        if (@paddle_L[:y] > @max_paddle_y)
            @paddle_L[:y] = @max_paddle_y
        end
        if (@paddle_L[:y] < @min_paddle_y)
            @paddle_L[:y] = @min_paddle_y
        end
        @paddle_R[:y] +=  GameStateHash.instance.return_value("paddle_p2_#{self.id}")
        if (@paddle_R[:y] > @max_paddle_y)
            @paddle_R[:y] = @max_paddle_y
        end
        if (@paddle_R[:y] < @min_paddle_y)
            @paddle_R[:y] = @min_paddle_y
        end
    end

    def update_game_condition
        if (@ball[:reset])
			if ((@ball[:x] + @ball[:radius]) + @ball[:dx] >= @canvas_width)
				self.p1_score += 1
			else
                self.p2_score += 1;
            end
            if (p1_score == 21 || p2_score == 21)
                GameStateHash.instance.add_kv("status_#{self.id}", "ended")
                GameStateHash.instance.delete_key("paddle_p2_#{self.id}")
                GameStateHash.instance.delete_key("paddle_p1_#{self.id}")
                self.status = :ended
                self.save
                return false
            end
			@ball[:x] = @canvas_width / 2
			@ball[:y] = @canvas_height / 2
			@ball[:reset] = false
			@ball[:radius] = @grid * self.ball_size
			@ball[:dx] = @speed
			@ball[:dy] = -@speed
			return true
        end
		return false
    end





end