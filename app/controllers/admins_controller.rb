class AdminsController < ApplicationController
	def index
		@admins = Admin.all
		@guests = Guest.all
		@hosts = Host.all
	end

	def analytics
	end

end
