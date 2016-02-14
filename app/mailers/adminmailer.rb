class Adminmailer < ApplicationMailer
	def host_created(host_id)
		@host = Host.find host_id
		mail(to: "info@meetthedanes.dk", subject: "A new host has been created!")
	end

	def experience_completed(host_id, guest_id)
		@host = Host.find host_id
		@guest = Guest.find guest_id
		@admin = Admin.first
		mail(to: @admin.email, subject: "A host has completed an experience")
	end

	def host_cancel(guest_id,host_id,booking_id)
		@guest = Guest.find guest_id
		@host = Host.find host_id
		@booking = Booking.find booking_id
		@admin = Admin.first
		mail(to: @admin.email, subject: "A host has canceled a booking")
	end

	def guest_cancel(guest_id,host_id,booking_id)
		@guest = Guest.find guest_id
		@host = Host.find host_id
		@booking = Booking.find booking_id
		@admin = Admin.first
		mail(to: @admin.email, subject: "A guest has canceled a booking")
	end

	def payment_reminder(booking_id, host_id)
		@host = Host.find host_id
		@booking = Booking.find booking_id
		@admin = Admin.first
		mail(to: @admin.email, subject: "A host payment is pending")
	end

	def guest_has_payed(guest_id,host_id,booking_id)
		@guest = Guest.find guest_id
		@host = Host.find host_id
		@booking = Booking.find booking_id
		@admin = Admin.first
		mail(to: @admin.email, subject: "A guest has completed payment")
	end	

	def email_to_hosts(host_id,body,title)
		@host = Host.find host_id
		@body = body
		mail(to: @host.email, subject: "#{title}")
	end
end