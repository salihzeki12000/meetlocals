class StaticPagesController < ApplicationController

  def home
    @hosts = Host.where(approved: true).joins(:experiences).uniq.shuffle.take(3)
    # @recent_events = Experience.normal_events.order(created_at: :desc).limit(3)
    @host_party = Experience.available.special_events.order(:date).limit(3)
  end

  def how_it_works
  end

  def about
  end

  def explore
  end

  def terms_of_service
  end

  def page_not_found
  end

  def unknown_error
  end

  def press
    @posts = Post.where(post_type: "press").order('created_at DESC')
  end

  protect_from_forgery except: [:payment_success, :payment_failure]
  def payment_success
    if (request.request_method == "POST")
      redirect_to payment_success_path
    end
  end

  def payment_failure
    if (request.request_method == "POST")
      redirect_to payment_failure_path
    end
  end
end
