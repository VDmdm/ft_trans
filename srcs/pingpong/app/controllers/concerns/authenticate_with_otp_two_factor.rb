module AuthenticateWithOtpTwoFactor
	extend ActiveSupport::Concern


	def authenticate_with_otp_two_factor
	  user = self.resource = find_user
	  if user&.valid_password?(user_params[:password])
		prompt_for_otp_two_factor(user)
	  end
	end
  
	private
  
	def valid_otp_attempt?(user)
		@otp_secret = user.otp_secret
		totp = ROTP::TOTP.new(
		@otp_secret, issuer: 'PingPong'
		)

		last_otp_at = totp.verify(
		user_params[:otp_attempt], drift_behind: 15
		)

		if last_otp_at
			user.update(last_otp_at: last_otp_at)
		else
			return nil
		end
	end
  
	def prompt_for_otp_two_factor(user)
	  @user = user
  
	  render 'devise/sessions/two_factor'
	end
  
	def authenticate_user_with_otp_two_factor(user)
	  if valid_otp_attempt?(user)
		# Remove any lingering user data from login
		session.delete(:otp_user_id)
  
		remember_me(user) if user_params[:remember_me] == '1'
		user.save!
		sign_in(user, event: :authentication)
	  else
		flash.now[:alert] = 'Invalid two-factor code.'
		prompt_for_otp_two_factor(user)
	  end
	end
  
	def user_params
	  params.require(:user).permit(:email, :password, :remember_me, :otp_secret)
	end
  
	def find_user
	  if session[:otp_user_id]
		User.find(session[:otp_user_id])
	  elsif user_params[:email]
		User.find_by(email: user_params[:email])
	  end
	end
  
	def otp_two_factor_enabled?
	  find_user.otp_secret
	end
end