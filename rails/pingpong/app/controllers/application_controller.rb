class ApplicationController < ActionController::Base

	before_action :signed_in, unless: -> { home_controller? || devise_controller? }
	before_action :configure_permitted_parameters, if: :devise_controller?

	add_flash_types :success

	protected
    def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
	end

	private

	def signed_in
		redirect_to root_path unless user_signed_in? && :devise_controller?
	end

	def home_controller?
		return true if params[:controller] == "home"
	end

end
