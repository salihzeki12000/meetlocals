class MessagesController < ApplicationController
  def new
    @message = params[:message]
    new_message = Message.create(text: @message[:text],
                    sender_id: @message[:sender_id],
                    sender_type: @message[:sender_type],
                    booking_id: @message[:booking_id]  )

    booking = new_message.booking
    if new_message.sender_type == "host"
      guest = Guest.find(booking.guest_id)
      Guestmailer.guest_get_mail(guest.id,booking.id).deliver
    elsif new_message.sender_type == "guest"
      host = Host.find(booking.experience.host_id)
      Hostmailer.host_get_mail(host.id, booking.id).deliver
    end

    redirect_to "/bookings/#{@message[:booking_id]}"
  end

end
