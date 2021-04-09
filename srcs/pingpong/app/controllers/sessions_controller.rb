class SessionsController < Devise::SessionsController
	def destroy
		if current_user.otp_secret
			current_user.update_attribute(:otp_required, true)
		end
		super
		
	end
	
  end