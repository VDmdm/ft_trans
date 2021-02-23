class OtpSecretsController < ApplicationController
	require 'rubygems'
	require 'rotp'
	def new
		@otp_secret = ROTP::Base32.random
		totp = ROTP::TOTP.new(
		  @otp_secret, issuer: 'PingPong'
		)
		@qr_code = RQRCode::QRCode
		  .new(totp.provisioning_uri(current_user.email))
		  .as_png(resize_exactly_to: 200)
		  .to_data_url
	end
	
	  def create
		@otp_secret = params[:otp_secret]
		totp = ROTP::TOTP.new(
		  @otp_secret, issuer: 'PingPong'
		)
	
		last_otp_at = totp.verify(
		  params[:otp_attempt], drift_behind: 15
		)
	
		if last_otp_at
		  current_user.update(
			otp_secret: @otp_secret, last_otp_at: last_otp_at
		  )
		  redirect_to(
			edit_user_registration_path,
			notice: 'Successfully configured OTP protection for your account'
		  )
		else
		  flash.now[:alert] = 'The code you provided was invalid!'
		  @qr_code = RQRCode::QRCode
			.new(totp.provisioning_uri(current_user.email))
			.as_png(resize_exactly_to: 200)
			.to_data_url
		  render :new
		end
	  end

	  def destroy
		current_user.update(
			otp_secret: nil, last_otp_at: nil
		  )
		  redirect_to(
			edit_user_registration_path,
			notice: 'Successfully turned off OTP protection for your account'
		  )
	  end

	  def login
	  end

	  def auth_logger
		otp_secret = current_user.otp_secret
		totp = ROTP::TOTP.new(
			otp_secret, issuer: 'PingPong'
		  )
		p "*$#%&(&$&#%*@($#*(#%&(@$&(#*$&*#(&$(*@$&(#$&(#&(%^@(^$%#%(#$(#*^$#^%^(@^%(#%(*#^%(@%^@$^#(*$^#(*%^#(%^#%^#(%"
		p params
		  otp_attempt = params[:otp_attempt]
		p otp_attempt.to_s
		p current_user
		p otp_secret

		  last_otp_at = totp.verify(
			otp_attempt.to_s, after: current_user.last_otp_at, drift_behind: 15
		  )
	  
		  if last_otp_at
			current_user.update(
				otp_required: false, last_otp_at: last_otp_at
			)
			redirect_to root_path, success: "Signed in"
		else
			redirect_back fallback_location: root_path, alert: "Incorrect token"
		end
			
	  end

end
