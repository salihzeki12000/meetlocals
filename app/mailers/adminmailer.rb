class Adminmailer < ApplicationMailer
	def host_created(host_id, bank_number,bank_name,reg_number)
		@host = Host.find host_id
		@admin = Admin.find 1
		@bank_number = bank_number
		@bank_name = bank_name
		@registration_number = reg_number
		mail(to: @admin.email, subject: "A new host has been created!")
	end
end