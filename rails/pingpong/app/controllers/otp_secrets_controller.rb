class OtpSecretsController < ApplicationController
	require 'rubygems'
	require 'rotp'

	before_action	:if_have_auth, only: [:new, :create]
	before_action	:if_have_auth_destroy, only: [:destroy]

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
		p params[:otp_secret]
		totp = ROTP::TOTP.new(
		  @otp_secret, issuer: 'PingPong'
		)
	
		p "@@@@@@@@@*#@!*#!@*#************!@#*!@"
		p params
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
		  @qr_code = RQRCode::QRCode
			.new(totp.provisioning_uri(current_user.email))
			.as_png(resize_exactly_to: 200)
			.to_data_url
		  redirect_to otp_secrets_path, alert: "Wrong key!"
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
		  otp_attempt = params[:otp_attempt]
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

	  def if_have_auth_destroy
		redirect_to edit_user_registration_path, alert: "Doesn't have two-step" if !current_user.otp_secret
	  end

	  def if_have_auth
		redirect_to edit_user_registration_path, alert: "Already have two-step" if current_user.otp_secret
	  end
end
